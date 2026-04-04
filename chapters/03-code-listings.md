# Code Listings {#sec:code-listings}

Code is a first-class citizen in this template. Fenced code blocks receive syntax highlighting from the Base16 Light theme, automatic line numbers, and soft-wrap for long lines.

## Fenced Code Blocks

A fenced code block starts and ends with three backticks. Add a language identifier immediately after the opening fence:

````markdown
```python
def fibonacci(n: int) -> int:
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)
```
````

This produces a highlighted, numbered listing:

```python
def fibonacci(n: int) -> int:
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

print([fibonacci(i) for i in range(10)])
# [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

## Supported Languages

The template uses Pandoc's built-in KDE syntax highlighter, which covers over 140 languages. Common ones for technical books:

| Language Tag | Use for |
|---|---|
| `python` | Python 3 |
| `javascript` / `typescript` | JS / TS |
| `rust` | Rust |
| `go` | Go |
| `java` | Java / Kotlin |
| `bash` / `console` | Shell commands |
| `sql` | SQL queries |
| `yaml` / `json` | Configuration |
| `dockerfile` | Docker |
| `markdown` | Markdown source |

Use `text` or omit the language tag for plain monospace without highlighting.

## The Base16 Light Palette

The color assignments follow the Base16 Light theme:

| Token type | Color | Example |
|---|---|---|
| Keyword | `#ac4142` | `def`, `return`, `if` |
| String | `#f4bf75` | `"hello world"` |
| Comment | `#8f5536` | `# this is a comment` |
| Number | `#aa759f` | `42`, `3.14` |
| Type / built-in | `#6a9fb5` | `int`, `str`, `None` |
| Function name | `#d28445` | function definitions |
| Variable | `#90a959` | variable names |

## Line Numbers and Soft Wrap

Line numbers are added automatically to every code block — no per-block annotation is needed. The numbers appear in muted gray on the left.

Long lines soft-wrap at whitespace with a `↩` continuation indicator. This means your code is never clipped at the page margin:

```python
# This is a deliberately long line to demonstrate soft-wrapping behavior in the PDF output
result = some_very_long_function_name(first_argument, second_argument, third_argument, fourth_argument)
```

## Multiple Languages in One Chapter

Technical chapters often show the same concept in several languages. Each block is independently highlighted:

```go
func fibonacci(n int) int {
    if n <= 1 {
        return n
    }
    return fibonacci(n-1) + fibonacci(n-2)
}
```

```rust
fn fibonacci(n: u64) -> u64 {
    match n {
        0 | 1 => n,
        _ => fibonacci(n - 1) + fibonacci(n - 2),
    }
}
```

```typescript
function fibonacci(n: number): number {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}
```

## Shell Sessions

Use the `bash` or `console` language tag for terminal sessions. Start interactive lines with `$` to distinguish commands from output:

```bash
$ git clone https://github.com/you/your-book.git
$ cd your-book
$ make install-deps
...
$ make pdf
build/book.pdf
```

```{=latex}
\begin{tipbox}
There is no special "output" language tag. The \texttt{\$} prefix is a
convention, not syntax. Pandoc highlights the entire block as bash, so
the prompt and the output text receive the same treatment.
\end{tipbox}
```

## Inline Code

Use single backticks for inline code: a `Config` struct, the `--output` flag, a path like `build/book.pdf`. Inline code is rendered in Fira Code at 85% of the body size.

## External Code Files

For long, complete programs, keep the source in `code/` and reference it from the chapter. This keeps your Markdown readable and lets readers copy the file directly.

In the chapter, show the relevant excerpt inline and add a note pointing to the full listing:

```python
# Excerpt — see code/fibonacci_server.py for the complete implementation
@app.route("/fib/<int:n>")
def fib_endpoint(n: int):
    return {"result": fibonacci(n)}
```

For PDF output you can include an external file verbatim using a raw LaTeX block:

```{=latex}
% \lstinputlisting[language=Python, caption={Complete server implementation},
%   label={lst:fib-server}]{code/fibonacci_server.py}
```

```{=latex}
\begin{warningbox}
\texttt{\textbackslash lstinputlisting} requires the \texttt{listings}
package, which conflicts with Pandoc's native highlighter. To include
external files verbatim, use a fenced block and paste the relevant
excerpt, or use \texttt{pandoc --extract-media} to manage assets.
\end{warningbox}
```

## Disabling Line Numbers for a Block

If you want a code block without line numbers — for example, a short two-line snippet where numbering adds clutter — wrap it in raw LaTeX to use a plain `Verbatim` environment directly:

```{=latex}
\begin{Verbatim}
$ make pdf
\end{Verbatim}
```
