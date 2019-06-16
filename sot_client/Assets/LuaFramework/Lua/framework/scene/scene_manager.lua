--[[
file	scene_manager.lua
author	dengchao
time	2015.3.19

]]--

---@class SceneManager 场景管理器
---@field sceneList table[]
SceneManager = {}
SceneManager.sceneList = {}

function SceneManager.PushScene(scene, param)
    if SceneManager.is_loading_secene then
        app.log_error("正在加载场景的时候PushScene "..tostring(scene._className)..debug.traceback())
    end
    -- UiSceneChange.Enter(scene, param)
    -- UiSceneChange.SetEnterCallback(SceneManager.PushSceneCallback, {scene=scene, param = param})
    -- UiSceneChange.SetExitCallback(function()
    --         UiSceneChange.Destroy();
    --         local currentSceneAndData = SceneManager.GetCurrentScene();
    --         if currentSceneAndData then
    --             currentSceneAndData.scene:StartFight();
    --         end
    --         end )
    SceneManager.PushSceneCallback({scene=scene, param = param});
end

function SceneManager.PushSceneCallback(data)
    ResourceManager.GC(false, true);
    ResourceManager.SetAutoGC(false);
    
    local currentSceneAndData = SceneManager.GetCurrentScene();
    local sceneAndData = {};
    sceneAndData.scene = data.scene:new();
    sceneAndData.sceneData = data.param;
    table.insert(SceneManager.sceneList,sceneAndData);
    if currentSceneAndData then
        currentSceneAndData.scene:Pause(currentSceneAndData.sceneData);
    end
    ResourceManager.DestroyRes();
    SceneManager.is_loading_secene = true;
    sceneAndData.scene:Start(data.param, function ()
            SceneManager.is_loading_secene = false;          
        end);
    --释放unused资源
    util.unload_unused_assets();
end

function SceneManager.GetCurrentScene()
    local index = #SceneManager.sceneList;
    if index == 0 then
        return nil;
    end
    return SceneManager.sceneList[index];
end

function SceneManager.PopScene()
    if SceneManager.is_loading_secene then
        app.log_error("正在加载场景的时候PopScene "..debug.traceback());
    end
    UiSceneChange.Enter();
    UiSceneChange.SetEnterCallback(SceneManager.PopSceneCallback);
    UiSceneChange.SetExitCallback(function()
        UiSceneChange.Destroy();
    end )
end

function SceneManager.PopSceneCallback()
    ResourceManager.GC(false, true);
    local currentSceneAndData = SceneManager.GetCurrentScene();
    if currentSceneAndData == nil or currentSceneAndData.scene == nil then
        app.log_error("SceneManager.PopSceneCallback pop场景失败"..debug.traceback());
        return;
    end
    table.remove(SceneManager.sceneList,#SceneManager.sceneList);
    currentSceneAndData.scene:Destroy(currentSceneAndData.sceneData);
    ResourceManager.DestroyRes();

    if #SceneManager.sceneList > 0 then
        currentSceneAndData = SceneManager.GetCurrentScene();
        SceneManager.is_loading_secene = true;
        currentSceneAndData.scene:Resume(currentSceneAndData.sceneData, function ()
            SceneManager.is_loading_secene = false;          
        end)
    end
end

function SceneManager.Update(dt)
    local currentSceneAndData = SceneManager.GetCurrentScene();
    if not currentSceneAndData then
        return;
    end
    currentSceneAndData.scene:Update(dt)
end

function SceneManager.LateUpdate(dt)
    local currentSceneAndData = SceneManager.GetCurrentScene();
    if not currentSceneAndData then
        return;
    end
    currentSceneAndData.scene:LateUpdate(dt)
end

function SceneManager.ReplaceScene(scene,param)
    if #SceneManager.sceneList == 0 then
        return SceneManager.PushScene(scene, param)
    end
    local currentSceneAndData = SceneManager.GetCurrentScene();
    if currentSceneAndData == nil then
        return;
    end
    UiSceneChange.Enter()
    UiSceneChange.SetEnterCallback(SceneManager.ReplaceSceneCallback, {scene=scene, param = param})
    UiSceneChange.SetExitCallback(function()
    UiSceneChange.Destroy();
    end)
end

function SceneManager.ReplaceSceneCallback(data)
    local currentSceneAndData = SceneManager.GetCurrentScene();
    table.remove(SceneManager.sceneList,#SceneManager.sceneList)

    currentSceneAndData.scene.isPause = false 
    currentSceneAndData.scene:Destroy(currentSceneAndData.sceneData);
    ResourceManager.DestroyRes()

    local sceneAndData = {}
    sceneAndData.scene = data.scene:new();
    sceneAndData.sceneData = data.param;
    table.insert(sceneList,sceneAndData);
    SceneManager.is_loading_secene = true;
    sceneAndData.scene:Start(data.param, function ()
        SceneManager.is_loading_secene = false;
    end)
end


function SceneManager.GetUIMgr()
    local currentSceneAndData = SceneManager.GetCurrentScene();
    if not currentSceneAndData or not currentSceneAndData.scene then
        return;
    end
    local fm = currentSceneAndData.scene:GetUIMgr();
    if fm then
        return fm
    else
        return uiManager;
    end 
end

function SceneManager.Destroy()
    for i, v in pairs(SceneManager.sceneList) do
        v.scene:Destroy(v.sceneData);
        v.scene = nil;
        v.sceneData = nil;
    end
    SceneManager.sceneList = {}
end

--Root.AddUpdate(SceneManager.Update)
--Root.AddLateUpdate(SceneManager.LateUpdate);

return SceneManager