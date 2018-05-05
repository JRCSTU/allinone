#!/bin/bash
#
## CO2MPAS AIO UpgradePack script

VERSION_FILE_CHECK="AIO-1.7.3*.ver"
NEW_VERSION=
INFLATE_DIR=
declare -i WINPY_NPACKAGES=

set -u  # fail on unset variables
set -E  # funcs inherit traps
#set -o pipefail  # code written &&  expects diffrently...

prog="$0"
declare -i verbose=0
BAD_OPTS= BAD_ARGS= DRY_RUN= FORCE= ALL_YES= INFLATE_ONLY= KEEP_INFLATED=

## ALL CMDS HERE 
#  (remember to add them also in verbose/dry-run)
#
CMDPATH="${CMDPATH:-/usr/bin}"
rm="${rm:=$CMDPATH/rm}"
    set +x
tmp_rm="${tmp_rm:=$CMDPATH/rm}"     # separate, not to --dry-run temp-folder
cat="${cat:=$CMDPATH/cat}"
cp="${cp:=$CMDPATH/cp}"
rsync="${rsync:=$CMDPATH/rsync}"
mkdir="${mkdir:=$CMDPATH/mkdir}"
tar="${tar:-$CMDPATH/tar}"
tee="${tee:=$CMDPATH/tee}"
find="${find:=$CMDPATH/find}"       # same filename in Windows path
grep="${grep:=$CMDPATH/grep}"
date="${date:=$CMDPATH/date}"
tput="${tput:=$CMDPATH/tput}"
cygpath="${cygpath:=$CMDPATH/cygpath}"
pip="${pip:=pip}"                   # python progs not in /usr/bin
python="${python:=python}"          # python progs not in /usr/bin


HELP_OPENING="CO2MPAS upgrade-pack for ${VERSION_FILE_CHECK%.ver} --> $NEW_VERSION"

## Prefer `cat` instead of `read` command below (from https://serverfault.com/a/72511/215750)
#  because its exit-status is 1 when EOF.
# read -r -d '' help <<'EOF'
HELP=$( $cat <<EOF
$HELP_OPENING

SYNTAX:
    $prog [options]
OPTIONS:
    -f|--force:         upgrade AIO even if not ${VERSION_FILE_CHECK%.ver}
    -h|--help           display this message
    --inflate-only      extract pack-files and exit
    -k|--keep-going:    continue working even if some upgrade steps fail
    --keep-inflated     do not clean up in  flated temporary dir
    -n|--dry-run:       pretend actions executed (pack-files always inflated)
    -v|--verbose:       print commands as executed
    -y|--yes:           answer all questions with yes (no interactive)

- Contains $WINPY_NPACKAGES new or updated python packages (wheels).
- Files will be inflated under \$TMP folder ($INFLATE_DIR).
- \$CMDPATH controls the execution path of all POSIX commands invoked.
EOF
)

####################################
# Cmdline parsing & validation.
####################################
#
parse_opt () {
    case "$1" in
        (--inflate-only)
            INFLATE_ONLY=true
            KEEP_INFLATED=true
            ;;
        (--keep-inflated)
            KEEP_INFLATED=true
            ;;
        (-h|--help)
            echo "$HELP"
                set +x
            exit
            ;;
        (-k|--keep-going)
            keep_going=true
            ;;
        (-f|--force)
            FORCE=true
            ;;
        (-y|--yes)
            ALL_YES=true
            ;;
        (-n|--dry-run)
            DRY_RUN=true
            ;;
        (-v|--verbose)
            verbose=$((verbose + 1))
            ;;
        (-[a-z]?*)
            ## recursively parse '-vvn'`' opts.`
            #
            parse_opt "-${1:1:1}"
            parse_opt "-${1:2}"
            ;;
        (-*)
            echo "p$1p"
            BAD_OPTS="$BAD_OPTS $1"
            ;;
        (*)
            BAD_ARGS="$BAD_ARGS $1"
            ;;
    esac
}


pargs_cmdline_args () {
    while [ $# -ne 0 ]; do
        parse_opt "$1"
        shift
    done
    if [ -n "$BAD_OPTS$BAD_ARGS" ]; then
        yell "command received invalid options or arguments:" \
            "\n  bad options: $BAD_OPTS" \
            "\n  unexpected args: $BAD_ARGS\nAborting.\n\n$HELP"
    fi

    exec 3>/dev/null  # &3 used for redirecting stuff to log.
    if [ $verbose -gt 0 ]; then
        rm="$rm -v"
        tmp_rm="$rm -v"
        cp="$cp -v"
        rsync="$rsync -v"
        mkdir="$mkdir -v"
        tar="$tar -v"
        exec 3>&2

        log "cmdline options:\n  - verbose: $verbose\n  - DRY_RUN: $DRY_RUN\n  - FORCE  : $FORCE" \
           "\n  - ALL_YES: $ALL_YES\n  - keep_going: $keep_going\n  - KEEP_INFLATED: $KEEP_INFLATED " \
           "\n  - INFLATE_ONLY: $INFLATE_ONLY"

       if [ $verbose -gt 1 ]; then
            set -v
            pip="$pip -v"

            if [ $verbose -gt 2 ]; then
                set -x
                pip="$pip -vv"
            fi
        fi
    fi
    if [ -n "$DRY_RUN" ]; then
        info "DRY-RUN actions..."
        cp="echo DRY-RUN $cp"
        rsync="$rsync --dry-run -v"
        rm="echo DRY-RUN $rm"
        mkdir="echo DRY-RUN $mkdir"
        tar="echo DRY-RUN $tar"
        pip="echo DRY-RUN $pip"
        tee="echo DRY-RUN $tee"
    fi
}


####################################
# Logging & Errors utils
####################################
#
## Logging from: https://natelandau.com/bash-scripting-utilities/
# Only those attributes below work in AIO-console.
#
reset=$($tput sgr0)
bold=$($tput bold)
red=$($tput setaf 1)
#red=$($tput setaf 6)    # redder
green=$($tput setaf 2)   # hard to tell from cyan/blue
tan=$($tput setaf 3)     # with bold only
blue=$($tput setaf 4)
log () {
    echo -e "$prog:" "$@" >&2
}
debug () {
    if [ $verbose -gt 0 ]; then
        log "$@"
    fi
}
info () {
    log $bold$blue"$@" $reset
}
notice () {
    log $bold$green"$@" $reset
}
warn () {
    log WARN: $bold$tan"$@" $reset
}
yell () {
    log ERR $bold$red"$@" $reset
    exit 1
}
keep_going=''  # Fail early on any error while script init.
err_report () {
    ## From: https://stackoverflow.com/a/185900/548792
    if [ -z "$keep_going" ]; then
        yell "aborted in line $1: ${2:-unspecified error}" \
            "\n  stack: ${FUNCNAME[@]:1}" \
            "\n  (relaunch with -v(vv) to debug it, or  -k to keep going)"
    else
        warn "error in line $1:${2:-unspecified error}\n  ...but KEEP GOING."
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
# Upgrade AIO functionality
####################################
#
prompt_for_abort() {
    if [ "$OLD_AIO_VERSION" = "$NEW_VERSION" ]; then
        SCRIPT_ACTION="RE-INSTALL into '$AIODIR', version $OLD_AIO_VERSION"
    else
        SCRIPT_ACTION="UPGRADE '$AIODIR', from version $OLD_AIO_VERSION --> $NEW_VERSION"
    fi

    if [ -z "$ALL_YES" ]; then
        read -rs -p "${green}Ready to $SCRIPT_ACTION
  Press [Enter] to continue, or [Ctrl+C] to cancel? $reset"
        echo >&2
    else
        notice "Proceeding to $SCRIPT_ACTION..."
    fi
}


check_python_version () {
    local inpver="${1#AIO-}"
    _VALID_VERSION=$( $python -c "import packaging.version as v;print(v.Version('$inpver'),end='')" )
}

check_existing_AIO () {
    ##  Check existing AIO's version and decide future-one.

    if [ -z "${AIODIR+x}" ];then
        yell "no \$AIODIR variable is defined!" \
        "\n  command must launch from an AIO-1.7.3+ console!\nAborting."
    fi

    AIODIR="$( $cygpath "$AIODIR" )"
    local old_version_files="$( $find "$AIODIR" -maxdepth 1 -name "$VERSION_FILE_CHECK" -printf '%f ')"

    if [ -n "$old_version_files" ]; then
        ## Leninent handling of multiple version-files.
        #
        local allvers=( $old_version_files ) # var-to-array from; https://stackoverflow.com/a/15108607/548792
        OLD_AIO_VERSION=${allvers[0]%.ver}
        OLD_AIO_VERSION=${OLD_AIO_VERSION#AIO-}
        if [ ${#allvers[@]} -ne 1 ]; then
            warn "existing AIO has ${#allvers[@]} version-files: ${allvers[@]}" \
            "\n  Arbitrarily assumed the first one as authoritative: $OLD_AIO_VERSION"
        fi

    else  # no version-file found
        local old_version
        local msg="cannot locate existing AIO's version-file: $AIODIR/$VERSION_FILE_CHECK"
        msg="$msg\n  Command must launch from an AIO-1.7.3+ console!"
        if [ -n "$FORCE" ]; then
            warn "$msg\n  ...but FORCED upgrade."

            while true; do
                read -p "${green}Which is your current AIO version? $reset" old_version
                [ -z "$old_version" ] && continue
                check_python_version "$old_version" || continue
                old_version="AIO-${_VALID_VERSION#AIO-}"
                if yesorno 'N' 1 "${green}Is your current version '$old_version'? [y/N]$reset"; then
                    OLD_AIO_VERSION="$old_version"
                    break
                fi
            done
        else
            yell "$msg\n  (use --force if you must)"
        fi
    fi

    NEW_VERSION="${OLD_AIO_VERSION%?${NEW_VERSION}}.$NEW_VERSION"
}


clean_inflated () {
    if [ -z "$KEEP_INFLATED" ]; then
        debug "cleaning any inflated pack-files in temporary folders..."
        $tmp_rm -rf "$INFLATE_DIR"
    fi
    
}


inflate_pack_files () {
    $tmp_rm -rf "$INFLATE_DIR"  # clean any remnants
    info "inflating pack-files in '$INFLATE_DIR'..."

    ## Find the lineno of the last B64 HEADER.
    #
    local match_text='UpgradePack_RAW_BYTES_BELOW'
    local lineno=$( $grep --line-number --text "$match_text" "$prog" | cut -d: -f1 | tail -1 )
    lineno=$(( lineno + 2 ))

    mkdir -p "$INFLATE_DIR"
    trap 'clean_inflated' EXIT
    ## NOTE: --exclude does not work when archiving.
    tail +$lineno "$prog" | tar --exclude=.keepme -xj -C "$INFLATE_DIR"

    ## Check some expected dirs exist.
    #
    local inflation_err=''
    for exp_dir in AIO wheelhouse; do
        [ -d "$INFLATE_DIR/$exp_dir" ] || inflation_err="$inflation_err\n  - missing dir: $exp_dir/"
    done

    ## Count wheels.
    #
    local wheels="$( $find "$INFLATE_DIR/wheelhouse" -name '*.whl' )"
    wheels=( $wheels )
    local nwhl=${#wheels[@]}
    [ $nwhl -ne $WINPY_NPACKAGES ] && inflation_err="\n  - missmatch num-of-wheels: expected $WINPY_NPACKAGES, inflated $nwhl"

    if [ -n "$inflation_err" ]; then
        yell "inflating upgrade-pack has failed due to: $inflation_err!\nAborting."
    fi
}


do_upgrade () {
    local old_version_file="$AIODIR/ΑΙΟ-$OLD_AIO_VERSION.ver"
    local new_version_file="$AIODIR/ΑΙΟ-$NEW_VERSION.ver"
    local -i nsteps=4
    local -i step=1

    logstep() { 
        info "$step of $nsteps: $1"
        let step++
    }

    logstep "engraving new version-file $new_version_file..."
    if [ -f "$old_version_file" ]; then
        $cp "$old_version_file" "$new_version_file"
    fi
    echo -e "\n$NEW_VERSION: $( $date )" | $tee -a "$AIODIR/AIO-$NEW_VERSION.ver" >&3

    logstep "upgrading WinPython packages..."
    $pip install --no-index "$INFLATE_DIR"/wheelhouse/*.whl

    logstep "overlaying Apps files..."
    $rsync -r "$INFLATE_DIR/AIO/" "$AIODIR/"

    logstep "deleting old version-file $old_version_file..."
    if [ -f "$old_version_file" ]; then
        $rm "$old_version_file"
    fi
}

####################################
## Main body
####################################
notice "$HELP_OPENING\n  Use $prog --help for more options (e.g. --dry-run)"

pargs_cmdline_args "$@"
inflate_pack_files
if [ -n "$INFLATE_ONLY" ]; then
    notice "inflated pack-files in '$INFLATE_DIR' and stopped."
    exit 0
fi
check_existing_AIO
prompt_for_abort
    set +x
do_upgrade

notice "finished $SCRIPT_ACTION successfully."

exit 0
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
#######################################################################
##                  UpgradePack_RAW_BYTES_BELOW                      ##
#######################################################################
