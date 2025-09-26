-- Head render stuff. You can place this file in your mod to use the head render function (please give credit!).
-- Comes with an API for Character Select (see bottom for info).

local WING_HUD = get_texture_info("hud_wing")

local FEATURE = -1
local NONE = -2

-- Info for the default characters.
local defaultColorData = {
  [CT_MARIO] = {
    tex = get_texture_info("mario_head_recolor"),
    order = { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE },
    order_capless = { SKIN, HAIR, NONE, FEATURE, NONE, HAIR },
    metal_sheet_x = 5,         --\ Moves where the metal parts are reserved for legacy purposes
    metal_capless_sheet_x = 7, --/
  },
  [CT_LUIGI] = {
    tex = get_texture_info("luigi_head_recolor"),
    order = { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE },
    order_capless = { SKIN, HAIR, NONE, FEATURE, NONE, HAIR },
    metal_sheet_x = 5,
    metal_capless_sheet_x = 7,
  },
  [CT_TOAD] = {
    tex = get_texture_info("toad_head_recolor"),
    order = { SKIN, GLOVES, CAP, FEATURE, NONE, NONE },
    order_capless = { SKIN, NONE, NONE, FEATURE, NONE, HAIR },
    metal_sheet_x = 5,
    metal_capless_sheet_x = 7,
  },
  [CT_WALUIGI] = {
    tex = get_texture_info("waluigi_head_recolor"),
    order = { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE },
    order_capless = { SKIN, HAIR, NONE, FEATURE, NONE, HAIR },
    metal_sheet_x = 5,
    metal_capless_sheet_x = 7,
  },
  [CT_WARIO] = {
    tex = get_texture_info("wario_head_recolor"),
    order = { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE },
    order_capless = { SKIN, HAIR, NONE, FEATURE, NONE, HAIR },
    metal_sheet_x = 5,
    metal_capless_sheet_x = 7,
  },
}

if not csColorData then
  _G.csColorData = {
    ["Toadette"] = {
      tex = get_texture_info("toadette_head_recolor"),
      order = { SKIN, CAP, GLOVES, FEATURE, NONE, NONE },
      order_capless = { SKIN, NONE, NONE, FEATURE, NONE, HAIR },
      metal_sheet_x = 5,
      metal_capless_sheet_x = 7,
    },
    ["Peach"] = {
      tex = get_texture_info("peach_head_recolor"),
      order = { SKIN, HAIR, CAP, FEATURE, SHOES, FEATURE },
      order_capless = { SKIN, HAIR, NONE, FEATURE, SHOES, NONE },
      metal_sheet_x = 5,
      metal_capless_sheet_x = 7,
    },
    ["Daisy"] = {
      tex = get_texture_info("daisy_head_recolor"),
      order = { SKIN, GLOVES, CAP, FEATURE, FEATURE, SHOES, HAIR },
      order_capless = { SKIN, GLOVES, NONE, FEATURE, NONE, SHOES, HAIR },
    },
  }
end

-- The actual head render function.
-- Set noSpecial to "true" to ignore cap state, or set alwaysCap to "true" to ignore specially the capless state (and not wing cap, for example).
-- Alpha will always be 255 (fully opaque) unless alpha_ is set to another value.
-- Note that the vanish cap will subtract 155 from whatever the alpha is set to (minimum of 0, causing it to not render).
--- @param index integer
--- @param x integer
--- @param y integer
--- @param scaleX number
--- @param scaleY number
--- @param noSpecial boolean
--- @param alwaysCap boolean
--- @param alpha_ integer
function render_player_head(index, x, y, scaleX, scaleY, noSpecial, alwaysCap, alpha_)
  local m = gMarioStates[index]
  local np = gNetworkPlayers[index]

  local alpha = alpha_ or 255
  if (not noSpecial) and (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0 and (index == 0 or np.fadeOpacity >= 32) then
    alpha = math.max(alpha - 155, 0)     -- vanish effect
  end

  local thisIconColorData = defaultColorData[m.character.type]
  local noColorHead = false
  if not thisIconColorData then
    noColorHead = true
    djui_hud_set_color(255, 255, 255, alpha)
    djui_hud_render_texture(m.character.hudHeadTexture, x, y, scaleX, scaleY)
  elseif charSelectExists then
    local charNum = charSelect.character_get_current_number(index)
    local costume = charSelect.character_get_current_costume(index)
    thisIconColorData = csColorData[charNum]
    if thisIconColorData then
      if thisIconColorData[1] then
        thisIconColorData = thisIconColorData[costume] or thisIconColorData[1]
      end
    else
      local charTable = charSelect.character_get_full_table()[charNum]
      thisIconColorData = charTable and csColorData[charTable.saveName]
    end

    if not thisIconColorData then
      local tex = charSelect.character_get_life_icon(index) or "?"
      local isVanilla = true
      if charSelect.character_is_vanilla then
        isVanilla = charSelect.character_is_vanilla(charNum) and (costume == 1)
      else
        isVanilla = (charNum == 1) and (costume == 1)
      end

      if (not isVanilla) then
        if type(tex) == "string" then
          djui_hud_set_font(FONT_RECOLOR_HUD)
          local charTable = charSelect.character_get_current_table(nil, costume)
          local color = { r = 255, g = 255, b = 255 }
          if charTable then
            color = charTable.color or color
          end
          djui_hud_set_color(color.r, color.g, color.b, alpha)
          djui_hud_print_text(tex, x, y, scaleX)
        else
          djui_hud_set_color(255, 255, 255, alpha)
          djui_hud_render_texture(tex, x, y, scaleX / (tex.width * 0.0625),
            scaleY / (tex.width * 0.0625))
        end
        noColorHead = true
      else
        thisIconColorData = defaultColorData[m.character.type]
      end
    end
  end

  local isMetal = false
  local capless = false

  if not noColorHead then
    local tex = thisIconColorData.tex
    local headWidth = thisIconColorData.headWidth or 16
    local headHeight = thisIconColorData.headHeight or 16
    local totalX = tex.width // headWidth - 1
    local order = thisIconColorData.order or { SKIN, HAIR, CAP, FEATURE, FEATURE, NONE }
    if (not (noSpecial or alwaysCap)) and m.marioBodyState.capState == MARIO_HAS_DEFAULT_CAP_OFF and thisIconColorData.order_capless then
      capless = true
      order = thisIconColorData.order_capless
    end

    if (not noSpecial) and (m.marioBodyState.modelState & MODEL_STATE_METAL) ~= 0 then -- metal
      local color = network_player_get_override_palette_color(np, METAL)
      djui_hud_set_color(color.r, color.g, color.b, alpha)
      isMetal = true

      local sheetX = thisIconColorData.metal_sheet_x or #order
      if capless then
        sheetX = thisIconColorData.metal_capless_sheet_x or (#order + 1)
      end
      djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, sheetX * headWidth, 0, headWidth, headHeight)
    else
      local orderX = 0
      local sheetX = 0
      while sheetX < totalX do
        local metalSheetX = thisIconColorData.metal_sheet_x or #order
        local metalCaplessSheetX = thisIconColorData.metal_capless_sheet_x or (#order + 1)
        if sheetX ~= metalSheetX and sheetX ~= metalCaplessSheetX then
          orderX = orderX + 1
          local color = { r = 255, g = 255, b = 255 }
          local part = order[orderX]
          if part == nil then break end
          if part ~= NONE then
            if part ~= FEATURE then
              color = network_player_get_override_palette_color(np, part)
            end
            djui_hud_set_color(color.r, color.g, color.b, alpha)
            djui_hud_render_texture_tile(tex, x, y, scaleX, scaleY, sheetX * headWidth, 0, headWidth, headHeight)
          end
        end
        sheetX = sheetX + 1
      end
    end
  end

  if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
    djui_hud_set_color(255, 255, 255, alpha)
    if (not noColorHead) and isMetal then
      djui_hud_set_color(109, 170, 173, alpha)              -- blueish green
    end
    djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY) -- wing
  end

  -- MarioHunt's only addition- render the player's crown
  local ctex = get_crown_tex(index)
  if ctex then
    djui_hud_set_color(255, 255, 255, alpha)
    djui_hud_render_texture(ctex, x, y - 12 * scaleY, scaleX, scaleY)
  end
end

-- Adds a head for a CS character!
---@param char integer|string Character number or saveName. Number is recommended.
---@param costume integer? Costume to apply this icon to. Set to 'nil' to apply to all costumes.
---@param tex TextureInfo Texture of the recolorable icon- use get_texture_info
---@param order table Order of palette colors for each layer, from left to right. FEATURE doesn't recolor and NONE doesn't render. Last two layers are reserved for METAL and METAL CAPLESS forms and will always use the METAL color.
---@param order_capless table? Like order, but only for capless form. Optional.
---@param headWidth integer? Width of the icon (defaults to 16)
---@param headHeight integer? Height of the icon (defaults to 16)
---@param extra table? Table of extra information; you probably won't need this
function add_head_for_cs(char, costume, tex, order, order_capless, headWidth, headHeight, extra)
  -- if already defined without a costume, move the already defined one to use the costume system
  if csColorData[char] and csColorData[char].tex and costume then
    print("Moving already defined head to default costume")
    local costumeTable = csColorData[char]
    csColorData[char] = {}
    csColorData[char][1] = costumeTable
  end

  local useTable = csColorData[char]
  if not useTable then
    csColorData[char] = {}
    useTable = csColorData[char]
  end
  if costume then
    csColorData[char][1] = {}
    useTable = csColorData[char][1]
  end

  if useTable then
    print("Overwriting head for " .. tostring(char) .. ":" .. tostring(costume or "Any"))
  else
    print("Creating head for " .. tostring(char) .. ":" .. tostring(costume or "Any"))
  end

  useTable.tex = tex
  useTable.order = order
  useTable.order_capless = order_capless
  useTable.headWidth = headWidth
  useTable.headHeight = headHeight
  if extra then
    for i, v in pairs(extra) do
      useTable[i] = v
    end
  end
end

-- Base mod won't override other mods that implement this file.
if origHudMod then return end
_G.dynamicHudExists = true
_G.dynamicHudIsOriginal =
    origHudMod -- TRUE if we're using the original mod, and FALSE if we're using another mod that just implements this.
_G.dynamicHudAPI = {
  render_player_head = render_player_head,
  add_head_for_cs = add_head_for_cs,
  FEATURE = FEATURE,
  NONE = NONE,
}
