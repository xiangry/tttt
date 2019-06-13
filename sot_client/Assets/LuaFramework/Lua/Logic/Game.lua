require "Logic/CtrlManager"
require "Common/functions"

--管理器--
Game = {};
local this = Game;

function Game.InitViewPanels()
    require ("ui/battle/BattleUIPanel")
end

--初始化完成，发送链接服务器信息--
function Game.OnInitOK()

    --注册LuaView--
    this.InitViewPanels();

    CtrlManager.Init();
    local ctrl = CtrlManager.GetCtrl(CtrlNames.BattleUI);
    logWarn('LuaFramework ctrl --->>>' .. tostring(ctrl));
    if ctrl ~= nil then
        ctrl:Awake();
    end
       
    logWarn('LuaFramework InitOK--->>>');
end

--销毁--
function Game.OnDestroy()
	--logWarn('OnDestroy--->>>');
end
