# $Id$

PACKAGE     = ydoc
PACKAGE_STY = ydoc.cls ydoc.sty ydoc-desc.sty ydoc-expl.sty ydoc-code.sty ydoc-doc.sty ydoc.cfg
PACKAGE_SUBDTX=ydoc.ins  ydoc_doc.dtx  ydoc_cls.dtx  ydoc_sty.dtx  ydoc_cfg.dtx  ydoc_code_sty.dtx  ydoc_doc_sty.dtx  ydoc_desc_sty.dtx  ydoc_expl_sty.dtx
PACKAGE_DTX = ydoc.dtx
PACKAGE_DOC = $(PACKAGE_DTX:.dtx=.pdf)
PACKAGE_SRC = ${PACKAGE_DTX} ${PACKAGE}.ins Makefile
PACKFILES   = ${PACKAGE_SRC} ${PACKAGE_DOC} README

TEXAUX = *.aux *.log *.glo *.ind *.idx *.out *.svn *.svx *.svt *.toc *.ilg *.gls *.hd *.exa *.exb *.fdb_latexmk *.tmp *.cpr *.cod
INSGENERATED = ${PACKAGE_STY}
GENERATED = ${INSGENERATED} ${PACKAGE}.pdf ${PACKAGE}.zip ${PACKAGE}.tar.gz ${TESTDIR}/test*.pdf
ZIPFILE = ${PACKAGE}-${ZIPVERSION}.zip
TDSZIPFILE = ${PACKAGE}-${ZIPVERSION}.tds.zip

TESTDIR = .
TESTS = $(patsubst %.tex,%,$(subst ${TESTDIR}/,,$(wildcard ${TESTDIR}/test?.tex ${TESTDIR}/test??.tex))) # look for all test*.tex file names and remove the '.tex' 
TESTARGS = -output-directory ${TESTDIR}

LATEX_OPTIONS = -interaction=batchmode -halt-on-error
LATEX = pdflatex ${LATEX_OPTIONS}
PDFLATEX = pdflatex ${LATEX_OPTIONS}

TEXMFDIR = ${HOME}/texmf

RED   = \033[01;31m
GREEN = \033[01;32m
WHITE = \033[00m

CP = cp -v
MV = mv -v
RMDIR = rm -rf
MKDIR = mkdir -p

.PHONY: all doc package clean fullclean example testclean ${TESTS} tds ${CHECK_LOG}

###############################################################################

all: package doc example
new: fullclean all

doc: ${PACKAGE_DOC}

package: unpack

%.pdf: %.dtx
	${LATEX} $*.dtx || ${RM} $*.aux
	-makeindex -s gind.ist -o $*.ind $*.idx
	-makeindex -s gglo.ist -o $*.gls $*.glo
	${LATEX} $*.dtx || ${RM} $*.aux
	${LATEX} $*.dtx || ${RM} $*.aux

pdfopt: doc
	@-pdfopt ydoc.pdf .temp.pdf && mv .temp.pdf ydoc.pdf

ydoc.pdf: ydoc.dtx
	${PDFLATEX} $< || ${RM} ${PACKAGE}.aux
	${PDFLATEX} '\let\install\iffalse\let\endinstall\fi\input{$<}' || ${RM} ${PACKAGE}.aux
	-makeindex -s gind.ist -o "$@" "$<"
	-makeindex -s gglo.ist -o "$@" "$<"
	${PDFLATEX} '\let\install\iffalse\let\endinstall\fi\input{$<}' || ${RM} ${PACKAGE}.aux
	${PDFLATEX} '\let\install\iffalse\let\endinstall\fi\input{$<}' || ${RM} ${PACKAGE}.aux


${PACKAGE}.pdf: ${PACKAGE}.sty

unpack: ${INSGENERATED}

${INSGENERATED}: ydoc.dtx
	${RM} ${INSGENERATED}
	${PDFLATEX} -interaction=nonstopmode '\def\endinstall{\endgroup\csname @enddocumenthook\endcsname\csname @@end\endcsname}\input{ydoc.dtx}' || ${RM} ${PACKAGE}.aux

symlinks:
	${RM} ${INSGENERATED}
	ln -s  ydoc_cls.dtx  ydoc.cls
	ln -s  ydoc_sty.dtx  ydoc.sty
	ln -s  ydoc_cfg.dtx  ydoc.cfg
	ln -s  ydoc_code_sty.dtx  ydoc-code.sty
	ln -s  ydoc_doc_sty.dtx   ydoc-doc.sty
	ln -s  ydoc_desc_sty.dtx  ydoc-desc.sty
	ln -s  ydoc_expl_sty.dtx  ydoc-expl.sty

# 'doc' and 'ydoc.pdf' call itself until everything is stable
doc: ydoc.pdf
	@${MAKE} --no-print-directory ydoc.pdf

once: ydoc.dtx
	pdflatex $< || ${RM} ${PACKAGE}.aux
	-readacro ydoc.pdf

twice: ydoc.dtx
	${PDFLATEX} $< || ${RM} ${PACKAGE}.aux
	${PDFLATEX} '\let\install\iffalse\let\endinstall\fi\input{$<}' || ${RM} ${PACKAGE}.aux
	-readacro ydoc.pdf


clean:
	${RM} -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX})

fullclean: clean
	${RM} -f ${GENERATED} *~ *.backup
	${RM} -f ${PACKAGE}*.zip
	${RM} -rf tds/

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

release: fullclean package doc example tests ${ZIPFILE}

ctanify: ${PACKAGE_STY} ${PACKAGE_DTX} ${PACKAGE_DOC} ${PACKAGE_SRC} README
	ctanify $^

###############################################################################

# Make sure TeX finds the input files in TESTDIR
tests ${TESTS}: export TEXINPUTS:=${TEXINPUTS}:${TESTDIR}
tests ${TESTS}: LATEX_OPTIONS=

testclean:
	@${RM} $(foreach ext, aux log out pdf svn svx, tests/test*.${ext})

tests: package testclean
	@echo "Running tests: ${TESTS}:"
	@${MAKE} -e -i --no-print-directory ${TESTS} \
		TESTARGS="-interaction=batchmode -output-directory=${TESTDIR}"\
		TESTPLOPT="-q"\
		> /dev/null

${TESTS}: % : ${TESTDIR}/%.tex package testclean
	@-${LATEX} -interaction=nonstopmode ${TESTARGS} $< 1>/dev/null 2>/dev/null
	@if (${LATEX} ${TESTARGS} $<); \
		then /bin/echo -e "${GREEN}$@ succeeded${WHITE}" >&2; \
		else /bin/echo -e "${RED}$@ failed!!!!!!${WHITE}" >&2; fi

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

install: .tds
	test -d "${TEXMFDIR}" && ${CP} -a tds/* "${TEXMFDIR}/" && texhash ${TEXMFDIR}

uninstall:
	test -d "${TEXMFDIR}" && ${RM} -rv "${TEXMFDIR}/tex/latex/${PACKAGE}" \
	"${TEXMFDIR}/doc/latex/${PACKAGE}" "${TEXMFDIR}/source/latex/${PACKAGE}" \
	"${TEXMFDIR}/scripts/${PACKAGE}" && texhash ${TEXMFDIR}

dtx: ydoc.dtx

ydoc.dtx: ${PACKAGE_SUBDTX}
	@echo Creating $@
	@cat $^ | perl -ne 'if (/^(\s*\\DocInput)/) { if (!$$n++) { print "$${1}{ydoc.dtx}\n"; } } else { print }' > $@
	@echo '% \Finale' >> $@
	@echo '% \endinput' >> $@

