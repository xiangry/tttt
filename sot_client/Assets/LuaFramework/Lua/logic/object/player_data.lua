---@class PlayerData 用户数据
local PlayerData = Class("PlayerData")
_G["PlayerData"] = PlayerData

function PlayerData:Init(data)
	if data then
		self:UpdateData(data);
	end
end

function PlayerData:UpdatePlayerData(info)

end

function PlayerData:UpdateData(info)

end
