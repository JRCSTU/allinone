## Makefile for updating AIO image to VELA Drive
#
ROOTDIR := co2mpas_AIO/
REMOTE_DIR := "/k/PERSONNEL/Ankostis/Xchange/$(ROOTDIR)"

_n := $(findstring -n,$(firstword -$(MAKEFLAGS)))

.PHONY: all clean push
 
all: push
 
clean: 
	+./prepare.sh $(_n)

push: clean
	+rsync $(_n) -P --recursive --links --times \
	   --delete \
		$(ROOTDIR)  $(REMOTE_DIR)
