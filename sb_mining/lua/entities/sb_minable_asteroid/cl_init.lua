include("shared.lua")

function ENT:DrawCustom()
	local scale = self:GetAsteroidScale()
	local vscale = Vector( scale, scale, scale)

	local mat = Matrix()
	mat:Scale( vscale )
	self:EnableMatrix( "RenderMultiply", mat )
	self:DrawModel()
end

function ENT:Initialize()
	spawnedAsteroids[self:EntIndex()] = self
end

function ENT:OnRemove()
	spawnedAsteroids[self:EntIndex()] = nil
end