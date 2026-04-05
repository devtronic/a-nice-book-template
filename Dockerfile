# syntax=docker/dockerfile:1
# ============================================================
#  Book build image — based on pandoc/latex
#  (pandoc + TinyTeX/XeLaTeX already included)
#
#  Build:  make docker-build
#  Use:    make pdf          (runs automatically via Makefile)
# ============================================================
FROM pandoc/latex:3.9.0-ubuntu

# ── Build-time pins ──────────────────────────────────────────
ARG INTER_VERSION=4.1

# ── System packages ──────────────────────────────────────────
# Includes shared libs required by Puppeteer's bundled Chromium.
# We do NOT install a system Chrome/Chromium — Puppeteer downloads
# the right binary for the current arch (amd64 or arm64/Apple Silicon).
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    qpdf \
    nodejs \
    npm \
    fonts-firacode \
    wget \
    unzip \
    fontconfig \
    # Puppeteer/Chromium runtime dependencies \
    libnspr4 libnss3 \
    libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libgbm1 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libpango-1.0-0 libcairo2 \
    libasound2t64 \
  && rm -rf /var/lib/apt/lists/*

# ── LaTeX packages (via tlmgr, already configured in base image) ─
RUN tlmgr install \
    framed enumitem pdfcol tikzfill fvextra \
    booktabs caption microtype fancyhdr \
    titlesec tcolorbox fontawesome5 \
    colortbl

# ── Inter font (static TTF variants) ─────────────────────────
# Inter v4.x ships two optical-size families as static TTFs in
# extras/ttf/: "Inter" (text) and "Inter Display" (headings).
# book.yaml uses "Inter" as mainfont; preamble.tex uses
# "Inter Display" for chapter/section headings.
RUN wget -q -O /tmp/inter.zip \
    "https://github.com/rsms/inter/releases/download/v${INTER_VERSION}/Inter-${INTER_VERSION}.zip" \
  && mkdir -p /usr/local/share/fonts/inter \
  && unzip -q /tmp/inter.zip -d /tmp/inter \
  && find /tmp/inter/extras/ttf -name "*.ttf" \
       -exec cp {} /usr/local/share/fonts/inter/ \; \
  && fc-cache -fv \
  && rm -rf /tmp/inter /tmp/inter.zip

# ── mermaid-cli ──────────────────────────────────────────────
# Install to /opt/mermaid so its bin does not conflict with the
# /usr/local/bin/mmdc wrapper created below.
# Skip Puppeteer's bundled Chromium — it doesn't provide arm64
# Linux builds. We install Chromium separately via Playwright.
ENV PUPPETEER_SKIP_DOWNLOAD=true

RUN npm install -g --prefix /opt/mermaid @mermaid-js/mermaid-cli

# ── Chromium (arm64-compatible) ──────────────────────────────
# Playwright maintains Chromium builds for both amd64 and arm64
# Linux. Install Chromium, then symlink to a stable path so the
# Puppeteer config doesn't depend on the Playwright revision ID.
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/playwright
RUN npx -y playwright install chromium 2>/dev/null \
  && CHROME_BIN=$(find /opt/playwright -name "chrome" -type f -path "*/chromium-*/chrome-linux/*" | head -1) \
  && mkdir -p /opt/chromium \
  && ln -s "$CHROME_BIN" /opt/chromium/chrome

# Puppeteer config: point to Playwright's Chromium, disable sandbox
RUN printf '{\n  "executablePath": "/opt/chromium/chrome",\n  "args": [\n    "--no-sandbox",\n    "--disable-setuid-sandbox",\n    "--disable-dev-shm-usage",\n    "--disable-gpu"\n  ]\n}\n' \
    > /etc/mmdc-puppeteer-config.json

# mmdc wrapper: transparently injects --puppeteerConfigFile so
# filters/mermaid.lua (which calls plain `mmdc`) works unmodified.
RUN printf '#!/bin/sh\nexec /opt/mermaid/bin/mmdc \\\n  --puppeteerConfigFile /etc/mmdc-puppeteer-config.json \\\n  "$@"\n' \
    > /usr/local/bin/mmdc \
  && chmod +x /usr/local/bin/mmdc

# ── Working directory ────────────────────────────────────────
WORKDIR /book

ENTRYPOINT ["make"]
CMD ["all"]
