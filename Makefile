# $Id$

PACKAGE      = ydoc
LATEXFILES   = ydoc.cls ydoc.sty ydoc-desc.sty ydoc-expl.sty ydoc-code.sty ydoc-doc.sty ydoc.cfg ydocstrip.tex
DTXFILES     = ydoc_doc.dtx  ydoc_cls.dtx  ydoc_sty.dtx  ydoc_cfg.dtx  ydoc_code_sty.dtx  ydoc_doc_sty.dtx  ydoc_desc_sty.dtx  ydoc_expl_sty.dtx
SOURCEFILES  = ydoc.dtx ydocstrip.tex
DOCFILES     = ydoc.pdf  README

PACKFILES    = ${SOURCEFILES} ${DOCFILES}

INSGENERATED = ydoc.cls ydoc.sty ydoc-desc.sty ydoc-expl.sty ydoc-code.sty ydoc-doc.sty ydoc.cfg
TEXAUX       = *.aux *.log *.glo *.ind *.idx *.out *.svn *.svx *.svt *.toc *.ilg *.gls *.hd *.exa *.exb *.fdb_latexmk *.tmp *.cpr *.cod
GENERATED    = ${INSGENERATED} ${PACKAGE}.pdf ${PACKAGE}.zip ${PACKAGE}.tar.gz ${TESTDIR}/test*.pdf ydoc.dtx
ZIPFILE      = ${PACKAGE}.zip
TDSZIPFILE   = ${PACKAGE}.tds.zip

LATEX_OPTIONS = -interaction=batchmode -halt-on-error
PDFLATEX = pdflatex ${LATEX_OPTIONS}

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

${PACKAGE}.dtx: ${PACKAGE}.ins ${DTXFILES}
	@${RM} $@
	@echo Creating $@
	@cat $^ | perl -ne 'if (/^(\s*\\DocInput)/) { if (!$$n++) { print "$${1}{${PACKAGE}.dtx}\n"; } } else { print }' > $@
	@echo '% \Finale' >> $@
	@echo '% \endinput' >> $@

unpack:
	${RM} ${INSGENERATED} ${PACKAGE}.dtx
	${MAKE} --no-print-directory ${PACKAGE}.dtx
	${PDFLATEX} -draftmode -interaction=nonstopmode '\def\endinstall{\endgroup\csname @enddocumenthook\endcsname\csname @@end\endcsname}\input{${PACKAGE}.ins}' || (${RM} ${PACKAGE}.aux; false)
	@touch --reference=ydoc_cls.dtx       ydoc.cls
	@touch --reference=ydoc_sty.dtx       ydoc.sty
	@touch --reference=ydoc_cfg.dtx       ydoc.cfg
	@touch --reference=ydoc_code_sty.dtx  ydoc-code.sty
	@touch --reference=ydoc_doc_sty.dtx   ydoc-doc.sty
	@touch --reference=ydoc_desc_sty.dtx  ydoc-desc.sty
	@touch --reference=ydoc_expl_sty.dtx  ydoc-expl.sty

symlinks:
	${RM} ${INSGENERATED}
	ln -s  ydoc_cls.dtx       ydoc.cls
	ln -s  ydoc_sty.dtx       ydoc.sty
	ln -s  ydoc_cfg.dtx       ydoc.cfg
	ln -s  ydoc_code_sty.dtx  ydoc-code.sty
	ln -s  ydoc_doc_sty.dtx   ydoc-doc.sty
	ln -s  ydoc_desc_sty.dtx  ydoc-desc.sty
	ln -s  ydoc_expl_sty.dtx  ydoc-expl.sty
	@touch -h --reference=ydoc_cls.dtx       ydoc.cls
	@touch -h --reference=ydoc_sty.dtx       ydoc.sty
	@touch -h --reference=ydoc_cfg.dtx       ydoc.cfg
	@touch -h --reference=ydoc_code_sty.dtx  ydoc-code.sty
	@touch -h --reference=ydoc_doc_sty.dtx   ydoc-doc.sty
	@touch -h --reference=ydoc_desc_sty.dtx  ydoc-desc.sty
	@touch -h --reference=ydoc_expl_sty.dtx  ydoc-expl.sty

ydoc.cls: ydoc_cls.dtx
	${MAKE} --no-print-directory unpack

ydoc.sty: ydoc_sty.dtx
	${MAKE} --no-print-directory unpack

ydoc.cfg: ydoc_cfg.dtx
	${MAKE} --no-print-directory unpack

ydoc-code.sty: ydoc_code_sty.dtx
	${MAKE} --no-print-directory unpack

ydoc-doc.sty: ydoc_doc_sty.dtx
	${MAKE} --no-print-directory unpack

ydoc-desc.sty: ydoc_desc_sty.dtx
	${MAKE} --no-print-directory unpack

ydoc-expl.sty: ydoc_expl_sty.dtx
	${MAKE} --no-print-directory unpack


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

zip: ${PACKAGE}.zip

${PACKAGE}.zip: ${PACKFILES} | unpack
	@test -n "${IGNORE_CHECKSUM}" || grep -L '\* Checksum passed \*' ${PACKAGE_DTX:.dtx=.log} | wc -l | grep -q '^0$$'
	-pdfopt ${PACKAGE}.pdf opt_${PACKAGE}.pdf && mv opt_${PACKAGE}.pdf ${PACKAGE}.pdf
	${RM} $@
	zip $@ ${PACKFILES}
	@echo
	@echo "ZIP file $@ created!"

release: fullclean package doc tests ${ZIPFILE}

ctanify: ${PACKFILES} ${PACKAGE}.tds.zip
	${RM} adjustbox.zip
	zip adjustbox.zip $^
	unzip -t adjustbox.zip
	unzip -t adjustbox.tds.zip

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

