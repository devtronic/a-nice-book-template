-- filters/preamble.lua
-- Appends preamble.tex to header-includes AFTER the YAML metadata entries,
-- so user-defined \newcommand overrides in book.yaml always run first and
-- \providecommand fallbacks in preamble.tex are no-ops for anything already set.

local PREAMBLE = "templates/latex/preamble.tex"

function Meta(meta)
  if FORMAT ~= "latex" and FORMAT ~= "pdf" then
    return nil
  end

  local f = io.open(PREAMBLE, "r")
  if not f then
    io.stderr:write("[preamble] WARNING: cannot open " .. PREAMBLE .. "\n")
    return nil
  end
  local content = f:read("*a")
  f:close()

  -- Ensure header-includes is a list, then append the preamble block
  if type(meta["header-includes"]) ~= "table" then
    meta["header-includes"] = pandoc.MetaList({})
  end
  table.insert(meta["header-includes"],
    pandoc.MetaBlocks({pandoc.RawBlock("latex", content)}))

  return meta
end
