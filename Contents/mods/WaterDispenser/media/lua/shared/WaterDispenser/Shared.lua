local WaterDispenser = require("WaterDispenser/WaterDispenser");

---@param _square IsoGridSquare
local function onLoadGridsquare( _square )
    local dispenser = WaterDispenser.GetVanillaDispenserOnSquare(_square);

    --- Convert original dispenser
    if dispenser then
        dispenser:transform("Water");
        dispenser:setAmount(ZombRand(50, 250));
        dispenser:setTainted(false);
    end
end
Events.LoadGridsquare.Add(onLoadGridsquare);

local function onWaterAmountChange(object, prevAmount)
    local square = getCell():getGridSquare(object:getX(), object:getY(), object:getZ())
    local dispenser = WaterDispenser.GetFromSquare(square);
    if dispenser and dispenser:getAmount() < 1 then
        dispenser:transform("Empty");
        print("Dispenser should be empty!");
    end
end
Events.OnWaterAmountChange.Add(onWaterAmountChange)