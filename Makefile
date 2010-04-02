# $Id$


doc: ydoc-desc.pdf

view: view.pdf

view.pdf: ydoc-desc.dtx ydoc-desc.ins
	pdflatex -interaction=nonstopmode ydoc-desc.ins
	pdflatex -interaction=nonstopmode ydoc-desc.dtx
	cp ydoc-desc.pdf $@
	pdfreload --file $@

package: ydoc-desc.sty

ydoc-desc.sty: %.sty: %.ins %.dtx
	pdflatex $<

ydoc-desc.pdf: %.pdf: %.dtx %.sty
	pdflatex -interaction=nonstopmode $<

