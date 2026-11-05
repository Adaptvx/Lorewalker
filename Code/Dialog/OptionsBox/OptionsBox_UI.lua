local env = select(2, ...)
local GenericEnum = env.modules:Import("packages\\generic-enum")
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List, SecureButton, ModelScene = unpack(UIKit.UI.Frames)
local UIAnim = env.modules:Import("packages\\ui-anim")
local GossipOptionBase = env.modules:Import("@\\Dialog\\DialogFrame\\Widgets\\GossipOptionBase")
local OptionsBox_Preload = env.modules:Import("@\\Dialog\\OptionsBox\\Preload")
local OptionsBox_UI = env.modules:New("@\\Dialog\\OptionsBox\\UI")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

do -- Option
    local ICON_SIZE = 22
    local TEXT_MAX_WIDTH = 300
    local CONTENT_SPACING = 12
    local SUBLABEL_WIDTH = UIKit.Define.Fit{ delta = CONTENT_SPACING }
    local ALPHA_DISABLED = 0.5
    local ALPHA_NORMAL = 0.75
    local ALPHA_HIGHLIGHTED = 1
    local ALPHA_PUSHED = 0.875

    local OptionMixin = CreateFromMixins(GossipOptionBase.OptionMixin)

    function OptionMixin:OnLoad()
        GossipOptionBase.OptionMixin.OnLoad(self)

        self:HookScript("OnHide", function()
            self:SetPushed(false)
            self:SetHighlighted(false)
            self:UpdateButtonState()
            self:UpdateAnimation()
        end)
    end

    function OptionMixin:OnClick(button)
        if not self:IsEnabled() or not LWOptionsBox:IsActive() or LWOptionsBox.isDragging then return end
        if button == "RightButton" then return end

        GossipOptionBase.OptionMixin.OnClick(self)
    end

    function OptionMixin:UpdateAnimation()
        self.AnimGroup:Stop(self.ContainerFrame)
        if not self:IsEnabled() then
            self.ContainerFrame:SetAlpha(ALPHA_DISABLED)
            return
        end
        self.AnimGroup:Play(self.ContainerFrame, self:GetButtonState())
    end

    function OptionMixin:PlayPushedAnimation(onFinish)
        self:SetPushed(true)
        self:UpdateButtonState()
        self.AnimGroup:Play(self.ContainerFrame, "PUSHED"):onFinish(function()
            self:SetPushed(false)
            self:UpdateButtonState()
            onFinish()
        end)
    end

    OptionMixin.AnimGroup = UIAnim.New()
    do
        local NormalAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.125):to(ALPHA_NORMAL)
        OptionMixin.AnimGroup:State("NORMAL", function(frame)
            NormalAlpha:Play(frame)
        end)

        local HighlightedAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.125):to(ALPHA_HIGHLIGHTED)
        OptionMixin.AnimGroup:State("HIGHLIGHTED", function(frame)
            HighlightedAlpha:Play(frame)
        end)

        local PushedAlpha = UIAnim.Animate():property(UIAnim.Enum.Property.Alpha):duration(0.075):to(ALPHA_PUSHED)
        OptionMixin.AnimGroup:State("PUSHED", function(frame)
            PushedAlpha:Play(frame)
        end)
    end

    OptionsBox_UI.Option = UIKit.Template(function(id, name, children, ...)
        local frame =
            LayoutVertical(name, {
                LayoutHorizontal(name .. ".ContainerFrame", {
                    Frame(name .. ".Icon")
                        :id("Icon", id)
                        :size(ICON_SIZE, ICON_SIZE)
                        :background(UIKit.UI.TEXTURE_NIL),

                    Text(name .. ".Label")
                        :id("Label", id)
                        :size(UIKit.UI.FIT, UIKit.UI.FIT)
                        :maxWidth(TEXT_MAX_WIDTH)
                        :fontObject(UIFont.UIFontObjectNormal16)
                        :textColor(GenericEnum.UIColorRGB.WHITE_FONT_COLOR)
                        :textJustifyH("LEFT")
                        :textJustifyV("MIDDLE")
                        :wordWrap(true),

                    Text(name .. ".Sublabel")
                        :id("Sublabel", id)
                        :frameLevel(2)
                        :size(SUBLABEL_WIDTH, UIKit.UI.FIT)
                        :layoutPushH()
                        :textJustifyH("RIGHT")
                        :textJustifyV("MIDDLE")
                        :fontObject(UIFont.UIFontObjectNormal16)
                        :textColor(GenericEnum.UIColorRGB.WHITE_FONT_COLOR)
                        :textVerticalSpacing(1.5)
                        :alpha(0.5)
                })
                    :id("ContainerFrame", id)
                    :frameLevel(2)
                    :size(UIKit.UI.FIT, UIKit.UI.FIT)
                    :layoutAlignmentV(UIKit.Enum.Direction.Justified)
                    :layoutSpacing(CONTENT_SPACING)
                    :alpha(ALPHA_DISABLED)
            })
            :size(UIKit.UI.FIT, UIKit.UI.FIT)
            :layoutStretchH()
            :enableMouse(true)

        frame.ContainerFrame = UIKit.GetElementById("ContainerFrame", id)
        frame.Icon = UIKit.GetElementById("Icon", id)
        frame.IconTexture = frame.Icon:GetTextureFrame()
        frame.Label = UIKit.GetElementById("Label", id)
        frame.Sublabel = UIKit.GetElementById("Sublabel", id)

        Mixin(frame, OptionMixin)
        frame:OnLoad()

        return frame
    end)
end

do -- Options Box
    local SHADOW_SIZE = UIKit.Define.Fill{ delta = -325 }
    local FRAME_SIZE = UIKit.Define.Fit{ delta = 48 }
    local CONTENT_SPACING = 8

    local function OnOptionUpdate(element, index, value)
        GossipOptionBase.OnOptionUpdate(element, index, value, true)
        element:SetHighlighted(false)
        element:UpdateButtonState()
        element:UpdateAnimation()
    end

    local name = "LWOptionsBox"
    local id = "LWOptionsBox"

    local frame = Frame(name, {
            HitRect(name .. ".HitRect")
                :id("HitRect", id)
                :size(UIKit.UI.FILL)
                :frameLevel(1000)
                :registerForDrag(true)
                :_excludeFromCalculations(true),

            Frame(name .. ".Shadow")
                :id("Shadow", id)
                :background(OptionsBox_Preload.UIDEF.UIOptionsBoxShadow)
                :size(SHADOW_SIZE)
                :frameLevel(1)
                :_excludeFromCalculations(true),

            LayoutVertical(name .. ".ContentFrame", {
                List(name .. ".OptionsList")
                    :id("OptionsList", id)
                    :poolTemplate(OptionsBox_UI.Option)
                    :poolElementUpdate(OnOptionUpdate)
            })
                :id("ContentFrame", id)
                :frameLevel(2)
                :point(UIKit.Enum.Point.Center)
                :size(UIKit.UI.FIT, UIKit.UI.FIT)
                :layoutStretchH()
                :layoutSpacing(CONTENT_SPACING)
        })
        :parent(LWParent)
        :frameStrata(UIKit.Enum.FrameStrata.Fullscreen)
        :size(FRAME_SIZE, FRAME_SIZE)
        :movable(true)
        :dontSavePosition(true)
        :clampedToScreen(true)
        :enableMouse(true)
        :_Render()

    frame.HitRect = UIKit.GetElementById("HitRect", id)
    frame.Shadow = UIKit.GetElementById("Shadow", id)
    frame.ContentFrame = UIKit.GetElementById("ContentFrame", id)
    frame.OptionsList = UIKit.GetElementById("OptionsList", id)

    LWOptionsBox = frame
end
