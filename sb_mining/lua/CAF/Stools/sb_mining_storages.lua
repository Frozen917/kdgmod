TOOL.Category           = "Mining Addon"
TOOL.Name               = "Ore Container"

TOOL.DeviceName         = "Ore Container"
TOOL.DeviceNamePlural   = "Ore Containers"
TOOL.ClassName          = "sb_mining_storages"

TOOL.DevSelect          = true
TOOL.CCVar_type         = "sb_ore_container"
TOOL.CCVar_sub_type     = "Small Ore Container"
TOOL.CCVar_model        = "models/mandrac/ore_container/ore_small.mdl"

TOOL.Limited            = true
TOOL.LimitName          = "sb_mining_storages"
TOOL.Limit              = 20

CAFToolSetup.SetLang("Asteroid Mining Storage Devices", "Create Storage Devices attached to any surface.", "Left-Click: Spawn a Device.  Reload: Repair Device.")

local function capitalize(text)
    return string.upper(string.Left(text, 1)) .. string.Right(text, string.len(text)-1)
end

function TOOL.EnableFunc()
    if not CAF then
        return false;
    end
    if not CAF.GetAddon("Resource Distribution") or not CAF.GetAddon("Resource Distribution").GetStatus() then
        return false;
    end
    return true;
end

local smallContenance = 8000
local mediumContenance = 16000
local largeContenance = 24000

--[[
	TOOL.AdminOnly 			= true --Make the Stool admin only
	TOOL.EnableFunc  = function(ply) return true or false end (Optional)
	
	
	type = {
		type			= "entity type", --same as key (optional). typically same as class
		class			= "entity class", --entity class used by ents.Create() (optional if type is class)
		Name			= "Print Name used for device catagory in tool",
		legacy		= true, --if _WHOLE_ group contains _ONLY_ ents that are from orginal ls2 (optional) this is for old dupe saves that use model as a sub type
		hide			= true, --if this group should be hidden on the control panel (optional)
		
		MakeFunc		= function(tool, ply, Ang, Pos, type, sub_type, model, frozen, Extra_Data, devinfo) return ent end (optional)
		MakeFuncReturn	= true, --skips rest of make rd2 ent function and returns ent (optional)
		EnableFunc  = function(ply) return true or false end (Optional)
		func			= function(ent,type,sub_type,devinfo,Extra_Data,ent_extras) addres(ent) return mass, maxhealth end (optional)
		AdminOnly		= true/false --Make the Device group Admin only
		devices = {
			sub_type = {
				Name		= "Print Name for this sub_type in tool",
				type		= "entity class", can be different than group type (optional)
				class		= "entity class", --entity class used by ents.Create() (optional if type is class or if same as group.class or group.type)
				model		= "path/to/model",
				skin		= # for skin, (optional)
				res			= {coolant = 4000},
				EnableFunc  = function(ply) return true or false end (Optional)
				maxhealth	= 300,
				mass		= 20,
				legacy	= true, --if ent is from ls2 (optional)
				hide		= true, --if this sub_type should be hidden on the control panel (optional)
				ent_extras	= {}, --table of exra info to copy to ent (optional)
				AdminOnly		= true/false --Make the Device Admin only
			},
			sub_type = {
				Name		= "Print Name for this sub_type in tool",
				model		= "path/to/model",
				material	= "path/to/material", (optional)
				func		= function(ent,type,sub_type,devinfo,Extra_Data,ent_extras) addres(ent) return mass, maxhealth end (optional)
			},
		},
	},
]]

local function ore_container_func(ent, type, sub_type, devinfo, Extra_Data, ent_extras)
    local res = ent_extras.res
    local mass = 0
    local maxhealth = 0
    if sub_type == "small_ore_container" then
        mass = 80
        maxhealth = 200
    elseif sub_type == "medium_ore_container" then
        mass = 160
        maxhealth = 400
    elseif sub_type == "large_ore_container" then
        mass = 240
        maxhealth = 600
    end
    for k,v in pairs(res) do
        CAF.GetAddon("Resource Distribution").AddResource(ent, k, v)
    end
    ent:SetResources(res)
    return mass, maxhealth
end

TOOL.Devices = {
    sb_ore_container = {
        Name = "Ore Container",
        type = "sb_ore_container",
        class = "sb_ore_container",
        func = ore_container_func,
        devices = {
            --[[small_ore_container1 = {
                Name = "Medium " .. capitalize(MiningAddon.Ores[1]) .. " Container",
                model = "models/mandrac/ore_container/ore_small.mdl",
                skin = 0,
                legacy = false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				ent_extras = {
					res = {[ MiningAddon.Ores[1] ] = smallContenance}
				}
            },]]
            medium_ore_container1 = {
                Name = "Medium " .. capitalize(MiningAddon.Ores[1]) .. " Container",
                model = "models/mandrac/ore_container/ore_medium.mdl",
                skin = 0,
                legacy = false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				ent_extras = {
					res = {[ MiningAddon.Ores[1] ] = mediumContenance}
				}
            },
            large_ore_container1 = {
                Name = "Large " .. capitalize(MiningAddon.Ores[1]) .. " Container",
                model = "models/mandrac/ore_container/ore_large.mdl",
                skin = 0,
                legacy = false,
				ent_extras = {
					res = { [ MiningAddon.Ores[1] ] = largeContenance}
				}
            },
			--[[small_ore_container2 = {
                Name = "Small " .. capitalize(MiningAddon.Ores[1]) .. " Container",
                model = "models/mandrac/ore_container/ore_small.mdl",
                skin = 0,
                legacy = false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				ent_extras = {
					res = { [ MiningAddon.Ores[2] ] = smallContenance}
				}
            },]]
            medium_ore_container2 = {
                Name = "Medium " .. capitalize(MiningAddon.Ores[2]) .. " Container",
                model = "models/mandrac/ore_container/ore_medium.mdl",
                skin = 0,
                legacy = false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				ent_extras = {
					res = { [ MiningAddon.Ores[2] ] = mediumContenance}
				}
            },
            large_ore_container2 = {
                Name = "Large " .. capitalize(MiningAddon.Ores[2]) .. " Container",
                model = "models/mandrac/ore_container/ore_large.mdl",
                skin = 0,
                legacy = false,
				ent_extras = {
					res = { [ MiningAddon.Ores[2] ] = largeContenance}
				}
            },
			--[[small_ore_container3 = {
                Name = "Small " .. capitalize(MiningAddon.Ores[3]) .. " Container",
                model = "models/mandrac/ore_container/ore_small.mdl",
                skin = 0,
                legacy = false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				ent_extras = {
					res = { [ MiningAddon.Ores[3] ] = smallContenance}
				}
            },]]
            medium_ore_container3 = {
                Name = "Medium " .. capitalize(MiningAddon.Ores[3]) .. " Container",
                model = "models/mandrac/ore_container/ore_medium.mdl",
                skin = 0,
                legacy = false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				ent_extras = {
					res = { [ MiningAddon.Ores[3] ] = mediumContenance}
				}
            },
            large_ore_container3 = {
                Name = "Large " .. capitalize(MiningAddon.Ores[3]) .. " Container",
                model = "models/mandrac/ore_container/ore_large.mdl",
                skin = 0,
                legacy = false,
				ent_extras = {
					res = { [ MiningAddon.Ores[3] ] = largeContenance}
				}
            },
        },
    },
}
