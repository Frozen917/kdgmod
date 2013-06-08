include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

local function capitalize(text)
    return string.upper(string.Left(text, 1)) .. string.Right(text, string.len(text)-1)
end

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.damaged = 0
end

function ENT:SetResources(resources)
    self.BaseClass.Initialize(self)
    self.resources = resources
    if WireAddon then
        self.WireDebugName = self.PrintName
        local outputs = {}
        for k,v in pairs(resources) do
            table.insert(outputs, capitalize(k))
        end
        for k,v in pairs(resources) do
            table.insert(outputs, "Max " .. capitalize(k))
        end
        self.Outputs = Wire_CreateOutputs(self, outputs)
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

function ENT:Think()
    self.BaseClass.Think(self)
    if WireAddon then
        self:UpdateWireOutput()
    end
    self:NextThink(CurTime() + 1)
    return true
end

function ENT:UpdateWireOutput()
    for k,v in pairs(self.resources) do
        Wire_TriggerOutput(self, capitalize(k), self:GetResourceAmount(k))
        Wire_TriggerOutput(self, "Max " .. capitalize(k), self:GetNetworkCapacity(k))
    end
end
