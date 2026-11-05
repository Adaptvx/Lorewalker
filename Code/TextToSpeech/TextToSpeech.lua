local env = select(2, ...)
local CallbackRegistry = env.modules:Import("packages\\callback-registry")
local LazyTimer = env.modules:Import("packages\\lazy-timer")
local TextToSpeech = env.modules:New("@\\TextToSpeech")

local GetTtsVoices = C_VoiceChat.GetTtsVoices
local SpeakText = C_VoiceChat.SpeakText
local StopSpeakingText = C_VoiceChat.StopSpeakingText
local GetVoiceOptionID = C_TTSSettings.GetVoiceOptionID
local GetSpeechRate = C_TTSSettings.GetSpeechRate
local GetSpeechVolume = C_TTSSettings.GetSpeechVolume
local CreateFrame = CreateFrame
local ipairs = ipairs
local pairs = pairs
local type = type
local wipe = table.wipe
local tinsert = table.insert
local tremove = table.remove


do --Voices
    function TextToSpeech.GetVoices()
        return GetTtsVoices()
    end

    function TextToSpeech.GetVoice(voiceID)
        for _, voice in ipairs(TextToSpeech.GetVoices()) do
            if voice.voiceID == voiceID then
                return voice
            end
        end
    end

    function TextToSpeech.GetDefaultVoiceID()
        local voiceID = GetVoiceOptionID(Enum.TtsVoiceType.Standard)
        if TextToSpeech.GetVoice(voiceID) then return voiceID end

        local voices = TextToSpeech.GetVoices()
        return voices[1] and voices[1].voiceID
    end

    function TextToSpeech.IsAvailable()
        return #TextToSpeech.GetVoices() > 0
    end
end


do --Playback
    local PlaybackUtil = {}
    PlaybackUtil.Queue = {}
    PlaybackUtil.ActiveEntries = {}
    PlaybackUtil.SubmittingEntry = nil
    PlaybackUtil.QueueTimer = LazyTimer.New()

    local SPEAK_TEXT_SUCCESS_LOOKUP = {
        [Enum.VoiceTtsStatusCode.Success]             = true,
        [Enum.VoiceTtsStatusCode.InputTextEnqueued]   = true,
        [Enum.VoiceTtsStatusCode.EnqueueNotNecessary] = true
    }

    function PlaybackUtil.CreateEntry(text, voiceID, rate, volume, overlap)
        if type(text) ~= "string" or text == "" then return nil, "INVALID_TEXT" end

        if voiceID == nil then voiceID = TextToSpeech.GetDefaultVoiceID() end
        if not TextToSpeech.GetVoice(voiceID) then return nil, "VOICE_UNAVAILABLE" end

        if rate == nil then rate = GetSpeechRate() end
        if volume == nil then volume = GetSpeechVolume() end
        if overlap == nil then overlap = false end

        if type(rate) ~= "number" then return nil, "INVALID_RATE" end
        if type(volume) ~= "number" or volume < 0 or volume > 100 then return nil, "INVALID_VOLUME" end
        if type(overlap) ~= "boolean" then return nil, "INVALID_OVERLAP" end

        return {
            text    = text,
            voiceID = voiceID,
            rate    = rate,
            volume  = volume,
            overlap = overlap
        }
    end

    function PlaybackUtil.CanProcessQueue()
        return PlaybackUtil.Queue[1] and (#PlaybackUtil.ActiveEntries == 0 or PlaybackUtil.Queue[1].playImmediately)
    end

    function PlaybackUtil.ScheduleQueue()
        if not PlaybackUtil.CanProcessQueue() then return end
        PlaybackUtil.QueueTimer:Start(0)
    end

    function PlaybackUtil.FindEntry(utteranceID, allowPending)
        local pendingEntry = nil
        for _, entry in ipairs(PlaybackUtil.ActiveEntries) do
            if entry.utteranceID == utteranceID then return entry end
            if allowPending and entry.utteranceID == nil and (not pendingEntry or entry == PlaybackUtil.SubmittingEntry) then
                pendingEntry = entry
            end
        end
        return pendingEntry
    end

    function PlaybackUtil.ReleaseEntry(entry)
        if not entry then return end

        for index, activeEntry in ipairs(PlaybackUtil.ActiveEntries) do
            if activeEntry == entry then
                tremove(PlaybackUtil.ActiveEntries, index)
                break
            end
        end
        PlaybackUtil.ScheduleQueue()
    end

    function PlaybackUtil.SubmitEntry(entry)
        if not entry.overlap then wipe(PlaybackUtil.ActiveEntries) end
        PlaybackUtil.ActiveEntries[#PlaybackUtil.ActiveEntries + 1] = entry

        PlaybackUtil.SubmittingEntry = entry
        SpeakText(entry.voiceID, entry.text, entry.rate, entry.volume, entry.overlap)
        PlaybackUtil.SubmittingEntry = nil
    end

    function PlaybackUtil.ProcessQueue()
        if not PlaybackUtil.CanProcessQueue() then return end
        PlaybackUtil.SubmitEntry(tremove(PlaybackUtil.Queue, 1))
        PlaybackUtil.ScheduleQueue()
    end

    function PlaybackUtil.OnSpeakTextUpdate(_, status, utteranceID)
        local entry = PlaybackUtil.FindEntry(utteranceID, true)
        if not entry then return end

        entry.utteranceID = utteranceID
        if not SPEAK_TEXT_SUCCESS_LOOKUP[status] then
            PlaybackUtil.ReleaseEntry(entry)
        end
    end

    function PlaybackUtil.OnPlaybackStarted(_, utteranceID)
        local entry = PlaybackUtil.FindEntry(utteranceID, true)
        if entry then entry.utteranceID = utteranceID end
    end

    function PlaybackUtil.OnPlaybackFinished(_, utteranceID)
        PlaybackUtil.ReleaseEntry(PlaybackUtil.FindEntry(utteranceID))
    end

    function PlaybackUtil.OnPlaybackFailed(_, utteranceID)
        PlaybackUtil.ReleaseEntry(PlaybackUtil.FindEntry(utteranceID, true))
    end

    CallbackRegistry.Add("TextToSpeech.SpeakTextUpdate", PlaybackUtil.OnSpeakTextUpdate, -1)
    CallbackRegistry.Add("TextToSpeech.PlaybackStarted", PlaybackUtil.OnPlaybackStarted, -1)
    CallbackRegistry.Add("TextToSpeech.PlaybackFinished", PlaybackUtil.OnPlaybackFinished, -1)
    CallbackRegistry.Add("TextToSpeech.PlaybackFailed", PlaybackUtil.OnPlaybackFailed, -1)

    PlaybackUtil.QueueTimer:SetAction(PlaybackUtil.ProcessQueue)

    function TextToSpeech.SpeakText(text, voiceID, rate, volume, overlap, playImmediately)
        local entry, reason = PlaybackUtil.CreateEntry(text, voiceID, rate, volume, overlap)
        if not entry then return false, reason end

        if playImmediately then
            entry.playImmediately = true
            local index = 1
            while PlaybackUtil.Queue[index] and PlaybackUtil.Queue[index].playImmediately do
                index = index + 1
            end
            tinsert(PlaybackUtil.Queue, index, entry)
        else
            PlaybackUtil.Queue[#PlaybackUtil.Queue + 1] = entry
        end
        PlaybackUtil.ScheduleQueue()
        return true
    end

    function TextToSpeech.ClearQueue(stopCurrent)
        wipe(PlaybackUtil.Queue)
        PlaybackUtil.QueueTimer:Stop()

        if stopCurrent then
            wipe(PlaybackUtil.ActiveEntries)
            StopSpeakingText()
        end
    end

    function TextToSpeech.StopSpeakingText()
        TextToSpeech.ClearQueue(true)
    end

    function TextToSpeech.GetQueueSize()
        return #PlaybackUtil.Queue
    end

    function TextToSpeech.IsBusy()
        return #PlaybackUtil.ActiveEntries > 0 or #PlaybackUtil.Queue > 0
    end
end


do --Events
    local EVENT_CALLBACK_LOOKUP = {
        VOICE_CHAT_TTS_VOICES_UPDATE     = "TextToSpeech.VoicesChanged",
        VOICE_CHAT_TTS_SPEAK_TEXT_UPDATE = "TextToSpeech.SpeakTextUpdate",
        VOICE_CHAT_TTS_PLAYBACK_STARTED  = "TextToSpeech.PlaybackStarted",
        VOICE_CHAT_TTS_PLAYBACK_FINISHED = "TextToSpeech.PlaybackFinished",
        VOICE_CHAT_TTS_PLAYBACK_FAILED   = "TextToSpeech.PlaybackFailed",
        VOICE_CHAT_TTS_PLAYBACK_BOOKMARK = "TextToSpeech.PlaybackBookmark"
    }

    local EL = CreateFrame("Frame")
    for event in pairs(EVENT_CALLBACK_LOOKUP) do EL:RegisterEvent(event) end
    EL:SetScript("OnEvent", function(_, event, ...)
        if event == "VOICE_CHAT_TTS_VOICES_UPDATE" then
            CallbackRegistry.Trigger(EVENT_CALLBACK_LOOKUP[event], TextToSpeech.GetVoices())
        else
            CallbackRegistry.Trigger(EVENT_CALLBACK_LOOKUP[event], ...)
        end
    end)
end
