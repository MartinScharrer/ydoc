# $Id$


doc: ydoc-desc.pdf

view.pdf: ydoc-desc.pdf
	cp $< $@
	pdfreload --file $@

package: ydoc-desc.sty

ydoc-desc.sty: %.sty: %.ins %.dtx
	pdflatex $<

ydoc-desc.pdf: %.pdf: %.dtx %.sty
	pdflatex -interaction=nonstopmode $<

