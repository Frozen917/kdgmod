AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	if WireLib then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, {"On"})
		self.Outputs = Wire_CreateOutputs(self, {"On"})
	end
end

function ENT:SetupLaser(resType, resRate, energy, laserPos, laserDir)
    self.resType = resType
	self.resRate = resRate
	self.energyRate = energyRate
	
	self:SetLaserBeamStart(laserPos)
	self:SetLaserBeamDirection(laserDir)
	self:SetOreType(resType)
end

function ENT:TriggerInput(name, value)
	if name == "On" then
		if value then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end

function ENT:Damage()
    if (self.damaged == 0) then
        self.damaged = 1
    end
end

function ENT:Repair()
    self.BaseClass.Repair(self)
    self:SetColor(Color(255, 255, 255, 255))
    self.damaged = 0
end

function ENT:Destruct()
    if CAF and CAF.GetAddon("Life Support") then
        CAF.GetAddon("Life Support").Destruct(self, true)
    end
end

function ENT:TurnOff()
	self.Active = 0
	self:SetOOO(0)
	if WireLib then
		Wire_TriggerOutput(self, "On", 0)
	end
end

function ENT:TurnOn()
	self.Active = 1
	self:SetOOO(1)
	if WireLib then
		Wire_TriggerOutput(self, "On", 1)
	end
end

function ENT:Think()
	local mining = false
	self.BaseClass.Think(self)
	if self.Active == 1 then
		local energyConsumption = self.energyRate
		if self:GetResourceAmount("energy") < energyConsumption then
			self:TurnOff()
		else
			local tracedata = {}
			tracedata.start = self:LocalToWorld(self:GetLaserBeamStart())
			tracedata.endpos = self:LocalToWorld(self:GetLaserBeamStart() + self:GetLaserBeamDirection() * self.LaserRange)
			tracedata.filter = self
			local tr = util.TraceLine(tracedata)
			self:SetLaserBeamDistance((tr.HitPos - tracedata.start):Length())
			if tr.Entity and tr.Entity:IsValid() then
				if tr.Entity:GetClass() == "sb_minable_asteroid" then
					energyConsumption = energyConsumption * 2
					local asteroid = tr.Entity
					local resources = tr.Entity:GetResources()
					
					if resources[self.resType] and resources[self.resType] > 0 then
						mining = true
						if CurTime() - (self.lastMined or 0) > 1 then
							local toDrain = asteroid:TakeResource(self.resType, self.resRate)
							self:SupplyResource(self.resType, toDrain)
							energyConsumption = energyConsumption * toDrain / self.resRate
							self.lastMined = CurTime()
							self:ConsumeResource("energy", energyConsumption)
						end
					end
				else
					local dmg = DamageInfo()
					dmg:SetAttacker(self)
					dmg:SetInflictor(self)
					dmg:SetDamageType(DMG_DISSOLVE)
					dmg:SetDamage(1000)
					tr.Entity:TakeDamageInfo(dmg)
				end
			end
			
		end
	end
	self:SetMining(mining)
	self:NextThink(CurTime() + 0.01)
	return true
end