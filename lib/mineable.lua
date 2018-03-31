-- name == is_mineable
--  or
-- name == { is_mineable, isOreToBeMined, beepBefore, overrideHarvestTool }
--
-- beepBefore: Beep when switching to this ore
-- overrideHarvestTool: some harvesting tools aren't
--  specified correctly on the blocks

return	{
	["basemetals:adamantine_ore"] = {true, true},
	["basemetals:coldiron_ore"] = {true, true},
	["basemetals:copper_ore"] = {true, true},
	["basemetals:lead_ore"] = {true, true},
	["basemetals:mercury_ore"] = {true, true, false, "pickaxe"},
	["basemetals:silver_ore"] = {true, true},
	["basemetals:tin_ore"] = {true, true},
	["basemetals:zinc_ore"] = {true, true},

	["minecraft:coal_ore"] = {true, true},
	["minecraft:diamond_ore"] = {"silk", true},
	["minecraft:dirt"] = "hand",
	["minecraft:emerald_ore"] = {"silk", true},
	["minecraft:gravel"] = "hand",
	["minecraft:iron_ore"] = {true, true},
	["minecraft:glowstone"] = {"silk", true},
	["minecraft:gold_ore"] = {true, true},
	["minecraft:lapis_ore"] = {"fortune", true},
	["minecraft:lit_redstone_ore"] = {"silk", true},
	["minecraft:magma"] = {true, true, false, "pickaxe"},
	["minecraft:quartz_ore"] = {"silk", true},
	["minecraft:redstone_ore"] = {"silk", true},
	["minecraft:soul_sand"] = true,
	["minecraft:stone"] = {true, false, true},
	["minecraft:netherrack"] = true,
	["minecraft:torch"] = "hand",
	
	["mineralogy:amphibolite"] = true,
	["mineralogy:conglomerate"] = true,
	["mineralogy:dolomite"] = true,
	["mineralogy:gneiss"] = true,
	["mineralogy:granite"] = true,
	["mineralogy:gypsum"] = true,
	["mineralogy:limestone"] = true,
	["mineralogy:nitrate_ore"] = {true, true},
	["mineralogy:phosphorous_ore"] = {true, true},
	["mineralogy:phyllite"] = true,
	["mineralogy:rhyolite"] = true,
	["mineralogy:sulfur_ore"] = {true, true},
	["mineralogy:schist"] = true,
	["mineralogy:slate"] = true,
	["thermalfoundation:ore"] = {true, true},
	["quantumflux:graphiteOre"] = {true, true},
	--chests, sign etc
	["minecraft:chest"] = {false, true},
	["minecraft:trapped_chest"] = {false, true},
	["minecraft:standing_sign"] = {false, true},
	["railcraft:ore_metal_poor"] = {true, true},
}

