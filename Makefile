# $Id$

PACKAGE      = ydoc
LATEXFILES   = ydoc.cls ydoc.sty ydoc-desc.sty ydoc-expl.sty ydoc-code.sty ydoc-doc.sty ydoc.cfg ydocstrip.tex ydocincl.tex
DTXFILES     = ydoc_doc.dtx  ydoc_cls.dtx  ydoc_sty.dtx  ydoc_cfg.dtx  ydoc_code_sty.dtx  ydoc_doc_sty.dtx  ydoc_desc_sty.dtx  ydoc_expl_sty.dtx
SOURCEFILES  = ydoc.dtx ydocstrip.tex ydocincl.tex
DOCFILES     = ydoc.pdf  README

PACKFILES    = ${SOURCEFILES} ${DOCFILES}

INSGENERATED =
TEXAUX       = *.aux *.log *.glo *.ind *.idx *.out *.svn *.svx *.svt *.toc *.ilg *.gls *.hd *.exa *.exb *.fdb_latexmk *.tmp *.cpr *.cod
GENERATED    = ${INSGENERATED} ${PACKAGE}.pdf ${PACKAGE}.zip ${PACKAGE}.tar.gz ${TESTDIR}/test*.pdf ydoc.dtx
ZIPFILE      = ${PACKAGE}.zip
TDSZIPFILE   = ${PACKAGE}.tds.zip

LATEX_OPTIONS = -interaction=batchmode -halt-on-error
PDFLATEX = pdflatex ${LATEX_OPTIONS}
PDFOPT = qpdf

TEXMFDIR = ${HOME}/texmf

CP = cp -v
MV = mv -v
RMDIR = rm -rf
MKDIR = mkdir -p

.PHONY: all new unpack .tds tds pdfopt doc package clean fullclean

###############################################################################

all: doc
new: fullclean all

doc: ${DOCFILES}

package: unpack

###############################################################################

pdfopt: ${PACKAGE}.pdf
	@-pdfopt ${PACKAGE}.pdf .temp.pdf && mv .temp.pdf ${PACKAGE}.pdf


pdf: ${PACKAGE}.pdf

${PACKAGE}.pdf: ${DTXFILES} | ${INSGENERATED}
	${PDFLATEX} -draftmode '\let\install\iffalse\let\endinstall\fi\input{$<}' || (${RM} ${PACKAGE}.aux; false)
	-makeindex -s gind.ist -o "$@" "$<"
	-makeindex -s gglo.ist -o "$@" "$<"
	${PDFLATEX} -draftmode '\let\install\iffalse\let\endinstall\fi\input{$<}' || (${RM} ${PACKAGE}.aux; false)
	${PDFLATEX} -jobname "${PACKAGE}" '\let\install\iffalse\let\endinstall\fi\input{$<}' || (${RM} ${PACKAGE}.aux; false)

once: ${PACKAGE}.dtx
	${PDFLATEX} -interaction=errorstopmode $< || (${RM} ${PACKAGE}.aux; false)
	-readacro ${PACKAGE}.pdf

twice: ${PACKAGE}.dtx
	${PDFLATEX} -draftmode $< || (${RM} ${PACKAGE}.aux; false)
	${PDFLATEX} '\let\install\iffalse\let\endinstall\fi\input{$<}' || (${RM} ${PACKAGE}.aux; false)
	-readacro ${PACKAGE}.pdf

dtx: ${PACKAGE}.dtx

unpack:
	${RM} ${INSGENERATED} ${PACKAGE}.dtx
	${MAKE} --no-print-directory ${PACKAGE}.dtx
	${PDFLATEX} -draftmode -interaction=nonstopmode '\def\endinstall{\endgroup\csname @enddocumenthook\endcsname\csname @@end\endcsname}\input{${PACKAGE}.ins}' || (${RM} ${PACKAGE}.aux; false)


TEXMFSRCDIR=${TEXMFDIR}/tex/latex/${PACKAGE}/

installsymlinks:
	${MKDIR} "${TEXMFDIR}/tex/" "${TEXMFDIR}/tex/latex/" "${TEXMFDIR}/tex/latex/${PACKAGE}/"
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc.cls       ydoc.cls
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc.sty       ydoc.sty
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc.cfg       ydoc.cfg
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc-code.sty  ydoc-code.sty
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc-doc.sty   ydoc-doc.sty
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc-desc.sty  ydoc-desc.sty
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc-expl.sty  ydoc-expl.sty
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydocstrip.tex  ydocstrip.tex
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydocincl.tex   ydocincl.tex
	texhash ${TEXMFDIR}


clean:
	${RM} ${INSGENERATED} ${TEXAUX}

fullclean: clean
	${RM} ${GENERATED} *~ *.backup ${PACKAGE}*.zip
	${RM} -rf tds .tds

###############################################################################

zip: ${PACKAGE}.zip

${PACKAGE}.zip: ${PACKFILES}
	#@test -n "${IGNORE_CHECKSUM}" || grep -L '\* Checksum passed \*' ${PACKAGE_DTX:.dtx=.log} | wc -l | grep -q '^0$$'
	-pdfopt ${PACKAGE}.pdf opt_${PACKAGE}.pdf && mv opt_${PACKAGE}.pdf ${PACKAGE}.pdf
	${RM} $@
	zip $@ ${PACKFILES}
	@echo
	@echo "ZIP file $@ created!"

release: fullclean package doc tests ${ZIPFILE}

ctanify: ${PACKFILES} ${PACKAGE}.tds.zip
	${RM} ydoc.zip
	zip ydoc.zip $^
	unzip -t ydoc.zip
	unzip -t ydoc.tds.zip

###############################################################################


install: .tds uninstall
	test -d "${TEXMFDIR}" && ${CP} -a tds/* "${TEXMFDIR}/" && texhash ${TEXMFDIR}

uninstall:
	test -d "${TEXMFDIR}" && ${RM} -rv "${TEXMFDIR}/tex/latex/${PACKAGE}" \
	"${TEXMFDIR}/doc/latex/${PACKAGE}" "${TEXMFDIR}/source/latex/${PACKAGE}" \
	"${TEXMFDIR}/scripts/${PACKAGE}" && texhash ${TEXMFDIR}



manual: ydoc.dtx ydoc.ins
	-mkdir .manual && cd .manual && ln -s ../*.sty .
	perl ../dtx/dtx.pl ydoc.dtx .manual/ydoc.dtx
	cd .manual && latexmk -pdf ydoc.dtx || rm .manual/ydoc.aux
	mv .manual/ydoc.pdf ydoc.pdf

build: ydoc.dtx ydoc.ins README Makefile ydoc.cfg ydoc.cls ydoc.sty ydoc-code.sty ydoc-desc.sty ydoc-expl.sty ydoc-doc.sty ydocstrip.tex ydocincl.tex
	rm -rf build/
	mkdir build
	tex '\input ydocincl\relax\includefiles{ydoc.dtx}{build/ydoc.dtx}'
	${CP} ydoc.ins README build/
	cd build && tex ydoc.dtx
	cd build && latexmk -pdf ydoc.dtx
	cd build && ${PDFOPT} ydoc.pdf opt.pdf && mv opt.pdf ydoc.pdf
	cd build && ctanify --pkgname ydoc ydoc.dtx -t "*.cls" -t "*.sty" -t "*.cfg" -t "*.tex" *.sty *.cls *.cfg  ydoc.cfg=tex/latex/ydoc/ "*.tex=tex/latex/ydoc/" README ydoc.pdf
	@cd build && ${CP} ydoc.tar.gz /tmp

buildonce: ydoc.dtx ydoc.ins README
	rm -rf build/
	mkdir build
	tex '\input ydocincl\relax\includefiles{ydoc.dtx}{build/ydoc.dtx}'
	${CP} ydoc.ins README build/
	cd build && tex ydoc.dtx
	cd build && pdflatex ydoc.dtx
#	cd build && pdflatex storebox.dtx



