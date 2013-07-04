ENT.Type 			= "anim"
ENT.Base 			= "base_rd3_entity"
ENT.RenderGroup 	= RENDERGROUP_BOTH

list.Set("LSEntOverlayText", "sb_mining_laser", { HasOOO = true, resnames = { "energy" }})

ENT.PrintName	    = "Ore Miner"
ENT.Author		    = ""
ENT.Instructions    = ""

ENT.LaserRange = 512
function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "LaserBeamStart" )
	self:NetworkVar( "Vector", 1, "LaserBeamDirection" )
	self:NetworkVar( "Float", 0, "LaserBeamDistance" )
	self:NetworkVar( "String", 0, "OreType" )
	self:NetworkVar( "String", 1, "CustomEntName" )
	self:NetworkVar( "Bool", 0, "Mining" )
end