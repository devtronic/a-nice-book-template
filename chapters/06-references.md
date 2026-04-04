# Citations and References {#sec:references}

The template uses Pandoc's built-in citation processor (`--citeproc`) with a BibTeX bibliography. You write citation keys in your prose, and Pandoc resolves them against `references.bib` to produce correctly formatted in-text citations and a bibliography section.

## Adding References to the Bibliography

Open `references.bib` and add entries in BibTeX format. The file ships with a few examples:

```bibtex
@book{knuth1984literate,
  author    = {Knuth, Donald E.},
  title     = {Literate Programming},
  publisher = {Center for the Study of Language and Information},
  year      = {1984},
}

@article{lamport1978time,
  author  = {Lamport, Leslie},
  title   = {Time, Clocks, and the Ordering of Events in a
             Distributed System},
  journal = {Communications of the ACM},
  volume  = {21},
  number  = {7},
  pages   = {558--565},
  year    = {1978},
  doi     = {10.1145/359545.359563},
}
```

BibTeX supports many entry types:

| Type | Use for |
|---|---|
| `@book` | Books and monographs |
| `@article` | Journal articles |
| `@inproceedings` | Conference papers |
| `@techreport` | Technical reports, RFCs |
| `@misc` | Web pages, software, other sources |
| `@online` | URLs (pandoc-citeproc extension) |

## Citing in Prose

Use the `@key` syntax to cite a work. Pandoc resolves the key against `references.bib` and inserts a formatted citation.

A bare citation in parentheses:

```markdown
Distributed systems require careful reasoning about time [@lamport1978time].
```

Distributed systems require careful reasoning about time [@lamport1978time].

A citation with a page number:

```markdown
The concept was first formalized in [@lamport1978time, p. 559].
```

The concept was first formalized in [@lamport1978time, p. 559].

An inline citation (author becomes part of the sentence):

```markdown
@knuth1984literate argues that programs should be written for humans first.
```

@knuth1984literate argues that programs should be written for humans first.

Multiple citations in one set of brackets:

```markdown
These ideas appear across the literature [@knuth1984literate; @lamport1978time].
```

These ideas appear across the literature [@knuth1984literate; @lamport1978time].

## The Bibliography Section

Pandoc appends a bibliography at the end of the last chapter automatically when `--citeproc` is active. No `\bibliography{}` command or special section is required.

To control where the bibliography appears, add a fenced div with the `refs` class at the desired location:

```markdown
## References

::: {#refs}
:::
```

Everything cited in the book appears here. Uncited entries in `references.bib` are not included.

## Citation Style

By default, Pandoc uses the Chicago author-date style. To use a different style, download a CSL file from `citationstyles.org` and reference it in `book.yaml`:

```yaml
csl: templates/ieee.csl
```

Popular choices for technical books:

| Style | File | Use case |
|---|---|---|
| Chicago author-date | *(default)* | General technical books |
| IEEE | `ieee.csl` | Engineering, computer science |
| APA | `apa.csl` | Social sciences |
| Nature | `nature.csl` | Natural sciences |

```{=latex}
\begin{tipbox}
The CSL repository at \texttt{github.com/citation-style-language/styles}
contains over 10,000 styles. Download the \texttt{.csl} file, place it in
\texttt{templates/}, and update the \texttt{csl} key in \texttt{book.yaml}.
\end{tipbox}
```

## Managing References with a Reference Manager

For books with many sources, a reference manager makes BibTeX maintenance much easier. Tools that export `.bib` files directly:

- **Zotero** (free) — the most popular choice; use Better BibTeX for clean keys
- **JabRef** (free) — native BibTeX editor, good for large collections
- **Papers** / **Mendeley** — commercial options with export support

Keep `references.bib` in version control. Reference managers can be configured to auto-export to a fixed path when the library changes.

## References

::: {#refs}
:::
