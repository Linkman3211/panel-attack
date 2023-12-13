local sceneManager = require("scenes.sceneManager")

--function warpConfigMenu()
  --sceneManager:switchToScene("InputConfigMenu")
--end
--
local joystickDetection = {}

function joystickDetection.warpConfigMenu()
  sceneManager:switchToScene("InputConfigMenu")
end

return joystickDetection