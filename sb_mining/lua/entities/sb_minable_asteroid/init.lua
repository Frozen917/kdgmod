include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

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
