#################################################################################
#
# Cocoa-Emacs Makefile
#
#################################################################################

PREFIX = /Users/nanasess/src/cocoa-emacs
RM = /bin/rm -rfv
TAR = tar xvzf
CURL = curl -O
SOURCE_DIR = $(EMACS_SRC) $(APEL_SRC) $(SKK_SRC) $(MEW_SRC) $(W3M_SRC) $(HOWM_SRC)

## Emacs Variables
EMACS_SRC = emacs-24.0.90
EMACS_APP = $(PREFIX)/$(EMACS_SRC)/nextstep/Emacs.app
EMACS = $(EMACS_APP)/Contents/MacOS/Emacs
EMACS_PREFIX = $(EMACS_APP)/Contents/Resources
EMACS_BINDIR = $(EMACS_APP)/Contents/MacOS/bin
INFO_DIR = $(EMACS_PREFIX)/info
SITE_DIR = $(EMACS_PREFIX)/site-lisp
ETC_DIR = $(EMACS_PREFIX)/etc

# SKK Variables
SKK_BASE = skk
SKK_SRC = $(SKK_BASE)/main
SKK_CFG = SKK-CFG
SKK_DATADIR = $(EMACS_PREFIX)/etc/skk
SKK_INFODIR = $(INFO_DIR)
SKK_LISPDIR = $(SITE_DIR)/skk
SKK_SET_JISYO = t

# migemo Variables
MIGEMO_SRC = migemo

# Mew Variables
MEW_SRC = mew

# DVC Variables
DVC_SRC = dvc

# W3M Variables
W3M_SRC = emacs-w3m

# navi2ch Variables
NAVI2CH_SRC = navi2ch

all:
	@echo "make checkout or make update"
	@echo "make emacsinstall"
	@echo "make installlib"

################################################################################
# common targets
################################################################################

update:
	cd $(SKK_SRC) && cvs -q update -dP
#	cd $(MIGEMO_SRC) && cvs -q update -dP
	cd $(W3M_SRC) && cvs -q update -dP
	cd $(NAVI2CH_SRC) && cvs -q update -dP
	cd $(EMACS_SRC) && bzr pull
	cd $(MEW_SRC) && git pull

install: emacsinstall installlib

buildlib: skkbuild dvcbuild mewbuild w3mbuild navi2chbuild

installlib: skkinstall dvcinstall mewinstall w3minstall navi2chinstall

cleanall: emacsdistclean skkclean skkcfgclean mewclean w3mclean navi2chclean

sourceclean:
	$(RM) $(SOURCE_DIR) $(HOWM_SRC).* $(MUSE_SRC).*

checkout: sourceclean checkoutemacs checkoutskk checkoutmew checkoutw3m checkoutnavi2ch

################################################################################
# checkouts
################################################################################

checkoutemacs:
	cvs -z3 -d:pserver:anonymous@cvs.savannah.gnu.org:/sources/emacs co $(EMACS_SRC)

checkoutskk:
	cvs -d :pserver:guest@openlab.jp:/circus/cvsroot checkout $(SKK_SRC)

checkoutmigemo:
	cvs -z3 -d:pserver:anonymous@migemo.cvs.sourceforge.net:/cvsroot/migemo co $(MIGEMO_SRC)

checkoutmew:
	cvs -d :pserver:anoncvs@anoncvs.mew.org:/cvsmew co $(MEW_SRC)

checkoutw3m:
	cvs -d :pserver:anonymous@cvs.namazu.org:/storage/cvsroot co $(W3M_SRC)

checkoutnavi2ch:
	cvs -z3 -d:pserver:anonymous@navi2ch.cvs.sourceforge.net:/cvsroot/navi2ch co $(NAVI2CH_SRC)

################################################################################
# emacs targets
################################################################################

emacsbuild:
	cd $(EMACS_SRC); \
	./configure --with-ns \
	--without-dbus; \
	make

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

################################################################################
# migemo targets
################################################################################

migemobuild:
	cp $(SKK_BASE)/dic/SKK-JISYO.L $(MIGEMO_SRC)
	cd $(MIGEMO_SRC); \
	./configure	--with-emacs=$(EMACS) --prefix=$(EMACS_PREFIX) \
			--bindir=$(EMACS_BINDIR) \
			--with-lispdir=$(SITE_DIR)/migemo \
			--sysconfdir=$(ETC_DIR) --infodir=$(INFO_DIR) \
	make

migemoinstall: migemobuild
	cd $(MIGEMO_SRC); \
	make install rubydir=/Library/Ruby/Site/1.8

migemoclean:
	cd $(MIGEMO_SRC); \
	make distclean


################################################################################
# mew targets
################################################################################

mewbuild:
	cd $(MEW_SRC); \
	./configure	--with-emacs=$(EMACS) --prefix=$(PREFIX) \
			--bindir=$(EMACS_BINDIR) --with-elispdir=$(SITE_DIR)/mew \
			--with-etcdir=$(ETC_DIR) --infodir=$(INFO_DIR) \
	make

mewinstall: mewbuild
	cd $(MEW_SRC); \
	make install

mewclean:
	cd $(MEW_SRC); \
	make distclean

################################################################################
# dvc targets
################################################################################

dvcbuild:
	cd $(DVC_SRC); \
	autoconf; \
	./configure	--with-emacs=$(EMACS) --prefix=$(PREFIX) \
			--bindir=$(EMACS_BINDIR) --with-lispdir=$(SITE_DIR)/dvc \
			--sysconfdir=$(ETC_DIR) --infodir=$(INFO_DIR) \
	make

dvcinstall: dvcbuild
	cd $(DVC_SRC); \
	make install

dvcclean:
	cd $(DVC_SRC); \
	make distclean

################################################################################
# w3m targets
################################################################################

w3mbuild:
	cd $(W3M_SRC); \
	autoconf; \
	./configure	--with-emacs=$(EMACS) --prefix=$(PREFIX) \
			--bindir=$(EMACS_BINDIR) --sbindir=$(EMACS_BINDIR) \
			--with-lispdir=$(SITE_DIR)/w3m --infodir=$(INFO_DIR) \
	make

w3minstall: w3mbuild
	cd $(W3M_SRC); \
	make install && make install-icons && make install-icons30

w3mclean:
	cd $(W3M_SRC); \
	make distclean

################################################################################
# navi2ch targets
################################################################################

navi2chbuild:
	cd $(NAVI2CH_SRC); \
	./configure	EMACS=$(EMACS) --with-lispdir=$(SITE_DIR)/navi2ch \
			--infodir=$(INFO_DIR) --with-icondir=$(ETC_DIR) \
	make

navi2chinstall: navi2chbuild
	cd $(NAVI2CH_SRC); \
	make install

navi2chclean:
	cd $(NAVI2CH_SRC); \
	make distclean

