return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`weapon_customization_chains` encountered an error loading the Darktide Mod Framework.")

		new_mod("weapon_customization_chains", {
			mod_script       = "weapon_customization_chains/scripts/mods/weapon_customization_chains/weapon_customization_chains",
			mod_data         = "weapon_customization_chains/scripts/mods/weapon_customization_chains/weapon_customization_chains_data",
			mod_localization = "weapon_customization_chains/scripts/mods/weapon_customization_chains/weapon_customization_chains_localization",
		})
	end,
	require = {
		 "weapon_customization",
	},
	load_after = {
		 "weapon_customization",
		 "for_the_drip",
	},
	load_before = {
		"weapon_customization_mt_stuff",
	},
	packages = {},
}
