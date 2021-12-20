require "TimedActions/ISBaseTimedAction";

---@class PlaceWaterJugOnDispenser : ISBaseTimedAction
local PlaceWaterJugOnDispenser = ISBaseTimedAction:derive("PlaceWaterJugOnDispenser");

function PlaceWaterJugOnDispenser:isValid()
    return self.waterDispenser.isoObject ~= nil and self.waterDispenser:isNone() and self.inventory:contains(self.waterJug.item);
end

function PlaceWaterJugOnDispenser:update()
    self.waterJug.item:setJobDelta(self:getJobDelta());
    self.character:faceThisObject(self.waterDispenser.isoObject);
    self.character:setMetabolicTarget(Metabolics.LightDomestic);
end

function PlaceWaterJugOnDispenser:start()
    self.waterJug.item:setJobType("Placing");
    self.waterJug.item:setJobDelta(0.0);
    self:setActionAnim("Loot");
end

function PlaceWaterJugOnDispenser:stop()
    ISBaseTimedAction.stop(self);
    self.waterJug.item:setJobDelta(0.0);
end

function PlaceWaterJugOnDispenser:perform()
    self.waterJug.item:setJobDelta(0.0);

    local args = {
        x = self.waterDispenser.isoObject:getX(),
        y = self.waterDispenser.isoObject:getY(),
        z = self.waterDispenser.isoObject:getZ(),
        amount = 250 * self.waterJug:getUsedDelta(),
        tainted = self.waterJug:isTainted()
    };
    sendClientCommand(self.character, 'WaterDispenser', 'PlaceBottle', args);

    self.waterJug:delete();

    ISBaseTimedAction.perform(self);
end

---@param character IsoPlayer
---@param waterJug WaterJug
---@param waterDispenser WaterDispenser
function PlaceWaterJugOnDispenser:new(character, waterDispenser, waterJug)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = 20 + 280 * (waterJug:getUsedDelta());
    -- custom fields
    o.inventory = character:getInventory();
    o.waterDispenser = waterDispenser;
    o.waterJug = waterJug;
    return o;
end

return PlaceWaterJugOnDispenser;
