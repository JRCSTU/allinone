#!/bin/bash
#
# Upgrade-pack for CO2MPAS ${VERSION_FILE_CHECK%.ver} --> $NEW_VERSION
#
# SYNTAX:
#     $prog [options]
# OPTIONS:
#   -d|--debug                      like --keep-going, but break into a debug shell to fix problem
#   -h|--help                       display this message
#   --inflate-only                  extract pack-files and exit
#   -k|--keep-going:                continue working on errors (see also to --debug)
#   --keep-inflated                 do not clean up in  flated temporary dir, re-use it if exists
#   -n|--dry-run:                   pretend actions executed (pack-files always inflated)
#   --old-aio-version <VERSION>     don't ask user for it (used only if cannot locate AIO's version-file).
#   --steps <NUM> ...               run given upgrade-steps only (one-based)
#   -v|--verbose:                   increase verbosity (eg -vvv prints commands as executed)
#   -y|--yes:                       answer all questions with yes (no interactive)
#
# - Contains $WINPY_NPACKAGES new or updated python packages (wheels).
# - Files will be inflated (or reused) under \$TMP folder ($INFLATE_DIR).
# - \$CMDPATH controls the execution path of all POSIX commands invoked.
# - All options have env-var counterparts (eg. --dry-run <--> \$DRY_RUN).
# - Use \$ARCHIVE envvar to specify adiffferent 7z file than its self.
# - Config-variables: ${!CONF[@]}
#

set -u  # fail on unset variables
set -E  # funcs inherit traps
#set -o pipefail  # code written &&  expects diffrently...
set -a  # export all, to facilitate --debug sub-shell

VERSION_FILE_CHECK="AIO-1.7.3*.ver"
NEW_VERSION=

declare -i WINPY_NPACKAGES=

prog="$0"

declare -i VERBOSE="${VERBOSE:-0}"
declare -A CONF=(  # Wrapped in an array not to type var-names twice.
    [VERBOSE]="$VERBOSE"
    [AIODIR]="${AIODIR:=}"
    [WINPYDIR]="${WINPYDIR:=}"
    [STEPS]="${STEPS:=1 2 3 4 5 6}"  # 1-based
    [DRY_RUN]="${DRY_RUN:=}"
    [KEEP_GOING]="${KEEP_GOING:=}"
    [DEBUG]="${DEBUG:=}"
    [ALL_YES]="${ALL_YES:=}"
    [ARCHIVE]="${ARCHIVE:=$prog}"
    [INFLATE_DIR]="${INFLATE_DIR:=.}"
    [OLD_AIO_VERSION]="${OLD_AIO_VERSION:=}"
    ## Recomendation: https://pip.pypa.io/en/stable/user_guide/#installation-bundles
    #[PIP_INSTALL_OPTS]="${PIP_INSTALL_OPTS:=--force-reinstall --ignore-installed --upgrade --no-index --no-deps}"
    [PIP_INSTALL_OPTS]="${PIP_INSTALL_OPTS:=--no-index --no-deps}"
)

#exec 2> >(tee -ia "$AIODIR/install.log") >&2
exec 3>/dev/null  # &3 used for redirecting `tee` to log when verbose.

## ALL CMDS HERE
#  (remember to add them also in verbose/dry-run)
#
CONF_CMDS=(
    "${CMDPATH:=/usr/bin}"
    "${rm:=$CMDPATH/rm}"
    "${mv:=$CMDPATH/mv}"
    "${cat:=$CMDPATH/cat}"
    "${cp:=$CMDPATH/cp}"
    "${rsync:=$CMDPATH/rsync}"
    "${patch:=$CMDPATH/patch -uN}"
    "${tee:=$CMDPATH/tee}"
    "${find:=$CMDPATH/find}"        # same filename in Windows path
    "${grep:=$CMDPATH/grep}"
    "${sed:=$CMDPATH/sed}"
    "${date:=$CMDPATH/date}"
    "${tput:=$CMDPATH/tput}"
    "${cygpath:=$CMDPATH/cygpath}"
    "${cmd:=$COMSPEC}"
    "${pip:=$WINPYDIR/Scripts/pip}"
    "${gpg2:=gpg2}"

    "${python:=$WINPYDIR/python}"

    ## Differentiate, not to --dry-run pack-files inflation.
    #
    "${infl_rm:=$rm}"
    "${infl_awk:=$CMDPATH/awk}"
    "${infl_python:=$python}"
)


####################################
# Cmdline parsing & validation.
####################################
#
build_help () {
    local -a help_lines
    ## Read as array (from https://unix.stackexchange.com/a/205073/156357)
    #  and remove the 2-char comment prefix.
    #
    HELP=$(sed '1,2d; /^$/q; s/^# *//' "$prog")
    HELP_OPENING="$(echo "$HELP"| head -n1)"

    # Expand variables, from https://stackoverflow.com/a/27948896/548792
    #
    HELP=$(eval "echo \"$HELP\"")
    HELP_OPENING=$(eval "echo \"$HELP_OPENING\"")
}

BAD_OPTS= BAD_ARGS=
declare -i SHIFTARGS=0
parse_opt () {
    SHIFTARGS=1
    case "$1" in
        (--steps)
            if [ $# -lt 2 ]; then
                BAD_OPTS="$BAD_OPTS $1(step number missing)"
            else
                local step
                for step in "${@:2}"; do
                    if ! [[ $step =~ ^[0-9]+$ ]]; then
                        if [ $SHIFTARGS -lt 2 ]; then
                            BAD_OPTS="$BAD_OPTS $1(followed by a non number '$step')"
                        fi
                        break
                    fi
                    let SHIFTARGS++
                done

                local -i nsteps
                nsteps=$(($SHIFTARGS - 1))
                STEPS="${@:2:$nsteps}"
            fi
            ;;
        (--old-aio-version)
            if [ $# -lt 2 ]; then
                BAD_OPTS="$BAD_OPTS $1(version missing)"
            elif [ "${2#-}" != "$2" ]; then
                BAD_OPTS="$BAD_OPTS $1(followed by option $2)"
            else
                OLD_AIO_VERSION=$2
                SHIFTARGS=2
            fi
            ;;
        (-h|--help)
            echo "$HELP"
                set +x
            exit
            ;;
        (-k|--keep-going)
            KEEP_GOING=1
            ;;
        (-d|--debug)
            DEBUG=1
            ;;
        (-y|--yes)
            ALL_YES=1
            patch="$patch -ft"
            ;;
        (-n|--dry-run)
            DRY_RUN=1
            ;;
        (-v|--verbose)
            VERBOSE=$((VERBOSE + 1))
            ;;
        (-[a-z]?*)
            ## recursively parse '-vvn'`' opts.`
            #
            parse_opt "-${1:1:1}"
            parse_opt "-${1:2}"
            ;;
        (-*)
            BAD_OPTS="$BAD_OPTS $1"
            ;;
        (*)
            BAD_ARGS="$BAD_ARGS $1"
            ;;
    esac
}


parse_cmdline_args () {
    while [ $# -ne 0 ]; do
        parse_opt "$@"
        shift $SHIFTARGS
    done
    if [ -n "$BAD_OPTS$BAD_ARGS" ]; then
        die "command received invalid options or arguments:" \
            "\n  bad options: $BAD_OPTS" \
            "\n  unexpected args: $BAD_ARGS\nAborting.\n\n$HELP"
    fi

    if [ -n "$DRY_RUN" ]; then
        DRY_RUN="PRETEND "
        info "${DRY_RUN}actions..."
        cp="echo $DRY_RUN$cp"
        rsync="$rsync --dry-run"
        patch="$patch --dry-run"
        rm="echo $DRY_RUN$rm"
        mv="echo $DRY_RUN$mv"
        tee="echo $DRY_RUN$tee"
        sed="echo $DRY_RUN$sed"
        pip="echo $DRY_RUN$pip"
        gpg2="echo $DRY_RUN$gpg2"
        python="echo $DRY_RUN$python"
        cmd="echo $DRY_RUN$cmd"
    fi

    if [ $VERBOSE -gt 0 ]; then
        local confdump=

        rm="$rm -v"
        cp="$cp -v"
        rsync="$rsync -v"
        patch="$patch --verbose"
        infl_rm="$rm -v"
        exec 3>&2

       if [ $VERBOSE -gt 1 ]; then
            confdump=$( set -o posix; set )
            (set -o posix; set)
            pip="$pip -vv"
            rsync="$rsync -v"
            if [ $VERBOSE -gt 2 ]; then
                set -x
            fi
        else
            confdump="- configuration: $(declare -p CONF) \n- command paths: ${CONF_CMDS[@]}"
        fi

        log "$confdump\n$reset"
        ## Variable printing above surely garbled terminal.
        stty sane
        log $reset
    fi
}


####################################
# Logging & Errors utils
####################################
#
## Logging from: https://natelandau.com/bash-scripting-utilities/
# Only those attributes below work in AIO-console.
#
bold=$($tput bold)
red=$($tput setaf 1)
#red=$($tput setaf 6)    # redder
green=$($tput setaf 2)   # hard to tell from cyan/blue
tan=$($tput setaf 3)     # with bold only
blue=$($tput setaf 4)
reset=$($tput sgr0)
log () {
    echo -e "$prog:" "$@" >&2
}
debug () {
    if [ $VERBOSE -gt 0 ]; then
        log "$@"
    fi
}
info () {
    log $bold$blue"$@"$reset
}
notice () {
    log $bold$green"$@"$reset
}
warn () {
    log WARN: $bold$tan"$@"$reset
}
error () {
    log ERR: $bold$red"$@"$reset
}
die () {
    log FATAL $bold$red"$@"$reset
    exit 1
}
launch_debug_shell() {
    local banner="$bold${green}Broke into DEBUG shell.
  - All functions and variables have been inherited.
  - Exit when done to continue.
  - Exit with non-zero status to abort program.$reset"

        # From: https://stackoverflow.com/a/7193037/548792
        if ! bash --rcfile <(echo "export PS1='\[\033[33m\][$prog: line $1]\[\033[0m\] > ' &&  echo -e \"\$banner\""); then
            die "Aborted by debug shell."
        fi

}
err_report () {
    ## Adapted from: https://stackoverflow.com/a/185900/548792
    local err="aborted in line $1: ${2:-unspecified error}"
    err+="\n  stack: ${FUNCNAME[@]:1}"
    if [ -n "$DEBUG" ]; then
        error "$err"
        launch_debug_shell "$@"
    elif [ -n "$KEEP_GOING" ]; then
        error "$err$green\n  ...but KEEP GOING."
    else
        die "$err\n  (relaunch with -v(vv) and ask for help)"
    fi
}
trap 'err_report $LINENO  "$BASH_COMMAND"' ERR


####################################
# Generic utils
####################################
#
in_str() {
    ## $ in_str 'b' 'abc && echo ok
    #  ok
    #  from https://stackoverflow.com/a/20460402/548792
    [ -z "${2##*$1*}" ];
}
yesorno() {
    local resp default_key="$1" default_ret="$2"  msg="${@:3}"
    while true; do
        echo "$msg" >&2
        while read resp; do
            [ -z "$resp" ] && echo "$default_key" && return $default_ret
            [ ${#resp} -ne 1 ] && continue
            in_str $resp 'yY' && return 0
            in_str $resp 'nN' && return 1
        done
    done
}


####################################
# AIO checks
####################################
#
check_python_version () {
    local inpver="${1#AIO-}"
    _VALID_VERSION=$( $infl_python -c "import packaging.version as v;print(v.Version('$inpver'),end='')" )
}


add_versions () {
    NEW_VERSION="$( PYTHONPATH="$INFLATE_DIR/wheelhouse/packaging-17.1-py2.py3-none-any.whl" \
                $infl_python "$INFLATE_DIR/vermath.py" "${OLD_AIO_VERSION}" "+$NEW_VERSION" )"

}

check_existing_AIO () {
    ##  Check existing AIO's version and decide future-one.
    local action_prefix="$1"

    if [ -z "${AIODIR:+x}" ];then
        die "no \$AIODIR variable is defined!" \
        "\n  command must launch from an AIO-1.7.3+ console!\nAborting."
    fi

    AIODIR="$( $cygpath "$AIODIR" )"
    local old_version_files="$( $find "$AIODIR" -maxdepth 1 -name "$VERSION_FILE_CHECK" \
                                -printf '%T@\0%f\n' | sort -rn | cut -d '' -f2 )"

    if [ -n "$old_version_files" ]; then
        if [ -n "$OLD_AIO_VERSION" ]; then
            warn "ignoring given old---aio-version: $OLD_AIO_VERSION"
        fi
        ## Leninent handling of multiple version-files.
        #
        local allvers=( $old_version_files ) # var-to-array from; https://stackoverflow.com/a/15108607/548792
        OLD_AIO_VERSION=${allvers[0]%.ver}
        OLD_AIO_VERSION=${OLD_AIO_VERSION#AIO-}
        if [ ${#allvers[@]} -ne 1 ]; then
            warn "existing AIO has ${#allvers[@]} version-files: ${allvers[@]}" \
            "\n  Assumiming arbitrarily the latest  chronologically is the authoritative one: $OLD_AIO_VERSION"
        fi

    else  # no version-file found
        local old_version
        local msg="cannot locate existing AIO's version-file: $AIODIR/$VERSION_FILE_CHECK"

        if [ -n "$OLD_AIO_VERSION" ]; then
            warn "$msg$blue\n  using given version: $OLD_AIO_VERSION"
            check_python_version "$OLD_AIO_VERSION" || die "invalid --old-aio-version $OLD_AIO_VERSION"

        else  # none given from cmdline, ask user.
            warn "$msg"

            while true; do
                read -p "${green}Which is your current AIO version? $reset" old_version
                [ -z "$old_version" ] && continue
                if check_python_version "$old_version"; then
                    OLD_AIO_VERSION="${_VALID_VERSION#AIO-}"
                    break
                fi
            done
        fi
    fi

    add_versions
    if [ "$OLD_AIO_VERSION" = "$NEW_VERSION" ]; then
        SCRIPT_ACTION="RE-INSTALL into '$AIODIR', version $OLD_AIO_VERSION"
    else
        SCRIPT_ACTION="UPGRADE '$AIODIR', from version: $OLD_AIO_VERSION --> $NEW_VERSION"
    fi
    SCRIPT_ACTION="$action_prefix$SCRIPT_ACTION"

    ## Update also teminal title
    #  from: https://askubuntu.com/questions/636944/how-to-change-the-title
    echo -e "\033]0;$SCRIPT_ACTION\a"
}



prompt_for_abort() {
    if [ -z "$ALL_YES" ]; then
        read -rs -p "${green}Ready to $SCRIPT_ACTION
  Press [Enter] to continue, or [Ctrl+C] to cancel? $reset"
        echo >&2  # Add new-line as feedback when user proceeds.
    else
        notice "Proceeding to $SCRIPT_ACTION..."
    fi
}


do_delete_old_version_file() {
    ## This marks the end of all setup.
    local old_version_file="$AIODIR/ΑΙΟ-$OLD_AIO_VERSION.ver"

    logstep "${DRY_RUN}deleting old version-file $old_version_file..."
    if [ -f "$old_version_file" ]; then
        $rm "$old_version_file"
    fi

}

run_upgrade_steps () {
    ## Launches all (or selected by `STEPS`) given functions, with `logstep` variable for logging.
    local -i nsteps=${#@}
    local -a step_funcs=("$@")
    local -i step
    local step_func

    stty sane; log $reset
    prompt_for_abort

    logstep() {
        info "$step of $nsteps: $1"
    }

    if [ -z "$STEPS" ]; then
        STEPS=$(seq 1 nsteps)
    fi

    info "steps to run: "$STEPS

    for step in $STEPS; do
        if [ -v "step_funcs[$(( $step - 1 ))]" ]; then
            step_func="${step_funcs[$(( $step - 1 ))]}"
            "$step_func"
        else
            warn "ignoring invalid step $step!"
        fi
    done
}

####################################
# Upgrade AIO STAGE-1
####################################
#

do_new_version_file() {
    local old_version_file="$AIODIR/ΑΙΟ-$OLD_AIO_VERSION.ver"
    local new_version_file="$AIODIR/ΑΙΟ-$NEW_VERSION.ver"
    logstep "${DRY_RUN}engraving new version-file '$new_version_file'..."
    if [ -f "$old_version_file" ]; then
        $cp "$old_version_file" "$new_version_file"
    fi
    echo -e "\n$NEW_VERSION: $( $date )" | $tee -a "$AIODIR/AIO-$NEW_VERSION.ver" >&3
}
do_upgrade_winpy() {
    ## Recomendation: https://docs.python.org/3/distributing/index.html#installing-the-tools
    logstep "${DRY_RUN}upgrading WinPython packages..."
    local basepacks_regex='(pip|setuptools|wheel|twine)-.*\.whl'
    cd "$INFLATE_DIR/wheelhouse"

    $pip uninstall co2mpas -y
    $find . -name '*.whl' | grep -E $basepacks_regex | \
            xargs $python -m pip install $PIP_INSTALL_OPTS
    yes | $cmd /c "$(cygpath -w "$AIODIR/Apps/WinPython/scripts/make_winpython_movable.bat")"
    ## For opts: https://pip.pypa.io/en/stable/user_guide/#installation-bundles
    $find . -name '*.whl' | grep -vE "$basepacks_regex" | \
            xargs $pip install $PIP_INSTALL_OPTS
    cd -
}
do_overlay_aio_files() {
    logstep "${DRY_RUN}overlaying Apps files..."
    $rsync -r "$INFLATE_DIR/AIO/" "$AIODIR/"
}
do_extend_test_key_expiration() {
    logstep "${DRY_RUN}extending test-key expiration date..."
    printf 'expire\n1m\nsave\n' | $gpg2  --batch --yes --command-fd 0 --status-fd 2 --edit-key 5464E04EE547D1FEDCAC4342B124C999CBBB52FF
}
do_remove_co2mpas_bash_completion () {
 logstep "${DRY_RUN}removing co2mpas-command autocompletion, was broken..."
 $sed -i.orig '/complete -fdev .* co2mpas$/d' ~/.bashrc
 $rm -f $AIODIR/Apps/clink/profile/co2mpas_autocompletion.lua
}
## UNUSED, if used, remeber it needs 1.9+ `env_bat()`.
do_make_stage_2_script() {
    logstep "${DRY_RUN}creating stage-2 upgrade file (to upgrade MSYS2/console on next launch)..."
    $sed "/^# Upgrade AIO STAGE-1/Q" "$prog" |  $tee "$AIODIR/upgrade.sh" >&3
    $cat "$INFLATE_DIR/upgrade2-footer.sh" | $tee -a "$AIODIR/upgrade.sh" >&3

notice "You need to exit all AIO-console instances and relaunch it,
to complete STAGE-2 of the upgrade."
}

####################################
## Main body
####################################
build_help
notice "STAGE-1 of $HELP_OPENING\n  Use $prog --help for more options (e.g. --dry-run)"
parse_cmdline_args "$@"

check_existing_AIO "STAGE-1 of "
run_upgrade_steps \
    do_new_version_file \
    do_upgrade_winpy \
    do_overlay_aio_files \
    do_extend_test_key_expiration \
    do_remove_co2mpas_bash_completion \
    do_delete_old_version_file

notice "finished $DRY_RUN$SCRIPT_ACTION successfully."

exit 0
