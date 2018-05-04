#!/bin/bash
#
## CO2MPAS AIO UpgradePack script 

VERSION_FILE_CHECK="AIO-1.7.3*.ver"
NEW_VERSION=
INFLATE_DIR=
declare -i WINPY_NPACKAGES=

set -u  # fail on unset variables
set -E  # funcs inherit traps
set -o pipefail

declare -i verbose
bad_opts='' bad_args='' dry_run='' force='' all_yes='' verbose=0

prog="$0"

HELP_OPENING="CO2MPAS upgrade-pack for ${VERSION_FILE_CHECK%.ver} --> $NEW_VERSION"

## Prefer `cat` instead of `read` command below (from https://serverfault.com/a/72511/215750)
#  because its exit-status is 1 when EOF.
# read -r -d '' help <<'EOF'
HELP=$(cat <<EOF
$HELP_OPENING

SYNTAX:
    $prog [options]
OPTIONS:
    -f|--force:         upgrade AIO even if not ${VERSION_FILE_CHECK%.ver}
    -h|--help           display this message
    -k|--keep-going:    continue working on errors
    -n|--dry-run:       pretend commands executed
    -v|--verbose:       print commands as executed
    -y|--yes:           answer all questions with yes (no interactive)

- Contains $WINPY_NPACKAGES new or updated python packages (wheels).
- Files will be inflated under \$TMP folder ($INFLATE_DIR).
EOF
)

####################################
# Cmdline parsing & validation.
####################################
#
parse_opt () {
    case "$1" in
        (-h|--help)
            echo "$HELP"
            exit
            ;;
        (-k|--keep-going)
            keep_going=true
            ;;
        (-f|--force)
            force=true
            ;;
        (-y|--yes)
            all_yes=true
            ;;
        (-n|--dry-run)
            dry_run=true
            ;;
        (-v|--verbose)
            verbose=$((verbose + 1))
            ;;
        (-[a-z]?*)
            parse_opt "-${1:1:1}"
            parse_opt "-${1:2}"
            ;;
        (-*)
            echo "p$1p"
            bad_opts="$bad_opts $1"
            ;;
        (*)
            bad_args="$bad_args $1"
            ;;
    esac
}

pargs_cmdline_args () {
    while [ $# -ne 0 ]; do
        parse_opt "$1"
        shift
    done
    if [ -n "$bad_opts$bad_args" ]; then
        yell "command received invalid options or arguments:" \
            "\n  bad options: $bad_opts" \
            "\n  unexpected args: $bad_args\nAborting.\n\n$HELP"
    fi

    rm="rm"
    tmp_rm="rm"
    cat="cat"
    cp="cp"
    rsync="rsync"
    mkdir="mkdir"
    tar="tar -v"
    pip="pip"
    tee="tee"
    exec 3>/dev/null  # &3 used for redirecting stuff to log.
    if [ $verbose -gt 0 ]; then
        rm="$rm -v"
        tmp_rm="$rm -v"
        cp="$cp -v"
        rsync="$rsync -v"
        mkdir="$mkdir -v"
        tar="$tar -v"
        exec 3>&2
        
        log "cmdline options:\n  - verbose: $verbose\n  - dry_run: $dry_run\n  - force  : $force" \
           "\n  - all_yes: $all_yes\n  - keep_going: $keep_going"
           
       if [ $verbose -gt 1 ]; then
            set -x
            pip="$pip -v"

            if [ $verbose -gt 2 ]; then
                set -v
                pip="$pip -vv"
            fi
        fi
    fi
    if [ -n "$dry_run" ]; then
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
reset=$(tput sgr0)
bold=$(tput bold)
red=$(tput setaf 1)
#red=$(tput setaf 6)    # redder
green=$(tput setaf 2)   # hard to tell from cyan/blue
tan=$(tput setaf 3)     # with bold only
blue=$(tput setaf 4)
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
    if [ -z "$all_yes" ]; then
        read -rs -p "${green}Ready to upgrade $OLD_AIO_VERSION --> $NEW_VERSION.  
  Press [Enter] to continue, or [Ctrl+C] to cancel? $reset"
        echo >&2
    fi
}


check_python_version () {
    local inpver="${1#AIO-}"
    _VALID_VERSION=$(python -c "import packaging.version as v;print(v.Version('$inpver'),end='')")
    _VALID_VERSION="AIO-$_VALID_VERSION"
}

check_existing_AIO () {
    ##  Check existing AIO's version and decide future-one.

    if [ -z "${AIODIR+x}" ];then
        yell "no \$AIODIR variable is defined!" \
        "\n  command must launch from an AIO-1.7.3+ console!\nAborting."
    fi

    AIODIR="$(cygpath "$AIODIR")"
    local old_version_files="$( find "$AIODIR" -maxdepth 1 -name "$VERSION_FILE_CHECK" -printf '%f ')"

    if [ -n "$old_version_files" ]; then
        ## Leninent handling of multiple version-files.
        #
        local allvers=( $old_version_files ) # var-to-array from; https://stackoverflow.com/a/15108607/548792
        OLD_AIO_VERSION=${allvers[0]%.ver}
        if [ ${#allvers[@]} -ne 1 ]; then
            warn "existing AIO has ${#allvers[@]} version-files: ${allvers[@]}" \
            "\n  Arbitrarily assumed the first one as authoritative: $OLD_AIO_VERSION"
        fi

    else  # no version-file found
        local old_version
        local msg="cannot locate existing AIO's version-file: $AIODIR/$VERSION_FILE_CHECK"
        msg="$msg\n  Command must launch from an AIO-1.7.3+ console!"
        if [ -n "$force" ]; then
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
    debug "cleaning any inflated pack-files in temporary folders..."
    $tmp_rm -rf "$INFLATE_DIR"
}

inflate_pack_files () {
    clean_inflated
    info "inflating pack-files in: $INFLATE_DIR"

    ## Find the lineno of the last B64 HEADER.
    #
    local match_text='UpgradePack_RAW_BYTES_BELOW'
    local lineno=$(grep --line-number --text "$match_text" "$prog" | cut -d: -f1 | tail -1)
    lineno=$(( lineno + 2 ))

    mkdir -p "$INFLATE_DIR"
    trap 'clean_inflated' EXIT
    ## NOTE: --exclude does not work when archiving.
    tail +$lineno "$prog" | tar --exclude=.keepme -xj -C "$INFLATE_DIR"

    local inflation_err=''
    for exp_dir in AIO wheelhouse; do
        [ -d "$INFLATE_DIR/$exp_dir" ] || inflation_err="$inflation_err\n  - missing dir: $exp_dir/"
    done
    local wheels="$(find "$INFLATE_DIR/wheelhouse" -name '*.whl')"
    wheels=( $wheels )
    local nwhl=${#wheels[@]}
    [ $nwhl -ne $WINPY_NPACKAGES ] && inflation_err="\n  - missmatch num-of-wheels: expected $WINPY_NPACKAGES, inflated $nwhl"
    
    if [ -n "$inflation_err" ]; then 
        yell "inflating upgrade-pack has failed due to: $inflation_err!\nAborting."
    fi
}

do_upgrade () {
    local old_version_file="$AIODIR/$OLD_AIO_VERSION.ver"
    local new_version_file="$AIODIR/$NEW_VERSION.ver"

    info "1. engrave new AIO-version..."
    if [ -f "$old_version_file" ]; then
        $cp "$old_version_file" "$new_version_file" 
    fi
    echo -e "\n$NEW_VERSION" | $tee -a "$AIODIR/$NEW_VERSION.ver" >&3

    info "2. upgrading WinPython packages..."
    $pip install --no-index --no-dependencies "$INFLATE_DIR"/wheelhouse/*.whl

    info "3. overlaying Apps files..."
    $rsync -r "$INFLATE_DIR/AIO/" "$AIODIR/"

    info "4. delete old AIO-version"
    if [ -f "$old_version_file" ]; then
        $rm "$old_version_file"
    fi
}

####################################
## Main body
####################################
notice "$HELP_OPENING\n  Use $prog --help for more options (e.g. --dry-run)"

pargs_cmdline_args "$@"
check_existing_AIO
inflate_pack_files
prompt_for_abort
do_upgrade

notice "successfully upgraded $OLD_AIO_VERSION --> $NEW_VERSION"

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
