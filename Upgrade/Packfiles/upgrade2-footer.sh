## Stage-2 of Upgrade-pack
####################################

do_patch_console_config () {
    local orig_file="$AIODIR/Apps/Console/console.xml"
    local backup_file="$AIODIR/Apps/Console/console.OLD-$OLD_AIO_VERSION.xml"
    
    $cp "$orig_file" "$backup_file"
    $sed -i "s/title=\"AIO-[^\"+]\"/title=\"AIO-$NEW_VERSION/" "$orig_file" 
    ## TODO: fix MSYS2 unset vars...
}
do_disable_2nd_stage_script() {
    mv "$0" "${0#.sh}-$OLD_AIO_VERSION.sh"
}
do_delete_old_version_file() {
    ## This marks the end of all setup.
    logstep "${DRY_RUN}deleting old version-file $old_version_file..."
    local old_version_file="$AIODIR/ΑΙΟ-$OLD_AIO_VERSION.ver"
    if [ -f "$old_version_file" ]; then
        $rm "$old_version_file"
    fi

}

####################################
## Main body
####################################
build_help
parse_cmdline_args "$@"

notice "Stage 2 of $HELP_OPENING"

check_existing_AIO
check_python_version
run_upgrade_steps \
    do_patch_console_config \
    do_disable_2nd_stage_script \
    do_delete_old_version_file


notice "finished stage-2 of $DRY_RUN$SCRIPT_ACTION successfully." \
    "\n  Press any key to continue."
read -sn1