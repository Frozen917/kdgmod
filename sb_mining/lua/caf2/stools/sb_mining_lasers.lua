TOOL.Category           = "Mining Addon"
TOOL.Name               = "Mining Laser"

TOOL.DeviceName         = "Mining Laser"
TOOL.DeviceNamePlural   = "Mining Lasers"
TOOL.ClassName          = "sb_mining_lasers"

TOOL.DevSelect          = true
TOOL.CCVar_type         = "sb_mining_laser"
TOOL.CCVar_sub_type     = "Small Mining Laser"
TOOL.CCVar_model        = "models/mandrac/laser5.mdl"

TOOL.Limited            = true
TOOL.LimitName          = "sb_mining_lasers"
TOOL.Limit              = 20

CAFToolSetup.SetLang("Asteroid Mining Lasers", "Create Mining Lasers attached to any surface.", "Left-Click: Spawn a Device.  Reload: Repair Device.")

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

function mining_laser_func(ent, type, sub_type, devinfo, Extra_Data, ent_extras)
    local res = {}
    local mass = 80
    local maxhealth = 200

	ent.caf.custom.resource = ent_extras.resType
	ent:SetCustomEntName(devinfo.Name)
	ent:SetupLaser(ent_extras.resType, ent_extras.resAmount, ent_extras.energyRate, ent_extras.laserPos, ent_extras.direction)
	
	CAF.GetAddon("Resource Distribution").RegisterNonStorageDevice(ent)
	
	
	
    return mass, maxhealth
end

TOOL.Devices = {
    sb_mining_laser = {
        Name = "Mining Laser",
        type = "sb_mining_laser",
        class = "sb_mining_laser",
        func = mining_laser_func,
        devices = {
            laser_type_1 = {
                Name = capitalize(MiningAddon.Ores[1]).." Mining Laser",
                model = "models/mandrac/laser5.mdl",
                skin = 0,
                legacy = false, --these two vars must be defined per ent as the old tanks (defined in external file) require different values
				ent_extras = {
					resType = MiningAddon.Ores[1],
					resRate = 100,
					energyRate = 200,
					laserPos = Vector(-70.08, 0, 0),
					direction = Vector(-1,0,0)
				}
            },
            laser_type_2 = {
                Name = capitalize(MiningAddon.Ores[2]).." Mining Laser",
                model = "models/mandrac/laser5.mdl",
                skin = 0,
                legacy = false,
				ent_extras = {
					resType = MiningAddon.Ores[2],
					resRate = 100,
					energyRate = 200,
					laserPos = Vector(-70.08, 0, 0),
					direction = Vector(-1,0,0)
				}
            },
			laser_type_3 = {
                Name = capitalize(MiningAddon.Ores[3]).." Mining Laser",
                model = "models/mandrac/laser5.mdl",
                skin = 0,
                legacy = false,
				ent_extras = {
					resType = MiningAddon.Ores[3],
					resRate = 100,
					energyRate = 200,
					laserPos = Vector(-70.08, 0, 0),
					direction = Vector(-1,0,0)
				}
            },
			--[[laser_type_4 = {
                Name = "Laser4",
                model = "models/mandrac/laser4.mdl",
                skin = 0,
                legacy = false,
				ent_extras = {
					resType = "ore4",
					resRate = 100,
					energyRate = 200,
					laserPos = Vector(-70.08, 0, -1.2),
					direction = Vector(-1,0,0)
				}
            },
			laser_type_5 = {
                Name = "Laser5",
                model = "models/mandrac/laser5.mdl",
                skin = 0,
                legacy = false,
				ent_extras = {
					resType = "ore5",
					resRate = 100,
					energyRate = 200,
					laserPos = Vector(-70.08, 0, -1.2),
					direction = Vector(-1,0,0)
				}
            },]]
        },
    },
}
