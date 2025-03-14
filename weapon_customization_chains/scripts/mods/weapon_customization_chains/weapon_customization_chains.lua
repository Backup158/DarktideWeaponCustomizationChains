local mod = get_mod("weapon_customization_chains")
mod.version = "1.0"

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
        -- Not Necessary
        --"chainaxe_p1_m1",
        --"chainsword_2h_p1_m1",
        --"chainsword_p1_m1",
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
        -- "forcesword_2h_p1_m1", -- Not supported yet
        "forcesword_p1_m1",
        "ogryn_combatblade_p1_m1",
        --"powersword_2h_p1_m1", -- Not supported yet
        "powersword_p1_m1",
        -- Body
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
    -- CREATING THE ATTACHMENT SLOTS
    -- ####################################################################
    for _, weapon in ipairs(weaponClasses) do
        wc.attachment[weapon].chain = {}
    end

    -- ####################################################################
    -- ATTACHMENT INJECTION
    -- See the EWC Template plugin (pinned in the Darktide Modder's Discord EWC Channel) for details
    -- ####################################################################
    -- Loops over all ranged weapons
    for _, weaponClass in ipairs(weaponClasses) do
        -- ########################################
        -- Inject attachment definition
        -- ########################################
        if debug then
            if (type(wc.attachment[weaponClass].chain) == "table") then
                mod:info("Correct table found: wc.attachment."..weaponClass..".chain")
            else
                mod:error("!!! Chains is in a pickle! Could not find table: wc.attachment."..weaponClass..".chain")
            end
        end

        -- First time creating chains for these, so I need a default unequipped
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_default", name = "Default", no_randomize = false}
        )
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_chainaxe", name = "Chain Axe Chain", no_randomize = true}
        )
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_1h_chain_sword", name = "1h Chain Sword Chain", no_randomize = true}
        )
        table.insert(
            wc.attachment[weaponClass].chain,
            {id = "chain_2h_chain_sword", name = "2h Chain Sword Chain", no_randomize = true}
        )
        -- ########################################
        -- Inject attachment model
        -- ########################################
        if debug then
            if (type(wc.attachment_models[weaponClass]) == "table") then
                mod:info("Correct table found: wc.attachment_models."..weaponClass)
            else
                mod:error("!!! Chains is in a pickle! Could not find table: wc.attachment."..weaponClass)
            end
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
            {chain_1h_chain_sword = {model = _item_melee.."/chains/chain_sword_chain_01", type = "chain", parent = weaponParent } }
        )
        table.merge_recursive(
            wc.attachment_models[weaponClass],
            {chain_2h_chain_sword = {model = _item_melee.."/chains/2h_chain_sword_chain_01", type = "chain", parent = weaponParent } }
        )
        -- ########################################
        -- Inject fixes
        -- ########################################
        -- This is where the weapons are aligned
        -- ########################################
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
                {   dependencies =  { "chain_chainaxe" },
                    chain =         { offset = true, position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.0, 1.0, 1.0) },
                },
            }
        )
        table.prepend(
            wc.anchors[weaponClass].fixes, {
                {   dependencies =  { "chain_2h_chain_sword" },
                    chain =         { offset = true, position = vector3_box(0.0, 0.0, 0.0), rotation = vector3_box(0, 0, 0), scale = vector3_box(1.0, 1.0, 1.0) },
                },
            }
        )
        table.prepend(
            wc.anchors[weaponClass].fixes, {
                {   dependencies =  { "chain_2h_chain_sword" },
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
            "chain_2h_chain_sword",
            "chain_2h_chain_sword",
        }
    end
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
