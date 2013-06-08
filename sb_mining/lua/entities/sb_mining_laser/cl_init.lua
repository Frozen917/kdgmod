include("shared.lua")

local laserMat = CreateMaterial("MiningLaserMat", "UnlitGeneric",{
	["$basetexture"] = "sprites/physbeam_active_white", 
	["$color"] = "[1 1 1]" , 
	["$translucent"] = "1",
	["$nocull"] = "1",
	["$additive"] = "1",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1",
	["$surfaceprop"] = "Default",
	["Proxies"] = {
		["TextureScroll"] = {
			["texturescrollvar"] = "$baseTextureTransform",
			["texturescrollrate"] = "10",
			["texturescrollangle"] = "270.00"
		}
	}
})

function ENT:Initialize()
	self.emitter = ParticleEmitter(self:GetPos())
	spawnedMininglasers[self:EntIndex()] = self
end

function ENT:OnRemove()
	spawnedMininglasers[self:EntIndex()] = nil
end

function ENT:Draw()
end

function ENT:DrawCustom()
	l.BaseClass.Draw(l)
	if self:GetOOO() == 1 then
		local color = MiningAddon.OreColors[self:GetOreType()] or Color(255,255,255)
		local startPos = self:LocalToWorld(self:GetLaserBeamStart())
		local endPos = self:LocalToWorld(self:GetLaserBeamStart() + self:GetLaserBeamDirection() * self:GetLaserBeamDistance())
		if self:GetMining() then
			for i=1, 10 do
				local part = self.emitter:Add("sprites/light_glow02_add", endPos)
				if part then
					part:SetColor(255,255,255,math.random(255))
					part:SetVelocity(VectorRand() * 30)
					part:SetDieTime(0.8)
					part:SetGravity((startPos - endPos):GetNormalized() *50)
					part:SetLifeTime(0)
					part:SetStartSize(5)
					part:SetEndSize(0)
				end
			end
			for i=1,5*(startPos - endPos):Length()/self.LaserRange do
				local lolpos = endPos + VectorRand() * 10
				local part2 = self.emitter:Add("sprites/light_glow02_add", lolpos)
				if part2 then
					part2:SetColor(color.r,color.g,color.b, 255)
					part2:SetVelocity((startPos - lolpos):GetNormalized() * 80)
					part2:SetDieTime((startPos - lolpos):Length()/80 +1.2)
					part2:SetLifeTime(0)
					part2:SetStartSize(15)
					part2:SetEndSize(10)
				end
			end
		end
		render.SetMaterial(laserMat)
		--render.SetColorMaterial(Color(255,255,0,255))
		render.DrawBeam(startPos, endPos, 12, 5*self.LaserRange/self:GetLaserBeamDistance(), 0.1, Color(255,255,255,255))
	end
end