if not MiningAddon then MiningAddon = {} end

MiningAddon.AsteroidModels = {}
	--[["models/ce_ls3additional/asteroids/asteroid_200.mdl",
	"models/ce_ls3additional/asteroids/asteroid_250.mdl",
	"models/ce_ls3additional/asteroids/asteroid_300.mdl",
	"models/ce_ls3additional/asteroids/asteroid_350.mdl",
	"models/ce_ls3additional/asteroids/asteroid_400.mdl",
	"models/ce_ls3additional/asteroids/asteroid_450.mdl",
	"models/ce_ls3additional/asteroids/asteroid_500.mdl"
	"models/mandrac/asteroid/geode1.mdl",
	"models/mandrac/asteroid/geode2.mdl",
	"models/mandrac/asteroid/geode3.mdl",
	"models/mandrac/asteroid/geode4.mdl"]]

MiningAddon.Ores = {}
MiningAddon.LaserColors = {}
function MiningAddon.RegisterOre(sName, cColor)
	if sName then
		table.insert(MiningAddon.Ores, sName)
		MiningAddon.LaserColors[sName] = cColor or Color(255,255,255)
	end
end

function MiningAddon.RegisterAsteroidModel(sName, sModel, tSkinTable)
	if sModel and sName and not MiningAddon.AsteroidModels[sName] then
		local t = {}
		t.model = sModel
		t.skins = tSkinTable or {}
		
		MiningAddon.AsteroidModels[sName] = t
	end
end

MiningAddon.RegisterOre("Spessartine", Color(255,152,0))
MiningAddon.RegisterOre("Torbenite", Color(5,103,0))
MiningAddon.RegisterOre("Dioptase", Color(0,97,100))

MiningAddon.RegisterAsteroidModel("Geode 1", "models/mandrac/asteroid/geode1.mdl", {Spessartine = 3, Torbenite = 1, Dioptase = 2 })
MiningAddon.RegisterAsteroidModel("Geode 2", "models/mandrac/asteroid/geode2.mdl", {Spessartine = 3, Torbenite = 1, Dioptase = 2 })
MiningAddon.RegisterAsteroidModel("Geode 3", "models/mandrac/asteroid/geode3.mdl", {Spessartine = 3, Torbenite = 1, Dioptase = 2 })
MiningAddon.RegisterAsteroidModel("Geode 4", "models/mandrac/asteroid/geode4.mdl", {Spessartine = 3, Torbenite = 1, Dioptase = 2 })

if SERVER then
	MiningAddon.AsteroidSpots = {
		sb_gooniverse = {
			Vector(-8120, 7360, -10560),
			Vector(-12305, 305, 6200),
			Vector(9367, -6350, 11540)
		}
	}

	if not MiningAddon.currentSpots then
		MiningAddon.currentSpots = {}
		MiningAddon.AsteroidCount = 0
	end
	MiningAddon.MinRespawnTime = 3
	MiningAddon.ModelScaleMultiplier = 5
	MiningAddon.MaxRespawnTime = 6
	MiningAddon.MaxResourcePerAsteroid = 80000
	MiningAddon.MaxAsteroidMass = 50000
	MiningAddon.MinModelScale = 1
	MiningAddon.SpawnRadius = 1500
	MiningAddon.MaxAsteroids = 16
	MiningAddon.MinAsteroidsPerSpot = 1
	MiningAddon.MaxAsteroidsPerSpot = 6

	function MiningAddon.ComputeNewAsteroidPos(spot)
		return spot.spotPos + Vector(math.random(-MiningAddon.SpawnRadius, MiningAddon.SpawnRadius), math.random(-MiningAddon.SpawnRadius, MiningAddon.SpawnRadius), math.random(-MiningAddon.SpawnRadius, MiningAddon.SpawnRadius))
	end

	function MiningAddon.SpawnAsteroids(spot, newCount)
		print("Spawning ".. newCount - spot.asteroidCount .. " asteroids")
		local toSpawn = newCount - spot.asteroidCount
		
		for i=1, toSpawn do
			local asteroidPos = MiningAddon.ComputeNewAsteroidPos(spot)
			local asteroid = ents.Create("sb_minable_asteroid")
			local res = {}
			--local ores = table.Copy(MiningAddon.OreTypes)
			
			local currentResAmount = math.random(math.min(MiningAddon.MaxResourcePerAsteroid*MiningAddon.MinModelScale, MiningAddon.MaxResourcePerAsteroid/10) , MiningAddon.MaxResourcePerAsteroid)
			res[spot.oreType] = currentResAmount
			--[[for _, ore in ipairs(ores) do
				if math.random() >= 0.5 and currentResAmount <= MiningAddon.MaxResourcePerAsteroid then
					local a = math.random((MiningAddon.MaxResourcePerAsteroid - currentResAmount)/10, MiningAddon.MaxResourcePerAsteroid - currentResAmount)
					res[ore] = a
					currentResAmount = currentResAmount + a
				end
			end]]
			local modelInfo = table.Random(MiningAddon.AsteroidModels)
			local model = modelInfo.model
			
			asteroid:Setup(model, res, asteroidPos, spot)
			asteroid:SetSkin(modelInfo.skins[spot.oreType] or 1)
			
			asteroid:SetAngles(Angle(math.random(0,360), math.random(0,360), math.random(0,360)))
			asteroid:Spawn()
			asteroid:Activate()
			asteroid:SetNetworkedString("Owner","World")
			
			spot.asteroidCount = spot.asteroidCount + 1
			MiningAddon.AsteroidCount = MiningAddon.AsteroidCount + 1
			
		end
		
		spot.spawning = false
	end

	function MiningAddon.RefillAsteroidSpots()
		MiningAddon.AsteroidCount = 0
		for _, spot in pairs(MiningAddon.currentSpots) do
			MiningAddon.AsteroidCount = MiningAddon.AsteroidCount + spot.asteroidCount
			local newCount = math.random(MiningAddon.MinAsteroidsPerSpot, MiningAddon.MaxAsteroidsPerSpot)
			if spot.asteroidCount == 0 then
				spot.oreType = table.Random(MiningAddon.Ores)
			end
			if spot.asteroidCount < newCount and not spot.spawning and MiningAddon.AsteroidCount + (newCount - spot.asteroidCount) <= MiningAddon.MaxAsteroids then
				spot.spawning = true
				timer.Simple(math.random(MiningAddon.MinRespawnTime, MiningAddon.MaxRespawnTime), function()
					MiningAddon.SpawnAsteroids(spot, newCount)
				end)
			end
		end
	end
	
	function MiningAddon.HandleAsteroidDeletion(ent)
		if ent:GetClass() == "sb_minable_asteroid" and ent.spot then
			print("Handling removing of asteroid "..tostring(ent))
			ent.spot.asteroidCount = ent.spot.asteroidCount - 1
			MiningAddon.AsteroidCount = MiningAddon.AsteroidCount - 1
		end
	end
	hook.Add("EntityRemoved", "MiningAddon.HandleAsteroidDeletion", MiningAddon.HandleAsteroidDeletion)
	
	function MiningAddon.InitAsteroidSpots()
		local spots = MiningAddon.AsteroidSpots[game.GetMap()]
		if spots then
			for i,pos in ipairs(spots) do
				MiningAddon.currentSpots[i] = {
					spotPos = pos,
					asteroidCount = 0,
					spawning = false,
					oreType = nil
				}
			end -- On vérifie qu'il y a assez d'astéroides toutes les 15 secondes
			timer.Create("RefillAsteroidSpots", 15, 0, MiningAddon.RefillAsteroidSpots)
		else
			print("No asteroid spot defined for map " .. game.GetMap())
		end
	end
	hook.Add("InitPostEntity", "StartAsteroidPlacing", MiningAddon.InitAsteroidSpots)
else
	
	function MiningAddon.AlwaysDrawEnts()
		for _, ast in pairs(ents.FindByClass("sb_minable_asteroid")) do
			if ast then
				ast:DrawCustom()
			end
		end
		for _, l in pairs(ents.FindByClass("sb_mining_laser")) do
			if l then
				l:DrawCustom()
			end
		end
	end
	hook.Add("PostDrawOpaqueRenderables", "MiningAddonAlwaysRender", MiningAddon.AlwaysDrawEnts)
	
end
function MiningAddon.NoAsteroidPickup(ply, ent)
	if ent:GetClass() == "sb_minable_asteroid" then
		return false
	end
end
hook.Add("PhysgunPickup", "NoAsteroidPickup", MiningAddon.NoAsteroidPickup)