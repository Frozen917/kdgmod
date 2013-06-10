include("shared.lua")

function ENT:DrawCustom()
	local scale = self:GetAsteroidScale()
	local vscale = Vector( scale, scale, scale)

	local mat = Matrix()
	mat:Scale( vscale )
	self:EnableMatrix( "RenderMultiply", mat )
	self:DrawModel()
end

function ENT:OnRemove()
	spawnedAsteroids[self:EntIndex()] = nil
end

function ENT:Think()
	if self:GetAsteroidScale() > 0 and self:GetUpdateNeeded() then
		self:ResizePhysics()
		self.lastPhysicsResize = CurTime()
	end

	self:NextThink(CurTime() + 0.1)
	return true
end