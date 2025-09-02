-- Split Party Frames Addon (Safe Version)
local E, L, V, P, G = unpack(ElvUI)
local SP = E:NewModule("SplitPartyFrames", "AceEvent-3.0", "AceHook-3.0")

-- Profile defaults
P.splitPartyFrames = { enabled = true }

local holders = {}
local created = false
local applyPending = false

-- Utility to get party button
local function partyButton(i)
    return _G["ElvUF_PartyGroup1UnitButton"..i]
end

-- Helper to get the party frame size safely
local function GetPartyFrameSize()
    local template = partyButton(1)
    local width

    local UF = E:GetModule("UnitFrames", true)
    local width, height

    if UF and UF.db and UF.db.units and UF.db.units.party then
        width  = UF.db.units.party.width  or 120
        height = UF.db.units.party.height or 36
    else
        width, height = 120, 36
    end

    return width, height
end

-- Create holders and movers
local function ensureHolders()
    for i = 1, 5 do
        if not holders[i] then
            local holder = CreateFrame("Frame", "SPP_PartyHolder"..i, E.UIParent)
            holder:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- temporary anchor
            holders[i] = holder

            E:CreateMover(holder, "SPP_PartyHolder"..i.."Mover", ("Party %d"):format(i))
        end

        -- Always update the size when called
        holders[i]:SetSize(GetPartyFrameSize())
    end
end

-- Re-anchor party buttons to holders when they are actually shown
function SP:Reanchor()
    if not E.db.splitPartyFrames.enabled then return end
    if InCombatLockdown() then applyPending = true return end

    for i = 1, 5 do
        local btn = partyButton(i)
        local holder = holders[i]

        if btn and holder and btn:IsVisible() then
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
        end
    end
end

function SP:PLAYER_REGEN_ENABLED()
    if applyPending then
        applyPending = false
        self:Reanchor()
    end
end

-- Hide the default party mover
function SP:HideDefaultPartyMover()
    local defaultMoverTable = E.CreatedMovers["ElvUF_PartyMover"]
    if defaultMoverTable and defaultMoverTable.mover then
        local moverFrame = defaultMoverTable.mover
        moverFrame:Hide()
        moverFrame:SetScript("OnShow", moverFrame.Hide)
    end
end

local function SetPartyOptionsDisabled(party, sppEnabled) 
    -- Gray out positionin options when enabled
    party.args.positionsGroup.args.growthDirection.disabled = sppEnabled
    party.args.positionsGroup.args.horizontalSpacing.disabled = sppEnabled
    party.args.positionsGroup.args.verticalSpacing.disabled = sppEnabled
    party.args.sortingGroup.disabled = sppEnabled
end

-- Add our checkbox and gray out positionin controls
local function InjectPartyOptions()
    local party = E.Options.args.unitframe.args.groupUnits.args.party.args.generalGroup
    if not party or not party.args then return end

    SetPartyOptionsDisabled(party, E.db.splitPartyFrames.enabled)

    -- Add our toggle if not already present
    if type(party.args.positionsGroup.args.splitPartyFramesEnable) ~= "table" then
        party.args.positionsGroup.args.splitPartyFramesEnable = {
            order = 1,
            type = "toggle",
            width = "full",
            name = L["Position Party Frames Individually"],
            desc = "Move each party frame individually, rather than as a group.",
            get = function(info) return E.db.splitPartyFrames.enabled end,
            set = function(info, value)
                E.db.splitPartyFrames.enabled = value
                SetPartyOptionsDisabled(party, value)
                E:StaticPopup_Show("CONFIG_RL")
            end,
        }
    end
end

function SP:Initialize()
    -- assume it's enabled if this is our first time loading the extension
    if E.db.splitPartyFrames.enabled == nil then E.db.splitPartyFrames.enabled = P.splitPartyFrames.enabled end 
    
    -- Register to inject options when config loads
    self:RegisterEvent("ADDON_LOADED", function(_, addon)
        if addon == "ElvUI_Options" then
            InjectPartyOptions()
        end
    end)

    if not E.db.splitPartyFrames.enabled then return end

    ensureHolders()

    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "Reanchor")

    -- Hook ElvUI party frame updates
    local UF = E:GetModule("UnitFrames", true)
    if UF then
        -- Only re-anchor after ElvUI updates frames (including Display Frames)
        self:SecureHook(UF, "Update_PartyFrames", function()
            SP:Reanchor()
        end)

        self:SecureHook(UF, "CreateAndUpdateHeaderGroup", function(_, group)
            if group == "party" then 
                SP:Reanchor()     
            end
        end)
    end

    hooksecurefunc(E, "ToggleMovers", function(show)
        if show and SP then
            ensureHolders()
            SP:HideDefaultPartyMover()
        end
    end)

    
end

E:RegisterModule(SP:GetName())