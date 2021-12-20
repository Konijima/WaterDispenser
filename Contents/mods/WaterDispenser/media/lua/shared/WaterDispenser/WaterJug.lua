require 'ISBaseObject';

---@class WaterJug
local WaterJug = ISBaseObject:derive("WaterJug");

WaterJug.Items = {
    Module = "WaterDispenser",
    Empty = "WaterJugEmpty",
    WaterFull = "WaterJugWaterFull"
}

--- Get a waterjug instance from an item
---@param item InventoryItem
function WaterJug.GetFromItem(item)
    if instanceof(item, "InventoryItem") then
        if item:getFullType() == WaterJug.Items.Module .. "." .. WaterJug.Items.Empty or item:getFullType() == WaterJug.Items.Module .. "." .. WaterJug.Items.WaterFull then
            return WaterJug:new(item);
        end
    end
    return nil
end

--- Get all waterjug in an inventory container
---@param inventory ItemContainer
function WaterJug.GetAllFromInventory(inventory)
    local resultObjects = ArrayList.new();

    if instanceof(inventory, "ItemContainer") then
        local inventoryItems = inventory:getItems();
        for i=0, inventoryItems:size()-1 do
            local waterJugItem = WaterJug.GetFromItem(inventoryItems:get(i))
            if waterJugItem then
                resultObjects:add(waterJugItem);
            end
        end
    end

    return resultObjects
end

--- Get all waterjug on a square
---@param square IsoGridSquare
function WaterJug.GetAllFromSquare(square)
    local resultObjects = ArrayList.new();

    if instanceof(square, "IsoGridSquare") then
        local squareObjects = square:getObjects();
        for i=0, squareObjects:size()-1 do
            ---@type IsoWorldInventoryObject
            local obj = squareObjects:get(i);
            if instanceof(obj, "IsoWorldInventoryObject") then
                local waterJugItem = WaterJug.GetFromItem(obj:getItem())
                if waterJugItem then
                    resultObjects:add(waterJugItem);
                end
            end
        end
    end

    return resultObjects
end

--- Create an item to add to an inventory
function WaterJug.Create(usedDelta, tainted)
    local item = InventoryItemFactory.CreateItem(WaterJug.Items.Module .. "." .. WaterJug.Items.Empty);
    local waterJug = WaterJug.GetFromItem(item);
    waterJug:setUsedDelta(usedDelta);
    waterJug:setTainted(tainted);
    return waterJug;
end

--- Check if it's full (sprite only)
function WaterJug:isFull()
    return self.item:getFullType() == WaterJug.Items.Module .. "." .. WaterJug.Items.WaterFull;
end

--- Check if it's empty (sprite only)
function WaterJug:isEmpty()
    return self.item:getFullType() == WaterJug.Items.Module .. "." .. WaterJug.Items.Empty;
end

--- Check if it's tainted
function WaterJug:isTainted()
    return instanceof(self.item, "DrainableComboItem") and self.item:isTaintedWater();
end

--- Check fill the max useddelta
function WaterJug:fill()
    if self.item:isEquipped() then return; end

    if self:isEmpty() then
        self:replace(WaterJug.Items.WaterFull);
    else
        self.item:setUsedDelta(1);
    end
end

function WaterJug:getUsedDelta()
    if self:isEmpty() then
        return 0;
    else
        return self.item:getUsedDelta();
    end
end

--- Set the used delta
function WaterJug:setUsedDelta(usedDelta)
    if self.item:isEquipped() then return; end

    if usedDelta > 0 then
        if self:isEmpty() then
            self:replace(WaterJug.Items.WaterFull);
        end

        self.item:setUsedDelta(usedDelta);
    else
        self:replace(WaterJug.Items.Empty);
    end
end

--- Set tainted
function WaterJug:setTainted(isTainted)
    if self:isFull() then
        isTainted = isTainted == true;
        self.item:setTaintedWater(isTainted);
    end
end

--- Empty the waterjug
function WaterJug:empty()
    if self.item:isEquipped() then return; end

    if not self:isEmpty() then
        self:replace(WaterJug.Items.Empty);
    end
end

--- Replace the item
function WaterJug:replace(newType)
    if self.item:isEquipped() then return; end

    ---@type IsoWorldInventoryObject
    local worldObject = self.item:getWorldItem();

    local newItem = InventoryItemFactory.CreateItem(WaterJug.Items.Module .. "." .. newType);

    if worldObject then
        worldObject:swapItem(newItem);
    else
        ---@type ItemContainer
        local container = self.item:getContainer();
        if container then
            container:Remove(self.item);
            container:AddItem(newItem);
        end
    end

    self.item = newItem;
end

--- Delete the item
function WaterJug:delete()
    --- Unequip
    if self.item:isEquipped() then
        local character = self.item:getEquipParent();
        if self.item == character:getPrimaryHandItem() then
            if (self.item:isTwoHandWeapon() or self.item:isRequiresEquippedBothHands()) and self.item == character:getSecondaryHandItem() then
                character:setSecondaryHandItem(nil);
            end
            character:setPrimaryHandItem(nil);
        end
        if self.item == character:getSecondaryHandItem() then
            if (self.item:isTwoHandWeapon() or self.item:isRequiresEquippedBothHands()) and self.item == character:getPrimaryHandItem() then
                character:setPrimaryHandItem(nil);
            end
            character:setSecondaryHandItem(nil);
        end
    end

    ---@type IsoWorldInventoryObject
    local worldObject = self.item:getWorldItem();

    if worldObject then
        worldObject:removeFromSquare();
    end
    self.item:getContainer():Remove(self.item);
    self = nil;
end

---@param item InventoryItem
function WaterJug:new(item)
    local o = {};
    setmetatable(o, self);
    self.__index = self;

    o.item = item;

    return o;
end

return WaterJug;
