ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Minable Asteroid"
ENT.Author          = "Frozen, Marmotte Unijambiste"
ENT.Contact         = "www.kingdown.fr"
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false


function ENT:SetupDataTables()
	self:NetworkVar( "Float", 0, "AsteroidScale" )
end

local function deepCopy(tab)
	local toR = {}
	for k,v in pairs(tab) do
		if type(v) == "table" then
			toR[k] = deepCopy(v)
		elseif type(v) == "Vector" then
			toR[k] = Vector(v.x, v.y, v.z)
		else
			toR[k] = v
		end
	end
	return toR
end

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	if self:GetPhysicsObject():IsValid() then
		self.originalMesh = self:GetPhysicsObject():GetMesh()
	end
	if CLIENT then
		spawnedAsteroids[self:EntIndex()] = s
	else
		self:SetAsteroidScale(1)
	end
end

function ENT:ResizePhysicsServer()
	if self:GetPhysicsObject():IsValid() then 
		local oldFrozen = self:GetPhysicsObject():IsMotionEnabled()
		self:GetPhysicsObject():EnableMotion(false)
		
		local s = self:GetAsteroidScale()
		local newMesh = {}
		for i, vertex in pairs( self.originalMesh ) do
			newMesh[i] = deepCopy(vertex)
			newMesh[i].pos = vertex.pos * s
		end
		
		self:PhysicsFromMesh(newMesh)
		self:EnableCustomCollisions(true)

		self:GetPhysicsObject():EnableMotion(oldFrozen)
	end
end

function ENT:Think()
	if SERVER then
		if self.currTotalResources <= 0 then
			self:Remove()
		elseif not self.oldTotalResources or self.oldTotalResources - self.currTotalResources > 0 then
			local s = MiningAddon.ModelScaleMultiplier * self.currTotalResources / MiningAddon.MaxResourcePerAsteroid
			if s > MiningAddon.MinModelScale then
				self:SetAsteroidScale(s)
			end
			self.oldTotalResources = self.currTotalResources
		end
	end
	
	if CurTime() - (self.lastPhysicsResize or 0) > 15 then
		if SERVER then
			--self:ResizePhysicsServer()
		end
		self.lastPhysicsResize = CurTime()
	end

	self:NextThink(CurTime() + 1)
	return true
end

