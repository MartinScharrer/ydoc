The `ydoc` class and packages
=============================
Copyright (c) 2011-2022 by Martin Scharrer <martin.scharrer@web.de>  
License: [LPPL v1.3c](https://www.latex-project.org/lppl/lppl-1-3c/)  
CTAN: https://www.ctan.org/pkg/ydoc  
Texdoc: https://texdoc.org/pkg/ydoc  
Homepage: https://github.com/MartinScharrer/ydoc  
Repository: https://github.com/MartinScharrer/ydoc.git  
Issue tracker: https://github.com/MartinScharrer/ydoc/issues  

`ydoc` provides macros and environments to document LaTeX packages and classes.
It is an alternative to the `ltxdoc` class and `doc` package.
It targets a different layout and tries to provide more modern styles (`xcolor`, `hyperref`, etc.).

This is an alpha release. It should not be used yet for other packages.

INSTALL
-------

This package might be part of your LaTeX distribution (TeX Live, MikTeX, ...) and then is installable using
the distributions package manager (TeX Live: `tlmgr install ydoc`).
However, it is also manually installable using the following ways:

### TDS ZIP FILE ###

A TDS ZIP file includes all files in a installable format and using the required directory structure.
Simply unzip the TDS ZIP file over your TEXMF tree.
The TDS ZIP file can be downloaded from CTAN:
http://mirrors.ctan.org/install/macros/latex/contrib/ydoc.tds.zip


### DTX FILE ###

The `ydoc.dtx` file includes all required files, which can be extracted by compiling it using TeX (not LaTeX):

    tex ydoc.dtx

To build the documentation compile the same file using LaTeX (preferable 'pdflatex') multiple times:

    pdflatex ydoc.dtx
    pdflatex ydoc.dtx
    pdflatex ydoc.dtx

Copy all files to their correct location of your local TEXMF tree.
For example under Linux a personal TEXMF is normally located at `~/texmf` (`$HOME/texmf`)
and under Windows usually under `C:\Users\<username>\texmf`.  
The files can be installed using the following Linux commands:

    mkdir -p "${TEXMF}/tex/latex/ydoc/"
    mkdir -p "${TEXMF}/source/latex/ydoc/"
    mkdir -p "${TEXMF}/doc/latex/ydoc/"
    mkdir -p "${TEXMF}/tex/generic/ydoc/"
    cp ydoc.sty ydoc.cls ydoc-code.sty ydoc-desc.sty ydoc-doc.sty ydoc-expl.sty ydoc.cfg "${TEXMF}/tex/latex/ydoc"
    cp ydoc.dtx ydoc.ins "${TEXMF}/source/latex/ydoc"
    cp ydoc.pdf README "${TEXMF}/doc/latex/ydoc"
    cp ydocincl.tex ydocstrip.tex "${TEXMF}/tex/generic/ydoc"

Update the tree database file (might be not required for modern versions and personal TEXMF trees):

    texhash ${TEXMF}


