local env = select(2, ...)
local Path = env.modules:Import("packages\\path")
local UIKit = env.modules:Import("packages\\ui-kit")
local Utils_Texture = env.modules:Import("packages\\utils\\texture")
local StoryMode_Preload = env.modules:New("@\\Dialog\\Modes\\Story\\Preload")


StoryMode_Preload.Enum = {
    PlaybackState = {
        Dialogue = 1,
        Options  = 2,
        Quest    = 3
    }
}

local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\Dialog\\StoryMode\\StoryModeFrame" }
Utils_Texture.Preload(Path.Root .. "\\Art\\Dialog\\StoryMode\\StoryModeFrame")
StoryMode_Preload.UIDEF = {
    UIOptionsBoxShadow             = ATLAS{ inset = 47, scale = 5, left = 8 / 512, right = 104 / 512, top = 167 / 512, bottom = 263 / 512, sliceMode = Enum.UITextureSliceMode.Stretched },
    UIDialogBoxDivider             = ATLAS{ inset = 0, left = 7 / 512, right = 58 / 512, top = 7 / 512, bottom = 19 / 512, sliceMode = Enum.UITextureSliceMode.Stretched },
    UIDialogBoxDividerOrnament     = ATLAS{ left = 63 / 512, right = 75 / 512, top = 7 / 512, bottom = 19 / 512 },
    UIDialogBoxDividerSectionLeft  = ATLAS{ inset = { 0, 12, 0, 0 }, left = 80 / 512, right = 111 / 512, top = 7 / 512, bottom = 19 / 512 },
    UIDialogBoxDividerSectionRight = ATLAS{ inset = { 12, 0, 0, 0 }, left = 111 / 512, right = 142 / 512, top = 7 / 512, bottom = 19 / 512 },
    UIDialogBoxShadow              = ATLAS{ left = 7 / 512, right = 504 / 512, top = 26 / 512, bottom = 145 / 512 },
    UIArrow                        = ATLAS{ left = 6 / 512, right = 22 / 512, top = 146 / 512, bottom = 162 / 512 }
}
