-- FosterFrames - Custom Border Generator
-- Enhanced 1.12.1 Engine Stack

local borderTexture = [[Interface\AddOns\FosterFrames\globals\resources\border.tga]]
local defaultTcut = 1 / 4.2

local function getTextCoords(tcutsize)
    local sides = {
        [1] = { 0, tcutsize, tcutsize, 1 - tcutsize },
        [2] = { 1 - tcutsize, 1, tcutsize, 1 - tcutsize },
        [3] = { tcutsize, 1 - tcutsize, 0, tcutsize },
        [4] = { tcutsize, 1 - tcutsize, 1 - tcutsize, 1 },
    }
    local corners = {
        [1] = { { 0, tcutsize, 0, tcutsize }, 'TOPLEFT' },
        [2] = { { 1 - tcutsize, 1, 0, tcutsize }, 'TOPRIGHT' },
        [3] = { { 0, tcutsize, 1 - tcutsize, 1 }, 'BOTTOMLEFT' },
        [4] = { { 1 - tcutsize, 1, 1 - tcutsize, 1 }, 'BOTTOMRIGHT' },
    }
    return corners, sides
end

function CreateBorder(name, parent, size, tcut)
    local this = CreateFrame('Frame', name, parent)
    this:SetAllPoints()
    this:SetFrameLevel(parent:GetFrameLevel() + 1)

    local tcutsize = tcut or defaultTcut
    local corners, sides = getTextCoords(tcutsize)

    this.c = {}
    for i = 1, 4 do
        this.c[i] = this:CreateTexture(nil, 'OVERLAY')
        this.c[i]:SetHeight(size)
        this.c[i]:SetWidth(size)
        this.c[i]:SetTexture(borderTexture)
        this.c[i]:SetTexCoord(corners[i][1][1], corners[i][1][2], corners[i][1][3], corners[i][1][4])

        local xo = (i == 1 or i == 3) and -1/8 or 1/8
        local yo = (i == 1 or i == 2) and 1/8 or -1/8
        this.c[i]:SetPoint(corners[i][2], this, xo * size, yo * size)
    end

    this.s = {}
    for i = 1, 4 do
        this.s[i] = this:CreateTexture(nil, 'OVERLAY')
        this.s[i]:SetTexture(borderTexture)
        this.s[i]:SetTexCoord(sides[i][1], sides[i][2], sides[i][3], sides[i][4])
    end

    this.s[1]:SetPoint('TOPLEFT', this.c[1], 'BOTTOMLEFT')
    this.s[1]:SetPoint('BOTTOMRIGHT', this.c[3], 'TOPRIGHT')

    this.s[2]:SetPoint('TOPLEFT', this.c[2], 'BOTTOMLEFT')
    this.s[2]:SetPoint('BOTTOMRIGHT', this.c[4], 'TOPRIGHT')

    this.s[3]:SetPoint('TOPLEFT', this.c[1], 'TOPRIGHT')
    this.s[3]:SetPoint('BOTTOMRIGHT', this.c[2], 'BOTTOMLEFT')

    this.s[4]:SetPoint('TOPLEFT', this.c[3], 'TOPRIGHT')
    this.s[4]:SetPoint('BOTTOMRIGHT', this.c[4], 'BOTTOMLEFT')

    function this:SetColor(r, g, b)
        for i = 1, 4 do
            this.c[i]:SetVertexColor(r, g, b)
            this.s[i]:SetVertexColor(r, g, b)
        end
    end
    this:SetColor(0.1, 0.1, 0.1)

    function this:SetPadding(x, y)
        local spacingx, spacingy = x, y or x
        local x0, x1, y0, y1 = -spacingx, spacingx, -spacingy, spacingy
        for i = 1, 4 do
            local xo = (i == 1 or i == 3) and -1/8 or 1/8
            local yo = (i == 1 or i == 2) and 1/8 or -1/8
            local px = (i == 1 or i == 3) and x0 or x1
            local py = (i == 1 or i == 2) and y1 or y0
            this.c[i]:SetPoint(corners[i][2], this, xo * size + px, yo * size + py)
        end
    end

    return this
end