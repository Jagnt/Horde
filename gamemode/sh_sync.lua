if SERVER then
util.AddNetworkString("Horde_SyncToLocal")
util.AddNetworkString("Horde_SyncToServer")
end

local EXPECTED_HEADER = "Horde_Rank"

function HORDE:SyncToLocal(ply)
    -- Sync ranks from server to local.
    -- Player is already in the server so, just ask local to sync
    if SERVER then
        net.Start("Horde_SyncToLocal")
        net.Send(ply)
    end
end

net.Receive("Horde_SyncToLocal", function ()
    if SERVER then return end
    local ply = LocalPlayer()
    if not ply:IsValid() then return end
    local local_levels = {}
    local local_exps = {}
	local path, strm

	if not file.IsDir("horde/ranks", "DATA") then
		file.CreateDir("horde/ranks", "DATA")
	end

	path = "horde/ranks/" .. HORDE:ScrubSteamID(ply) .. ".txt"

	if not file.Exists(path, "DATA") then
		print("Path", path, "does not exist!")
		return
	end

	strm = file.Open(path, "rb", "DATA")
		local header = strm:Read(#EXPECTED_HEADER)

		if header == EXPECTED_HEADER then
			for _, _ in pairs(HORDE.classes) do
                local order = strm:ReadShort()
				local exp = strm:ReadLong()
				local level = strm:ReadShort()
				if order == nil then
				else
					local class_name = HORDE.order_to_class_name[order]
					local_levels[class_name] = level
					local_exps[class_name] = exp
				end
            end
		else
			for _, class in pairs(HORDE.classes) do
                local_levels[class.name] = 0
				local_exps[class.name] = 0
            end
		end
	strm:Close()

    for name, class in pairs(HORDE.classes) do
        local server_level = ply:Horde_GetLevel(name)
        local server_exp = ply:Horde_GetExp(name)
        local_levels[name] = math.max(server_level, local_levels[name] or 0)
        local_exps[name] = math.max(server_exp, local_exps[name] or 0)
    end

    -- Save
	strm = file.Open(path, "wb", "DATA" )
		strm:Write(EXPECTED_HEADER)
        for name, class in pairs(HORDE.classes) do
            strm:WriteShort(class.order)
            strm:WriteLong(local_exps[name])
			strm:WriteShort(local_levels[name])
        end
	strm:Close()

    notification.AddLegacy("Sucessfully synced local data from server.", NOTIFY_GENERIC, 5)
end)

function HORDE:SyncToServer(ply)
end