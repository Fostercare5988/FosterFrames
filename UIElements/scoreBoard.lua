-- FosterFrames - Battleground Scoreboard Class Coloring
-- Enhanced 1.12.1 Engine Stack (ClassicAPI hooksecurefunc)

local function ColorScoreBoardNames()
    local numScores = GetNumBattlefieldScores()
    local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)

    for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
        local index = offset + i
        if index <= numScores then
            local name, _, _, _, _, _, _, _, class = GetBattlefieldScore(index)
            if name and name ~= UnitName('player') and class then
                local classUpper = string.upper(class)
                local color = RAID_CLASS_COLORS[classUpper]
                if color then
                    local btn = _G["WorldStateScoreButton" .. i .. "NameButtonName"]
                    if btn then
                        btn:SetVertexColor(color.r, color.g, color.b)
                    end
                end
            end
        end
    end
end

if WorldStateScoreFrame_Update then
    hooksecurefunc("WorldStateScoreFrame_Update", ColorScoreBoardNames)
end