BattleUICtrl = {};
local this = BattleUICtrl;

local panel;
local prompt;
local transform;
local gameObject;

--构建函数--
function BattleUICtrl.New()
	logWarn("BattleUICtrl.New--->>");
	return this;
end

function BattleUICtrl.Awake()
	logWarn("BattleUICtrl.Awake--->>");
    panelMgr:CreatePanel('BattleUI', "battle/battleuipanel", this.OnCreate);
end

--启动事件--
function BattleUICtrl.OnCreate(obj)
	gameObject = obj;
	transform = obj.transform;
	panel = transform:GetComponent('UIPanel');
	prompt = transform:GetComponent('LuaBehaviour');
	logWarn("Start lua--->>"..gameObject.name);

	--prompt:AddClick(PromptPanel.btnOpen, this.OnClick);
	--resMgr:LoadPrefab('prompt_item', { 'PromptItem' }, this.InitPanel);
end

--初始化面板--
function BattleUICtrl.InitPanel(objs)
end

--滚动项单击--
function BattleUICtrl.OnItemClick(go)
    log(go.name);
end

--单击事件--
function BattleUICtrl.OnClick(go)
	logWarn("OnClick---->>>"..go.name);
end