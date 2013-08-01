PlayerSlots = {}

-- CONFIG --

PlayerSlots.AdminSlotCount = 1
PlayerSlots.VipSlotCount = 2

function PlayerSlots.IsAdmin(ply)
	return ply:IsAdmin()
end

function PlayerSlots.IsVip(ply) --DEFINE MEH
	return ply.KDVIP
end

-- INTERNALS --

PlayerSlots.regularSlotCount = game.MaxPlayers() - PlayerSlots.AdminSlotCount - PlayerSlots.VipSlotCount
if PlayerSlots.regularSlotCount < 0 then
	PlayerSlots.regularSlotCount  = 0
end
RunConsoleCommand("sv_visiblemaxplayers", tostring(PlayerSlots.regularSlotCount))


PlayerSlots.adminSlots = {}
PlayerSlots.vipSlots = {}
PlayerSlots.regularSlots = {}

function PlayerSlots.regularSlotAvailable()
	return (PlayerSlots.regularSlotCount - #PlayerSlots.regularSlots) > 0
end

function PlayerSlots.vipSlotAvailable()
	return (PlayerSlots.VipSlotCount - #PlayerSlots.vipSlots) > 0
end

function PlayerSlots.adminSlotAvailable()
	return (PlayerSlots.AdminSlotCount - #PlayerSlots.adminSlots) > 0
end

function PlayerSlots.HandleAuth(ply, steamID, uid)
	if not PlayerSlots.regularSlotAvailable() then
		if PlayerSlots.IsAdmin(ply) and PlayerSlots.adminSlotAvailable() then
			print(ply:Nick() .. " joined an admin-only slot")
			table.insert(PlayerSlots.adminSlots, ply:EntIndex())
		elseif PlayerSlots.IsVip(ply) and PlayerSlots.vipSlotAvailable() then
			print(ply:Nick() .. " joined a vip-only slot")
			table.insert(PlayerSlots.vipSlots, ply:EntIndex())
		else
			print(ply:Nick() .. " was kicked (no free regular slots)")
			ply:Kick("Unable to find a free, non-reserved slot!")
		end
	else
		print(ply:Nick() .. " joined a regular slot")
		table.insert(PlayerSlots.regularSlots, ply:EntIndex())
	end
end
hook.Add("PlayerAuthed", "PlayerSlotsHandleAuth", PlayerSlots.HandleAuth)

function PlayerSlots.fillRegularSlots()
	while PlayerSlots.regularSlotAvailable() do
		if #PlayerSlots.vipSlots > 0 then
			print(ply:Nick() .. " switched from vip to a regular slot")
			table.insert(PlayerSlots.regularSlots, table.remove(PlayerSlots.vipSlots, 1))
		elseif #PlayerSlots.adminSlots > 0 then
			print(ply:Nick() .. " switched from admin to a regular slot")
			table.insert(PlayerSlots.regularSlots, table.remove(PlayerSlots.adminSlots, 1))
		else
			break
		end
	end
end

function PlayerSlots.HandleBotSpawn(ply)
	if ply:IsBot() then
		if PlayerSlots.regularSlotAvailable() then
			table.insert(PlayerSlots.regularSlots, ply:EntIndex())
		else
			print(ply:Nick() .. " was kicked (no free regular slots)")
			ply:Kick("Unable to find a free, non-reserved slot!")
		end
	end
end
hook.Add("PlayerInitialSpawn", "PlayerSlotsHandleBotSpawn", PlayerSlots.HandleBotSpawn)

function PlayerSlots.HandleDisconnect(ply)
	local aKey, vKey, rKey = table.KeyFromValue(PlayerSlots.adminSlots, ply:EntIndex()), table.KeyFromValue(PlayerSlots.vipSlots, ply:EntIndex()), table.KeyFromValue(PlayerSlots.regularSlots, ply:EntIndex())
	if aKey then
		print(ply:Nick() .. " quitted an admin slot")
		table.remove(PlayerSlots.adminSlots, aKey)
	elseif vKey then
		print(ply:Nick() .. " quitted a vip slot")
		table.remove(PlayerSlots.vipSlots, vKey)
	elseif rKey then
		print(ply:Nick() .. " quitted a regular slot")
		table.remove(PlayerSlots.regularSlots, rKey)
	else
		print("FUCK YOU MARMOTTE :D")
	end
	PlayerSlots.fillRegularSlots()
end

hook.Add("EntityRemoved", "PlayerSlotsDisconnectHack", function(ent)
	if ent:IsPlayer() then
		PlayerSlots.HandleDisconnect(ent)
	end
end)