local env = select(2, ...)
local Config = env.Config
local LazyTimer = env.modules:Import("packages\\lazy-timer")
local SharedUtil = env.modules:New("@\\Dialog\\SharedUtil")

local UIParent = UIParent
local GetCursorPosition = GetCursorPosition
local ResetCursor = ResetCursor
local SetCursor = SetCursor
local next = next
local abs = math.abs
local max = math.max
local min = math.min


local SNAP_THRESHOLD = 12


local function GetDefaultSize(frame)
    if not frame.boundsDefaultSize then return end
    return frame.boundsDefaultSize(frame)
end

local function GetDefaultPosition(frame, index)
    local point, relativeTo, relativePoint, x, y = frame:GetDefaultPosition(index)
    if not point then return end

    local currentPoint, currentRelativeTo, currentRelativePoint, currentX, currentY = frame:GetPoint()
    if not currentPoint then return end

    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, x, y)
    local left = frame:GetLeft()
    local top = frame:GetTop()

    frame:ClearAllPoints()
    frame:SetPoint(currentPoint, currentRelativeTo, currentRelativePoint, currentX, currentY)
    return left, top
end

local function SetPosition(frame, left, top, clearPoints)
    if clearPoints then frame:ClearAllPoints() end

    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
end

local function StartDrag(frame, includeDefaultPositions)
    local left = frame:GetLeft()
    local top = frame:GetTop()
    if left == nil or top == nil then return false end

    if includeDefaultPositions then
        for index = 1, frame.boundsDefaultPositionCount do
            local defaultLeft, defaultTop = GetDefaultPosition(frame, index)
            if defaultLeft == nil or defaultTop == nil then return false end

            frame["boundsDragDefaultLeft" .. index] = defaultLeft
            frame["boundsDragDefaultTop" .. index] = defaultTop
        end
    end

    local cursorX, cursorY = GetCursorPosition()
    frame.boundsDragCursorX = cursorX
    frame.boundsDragCursorY = cursorY
    frame.boundsDragLeft = left
    frame.boundsDragTop = top
    frame.boundsDragWidth = frame:GetWidth()
    frame.boundsDragHeight = frame:GetHeight()
    frame.isBoundsDragging = true

    SetPosition(frame, left, top, true)
    return true
end

local function UpdateBounds(frame)
    if not frame.isBoundsDragging then return end

    if frame.isNameplateAnchored then
        SharedUtil.StopMoving(frame)
        return
    end

    local cursorX, cursorY = GetCursorPosition()
    local scale = frame:GetEffectiveScale()
    local deltaX = (cursorX - frame.boundsDragCursorX) / scale
    local deltaY = (cursorY - frame.boundsDragCursorY) / scale

    if frame.isResizing then
        local width = min(max(frame.boundsDragWidth + deltaX, frame.minWidth), frame.maxWidth)
        local height = min(max(frame.boundsDragHeight - deltaY, frame.minHeight), frame.maxHeight)
        if frame.forcedAspectRatio then height = width * frame.forcedAspectRatio end

        local defaultWidth, defaultHeight = GetDefaultSize(frame)
        if defaultWidth and defaultHeight
            and abs(width - defaultWidth) <= SNAP_THRESHOLD
            and abs(height - defaultHeight) <= SNAP_THRESHOLD then
            width, height = defaultWidth, defaultHeight
        end

        frame:SetSize(width, height)
        SetPosition(frame, frame.boundsDragLeft, frame.boundsDragTop)
    else
        local left = frame.boundsDragLeft + deltaX
        local top = frame.boundsDragTop + deltaY
        for index = 1, frame.boundsDefaultPositionCount do
            local defaultLeft = frame["boundsDragDefaultLeft" .. index]
            local defaultTop = frame["boundsDragDefaultTop" .. index]
            if abs(left - defaultLeft) <= SNAP_THRESHOLD
                and abs(top - defaultTop) <= SNAP_THRESHOLD then
                left = defaultLeft
                top = defaultTop
                break
            end
        end

        SetPosition(frame, left, top)
    end
end

local function StopDrag(frame)
    frame.isBoundsDragging = false
    if not frame.isNameplateAnchored then SharedUtil.SaveBounds(frame) end
end


function SharedUtil.RegisterBoundsForFrame(frame, key, defaultPositionCount, defaultSize)
    frame.boundsKey = key
    frame.boundsDefaultPositionCount = defaultPositionCount
    frame.boundsDefaultSize = defaultSize
    frame.isBoundsResizable = defaultSize ~= nil
    frame.bounds = {}
end

function SharedUtil.InitializeBoundsForFrame(frame, key, dragHandle, defaultPositionCount, defaultSize)
    SharedUtil.RegisterBoundsForFrame(frame, key, defaultPositionCount, defaultSize)

    frame.DragStopTimer = LazyTimer.New()
    frame.DragStopTimer:SetAction(function()
        if not frame.isBoundsDragging then frame.isDragging = false end
    end)

    dragHandle:SetScript("OnDragStart", function() SharedUtil.StartMoving(frame) end)
    dragHandle:SetScript("OnDragStop", function() SharedUtil.StopMoving(frame) end)
    frame:HookScript("OnUpdate", UpdateBounds)
    frame:HookScript("OnHide", function()
        if frame.isResizing then
            frame:StopResizing()
        elseif frame.isBoundsDragging then
            SharedUtil.StopMoving(frame)
        end
    end)
end

function SharedUtil.RestoreBounds(frame)
    local bounds = Config.DBGlobal:GetVariable(frame.boundsKey)
    if frame.isBoundsResizable then
        local defaultWidth, defaultHeight = GetDefaultSize(frame)
        frame:SetSize(bounds and bounds.width or defaultWidth, bounds and bounds.height or defaultHeight)
    end

    if bounds and bounds.point and bounds.x ~= nil and bounds.y ~= nil then
        frame:ClearAllPoints()
        frame:SetPoint(bounds.point, UIParent, bounds.x, bounds.y)
    else
        frame:SetDefaultPosition(1)
    end
end

function SharedUtil.SaveBounds(frame)
    local left = frame:GetLeft()
    local top = frame:GetTop()
    if left == nil or top == nil then return end

    local bounds = frame.bounds
    bounds.point = nil
    bounds.x = nil
    bounds.y = nil
    bounds.width = nil
    bounds.height = nil
    local defaultPositionIndex
    for index = 1, frame.boundsDefaultPositionCount do
        local defaultLeft, defaultTop = GetDefaultPosition(frame, index)
        if defaultLeft and defaultTop
            and abs(left - defaultLeft) < 0.5
            and abs(top - defaultTop) < 0.5 then
            defaultPositionIndex = index
            break
        end
    end

    if defaultPositionIndex then
        frame:SetDefaultPosition(defaultPositionIndex)
    else
        local screenHeight = UIParent:GetHeight() * UIParent:GetEffectiveScale() / frame:GetEffectiveScale()
        bounds.point = "TOPLEFT"
        bounds.x = left
        bounds.y = top - screenHeight
    end

    if frame.isBoundsResizable then
        local width, height = frame:GetSize()
        local defaultWidth, defaultHeight = GetDefaultSize(frame)
        if not defaultWidth or not defaultHeight
            or abs(width - defaultWidth) >= 0.5
            or abs(height - defaultHeight) >= 0.5 then
            bounds.width = width
            bounds.height = height
        end
    end

    Config.DBGlobal:SetVariable(frame.boundsKey, next(bounds) and bounds or nil)
end

function SharedUtil.StartMoving(frame)
    if frame.isNameplateAnchored or frame.isBoundsDragging then return false end
    if not StartDrag(frame, true) then return false end

    frame.isDragging = true
    SetCursor("Interface\\Cursor\\UI-Cursor-Move")
    return true
end

function SharedUtil.StopMoving(frame)
    if not frame.isBoundsDragging or frame.isResizing then return end

    StopDrag(frame)
    ResetCursor()
    frame.DragStopTimer:Start(0)
end

function SharedUtil.StartResizing(frame)
    if frame.isBoundsDragging then return false end
    if not StartDrag(frame) then return false end

    frame.isResizing = true
    return true
end

function SharedUtil.StopResizing(frame)
    if not frame.isResizing then return end

    frame.isResizing = false
    StopDrag(frame)
end
