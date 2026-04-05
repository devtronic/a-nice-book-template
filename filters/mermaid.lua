-- filters/mermaid.lua
-- Renders mermaid code blocks to PNG via mmdc and replaces them with images.
-- Requires: npm install -g @mermaid-js/mermaid-cli
--
-- Usage in Markdown:
--   ```mermaid
--   flowchart LR
--       A --> B --> C
--   ```
--
-- Optional attributes:
--   ```{.mermaid width=60% caption="My Diagram" #fig:my-diagram}
--   ...
--   ```
--   width   — display width passed to the image (e.g. 50%, 80%, 100%)
--             defaults to 100% if omitted
--   caption — figure caption (optional)
--   #id     — label for cross-referencing (optional)

local build_dir = "build/mermaid"
local mmdc      = "mmdc"

-- Mermaid config: white background, Inter font, matches book theme
local mmdc_config = [[{
  "theme": "base",
  "themeVariables": {
    "background":        "#ffffff",
    "primaryColor":      "#e8f0fe",
    "primaryBorderColor":"#6a9fb5",
    "primaryTextColor":  "#202020",
    "lineColor":         "#718096",
    "secondaryColor":    "#f5f5f5",
    "tertiaryColor":     "#f5f5f5",
    "fontFamily":        "trebuchet ms, verdana, arial, sans-serif",
    "fontSize":          "14px"
  }
}]]

local config_file = nil

local function ensure_build_dir()
  os.execute("mkdir -p " .. build_dir)
end

local function write_config()
  if config_file then return config_file end
  config_file = build_dir .. "/mmdc-config.json"
  local f = io.open(config_file, "w")
  if f then
    f:write(mmdc_config)
    f:close()
  end
  return config_file
end

local function render_mermaid(source, index)
  ensure_build_dir()
  local cfg      = write_config()
  local src_path = build_dir .. "/diagram-" .. index .. ".mmd"
  local out_path = build_dir .. "/diagram-" .. index .. ".png"

  -- Write mermaid source
  local f = io.open(src_path, "w")
  if not f then
    io.stderr:write("[mermaid] ERROR: cannot write to " .. src_path .. "\n")
    return nil
  end
  f:write(source)
  f:close()

  -- Render via mmdc (scale=2 for retina-quality in PDF)
  local cmd = string.format(
    "%s -i %s -o %s --configFile %s --scale 2 --quiet 2>/dev/null",
    mmdc, src_path, out_path, cfg
  )
  local ok = os.execute(cmd)
  if ok ~= 0 and ok ~= true then
    io.stderr:write("[mermaid] WARNING: mmdc failed for diagram " .. index
                    .. ". Check that mmdc is on PATH.\n")
    return nil
  end
  return out_path
end

-- Parse a Pandoc-style attribute string: {width=80% align=center caption="My Cap" #fig:id}
-- Returns: id, width, caption, align  (all strings or nil/empty)
local function parse_attr_comment(line)
  -- Strip leading "%%" and optional whitespace, then extract { ... }
  local inner = line:match("^%%%%%s*{(.-)}")
  if not inner then return nil, nil, nil, nil end

  local id      = inner:match("#([%w:%-]+)") or ""
  local width   = inner:match("width=([^%s\"'{}]+)")
  local align   = inner:match("align=([^%s\"'{}]+)")
  local caption = inner:match('caption="([^"]*)"')
                  or inner:match("caption='([^']*)'")
                  or inner:match("caption=([^%s\"'{}]+)")
  return id, width, caption, align
end

-- Wrap a Para block in an alignment environment.
-- For PDF/LaTeX: uses flushleft/flushright/center LaTeX environments.
-- For HTML/EPUB: wraps in a styled div.
local function align_block(para, align)
  align = align or "center"
  if FORMAT == "latex" or FORMAT == "pdf" then
    local env = ({left="flushleft", center="center", right="flushright"})[align]
                or "center"
    return {
      pandoc.RawBlock("latex", "\\begin{" .. env .. "}"),
      para,
      pandoc.RawBlock("latex", "\\end{" .. env .. "}"),
    }
  else
    local style = "text-align: " .. align
    return pandoc.Div({para}, pandoc.Attr("", {}, {style = style}))
  end
end

local diagram_count = 0

function CodeBlock(block)
  -- Accept both ```mermaid and ```{.mermaid ...}
  if not (block.classes[1] == "mermaid") then
    return nil
  end

  diagram_count = diagram_count + 1

  -- Check for %% {attrs} comment on first line (IDE-compatible syntax)
  local source      = block.text
  local first_line  = source:match("^([^\n]*)")
  local comment_id, comment_width, comment_caption, comment_align

  if first_line and first_line:match("^%%%%%s*{") then
    comment_id, comment_width, comment_caption, comment_align = parse_attr_comment(first_line)
    -- Strip the comment line before passing source to mmdc
    source = source:match("^[^\n]*\n?(.*)") or ""
  end

  local img_path = render_mermaid(source, diagram_count)

  if not img_path then
    -- Fallback: render as a plain code block if mmdc fails
    block.classes[1] = "text"
    return block
  end

  -- Attributes: %% comment takes priority, fall back to block attrs
  local caption_text = comment_caption or block.attributes["caption"] or ""
  local width        = comment_width   or block.attributes["width"]   or "100%"
  local align        = comment_align   or block.attributes["align"]   or "center"
  local label        = (comment_id ~= "" and comment_id) or block.identifier or ""

  local caption = pandoc.read(caption_text, "markdown").blocks
  local inlines = #caption > 0 and caption[1].content or {}

  local img_attrs = {id = label, width = width}
  local img       = pandoc.Image(inlines, img_path, caption_text, img_attrs)
  return align_block(pandoc.Para({img}), align)
end
