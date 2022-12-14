% \subsection{Class File}
%
%    \begin{macrocode}
\NeedsTeXFormat{LaTeX2e}[1999/12/01]
\ProvidesClass{ydoc}[%
%<!DATE>
%<!VERSION>
%<*DRIVER>
    2011/08/11 develop
%</DRIVER>
    ydoc class: document LaTeX class and packages]
%    \end{macrocode}
%
% At the moment simply load \cls{article} class with \opt{a4paper} option
% and load the \pkg{ydoc} package.
%    \begin{macrocode}
\PassOptionsToClass{a4paper}{article}
\DeclareOption*{\expandafter\PassOptionsToClass\expandafter{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}
\RequirePackage{ydoc}
%    \end{macrocode}
