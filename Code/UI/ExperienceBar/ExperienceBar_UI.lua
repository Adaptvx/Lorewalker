local env = select(2, ...)
local UIKit = env.modules:Import("packages\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollContainer, LazyScrollContainer, ScrollBar, ScrollContainerEdge, Input, LinearSlider, HitRect, List, SecureButton, ModelScene = unpack(UIKit.UI.Frames)
local UI_Preload = env.modules:Import("@\\UI\\Preload")


do --LWUIExperienceBar
    local name = "LWUIExperienceBar"
    local id = "LWUIExperienceBar"

    local frame = Frame(name, {
            Frame(name .. ".Fill")
                :id("Fill", id)
                :size(0, UIKit.UI.P_FILL)
                :point(UIKit.Enum.Point.Left)
                :frameStrata(UIKit.Enum.FrameStrata.Fullscreen)
                :frameLevel(2)
                :background(UI_Preload.UIDEF.UIExperienceBarFill)
                :_updateMode(UIKit.Enum.UpdateMode.None)
        })
        :parent(LWParent)
        :frameStrata(UIKit.Enum.FrameStrata.Fullscreen)
        :frameLevel(1)
        :size(UIKit.UI.P_FILL, 16)
        :point(UIKit.Enum.Point.Bottom)
        :enableMouseMotion(true)
        :background(UI_Preload.UIDEF.UIExperienceBarFrame)
        :_Render()

    frame.Fill = UIKit.GetElementById("Fill", id)
    frame:Hide()

    LWUIExperienceBar = frame
end
