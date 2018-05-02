########################
CO2MPAS ALLINONE archive
########################

Ingredients for a pre-populated archive with WinPython+Consoles+Graphviz to run *CO2MPAS* on *Windows*.

Building & Packaging
====================
The creation of a new AIO is based on 2 identical folder hierarchies:

- the ``./Archive/`` containing "template files" that should be copied in
- the ``./co2mpas_AIO/`` folder, that is the actual "AIO" to be 7zipped.

The bash-script ``./prepare.sh`` copies those files in their appropriate place and
performs various clean-up tasks. Running this script should be the last thing to do
before compressing the final archive (see step 4, below).

To build the 2nd AIO folder follow these steps:

1. The AIO folder is usually created by extracting a previous AIO version, to arrive
   in this hierarchy of folders and files::

     ./co2mpas_AIO/
       +--Apps/...
       +--CO2MPAS/...
       +--CO2MPAS.vbs
       +--CONSOLE.vbs
       +--INSTALL.vbs
       +--co2mpas-env.bat
       +--README

   Otherwise, follow the specific instructions for downloading and extracting each
   application under a separate folder in ``./co2mpas_AIO/Apps/``, as explained in the
   sections below.

2. Install latest `co2mpas` package with `pip` command (either from *PyPi* or locally,
   if i's a *dev* release) and run and test the basic commands and procedures to
   check everything works as planned.

3. The AIO has its own version in ``VERSION.txt`` file, distinct from *co2mpas*
   package, which is imprinted in various places, so you you have to modify it
   before running ``./prepare.sh``.

   The name of the containing folder must also contain the AIO version; since
   the AIO folder is always named ``co2mpas_AIO``, do run this command once
   in ``cmd.exe`` to arrive to a ``co2mpas_AIO-X.Y.Z`` name (and rename the
   junction in subsequent releases)::

         mklink  /J  C:\co2mpas_AIO-X.Y.Z  C:\Apps\allinone.git\co2mpas_AIO

   .. Tip:
      Remeber to respect PEP 440 version format (e.g. ``1.1.1b0`` but
      ``1.1.1.post0``).

4. Commit the 2 modified files above.

5. Execute the ``./prepare.sh`` script from a Bash launched **outside of the AIO folder!**

6. Finally, compress the ``C:\co2mpas_AIO-X.Y.Z`` folder created above using either
   the 7zip utility or the `Total-Commander+7zip plugin <https://www.ghisler.com/plugins.htm>`_.
   Use maximum compression.   Check the contents of the result 7zip archive are
   structured like the previous releases.

7. Deploy release:  Make sure release appropriately tagged and signed in git
   with your private key.

   - If "BETA": draft a new pre-release in private co2mpas repo
   - If "FINAL": draft a new release in private co2mpas repo with the
     "announcement email-text" in it.  If archive is deemed ok, copy text to
     public repo and repeat this step; modify `issue #8
     <https://github.com/JRCSTU/co2mpas-ta/issues/8>`_ to announce new release
     to subscribers of this issue.

  Study also `old release guidelines:
  <https://github.com/JRCSTU/co2mpas/wiki/Developer-Guidelines#release-checklist>`_


Apps
====
- Add ``prog-x.y.z.ver`` on each app-folder.


WinPython
---------
*WinPython* is a **portable** distribution, so certain procedure is needed
to maintain it.
The instructions below have been updated to reflect `March 2018's release
<https://github.com/winpython/winpython/issues/574`_:

.. Note:
   Specifically, when upgrading pip, always use this *WinPython* script:
   ``$aio/Apps/WinPython/scripts/upgrade_pip.bat``

   Otherwise, whatever pip install <package> you do, will not run if AIO folder moved.
   In any case, running ``$aio/Apps/WinPython/scripts/make_winpython_movable.bat``
   script wll fix both problems.


0. Extract the new WinPython in AIO in place of the old one.
   Or even better, extract it somewhere as a PRISTINE template,
   and copy it each time you need to to start over the upgrade.

1. Generate a list of all PRISTINE WinPython packages installed
   (or the packages from the earlier AIO).
   Keep this list open (e.g. in a total-commander lister window)::

       pip freeze > $tmp/winpy-3.5.6-pristine.freeze.txt

   Consult it whenever you need to see if a package is already installed.


2. Ensure *pip* upgraded::

    ## Upgrade PIP
    python -m pip install -U pip
    "python.exe" -c "from winpython import wppm;dist=wppm.Distribution(r'$WINPYDIR');dist.patch_standard_packages('pip', to_movable=True)"

3. Download latest get-pypi.dev::

    wget https://bootstrap.pypa.io/get-pip.py -O $WINPYDIRBASE/scripts/get-pip.py


2. Create an empty folder with co2mpas dependencies::

    DOWNDIR="$AIODIR/.."
    rm -rf "$DOWNDIR"
    mkdir -p "$DOWNDIR"

3. Download in there all CO2MPAS requirements::

    pip install -r co2mpas.git/requirements/dev.pip  -r ...

   and copy the last line for ``pip``'s output where it lists
   all installed packages.
   Then paste them in the following command::

    pip download -d "$DOWNDIR" ... (--pre)

4. Convert all tgz, zip to Wheels::

    pip wheel  --no-dependencies --wheel-dir=$DOWNDIR \
            foo.tgz ...

4. Download these packages from `Python Unofficial
   <https://www.lfd.uci.edu/~gohlke/pythonlibs/>`_::

    ## co2mpas deps
    #
    xgboost
    pycosat     # Why needed? (https://github.com/JRCSTU/co2mpas/issues/463)
    pyYAML

    ## For wormhole
    Twisted (+ constantly, incremental, Automat, hyperlink, zope.interface)  # for wormhole

    ## Good to have
    #
    pygit2
    OpenCV-...+contrib_opencl....whl

5. Download extra packages::

    pip download -d "$DOWNDIR" \
        magic-wormhole ViTables pipdeptree pip-tools
        ## wormhole deps
        pynacl txtorcon humanize txaio autobahn hkdf spake2 ipaddress pypiwin32
        asn1crypto cryptography pyopenssl pyasn1 pyasn1-modules service-identity
        ## polyvers deps
        flake8 flake8-builtins flake8-mutable coverage pytest-runner pytest-cov spectate con


6. DELETE packages from Download-dir that already exist in new WinPython
   (actually move them into some temporary folder, just in case....):

   .. Tip::
      A usefull regex to extract package-names from an IPython folder-list::

          dpacks = !ls $DOWNDIR
          todel = [re.search(r'(.+?)-\d', fname).group(1)
                  for fname in dpacks
                  if fname in winpy_pristine_packnames]

      Note that a ``py`` & ``pytest`` packages might match too many packages
      when used as a wildcards...


   - native packages (numpy/pandas/scipy/numexpr/...): MKL preferred!
   - system packages (pip/conda): irrelevant, generated by docker-image's conda,
     besides, `pip` needs ``pyton -m pip instal ...``.
   - ``co2mpas`` mistakenly downloaded.
   - AIO-redundant packages: TOO MANY!!
     but KEEP::

        dill, graphviz, easygui, asteval, doit, openpyxl, future,
        pandalone, regex, schema, tqdm, boltons, pykalman, xlwings,
        wltp, cachetools, setuptools-git, ddt

   - Interesting EXISTENT but UPGRADED packages (1 May 2018, latest WinPython)::

        Flask       1.0.1   <--0.12.2
        Pillow      5.1.0   <-- 5.0.0
        pytest      3.5.1   <-- 3.5.0
        Sphinx      1.7.4   <-- 1.7.2   UPGR
        sphinx_rtd-theme    0.2.4   <-- 0.3.0
        Tornado     5.0.2   <-- 4.5.3   UPGR
        tqdm        4.23.1  <-- 4.19.9  UPGR
        urlib3      1.22    <-- 1.22    UPGR
        XlsxWriter  1.0.4   <-- 1.0.2   UPGR
        xlwings     0.11.7  <-- 0.11.5  UPGR


7. UNINSTALL packages:
   - tensorflow: conflicting dependencies: requires: bleach==1.5.0
   - some(?) big packages::

        pip uninstall theano boto3 botocore nltk lasagne  # (DANGEROUS)

8. Finally install all packages in download-dir & co2mpas::

    pip install  --find-links "$DOWNDIR" --no-index \
            -r ../co2mpas.git/requirements/dev.pip
    pip install co2mpas[sampling]                        (--pre)
    cp co2mpas-xxx.whl  ~/packages
    co2mpas --version -v

8. Override from sources (May 2018: still needed?)::

    pip install git+https://github.com/ankostis/pyreadline@redisplay


6. HOTFIXES:
~~~~~~~~~~~~

- GitPython: cygpath fix:
  Copy ``git/utils.py`` from:
  https://github.com/gitpython-developers/GitPython/pull/639

- `imaplib noop Debug <https://bugs.python.org/issue26543>`_ error in
  https://github.com/python/cpython/blob/master/Lib/imaplib.py#L1217 ::

      - l = map(lambda x:'%s: "%s"' % (x[0], x[1][0] and '" "'.join(x[1]) or ''), l)
      + l = map(lambda x:'%s: "%s"' % (x[0], x[1][0] and '" "'.join(str(k) for k in x[1]) or ''), l)

  Or even better appply patch.

- Add ``__init__.py`` files::

      $WINPYDIRBASE/python-3.5.2.amd64/Lib/site-packages/mpl_toolkits/__init__.py
      $WINPYDIRBASE/python-3.6.1.amd64/lib/site-packages/google/__init__.py
      $WINPYDIRBASE/python-3.6.1.amd64/lib/site-packages/google/__init__.py

  to avoid warnings like that:

      2017-02-10 15:37:16,032:WARNI:py.warnings: AIO\Apps\WinPython\python-3.5.2.amd64\lib\importlib\_bootstrap_external.py:415: ImportWarning: Not importing directory AIO\apps\winpython\python-3.5.2.amd64\lib\site-packages\mpl_toolkits: missing __init__
   _warnings.warn(msg.format(portions[0]), ImportWarning)

- Add these lines in ``getpass.py#167`` standard-lib for polite Git msg (FIX)::


      if os.name =='nt':
          raise ValueError("Cannot derive user-name!\n  Is USERNAME env-var empty?")

- GnuPG:

  - Capture ``key_id`` from ENC_TO when encrypting, see
    https://bitbucket.org/vinay.sajip/python-gnupg/issues/83/handle-enc_to-to-acquire-key_id-on

  - Capture ``key_id/username`` when signing, see
    https://bitbucket.org/vinay.sajip/python-gnupg/pull-requests/21/fix-sign-capture-also-userid_hint-when/diffhttps://bitbucket.org/vinay.sajip/python-gnupg/pull-requests/21/fix-sign-capture-also-userid_hint-when/diffhttps://bitbucket.org/vinay.sajip/python-gnupg/issues/83/handle-enc_to-to-acquire-key_id-on

- pandas OpenPYXL usage::

    $WINPYDIRBASE/python-3.5.2.amd64/Lib/site-packages/pandas/io/excel.py

         L784:
         - self.book.remove_sheet(self.book.worksheets[0])
         + self.book.remove(self.book.worksheets[0])

to remove warning::

     15:47:55:WARNI:py.warnings: AIO\Apps\WinPython\python-3.5.2.amd64\lib\site-packages\openpyxl\workbook\workbook.py:182: DeprecationWarning: Call to deprecated function or class remove_sheet (Use wb.remove(worksheet) or del wb[sheetname]).
     def remove_sheet(self, worksheet):

- SOCKS:
  - https://github.com/python/cpython/pull/562 (socks library).

  - Link socks-errors (socks.py#711)::

        - except ValueError as ex:
        -     raise GeneralProxyError("HTTP proxy server sent invalid response")
        + except ValueError:
        +     raise GeneralProxyError("HTTP proxy server sent invalid response") from ex

  - Link socks-errors (socks.py#719)::

        - except ValueError:
        -     raise HTTPError("HTTP proxy server did not return a valid HTTP status")
        + except ValueError as ex:
        +     raise HTTPError(
        +         "HTTP proxy server did not return a valid HTTP status") from ex

  - Link socks-errors (socks.py#806)::

            - raise ProxyConnectionError(msg, error)
            + raise ProxyConnectionError(msg, error) from error

  - Link socks-errors (socks.py#817)::

                - raise GeneralProxyError("Socket error", error)
                + raise GeneralProxyError("Socket error", error) from error

- ``rainbow_logging_handler``: move ``import sys`` at the top of the file
  https://github.com/laysakura/rainbow_logging_handler/blob/master/rainbow_logging_handler/__init__.py#L210
  See https://github.com/laysakura/rainbow_logging_handler/issues/14

- ``exchangelib``:
  Just close pool; see https://github.com/ecederstrand/exchangelib/issues/160

- ``schedula``:
    Fix ``DispatcherAbort`` cstor, see https://github.com/vinci1it2000/schedula/pull/9


POSIX
-----

Cygwin:
~~~~~~~
DROPPED before 1.7.x release because `git-2.15+`, could not install
``pip instal git:-https://...``.

Upgrade:
- Download recent installer from: https://cygwin.com/install.html
- Write its version as ``cygwin_setup-x86_64-877.ver`` file next to it.
- Run it to get upgrade all installed packages.

Packages to install:
- git, git-completion, colordif, patch
- make, zip, unzip, bzip2, 7z, dos2unix, rsync, inetutils (telnet), nc
- openssh, curl, wget, gnupg
- procps, vim, vim-syntax

DOWNGRADE Git to 2.8.3 from timemachine or else ``pip install git+https://...``
FAILS if Git-2.12+!

    - http://ctm.crouchingtigerhiddenfruitbat.org/pub/cygwin/circa/64bit/2017/04/16/142118/index.html

MSYS2:
~~~~~~
Under *MSYS2* make sure ``wget curl openssh gnupg procps vim telnet``
exist after installing::

- ::

      pacman -S man git make tar zip p7zip unzip  dos2unix rsync \
                procps inetutils patch gnu-netcat colordiff

- Ensure *ssh* config-folder exists in WinUser's home dir
  (usually ``/c/Users/<user>/.ssh``) because as `explained
  <https://sourceforge.net/p/msys2/tickets/111/>`_:

    OpenSSH does never use the value of $HOME to
    search for the users configuration files! It always uses the
    value of the pw_dir field in /etc/passwd as the home directory.

  As dictated by `Cygwin instructions
  <https://cygwin.com/cygwin-ug-net/ntsec.html>`_, we musr modify
  ``/etc/nsswitch.conf`` accordingly::

      @L7:
      - db_home: cygwin desc
      + db_home: /%H

Install Git for Windows
^^^^^^^^^^^^^^^^^^^^^^^
MSYS-git after 2.13+ (tested with v2.17.0) is failing simple cmds
unless a MSYS2 console is running on the PC.
For instance::

    $ cd <some-git-repo>
    $ git log
    fatal: BUG: disabling cancellation: Invalid argument

See also: https://github.com/Alexpux/MINGW-packages/issues/3351#issuecomment-384413989

- Read guide at:
  https://github.com/git-for-windows/git/wiki/Install-inside-MSYS2-proper
- Ensure ``[MSYS2]/etc/pacman.conf`` patched with *mingw-git* repo
  (already included in ``Archive/MSYS2/`` subtree).
- Run cmds in the guide.
- Finally use the command from OP in:
  https://stackoverflow.com/questions/40262434/what-are-the-differences-between-msys-git-and-git-for-windows-mingw-w64-x86-64-g)::

  pacman -S mingw-w64-x86_64-git


Manually Install git-lfs:
^^^^^^^^^^^^^^^^^^^^^^^
- Download zip for windows from; https://github.com/git-lfs/git-lfs/releases,
- extract and copy ``git-lfs.exe --. $AIODIR/Apps/Cygwin/usr/bin``.


GnuPG:
------
- Download latest Gpg4Win from https://www.gpg4win.org/download.html,
  install locally, then copy installation folder into ``$AIODIR/Apps/GunPG/``.
  ``prepare.sh`` makes it portable by creating ``gpgconf.ctl`` in same dir
  as ``gpgconf.exe`` (https://www.gnupg.org/documentation/manuals/gnupg/gpgv.html)

- Execute this command to create ``$GNUPGHOME/pubring.kbx``::

      gpgconf --check-programs



ConsoleZ
--------
- Download from: https://github.com/cbucher/console/wiki/Downloads
- Copy-paste folder of the extracted zipped-release.
- Update ALLINONE-version in Window-title pattern in
  ``/Archive/Apps/Console/console.xml`` or copy the other way round.


clink:
-------
- Download *stripped-zip* from: https://github.com/mridgers/clink/pull/464#issuecomment-318199655
  to fix ``doskey`` issue on *Windows-10*.
- Update ``profile`` folder and *merge* bat to print *console help*.


Graphviz
--------
- Download from: http://www.graphviz.org/Download_windows.php
- Copy-paste folder of the extracted zipped-release.


node.js
-------

For declarative-widgets:

- Download and unzip the *7z* from: https://nodejs.org/dist/latest/
- OR install node.js according to this: https://gist.github.com/massahud/321a52f153e5d8f571be#file-portable-node-js-andnpm-on-windows-md
- ``npm install bower``


