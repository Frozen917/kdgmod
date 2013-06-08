include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Setup(model, resources, position, spot)
    self:SetModel(model)
    self.resources = resources
	self.spot = spot
    self:SetPos(position)
	self.currTotalResources = 0
	for _, r in pairs(resources) do
		self.currTotalResources = self.currTotalResources + r
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

function ENT:ResizePhysics()
	if self:GetPhysicsObject():IsValid() then 
		local oldFrozen = self:GetPhysicsObject():IsMotionEnabled()
		local s = self:GetAsteroidScale()
		local vertices = {}
		for i, vertex in pairs(self.originalMesh) do
			vertices[i] = deepCopy(vertex)
			vertices[i].pos = vertex.pos * s
		end
		self:PhysicsFromMesh(vertices)
		self:EnableCustomCollisions(true)
		self:GetPhysicsObject():EnableMotion(oldFrozen)
		self:GetPhysicsObject():SetMass(MiningAddon.MaxAsteroidMass/MiningAddon.ModelScaleMultiplier * s)
	end
end

function ENT:Think()
	if self.currTotalResources <= 0 then
		self:Remove()
	elseif not self.oldTotalResources or self.oldTotalResources - self.currTotalResources > 0 then
		local s = --[[MiningAddon.ModelScaleMultiplier *]] self.currTotalResources / MiningAddon.MaxResourcePerAsteroid
		if s > MiningAddon.MinModelScale then
			self:SetAsteroidScale(s)
			if CurTime() - (self.lastPhysicsResize or 0) > 1 then
				self:ResizePhysics()
				self.lastPhysicsResize = CurTime()
			end
		end
		self.oldTotalResources = self.currTotalResources
	end

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:GetResources()     -- Returning a COPY of the table
    return table.Copy(self.resources)
end

function ENT:TakeResource(resource, amount)
    if amount <= self.resources[resource] then
        self.resources[resource] = self.resources[resource] - amount
		self.currTotalResources = self.currTotalResources - amount
        return amount
    else
        local taken = self.resources[resource]
        self.resources[resource] = 0
		self.currTotalResources = self.currTotalResources - taken
        return taken
    end
end
