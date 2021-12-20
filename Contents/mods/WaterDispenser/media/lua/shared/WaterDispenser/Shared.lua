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
