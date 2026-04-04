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
-- Optional caption and label via attributes:
--   ```{.mermaid caption="My Diagram" #fig:my-diagram}
--   ...
--   ```

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
    "fontFamily":        "Inter 18pt, Inter, sans-serif",
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

local diagram_count = 0

function CodeBlock(block)
  -- Accept both ```mermaid and ```{.mermaid ...}
  if not (block.classes[1] == "mermaid") then
    return nil
  end

  diagram_count = diagram_count + 1
  local img_path = render_mermaid(block.text, diagram_count)

  if not img_path then
    -- Fallback: render as a plain code block if mmdc fails
    block.classes[1] = "text"
    return block
  end

  -- Build image element
  local caption_text = block.attributes["caption"] or ""
  local label        = block.identifier or ""
  local caption      = pandoc.read(caption_text, "markdown").blocks
  local inlines      = #caption > 0 and caption[1].content or {}
  local img          = pandoc.Image(inlines, img_path, caption_text,
                                    {id = label})

  -- Wrap in a Para (inline context) or Figure (pandoc 3.x)
  if pandoc.types and pandoc.Figure then
    return pandoc.Figure(
      pandoc.Plain({img}),
      #inlines > 0 and pandoc.Caption(nil, caption) or pandoc.Caption(),
      {id = label}
    )
  else
    return pandoc.Para({img})
  end
end
