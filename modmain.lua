-- DST Sophisticated Backpacks v0.2.0
-- Backpack upgrade kits consume ONLY ordinary, carryable materials.
-- The old backpack is consumed separately via USEITEMON on a dropped backpack.
PrefabFiles = { "sb_backpacks" }

local G = GLOBAL
local defs = require("sb_backpack_defs")
local containers = G.require("containers")
local Vector3 = G.Vector3

local MODULE_TAG = "sb_upgrade_module"
local COLUMN_COUNT = 8
local SLOT_STEP = 66

for _, def in ipairs(defs) do
    local positions = {}
    local rows = math.ceil(def.storage / COLUMN_COUNT)
    local top_y = ((rows - 1) * SLOT_STEP) / 2 + 25
    local left_x = -528
    for index = 1, def.storage do
        local column = (index - 1) % COLUMN_COUNT
        local row = math.floor((index - 1) / COLUMN_COUNT)
        positions[#positions + 1] = Vector3(left_x + column * SLOT_STEP, top_y - row * SLOT_STEP, 0)
    end
    local module_y = top_y - rows * SLOT_STEP - 12
    for index = 1, def.modules do
        positions[#positions + 1] = Vector3(left_x + (index - 1) * SLOT_STEP, module_y, 0)
    end

    local storage = def.storage
    containers.params[def.prefab] = {
        widget = {
            slotpos = positions,
            animbank = "ui_piggyback_2x6",
            animbuild = "ui_piggyback_2x6",
            pos = Vector3(-5, -65, 0),
            side_align_tip = 120,
        },
        issidewidget = true,
        type = "pack",
        openlimit = 1,
        itemtestfn = function(container, item, slot)
            if item == nil then
                return false
            end
            if slot == nil then
                return true
            end
            if slot > storage then
                return item:HasTag(MODULE_TAG)
            end
            return not item:HasTag(MODULE_TAG)
        end,
    }
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS or 0, #positions)
end

G.SB_BACKPACK_SPEED_MULT = GetModConfigData("speed_mult") or 1

for _, def in ipairs(defs) do
    local backpack_key = string.upper(def.prefab)
    local kit_prefab = "sb_upgrade_kit_lv" .. tostring(def.level)
    local kit_key = string.upper(kit_prefab)

    G.STRINGS.NAMES[backpack_key] = string.format("精妙背包 LV%d", def.level)
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[backpack_key] = string.format(
        "可存放 %d 格物品，拥有 %d 个模块插槽。", def.storage, def.modules
    )

    G.STRINGS.NAMES[kit_key] = string.format("精妙背包 LV%d 升级包", def.level)
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[kit_key] = string.format(
        "将它用在放置于地面的 %s 上，升级为 LV%d。", 
        def.level == 1 and "猪皮包" or ("LV" .. tostring(def.level - 1) .. " 精妙背包"),
        def.level
    )
    G.STRINGS.RECIPE_DESC[kit_key] = string.format(
        "需放置旧背包：%s · %d 格 + %d 模块槽",
        def.level == 1 and "猪皮包" or ("LV" .. tostring(def.level - 1)),
        def.storage, def.modules
    )

    -- The old bag CANNOT enter player inventory, so exclude it from Ingredient().
    -- It is instead the targeted world entity consumed when using the kit.
    local ingredients = {}
    for _, ingredient in ipairs(def.ingredients) do
        if ingredient[1] ~= def.previous then
            ingredients[#ingredients + 1] = Ingredient(ingredient[1], ingredient[2])
        end
    end

    AddRecipe2(
        kit_prefab,
        ingredients,
        G.TECH.SCIENCE_TWO,
        {
            atlas = G.GetInventoryItemAtlas("piggyback.tex"),
            image = "piggyback.tex",
            nounlock = false,
        },
        { "CLOTHING", "CONTAINERS" }
    )
end
