FORMAT ?= svg
SOURCES = $(wildcard ./*.wsd)
TARGETS = $(patsubst %.wsd,%.$(FORMAT),$(SOURCES))
STYLE ?= style.isvg

.PHONY: all clean toolset force

validate = test -s $@ || { rm $@; exit 1; }

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.svg: %.wsd
	cat $< \
	| plantuml -tsvg -pipe \
	| xmllint --format - \
	| sed -e "/<g>/r $(STYLE)" \
	> $@
	$(validate)

%.png: %.wsd
	$(MAKE) $*.svg
	mogrify -antialias -density 240 -format png $*.svg
	rm -vf $*.svg
	$(validate)


install-toolset: plantuml.tool xmllint.tool mogrify.tool
%.tool: force
	$(MAKE) $*.tool.$(uname -s)
plantuml.tool.Darwin:
	brew install plantuml
mogrify.tool.Darwin:
	brew install imagemagick
xmllint.tool.Darwin:
	true

force:
	@true
