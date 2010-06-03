OUTDOC=doc/README.html
ZIPDIR := $(shell mktemp -d)
ZIPFILE := $(shell mktemp -u)

# NOTE: Make does NOT expand the following back ticks!
VERSION=`grep '^" Version:' pyref.vim | awk '{print $$3}'`

# The main rule builds a ZIP that can be published to http://www.vim.org.
main: Makefile pyref.vim index spider.py $(OUTDOC)
	@echo "Creating \`pyref-$(VERSION).zip' .."
	@mkdir -p $(ZIPDIR)/plugin $(ZIPDIR)/pyref
	@cp pyref.vim $(ZIPDIR)/plugin
	@cp index $(OUTDOC) spider.py $(ZIPDIR)/pyref
	@cd $(ZIPDIR) && zip -r $(ZIPFILE) . >/dev/null
	@rm -R $(ZIPDIR)
	@mv $(ZIPFILE) pyref-$(VERSION).zip

# This rule converts the Markdown README to HTML, which reads easier.
$(OUTDOC): Makefile README.md
	@echo "Creating $(OUTDOC) .."
	@cat doc/README.header > $(OUTDOC)
	@markdown README.md >> $(OUTDOC)
	@cat doc/README.footer >> $(OUTDOC)
