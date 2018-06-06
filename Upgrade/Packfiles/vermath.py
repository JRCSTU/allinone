#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright 2015-2018 European Commission (JRC);
# Licensed under the EUPL 1.2+ (the 'Licence');
# You may not use this work except in compliance with the Licence.
# You may obtain a copy of the Licence at: http://ec.europa.eu/idabc/eupl
#
"""Validate absolute versions or add relative ones on top of a base absolute."""

from typing import Union, Optional
import re

from packaging.version import InvalidVersion, Version, _parse_letter_version

import itertools as itt

VerLike = Union[str, Version]


def _packver(v: VerLike) -> Version:
    return v if isinstance(v, Version) else Version(str(v))


#: Possible to skip release-numbers, no local-part.
#: Adapted from :data:`packaging.VERSION_PATTERN`.
_relative_ver_regex = re.compile(r"""(?ix)
    ^\s*
    v?
    (?:
        (?P<op>[+^])                                      # relative operator
        (?P<fix>=?)                                       # fix pre/post/dev parts
        (?:(?P<epoch>[0-9]+)!)?                           # epoch
        (?P<release>[0-9]+(?:\.[0-9]+)*)?                 # release segment
        (?P<pre>                                          # pre-release
            (?P<fixpre>=?)                                # fix pre part
            [-_\.]?
            (?P<pre_l>(a|b|c|rc|alpha|beta|pre|preview))
            [-_\.]?
            (?P<pre_n>[0-9]+)?
        )?
        (?P<post>                                         # post release
            (?P<fixpost>=?)                                # fix post part
            (?:
                (?:-(?P<post_n1>[0-9]+))
                |
                (?:
                    [-_\.]?
                    (?P<post_l>post|rev|r)
                    [-_\.]?
                    (?P<post_n2>[0-9]+)?
                )
            )
        )?
        (?P<dev>                                          # dev release
            (?P<fixdev>=?)                                # fix dev part
            [-_\.]?
            (?P<dev_l>dev)
            [-_\.]?
            (?P<dev_n>[0-9]+)?
        )?
    )
    (?:\+(?P<local>[a-z0-9]+(?:[-_\.][a-z0-9]+)*))?       # local version
    \s*$""")


def is_version_id_relative(version_str: VerLike) -> bool:
    return _relative_ver_regex.match(str(version_str)) is not None


def _add_pre(base_tuple, rel_label, rel_num):
    assert base_tuple is not None or rel_label is not None, (
        base_tuple, rel_label, rel_num)
    if not rel_label:
        return base_tuple

    blabel, bnum = base_tuple or (None, 0)
    rlabel, rnum = _parse_letter_version(rel_label, rel_num)

    if blabel == rlabel:
        return blabel, bnum + rnum
    else:
        return rlabel, rnum


def _add_versions(base_ver: VerLike, relative_ver):
    ## TODO: epoch vermath, and update README
    bver = _packver(base_ver)
    m = _relative_ver_regex.match(str(relative_ver))
    if not m:
        raise InvalidVersion("Invalid relative version: {}".format(relative_ver))

    op = m.group('op')

    ver_nums = list(bver.release)
    rel_release = m.group('release')
    if rel_release:
        #
        ## Caret(^) makes a difference only for release-digits.

        rel_nums = [int(d) for d in rel_release.split('.')]
        if op == '^':
            ##  Extend caret version from base-version's last digit.
            #
            ver_nums[-1] += rel_nums[0]
            ver_nums.extend(rel_nums[1:])
        elif op == '+':
            ver_nums = [a + b
                        for a, b in itt.zip_longest(ver_nums, rel_nums, fillvalue=0)]
        else:
            raise AssertionError(op)

    parts = ['.'.join(str(i) for i in ver_nums)]

    fix_parts = bool(m.group('fix'))
    """When `fix`, pre/post/dev parts are not reset if earlier parts have changed,
       and relative-number is added on top of existing base one."""
    are_previous_parts_changed = bool(rel_release)
    """A rolling flag tracking if any earlier release/pre/post/dev part has changed.
       Used to decide whether to update/reset/clear the part-number ."""

    def is_part_in_new_version(rel_exist, base_exist, part_fix) -> bool:
        """
        decide whether the new-version must have pre/post/dev part,
        base on previous parts that have been updated.

        :param rel_exists:
            if relative-version has a pre/post/dev part
        :param base_exists:
            if base-version has a pre/post/dev part
        :return:
            true when the part must be updated
        """
        nonlocal are_previous_parts_changed

        must_update = bool(rel_exist or
                           base_exist and (not are_previous_parts_changed or
                                           fix_parts or
                                           part_fix))
        are_previous_parts_changed |= must_update

        return must_update

    def rebase_part(base_part: Optional[int]) -> int:
        "conditionally reset pre/post/dev part if earlier parts have changed"
        return (0
                if are_previous_parts_changed and not fix_parts else
                base_part or 0)

    if is_part_in_new_version(m.group('pre'), bver.pre, m.group('fixpre')):
        bver_pre = bver.pre
        if bver_pre:
            bver_pre = (bver_pre[0], rebase_part(bver_pre[1]))
        parts.append('%s%s' % _add_pre(bver_pre,
                                       m.group('pre_l'),
                                       m.group('pre_n')))

    if is_part_in_new_version(m.group('post'), bver.post is not None, m.group('fixpost')):
        rel_post = m.group('post_n1') or m.group('post_n2') or 0
        new_post = rebase_part(bver.post) + int(rel_post)
        parts.append(".post%s" % new_post)

    if is_part_in_new_version(m.group('dev'), bver.dev is not None, m.group('fixdev')):
        new_dev = rebase_part(bver.dev) + int(m.group('dev_n') or 0)
        parts.append(".dev%s" % new_dev)

    if bver.local:
        parts.append('+' + bver.local)

    new_version = ''.join(parts)

    return _packver(new_version)


def add_versions(v1: VerLike, *rel_versions: VerLike) -> Version:
    """return the "sum" of the the given two versions."""
    new_version = v1
    for v2 in rel_versions:
        new_version = _add_versions(new_version, v2)

    v1 = _packver(v1)
    ## TODO: make backward bump forceable.
    if new_version < v1:
        raise InvalidVersion("Backward bump is forbidden: %s -/-> %s" %
                           (v1, new_version))
    return new_version


if __name__ == '__main__':
    import sys

    print("Adding relver(%s) onto base(%s)." %
          (' '.join(sys.argv[2:]), sys.argv[1]), file=sys.stderr)
    print(add_versions(*sys.argv[1:]), end='')
