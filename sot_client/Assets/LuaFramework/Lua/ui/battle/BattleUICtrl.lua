---@class BattleUICtrl
local BattleUICtrl = Class("BattleUICtrl", UiBaseClass)
_G["BattleUICtrl"] = BattleUICtrl

function BattleUICtrl:Init(data)
	self.pathRes = "panel_battle";

	UiBaseClass.Init(self,data)
end

--启动事件--
function BattleUICtrl:InitUI(obj)
	self.btnOpen = obj.transform:Find("animation/top_cont/control/btn_pause").gameObject;
	self.luaBehavior:AddClick(self.btnOpen, Utility.handler(self, self.OnClick));

	logError("self.btnOpen ---------------- " .. tostring(self.btnOpen))

	UiBaseClass.InitUI(self, obj)
end

--单击事件--
function BattleUICtrl:OnClick(go)
	logError("OnClick---->>>"..go.name);
end