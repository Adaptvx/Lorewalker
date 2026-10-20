local env = select(2, ...)
local L = env.L
local Config = env.Config
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local GenericEnum = env.modules:Import("packages\\generic-enum")
local UIAnim = env.modules:Import("packages\\ui-anim")
local HideUI = env.modules:Import("@\\HideUI")

local Mixin = Mixin
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local UnitLevel = UnitLevel
local GetRestState = GetRestState
local IsResting = IsResting
local BreakUpLargeNumbers = BreakUpLargeNumbers
local SecondsToTime = SecondsToTime
local GetMaxPlayerLevel = GameRulesUtil and GameRulesUtil.GetEffectiveMaxLevelForPlayer or GetMaxPlayerLevel
local time = time
local format = string.format
local ceil = math.ceil
local min = math.min
local max = math.max


local ExperienceBarMixin = {}

function ExperienceBarMixin:OnLoad()
    self.value = 0
    self.statistics = Config.DBLocal:GetVariable("experienceBarSession")
    if not self.statistics then self:ResetStatistics() end

    self:HookScript("OnSizeChanged", function() self:SetValue(self.value) end)
    self:HookScript("OnHide", self.OnHide)
    self:HookScript("OnEnter", self.OnEnter)
    self:HookScript("OnLeave", self.OnLeave)
    LWParent:HookScript("OnSizeChanged", function() self:_Render() end)
    self:SetScript("OnEvent", self.OnEvent)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_XP_UPDATE")
    self:RegisterEvent("PLAYER_LEVEL_UP")

    CallbackRegistry.Add("HideUI.VisibilityChanged", function() self:Update() end)
    CallbackRegistry.Add("WoWClient.OnUIScaleChanged", function() self:_Render() end)

    self:Update(true)
end

function ExperienceBarMixin:OnEvent(event, ...)
    local newLevel = nil
    if event == "PLAYER_XP_UPDATE" then
        local unit = ...
        if unit ~= "player" then return end
        self:UpdateStatistics()
    elseif event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin = ...
        if isInitialLogin then
            self:ResetStatistics()
        else
            self:UpdateStatistics()
        end
    elseif event == "PLAYER_LEVEL_UP" then
        newLevel = ...
    end

    self:Update(event == "PLAYER_ENTERING_WORLD", newLevel)
    self:UpdateTooltip()
end

function ExperienceBarMixin:OnHide()
    self:StopAnimation()
    self.AnimGroup:Stop(self)
    self:OnLeave()
end

function ExperienceBarMixin:OnEnter()
    self:OnLeave()
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
    self:UpdateTooltip()

    self.tooltipTicker = C_Timer.NewTicker(0.5, function()
        if not self:IsVisible() or not GameTooltip:IsShown() or not GameTooltip:IsOwned(self) then
            self:OnLeave()
            return
        end
        self:UpdateTooltip()
    end)
end

function ExperienceBarMixin:OnLeave()
    if self.tooltipTicker then
        self.tooltipTicker:Cancel()
        self.tooltipTicker = nil
    end
    if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
end

function ExperienceBarMixin:ResetStatistics()
    self.statistics = {
        startTime = time(),
        gainedXP = 0,
        lastXP = UnitXP("player"),
        lastMaxXP = UnitXPMax("player")
    }
    Config.DBLocal:SetVariable("experienceBarSession", self.statistics)
end

function ExperienceBarMixin:UpdateStatistics()
    local statistics = self.statistics
    local xp = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local gainedXP = xp - statistics.lastXP

    if gainedXP < 0 or maxXP ~= statistics.lastMaxXP then
        gainedXP = statistics.lastMaxXP - statistics.lastXP + xp
    end

    statistics.gainedXP = statistics.gainedXP + max(gainedXP, 0)
    statistics.lastXP = xp
    statistics.lastMaxXP = maxXP
end

function ExperienceBarMixin:UpdateTooltip()
    if not self:IsVisible() or not GameTooltip:IsOwned(self) then return end

    local level = UnitLevel("player")
    local maxLevel = GetMaxPlayerLevel()
    local xp = UnitXP("player")
    local maxXP = UnitXPMax("player")
    if maxXP <= 0 then return end

    GameTooltip:ClearLines()
    GameTooltip:AddLine(format("%s: %s / %s", LEVEL, level, maxLevel), GenericEnum.ColorRGB01.NORMAL_FONT_COLOR.r, GenericEnum.ColorRGB01.NORMAL_FONT_COLOR.g, GenericEnum.ColorRGB01.NORMAL_FONT_COLOR.b)
    GameTooltip:AddLine(format("%s / %s" .. GenericEnum.ColorHEX.GRAY_FONT_COLOR .. " (%0.1f%%)|r", BreakUpLargeNumbers(xp), BreakUpLargeNumbers(maxXP), xp / maxXP * 100), GenericEnum.ColorRGB01.WHITE_FONT_COLOR.r, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.g, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.b)

    local elapsed = time() - self.statistics.startTime
    local xpPerHour = elapsed > 0 and ceil(self.statistics.gainedXP / elapsed * 3600) or 0
    local timeUntilLevel = xpPerHour > 0 and SecondsToTime(ceil((maxXP - xp) / xpPerHour * 3600)) or "N/A"
    local timeUntilLevelFormat = maxLevel - level == 1 and L["TOOLTIP_EXPERIENCE_BAR_UNTIL_MAX_LEVEL"] or L["TOOLTIP_EXPERIENCE_BAR_UNTIL_NEXT_LEVEL"]

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["TOOLTIP_EXPERIENCE_BAR_STATISTICS"])
    GameTooltip:AddLine(format(L["TOOLTIP_EXPERIENCE_BAR_EXPERIENCE_PER_HOUR"], xpPerHour > 0 and BreakUpLargeNumbers(xpPerHour) or "N/A"), GenericEnum.ColorRGB01.WHITE_FONT_COLOR.r, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.g, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.b)
    GameTooltip:AddLine(format(timeUntilLevelFormat, timeUntilLevel), GenericEnum.ColorRGB01.WHITE_FONT_COLOR.r, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.g, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.b)

    local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState()
    if exhaustionStateName and exhaustionStateMultiplier then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(format(EXHAUST_TOOLTIP1, exhaustionStateName, exhaustionStateMultiplier * 100))

        if not IsResting() and (exhaustionStateID == 4 or exhaustionStateID == 5) then
            GameTooltip:AddLine(EXHAUST_TOOLTIP2, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.r, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.g, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.b)
        end
    end

    if GameLimitedMode_IsBankedXPActive and GameLimitedMode_IsBankedXPActive() then
        local bankedLevels = UnitTrialBankedLevels("player")
        local bankedXP = UnitTrialXP("player")

        if bankedLevels > 0 or bankedXP > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(XP_TEXT_BANKED_XP_HEADER, GenericEnum.ColorRGB01.NORMAL_FONT_COLOR.r, GenericEnum.ColorRGB01.NORMAL_FONT_COLOR.g, GenericEnum.ColorRGB01.NORMAL_FONT_COLOR.b)
        end

        if bankedLevels > 0 then
            GameTooltip:AddLine(format(TRIAL_CAP_BANKED_LEVELS_TOOLTIP, bankedLevels), GenericEnum.ColorRGB01.WHITE_FONT_COLOR.r, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.g, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.b)
        elseif bankedXP > 0 then
            GameTooltip:AddLine(TRIAL_CAP_BANKED_XP_TOOLTIP, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.r, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.g, GenericEnum.ColorRGB01.WHITE_FONT_COLOR.b)
        end
    end

    GameTooltip:Show()
end

function ExperienceBarMixin:StopAnimation()
    if not self.valueAnimation then return end
    self.valueAnimation:Stop()
    self.valueAnimation = nil
end

function ExperienceBarMixin:SetValue(value)
    self.value = value
    local progress = value % 1
    self.Fill:size(self:GetWidth() * progress, self:GetHeight())
    self.Fill:SetShown(progress > 0)
end

function ExperienceBarMixin:Update(instant, newLevel)
    local level = UnitLevel("player")
    local maxXP = UnitXPMax("player")
    local shouldShow = HideUI.isHidden and (newLevel or level) < GetMaxPlayerLevel() and maxXP > 0

    local progress = maxXP > 0 and min(max(UnitXP("player") / maxXP, 0), 1) or 0
    local value = level + progress

    if instant then
        self:StopAnimation()
        self:SetValue(value)
        self.targetValue = value
    end

    if not shouldShow then
        self:Hide()
        return
    end

    if not self:IsShown() then
        self:SetAlpha(0)
        self:Show()
        self.AnimGroup:Play(self, "FADE_IN")
    end

    if value ~= self.targetValue or (not self.valueAnimation and self.value ~= value) then
        self:StopAnimation()
        self.targetValue = value
        self.valueAnimation = UIAnim.AnimateNumber(self.value, value, 0.3, UIAnim.Enum.Easing.SineOut, function(animatedValue)
            self:SetValue(animatedValue)
        end, function()
            self.valueAnimation = nil
        end)
    end
end

ExperienceBarMixin.AnimGroup = UIAnim.New()
do
    local FadeIn = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(HideUI.FadeDuration):from(0):to(1)
    ExperienceBarMixin.AnimGroup:State("FADE_IN", function(frame)
        FadeIn:Play(frame)
    end)
end


Mixin(LWUIExperienceBar, ExperienceBarMixin)
CallbackRegistry.Add("Preload.AddonReady", function() LWUIExperienceBar:OnLoad() end)
