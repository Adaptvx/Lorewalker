local env = select(2, ...)
local Config = env.Config
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local InputHandler = env.modules:Import("packages\\input-handler")
local ControlCenter = env.modules:Import("@\\Dialog\\ControlCenter")
local DialogFrame = env.modules:Import("@\\Dialog\\DialogFrame")
local Modes_ModeHandler = env.modules:Import("@\\Dialog\\Modes\\ModeHandler")
local ControlDispatcher = env.modules:New("@\\ControlDispatcher")


local REPEAT_INITIAL_DELAY = 0.375
local REPEAT_INTERVAL = 0.125
local Repeater = InputHandler.NewRepeater(REPEAT_INITIAL_DELAY, REPEAT_INTERVAL)


local function TryClick(button)
    if button and button:IsShown() and button:IsVisible() then
        button:OnClick()
        InputHandler.BlockKeyEvent()
        return true
    end
end

local function TryScrollDown(container)
    if container and container:IsVisible() and container:HasContentBelow() then
        container:ScrollDown()
        InputHandler.BlockKeyEvent()
        return true
    end
end

local function TryScrollUp(container)
    if container and container:IsVisible() and container:HasContentAbove() then
        container:ScrollUp()
        InputHandler.BlockKeyEvent()
        return true
    end
end

local function HandleSelectionResult(selected, deselected, allowScroll, scrollFunc, scrollContainer)
    if selected then
        InputHandler.BlockKeyEvent()
        return true
    end

    if deselected then
        if allowScroll and scrollFunc(scrollContainer) then
            return true
        end

        InputHandler.BlockKeyEvent()
        return false
    end
end

local function IsStoryOptionsShown()
    return LWStoryOptionsBox:IsActive()
end

local function HandleStoryOptionsAction(handler)
    if not IsStoryOptionsShown() then return end

    if handler(LWStoryOptionsBox) then
        InputHandler.BlockKeyEvent()
        return true
    end
    return false
end

local function HandleConfirmAction()
    local result = HandleStoryOptionsAction(LWStoryOptionsBox.ConfirmSelection)
    if result ~= nil then return result end

    if LWDialogFrame:ConfirmGossipSelection() or LWDialogFrame:ConfirmQuestSelection() then
        InputHandler.BlockKeyEvent()
        return true
    end

    return TryClick(LWDialogFrame.Footer.PrimaryButton)
end

local function HandleCloseAction()
    if Config.DBGlobal:GetVariable("CloseToPreviousPage") == false then
        DialogFrame.RequestCloseSession()
        InputHandler.BlockKeyEvent()
        return true
    end

    return TryClick(LWDialogFrame.Footer.SecondaryButton)
end

local function HandleScrollDownAction()
    local result = HandleStoryOptionsAction(LWStoryOptionsBox.SelectNextOption)
    if result ~= nil then return result end

    if LWDialogFrame.GossipFrame:IsShown() then
        local selected, deselected, allowScroll = LWDialogFrame:SelectNextGossipOption()
        local result = HandleSelectionResult(selected, deselected, allowScroll, TryScrollDown, LWDialogFrame.GossipFrame.ScrollContainer)
        if result ~= nil then return result end
    end
    if LWDialogFrame.QuestFrame:IsShown() then
        local selected, deselected, allowScroll = LWDialogFrame:SelectNextQuestReward()
        local result = HandleSelectionResult(selected, deselected, allowScroll, TryScrollDown, LWDialogFrame.QuestFrame.ScrollContainer)
        if result ~= nil then return result end
    end
    if TryScrollDown(LWDialogFrame.GossipFrame.ScrollContainer) then
        return true
    end
    if TryScrollDown(LWDialogFrame.QuestFrame.ScrollContainer) then
        return true
    end
end

local function HandleScrollUpAction()
    local result = HandleStoryOptionsAction(LWStoryOptionsBox.SelectPreviousOption)
    if result ~= nil then return result end

    if LWDialogFrame.GossipFrame:IsShown() then
        local selected, deselected, allowScroll = LWDialogFrame:SelectPreviousGossipOption()
        local result = HandleSelectionResult(selected, deselected, allowScroll, TryScrollUp, LWDialogFrame.GossipFrame.ScrollContainer)
        if result ~= nil then return result end
    end
    if LWDialogFrame.QuestFrame:IsShown() then
        local selected, deselected, allowScroll = LWDialogFrame:SelectPreviousQuestReward()
        local result = HandleSelectionResult(selected, deselected, allowScroll, TryScrollUp, LWDialogFrame.QuestFrame.ScrollContainer)
        if result ~= nil then return result end
    end
    if TryScrollUp(LWDialogFrame.GossipFrame.ScrollContainer) then
        return true
    end
    if TryScrollUp(LWDialogFrame.QuestFrame.ScrollContainer) then
        return true
    end
end

local function HandleSelectDialogOptionAction(optionIndex)
    if IsStoryOptionsShown() then
        return LWStoryOptionsBox:SelectDialogOption(optionIndex)
    end

    ControlDispatcher.pushedDialogOption = LWDialogFrame:SetDialogOptionPushed(optionIndex, true)

    if ControlCenter.SelectDialogOption(optionIndex) then return true end

    ControlDispatcher.ReleasePushedDialogOption()
    return false
end

local DIALOG_FRAME_ACTIONS = {
    [env.Enum.Actions.Confirm] = {
        handler = HandleConfirmAction,
    },
    [env.Enum.Actions.Close] = {
        handler = HandleCloseAction,
    },
    [env.Enum.Actions.ScrollDown] = {
        handler = HandleScrollDownAction,
        repeatable = true,
    },
    [env.Enum.Actions.ScrollUp] = {
        handler = HandleScrollUpAction,
        repeatable = true,
    },
    [env.Enum.Actions.SelectOption1] = {
        handler = function() return HandleSelectDialogOptionAction(1) end,
        block = true,
    },
    [env.Enum.Actions.SelectOption2] = {
        handler = function() return HandleSelectDialogOptionAction(2) end,
        block = true,
    },
    [env.Enum.Actions.SelectOption3] = {
        handler = function() return HandleSelectDialogOptionAction(3) end,
        block = true,
    },
    [env.Enum.Actions.SelectOption4] = {
        handler = function() return HandleSelectDialogOptionAction(4) end,
        block = true,
    },
    [env.Enum.Actions.SelectOption5] = {
        handler = function() return HandleSelectDialogOptionAction(5) end,
        block = true,
    },
    [env.Enum.Actions.SelectOption6] = {
        handler = function() return HandleSelectDialogOptionAction(6) end,
        block = true,
    },
    [env.Enum.Actions.SelectOption7] = {
        handler = function() return HandleSelectDialogOptionAction(7) end,
        block = true,
    },
    [env.Enum.Actions.SelectOption8] = {
        handler = function() return HandleSelectDialogOptionAction(8) end,
        block = true,
    },
    [env.Enum.Actions.SelectOption9] = {
        handler = function() return HandleSelectDialogOptionAction(9) end,
        block = true,
    },
}

local IMMERSIVE_ACTIONS = {
    [env.Enum.Actions.PreviousDialog]  = {
        handler = LWImmersiveChatBubble.PreviousDialog,
        block = true,
    },
    [env.Enum.Actions.NextDialog]  = {
        handler = LWImmersiveChatBubble.NextDialog,
        block = true,
    },
}

local STORY_ACTIONS = {
    [env.Enum.Actions.Confirm] = {
        handler = LWStoryDialogBox.NextDialog,
        block = true,
    },
    [env.Enum.Actions.Close] = {
        handler = function()
            if not ControlCenter.IsInSession() then return false end
            DialogFrame.RequestCloseSession()
            return true
        end,
        block = true,
    },
    [env.Enum.Actions.NextDialog]  = {
        handler = LWStoryDialogBox.NextDialog,
        block = true,
    },
}

local function IsImmersiveModeActive()
    return Modes_ModeHandler.IsModeActive(env.Enum.Mode.Immersive)
end

local function IsStoryModeActive()
    return Modes_ModeHandler.IsModeActive(env.Enum.Mode.Story)
end

local function IsDialogFrameShown()
    return LWDialogFrame:IsShown()
end

local function CanProcessKeyInput()
    return not LWSettingFrame:IsShown() and (IsImmersiveModeActive() or IsStoryModeActive() or IsDialogFrameShown())
end

local function HandleAction(actionID)
    if IsStoryModeActive() then
        local action = STORY_ACTIONS[actionID]
        if action and action.handler(LWStoryDialogBox) then
            return action, IsStoryModeActive
        end
    end

    if IsImmersiveModeActive() then
        local action = IMMERSIVE_ACTIONS[actionID]
        if action and action.handler(LWImmersiveChatBubble) then
            return action, IsImmersiveModeActive
        end
    end

    if IsStoryOptionsShown() then
        local action = DIALOG_FRAME_ACTIONS[actionID]
        if action and action.handler() then
            return action, IsStoryOptionsShown
        end
        return
    end

    if IsDialogFrameShown() then
        local action = DIALOG_FRAME_ACTIONS[actionID]
        if action and action.handler() then
            return action, IsDialogFrameShown
        end
    end
end


function ControlDispatcher.ReleasePushedDialogOption()
    local optionElement = ControlDispatcher.pushedDialogOption
    ControlDispatcher.pushedDialogOption = nil
    ControlDispatcher.pushedDialogOptionKey = nil
    if not optionElement then return end

    optionElement:SetPushed(false)
    optionElement:UpdateButtonState()
end

function ControlDispatcher.OnKeyDown(key, device)
    if not CanProcessKeyInput() then
        Repeater:Stop()
        ControlDispatcher.ReleasePushedDialogOption()
        return
    end

    if Repeater:IsRepeatingKey(key) or key == ControlDispatcher.pushedDialogOptionKey then
        InputHandler.BlockKeyEvent()
        return
    end

    Repeater:Stop()
    ControlDispatcher.ReleasePushedDialogOption()

    local bindingKey = InputHandler.GetKeyChord(key)
    if not bindingKey then return end
    local actionID = InputHandler.Keybindings:GetActionForBinding(bindingKey, device)
    if Config.DBGlobal:GetVariable("ConfirmUseInteractKey") then
        if InputHandler.IsKeyBinding(key, "INTERACTTARGET") then
            actionID = env.Enum.Actions.Confirm
        elseif actionID == env.Enum.Actions.Confirm then
            return
        end
    end
    if not actionID then return end
    local action, isActionActive = HandleAction(actionID)
    if not action then return end

    if ControlDispatcher.pushedDialogOption then
        ControlDispatcher.pushedDialogOptionKey = key
    end

    if action.block then
        InputHandler.BlockKeyEvent()
    end

    if action.repeatable then
        Repeater:Start(key, bindingKey, action.handler, function()
            return CanProcessKeyInput() and isActionActive()
        end)
    end
end

function ControlDispatcher.OnKeyUp(key)
    if Repeater:IsRepeatingKey(key) then
        Repeater:Stop()
    end

    if key == ControlDispatcher.pushedDialogOptionKey then
        ControlDispatcher.ReleasePushedDialogOption()
    end
end

CallbackRegistry.Add("InputHandler.OnKeyDown", function(_, key, device)
    ControlDispatcher.OnKeyDown(key, device)
end)
CallbackRegistry.Add("InputHandler.OnKeyUp", function(_, key) ControlDispatcher.OnKeyUp(key) end)
CallbackRegistry.Add("ControlCenter.ModeChanged", function() Repeater:Stop() end)
