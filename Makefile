# $Id$

PACKAGE     = ydoc
LATEXFILES  = ydoc.cls ydoc.sty ydoc-desc.sty ydoc-expl.sty ydoc-code.sty ydoc-doc.sty ydoc.cfg
DTXFILES    = ydoc_doc.dtx  ydoc_cls.dtx  ydoc_sty.dtx  ydoc_cfg.dtx  ydoc_code_sty.dtx  ydoc_doc_sty.dtx  ydoc_desc_sty.dtx  ydoc_expl_sty.dtx
SOURCEFILES = ydoc.ins  ${DTXFILES}
DOCFILES    = ydoc.pdf  README

PACKFILES   = ${SOURCEFILES} ${DOCFILES} Makefile

TEXAUX = *.aux *.log *.glo *.ind *.idx *.out *.svn *.svx *.svt *.toc *.ilg *.gls *.hd *.exa *.exb *.fdb_latexmk *.tmp *.cpr *.cod
INSGENERATED = ${LATEXFILES}
GENERATED = ${INSGENERATED} ${PACKAGE}.pdf ${PACKAGE}.zip ${PACKAGE}.tar.gz ${TESTDIR}/test*.pdf ydoc.dtx
ZIPFILE = ${PACKAGE}-${ZIPVERSION}.zip
TDSZIPFILE = ${PACKAGE}-${ZIPVERSION}.tds.zip

LATEX_OPTIONS = -interaction=batchmode -halt-on-error
PDFLATEX = pdflatex ${LATEX_OPTIONS}

TEXMFDIR = ${HOME}/texmf

CP = cp -v
MV = mv -v
RMDIR = rm -rf
MKDIR = mkdir -p

.PHONY: all new unpack .tds tds pdfopt doc package clean fullclean

###############################################################################

all: unpack doc
new: fullclean all

doc: ${DOCFILES}

package: unpack

pdfopt: ydoc.pdf
	@-pdfopt ydoc.pdf .temp.pdf && mv .temp.pdf ydoc.pdf

ydoc.pdf: ydoc.dtx ${INSGENERATED}
	${PDFLATEX} -draftmode $< || (${RM} ${PACKAGE}.aux; false)
	${PDFLATEX} -draftmode '\let\install\iffalse\let\endinstall\fi\input{$<}' || (${RM} ${PACKAGE}.aux; false)
	-makeindex -s gind.ist -o "$@" "$<"
	-makeindex -s gglo.ist -o "$@" "$<"
	${PDFLATEX} -draftmode '\let\install\iffalse\let\endinstall\fi\input{$<}' || (${RM} ${PACKAGE}.aux; false)
	${PDFLATEX} '\let\install\iffalse\let\endinstall\fi\input{$<}' || (${RM} ${PACKAGE}.aux; false)
	-readacro ydoc.pdf

once: ydoc.dtx
	${PDFLATEX} -interaction=errorstopmode $< || (${RM} ${PACKAGE}.aux; false)
	-readacro ydoc.pdf

twice: ydoc.dtx
	${PDFLATEX} -draftmode $< || (${RM} ${PACKAGE}.aux; false)
	${PDFLATEX} '\let\install\iffalse\let\endinstall\fi\input{$<}' || (${RM} ${PACKAGE}.aux; false)
	-readacro ydoc.pdf

dtx: ydoc.dtx

ydoc.dtx: ydoc.ins ${DTXFILES}
	@${RM} $@
	@echo Creating $@
	@cat $^ | perl -ne 'if (/^(\s*\\DocInput)/) { if (!$$n++) { print "$${1}{ydoc.dtx}\n"; } } else { print }' > $@
	@echo '% \Finale' >> $@
	@echo '% \endinput' >> $@

unpack:
	${RM} ${INSGENERATED} ydoc.dtx
	${MAKE} ydoc.dtx
	${PDFLATEX} -draftmode -interaction=nonstopmode '\def\endinstall{\endgroup\csname @enddocumenthook\endcsname\csname @@end\endcsname}\input{ydoc.ins}' || (${RM} ${PACKAGE}.aux; false)

symlinks:
	${RM} ${INSGENERATED} ydoc.dtx
	ln -s  ydoc_doc.dtx       ydoc.dtx
	ln -s  ydoc_cls.dtx       ydoc.cls
	ln -s  ydoc_sty.dtx       ydoc.sty
	ln -s  ydoc_cfg.dtx       ydoc.cfg
	ln -s  ydoc_code_sty.dtx  ydoc-code.sty
	ln -s  ydoc_doc_sty.dtx   ydoc-doc.sty
	ln -s  ydoc_desc_sty.dtx  ydoc-desc.sty
	ln -s  ydoc_expl_sty.dtx  ydoc-expl.sty


TEXMFSRCDIR=${TEXMFDIR}/tex/latex/${PACKAGE}/

installsymlinks:
	${MKDIR} "${TEXMFDIR}/tex/" "${TEXMFDIR}/tex/latex/" "${TEXMFDIR}/tex/latex/${PACKAGE}/"
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc_cls.dtx       ydoc.cls
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc_sty.dtx       ydoc.sty
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc_cfg.dtx       ydoc.cfg
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc_code_sty.dtx  ydoc-code.sty
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc_doc_sty.dtx   ydoc-doc.sty
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc_desc_sty.dtx  ydoc-desc.sty
	cd ${TEXMFSRCDIR} && ln -sf ${PWD}/ydoc_expl_sty.dtx  ydoc-expl.sty
	texhash ${TEXMFDIR}


clean:
	${RM} ${INSGENERATED} ${TEXAUX}

fullclean: clean
	${RM} ${GENERATED} *~ *.backup ${PACKAGE}*.zip
	${RM} -rf tds .tds

###############################################################################

zip: ${PACKFILES}
	@${MAKE} --no-print-directory ${ZIPFILE}

zip: ZIPVERSION=$(shell grep "Package: ${PACKAGE} " ${PACKAGE}.log | \
	sed -e "s/.*Package: ${PACKAGE} ....\/..\/..\s\+\(v\S\+\).*/\1/")

tdszip: ZIPVERSION=$(shell grep "Package: ${PACKAGE} " ${PACKAGE}.log | \
	sed -e "s/.*Package: ${PACKAGE} ....\/..\/..\s\+\(v\S\+\).*/\1/")

${PACKAGE}%.zip: ${PACKFILES}
	@test -n "${IGNORE_CHECKSUM}" || grep -L '\* Checksum passed \*' ${PACKAGE_DTX:.dtx=.log} | wc -l | grep -q '^0$$'
	-pdfopt ${PACKAGE}.pdf opt_${PACKAGE}.pdf && mv opt_${PACKAGE}.pdf ${PACKAGE}.pdf
	${RM} $@
	zip $@ ${PACKFILES}
	@echo
	@echo "ZIP file $@ created!"

release: fullclean package doc tests ${ZIPFILE}

ctanify: ${PACKAGE_STY} ${PACKAGE_DTX} ${PACKAGE_DOC} ${PACKAGE_SRC} README
	ctanify $^

###############################################################################

tds: .tds

.tds: ${PACKAGE_STY} ${PACKAGE_DOC} ${PACKAGE_SRC}
	#@grep -q '\* Checksum passed \*' ${PACKAGE}.log
	${RMDIR} tds
	${MKDIR} tds/
	${MKDIR} tds/tex/ tds/tex/latex/ tds/tex/latex/${PACKAGE}/
	${MKDIR} tds/doc/ tds/doc/latex/ tds/doc/latex/${PACKAGE}/
	${MKDIR} tds/source/ tds/source/latex/ tds/source/latex/${PACKAGE}/
	${CP} ${PACKAGE_STY} tds/tex/latex/${PACKAGE}/
	${CP} ${PACKAGE_DOC} tds/doc/latex/${PACKAGE}/
	${CP} ${PACKAGE_SRC} tds/source/latex/${PACKAGE}/
	@touch $@

tdszip: ${TDSZIPFILE}

${TDSZIPFILE}: .tds
	${RM} ${TDSZIPFILE}
	cd tds && zip -r ../${TDSZIPFILE} .

###############################################################################

install: .tds uninstall
	test -d "${TEXMFDIR}" && ${CP} -a tds/* "${TEXMFDIR}/" && texhash ${TEXMFDIR}

uninstall:
	test -d "${TEXMFDIR}" && ${RM} -rv "${TEXMFDIR}/tex/latex/${PACKAGE}" \
	"${TEXMFDIR}/doc/latex/${PACKAGE}" "${TEXMFDIR}/source/latex/${PACKAGE}" \
	"${TEXMFDIR}/scripts/${PACKAGE}" && texhash ${TEXMFDIR}

