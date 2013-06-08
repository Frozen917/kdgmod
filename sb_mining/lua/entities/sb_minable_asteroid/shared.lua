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

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	if self:GetPhysicsObject():IsValid() then
		self.originalConvexes = self:GetPhysicsObject():GetMeshConvexes()
		self:PhysicsInitMultiConvex(self.originalConvexes)
		self.originalMesh = self:GetPhysicsObject():GetMesh()
	end
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

function ENT:ResizePhysicsServer()
	if self:GetPhysicsObject():IsValid() then 
		local oldFrozen = self:GetPhysicsObject():IsMotionEnabled()
		self:GetPhysicsObject():EnableMotion(false)
		
		local s = self:GetAsteroidScale()
		local aMultiConvex = {}
		print("aaaa")
		PrintTable(self.originalConvexes)
		for i, xConvex in ipairs( self.originalConvexes ) do
			print("i="..tostring(i))
			aMultiConvex[i] = {}
			for k, vVert in pairs( xConvex ) do
				aMultiConvex[i][k] = vVert.pos * s
			end
			
		end
		

		self:PhysicsInitMultiConvex(aMultiConvex)
		self:EnableCustomCollisions(true)
		--self:SetCustomCollisionCheck(true)
		self:GetPhysicsObject():EnableMotion(oldFrozen)
		--self:GetPhysicsObject():SetMass(MiningAddon.MaxAsteroidMass/MiningAddon.ModelScaleMultiplier * s)
		
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
			self:ResizePhysicsServer()
		else
		
		end
		self.lastPhysicsResize = CurTime()
	end

	self:NextThink(CurTime() + 1)
	return true
end

