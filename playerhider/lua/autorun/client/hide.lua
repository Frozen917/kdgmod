if not PlayerHider then 
	PlayerHider = {}
	PlayerHider.players = {}
end

--CLIENT--
function PlayerHider.isHidden(ply)
	if ply and ply.EntIndex and ply:EntIndex() then
		return PlayerHider.players[ply:EntIndex()] != nil
	end
end

function PlayerHider.refreshHiddenList()
	local cnt = net.ReadInt(32)
	PlayerHider.players = {}
	for i=1, cnt do
		local e = net.ReadEntity()
		if e and e:IsValid() then
			PlayerHider.players[e:EntIndex()] = e
		end
	end
end
net.Receive("PlayerHider.refreshList", PlayerHider.refreshHiddenList)

if not PlayerHider.OldEntityIsValid then 
	PlayerHider.OldEntityIsValid = FindMetaTable("Entity").IsValid
	FindMetaTable("Entity").IsValid = function(self)
		return not PlayerHider.isHidden(self) and PlayerHider.OldEntityIsValid(self)
	end
end

function PlayerHider.PlayerFootstep( ply, vPos, iFoot, strSoundName, fVolume, pFilter)
    return PlayerHider.isHidden(ply)
end
hook.Add("PlayerFootstep", "PlayerHiderPlayerFootstep", PlayerHider.PlayerFootstep)

function PlayerHider.OnEntityCreated(ent)
	if ent and ent:IsPlayer() then
		net.Start("PlayerHider.requestUpdate")
		net.SendToServer()
	end
end
hook.Add("OnEntityCreated", "PlayerHiderOnEntityCreated", PlayerHider.OnEntityCreated)

function PlayerHider.InitPostEntity()
    net.Start("PlayerHider.clientLoaded")
	net.SendToServer()
end
hook.Add("InitPostEntity", "PlayerHiderInitPostEntity", PlayerHider.InitPostEntity)

if not PlayerHider.OldPlayerGetAll then PlayerHider.OldPlayerGetAll = player.GetAll end
player.GetAll = function()
	local plys = PlayerHider.OldPlayerGetAll()
	local plys2 = {}
	for _, p in ipairs(plys) do
		if not PlayerHider.isHidden(p) then
			table.insert(plys2, p)
		end
	end
	return plys2
end

if not PlayerHider.OldIsValid then PlayerHider.OldIsValid = IsValid end
IsValid = function(e)
	return PlayerHider.OldIsValid(e) and not PlayerHider.isHidden(e)
end


if not PlayerHider.OldPlayerGetByID then PlayerHider.OldPlayerGetByID = player.GetByID end
player.GetByID = function(id)
	local ply = PlayerHider.OldPlayerGetByID(id)
	if not PlayerHider.isHidden(ply) then return ply end
	return nil
end

function PlayerHider.PrePlayerDraw(ply)
	return PlayerHider.isHidden(ply)
end
hook.Add("PrePlayerDraw", "PlayerHiderPrePlayerDraw", PlayerHider.PrePlayerDraw)

function PlayerHider.HUDDrawTargetID()
	local e = LocalPlayer():GetEyeTrace().Entity
	if e and e:IsPlayer() and PlayerHider.isHidden(e) then
		return false	
	end
end
hook.Add("HUDDrawTargetID", "PlayerHiderHUDDrawTargetID", PlayerHider.HUDDrawTargetID)