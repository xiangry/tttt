---@class BattleUI
local BattleUI = Class("BattleUI", UiBaseClass)
_G["BattleUI"] = BattleUI

function BattleUI:Init(data)
	self.pathRes = "panel_battle";

	UiBaseClass.Init(self,data)
end

--启动事件--
function BattleUI:InitUI(obj)
	self.btnOpen = obj.transform:Find("animation/top_cont/control/btn_pause").gameObject;
	self.luaBehavior:AddClick(self.btnOpen, Utility.handler(self, self.OnClick));

	log("self.btnOpen ---------------- " .. tostring(self.btnOpen))

	UiBaseClass.InitUI(self, obj)
end

--单击事件--
function BattleUI:OnClick(go)
	log("OnClick---->>>"..go.name);
end

return BattleUI