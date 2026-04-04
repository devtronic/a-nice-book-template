# Callout Boxes {#sec:callouts}

Callout boxes draw the reader's attention to information that matters more than ordinary prose — tips that save time, warnings about common mistakes, and danger notices about irreversible actions.

## The Three Variants

The template provides three callout environments, each with a distinct color and icon.

### Tip

A tip (`tipbox`) uses a blue accent and a lightbulb icon. Use it for shortcuts, best practices, and non-obvious approaches that a reader might appreciate knowing:

```{=latex}
\begin{tipbox}
You can pass multiple \texttt{-\/-lua-filter} flags to Pandoc. Filters
run in the order they are listed, so put \texttt{mermaid.lua} before
\texttt{tables.lua} to ensure diagrams are resolved before the table
filter inspects the AST.
\end{tipbox}
```

### Warning

A warning (`warningbox`) uses an orange accent and a triangle icon. Use it when a common mistake leads to a confusing error message or unexpected output:

```{=latex}
\begin{warningbox}
Pandoc renumbers ordered list items automatically, so using \texttt{1.}
for every item is safe and saves you from renumbering when you reorder.
However, if you mix Arabic numerals and letter-based lists in the same
block, Pandoc may interpret the result as a single list.
\end{warningbox}
```

### Danger

A danger box (`dangerbox`) uses a red accent and a fire icon. Reserve it for actions that destroy data, break the build permanently, or have security implications:

```{=latex}
\begin{dangerbox}
Running \texttt{make clean} deletes the entire \texttt{build/} directory,
including all rendered Mermaid images. Your Markdown source is safe, but
any manually placed files in \texttt{build/} will be gone permanently.
\end{dangerbox}
```

## Syntax

Callout boxes are raw LaTeX blocks. Wrap the content in the appropriate environment:

````markdown
```{=latex}
\begin{tipbox}
Your tip content here.
\end{tipbox}
```
````

The `{=latex}` fence tells Pandoc to pass the block through to XeLaTeX verbatim. It is ignored for EPUB and HTML output.

```{=latex}
\begin{tipbox}
For HTML and EPUB callouts, add a matching \texttt{\{=html\}} raw block
alongside the latex one, using a styled \texttt{<aside>} element. See
the sample chapter in the repository for a side-by-side example.
\end{tipbox}
```

## Custom Titles

Each environment accepts an optional argument to override the default title:

````markdown
```{=latex}
\begin{tipbox}[Performance Note]
Prefer \texttt{HashMap} over \texttt{BTreeMap} when you do not need
sorted iteration — hash-based lookups are $O(1)$ amortized.
\end{tipbox}
```
````

```{=latex}
\begin{tipbox}[Performance Note]
Prefer \texttt{HashMap} over \texttt{BTreeMap} when you do not need
sorted iteration — hash-based lookups are $O(1)$ amortized.
\end{tipbox}
```

## Multi-Paragraph Callouts

Callout boxes support multiple paragraphs and even code blocks inside them:

```{=latex}
\begin{warningbox}[Font Not Found]
If the build fails with a fontspec error, the Inter font is not
registered in the system font cache. Install or re-register it:

\begin{Verbatim}
$ brew install --cask font-inter
\end{Verbatim}

Then run \texttt{make clean \&\& make pdf} to rebuild from scratch.
\end{warningbox}
```

## Changing Default Labels

The default labels (Tip, Warning, Danger) are defined in `templates/latex/preamble.tex`. To change them — for example, to localize them or to add an icon — edit the `\newtcolorbox` definitions:

```latex
% Change "Tip" to "Pro Tip" with a star icon
\newtcolorbox{tipbox}[1][\faStar\enspace Pro Tip]{
  callout=accentblue,
  title=#1,
}
```

The icon name (`\faStar`) comes from the `fontawesome5` package. Browse available icons at `fontawesome.com/icons` and use the LaTeX name from the `fontawesome5` documentation.
