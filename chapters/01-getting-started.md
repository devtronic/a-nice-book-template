# Getting Started {#sec:getting-started}

This chapter walks you through installing every dependency, verifying your environment, and producing your first PDF.

## Prerequisites

You need three things before you begin:

| Tool | Purpose | Install |
|------|---------|---------|
| Homebrew | macOS package manager | `brew.sh` |
| Node.js | Mermaid diagram rendering | via Homebrew |
| Git | Version control | via Xcode CLT |

Everything else — Pandoc, XeLaTeX, fonts, and LaTeX packages — is installed by a single Makefile target.

## Installation

Run the following from the repository root:

```bash
$ make install-deps
```

This performs three steps:

1. Installs `pandoc` and `qpdf` via Homebrew.
2. Installs the `basictex` cask (~100 MB, includes XeLaTeX).
3. Installs the `Inter` and `Fira Code` font casks.

When it finishes, follow the printed instructions to update your `PATH` and install the required LaTeX packages.

### Updating PATH

The basictex cask places XeLaTeX in `/usr/local/texlive/*/bin/universal-darwin/`, which is not on your shell's default path. Run the helper command that `make install-deps` prints, or simply restart your terminal:

```bash
$ eval "$($(/usr/libexec/path_helper -s))"
$ which xelatex
/usr/local/texlive/2026basic/bin/universal-darwin/xelatex
```

```{=latex}
\begin{tipbox}
The Makefile auto-detects the texlive bin directory at build time using
\texttt{find}, so \texttt{make pdf} works even if your shell does not have
XeLaTeX on its \texttt{PATH} yet. The \texttt{which xelatex} step above is
only needed for running \texttt{xelatex} manually.
\end{tipbox}
```

### LaTeX Packages

Install the required packages using `tlmgr` in user mode (no `sudo` required):

```bash
$ TLMGR=/usr/local/texlive/$(ls /usr/local/texlive \
    | grep basic | sort | tail -1)/bin/universal-darwin/tlmgr

$ $TLMGR init-usertree
$ $TLMGR --usermode install \
    framed enumitem pdfcol tikzfill fvextra \
    booktabs caption microtype fancyhdr    \
    titlesec tcolorbox fontawesome5        \
    colortbl array
```

### Mermaid CLI

Diagram rendering requires the Mermaid CLI:

```bash
$ npm install -g @mermaid-js/mermaid-cli
$ mmdc --version
11.x.x
```

## Your First Build

Once dependencies are in place, build the PDF:

```bash
$ make pdf
pandoc \
  --metadata-file=book.yaml ...
  --output=build/book.pdf \
  chapters/*.md
```

The first build takes 10–20 seconds. Subsequent builds are faster because Make only re-runs pandoc when a source file changes.

Open `build/book.pdf` to confirm the output. You should see a title page, a table of contents, and the chapter text with Inter body font and Fira Code for any code blocks.

```{=latex}
\begin{warningbox}
If the build fails with \texttt{Font "Inter 18pt" cannot be found}, the
Inter font cask was not installed, or the font cache is stale. Run
\texttt{brew install --cask font-inter} and try again.
\end{warningbox}
```

## Repository Layout

After installation the repository looks like this:

```
book/
├── Makefile                   # build targets
├── book.yaml                  # title, author, fonts, PDF settings
├── references.bib             # BibTeX bibliography
├── .gitignore                 # excludes build/
├── chapters/                  # one .md file per chapter
├── assets/
│   └── images/                # figures referenced from chapters
├── code/                      # external code files
├── filters/
│   ├── mermaid.lua            # Mermaid diagram filter
│   └── tables.lua             # table header/row styling filter
└── templates/
    ├── highlighting/
    │   └── base16-light.theme # syntax highlighting palette
    └── latex/
        └── preamble.tex       # fonts, headings, callout boxes
```

Every file you touch when writing is in `chapters/`, `assets/images/`, `code/`, or `references.bib`. The rest is infrastructure you configure once and then leave alone.

## Adding a New Chapter

Create a new Markdown file in `chapters/` with a numeric prefix:

```bash
$ touch chapters/03-my-chapter.md
```

The Makefile includes chapters using `$(sort $(wildcard chapters/*.md))`, which expands lexicographically. Prefixes `00-` through `99-` give you up to 100 chapters in the correct order. Run `make pdf` and the new chapter appears automatically — no registration step required.

```{=latex}
\begin{tipbox}
Pad single-digit numbers: use \texttt{03-} not \texttt{3-}. Without
padding, \texttt{10-} sorts before \texttt{9-} and your chapters appear
in the wrong order.
\end{tipbox}
```
