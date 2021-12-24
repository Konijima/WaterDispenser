local WaterJug = require("WaterDispenser/WaterJug");
local WaterDispenser = require("WaterDispenser/WaterDispenser");
local PlaceWaterJugOnDispenser = require("WaterDispenser/Actions/PlaceWaterJugOnDispenser");
local TakeWaterJugFromDispenser = require("WaterDispenser/Actions/TakeWaterJugFromDispenser");

---@param dispenser WaterDispenser
---@param waterJug WaterJug
local function insert(playerObj, dispenser, waterJug)
    if luautils.walkAdj(playerObj, clickedSquare) then
        ISTimedActionQueue.add(PlaceWaterJugOnDispenser:new(playerObj, dispenser, waterJug))
    end
end

---@param dispenser WaterDispenser
local function remove(playerObj, dispenser)
    if luautils.walkAdj(playerObj, clickedSquare) then
        ISTimedActionQueue.add(TakeWaterJugFromDispenser:new(playerObj, dispenser))
    end
end

--- OnPreFillWorldObjectContextMenu
---@param _player number
---@param _context ISContextMenu
local function OnPreFillWorldObjectContextMenu( _player, _context, _worldobjects, _test )
    if _test then return true end

    ---@type IsoPlayer
    local playerObj = getSpecificPlayer(_player);

    ---@type ItemContainer
    local playerInv = playerObj:getInventory();

    ---@type WaterDispenser
    local waterDispenser = WaterDispenser.GetFromSquare(clickedSquare);

    if waterDispenser then

        local playerWaterJugs = WaterJug.GetAllFromInventory(playerInv);

        local objectInfo = WaterDispenser.GetObjectInfo(waterDispenser.isoObject);

        --- Main Option Tooltip
        if playerObj:DistToSquared(waterDispenser.isoObject:getX() + 0.5, waterDispenser.isoObject:getY() + 0.5) < 2 * 2 then
            local titleOption = _context:addOption(getText("ContextMenu_Water_Dispenser"));
            local tooltip = ISToolTip:new();
            tooltip:setName(getText("ContextMenu_Water_Dispenser"));
            local tx = getTextManager():MeasureStringX(tooltip.font, getText("ContextMenu_WaterName") .. ":") + 20
            tooltip.description = string.format("%s: <SETX:%d> %d / %d", getText("ContextMenu_WaterName"), tx, waterDispenser:getAmount(), 250);
            if waterDispenser:isTainted() then
                tooltip.description = tooltip.description .. " <BR> <RGB:1,0.5,0.5> " .. getText("Tooltip_item_TaintedWater");
            end
            tooltip.maxLineWidth = 512;
            titleOption.toolTip = tooltip;
        end

        --- Main Context Menu Options
        if objectInfo.type == "Water" or objectInfo.type == "Empty" then
            _context:addOption(getText("ContextMenu_TakeBottleFromDispenser"), playerObj, remove, waterDispenser);

        elseif objectInfo.type == "None" then
            if playerWaterJugs:size() > 0 then
                local option = _context:addOption(getText("ContextMenu_PlaceOnDispenser"));
                local subContext = ISContextMenu:getNew(_context);
                _context:addSubMenu(option, subContext);
                for i=0, playerWaterJugs:size()-1 do
                    ---@type WaterJug
                    local waterJug = playerWaterJugs:get(i);
                    local subOption = subContext:addOption(waterJug.item:getName(), playerObj, insert, waterDispenser, waterJug);
                    local tooltip = ISToolTip:new();
                    local tx = getTextManager():MeasureStringX(tooltip.font, getText("ContextMenu_WaterName") .. ":") + 20
                    tooltip.description = string.format("%s: <SETX:%d> %d / %d", getText("ContextMenu_WaterName"), tx, 250 * waterJug:getUsedDelta(), 250);
                    if waterJug:isTainted() then
                        tooltip.description = tooltip.description .. " <BR> <RGB:1,0.5,0.5> " .. getText("Tooltip_item_TaintedWater");
                    end
                    tooltip.maxLineWidth = 512;
                    subOption.toolTip = tooltip;
                end
            end
        end

        --- DEBUG CONTEXT
        --if isDebugEnabled() then
        --    local option = _context:addOption("[DEBUG] Water Dispenser");
        --    local subContext = ISContextMenu:getNew(_context);
        --    _context:addSubMenu(option, subContext);
        --
        --    subContext:addOption("Set sprite to none", waterDispenser, waterDispenser.transform, "None");
        --    subContext:addOption("Set sprite to empty", waterDispenser, waterDispenser.transform, "Empty");
        --    subContext:addOption("Set sprite to water", waterDispenser, waterDispenser.transform, "Water");
        --    subContext:addOption("Set sprite to vanilla", waterDispenser, waterDispenser.transform, "Vanilla");
        --    subContext:addOption("Set amount full", waterDispenser, waterDispenser.setAmount, 250);
        --    subContext:addOption("Set amount empty", waterDispenser, waterDispenser.setAmount, 0);
        --    subContext:addOption("Set clean", waterDispenser, waterDispenser.setTainted, false);
        --    subContext:addOption("Set tainted", waterDispenser, waterDispenser.setTainted, true);
        --end
    end

end

--- OnPreFillInventoryObjectContextMenu
---@param _player number
---@param _context ISContextMenu
local function OnPreFillInventoryObjectContextMenu( _player, _context, _items )

    --- DEBUG CONTEXT
    if isDebugEnabled() then

        ---@param items ArrayList
        local function fill(items)
            for i=0, items:size()-1 do
                items:get(i):setUsedDelta(1);
            end
        end

        ---@param items ArrayList
        local function empty(items)
            for i=0, items:size()-1 do
                items:get(i):empty();
            end
        end

        ---@param items ArrayList
        local function clean(items)
            for i=0, items:size()-1 do
                items:get(i):setTainted(false);
            end
        end

        ---@param items ArrayList
        local function taint(items)
            for i=0, items:size()-1 do
                items:get(i):setTainted(true);
            end
        end

        ---@param items ArrayList
        local function delete(items)
            for i=0, items:size()-1 do
                items:get(i):delete();
            end
        end

        local selectedWaterJugs = ArrayList.new();
        for _, k in pairs(_items) do
            if not instanceof(k, "InventoryItem") then
                for i2, k2 in ipairs(k.items) do
                    if i2 ~= 1 then
                        local waterJugItem = WaterJug.GetFromItem(k2);
                        if waterJugItem then
                            selectedWaterJugs:add(waterJugItem);
                        end
                    end
                end
            else
                local waterJugItem = WaterJug.GetFromItem(k);
                if waterJugItem then
                    selectedWaterJugs:add(waterJugItem);
                end
            end
        end

        local selectedCount = selectedWaterJugs:size();
        if selectedCount > 0 then
            local option = _context:addOption("[DEBUG] WaterJug");
            local subContext = ISContextMenu:getNew(_context);
            _context:addSubMenu(option, subContext);

            subContext:addOption("Fill " .. selectedCount .. " WaterJug", selectedWaterJugs, fill);
            subContext:addOption("Empty " .. selectedCount .. " WaterJug", selectedWaterJugs, empty);
            subContext:addOption("Clean " .. selectedCount .. " WaterJug", selectedWaterJugs, clean);
            subContext:addOption("Taint " .. selectedCount .. " WaterJug", selectedWaterJugs, taint);
            subContext:addOption("Delete " .. selectedCount .. " WaterJug", selectedWaterJugs, delete);
        end
    end

end

Events.OnPreFillWorldObjectContextMenu.Add(OnPreFillWorldObjectContextMenu);
Events.OnPreFillInventoryObjectContextMenu.Add(OnPreFillInventoryObjectContextMenu);
