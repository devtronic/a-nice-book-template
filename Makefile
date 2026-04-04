# ============================================================
#  Book build system — Pandoc + XeLaTeX
#
#  Prerequisites: pandoc, xelatex (via basictex), qpdf
#  Install with:  make install-deps
#  After install: restart terminal, then run the tlmgr commands
#                 printed by install-deps.
# ============================================================

BOOK          := book
BUILD         := build
CHAPTERS      := $(sort $(wildcard chapters/*.md))
METADATA      := book.yaml
BIBFILE       := references.bib
PREAMBLE      := templates/latex/preamble.tex
HL_THEME      := templates/highlighting/base16-light.theme
EPUB_COVER    := assets/cover.png
FILTERS       := --lua-filter=filters/preamble.lua \
                 --lua-filter=filters/mermaid.lua \
                 --lua-filter=filters/tables.lua

# Auto-detect XeLaTeX from basictex/MacTeX installation
TEXLIVE_BIN := $(shell find /usr/local/texlive -maxdepth 4 -name "xelatex" \
                  ! -name "*-dev" ! -name "*-unsafe" 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
ifneq ($(TEXLIVE_BIN),)
  export PATH := $(TEXLIVE_BIN):$(PATH)
endif

# Excerpt page range (override on command line)
EXCERPT_START ?= 1
EXCERPT_END   ?= 3

# Common pandoc flags shared across targets
PANDOC_COMMON := \
  --metadata-file=$(METADATA) \
  --bibliography=$(BIBFILE) \
  --citeproc \
  --number-sections \
  --toc \
  --toc-depth=3 \
  --syntax-highlighting=$(HL_THEME)

.PHONY: all pdf epub html excerpt clean install-deps

all: pdf epub html

# ------------------------------------------------------------------
#  PDF via pandoc -> XeLaTeX
# ------------------------------------------------------------------
pdf: $(BUILD)/$(BOOK).pdf

$(BUILD)/$(BOOK).pdf: $(CHAPTERS) $(METADATA) $(BIBFILE) $(PREAMBLE) $(HL_THEME) | $(BUILD)
	pandoc \
	  $(PANDOC_COMMON) \
	  $(FILTERS) \
	  --to=pdf \
	  --pdf-engine=xelatex \
	  \
	  --output=$@ \
	  $(CHAPTERS)

# ------------------------------------------------------------------
#  EPUB
# ------------------------------------------------------------------
epub: $(BUILD)/$(BOOK).epub

$(BUILD)/$(BOOK).epub: $(CHAPTERS) $(METADATA) $(BIBFILE) | $(BUILD)
	pandoc \
	  $(PANDOC_COMMON) \
	  --lua-filter=filters/mermaid.lua \
	  --to=epub3 \
	  $(if $(wildcard $(EPUB_COVER)),--epub-cover-image=$(EPUB_COVER),) \
	  --output=$@ \
	  $(CHAPTERS)

# ------------------------------------------------------------------
#  HTML (self-contained single file)
# ------------------------------------------------------------------
html: $(BUILD)/$(BOOK).html

$(BUILD)/$(BOOK).html: $(CHAPTERS) $(METADATA) $(BIBFILE) | $(BUILD)
	pandoc \
	  $(PANDOC_COMMON) \
	  --lua-filter=filters/mermaid.lua \
	  --to=html5 \
	  --embed-resources \
	  --standalone \
	  --output=$@ \
	  $(CHAPTERS)

# ------------------------------------------------------------------
#  Excerpt: extract a page range from the built PDF
#  Usage:   make excerpt EXCERPT_START=5 EXCERPT_END=20
#  Output:  build/excerpt-pN-pM.pdf
# ------------------------------------------------------------------
excerpt: $(BUILD)/$(BOOK).pdf
	@echo "Extracting pages $(EXCERPT_START)-$(EXCERPT_END) from $< ..."
	qpdf $< \
	  --pages $< $(EXCERPT_START)-$(EXCERPT_END) \
	  -- $(BUILD)/excerpt-p$(EXCERPT_START)-p$(EXCERPT_END).pdf
	@echo "Written: $(BUILD)/excerpt-p$(EXCERPT_START)-p$(EXCERPT_END).pdf"

# ------------------------------------------------------------------
#  Housekeeping
# ------------------------------------------------------------------
$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)

# ------------------------------------------------------------------
#  Dependency installation (macOS / Homebrew)
#
#  basictex is ~100 MB; use 'brew install --cask mactex' for the
#  full 4 GB distribution if you need additional packages.
# ------------------------------------------------------------------
install-deps:
	brew update
	brew install pandoc qpdf
	brew install --cask basictex font-inter font-fira-code
	@echo ""
	@echo "================================================================"
	@echo " Dependencies installed. Now:"
	@echo ""
	@echo " 1. Restart your terminal to put xelatex on PATH:"
	@echo "    eval \"\$$($$(/usr/libexec/path_helper -s))\""
	@echo ""
	@echo " 2. Install required LaTeX packages (user-mode, no sudo needed):"
	@echo "    TLMGR=/usr/local/texlive/\$$(ls /usr/local/texlive | grep basic | sort | tail -1)/bin/universal-darwin/tlmgr"
	@echo "    \$$TLMGR init-usertree"
	@echo "    \$$TLMGR --usermode install \\"
	@echo "      framed enumitem pdfcol tikzfill fvextra \\"
	@echo "      booktabs caption microtype fancyhdr \\"
	@echo "      titlesec tcolorbox fontawesome5 \\"
	@echo "      colortbl array"
	@echo ""
	@echo " 3. Install mermaid CLI: npm install -g @mermaid-js/mermaid-cli"
	@echo ""
	@echo " 4. Then run: make pdf"
	@echo "================================================================"
