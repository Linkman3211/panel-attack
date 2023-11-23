local input = require("inputManager")
local sceneManager = require("scenes.sceneManager")
local tableUtils = require("tableUtils")

local function runSystemCommands()
  -- toggle debug mode
  if input.allKeys.isDown["d"] then
    config.debug_mode = not config.debug_mode
  -- reload characters
  elseif input.allKeys.isDown["c"] then
    characters_reload_graphics()
  -- reload panels
  elseif input.allKeys.isDown["p"] then
    panels_init()
  -- reload stages
  elseif input.allKeys.isDown["s"] then
    stages_reload_graphics()
  -- reload themes
  elseif input.allKeys.isDown["t"] then
    themes[config.theme]:json_init()
    themes[config.theme]:graphics_init()
    themes[config.theme]:final_init()
  end
end

local function takeScreenshot()
  local now = os.date("*t", to_UTC(os.time()))
  local filename = "screenshot_" .. "v" .. config.version .. "-" .. string.format("%04d-%02d-%02d-%02d-%02d-%02d", now.year, now.month, now.day, now.hour, now.min, now.sec) .. ".png"
  love.filesystem.createDirectory("screenshots")
  love.graphics.captureScreenshot("screenshots/" .. filename)
  return true
end

local function refreshDesignHelper()
  if sceneManager.activeScene.name == "DesignHelper" then
    package.loaded["scenes.DesignHelper"] = nil
    sceneManager.activeScene = require("scenes.DesignHelper")
    sceneManager.activeScene:load()
  end
end

local function handleCopy()
  local stacks = {}
  if GAME.match.P1 then
    stacks["P1"] = GAME.match.P1:toPuzzleInfo()
  end
  if GAME.match.P2 then
    stacks["P2"] = GAME.match.P2:toPuzzleInfo()
  end
  if tableUtils.length(stacks) > 0 then
    love.system.setClipboardText(json.encode(stacks))
    return true
  end
end

local function handleDumpAttackPattern(playerNumber)
  local stack = GAME.match.players[playerNumber]

  if stack then
    local data, state = stack:getAttackPatternData()
    saveJSONToPath(data, state, "dumpAttackPattern.json")
    return true
  end
end

local function modifyWinCounts(functionIndex)
  if GAME.battleRoom then
    if functionIndex == 1 then -- Add to P1's win count
      GAME.battleRoom.modifiedWinCounts[1] = math.max(0, GAME.battleRoom.modifiedWinCounts[1] + 1)
    end
    if functionIndex == 2 then -- Subtract from P1's win count
      GAME.battleRoom.modifiedWinCounts[1] = math.max(0, GAME.battleRoom.modifiedWinCounts[1] - 1)
    end
    if functionIndex == 3 then -- Add to P2's win count
      GAME.battleRoom.modifiedWinCounts[2] = math.max(0, GAME.battleRoom.modifiedWinCounts[2] + 1)
    end
    if functionIndex == 4 then -- Subtract from P2's win count
      GAME.battleRoom.modifiedWinCounts[2] = math.max(0, GAME.battleRoom.modifiedWinCounts[2] - 1)
    end
    if functionIndex == 5 then -- Reset key
      GAME.battleRoom.modifiedWinCounts[1] = 0
      GAME.battleRoom.modifiedWinCounts[2] = 0
    end
  end
end

function handleShortcuts()
  if input.allKeys.isDown["f2"] or input.allKeys.isDown["printscreen"] then
    takeScreenshot()
  end

  if DEBUG_ENABLED and input.allKeys.isDown["f5"] then
    refreshDesignHelper()
  end

  if input.isPressed["SystemKey"] then
    runSystemCommands()
  elseif input.isPressed["Ctrl"] then
    if input.allKeys.isDown["c"] then
      handleCopy()
    elseif input.allKeys.isDown["1"] then
      handleDumpAttackPattern(1)
    elseif input.allKeys.isDown["2"] then
      handleDumpAttackPattern(2)
    end
  elseif input.isPressed["Alt"] then
    if input.isDown["return"] then
      love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
    elseif input.allKeys.isDown["1"] then
      modifyWinCounts(1)
    elseif input.allKeys.isDown["2"] then
      modifyWinCounts(2)
    elseif input.allKeys.isDown["3"] then
      modifyWinCounts(3)
    elseif input.allKeys.isDown["4"] then
      modifyWinCounts(4)
    elseif input.allKeys.isDown["5"] then
      modifyWinCounts(5)
    end
  end
end

return handleShortcuts