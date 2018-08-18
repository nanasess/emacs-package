#################################################################################
#
# Cocoa-Emacs Makefile
#
#################################################################################

PREFIX = $(shell pwd)
RM = /bin/rm -rfv
TAR = tar xvzf
CURL = curl -O
SOURCE_DIR = $(EMACS_SRC) $(SKK_SRC) $(MEW_SRC) $(W3M_SRC)

## Emacs Variables
EMACS_SRC = emacs
EMACS_VERSION = 24.3		# see. PACKAGE_VERSION
EMACS_APP = $(PREFIX)/$(EMACS_SRC)/mac/Emacs.app
EMACS = $(EMACS_APP)/Contents/MacOS/Emacs
EMACS_PREFIX = $(EMACS_APP)/Contents/Resources
EMACS_BINDIR = $(EMACS_APP)/Contents/MacOS/bin
INFO_DIR = $(EMACS_PREFIX)/share/emacs/info
SITE_DIR = $(EMACS_PREFIX)/share/emacs/site-lisp
ETC_DIR = $(EMACS_PREFIX)/share/emacs/$(EMACS_VERSION)/etc

# SKK Variables
SKK_BASE = skk
SKK_SRC = $(SKK_BASE)/main
SKK_CFG = SKK-CFG
SKK_DATADIR = $(ETC_DIR)/skk
SKK_INFODIR = $(INFO_DIR)
SKK_LISPDIR = $(SITE_DIR)/skk
SKK_SET_JISYO = t

all:
	@echo "make checkout or make update"
	@echo "make emacsinstall"
	@echo "make installlib"

################################################################################
# common targets
################################################################################

update:
	cd $(SKK_SRC) && cvs -q update -dP

install: emacsinstall

buildlib: skkbuild

installlib: skkinstall

cleanall: emacsdistclean skkclean skkcfgclean

sourceclean:
	$(RM) $(SOURCE_DIR)

checkout: sourceclean checkoutskk

################################################################################
# checkouts
################################################################################

checkoutskk:
	cvs -d :pserver:guest@openlab.jp:/circus/cvsroot checkout $(SKK_SRC)

################################################################################
# emacs targets
################################################################################

emacsbuild:
	cd $(EMACS_SRC); \
	CC="clang -fobjc-arc -Ofast -march=native" ./configure	--prefix=$(EMACS_PREFIX) \
			--with-mac --without-x --without-dbus \
			--with-gnutls --with-modules --with-rsvg \
			--with-imagemagick \
			--enable-mac-app=~/Applications
	make -j $(shell sysctl -n hw.activecpu)

emacsinstall: emacsbuild
	cd $(EMACS_SRC); \
	make install

emacsclean:
	cd $(EMACS_SRC); \
	make clean

emacsdistclean:
	cd $(EMACS_SRC); \
	make distclean

################################################################################
# skk targets
################################################################################

skkcfg:
	cd $(SKK_SRC); \
	echo '(setq PREFIX "$(EMACS_PREFIX)")' >> $(SKK_CFG); \
	echo '(setq SKK_DATADIR "$(SKK_DATADIR)")' >> $(SKK_CFG); \
	echo '(setq SKK_INFODIR "$(SKK_INFODIR)")' >> $(SKK_CFG); \
	echo '(setq SKK_LISPDIR "$(SKK_LISPDIR)")' >> $(SKK_CFG); \
	echo '(setq SKK_SET_JISYO $(SKK_SET_JISYO))' >> $(SKK_CFG);

skkcfgclean:
	cd $(SKK_SRC); \
	$(RM) $(SKK_CFG); \
	cvs update $(SKK_CFG)

skkbuild: skkcfg
	cd $(SKK_SRC); \
	make what-where EMACS=$(EMACS); \
	make EMACS=$(EMACS)

skkinstall: skkbuild
	cd $(SKK_SRC); \
	make install EMACS=$(EMACS)


skkclean:
	cd $(SKK_SRC); \
	make clean EMACS=$(EMACS)

