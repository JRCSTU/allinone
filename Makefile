## Makefile for updating AIO image to VELA Drive
#
ROOTDIR := $(wildcard co2mpas_AIO-v*)
REMOTE_DIR := "/cygdrive/k/PERSONNEL/Ankostis/Xchange/$(ROOTDIR)/"

_n := $(findstring -n,$(firstword -$(MAKEFLAGS)))

.PHONY: all clean push
 
all: push
 
clean: 
	+./clean.sh $(_n)

push: clean
	+rsync $(_n) -P --recursive --links --times \
	   --delete \
		$(ROOTDIR)  $(REMOTE_DIR)
