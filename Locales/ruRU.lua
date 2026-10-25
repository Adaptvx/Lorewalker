-- ♡ Contributors: ZamestoTV (Hubbotu)

if GetLocale() ~= "ruRU" then return end

local env = select(2, ...)
local L = env.L

L["ESC"] = "ESC"
L["GOODBYE"] = GOODBYE
L["ACCEPT"] = ACCEPT
L["AUTO_ACCEPT"] = ACCEPT
L["DECLINE"] = DECLINE
L["CANCEL"] = CANCEL
L["CONTINUE"] = CONTINUE
L["COMPLETE"] = COMPLETE
L["OBJECTIVES"] = "Задачи"
L["REQUIRED_ITEMS"] = TURN_IN_ITEMS
L["REWARDS"] = REWARDS
L["LEARN_SPELL_OBJECTIVE"] = LEARN_SPELL_OBJECTIVE
L["WIP"] = "В разработке"
L["FORMAT_SECONDS"] = "%g s"

-- Frames
L["DIALOG_FRAME"] = "Окно диалога"
L["DIALOG_SETTINGS_OPEN"] = "Открыть настройки"
L["DIALOG_SETTINGS_MODE"] = "Режим диалогов"
L["DIALOG_QUEST_LEVEL"] = "Уровень %d"
L["TOOLTIP_EXPERIENCE_BAR_STATISTICS"] = "Статистика"
L["TOOLTIP_EXPERIENCE_BAR_EXPERIENCE_PER_HOUR"] = "%s опыта в час."
L["TOOLTIP_EXPERIENCE_BAR_UNTIL_NEXT_LEVEL"] = "%s до следующего уровня."
L["TOOLTIP_EXPERIENCE_BAR_UNTIL_MAX_LEVEL"] = "%s до максимального уровня."

-- Playback
L["PLAYBACK_PAUSE_CHARACTERS"] = {
    "…",
    "!",
    "?",
    ".",
    ",",
    ";",
}
L["PLAYBACK_SPEED_MODIFIER"] = 1

-- Config
L["CONFIG_GENERAL"] = "Общие"
L["CONFIG_GENERAL_PREFERENCES"] = "Предпочтения"
L["CONFIG_GENERAL_PREFERENCES_FONT"] = "Шрифт"
L["CONFIG_GENERAL_OTHER"] = "Другое"
L["CONFIG_GENERAL_OTHER_RESETBUTTON"] = "Сбросить все настройки"
L["CONFIG_GENERAL_OTHER_RESETPROMPT"] = "Вы уверены, что хотите сбросить все настройки?"
L["CONFIG_GENERAL_OTHER_RESETPROMPT_YES"] = "Подтвердить"
L["CONFIG_GENERAL_OTHER_RESETPROMPT_NO"] = "Отмена"

L["CONFIG_DIALOGUE"] = "Диалоги"
L["CONFIG_DIALOGUE_MODE_CLASSIC"] = "Классический"
L["CONFIG_DIALOGUE_MODE_IMMERSIVE"] = "Погружение"
L["CONFIG_DIALOGUE_MODE_STORY"] = "Story"
L["CONFIG_DIALOGUE_PREFERENCES"] = "Preferences"
L["CONFIG_DIALOGUE_PREFERENCES_FORCEGOSSIP"] = "Показывать скрытый флуд"
L["CONFIG_DIALOGUE_PREFERENCES_SHOWQUESTLEVEL"] = "Показывать уровень заданий"
L["CONFIG_DIALOGUE_PREFERENCES_SHOWQUESTPREVIEWTOOLTIP"] = "Показывать подсказку предпросмотра задания"
L["CONFIG_DIALOGUE_TEXTPLAYBACK"] = "Воспроизведение текста"
L["CONFIG_DIALOGUE_TEXTPLAYBACK_USE"] = "Использовать постепенное появление текста"
L["CONFIG_DIALOGUE_TEXTPLAYBACK_USE_DESCRIPTION"] = "Отображает текст диалогов постепенно, а не целиком."
L["CONFIG_DIALOGUE_TEXTPLAYBACK_CLASSIC"] = "Воспроизведение в классическом режиме"
L["CONFIG_DIALOGUE_TEXTPLAYBACK_IMMERSIVE"] = "Воспроизведение в иммерсивном режиме"
L["CONFIG_DIALOGUE_TEXTPLAYBACK_SPEED"] = "Скорость воспроизведения"
L["CONFIG_DIALOGUE_TEXTPLAYBACK_AUTOPROGRESS"] = "Автоматическое перелистывание"
L["CONFIG_DIALOGUE_TEXTPLAYBACK_AUTOPROGRESSDELAY"] = "Задержка"
L["CONFIG_DIALOGUE_TEXTPLAYBACK_PUNCTUATIONPAUSING"] = "Пауза на знаках препинания"
L["CONFIG_DIALOGUE_TEXTPLAYBACK_AUTOCLOSE"] = "Автоматическое закрытие"
L["CONFIG_DIALOGUE_TEXTPLAYBACK_AUTOCLOSE_DESCRIPTION"] = "Закрывает окно диалога с НПС после финальной реплики, если нет вариантов выбора."
L["CONFIG_DIALOGUE_TEXTPLAYBACK_CONTENTPREVIEWALPHA"] = "Яркость предпросмотра контента"
L["CONFIG_DIALOGUE_FRAME"] = "Окно диалогов"
L["CONFIG_DIALOGUE_RIGHTCLICKTOCLOSE"] = "Закрытие правым кликом"
L["CONFIG_DIALOGUE_CLOSETOPREVIOUSPAGE"] = "Назад на предыдущую страницу"
L["CONFIG_DIALOGUE_CLOSETOPREVIOUSPAGE_DESCRIPTION"] = "На страницах заданий клавиша закрытия возвращает вас на предыдущую страницу вместо полного закрытия интерфейса."
L["CONFIG_DIALOGUE_IMMERSIVE"] = "Иммерсивный"
L["CONFIG_DIALOGUE_IMMERSIVE_SPLITPARAGRAPHS"] = "Разделять на абзацы"
L["CONFIG_DIALOGUE_IMMERSIVE_SPLITPARAGRAPHS_DESCRIPTION"] = "Разделяет текст диалога по абзацам. Если отключено, текст будет разделяться по предложениям."

L["CONFIG_EFFECTS"] = "Эффекты"
L["CONFIG_EFFECTS_HIDEUI"] = "Скрывать интерфейс"
L["CONFIG_EFFECTS_CAMERA"] = "Эффекты камеры"
L["CONFIG_EFFECTS_CAMERA_NONE"] = "Нет"
L["CONFIG_EFFECTS_CAMERA_FULL"] = "Полные"
L["CONFIG_EFFECTS_CAMERA_BALANCED"] = "Сбалансированные"
L["CONFIG_EFFECTS_CAMERA_CUSTOM"] = "Пользовательские"

L["CONFIG_TTS"] = "Преобразование текста в речь"

L["CONFIG_KEYBINDINGS"] = "Назначение клавиш"
L["CONFIG_KEYBINDINGS_ACTIONS"] = "Действия"
L["CONFIG_KEYBINDINGS_DEVICE_KBM"] = "Кл. и мышь"
L["CONFIG_KEYBINDINGS_DEVICE_GAMEPAD"] = "Геймпад"
L["CONFIG_KEYBINDINGS_CONFIRM"] = "Подтвердить"
L["CONFIG_KEYBINDINGS_CONFIRM_USEINTERACTKEY"] = "Использовать клавишу взаимодействия"
L["CONFIG_KEYBINDINGS_CLOSE"] = "Закрыть"
L["CONFIG_KEYBINDINGS_SCROLLDOWN"] = "Прокрутка вниз"
L["CONFIG_KEYBINDINGS_SCROLLUP"] = "Прокрутка вверх"
L["CONFIG_KEYBINDINGS_SCROLLLEFT"] = "Прокрутка влево"
L["CONFIG_KEYBINDINGS_SCROLLRIGHT"] = "Прокрутка вправо"
L["CONFIG_KEYBINDINGS_PREVIOUSDIALOG"] = "Предыдущий диалог"
L["CONFIG_KEYBINDINGS_NEXTDIALOG"] = "Следующий диалог"
L["CONFIG_KEYBINDINGS_SELECTOPTION"] = "Выбрать вариант %d"

L["CONFIG_APPEARANCE"] = "Внешний вид"
L["CONFIG_APPEARANCE_POSITION"] = "Позиция"
L["CONFIG_APPEARANCE_POSITION_LOCKFRAMEPOSITIONS"] = "Зафиксировать расположение окон"
L["CONFIG_APPEARANCE_POSITION_RESTOREPOSITIONS"] = "Восстановить позиции"
L["CONFIG_APPEARANCE_POSITION_RESTOREPOSITIONS_PROMPT"] = "Вы уверены, что хотите сбросить расположение всех окон?"
L["CONFIG_APPEARANCE_POSITION_RESTOREPOSITIONS_PROMPT_YES"] = "Подтвердить"
L["CONFIG_APPEARANCE_POSITION_RESTOREPOSITIONS_PROMPT_NO"] = "Отмена"
L["CONFIG_APPEARANCE_DIALOG"] = "Окно диалога"
L["CONFIG_APPEARANCE_DIALOG_THEME"] = "Тема оформления"
L["CONFIG_APPEARANCE_DIALOG_THEME_LIGHT"] = "Светлая"
L["CONFIG_APPEARANCE_DIALOG_THEME_DARK"] = "Темная"
L["CONFIG_APPEARANCE_DIALOG_FRAMETHEME"] = "Тема оформления окон"
L["CONFIG_APPEARANCE_DIALOG_FRAMETHEME_DEFAULT"] = "По умолчанию"
L["CONFIG_APPEARANCE_DIALOG_FRAMETHEME_FOREVER"] = "Forever"
L["CONFIG_APPEARANCE_DIALOG_FONTSIZE"] = "Размер шрифта"
L["CONFIG_APPEARANCE_IMMERSIVE"] = "Погружение"
L["CONFIG_APPEARANCE_IMMERSIVE_FONTSIZE"] = "Размер шрифта облаков текста"

L["CONFIG_AUDIO"] = "Звук"
L["CONFIG_AUDIO_GENERAL"] = "Общие"
L["CONFIG_AUDIO_GENERAL_ENABLEGLOBALAUDIO"] = "Включить звук"

L["CONFIG_ABOUT"] = "О аддоне"
L["CONFIG_ABOUT_CONTRIBUTORS"] = "Помощники"
L["CONFIG_ABOUT_DEVELOPER"] = "Разработчик"
L["CONFIG_ABOUT_DEVELOPER_ADAPTIVEX"] = "AdaptiveX"

-- Contributors
L["CONTRIBUTORS_ZAMESTOTV"] = "ZamestoTV"
L["CONTRIBUTORS_ZAMESTOTV_DESCRIPTION"] = "Переводчик — на русский язык"
L["CONTRIBUTORS_CRAZYYOUNGS"] = "Crazyyoungs"
L["CONTRIBUTORS_CRAZYYOUNGS_DESCRIPTION"] = "Переводчик — на корейский язык"
L["CONTRIBUTORS_BRAINC3LL"] = "Brainc3ll"
L["CONTRIBUTORS_BRAINC3LL_DESCRIPTION"] = "Переводчик — на французский язык"
L["CONTRIBUTORS_LANJIAN625"] = "lanjian625"
L["CONTRIBUTORS_LANJIAN625_DESCRIPTION"] = "Код — исправление ошибок бета-версии"
