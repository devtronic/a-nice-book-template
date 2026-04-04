# Writing Content {#sec:writing-content}

Chapters are standard Pandoc-flavored Markdown files. This chapter covers the subset of Markdown you need for a technical book: headings, prose formatting, lists, and cross-references.

## Document Structure

A chapter file begins with a level-1 heading, which becomes the chapter title:

````markdown
# My Chapter Title {#sec:my-chapter}
````

The `{#sec:my-chapter}` attribute assigns an anchor you can link to from other chapters. Pandoc uses this for cross-references (see [Cross-References](#sec:cross-references)).

Use level-2 headings for sections and level-3 for subsections. Avoid going deeper than three levels — if you find yourself needing a level-4 heading, the section probably needs to be split into its own chapter.

## Prose Formatting

Standard Markdown inline formatting works as expected:

| Syntax | Output |
|--------|--------|
| `**bold**` | **bold** |
| `*italic*` | *italic* |
| `` `inline code` `` | `inline code` |
| `~~strikethrough~~` | ~~strikethrough~~ |

For a line break within a paragraph, end a line with two spaces or use a backslash at the end of the line.

## Lists

Unordered lists use `-` or `*`:

```markdown
- First item
- Second item
    - Nested item
    - Another nested item
- Third item
```

Which produces:

- First item
- Second item
    - Nested item
    - Another nested item
- Third item

Ordered lists use numbers. Pandoc renumbers automatically, so you can use `1.` for every item and the output will be correctly numbered:

```markdown
1. Clone the repository
1. Run `make install-deps`
1. Run `make pdf`
```

Produces:

1. Clone the repository
1. Run `make install-deps`
1. Run `make pdf`

## Block Quotes

Block quotes use the `>` prefix and are useful for quoting external sources:

```markdown
> The best way to predict the future is to invent it.
>
> — Alan Kay
```

> The best way to predict the future is to invent it.
>
> — Alan Kay

## Cross-References {#sec:cross-references}

Link to another section using its anchor in a standard Markdown link:

```markdown
See [Getting Started](#sec:getting-started) for installation instructions.
```

See [Getting Started](#sec:getting-started) for installation instructions.

For citations and bibliography references, use the `@key` syntax described in [Chapter 6](#sec:references).

## The Book Metadata File

`book.yaml` controls the title page and output options. The most important fields:

```yaml
title:    "Your Book Title"
subtitle: "A Practical Guide"
author:
  - "Your Name"
date:     "2026"
```

Change these fields before your first commit. The values appear on the PDF title page, in the EPUB metadata, and in the HTML `<title>` tag.

```{=latex}
\begin{warningbox}
The \texttt{hyperrefoptions} block in \texttt{book.yaml} lets you embed
PDF metadata (author, subject). Do not put a comma-separated value in
\texttt{pdfkeywords} directly in that block — the commas confuse
hyperref's keyval parser. Set keywords in \texttt{preamble.tex} via
\texttt{\textbackslash hypersetup\{pdfkeywords=\{word1; word2\}\}} instead.
\end{warningbox}
```

## Special Characters

Pandoc handles most Unicode transparently. XeLaTeX with the Inter font supports the full Latin Extended range, Greek, Cyrillic, and common mathematical symbols out of the box.

For occasional math inline, use `$...$`:

```markdown
The time complexity is $O(n \log n)$.
```

The time complexity is $O(n \log n)$.

For display equations, use `$$...$$` on its own paragraph:

```markdown
$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$
```

$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$
