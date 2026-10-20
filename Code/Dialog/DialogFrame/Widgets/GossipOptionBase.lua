local env = select(2, ...)
local Config = env.Config
local L = env.L
local Sound = env.modules:Import("packages\\sound")
local UICSharedMixin = env.modules:Import("packages\\uic-sharedmixin")
local InputHandler = env.modules:Import("packages\\input-handler")
local SharedUtil = env.modules:Import("@\\Dialog\\SharedUtil")
local ControlCenter_Preload = env.modules:Import("@\\Dialog\\ControlCenter\\Preload")
local ControlCenter_DataProvider = env.modules:Import("@\\Dialog\\ControlCenter\\DataProvider")
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
        self.questInfo = nil
        self:SetSublabelText(nil)

        self:InitButton()
        self:RegisterMouseEvents()
        self:HookScript("OnEnter", self.Option_OnEnter)
        self:HookScript("OnLeave", self.Option_OnLeave)
        self:HookScript("OnHide", self.Option_OnLeave)
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookClick(self.OnClick)
        self:UpdateAnimation()
    end

    function OptionMixin:OnClick()
        self:Option_OnLeave()
        DialogFrame.RequestGossipOptionSelection(self.optionType, self.optionKey)
        self:PlayInteractSound()
    end

    function OptionMixin:Option_OnEnter()
        local questInfo = self.questInfo
        if not questInfo or not self:IsEnabled() or not Config.DBGlobal:GetVariable("ShowQuestPreviewTooltip") then return end

        ControlCenter_DataProvider.RequestQuestPreviewData(questInfo.questID)

        if Config.DBGlobal:GetVariable("ActiveMode") == env.Enum.Mode.Story then
            GameTooltip_SetDefaultAnchor(GameTooltip, self)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        self:UpdateTooltip()
    end

    function OptionMixin:Option_OnLeave()
        if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
    end

    function OptionMixin:UpdateTooltip()
        local questInfo = self.questInfo
        if not questInfo or not self:IsShown() or not GameTooltip:IsOwned(self) then return end
        if not self:IsEnabled() or not Config.DBGlobal:GetVariable("ShowQuestPreviewTooltip") then
            self:Option_OnLeave()
            return
        end

        local previewInfo, isDataReady = ControlCenter_DataProvider.BuildQuestPreviewInfo(questInfo)
        SharedUtil.UpdateQuestTooltip(previewInfo, isDataReady, self.optionType == ControlCenter_Preload.Enum.OptionType.QuestIncomplete)
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
        element.questInfo = value.questInfo
        if GameTooltip:IsShown() and GameTooltip:IsOwned(element) then
            element:Option_OnLeave()
            element:Option_OnEnter()
        end
    end
end
