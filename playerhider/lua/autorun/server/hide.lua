if not PlayerHider then 
	PlayerHider = {}
	PlayerHider.players = {}
	PlayerHider.playerCount = 0
	PlayerHider.command1 = "!carotte"
	PlayerHider.command2 = "!tomate"
end

local CLIENT_STATE_NOT_LOADED = 0
local CLIENT_STATE_LOADED = 1

local HIDDEN_STATE_NOT_HIDDEN = 0
local HIDDEN_STATE_HIDDEN = 1
local HIDDEN_STATE_HIDDEN_FIRST_SPAWN = 2



util.AddNetworkString("PlayerHider.refreshList")
util.AddNetworkString("PlayerHider.clientLoaded")
util.AddNetworkString("PlayerHider.requestUpdate")

function PlayerHider.ShouldAddToHideList(ply)
	return ply:IsAdmin()
end

function PlayerHider.updateHiddenState(ply, state)
	if ply and ply:IsValid() then
		if not PlayerHider.players[ply:EntIndex()] then
			PlayerHider.players[ply:EntIndex()] = {}
		end
		PlayerHider.players[ply:EntIndex()].hidden_state = state or HIDDEN_STATE_NOT_HIDDEN
	end
end

function PlayerHider.getHiddenState(ply)
	if ply and ply:IsValid() then
		if not PlayerHider.players[ply:EntIndex()] then
			PlayerHider.players[ply:EntIndex()] = {}
		end
		return PlayerHider.players[ply:EntIndex()].hidden_state or HIDDEN_STATE_NOT_HIDDEN
	end
end

function PlayerHider.updateClientState(ply, state)
	if ply and ply:IsValid() then
		PlayerHider.players[ply:EntIndex()].client_state = state or CLIENT_STATE_LOADED
	end
end

function PlayerHider.getClientState(ply)
	if ply and ply:IsValid() then
		return PlayerHider.players[ply:EntIndex()].client_state or CLIENT_STATE_LOADED
	end
end

function PlayerHider.isHidden(ply)
	return PlayerHider.getHiddenState(ply) != HIDDEN_STATE_NOT_HIDDEN
end

-- NET --
-- Called when the client has loaded the entites clientside --
function PlayerHider.clientLoaded(len, ply)
	if PlayerHider.isHidden(ply) then
		if LogBox then 
			LogBox:Send(ply, Color(255, 200, 0), "You are a ninja! Type ", Color(255, 0, 0), PlayerHider.command1, Color(255, 200, 0), " to be visible !") 
		end
	end
	PlayerHider.updateClientState(ply, CLIENT_STATE_LOADED)
	PlayerHider.updateClient(ply)
end
net.Receive("PlayerHider.clientLoaded", PlayerHider.clientLoaded)

function PlayerHider.requestUpdate(len, ply)
	PlayerHider.updateClient(ply)
end
net.Receive("PlayerHider.requestUpdate", PlayerHider.requestUpdate)

-- Send hidden players to all (ready) clients --
function PlayerHider.updateAllClients()
	for id, _ in pairs(PlayerHider.players) do
		local ply = Entity(id)
		if PlayerHider.getClientState(ply) == CLIENT_STATE_LOADED then
			PlayerHider.updateClient(ply)
		end
	end
end

-- Send hidden players to client (must be ready) --
function PlayerHider.updateClient(ply)
	net.Start("PlayerHider.refreshList")
		net.WriteInt(PlayerHider.playerCount, 32)
		for id, _ in pairs(PlayerHider.players) do
			local p = Entity(id)
			if p and p:IsValid() and PlayerHider.isHidden(p) --[[and not (PlayerHider.ShouldAddToHideList(ply) and PlayerHider.ShouldAddToHideList(p))]] then
				net.WriteEntity(p)
			end
		end
	net.Send(ply)
end

-- HOOKS --
-- Player spawned for the first time --
function PlayerHider.PlayerConnected(ply)
	PlayerHider.players[ply:EntIndex()] = {
		hidden_state = HIDDEN_STATE_NOT_HIDDEN,
		client_state = CLIENT_STATE_NOT_LOADED
	}
	if PlayerHider.ShouldAddToHideList(ply) then
		PlayerHider.hideServerside(ply)
		timer.Simple(1, function()
			ply:Spawn()
		end)
		PlayerHider.updateAllClients()
	end
end
hook.Add("PlayerInitialSpawn", "PlayerHiderPlayerConnected", PlayerHider.PlayerConnected)

-- Player got his weapons --
function PlayerHider.PlayerLoadout(ply)
	if PlayerHider.isHidden(ply) then
		timer.Simple(10, function()
			PlayerHider.applyServersideEffects(ply)
		end)
	end
end
hook.Add("PlayerLoadout", "PlayerHiderPlayerLoadout", PlayerHider.PlayerLoadout)

-- Player said a command --
function PlayerHider.PlayerSay(ply, msg)
	if not ply or not ply:IsPlayer() then return msg end
	if PlayerHider.ShouldAddToHideList(ply) then
		if msg == PlayerHider.command2 then
			PlayerHider.applyServersideEffects(ply)
			PlayerHider.hideServerside(ply)
			PlayerHider.updateAllClients()
			return ""
		elseif msg == PlayerHider.command1 then
			PlayerHider.unapplyServersideEffects(ply)
			PlayerHider.revealServerside(ply)
			PlayerHider.updateAllClients()
			return ""
		end
	end
end
hook.Add("PlayerSay", "PlayerHiderPlayerSay", PlayerHider.PlayerSay)

-- Player disconnected (little hack) --
function PlayerHider.PlayerDisconnected(ply)
	PlayerHider.revealServerside(ply)
	PlayerHider.updateAllClients()
end
hook.Add("EntityRemoved", "PlayerHiderDisconnectHack", function(ent)
	if ent:IsPlayer() then
		PlayerHider.PlayerDisconnected(ent)
	end
end)

function PlayerHider.applyServersideEffects(ply)
	ply:DrawShadow(false)
	ply:SetNotSolid(true)
	if not ply.OldPhysgunColor then ply.OldPhysgunColor = ply:GetWeaponColor() end
	ply:SetWeaponColor(Vector(0,0,0))
	for _, wep in pairs(ply:GetWeapons()) do
		wep:DrawShadow(false)
	end
end

function PlayerHider.unapplyServersideEffects(ply)
	ply:DrawShadow(true)
	ply:SetNotSolid(false)
	ply:SetWeaponColor(ply.OldPhysgunColor or Vector(1, 1 ,1))
	for _, wep in pairs(ply:GetWeapons()) do
		wep:DrawShadow(true)
	end
end

function PlayerHider.hideServerside(ply)
	if not PlayerHider.isHidden(ply) then
		PlayerHider.playerCount = PlayerHider.playerCount + 1
		PlayerHider.updateHiddenState(ply, HIDDEN_STATE_HIDDEN)
	end
end

function PlayerHider.revealServerside(ply)
	if PlayerHider.isHidden(ply) then
		PlayerHider.playerCount = PlayerHider.playerCount - 1
		PlayerHider.unapplyServersideEffects(ply)
		PlayerHider.updateHiddenState(ply, HIDDEN_STATE_NOT_HIDDEN)
	end
end