local env = select(2, ...)
local Config = env.Config
local Path = env.modules:Import("packages\\path")
local InputHandler = env.modules:Import("packages\\input-handler")
local LazyTimer = env.modules:Import("packages\\lazy-timer")
local WoWClient = env.modules:Import("packages\\wow-client")
local SharedUtil = env.modules:New("@\\Dialog\\SharedUtil")

local UIParent = UIParent
local GetCursorPosition = GetCursorPosition
local ResetCursor = ResetCursor
local SetCursor = SetCursor
local next = next
local type = type
local gsub = string.gsub
local abs = math.abs
local floor = math.floor
local max = math.max
local min = math.min


local CLASSIC_QUEST_ID_MAP = {
    { 1,   2 }, { 5, 15 }, { 17, 40 }, { 45, 107 }, { 109, 116 }, { 118, 235 },
    { 237, 253 }, { 255, 299 }, { 301, 307 }, { 309, 315 }, { 317, 325 }, { 328, 348 },
    { 350, 389 }, { 391, 401 }, { 404, 409 }, { 411, 430 }, { 432, 578 }, { 580, 592 },
    { 594, 618 }, { 620, 739 }, { 741, 773 }, { 775, 778 }, { 780, 794 }, { 804, 812 },
    { 814, 821 }, { 823, 840 }, { 842, 858 }, { 860, 888 }, { 890, 903 }, { 905, 925 },
    { 927, 959 }, { 962, 971 }, { 973, 986 }, { 988, 995 }, 997, { 1000, 1004 },
    { 1007, 1098 }, { 1100, 1102 }, { 1104, 1126 }, { 1130, 1164 }, { 1166, 1173 }, { 1175, 1190 },
    { 1194, 1206 }, { 1218, 1222 }, { 1238, 1253 }, { 1258, 1262 }, { 1264, 1271 }, { 1273, 1280 },
    1282, { 1284, 1302 }, { 1318, 1324 }, { 1338, 1339 }, { 1358, 1375 }, { 1380, 1398 },
    { 1418, 1422 }, { 1424, 1441 }, { 1443, 1461 }, { 1465, 1492 }, { 1498, 1499 }, { 1501, 1513 },
    { 1515, 1538 }, { 1558, 1560 }, { 1578, 1582 }, { 1598, 1599 }, 1618, { 1638, 1640 },
    { 1642, 1644 }, { 1646, 1654 }, { 1656, 1667 }, { 1678, 1693 }, { 1698, 1713 }, { 1715, 1719 },
    { 1738, 1740 }, 1758, { 1778, 1788 }, { 1791, 1792 }, { 1795, 1796 }, { 1798, 1806 },
    { 1818, 1825 }, { 1838, 1848 }, { 1858, 1861 }, { 1879, 1886 }, { 1898, 1899 }, { 1918, 1921 },
    { 1938, 1963 }, 1978, { 1998, 2000 }, { 2018, 2020 }, { 2038, 2041 }, { 2058, 2059 },
    2078, 2098, 2118, { 2138, 2139 }, { 2158, 2161 }, 2178,
    { 2198, 2206 }, 2218, { 2238, 2242 }, { 2258, 2260 }, { 2278, 2284 }, { 2298, 2300 },
    2318, { 2338, 2342 }, { 2358, 2361 }, { 2378, 2383 }, { 2398, 2399 }, 2418,
    { 2438, 2440 }, { 2458, 2460 }, { 2478, 2480 }, { 2498, 2501 }, { 2518, 2521 }, 2541,
    2561, 2581, 2583, 2585, 2601, 2603,
    { 2605, 2609 }, { 2621, 2623 }, 2641, { 2661, 2662 }, 2681, { 2701, 2702 },
    2721, { 2741, 2746 }, { 2751, 2773 }, { 2781, 2784 }, 2801, { 2821, 2822 },
    { 2841, 2877 }, { 2879, 2880 }, { 2902, 2904 }, { 2922, 2952 }, 2954, { 2962, 3002 },
    { 3022, 3023 }, 3042, { 3062, 3065 }, { 3082, 3130 }, 3141, 3161,
    { 3181, 3182 }, 3201, 3221, 3241, 3261, 3281,
    3301, 3321, 3341, { 3361, 3362 }, { 3364, 3374 }, { 3376, 3381 },
    { 3383, 3385 }, { 3401, 3405 }, { 3422, 3425 }, { 3441, 3454 }, { 3461, 3463 }, { 3481, 3482 },
    3501, { 3504, 3531 }, { 3541, 3542 }, { 3561, 3566 }, { 3568, 3570 }, { 3601, 3602 },
    { 3621, 3643 }, 3661, 3681, { 3701, 3702 }, 3721, 3741,
    { 3761, 3765 }, { 3781, 3791 }, { 3801, 3802 }, { 3821, 3825 }, { 3841, 3845 }, { 3881, 3885 },
    { 3901, 3914 }, { 3921, 3924 }, { 3941, 3942 }, { 3961, 3962 }, { 3981, 3982 }, { 4001, 4005 },
    { 4021, 4024 }, { 4061, 4063 }, { 4081, 4084 }, { 4101, 4102 }, { 4120, 4136 }, { 4141, 4148 },
    4161, { 4181, 4186 }, 4201, { 4223, 4224 }, { 4241, 4245 }, { 4261, 4267 },
    { 4281, 4294 }, { 4296, 4301 }, { 4321, 4324 }, { 4341, 4342 }, { 4361, 4363 }, 4402,
    4421, { 4441, 4442 }, { 4449, 4451 }, { 4485, 4496 }, { 4501, 4513 }, 4521,
    { 4541, 4542 }, 4581, { 4601, 4602 }, { 4605, 4606 }, 4621, { 4641, 4642 },
    4681, 4701, { 4721, 4743 }, { 4761, 4771 }, { 4781, 4784 }, { 4786, 4788 },
    { 4808, 4813 }, { 4821, 4822 }, { 4841, 4842 }, { 4861, 4867 }, { 4881, 4883 }, { 4901, 4907 },
    4921, 4941, { 4961, 4969 }, { 4971, 4972 }, { 4974, 4976 }, { 4981, 4987 },
    { 5001, 5002 }, { 5021, 5023 }, 5041, { 5047, 5052 }, { 5054, 5058 }, { 5060, 5062 },
    { 5064, 5066 }, { 5081, 5098 }, { 5101, 5103 }, 5121, { 5123, 5128 }, { 5141, 5149 },
    { 5151, 5168 }, 5181, { 5202, 5217 }, { 5219, 5220 }, { 5222, 5223 }, { 5225, 5226 },
    { 5228, 5238 }, { 5241, 5253 }, { 5261, 5265 }, { 5281, 5284 }, { 5301, 5307 }, 5321,
    { 5341, 5344 }, 5361, { 5381, 5386 }, 5401, 5405, 5441,
    { 5461, 5466 }, { 5481, 5482 }, { 5501, 5507 }, { 5511, 5518 }, { 5520, 5538 }, { 5541, 5545 },
    5561, 5581, 5601, { 5621, 5713 }, { 5721, 5730 }, { 5741, 5742 },
    { 5761, 5763 }, 5781, { 5801, 5805 }, 5821, { 5841, 5848 }, { 5861, 5863 },
    { 5881, 5891 }, { 5901, 5904 }, { 5921, 5932 }, { 5941, 5944 }, 5961, { 6001, 6004 },
    { 6021, 6032 }, { 6041, 6042 }, { 6061, 6076 }, { 6081, 6089 }, { 6101, 6103 }, { 6121, 6130 },
    { 6132, 6136 }, { 6141, 6148 }, { 6161, 6165 }, { 6181, 6187 }, { 6201, 6202 }, 6261,
    { 6281, 6285 }, 6301, { 6321, 6324 }, { 6341, 6344 }, { 6361, 6365 }, { 6381, 6395 },
    { 6401, 6403 }, 6421, { 6441, 6442 }, { 6461, 6462 }, { 6481, 6482 }, { 6501, 6504 },
    { 6521, 6523 }, { 6541, 6544 }, 6548, { 6561, 6571 }, { 6582, 6585 }, { 6601, 6612 },
    { 6621, 6629 }, 6641, { 6661, 6662 }, 6681, 6702, 6704,
    6706, 6708, 6710, { 6721, 6722 }, { 6761, 6762 }, { 6804, 6805 },
    { 6821, 6824 }, { 6841, 6845 }, { 6921, 6922 }, { 6961, 6964 }, 6981, { 6983, 6984 },
    7003, { 7021, 7025 }, { 7028, 7029 }, { 7041, 7046 }, { 7061, 7070 }, { 7081, 7082 },
    { 7101, 7102 }, { 7121, 7124 }, { 7141, 7142 }, { 7161, 7172 }, 7181, { 7201, 7202 },
    { 7221, 7224 }, 7241, 7261, { 7281, 7282 }, { 7301, 7302 }, 7321,
    { 7361, 7368 }, { 7383, 7384 }, { 7401, 7402 }, 7441, { 7461, 7463 }, { 7481, 7482 },
    { 7486, 7509 }, { 7521, 7522 }, 7541, { 7561, 7564 }, { 7581, 7583 }, { 7601, 7604 },
    { 7621, 7659 }, { 7667, 7668 }, 7670, { 7681, 7682 }, { 7701, 7704 }, { 7721, 7724 },
    { 7727, 7734 }, 7741, 7761, { 7781, 7795 }, { 7798, 7800 }, { 7802, 7805 },
    { 7807, 7811 }, { 7813, 7818 }, { 7820, 7824 }, { 7826, 7831 }, { 7833, 7836 }, { 7839, 7850 },
    { 7861, 7877 }, { 7904, 7905 }, 7908, 7926, { 7961, 7962 }, { 8041, 8080 },
    { 8101, 8123 }, { 8141, 8156 }, { 8160, 8162 }, { 8166, 8171 }, { 8181, 8183 }, 8201,
    8227, { 8230, 8237 }, 8240, { 8247, 8248 }, { 8250, 8266 }, 8268,
    { 8271, 8288 }, { 8290, 8291 }, { 8294, 8295 }, 8297, 8299, 8301,
    { 8303, 8318 }, { 8320, 8323 }, { 8331, 8332 }, 8341, 8343, { 8348, 8349 },
    { 8351, 8352 }, 8361, { 8365, 8382 }, { 8393, 8396 }, { 8399, 8403 }, { 8409, 8430 },
    { 8436, 8439 }, { 8444, 8447 }, { 8458, 8462 }, { 8464, 8465 }, { 8470, 8471 }, 8481,
    { 8484, 8485 }, 8492, 8494, 8499, 8503, 8505,
    8509, 8511, 8513, 8515, 8517, { 8519, 8520 },
    8522, 8524, 8526, 8528, 8530, 8532,
    8542, 8545, 8549, { 8551, 8558 }, 8571, { 8575, 8580 },
    8582, { 8584, 8588 }, 8590, { 8597, 8600 }, 8604, { 8606, 8607 },
    8609, 8611, 8613, 8615, 8617, { 8619, 8620 },
    { 8635, 8636 }, { 8642, 8654 }, { 8670, 8686 }, { 8688, 8730 }, { 8733, 8736 }, { 8741, 8763 },
    { 8767, 8769 }, 8788, { 8791, 8803 }, { 8827, 8828 }, { 8857, 8862 }, { 8866, 8875 },
    8883, { 8897, 8970 }, 8973, { 8977, 8980 }, { 8982, 8992 }, { 8994, 9033 },
    { 9051, 9053 }, 9063, 9065, 9085, { 9120, 9124 }, 9126,
    9128, 9131, 9136, 9141, { 9153, 9154 }, { 9229, 9230 },
    { 9232, 9248 }, { 9250, 9251 }, 9257, { 9260, 9265 }, { 9269, 9272 }, 9292,
    9295, { 9299, 9302 }, 9304, 9310, 9319, { 9322, 9326 },
    { 9330, 9332 }, 9339, 9362, { 9364, 9365 }, { 9367, 9368 }, 9378,
    { 9388, 9389 }, { 9411, 9416 }, 9419, 9422, 9556, { 9664, 9665 },
    55296, 60860, { 60863, 60866 }, 60868, 60870, 61547,
    63769, 65309, 65593, 65597, { 65601, 65604 }, 65610,
    65616, 66145, 66193, 66281, { 66286, 66295 }, { 66317, 66318 },
    73193, 74584, 75300, { 75939, 75940 }, 75969, 76156,
    76160, 76240, 77568, 77571, { 77573, 77575 }, { 77582, 77588 },
    77590, 77592, { 77616, 77621 }, { 77642, 77643 }, { 77648, 77649 }, { 77651, 77652 },
    { 77655, 77661 }, { 77666, 77672 }, 77690, { 78023, 78024 }, { 78088, 78093 }, 78114,
    78121, 78124, 78127, { 78132, 78134 }, { 78142, 78150 }, { 78192, 78199 },
    78229, 78242, 78261, { 78265, 78267 }, 78277, 78280,
    78284, { 78287, 78288 }, { 78295, 78297 }, 78304, { 78306, 78307 }, 78506,
    78537, 78561, 78575, 78647, { 78650, 78654 }, { 78675, 78676 },
    { 78680, 78682 }, 78684, 78699, 78702, 78823, 78830,
    78832, { 78907, 78910 }, 78914, { 78916, 78917 }, { 78919, 78927 }, 78994,
    { 79007, 79008 }, { 79077, 79080 }, { 79090, 79099 }, 79192, 79229, { 79235, 79236 },
    79242, 79298, 79348, 79358, { 79360, 79366 }, 79377,
    79442, { 79482, 79487 }, 79492, 79495, { 79501, 79502 }, { 79535, 79536 },
    { 79614, 79615 }, 79624, 79626, 79637, { 79677, 79678 }, { 79687, 79689 },
    79695, 79700, 79705, 79719, 79731, 79905,
    { 79939, 79940 }, 79942, { 79945, 79953 }, 79961, 79963, 79970,
    { 79972, 79987 }, 80056, 80098, 80120, { 80131, 80143 }, { 80147, 80153 },
    { 80156, 80159 }, 80161, { 80180, 80182 }, 80241, { 80324, 80325 }, 80393,
    { 80410, 80411 }, { 80453, 80455 }, 80526, 81570, 81573, 81682,
    81697, { 81730, 81747 }, 81762, { 81764, 81766 }, { 81768, 81790 }, 81801,
    81817, 81820, 81826, 81830, { 81832, 81835 }, { 81837, 81839 },
    { 81850, 81852 }, { 81855, 81861 }, { 81863, 81868 }, { 81870, 81874 }, 81877, 81879,
    { 81883, 81885 }, 81900, 81917, 81919, 81924, 81944,
    81947, 81949, { 81951, 81956 }, { 81960, 81961 }, 81968, { 81973, 81975 },
    81977, { 81979, 81980 }, { 81982, 81983 }, { 81986, 81987 }, { 82001, 82004 }, { 82008, 82011 },
    { 82013, 82015 }, { 82017, 82023 }, 82032, { 82043, 82044 }, 82060, 82062,
    82068, { 82070, 82076 }, 82081, { 82083, 82084 }, { 82089, 82092 }, { 82095, 82104 },
    { 82106, 82108 }, { 82110, 82115 }, 82132, 82135, 82208, { 82304, 82306 },
    { 82310, 82316 }, { 82656, 82657 }, 82662, 82665, { 82850, 82851 }, 82853,
    { 83183, 83187 }, 83756, 83808, { 83822, 83823 }, { 83934, 83988 }, { 83990, 83998 },
    84004, 84008, 84017, { 84124, 84126 }, { 84135, 84138 }, { 84146, 84213 },
    84235, 84238, { 84317, 84332 }, 84338, { 84348, 84351 }, { 84355, 84356 },
    { 84359, 84360 }, { 84368, 84369 }, 84372, { 84374, 84375 }, 84377, { 84383, 84384 },
    { 84394, 84402 }, { 84405, 84408 }, { 84410, 84418 }, 84488, { 84495, 84496 }, { 84499, 84504 },
    84526, { 84545, 84546 }, { 84548, 84551 }, { 84555, 84558 }, { 84560, 84561 }, 84590,
    { 84636, 84637 }, 84853, 84870, { 84880, 84881 }, 84950, { 84968, 84969 },
    { 85030, 85031 }, { 85033, 85034 }, { 85056, 85058 }, 85061, { 85063, 85069 }, { 85073, 85074 },
    { 85086, 85087 }, { 85090, 85093 }, 85112, { 85140, 85150 }, 85152, 85248,
    { 85250, 85251 }, 85304, { 85385, 85386 }, 85388, 85401, 85435,
    { 85441, 85443 }, { 85445, 85447 }, { 85452, 85458 }, 85468, 85480, { 85485, 85486 },
    85501, { 85504, 85511 }, { 85521, 85522 }, 85525, { 85555, 85559 }, { 85576, 85579 },
    85583, { 85604, 85641 }, { 85643, 85644 }, { 85658, 85660 }, { 85699, 85706 }, { 85712, 85713 },
    85772, { 85882, 85883 }, 86181, 86326, { 86433, 86434 }, { 86442, 86445 },
    86449, 86670, { 86673, 86674 }, { 86679, 86680 }, { 86724, 86725 }, { 86964, 86971 },
    87283, { 87360, 87362 }, { 87364, 87373 }, { 87441, 87444 }, 87459, 87493,
    { 87497, 87498 }, 87502, 87506, { 87508, 87509 }, { 87516, 87518 }, 87520,
    { 88717, 88718 }, { 88729, 88730 }, { 88744, 88745 }, { 88748, 88749 }, 88940, { 88943, 88944 },
    { 88968, 88969 }, 89224, 89226, 89229, 89232, { 89234, 89237 },
    89245, 89253, { 89255, 89262 }, { 89298, 89301 }, { 89303, 89304 }, 89310,
    { 89328, 89329 }, { 89340, 89342 }, { 89355, 89376 }, 89381, 89421, { 89442, 89449 },
    89451, { 89462, 89463 }, 89471, { 89473, 89475 }, { 89485, 89489 }, 89491,
    { 89562, 89563 }, { 89567, 89568 }, 89574, { 90106, 90107 }, 90116, 90120,
    { 90506, 90508 }, 90510, 90516, { 90518, 90520 }, 90539, { 90558, 90560 },
    { 90566, 90567 }, { 90603, 90606 }, { 90611, 90613 }, { 90624, 90627 }, 90629, 91354,
    { 91888, 91889 }
}
local HOTKEY_REPLACEMENT_MAP = {
    ESCAPE       = { text = "ESC" },
    SPACE        = { icon = Path.Root .. "\\Art\\Hotkeys\\Space", noFrame = false },
    PADLSHOULDER = { icon = Path.Root .. "\\Art\\Hotkeys\\LB", noFrame = true },
    PADRSHOULDER = { icon = Path.Root .. "\\Art\\Hotkeys\\RB", noFrame = true },
    PADLTRIGGER  = { icon = Path.Root .. "\\Art\\Hotkeys\\LT", noFrame = true },
    PADRTRIGGER  = { icon = Path.Root .. "\\Art\\Hotkeys\\RT", noFrame = true }
}
local HOTKEY_REPLACEMENT_MAP_BY_DEVICE = {
    [InputHandler.Enum.DisplayInputDevices.Xbox] = {
        PAD1 = { icon = Path.Root .. "\\Art\\Hotkeys\\XBOX-P1", noFrame = true },
        PAD2 = { icon = Path.Root .. "\\Art\\Hotkeys\\XBOX-P2", noFrame = true },
        PAD3 = { icon = Path.Root .. "\\Art\\Hotkeys\\XBOX-P3", noFrame = true },
        PAD4 = { icon = Path.Root .. "\\Art\\Hotkeys\\XBOX-P4", noFrame = true }
    },
    [InputHandler.Enum.DisplayInputDevices.PS]   = {
        PAD1 = { icon = Path.Root .. "\\Art\\Hotkeys\\PS-P1", noFrame = true },
        PAD2 = { icon = Path.Root .. "\\Art\\Hotkeys\\PS-P2", noFrame = true },
        PAD3 = { icon = Path.Root .. "\\Art\\Hotkeys\\PS-P3", noFrame = true },
        PAD4 = { icon = Path.Root .. "\\Art\\Hotkeys\\PS-P4", noFrame = true }
    }
}
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

    if not frame.isResizing and Config.DBGlobal:GetVariable("LockFramePositions") then
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


function SharedUtil.GetHotkeyReplacement(key, device)
    local replacementMap = HOTKEY_REPLACEMENT_MAP_BY_DEVICE[device or InputHandler.GetDisplayInputDevice()]
    return replacementMap and replacementMap[key] or HOTKEY_REPLACEMENT_MAP[key]
end

function SharedUtil.GetHotkeyText(binding, device, forceIconSize)
    if not binding then return "" end

    local text = gsub(binding, "[^-]+", function(key)
        local replacement = SharedUtil.GetHotkeyReplacement(key, device)
        if not replacement then return key end

        if replacement.icon then
            local iconSize = (forceIconSize and forceIconSize) or (replacement.noFrame and 22 or 14)
            return "|T" .. replacement.icon .. ":" .. iconSize .. ":" .. iconSize .. "|t"
        end

        return replacement.text or key
    end)

    return text
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
    if Config.DBGlobal:GetVariable("LockFramePositions") then return false end
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

function SharedUtil.IsForeverQuest(questID)
    if not WoWClient.IS_FOREVER or not questID or questID <= 0 then return false end

    local low, high = 1, #CLASSIC_QUEST_ID_MAP
    while low <= high do
        local mid = floor((low + high) * 0.5)
        local entry = CLASSIC_QUEST_ID_MAP[mid]
        local firstID, lastID = entry, entry
        if type(entry) == "table" then firstID, lastID = entry[1], entry[2] end

        if questID < firstID then
            high = mid - 1
        elseif questID > lastID then
            low = mid + 1
        else
            return false
        end
    end

    return true
end
