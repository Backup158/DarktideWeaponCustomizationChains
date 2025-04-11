local mod = get_mod("weapon_customization_chains")
mod.version = "1.2.1"

-- Variables from the EWC Template
local table = table
local ipairs = ipairs
local pairs = pairs
local vector3_box = Vector3Box

local _item = "content/items/weapons/player"
local _item_ranged = _item.."/ranged"
local _item_melee = _item.."/melee"
local _item_minion = "content/items/weapons/minions"
-- End EWC Template vars

-- Prepend function from EWC Template
table.prepend = function(t1, t2)
    for i, d in ipairs(t2) do
        table.insert(t1, i, d)
    end
end

-- Returns names of melee weapons
function mod.get_weapons()
    return {
        -- Head
        "combataxe_p1_m1",
        "combataxe_p2_m1",
        "combataxe_p3_m1",
        "ogryn_club_p1_m1",
        "ogryn_pickaxe_2h_p1_m1",
        "ogryn_powermaul_p1_m1",
        "ogryn_powermaul_slabshield_p1_m1",
        "powermaul_2h_p1_m1",
        "powermaul_p1_m1",
        "thunderhammer_2h_p1_m1",
        -- Blade
        --"forcesword_2h_p1_m1", -- Not supported yet
        "forcesword_p1_m1",
        "ogryn_combatblade_p1_m1",
        --"powersword_2h_p1_m1", -- Not supported yet
        "powersword_p1_m1",
        -- Body
        --"chainaxe_p1_m1", -- Already has chains
        --"chainsword_2h_p1_m1", -- Already has chains
        --"chainsword_p1_m1", -- Already has chains
        "combatknife_p1_m1",
        "combatsword_p1_m1",
        "combatsword_p2_m1",
        "combatsword_p3_m1",
        "ogryn_club_p2_m1",
	}
end

-- Function Execution
function mod.on_all_mods_loaded()
    mod:info("WeaponCustomizationChains v" .. mod.version .. " loaded uwu nya :3")

    -- Checks for other mods loaded
    local wc = get_mod("weapon_customization")
    if not wc then
		mod:error("Extended Weapon Customization mod is required")
		return
	end
    local mt = get_mod("weapon_customization_mt_stuff")
    if mt then
        mod:info("User has MT Plugin uwu nya :3")
    end

    local showWarningMT = mod:get("show_warning_mt")
    if showWarningMT and not mt then
        mod:echo_localized("warning_mt")
    end

    local command_mt = mod:localize("ack_mt_description")
    mod:command("ack_mt", command_mt, function ()
        mod:set("show_warning_mt", false, false)
    end)

    -- Initializing data before injection
    local debug = mod:get("enable_debug_mode")
    local weaponClasses = mod:get_weapons()

    -- ####################################################################
    -- ATTACHMENT CREATION AND INJECTION
    -- See the EWC Template plugin (pinned in the Darktide Modder's Discord EWC Channel) for details
    -- Note about the table existence checks:
    --  In the base mod, there are some exceptions the typical weapon file structure
    --  The tactical axe marks 2 and 3 do not copy the attachment_models from tactical axe m1, but from combat axe m1 (weapon_customization_anchors.lua)
    --  In the weapon attachment files, some weapons are missing anchors.fixes table
    --      Tactical Axe, Sapper Shovel, Delver's Pickaxe, Crusher
    --      which are: combataxe_p2_m1, combataxe_p3_m1, ogryn_pickaxe_2h_p1_m1, powermaul_2h_p1_m1
    --      The MT plugin creates these, if you have it installed.
    -- ####################################################################
    -- Loops over all relevant melee weapons
    for _, weaponClass in ipairs(weaponClasses) do
        -- ####################################################################
        -- CREATING THE ATTACHMENT SLOTS
        --  The Chain slot already exists in the base plugin. It is equipped in the chain weapons (shocking!).
        --  Because I excluded those from weaponClasses, I can create the slot for the other weapons without worrying about overwriting them.
        --  That also means it's already localized.
        -- ####################################################################
        wc.attachment[weaponClass].chain = {}
        -- ########################################
        -- Inject attachment definition
        -- ########################################
        if (type(wc.attachment[weaponClass].chain) == "table") then
            if debug then mod:info("Table found: wc.attachment."..weaponClass..".chain") end
        else
            if debug then mod:error("!!! Chains is in a pickle! Could not find table: wc.attachment."..weaponClass..".chain") end
            wc.attachment[weaponClass].chain = {}
        end
        -- First time creating chains for these, so I need a default unequipped
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_default", name = mod:localize("attachment_name_default"), no_randomize = false}
        )
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_chainaxe", name = mod:localize("attachment_name_chainaxe"), no_randomize = true}
        )
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_chainaxe_gold", name = mod:localize("attachment_name_chainaxe_gold"), no_randomize = true}
        )
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_1h_chain_sword", name = mod:localize("attachment_name_1h_chainsword"), no_randomize = true}
        )
        --table.insert(
        --    wc.attachment[weaponClass].chain,
        --    {id = "chain_1h_chain_sword_gold", name = "1h Chain Sword Chain (Gold)", no_randomize = true}
        --)
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_2h_chain_sword", name = mod:localize("attachment_name_2h_chainsword"), no_randomize = true}
        )
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_2h_chain_sword_gold", name = mod:localize("attachment_name_2h_chainsword_gold"), no_randomize = true}
        )
        -- ########################################
        -- Inject attachment model
        -- ########################################
        if (type(wc.attachment_models[weaponClass]) == "table") then
            if debug then mod:info("Table found: wc.attachment_models."..weaponClass) end
        else
            if debug then mod:error("!!! Chains is in a pickle! Could not find table: wc.attachment."..weaponClass) end
            wc.attachment_models[weaponClass] = {}
        end
        --if (weaponClass == "forcesword_p1_m1") or (weaponClass == "forcesword_2h_p1_m1") or (weaponClass == "ogryn_combatblade_p1_m1") or (weaponClass == "powersword_2h_p1_m1") or (weaponClass == "powersword_p1_m1") then
        if (weaponClass == "forcesword_p1_m1") or (weaponClass == "ogryn_combatblade_p1_m1") or (weaponClass == "powersword_p1_m1") then
            weaponParent = "blade"
        elseif (weaponClass == "combatknife_p1_m1") or (weaponClass == "combatsword_p1_m1") or (weaponClass == "combatsword_p2_m1") or (weaponClass == "combatsword_p3_m1") or (weaponClass == "ogryn_club_p2_m1") then
            weaponParent = "body"
        else
            weaponParent = "head"
        end
        table.merge_recursive(
            wc.attachment_models[weaponClass],
            {chain_default = {model = "", type = "chain", parent = weaponParent } }
        )
        table.merge_recursive(
            wc.attachment_models[weaponClass],
            {chain_chainaxe = {model = _item_melee.."/chains/chain_axe_chain_01", type = "chain", parent = weaponParent } }
        )
        table.merge_recursive(
            wc.attachment_models[weaponClass],
            {chain_chainaxe_gold = {model = _item_melee.."/chains/chain_axe_chain_ml01", type = "chain", parent = weaponParent } }
        )
        table.merge_recursive(
            wc.attachment_models[weaponClass],
            {chain_1h_chain_sword = {model = _item_melee.."/chains/chain_sword_chain_01", type = "chain", parent = weaponParent } }
        )
        --table.merge_recursive(
        --    wc.attachment_models[weaponClass],
        --    {chain_1h_chain_sword_gold = {model = _item_melee.."/chains/chain_sword_chain_01_gold_01", type = "chain", parent = weaponParent } }
        --)
        table.merge_recursive(
            wc.attachment_models[weaponClass],
            {chain_1h_chain_sword_gold = {model = _item_melee.."/chains/chain_sword_chain_ml01", type = "chain", parent = weaponParent } }
        )
        table.merge_recursive(
            wc.attachment_models[weaponClass],
            {chain_2h_chain_sword = {model = _item_melee.."/chains/2h_chain_sword_chain_01", type = "chain", parent = weaponParent } }
        )
        table.merge_recursive(
            wc.attachment_models[weaponClass],
            {chain_2h_chain_sword_gold = {model = _item_melee.."/chains/2h_chain_sword_chain_01_gold_01", type = "chain", parent = weaponParent } }
        )
        -- ########################################
        -- Inject fixes
        -- ########################################
        -- This is where the weapons are aligned
        -- ########################################
        if (type(wc.anchors[weaponClass].fixes) == "table") then
            if debug then mod:info("Table found: wc.anchors."..weaponClass..".fixes") end
        else
            if debug then mod:error("!!! Chains is in a pickle! Could not find table: wc.anchors."..weaponClass..".fixes") end
            wc.anchors[weaponClass].fixes = {}
        end
        -- Default case doesn't need a fix since it's invisible
        --table.prepend(
        --    wc.anchors[weaponClass].fixes, {
        --        {   dependencies =  { "chain_default" },
        --            chain =         { offset = true, position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.0, 1.0, 1.0) },
        --        },
        --    }
        --)
        table.prepend(
            wc.anchors[weaponClass].fixes, {
                {   dependencies =  { "chain_chainaxe|chain_chainaxe_gold" },
                    chain =         { offset = true, position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.0, 1.0, 1.0) },
                },
            }
        )
        table.prepend(
            wc.anchors[weaponClass].fixes, {
                {   dependencies =  { "chain_1h_chain_sword|chain_1h_chain_sword_gold" },
                    chain =         { offset = true, position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.0, 1.0, 1.0) },
                },
            }
        )
        table.prepend(
            wc.anchors[weaponClass].fixes, {
                {   dependencies =  { "chain_2h_chain_sword|chain_2h_chain_sword_gold" },
                    chain =         { offset = true, position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.0, 1.0, 1.0) },
                },
            }
        )
        -- ########################################
        -- Inject attachment
        -- ########################################
        wc.add_custom_attachments.chain = "chain_list"
        wc.chain_list = {
            "chain_default",
            "chain_chainaxe",
            "chain_chainaxe_gold",
            "chain_1h_chain_sword",
            --"chain_1h_chain_sword_gold",
            "chain_2h_chain_sword",
            "chain_2h_chain_sword_gold",
        }
    end -- Ends for loop that iterates over most melee weapons
    -- ########################################
    -- Specific Fixes
    --  These fixes are outside of the for loop, so they will only apply to the single weapon family you specify
    --  If you want the fix to apply to every weapon, put it inside the for loop (so paste the fix in the Inject Fixes section, above the "end" right here)
    --      Copy the fixes in made in that section, not the example fix below
    --      The example fix is for when you want to make a fix that only applies to one weapon
    -- ########################################
    -- Example Fix
    --  This fix is applied to the Power Sword, as indicated by the "powersword_p1_m1". To make it apply for other weapons, replace this name with the relevant weapon name (see mod.get_weapon() table)
    --  For this fix, it occurs when you have equipped the chainaxe chain AND (MT dueling sword blade 1 OR MT dueling sword blade 2)
    --table.prepend(
    --    wc.anchors.powersword_p1_m1.fixes, {
    --        {   dependencies =  { "chain_chainaxe", "sabre_mt_blade_01|sabre_mt_blade_02" },
    --            chain =         { offset = true, position = vector3_box(0.0, 2.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.0, 1.0, 1.0) },
    --        },
    --    }
    --)
end
