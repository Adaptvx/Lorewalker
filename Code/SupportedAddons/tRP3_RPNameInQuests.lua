local env = select(2, ...)
local SupportedAddons = env.modules:Import("@\\SupportedAddons")
local ControlCenter_Formatting = env.modules:Import("@\\Dialog\\ControlCenter\\Formatting")

local function RenameText(text)
    if not text or not TRP3_API or not TRP3_API.module.isModuleLoaded("trp3_rpnameinquests") then return text end

    local api = TRP3RPNameInQuests.API
    if not api:IsTextModifierEnabled("questdialog") then return text end

    return api:CompleteRename(text)
end

local function OnAddonLoad()
    ControlCenter_Formatting.AddTextModifier(RenameText)
end

SupportedAddons.Add("tRP3_RPNameInQuests", OnAddonLoad)
