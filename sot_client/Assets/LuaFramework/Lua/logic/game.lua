require "common/functions"

require "enum/main"
require "framework/main"

require("logic/main")

--管理器--
Game = {};
local this = Game;

--初始化完成，发送链接服务器信息--
function Game.OnInitOK()
    SOTUiManager = UiManager:new()
    SOTUiManager:PushUi(EUI.BattleUI)

    logError(table.tostring({a = "123", b = { c = "dddd"}}))
end

--销毁--
function Game.OnDestroy()
	logWarn('OnDestroy--->>>');
end
