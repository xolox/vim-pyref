PROJECT=pyref
VIMDOC := $(shell mktemp -u)
ZIPFILE := $(shell mktemp -u)
ZIPDIR := $(shell mktemp -d)
RELEASE=$(PROJECT)-$(VERSION).zip

# NOTE: Make does NOT expand the following back ticks!
VERSION=`grep '^" Version:' $(PROJECT).vim | awk '{print $$3}'`

# The main rule builds a ZIP that can be published to http://www.vim.org.
archive: Makefile $(PROJECT).vim index spider.py README.md
	@echo "Creating \`$(PROJECT).txt' .."
	@mkd2vimdoc.py $(PROJECT).txt < README.md > $(VIMDOC)
	@echo "Creating \`$(RELEASE)' .."
	@mkdir -p $(ZIPDIR)/plugin $(ZIPDIR)/doc $(ZIPDIR)/$(PROJECT)
	@cp $(PROJECT).vim $(ZIPDIR)/plugin
	@cp $(VIMDOC) $(ZIPDIR)/doc/$(PROJECT).txt
	@cp index spider.py $(ZIPDIR)/$(PROJECT)
	@cd $(ZIPDIR) && zip -r $(ZIPFILE) . >/dev/null
	@rm -R $(ZIPDIR)
	@mv $(ZIPFILE) $(RELEASE)
