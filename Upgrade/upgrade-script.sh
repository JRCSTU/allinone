#!/bin/bash
#
## Upgrade AIO

VERSION_FILE_CHECK="AIO-1.7.3*.ver"
NEW_VERSION="AIO-1.7.3.2018.1.a2"
INFLATE_DIR="$TMP/CO2MPAS_AIO/UpgradePack-1.7.3+2018.1.ver"

set -u  # fail on unset variables
set -o pipefail

##################
# Utilities
##################
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
info () {    
    log $bold$blue "$@" $reset
}
notice () {    
    log $bold$green "$@" $reset
}
yell () {
    log $bold$red "$@" $reset
    exit 1
}
keep_going=''  # Fail early on any error while script init.
err_report () {
    ## From: https://stackoverflow.com/a/185900/548792
    if [ -z "$keep_going" ]; then
        yell "aborted in line $1: ${2:-unspecified error}" \
            "\n  (use -k to keep going, -v to debug it)"
    else
        info "error in line $1:${2:-unspecified error}\n  ...but KEEP GOING."
    fi
}
trap 'err_report $LINENO  $BASH_COMMAND' ERR

prog="$0"
my_dir="$(dirname "$0")"


##################
# MAIN FUNCTIONS
##################
#
prompt_for_abort() {
    local msg="upgrade $AIOVERSION..."
    if [ -n "$all_yes" ]; then
        info "started $msg"
    else
        info "ready to $msg\n  Press any key to continue, or [Ctrl+C] to cancel?"
        read
    fi
}


check_environ () {
    if [ -z "${AIODIR+x}" ];then
        yell "no \$AIODIR variable is defined!" \
        "\n  command must launch from an AIO-1.7.3+ console!\nAborting."
    fi
    AIODIR="$(cygpath "$AIODIR")"
    AIOVERSION="$(find "$AIODIR" -maxdepth 1 -name $VERSION_FILE_CHECK)"

    if [ ! -f  "$AIOVERSION" ]; then
        local msg="cannot locate AIO's version-file: $AIOVERSION\n  Command must launch from an AIO-1.7.3+ console!"
        if [ -n "$force" ]; then
            info "$msg\n  ...but FORCED upgrade."
        else
            yell "$msg\n  (use --force if you must)"
        fi
    fi
}


clean_inflated () {
    info "cleaning any inflated pack-files in temporary folders..."
    $rm -rf "$INFLATE_DIR"
}

inflate_pack () {
    clean_inflated
    info "inflating pack-files in: $INFLATE_DIR"
    local lineno=$(grep --line-number 'Base64-encoded UpgradePack' "$prog" | cut -d: -f1 | tail -1)
    lineno=$(( lineno + 3 ))
    $mkdir -p "$INFLATE_DIR"
    trap 'clean_inflated' EXIT
    tail +$lineno "$prog" | base64 --decode - | $tar -xj -C "$INFLATE_DIR"
    
    for exp_dir in AIO wheelhouse; do
        [ -d "$INFLATE_DIR/$exp_dir" ] || yell "inflating upgrade-pack has failed!\nAborting."
    done
}

do_upgrade () {
    info "upgradng WinPython packages..."
    $pip install --no-index --no-dependencies "$INFLATE_DIR"/wheelhouse/*.whl
    
    info "overlaying Apps files..."
    $cp -r "$INFLATE_DIR/AIO/"* "$AIODIR/."
    
    info "engraving new AIO-version: ..."
    $rm -f "$AIOVERSION"
    $echo $NEW_VERSION > "$AIODIR/$NEW_VERSION.ver"
    
    notice "successfully upgraded $AIOVERSION --> $NEW_VERSION"
}

##################
# Cmdline parsing & validation.
##################
#
notice "upgrade-pack for ${VERSION_FILE_CHECK%.ver*} --> $NEW_VERSION"

## Prefer `cat` instead of `read` command below (from https://serverfault.com/a/72511/215750)
#  because its exit-status is 1 when EOF.
# read -r -d '' help <<'EOF'
help=$(cat <<EOF
Inflate (in \$TMP/CO2MPAS_AIO/...) and install upgrade-pack for CO2MPAS $NEW_VERSION.
SYNTAX: 
    $prog [options]
OPTIONS:
    -f|--force:         upgrade AIO even if not ${VERSION_FILE_CHECK%.ver}
    -h|--help           display this message
    -k|--keep-going:    continue working on errors
    -n|--dry-run:       pretend commands executed
    -v|--verbose:       print commands as executed
    -y|--yes:           answer all questions with yes (no interactive)
EOF
)

declare -i verbose
bad_opts='' bad_args='' dry_run='' force='' all_yes='' verbose=0
while [ $# -ne 0 ]; do
    case "$1" in
        (-h|--help) 
            echo "$help"
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
        (--*|-*) 
            bad_opts="$bad_opts $1"
            ;;
        (*) 
            bad_args="$bad_args $1"
            ;;
    esac
    shift
done
if [ -n "$bad_opts$bad_args" ]; then
    yell "command received invalid options or arguments:" \
        "\n  bad options: $bad_opts" 
        "\n  unexpected args: $bad_args\nAborting.\n\n$help" 
fi

rm="rm"
cat="cat"
cp="cp"
mkdir="mkdir"
tar="tar -v"
pip="pip"
echo="echo"
if [ $verbose -gt 0 ]; then
    rm="$rm -v"
    cp="$cp -v"
    mkdir="$mkdir -v"
    tar="$tar -v"

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
    info "PRETEND actions..."
    cp="echo $cp"
    cat="echo $cat"
    rm="echo $rm"
    mkdir="echo $mkdir"
    tar="echo $tar"
    pip="echo $pip"
    echo="false && echo"  # avoid redirections
fi

check_environ
inflate_pack
prompt_for_abort
do_upgrade

exit

##############################################
## Base64-encoded UpgradePack archive BELOW ##
##############################################

