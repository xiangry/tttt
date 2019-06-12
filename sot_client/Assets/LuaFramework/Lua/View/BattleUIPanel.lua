local transform;
local gameObject;

BattleUIPanel = {};
local this = BattleUIPanel;

--启动事件--
function BattleUIPanel.Awake(obj)
	gameObject = obj;
	transform = obj.transform;

	this.InitPanel();
	logWarn("Awake lua--->>"..gameObject.name);
end

--初始化面板--
function BattleUIPanel.InitPanel()
	--this.btnOpen = transform:Find("Open").gameObject;
	--this.gridParent = transform:Find('ScrollView/Grid');
end

--单击事件--
function BattleUIPanel.OnDestroy()
	logWarn("OnDestroy---->>>");
end