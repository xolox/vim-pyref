VIMDOC=doc/pyref.txt
HTMLDOC=doc/readme.html
ZIPDIR := $(shell mktemp -d)
ZIPFILE := $(shell mktemp -u)

# NOTE: Make does NOT expand the following back ticks!
VERSION=`grep '^" Version:' pyref.vim | awk '{print $$3}'`

# The main rule builds a ZIP that can be published to http://www.vim.org.
archive: Makefile pyref.vim index spider.py $(VIMDOC) $(HTMLDOC)
	@echo "Creating \`pyref-$(VERSION).zip' .."
	@mkdir -p $(ZIPDIR)/plugin $(ZIPDIR)/doc $(ZIPDIR)/pyref 
	@cp pyref.vim $(ZIPDIR)/plugin
	@cp $(VIMDOC) $(ZIPDIR)/doc
	@cp index $(HTMLDOC) spider.py $(ZIPDIR)/pyref
	@cd $(ZIPDIR) && zip -r $(ZIPFILE) . >/dev/null
	@rm -R $(ZIPDIR)
	@mv $(ZIPFILE) pyref-$(VERSION).zip

# This rule converts the Markdown README to Vim documentation.
$(VIMDOC): Makefile README.md
	@echo "Creating \`$(VIMDOC)' .."
	@mkd2vimdoc.py `basename $(VIMDOC)` < README.md > $(VIMDOC)

# This rule converts the Markdown README to HTML, which reads easier.
$(HTMLDOC): Makefile README.md
	@echo "Creating \`$(HTMLDOC)' .."
	@cat doc/README.header > $(HTMLDOC)
	@markdown README.md >> $(HTMLDOC)
	@cat doc/README.footer >> $(HTMLDOC)

# This is only useful for myself, it uploads the latest README to my website.
web: $(HTMLDOC)
	@echo "Uploading homepage .."
	@scp -q $(HTMLDOC) vps:/home/peterodding.com/public/files/code/vim/pyref/index.html

all: archive web
