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

