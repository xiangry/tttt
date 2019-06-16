require "enum/main"
require "framework/main"

require("ui/battle/BattleUICtrl")
require "Common/functions"

--管理器--
Game = {};
local this = Game;

--初始化完成，发送链接服务器信息--
function Game.OnInitOK()
    --local battleUi = BattleUICtrl:new()
    --local ctrl = BattleUICtrl.New()
    --ctrl.Awake()
    SOTUiManager = UiManager:new()
    SOTUiManager:PushUi(EUI.BattleUICtrl)
end

--销毁--
function Game.OnDestroy()
	--logWarn('OnDestroy--->>>');
end
