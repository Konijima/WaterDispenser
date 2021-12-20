require "TimedActions/ISBaseTimedAction";
local WaterJug = require("WaterDispenser/WaterJug");

---@class TakeWaterJugFromDispenser : ISBaseTimedAction
local TakeWaterJugFromDispenser = ISBaseTimedAction:derive("TakeWaterJugFromDispenser");

function TakeWaterJugFromDispenser:isValid()
    return self.waterDispenser.isoObject ~= nil and not self.waterDispenser:isNone();
end

function TakeWaterJugFromDispenser:update()
    self.character:faceThisObject(self.waterDispenser.isoObject);
    self.character:setMetabolicTarget(Metabolics.LightDomestic);
end

function TakeWaterJugFromDispenser:start()
    self:setActionAnim("Loot");
end

function TakeWaterJugFromDispenser:stop()
    ISBaseTimedAction.stop(self);
end

function TakeWaterJugFromDispenser:perform()
    local waterJug = WaterJug.Create(self.waterDispenser:getAmount() / 250, self.waterDispenser:isTainted());
    self.inventory:addItem(waterJug.item);

    local args = {
        x = self.waterDispenser.isoObject:getX(),
        y = self.waterDispenser.isoObject:getY(),
        z = self.waterDispenser.isoObject:getZ(),
    };
    sendClientCommand(self.character, 'WaterDispenser', 'TakeBottle', args);

    ISBaseTimedAction.perform(self);
end

---@param character IsoPlayer
---@param waterDispenser WaterDispenser
function TakeWaterJugFromDispenser:new(character, waterDispenser)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = 20 + 280 * (waterDispenser:getAmount() / 250);
    -- custom fields
    o.inventory = character:getInventory();
    o.waterDispenser = waterDispenser;
    return o;
end

return TakeWaterJugFromDispenser;
