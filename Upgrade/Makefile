# Build a self-extract AIO-UpgradePack.
#
# ask ankostis

VERSION         = 0.20180506.a0
UPGRADE_SCRIPT  = CO2MPAS_AIO_UpgradePack-$(VERSION).sh
C_NATIVE_PACKS  = co2mpas|Bottleneck|coverage|fastparquet|llvmlite|numba|numexpr|pyarrow|regex|scikit_learn|thrift|xgboost
# 9(max): 303k(!), 5: 304, 2: 305037635, 2: 305k(!), 1(off): 305k!!
# 9(max), ZIP_ANALYSIS: 9(max): 296k   not worth the time
ZIP_LEVEL     	:= 1
ZIP_ANALYSIS	:= 1

input_script    := upgrade-script.sh
tmp_archive     := _packfiles.7z
wheels_tstamp   := Packfiles/wheelhouse/.keepme
wheels          := $(file < wheels.list)
## Any missed file in `wheels.list` will crash after inflating (on runtime).
nwheels         := $(words $(strip $(wheels)))
src_wheels      := $(addprefix wheelhouse/,$(wheels))
dst_wheels      := $(addprefix Packfiles/wheelhouse/,$(wheels))
## Archive's requirements could be a "recursive" variable,
#  in case another rule above had created more files.
pack_files := $(wildcard PackFiles/*)


## If script not ending with  a blank last line,
#  inflating pack-file archive fail on upgrade.
#
eol_script := $(shell tail -c 1 $(input_script))
ifneq ($(strip $(eol_script)),)
    $(error '$(input_script)' not ending with NEWLINE but $(eol_script))
endif

base64 	:= base64
cat := cat
cp 	:= cp -v
rm 	:= rm -v
rsync 	:= rsync -v
zip := 7zr
sed := sed
grep := grep
chmod 	:= chmod

.DELETE_ON_ERROR:
.PHONY: all clean

all: $(UPGRADE_SCRIPT)


## Independent utiliy rule to convert files-->freeze-list.
#
freeze.list: wheels.list 
	$(sed) -E 's/(.+)-([[:digit:]].+?)-(cp|py).+/\1 == \2/' $< | \
	$(grep) -vE '$(C_NATIVE_PACKS)' > $@

$(wheels_tstamp): wheels.list $(src_wheels)
	$(rm) -f Packfiles/wheelhouse/*.whl
	$(cp) $(src_wheels) Packfiles/wheelhouse/.
	touch $@

$(tmp_archive): $(wheels_tstamp)  $(pack_files)
	$(rm) -f $@
	$(zip)  -mx=$(ZIP_LEVEL) -myx=$(ZIP_ANALYSIS) -ms=off a $@ ./Packfiles/*  -xr!.keepme 

$(UPGRADE_SCRIPT): $(input_script) $(tmp_archive)
	$(sed)  -e '/^declare -i WINPY_NPACKAGES=/c declare -i WINPY_NPACKAGES=$(nwheels)' \
			-e '/^NEW_VERSION=/c NEW_VERSION="$(VERSION)"' \
			$(input_script)  |	$(cat)   -   $(tmp_archive)  >  $@
	$(chmod)  a+x  $@

clean:
	$(rm) -f $(tmp_archive) $(UPGRADE_SCRIPT)
