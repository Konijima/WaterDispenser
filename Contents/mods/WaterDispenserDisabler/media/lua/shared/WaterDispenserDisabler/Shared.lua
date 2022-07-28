
if getActivatedMods():contains("WaterDispenser") then
    print("Water Dispenser Disabler is not running, disable WaterDispenser mod first!");
    return;
end

print("Water Dispenser Disabler is running!");

local vanillaDispensers = {
    N = "location_business_office_generic_01_57",
    E = "location_business_office_generic_01_48",
    S = "location_business_office_generic_01_49",
    W = "location_business_office_generic_01_56"
}

---@param square IsoGridSquare
local function GetInvalidDispenserOnSquare(square)
    if square then
        local objects = square:getObjects();
        for i=1, objects:size()-1 do
            ---@type IsoObject
            local isoObject = objects:get(i);
            if isoObject:getModData().waterDispenserInfo then
                return isoObject;
            end
        end
    end
end

---@param _square IsoGridSquare
local function onLoadGridsquare( _square )
    local dispenser = GetInvalidDispenserOnSquare(_square);

    --- Convert custom dispenser into vanilla
    if dispenser then
        local modData = dispenser:getModData();
        local info = modData.waterDispenserInfo;
        local waterAmount = modData.waterAmount;
        dispenser:setSpriteFromName(vanillaDispensers[info.facing]);
        modData.waterAmount = waterAmount;      -- set water amount
        modData.taintedWater = nil;             -- unset tainted water
        modData.waterDispenserInfo = nil;       -- unset water dispenser info
        if isServer() then
            dispenser:transmitUpdatedSpriteToClients();
            dispenser:transmitModData();
        end
        print("Restored custom water dispenser at [x:" .. dispenser:getX() .. " y:" .. dispenser:getY() .. " z:" .. dispenser:getZ() .. "]");
    end
end
Events.LoadGridsquare.Add(onLoadGridsquare);
