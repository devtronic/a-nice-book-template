# ============================================================
#  Book build system — Pandoc + XeLaTeX
#
#  Quick start (Docker, recommended):
#    make docker-build        # build image once (~10-20 min first time)
#    make pdf                 # builds inside a transient container
#    make all                 # pdf + epub + html
#
#  Local build (requires pandoc, xelatex, fonts, qpdf installed):
#    make pdf USE_DOCKER=0
#    make install-deps        # macOS/Homebrew setup (USE_DOCKER=0 implied)
#
#  Other targets:
#    make epub
#    make html
#    make excerpt [EXCERPT_START=N EXCERPT_END=M]
#    make clean
#    make docker-shell        # open a shell inside the build container
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

# ── Docker configuration ──────────────────────────────────────
DOCKER_IMAGE  := book-builder:latest

# Set USE_DOCKER=0 on the command line to force a local build.
USE_DOCKER    ?= 1

# Set automatically to 1 inside the container to prevent re-entry.
IN_DOCKER     ?= 0

# Detect whether Docker daemon is reachable.
DOCKER_AVAILABLE := $(shell docker info >/dev/null 2>&1 && echo 1 || echo 0)

# Decide whether to delegate to Docker:
#   - skip if already inside the container (IN_DOCKER=1)
#   - skip if user opted out (USE_DOCKER=0)
#   - skip with a warning if Docker is not running
ifeq ($(IN_DOCKER),1)
  USE_DOCKER_RUN := 0
else ifeq ($(USE_DOCKER),0)
  USE_DOCKER_RUN := 0
else ifeq ($(DOCKER_AVAILABLE),0)
  USE_DOCKER_RUN := 0
  $(warning Docker not available - falling back to native build)
else
  USE_DOCKER_RUN := 1
endif

# docker run flags:
#   --rm           transient container, cleaned up on exit
#   -v             mount project root into the container's WORKDIR
#   -e IN_DOCKER=1 prevents the container's make from re-entering Docker
#   -e HOME=/tmp   gives XeLaTeX/fontconfig a writable home for caches
#   -e EXCERPT_*   forward page-range parameters for the excerpt target
DOCKER_RUN := docker run --rm \
  -v "$(CURDIR):/book" \
  -e IN_DOCKER=1 \
  -e HOME=/tmp \
  -e EXCERPT_START=$(EXCERPT_START) \
  -e EXCERPT_END=$(EXCERPT_END) \
  $(DOCKER_IMAGE)

# ── Excerpt page range (override on command line) ─────────────
EXCERPT_START ?= 1
EXCERPT_END   ?= 3

# ── Common pandoc flags ───────────────────────────────────────
PANDOC_COMMON := \
  --metadata-file=$(METADATA) \
  --bibliography=$(BIBFILE) \
  --citeproc \
  --number-sections \
  --toc \
  --toc-depth=3 \
  --syntax-highlighting=$(HL_THEME)

# ============================================================
#  Build targets
#  When USE_DOCKER_RUN=1: delegate each target into the container.
#  When USE_DOCKER_RUN=0: run natively (original recipes, unchanged).
# ============================================================

ifeq ($(USE_DOCKER_RUN),1)

.PHONY: all pdf epub html excerpt clean
all pdf epub html excerpt clean:
	$(DOCKER_RUN) $@

else

# Auto-detect XeLaTeX from basictex/MacTeX installation (macOS)
TEXLIVE_BIN := $(shell find /usr/local/texlive -maxdepth 4 -name "xelatex" \
                  ! -name "*-dev" ! -name "*-unsafe" 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
ifneq ($(TEXLIVE_BIN),)
  export PATH := $(TEXLIVE_BIN):$(PATH)
endif

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
	@echo " 4. Then run: make pdf USE_DOCKER=0"
	@echo "================================================================"

endif
# ── End of USE_DOCKER_RUN conditional ────────────────────────

# ============================================================
#  Docker image management (always run on the host)
# ============================================================
.PHONY: docker-build docker-shell

docker-build:
	docker build -t $(DOCKER_IMAGE) .

docker-shell:
	docker run --rm -it \
	  -v "$(CURDIR):/book" \
	  -e IN_DOCKER=1 \
	  -e HOME=/tmp \
	  --entrypoint /bin/bash \
	  $(DOCKER_IMAGE)
