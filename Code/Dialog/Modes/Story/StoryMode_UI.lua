local env = select(2, ...)
local GenericEnum = env.modules:Import("packages\\generic-enum")
local UIFont = env.modules:Import("packages\\ui-font")
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List, SecureButton, ModelScene = unpack(UIKit.UI.Frames)
local StoryMode_Preload = env.modules:Import("@\\Dialog\\Modes\\Story\\Preload")
local StoryMode_UI = env.modules:New("@\\Dialog\\Modes\\Story\\UI")

local Mixin = Mixin

do -- Divider
    local DividerMixin = {}

    function DividerMixin:SetText(text)
        self.Divider:SetShown(text == nil)
        self.SectionDivider:SetShown(text ~= nil)
        self.Label:SetText(text or "")
        self:_Render()
    end

    StoryMode_UI.Divider = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Divider", {
                    Frame(name .. ".DividerLine")
                        :id("DividerLine", id)
                        :size(UIKit.UI.P_FILL, 12)
                        :point(UIKit.Enum.Point.Center)
                        :background(StoryMode_Preload.UIDEF.UIDialogBoxDivider),

                    Frame(name .. ".DividerOrnament")
                        :id("DividerOrnament", id)
                        :size(12, 12)
                        :point(UIKit.Enum.Point.Center)
                        :background(StoryMode_Preload.UIDEF.UIDialogBoxDividerOrnament)
                })
                    :id("Divider", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.P_FILL, 12),

                LayoutHorizontal(name .. ".SectionDivider", {
                    Frame(name .. ".DividerLeft")
                        :id("DividerLeft", id)
                        :background(StoryMode_Preload.UIDEF.UIDialogBoxDividerSectionLeft)
                        :height(12)
                        :layoutGrow(1),

                    Text(name .. ".Label")
                        :id("Label", id)
                        :fontObject(UIFont.UIFontObjectNormal14)
                        :textColor(GenericEnum.UIColorRGB.NORMAL_FONT_COLOR)
                        :size(UIKit.UI.FIT, UIKit.UI.P_FILL)
                        :_updateMode(UIKit.Enum.UpdateMode.UserUpdate),

                    Frame(name .. ".DividerRight")
                        :id("DividerRight", id)
                        :background(StoryMode_Preload.UIDEF.UIDialogBoxDividerSectionRight)
                        :height(12)
                        :layoutGrow(1)
                })
                    :id("SectionDivider", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.P_FILL, 12)
                    :layoutSpacing(6)
            })
            :height(12)

        frame.Divider = UIKit.GetElementById("Divider", id)
        frame.DividerLine = UIKit.GetElementById("DividerLine", id)
        frame.DividerOrnament = UIKit.GetElementById("DividerOrnament", id)
        frame.SectionDivider = UIKit.GetElementById("SectionDivider", id)
        frame.DividerLeft = UIKit.GetElementById("DividerLeft", id)
        frame.Label = UIKit.GetElementById("Label", id)
        frame.DividerRight = UIKit.GetElementById("DividerRight", id)

        Mixin(frame, DividerMixin)

        return frame
    end)
end

do -- LWStoryDialogBox
    local name = "LWStoryDialogBox"
    local id = "LWStoryDialogBox"

    local frame = Frame(name, {
            Frame(name .. ".Shadow")
                :id("Shadow", id)
                :background(StoryMode_Preload.UIDEF.UIDialogBoxShadow)
                :point(UIKit.Enum.Point.Center)
                :size(UIKit.Define.Percentage{ value = 200 }, UIKit.Define.Percentage{ value = 100, operator = "+", delta = 100 })
                :frameLevel(1)
                :_excludeFromCalculations(true),

            LayoutVertical(name .. ".ContainerFrame", {
                Frame(name .. ".TitleFrame", {
                    Text(name .. ".TitleText")
                        :id("TitleText", id)
                        :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
                        :point(UIKit.Enum.Point.Center)
                        :fontObject(UIFont.UIFontObjectNormal18)
                        :textColor(GenericEnum.UIColorRGB.NORMAL_FONT_COLOR)
                        :textJustifyH("CENTER")
                        :textJustifyV("MIDDLE")
                })
                    :id("TitleFrame", id)
                    :size(UIKit.UI.P_FILL, 16),

                StoryMode_UI.Divider(name .. ".Divider")
                    :id("Divider", id)
                    :size(UIKit.UI.P_FILL, 9),

                Frame(name .. ".ContentFrame", {
                    Text(name .. ".ContentText")
                        :id("ContentText", id)
                        :size(UIKit.UI.P_FILL, UIKit.UI.FIT)
                        :point(UIKit.Enum.Point.Center)
                        :ignoreParentAlpha(true)
                        :fontObject(UIFont.UIFontObjectNormal18)
                        :textColor(GenericEnum.UIColorRGB.WHITE_FONT_COLOR)
                        :textJustifyH("CENTER")
                        :textJustifyV("MIDDLE")
                        :wordWrap(true)
                })
                    :id("ContentFrame", id)
                    :size(UIKit.Define.Percentage{ value = 75 }, UIKit.UI.FIT)
                    :minHeight(42),

                Frame(name .. ".ArrowFrame", {
                    Frame(name .. ".Arrow")
                        :id("Arrow", id)
                        :size(16, 16)
                        :point(UIKit.Enum.Point.Center)
                        :background(StoryMode_Preload.UIDEF.UIArrow)
                })
                    :id("ArrowFrame", id)
                    :size(16, 16)
            })
                :id("ContainerFrame", id)
                :size(UIKit.UI.P_FILL, UIKit.UI.FIT)
                :point(UIKit.Enum.Point.Center)
                :layoutAlignmentH(UIKit.Enum.Direction.Justified)
                :layoutAlignmentV(UIKit.Enum.Direction.Justified)
                :layoutSpacing(12)
                :frameLevel(2)
        })
        :parent(LWParent)
        :frameStrata(UIKit.Enum.FrameStrata.Fullscreen)
        :size(750, UIKit.UI.FIT)
        :minHeight(125)
        :movable(true)
        :dontSavePosition(true)
        :clampedToScreen(true)
        :enableMouse(true)
        :registerForDrag(true)
        :_Render()

    frame.Shadow = UIKit.GetElementById("Shadow", id)
    frame.ContainerFrame = UIKit.GetElementById("ContainerFrame", id)
    frame.TitleFrame = UIKit.GetElementById("TitleFrame", id)
    frame.TitleText = UIKit.GetElementById("TitleText", id)
    frame.Divider = UIKit.GetElementById("Divider", id)
    frame.ContentFrame = UIKit.GetElementById("ContentFrame", id)
    frame.ContentText = UIKit.GetElementById("ContentText", id)
    frame.ArrowFrame = UIKit.GetElementById("ArrowFrame", id)
    frame.Arrow = UIKit.GetElementById("Arrow", id)

    LWStoryDialogBox = frame
end

