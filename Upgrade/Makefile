# Build a self-extract AIO-UpgradePack.
#
## ask ankostis
#  btw, in the old AIO-1.7.3, `pip install co2mpas` prints this::
#
#     Automat-0.6.0 PySocks-1.6.8 Unidecode-1.0.22 bs4-0.0.1
#     constantly-15.1.0 easygui-0.98.1 future-0.16.0 gitdb2-2.0.3 gitpython-2.1.10
#     hyperlink-18.0.0 incremental-17.5.0 pandalone-0.2.4 parsedatetime-2.4 pyarrow-0.4.1
#     pykalman-0.9.5 python-gnupg-0.4.2 schedula-0.1.19 schema-0.6.7 smmap2-2.0.3
#     transitions-0.6.8 validate-email-1.3 wltp-0.1.0a2 zope.interface-4.5.0
#
#  And we don't want to touch these (hot-fixed?) packs::
#
# 	  PySocks, transitions, smmap2, gitdb2, gitpython, python-gnupg
#

VERSION			= 0.0.0.20180827rc2
UPGRADE_SCRIPT	= CO2MPAS_AIO_UpgradePack-$(VERSION).sh
#UPGRADE_EXE		= CO2MPAS_AIO_UpgradePack-$(VERSION).exe
UPGRADE_EXE		= CO2AIOUP.exe
C_NATIVE_PACKS  = co2mpas|Bottleneck|coverage|fastparquet|llvmlite|numba|numexpr|pyarrow|regex|scikit_learn|thrift|xgboost
# 9(max): 303k(!), 5: 304, 2: 305037635, 2: 305k(!), 1(off): 305k!!
# 9(max), ZIP_ANALYSIS: 9(max): 296k   not worth the time
ZIP_LEVE		= 6
ZIP_ANALYSIS	= 1

input_script	:= upgrade-script.sh
upgrade_script	:= upgrade.sh

## files to copy from `../Archive/ --> Packfiles/AIO/`
#
demofiles		:= $(wildcard ../Archive/Apps/.co2mpas-demos/*.xlsx)
demofiles_dir	:= Packfiles/AIO/Apps/.co2mpas-demos/
demofiles_dest	:= $(addprefix $(demofiles_dir), $(notdir $(demofiles)))
launchers		:= $(addprefix ../Archive/, \
					README.txt co2mpas-env.bat CONSOLE.vbs CO2MPAS.vbs)
launchers_dir	:= Packfiles/AIO/
launchers_dest	:= $(addprefix $(launchers_dir), $(notdir $(launchers)))

wheels			:= $(file < wheels.list)
## Any missed file in `wheels.list` will crash after inflating (on runtime).
nwheels			:= $(words $(strip $(wheels)))
src_wheels		:= $(addprefix wheelhouse/,$(wheels))
wheels_dir		:= Packfiles/wheelhouse/
dest_wheels		:= $(addprefix $(wheels_dir), $(wheels))
## Archive's requirements could be a "recursive" variable,
#  in case another rule above had created more files.
tmp_archive		:= _packfiles.7z


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

.PHONY: all clean rm_demos
.DELETE_ON_ERROR:
.SUFFIXES:

all: $(UPGRADE_SCRIPT)



## Independent utility rule to convert files-->freeze-list.
#
freeze.list: wheels.list
	$(sed) -E 's/(.+)-([[:digit:]].+?)-(cp|py).+/\1 == \2/' $< | \
	$(grep) -vE '$(C_NATIVE_PACKS)' > $@


$(wheels_dir).keepme: wheels.list $(src_wheels)
	## Comparing: wheels.list <--> wheelhouse
	sed -E 's/(.+)-[[:digit:]].+/\1/' ./wheels.list | sort | uniq -d
	# Rerun 2nd time to fail on duplicates printed above
	sed -E 's/-[[:digit:]].+//' ./wheels.list | sort | sort -cu
	
	## Copying wheels
	$(rm) -f Packfiles/wheelhouse/*
	$(cp) $(src_wheels) Packfiles/wheelhouse/.
	touch $@

$(demofiles_dir)%.xlsx: $(demofiles)
	$(rm) -rf $(demofiles_dir)
	mkdir $(demofiles_dir)
	$(cp) $^	 $(demofiles_dir)

$(launchers_dir).keepme: $(launchers)
	$(cp) -r $(launchers) $(launchers_dir)
	touch $@


$(tmp_archive): $(shell find Packfiles/) $(wheels_dir).keepme \
				$(demofiles_dest) $(launchers_dir).keepme
	$(rm) -f $@
	$(zip)  -mx=$(ZIP_LEVEL) -myx=$(ZIP_ANALYSIS) -ms=off a $@ ./Packfiles/*  -xr!.keepme


$(UPGRADE_SCRIPT): $(input_script) $(tmp_archive)
	$(sed)  -e '/^declare -i WINPY_NPACKAGES=/c declare -i WINPY_NPACKAGES=$(nwheels)' \
			-e '/^NEW_VERSION=/c NEW_VERSION="$(VERSION)"' \
			$(input_script)  |	$(cat)   -   $(tmp_archive)  >  $@
	$(chmod)  a+x  $@


UPack/upgrade.sh: 
	$(sed)  -e '/^declare -i WINPY_NPACKAGES=/c declare -i WINPY_NPACKAGES=$(nwheels)' \
			-e '/^NEW_VERSION=/c NEW_VERSION="$(VERSION)"' \
			upgrade.sh >  $@

tt.7z: UPack/upgrade.sh  $(wildcard UPack/*)
	$(zip)  -mx=$(ZIP_LEVEL) -myx=$(ZIP_ANALYSIS) -ms=off a $@ ./UPack/*

# `7z.sfx` from: 
#  https://github.com/chrislake/7zsfxmm/wiki/Download: 7zsd_extra_160_2712.7z!7zsd_All_x64.sfx
$(UPGRADE_EXE): 7z.sfx  tt.7z  7z.config 
	cat 7z.sfx 7z.config tt.7z > $@
	chmod a+x $@

clean:
	$(rm) -f $(tmp_archive) $(UPGRADE_SCRIPT) $(wheels_dir)*
