local env = select(2, ...)
local Config = env.Config
local L = env.L
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local SavedVariables = env.modules:Import("packages\\saved-variables")
local UIAnim = env.modules:Import("packages\\ui-anim")
local ControlCenter = env.modules:Import("@\\Dialog\\ControlCenter")
local ControlCenter_ContextIcon = env.modules:Import("@\\Dialog\\ControlCenter\\ContextIcon")
local DialogFrame = env.modules:Import("@\\Dialog\\DialogFrame")
local SharedUtil = env.modules:Import("@\\Dialog\\SharedUtil")
local OptionsBox = env.modules:New("@\\Dialog\\OptionsBox")

local Mixin = Mixin
local ipairs = ipairs
local wipe = wipe
local max = math.max
local min = math.min

OptionsBox.Enum = {
    OptionType = {
        Goodbye = "Goodbye"
    }
}

local GOODBYE_OPTION = {
    name = L["GOODBYE"],
    contextIcon = ControlCenter_ContextIcon.TexDef.GossipExit.path,
    optionType = OptionsBox.Enum.OptionType.Goodbye,
    optionKey = 0
}

local OptionsBoxMixin = {}

function OptionsBoxMixin:OnLoad()
    self.isLoaded = true
    self.options = {}
    self.selectedIndex = nil
    self.selectedElement = nil
    self.isSelectingOption = false

    self.HitRect:AddOnMouseUp(function(button)
        if button == "RightButton" and Config.DBGlobal:GetVariable("RightClickToClose") then
            DialogFrame.RequestCloseSession()
        end
    end)
    SharedUtil.InitializeBoundsForFrame(self, "optionsBoxBounds", self.HitRect, 2)

    CallbackRegistry.Add("InputHandler.InputDeviceChanged", function()
        if self:IsActive() then self:RefreshOptions() end
    end)
    SavedVariables.OnChange("LorewalkerDB_Global", "ShowQuestLevel", function()
        if self:IsActive() then self:RefreshOptions() end
    end)
    CallbackRegistry.Add("WoWClient.OnUIScaleChanged", function()
        if self:IsVisible() then
            self:_Render()
        end
    end)

    self:RestorePosition()
    self:Hide()
end

function OptionsBoxMixin:IsActive()
    return self:IsShown() and not self.AnimGroup:IsPlaying(self, "HIDE")
end

function OptionsBoxMixin:RestorePosition()
    SharedUtil.RestoreBounds(self)
end

function OptionsBoxMixin:GetDefaultPosition(index)
    local point = index == 2 and "LEFT" or "RIGHT"
    local x = UIParent:GetWidth() * 0.09

    if index ~= 2 then x = -x end
    return point, UIParent, point, x, 0
end

function OptionsBoxMixin:SetDefaultPosition(index)
    local point, relativeTo, relativePoint, x, y = self:GetDefaultPosition(index)
    self:ClearAllPoints()
    self:SetPoint(point, relativeTo, relativePoint, x, y)
end

function OptionsBoxMixin:ResetSelection()
    if self.selectedElement then self.selectedElement:OnLeave() end
    self.selectedIndex = nil
    self.selectedElement = nil
end

function OptionsBoxMixin:SetSelection(index)
    local option = self.options[index]
    if not option then return false end

    self:ResetSelection()
    self.selectedIndex = index
    self.selectedElement = self.OptionsList:GetElement(index, "Default")
    self.selectedElement:OnEnter()
    return true
end

function OptionsBoxMixin:RefreshOptions()
    if not self.isLoaded or not ControlCenter.GetGossipSessionType() then return end

    self.isSelectingOption = false
    local selectedOption = self.selectedIndex and self.options[self.selectedIndex]
    local selectedType = selectedOption and selectedOption.optionType
    local selectedKey = selectedOption and selectedOption.optionKey
    self:ResetSelection()
    wipe(self.options)

    for _, option in ipairs(ControlCenter.GetGossipOptionsQuestQuest()) do
        self.options[#self.options + 1] = option
    end
    for _, option in ipairs(ControlCenter.GetGossipOptions()) do
        self.options[#self.options + 1] = option
    end
    self.options[#self.options + 1] = GOODBYE_OPTION
    for index, option in ipairs(self.options) do
        option.dialogOptionIndex = index <= 9 and index or nil
    end

    self.OptionsList:SetData(self.options)
    self:_Render()

    if selectedKey then
        for index, option in ipairs(self.options) do
            if option.optionType == selectedType and option.optionKey == selectedKey then
                self:SetSelection(index)
                break
            end
        end
    end

    if #self.options == 0 then self:Close() end
end

function OptionsBoxMixin:SelectNextOption()
    if not self:IsActive() then return false end
    local index = self.selectedIndex and min(self.selectedIndex + 1, #self.options) or 1
    return self:SetSelection(index)
end

function OptionsBoxMixin:SelectPreviousOption()
    if not self:IsActive() then return false end
    local index = self.selectedIndex and max(self.selectedIndex - 1, 1) or #self.options
    return self:SetSelection(index)
end

function OptionsBoxMixin:ConfirmSelection()
    if not self:IsActive() then return false end
    if self.isSelectingOption then return true end
    if not self.selectedElement then return false end
    self.selectedElement:OnClick()
    return true
end

function OptionsBoxMixin:SelectDialogOption(optionIndex)
    if not self:IsActive() then return false end
    if self.isSelectingOption then return true end

    local option = self.options[optionIndex]
    if not option then return false end
    local element = self.OptionsList:GetElement(optionIndex, "Default")

    self.isSelectingOption = true
    element:PlayPushedAnimation(function()
        self.isSelectingOption = false
        if not self:IsActive() or self.options[optionIndex] ~= option then return end
        DialogFrame.RequestGossipOptionSelection(option.optionType, option.optionKey)
    end)
    return true
end

function OptionsBoxMixin:Open()
    if not self.isLoaded or #self.options == 0 then return end
    local wasShown = self:IsShown()
    self:Show()
    self.AnimGroup:Stop()

    if wasShown then
        self:SetAlpha(1)
    else
        self.AnimGroup:Play(self, "SHOW")
    end
end

function OptionsBoxMixin:Close()
    self.isSelectingOption = false
    self:ResetSelection()
    if not self:IsShown() or self.AnimGroup:IsPlaying(self, "HIDE") then return end
    self.AnimGroup:Stop()
    self.AnimGroup:Play(self, "HIDE"):onFinish(function() self:Hide() end)
end

function OptionsBoxMixin:CloseImmediately()
    self.isSelectingOption = false
    self:ResetSelection()
    self.AnimGroup:Stop()
    self:Hide()
end

OptionsBoxMixin.AnimGroup = UIAnim.New()
do
    local FadeIn = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.25):from(0):to(1)
    local OptionFadeIn = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.5):from(0):to(1)
    local OptionMoveIn = UIAnim.Animate():property(UIAnim.Enum.Property.PosY):easing(UIAnim.Enum.Easing.SineOut):duration(0.5):from(-5):to(0)
    OptionsBoxMixin.AnimGroup:State("SHOW", function(frame)
        FadeIn:Play(frame)
        for index = 1, #frame.options do
            local element = frame.OptionsList:GetElement(index, "Default")
            local delay = (index - 1) * 0.05
            element:SetAlpha(0)
            OptionFadeIn:wait(delay):Play(element)
            OptionMoveIn:wait(delay):Play(element.ContainerFrame)
        end
    end)

    local FadeOut = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.125):to(0)
    OptionsBoxMixin.AnimGroup:State("HIDE", function(frame)
        FadeOut:Play(frame)
    end)
end

Mixin(LWOptionsBox, OptionsBoxMixin)
CallbackRegistry.Add("Preload.AddonReady", function()
    LWOptionsBox:OnLoad()
end)
