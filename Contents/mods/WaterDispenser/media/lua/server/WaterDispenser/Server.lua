local WaterDispenser = require("WaterDispenser/WaterDispenser");

--- Water Dispenser Commands
local Commands = {};
Commands.WaterDispenser = {};

--- On Command Place Bottle
function Commands.WaterDispenser.PlaceBottle(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z);
    if sq ~= nil then
        local waterDispenser = WaterDispenser.GetFromSquare(sq);
        if waterDispenser then
            if args.amount < 1 then
                waterDispenser:transform("Empty");
                waterDispenser:setAmount(0);
                waterDispenser:setTainted(false);
            else
                waterDispenser:transform("Water");
                waterDispenser:setAmount(args.amount);
                waterDispenser:setTainted(args.tainted);
            end
        end
    end
end

--- On Command Take Bottle
function Commands.WaterDispenser.TakeBottle(player, args)
    local sq = getCell():getGridSquare(args.x, args.y, args.z);
    if sq ~= nil then
        local waterDispenser = WaterDispenser.GetFromSquare(sq);
        if waterDispenser then
            waterDispenser:transform("None");
            waterDispenser:setAmount(0);
            waterDispenser:setTainted(false);
        end
    end
end

--- On Client Command Received
local function onClientCommand(module, command, player, args)
    if Commands[module] and Commands[module][command] then
        local argStr = ''
        for k,v in pairs(args) do argStr = argStr..' '..k..'='..tostring(v) end
        Commands[module][command](player, args)
    end
end
Events.OnClientCommand.Add(onClientCommand);

--- On Water Amount Changed
local function onWaterAmountChange(object, prevAmount)
    local square = getCell():getGridSquare(object:getX(), object:getY(), object:getZ())
    local dispenser = WaterDispenser.GetFromSquare(square);
    if dispenser and not dispenser:isNone() and dispenser:getAmount() < 1 then
        dispenser:transform("Empty");
        print("Dispenser should be empty!");
    end
end
Events.OnWaterAmountChange.Add(onWaterAmountChange);