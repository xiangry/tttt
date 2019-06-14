local transform;
local gameObject;

BattleUIPanel = {};
local this = BattleUIPanel;

--启动事件--
function BattleUIPanel.Awake(obj, arg1, arg2, arg3)
	gameObject = obj;
	transform = obj.transform;

	this.InitPanel();
	--logError("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function BattleUIPanel.InitPanel()
	logError("transform == " .. tostring(transform))
	this.btnOpen = transform:Find("animation/top_cont/control/btn_pause").gameObject;
end

--单击事件--
function BattleUIPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end