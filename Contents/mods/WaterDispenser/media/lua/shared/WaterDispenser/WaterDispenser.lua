require 'ISBaseObject';

---@class WaterDispenser
local WaterDispenser = ISBaseObject:derive("WaterDispenser");

WaterDispenser.ObjectTypes = {
    Vanilla = {
        N = "location_business_office_generic_01_57",
        E = "location_business_office_generic_01_48",
        S = "location_business_office_generic_01_49",
        W = "location_business_office_generic_01_56"
    },
    None = {
        N = "coco_liquid_overhaul_01_0",
        E = "coco_liquid_overhaul_01_1",
        S = "coco_liquid_overhaul_01_2",
        W = "coco_liquid_overhaul_01_3"
    },
    Empty = {
        N = "coco_liquid_overhaul_01_4",
        E = "coco_liquid_overhaul_01_5",
        S = "coco_liquid_overhaul_01_6",
        W = "coco_liquid_overhaul_01_7"
    },
    Water = {
        N = "coco_liquid_overhaul_01_8",
        E = "coco_liquid_overhaul_01_9",
        S = "coco_liquid_overhaul_01_10",
        W = "coco_liquid_overhaul_01_11"
    },
};

---@param square IsoGridSquare
function WaterDispenser.GetVanillaDispenserOnSquare(square)
    if square then
        local objects = square:getObjects();
        for i=1, objects:size()-1 do
            ---@type IsoObject
            local isoObject = objects:get(i);
            local sprite = isoObject:getSprite();
            if sprite then
                local props = sprite:getProperties();
                if props:Val("CustomName") == "Dispenser" and props:Val("GroupName") == "Water" then
                    return WaterDispenser:new(isoObject);
                end
            end
        end
    end
end

---@param isoObject IsoObject
function WaterDispenser.GetObjectInfo(isoObject)
    if isoObject then
        local sprite = isoObject:getSprite();
        if sprite then
            local objectSpriteName = sprite:getName();

            for type, v in pairs(WaterDispenser.ObjectTypes) do
                for facing, spriteName in pairs(v) do
                    if objectSpriteName == spriteName then
                        return {
                            type = type,
                            facing = facing,
                            sprite = spriteName
                        }
                    end
                end
            end
        end
    end
end

---@param square IsoGridSquare
function WaterDispenser.GetFromSquare(square)
    if square then
        local objects = square:getObjects();
        for i=0, objects:size()-1 do
            local isoObject = objects:get(i);
            local objectTypeInfo = WaterDispenser.GetObjectInfo(isoObject);
            if objectTypeInfo then
                return WaterDispenser:new(isoObject);
            end
        end
    end
end

function WaterDispenser:isNone()
    local objectInfo = WaterDispenser.GetObjectInfo(self.isoObject);
    return objectInfo.type == "None";
end

function WaterDispenser:isEmpty()
    local objectInfo = WaterDispenser.GetObjectInfo(self.isoObject);
    return objectInfo.type == "Empty";
end

function WaterDispenser:isWater()
    local objectInfo = WaterDispenser.GetObjectInfo(self.isoObject);
    return objectInfo.type == "Water";
end

function WaterDispenser:getAmount()
    local modData = self.isoObject:getModData();
    if modData.waterAmount ~= nil then
        return tonumber(modData.waterAmount)
    end
    return 0;
end

function WaterDispenser:setAmount(amount)
    local modData = self.isoObject:getModData();
    modData.waterMax = 250;
    modData.waterAmount = amount;
    if isServer() then self.isoObject:transmitModData(); end
end

function WaterDispenser:isTainted()
    local modData = self.isoObject:getModData();
    return modData.taintedWater;
end

function WaterDispenser:setTainted(isTainted)
    local modData = self.isoObject:getModData();
    modData.taintedWater = isTainted == true;
    if isServer() then self.isoObject:transmitModData(); end
end

function WaterDispenser:transform(type)
    local objectInfo = WaterDispenser.GetObjectInfo(self.isoObject);
    self.isoObject:setSpriteFromName(WaterDispenser.ObjectTypes[type][objectInfo.facing]);
    ---if isClient() then self.isoObject:transmitUpdatedSpriteToServer(); end
    if isServer() then self.isoObject:transmitUpdatedSpriteToClients(); end
end

---@param isoObject IsoObject
function WaterDispenser:new(isoObject)
    local o = {};
    setmetatable(o, self)
    self.__index = self

    o.isoObject = isoObject;

    return o;
end

return WaterDispenser;
