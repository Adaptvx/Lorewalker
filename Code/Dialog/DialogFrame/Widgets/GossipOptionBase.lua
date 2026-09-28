local env = select(2, ...)
local Config = env.Config
local L = env.L
local Sound = env.modules:Import("packages\\sound")
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local InputHandler = env.modules:Import("packages\\input-handler")
local ControlCenter_Preload = env.modules:Import("@\\Dialog\\ControlCenter\\Preload")
local ControlCenter = env.modules:Import("@\\Dialog\\ControlCenter")
local DialogFrame = env.modules:Await("@\\Dialog\\DialogFrame")
local GossipOptionBase = env.modules:New("@\\Dialog\\DialogFrame\\Widgets\\GossipOptionBase")

local CreateFromMixins = CreateFromMixins
local format = string.format

do -- Option
    local CONTENT_Y = 0
    local CONTENT_Y_HIGHLIGHTED = 0
    local CONTENT_Y_PUSHED = -1
    local ALPHA_ENABLED = 1
    local ALPHA_DISABLED = 0.5

    local OptionMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)
    GossipOptionBase.OptionMixin = OptionMixin

    function OptionMixin:OnLoad()
        self.optionType = nil
        self.optionKey = nil
        self:SetSublabelText(nil)

        self:InitButton()
        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookClick(self.OnClick)
        self:UpdateAnimation()
    end

    function OptionMixin:OnClick()
        DialogFrame.RequestGossipOptionSelection(self.optionType, self.optionKey)
        self:PlayInteractSound()
    end

    function OptionMixin:SetText(text)
        self.Label:SetText(text)
    end

    function OptionMixin:SetSublabelText(text)
        self.Sublabel:SetText(text or "")
        self.Sublabel:SetShown(text ~= nil and text ~= "")
    end

    function OptionMixin:SetImage(texture)
        self.IconTexture:SetTexture(texture)
    end

    function OptionMixin:SetTrivial(isTrivial)
        self.IconTexture:SetAlpha(isTrivial and 0.75 or 1)
        self.Label:SetAlpha(isTrivial and 0.75 or 1)
    end

    function OptionMixin:UpdateAnimation()
        local enabled = self:IsEnabled()
        local buttonState = self:GetButtonState()

        if not enabled then
            self.Background:Hide()
            self.ContainerFrame:ClearAllPoints()
            self.ContainerFrame:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
        elseif buttonState == "NORMAL" then
            self.Background:Hide()
            self.ContainerFrame:ClearAllPoints()
            self.ContainerFrame:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
        elseif buttonState == "HIGHLIGHTED" then
            self.Background:Show()
            self.ContainerFrame:ClearAllPoints()
            self.ContainerFrame:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y_HIGHLIGHTED)
        elseif buttonState == "PUSHED" then
            self.Background:Show()
            self.ContainerFrame:ClearAllPoints()
            self.ContainerFrame:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y_PUSHED)
        end

        self.ContainerFrame:SetAlpha(enabled and ALPHA_ENABLED or ALPHA_DISABLED)
    end

    function OptionMixin:PlayInteractSound()
        if ControlCenter.GetGossipSessionType() == ControlCenter_Preload.Enum.SessionType.GossipGreeting then
            Sound.PlaySound("UI", SOUNDKIT.IG_QUEST_LIST_SELECT)
        end
    end
end

do -- Group
    local GroupMixin = {}
    GossipOptionBase.GroupMixin = GroupMixin

    function GroupMixin:SetData(data)
        self.OptionListFrame:SetData(data)
    end

    function GossipOptionBase.OnOptionUpdate(element, index, value, alternate)
        local optionIndex = value.dialogOptionIndex
        local showOptionIndex = optionIndex and InputHandler.GetInputDevice() == InputHandler.Enum.InputDevices.KBM
        local name = alternate and value.alternateName or value.name
        local questLevel = value.questInfo and value.questInfo.questLevel

        element:SetSublabelText(Config.DBGlobal:GetVariable("ShowQuestLevel") and questLevel and questLevel > 0 and format(L["DIALOG_QUEST_LEVEL"], questLevel) or nil)
        element:SetText((showOptionIndex and optionIndex .. ". " or "") .. name)
        element:SetImage(value.contextIcon or value.icon)
        element:SetTrivial(value.questInfo and value.questInfo.questIsTrivial)
        element:SetPushed(false)
        element:UpdateButtonState()

        element.optionType = value.optionType
        element.optionKey = value.optionKey
    end
end
