-- filters/tables.lua
-- Adds header-row and alternating-row background colors to pandoc tables
-- for PDF output using \cellcolor (per-cell) instead of \rowcolor
-- to avoid "Misplaced \noalign" errors in longtable environments.
-- No-op for non-LaTeX formats.

if FORMAT ~= "latex" and FORMAT ~= "pdf" then
  return {}
end

-- Prepend a \cellcolor command to the content of a cell.
local function colorize_cell(cell, color_name)
  local raw = pandoc.RawInline("latex",
    "\\cellcolor{" .. color_name .. "}")
  if #cell.contents > 0 and cell.contents[1].content then
    table.insert(cell.contents[1].content, 1, raw)
  else
    cell.contents = {pandoc.Plain({raw})}
  end
  return cell
end

-- Wrap cell content in \thead{} for bold + sans-serif header styling.
local function apply_thead(cell)
  if #cell.contents > 0 and cell.contents[1].content then
    local inlines = cell.contents[1].content
    table.insert(inlines, 1, pandoc.RawInline("latex", "\\thead{"))
    table.insert(inlines,    pandoc.RawInline("latex", "}"))
  end
  return cell
end

function Table(tbl)
  -- ── Header rows ───────────────────────────────────────────────
  for i, row in ipairs(tbl.head.rows) do
    for j, cell in ipairs(row.cells) do
      -- 1. Apply \thead{} to style the text
      cell = apply_thead(cell)
      -- 2. Apply \cellcolor (safe inside any table environment)
      cell = colorize_cell(cell, "tableheadbg")
      row.cells[j] = cell
    end
    tbl.head.rows[i] = row
  end

  -- ── Body rows: alternating tint on even rows ───────────────────
  for _, body in ipairs(tbl.bodies) do
    for i, row in ipairs(body.body) do
      if i % 2 == 0 then
        for j, cell in ipairs(row.cells) do
          row.cells[j] = colorize_cell(cell, "tablerowalt")
        end
        body.body[i] = row
      end
    end
  end

  return tbl
end
