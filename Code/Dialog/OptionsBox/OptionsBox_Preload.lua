local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIKit = env.modules:Import("packages\\ui-kit")
local Utils_Texture = env.modules:Import("packages\\utils\\texture")
local OptionsBox_Preload = env.modules:New("@\\Dialog\\OptionsBox\\Preload")

local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\Dialog\\StoryMode\\StoryModeFrame" }
Utils_Texture.Preload(Path.Root .. "\\Art\\Dialog\\StoryMode\\StoryModeFrame")
OptionsBox_Preload.UIDEF = {
    UIOptionsBoxShadow = ATLAS{ inset = 47, scale = 5, left = 8 / 512, right = 104 / 512, top = 167 / 512, bottom = 263 / 512, sliceMode = Enum.UITextureSliceMode.Stretched }
}
