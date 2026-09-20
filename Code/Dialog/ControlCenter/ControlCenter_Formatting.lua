local env = select(2, ...)
local L = env.L
local ControlCenter_Preload = env.modules:Import("@\\Dialog\\ControlCenter\\Preload")
local ControlCenter_Formatting = env.modules:New("@\\Dialog\\ControlCenter\\Formatting")

local format, gsub, find = string.format, string.gsub, string.find
local band = bit.band

local TRIVIAL_QUEST_DISPLAY_UNCOLORED = gsub(gsub(TRIVIAL_QUEST_DISPLAY, "|c%x%x%x%x%x%x%x%x", ""), "|r", "")
local PLAY_MOVIE_LABEL_PREPEND = Enum.GossipOptionRecFlags and Enum.GossipOptionRecFlags.PlayMovieLabelPrepend
local COLOR_MAP = {
    default = {
        ["|cFFFF0000"]        = "|cFFB20300",
        ["|cnRED_FONT_COLOR"] = "|cFFB20300",
        ["|cFF00BFF3"]        = "|cFF002AC1"
    },
    alternate = {
        ["|cFFFF0000"]        = "|cFFE07878",
        ["|cnRED_FONT_COLOR"] = "|cFFE07878",
        ["|cFF00BFF3"]        = "|cFF6EBAD6"
    }
}

local function ApplyColorReplacements(text, colorMap)
    for alertColor, replaceColor in pairs(colorMap) do
        text = gsub(text, alertColor, replaceColor)
    end
    return text
end

function ControlCenter_Formatting.GetOptionAlertTypeFromText(text)
    if find(text, "|cFFFF0000") or find(text, "|cnRED_FONT_COLOR") then
        return ControlCenter_Preload.Enum.OptionAlertType.Red
    elseif find(text, "|cFF00BFF3") then
        return ControlCenter_Preload.Enum.OptionAlertType.Blue
    end

    return nil
end

function ControlCenter_Formatting.FormatOption(text, flag, alternate)
    local colorMap = alternate and COLOR_MAP.alternate or COLOR_MAP.default
    text = ApplyColorReplacements(text, colorMap)

    if PLAY_MOVIE_PREPEND and PLAY_MOVIE_LABEL_PREPEND and band(flag or 0, PLAY_MOVIE_LABEL_PREPEND) == PLAY_MOVIE_LABEL_PREPEND then
        text = colorMap["|cFF00BFF3"] .. PLAY_MOVIE_PREPEND .. "|r " .. text
    end

    return text
end

function ControlCenter_Formatting.FormatQuestOption(text, isTrivial)
    return isTrivial and format(TRIVIAL_QUEST_DISPLAY_UNCOLORED, text) or text
end
