---@param item1 cc.item
---@param item2 cc.item
---@return boolean
local function sortItemCountAsc(item1, item2)
    return item1.count < item2.count
end

---@param item1 cc.item
---@param item2 cc.item
---@return boolean
local function sortItemCountDesc(item1, item2)
    return item1.count > item2.count
end

---@param item1 cc.item
---@param item2 cc.item
---@return boolean
local function sortItemNameAsc(item1, item2)
    return item1.displayName:lower() < item2.displayName:lower()
end

---@param item1 cc.item
---@param item2 cc.item
---@return boolean
local function sortItemNameDesc(item1, item2)
    return item1.displayName:lower() > item2.displayName:lower()
end

local metricSuffixes = {"K", "M", "T", "P"}

---@param value number
---@return string
local function metricString(value)
    local suffixIndex = 0
    while value > 1000 do
        value = value / 1000
        suffixIndex = suffixIndex + 1
    end

    if suffixIndex == 0 then
        return tostring(value)
    end
    return string.format("%.1f%s", value, metricSuffixes[suffixIndex])
end

---@param items table<string, cc.item>|cc.item[]
---@param asc? boolean
---@param sortCount? boolean
---@return string[]
local function itemStrings(items, asc, sortCount)
    if asc == nil then
        asc = false
    end
    if sortCount == nil then
        sortCount = true
    end

    local itemList = {}
    if #items > 0 then
        itemList = items
    else
        for _, item in pairs(items) do
            itemList[#itemList + 1] = item
        end
    end
    ---@cast itemList cc.item[]

    if sortCount then
        if asc then
            table.sort(itemList, sortItemCountAsc)
        else
            table.sort(itemList, sortItemCountDesc)
        end
    else
        if asc then
            table.sort(itemList, sortItemNameAsc)
        else
            table.sort(itemList, sortItemNameDesc)
        end
    end


    local strings = {}
    for _, item in ipairs(itemList) do
        strings[#strings + 1] = string.format(
            "%5sx %s", metricString(item.count), item.displayName
        )
    end

    return strings
end

local h = {}

h.metricString = metricString
h.itemStrings = itemStrings

return h
