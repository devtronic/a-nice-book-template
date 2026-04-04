# Customization {#sec:customization}

The template is designed to be changed. This chapter covers the four main customization surfaces: book metadata, fonts, the code color theme, and the LaTeX preamble.

## Book Metadata

Edit `book.yaml` to set the title page content and output options:

```yaml
title:    "Distributed Systems in Practice"
subtitle: "A Field Guide for Engineers"
author:
  - "Ada Lovelace"
  - "Grace Hopper"
date:     "2026"
```

Multiple authors are listed as a YAML sequence. They appear stacked on the title page.

### Paper Size

Change `papersize: letter` to `papersize: a4` for European print formats. The geometry margins adjust automatically; you may want to tweak them as well:

```yaml
papersize: a4
geometry: "top=25mm, bottom=30mm, left=30mm, right=25mm"
```

### Two-Sided Layout

For a print book with a spine, switch to two-sided layout:

```yaml
classoption:
  - twoside
  - 12pt
```

In two-sided mode, XeLaTeX applies alternating inner/outer margins and the header shows the chapter title on left pages and the section title on right pages.

## Fonts

### Body and Heading Font

The body font is set in `book.yaml`. The template ships configured for Inter:

```yaml
mainfont: "Inter 18pt"
sansfont: "Inter 18pt"
```

To switch to a different font, install it as a system font (e.g., via a Homebrew cask) and update the family name to match `fc-list` output:

```bash
$ fc-list | grep "Source Serif"
/Users/you/Library/Fonts/SourceSerif4-Regular.ttf: Source Serif 4:style=Regular
```

Then in `book.yaml`:

```yaml
mainfont: "Source Serif 4"
```

```{=latex}
\begin{tipbox}
Serif fonts (like Source Serif, TeX Gyre Termes, or Palatino) are
traditionally preferred for long-form print. Sans-serif fonts (Inter,
Source Sans) read better on screen. Choose based on your primary
distribution format.
\end{tipbox}
```

### Code Font

The code font is set with `monofont` and `monofontoptions`:

```yaml
monofont: "Fira Code"
monofontoptions:
  - "Contextuals=Alternate"  # enables programming ligatures
  - "Scale=0.85"
```

`Contextuals=Alternate` activates Fira Code's programming ligatures: `->`, `=>`, `!=`, `<=`, `>=`, `::`, and others render as single connected glyphs. To disable ligatures, remove that option.

Popular alternatives to Fira Code:

| Font | Notes |
|---|---|
| JetBrains Mono | Slightly wider, excellent at small sizes |
| Cascadia Code | Microsoft's ligature font, ships with VS Code |
| Inconsolata | Classic, no ligatures, very readable |
| IBM Plex Mono | Clean and neutral |

### Font Size

Change the base font size in `classoption`:

```yaml
classoption:
  - oneside
  - 11pt   # 10pt, 11pt, or 12pt
```

The LaTeX `book` class supports 10pt, 11pt, and 12pt directly. Everything else — heading sizes, code font scale, line spacing — scales proportionally.

## Syntax Highlighting Theme

The custom theme lives in `templates/highlighting/base16-light.theme`. It is a JSON file mapping pandoc token types to colors.

To change a color, find the token type and update its `text-color`:

```json
"Keyword": {
  "text-color": "#0000af",
  "bold": true,
  "italic": false,
  "underline": false
},
```

To switch to a built-in pandoc theme entirely, replace the `--syntax-highlighting` value in the Makefile:

```makefile
PANDOC_COMMON := \
  ...
  --syntax-highlighting=pygments   # or kate, tango, espresso, zenburn
```

The code block background color (`#f5f5f5`) is defined separately in `preamble.tex` as `\definecolor{shadecolor}{HTML}{f5f5f5}`. Update both if you switch to a dark theme.

```{=latex}
\begin{warningbox}
Dark code themes look striking in HTML but can be expensive to print.
If you are producing a print book, stick to a light background theme
to avoid wasting ink and ensure the code is legible in photocopies.
\end{warningbox}
```

## Callout Box Colors

Callout box colors are defined as named colors in `preamble.tex`:

```latex
\definecolor{accent}{HTML}{ac4142}      % danger / keyword red
\definecolor{accentblue}{HTML}{6a9fb5}  % tip / type blue
\definecolor{accentorange}{HTML}{d28445}% warning / function orange
```

Change any hex value to restyle the corresponding callout boxes. The colors are also used in the chapter heading accent (`accent`) and list bullet points (`accent`), so a change here propagates consistently.

## Page Headers and Footers

The header and footer are configured in `preamble.tex` using `fancyhdr`. The defaults show the chapter title on the left of the header and a centered page number in the footer.

To show the chapter title on the right and the book title on the left:

```latex
\fancyhead[L]{\small\sffamily\color{textmuted}My Book Title}
\fancyhead[R]{\small\sffamily\color{textmuted}\nouppercase{\leftmark}}
```

To move the page number to the outer margin (better for two-sided print):

```latex
\fancyfoot[LE,RO]{\small\sffamily\color{textmuted}\thepage}
\fancyfoot[LO,RE]{}
```

`L`=left, `R`=right, `C`=center, `E`=even pages, `O`=odd pages.

## Chapter Heading Style

The chapter heading format is defined in `preamble.tex` using `titlesec`. The default shows `CHAPTER N` in accent red above the title with a gray rule below.

To use a simpler style with just the number and title on one line:

```latex
\titleformat{\chapter}[hang]
  {\normalfont\headingfontlg\Huge\bfseries}
  {\thechapter\hspace{0.5em}\textcolor{rulecolor}{|}\hspace{0.5em}}
  {0pt}
  {}

\titlespacing*{\chapter}{0pt}{40pt}{20pt}
```

## Adding HTML Callouts

Raw `{=latex}` blocks are silently dropped in HTML and EPUB output. To show callout boxes in all formats, pair each LaTeX block with an HTML equivalent:

````markdown
```{=latex}
\begin{tipbox}
Use \texttt{make all} to build all three formats at once.
\end{tipbox}
```

```{=html}
<aside style="border-left: 4px solid #6a9fb5; background: #eef6fc;
              padding: 0.75em 1em; margin: 1.5em 0; border-radius: 0 4px 4px 0;">
  <strong style="color: #6a9fb5;">Tip</strong><br>
  Use <code>make all</code> to build all three formats at once.
</aside>
```
````

This approach keeps the source readable and gives you independent control over the PDF and HTML presentation.
