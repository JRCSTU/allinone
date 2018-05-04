# Build a self-extract AIO-UpgradePack.
#
# ask ankostis

VERSION         := 2018.1.a2
UPGRADE_SCRIPT  := "CO2MPAS_AIO_UpgradePack-$(VERSION).sh"

input_script    := upgrade-script.sh
tmp_archive     := _packfiles.tar.bz2
wheels_tstamp   := Packfiles/wheelhouse/.keepme
wheels          := $(file < wheels.list)
nwheels         := $(words $(strip $(wheels)))
src_wheels      := $(addprefix wheelhouse/,$(wheels))
dst_wheels      := $(addprefix Packfiles/wheelhouse/,$(wheels))

## If script not ending with  a blank last line,
#  inflating pack-file archive fail on upgrade.
#
eol_script := $(shell tail -c 1 $(input_script))
ifneq ($(strip $(eol_script)),)
    $(error '$(input_script)' not ending with NEWLINE but $(eol_script))
endif

rm := rm -v
base64 := base64
cat := cat
cp := cp -v
tar := tar -cv -C Packfiles --to-stdout
zip := bzip2 -7 - --stdout
sed := sed
chmod := chmod

pack_files = $(wildcard PackFiles/*)

.DELETE_ON_ERROR:
.PHONY: clean
## Comment-out this to inspect intermediate archive.
#.INTERMEDIATE: $(tmp_archive)


all: $(UPGRADE_SCRIPT)

$(wheels_tstamp): wheels.list $(src_wheels)
	$(cp) $(src_wheels) Packfiles/wheelhouse/.
	touch $@

$(tmp_archive): $(pack_files) $(wheels_tstamp)
	$(rm)       -f $(tmp_archive)
	$(tar)      $(pack_files:PackFiles/%=%)  |  $(zip)  >  $(tmp_archive) 

$(UPGRADE_SCRIPT): $(input_script) $(tmp_archive)
	## From https://unix.stackexchange.com/a/212419/156357
	$(sed)  -e '/^declare -i WINPY_NPACKAGES=/c declare -i WINPY_NPACKAGES=$(nwheels)' \
			-e '/^NEW_VERSION=/c NEW_VERSION="$(VERSION)"' \
			-e '/^INFLATE_DIR=/c INFLATE_DIR="$TMP/CO2MPAS_AIO/UpgradePack-$(VERSION)"' \
			$<  > $@
	$(cat)      $(tmp_archive)    >>  $@
	$(chmod)    a+x  $@

clean: 
	$(rm) -f $(tmp_archive) $(UPGRADE_SCRIPT)

