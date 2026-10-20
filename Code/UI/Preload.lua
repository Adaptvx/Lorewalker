local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIKit = env.modules:Import("packages\\ui-kit")
local Utils_Texture = env.modules:Import("packages\\utils\\texture")
local UI_Preload = env.modules:New("@\\UI\\Preload")


Utils_Texture.Preload(Path.Root .. "\\Art\\UI\\ExperienceBar")
local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\UI\\ExperienceBar" }
UI_Preload.UIDEF = {
    UIExperienceBarFrame = ATLAS{ inset = 10, left = 5 / 64, right = 59 / 64, top = 5 / 64, bottom = 33 / 64 },
    UIExperienceBarFill  = ATLAS{ inset = 10, left = 3 / 64, right = 53 / 64, top = 33 / 64, bottom = 57 / 64 }
}
