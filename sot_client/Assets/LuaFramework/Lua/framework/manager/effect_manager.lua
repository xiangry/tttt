---@class EffectManager
local EffectManager = Class("EffectManager")
_G["EffectManager"] = EffectManager

function EffectManager:Init(inf)
    self.filePath = inf.filePath
    self.placeHolder = nil
    self.effectEntity = nil
    self.GID = inf.gid;
    self.releaseTime = nil
    self.destroyTime = nil
    self.isActive = false;
    self.last_x = nil;
    self.last_y = nil;
    self.last_z = nil;
    self.local_scale = nil;
    self.isSelfEffect = false;
    self.obj_collision = { }
    self.playSpeed = nil; --
end
function EffectManager:Destroy(force)
    if not force then
        SnkEffectManager.deleteEffect(self:GetGID())
        return
    end
end
function EffectManager:__Dispose()

    if self.placeHolder then
        self.placeHolder:set_active(false);
        self.placeHolder = nil;
    end
    if self.effectEntity then
        self.effectEntity:set_active(false);
        self.effectEntity = nil;
    end
    if self.bindfunc then
        for k, v in pairs(self.bindfunc) do
            Utility.unbind_callback(self, v)
        end
        self.bindfunc = nil;
    end
end

function EffectManager:GetFilePath()
    return self.filePath;
end

function EffectManager:GetGID()
    return self.GID;
end

function EffectManager:getNode()
    if self.placeHolder ~= nil then
        return self.placeHolder
    else
        return self.effectEntity
    end
end

function EffectManager:GetName()    
    local node = self:getNode();
    if not node then
        return
    end
    return node:get_name();
end

function EffectManager:set_camp(camp)
    self.camp = camp;
    self:CampEffect();
end

function EffectManager:CampEffect()
    if not self.effectEntity then
        return;
    end
    if not self.leftEffectEntity then
        self.leftEffectEntity = self.effectEntity:get_child_by_name("left");
    end
    if not self.rightEffectEntity then
        self.rightEffectEntity = self.effectEntity:get_child_by_name("right");
    end
    if self.camp == 1 then
        if self.leftEffectEntity then
            self.leftEffectEntity:set_local_position(0, 0, 0);
        end
        if self.rightEffectEntity then
            self.rightEffectEntity:set_local_position(99999, -99999, 99999);
        end
    else
        if self.leftEffectEntity then
            self.leftEffectEntity:set_local_position(99999, -99999, 99999);
        end
        if self.rightEffectEntity then
            self.rightEffectEntity:set_local_position(0, 0, 0);
        end
    end
end

function EffectManager:GetNodeObj(name)
    if self.effectEntity then
        return self.effectEntity:get_child_by_name(name);
    end
end

function EffectManager:set_parent(parent, entity)
    self:getNode():set_parent(parent);
    --通知他下面挂载了一个特效  删除时需要移出来
    --解决bug：当一个怪身上挂有攻击光圈特效时，此时死了却还没有消失，又攻击另外的怪的时候，光圈特效会移动到另外的人身上
    --此时应该去掉原有怪的挂载关系，不然另外的怪身上的光圈会在死的那个怪消失的时候，被移出父节点，位置设置为10000
    -- if self.parentGid ~= nil then
    --     local obj = ObjectManager.GetObjectByName(self.parentEntityName);
    --     if obj then
    --         obj:NoticeMoveMountingEffect(self:GetGID());
    --     end
    --     self.parentEntityName = nil;
    -- end
    -- if entity then
    --     self.parentEntityName = entity:GetName();
    --     entity:NoticeMountingEffect(self:GetGID());
    -- end
end

function EffectManager:set_position(x, y, z)
    if x == nil or y == nil or z == nil then
        app.log_error("SnkEffect:set_position" .. debug.traceback())
        return
    end

    if nil == self:getNode() then
        ----app.log_error("nfx nil effect "..table.tostring(self) ..debug.traceback())
        return
    end

    self:getNode():set_position(x, y, z)
    self.last_x, self.last_y, self.last_z = self:getNode():get_local_position();
end

function EffectManager:get_pid()
    return self:getNode():get_pid();
end 

function EffectManager:get_position()
    return self:getNode():get_position()
end

function EffectManager:__raw_set_local_position(x, y, z)
    self:getNode():set_local_position(x, y, z)
end

function EffectManager:set_local_position(x, y, z)
    self:__raw_set_local_position(x, y, z)
    self.last_x, self.last_y, self.last_z = x, y, z
end

function EffectManager:get_local_position()
    return self:getNode():get_local_position()
end

function EffectManager:set_local_scale(x, y, z)

    if nil ~= self.placeHolder then
        self.placeHolder:set_local_scale(1, 1, 1)
    end

    if self.effectEntity ~= nil then
        self.effectEntity:set_local_scale(x, y, z)
    else
        self.local_scale = { x = x, y = y, z = z }
    end
end

function EffectManager:set_local_rotation(x, y, z)
    self:getNode():set_local_rotation(x, y, z)
end

function EffectManager:set_forward(x, y, z)
    self:getNode():set_forward(x, y, z)
end

function EffectManager:get_forward()
    return self:getNode():get_forward()
end

function EffectManager:set_rotationq(x, y, z, w)
    self:getNode():set_rotationq(x, y, z, w)
end

function EffectManager:get_rotation()
    return self:getNode():get_rotation()
end

function EffectManager:set_rotation(x, y, z)
    self:getNode():set_rotation(x, y, z)
end

function EffectManager:set_active(flag)
    if self:getNode() == nil then
        app.log_error("effect_node = nil "..debug.traceback())
        return;
    end
    -- self:getNode():opt_effect_reset_quality();


    if flag then
        if not self:getNode():get_active() then
            self:getNode():set_active(true);
        end

        if nil == self.last_x then
            self.last_x, self.last_y, self.last_z = self:get_local_position()
        end

        self:__raw_set_local_position(self.last_x, self.last_y, self.last_z)
        if nil ~= self.effectEntity then
            self.effectEntity:kof_effect_reset_state()            
        end
    else
        
        if nil ~= self.effectEntity then
            self.effectEntity:kof_effect_stop()
        end
        self:__raw_set_local_position(99999, -99999, 99999)
        --self:getNode():set_local_scale(1, 1, 1);
    end
    self.isActive = flag;
end

function EffectManager:__raw_set_local_position(x, y, z)
    self:getNode():set_local_position(x, y, z)
end

function EffectManager:set_place_holder(obj)
    self.placeHolder = obj;
end

function EffectManager:get_place_holder(obj)
    return self.placeHolder;
end

function EffectManager:setEffectEntity(obj)
    self.effectEntity = obj;
    self:CampEffect();
end

function EffectManager:getEffectEntity()
    return self.effectEntity;
end

function EffectManager:SetSpeed(speed)
    if speed < 0 or speed == self.playSpeed then
        return;
    end

    self.playSpeed = speed;

    if nil ~= self.effectEntity then
        self.effectEntity:opt_set_effect_play_speed(self.playSpeed)
    end
end

function EffectManager:Update(dt)
    if nil ~= self.effectEntity then
        self.effectEntity:kof_effect_update(dt)
    end
end

function EffectManager:__applySettingOnLoadOK()
    if self.playSpeed ~= nil and nil ~= self.effectEntity then
        self.effectEntity:opt_set_effect_play_speed(self.playSpeed)
    end

    if self.local_scale ~= nil and nil ~= self.effectEntity then
        self.effectEntity:set_local_scale(self.local_scale.x, self.local_scale.y, self.local_scale.z);
    end
end
-----------------------------------------特效管理器------------------------------
SnkEffectManager =
{
   place_holder_effect = "assetbundles/prefabs/fx/prefab/place_holder.assetbundle",
   effect_serno = 0,
   has_setup = false,
   -- 所有正在使用的特效列表
    allUsingObjList = { },
   -- 待用特效对象池 k: 资源名, v: {obj_list}
    standByObjPool = { },
   -- 自动回收检测的特效列表
    autoRecyleCheckObjList = { },
    --加载列表
    pending_loading_effect_obj = { },

    next_check_release_time = 0,
    --在池中的特效存在时间
    effectStandByTime = 100000,
}
function GGetFileName(filename)
    local _,b = string.find(filename,".*[/\\]")
    filename = string.sub(filename,b+1)
    filename = string.gsub(filename,'.assetbundle', '')
    return filename
end

function SnkEffectManager.CreateEffect(filePath, autoRelaseTime)
    if filePath == nil then
        app.log_error("SnkEffectManager.CreateEffect filePath==nil "..debug.traceback())
        return;
    end
    filePath = "assetbundles/prefabs/" .. filePath;
    -- --策略
    -- 1.从对象池中找
    -- 2.创建新的
    local nice_try = SnkEffectManager.__fetchObjectFromPool(filePath)
    if nice_try ~= nil then
        if nil ~= autoRelaseTime then
            nice_try.releaseTime = app.get_time() + autoRelaseTime
            SnkEffectManager.autoRecyleCheckObjList[nice_try:GetGID()] = nice_try;
        end
    end

    if nil ~= nice_try then
        SnkEffectManager.__add2UsingList(nice_try)
        nice_try:set_active(true)
        nice_try:set_parent(SnkEffectManager.sceneEffectObjNode)
        --重新创建的时候恢复播放速度标志(opt_replay_effect 会恢复内部的速度为1.0)
        if nice_try.playSpeed ~= nil then
            nice_try.playSpeed = 1.0
        end
        if nice_try:getNode() and (not nice_try:getNode():is_nil()) then
            nice_try:set_local_rotation(0, 0, 0);
            return nice_try;
        else
            SnkEffectManager.__ClearInvalidEffectFromPool(filePath, nice_try)
        end
    end

    --------------------------------------------------------------------------------.
    -- fix
    local releaseTime = nil
    if autoRelaseTime == nil then
        releaseTime = nil
    else
        releaseTime = app.get_time() + autoRelaseTime
    end

    local file_name = filePath;
    -- 从已加载资源列表找资源
    local effect_res = ResourceManager.GetResourceObject(file_name);

    local effect_obj = nil
    local gid = SnkEffectManager.__genSerNo();
    local effect_wapper = SnkEffect:new( { filePath = filePath, gid = gid })
    effect_wapper.releaseTime = releaseTime;
    local need_load = false
    if nil == effect_res then
        if not SnkEffectManager.placeHolderRes then
            return;
        end
        effect_obj = asset_game_object.create(SnkEffectManager.placeHolderRes)
        if nil == effect_obj then
            app.log_error("nfx create node by placeHolderRes failed..... ");
            return nil
        end
        effect_obj:set_parent(SnkEffectManager.sceneEffectObjNode);
        local posx, posy, posz = effect_obj:get_local_position()
        effect_wapper:set_place_holder(effect_obj);
        if effect_wapper:getNode() == nil then
            app.log_error("nfx filePath=" .. filePath)
        end
        -- 检查是否加载
        local loading_inf = SnkEffectManager.pending_loading_effect_obj[filePath];
        if nil == loading_inf then
            SnkEffectManager.pending_loading_effect_obj[filePath] = { }
            need_load = true
        end
        -- TIPS:这句一定要在load之前， 因为可能会遇到loadeffect立刻回调...
        table.insert(SnkEffectManager.pending_loading_effect_obj[filePath], {obj = effect_wapper, release_time = releaseTime});
    else
        effect_obj = asset_game_object.create(effect_res)
        effect_obj:set_parent(SnkEffectManager.sceneEffectObjNode)
        effect_obj:set_local_rotation(0, 0, 0);
        effect_wapper:setEffectEntity(effect_obj);
        if nil ~= releaseTime then
            effect_wapper.releaseTime = releaseTime
            SnkEffectManager.autoRecyleCheckObjList[effect_wapper:GetGID()] = effect_wapper
        else
            effect_wapper.releaseTime = nil;
        end
    end
    effect_wapper:set_active(true)
    SnkEffectManager.__add2UsingList(effect_wapper)

    ---------debug inf
    local fileName = GGetFileName(filePath);
    local time = 0;
    local ef_name = string.format("nfx_%d_%s_%s", effect_wapper:GetGID(), fileName, tostring(effect_wapper.releaseTime))
    effect_wapper.ef_name = ef_name
    if effect_wapper.placeHolder ~= nil then
        effect_wapper.placeHolder:set_name(ef_name)
    elseif effect_wapper.effectEntity ~= nil then
        effect_wapper.effectEntity:set_name(ef_name)
    else
        ----app.log_error("nfx set effect name error!");
    end
    -- 特效控制
    if need_load then
        SnkEffectManager.LoadEffect(filePath, effect_wapper:GetGID())
    end
    return effect_wapper
end


function SnkEffectManager.StartUp()
    SnkEffectManager.checkUpdateTime = 0;
    Root.AddUpdate(SnkEffectManager.Update);
    SnkEffectManager.LoadPlaceHolderRes();
end

function SnkEffectManager.LoadPlaceHolderRes()
    if SnkEffectManager.placeHolderRes == nil then
        SnkEffectManager.LoadEffect(SnkEffectManager.place_holder_effect, SnkEffectManager.__genSerNo())
    else
        app.log_error("nfx 重复初始化effectmanager.");
    end
end

function SnkEffectManager.Update(dt)
    local fight = SnkFightManager.GetLastFight()
    if fight then
        dt = dt * fight:GetFightShow().timeScale
    end
    ---@param v SnkEffect
    for _, v in pairs(SnkEffectManager.allUsingObjList) do
        v:Update(dt)
    end

    SnkEffectManager.checkUpdateTime = SnkEffectManager.checkUpdateTime + dt
    if SnkEffectManager.checkUpdateTime < 0.2 then --0.2秒更新一次
        return;
    end
    SnkEffectManager.checkUpdateTime = 0;
    -----------------------------------------------------------------

    SnkEffectManager.checkRelease();
end

function SnkEffectManager.LoadEffect(filePath, create_obj)
    if not filePath then
        return;
    end
    local file = filePath or ""

    local call_back = g_kof_on_load_effect_callback;
    if filePath == SnkEffectManager.place_holder_effect then
        call_back = g_kof_on_load_effect_place_holder_callback;
    end
    ResourceLoader.LoadAsset(file, { func = call_back, user_data = { name = file, create_obj = create_obj } }, nil)
end

function g_kof_on_load_effect_callback(parm, pid, fpath, asset_obj, error_info)
    if nil == asset_obj then
        ----app.log_error("nfx ani 特效加载失败:" .. parm.name);
        return;
    end
    -- 检查是否需要创建？ 预加载了就不需要创建了
    if not parm.create_obj then
        return;
    end
    
    local _effect_inf = SnkEffectManager.pending_loading_effect_obj[parm.name];
    if _effect_inf == nil then
        return;
    end
    for k, v in pairs(_effect_inf) do
        local eo = v.obj
        local effect_obj = asset_game_object.create(asset_obj)

        eo:setEffectEntity(effect_obj);
        if eo:get_place_holder():get_name() == nil then 
            eo.placeHolder = nil;
            eo.effectEntity = effect_obj;
            effect_obj:set_name(eo.ef_name);
            eo:set_active(eo.isActive);
        else 
            effect_obj:set_parent(eo:get_place_holder())
            effect_obj:set_local_position(0, 0, 0)
            effect_obj:set_local_rotation(0, 0, 0)
        end 
        
        if v.release_time ~= nil then
            v.obj.releaseTime = v.release_time;
            SnkEffectManager.autoRecyleCheckObjList[v.obj:GetGID()] = v.obj;
        end

        eo:__applySettingOnLoadOK();
    end
    SnkEffectManager.pending_loading_effect_obj[parm.name] = nil;
end 

function g_kof_on_load_effect_place_holder_callback(parm, pid, fpath, asset_obj, error_info)
    if nil == asset_obj then
        return;
    end

    SnkEffectManager.placeHolderRes = asset_obj;
    SnkEffectManager.effectPoolRootNode = asset_game_object.create(SnkEffectManager.placeHolderRes);
    SnkEffectManager.effectPoolRootNode:set_position(99999, -99999, 99999)
    SnkEffectManager.effectPoolRootNode:set_parent(nil)
    SnkEffectManager.effectPoolRootNode:set_name("kof_effect_pool_ex")
    asset_game_object.dont_destroy_onload(SnkEffectManager.effectPoolRootNode);

    SnkEffectManager.sceneEffectObjNode = asset_game_object.create(SnkEffectManager.placeHolderRes);
    SnkEffectManager.sceneEffectObjNode:set_position(0,0,0)
    SnkEffectManager.sceneEffectObjNode:set_parent(nil)
    SnkEffectManager.sceneEffectObjNode:set_name("kof_scene_effect")
    asset_game_object.dont_destroy_onload(SnkEffectManager.sceneEffectObjNode);
end

function SnkEffectManager.__genSerNo()
    SnkEffectManager.effect_serno = SnkEffectManager.effect_serno + 1
    return SnkEffectManager.effect_serno;
end

function SnkEffectManager.__fetchObjectFromPool(filePath)
    local obj_list = SnkEffectManager.standByObjPool[filePath]
    if nil == obj_list then
        return nil
    end

    for k, v in pairs(obj_list) do
        obj_list[k] = nil
        return v
    end
end

function SnkEffectManager.__add2UsingList(obj)
    if nil == obj or nil == obj:GetFilePath() or nil == obj:GetGID() then
        ----app.log_error(string.format("hfx __add2UsingList 错误的特效对象 :%s, GID：%s, %s", tostring(obj.id), tostring(obj:GetGID()), debug.traceback()))
        return false;
    end
    SnkEffectManager.allUsingObjList[obj:GetGID()] = obj
end

function SnkEffectManager.__ClearInvalidEffectFromPool(filePath, effect_obj)
    SnkEffectManager.allUsingObjList[effect_obj:GetGID()] = nil
    local obj_list = SnkEffectManager.standByObjPool[filePath]
    if nil == obj_list then
        return
    end
    for k, v in pairs(obj_list) do
        if v == effect_obj then
            obj_list[k] = nil
            return
        end
    end
end

function SnkEffectManager.checkRelease(releaseAll)
    local now = app.get_time();

    if SnkEffectManager.next_check_release_time <= now then
        SnkEffectManager.next_check_release_time = now + 0.5
        -- seconds
    else
        if not releaseAll then
            return
        end
    end


    for k, v in pairs(SnkEffectManager.autoRecyleCheckObjList) do
        if releaseAll or now >= v.releaseTime then
            -- 放入池中
            SnkEffectManager.__putObjectIntoPool(v)

            -- 从记录中清除
            SnkEffectManager.__removeFromUsingList(v)
            SnkEffectManager.__removeFromAutoRecyleList(v)
        end
    end
end

function SnkEffectManager.__putObjectIntoPool(effect_obj)
    if nil == effect_obj then
        ----app.log_error("nfx put nil obj into pool")
        return
    end

    local obj_list = SnkEffectManager.standByObjPool[effect_obj:GetFilePath()]
    if nil == obj_list then
        SnkEffectManager.standByObjPool[effect_obj:GetFilePath()] = { }
        obj_list = SnkEffectManager.standByObjPool[effect_obj:GetFilePath()]
    end

    obj_list[effect_obj:GetGID()] = effect_obj
    effect_obj:set_parent(SnkEffectManager.effectPoolRootNode)
    effect_obj:set_active(false)
    effect_obj:set_local_scale(1, 1, 1)

    effect_obj.releaseTime = nil
    effect_obj.destroyTime = app.get_time() + SnkEffectManager.effectStandByTime;
end

function SnkEffectManager.__removeFromUsingList(obj)
    if nil == obj or nil == obj:GetFilePath() then
        ----app.log_error(string.format("hfx __removeFromUsingList 错误的特效对象 :%d, GID：%d", tostring(obj.id), tostring(obj:GetGID())))
        return false
    end
    SnkEffectManager.allUsingObjList[obj:GetGID()] = nil
end

function SnkEffectManager.__removeFromAutoRecyleList(obj)
    if nil == obj or nil == obj:GetFilePath() or nil == obj:GetGID() then
        ----app.log_error(string.format("hfx __removeFromAutoRecyleList 错误的特效对象 :%d, GID：%d", tostring(obj.id), tostring(obj:GetGID())))
        return false
    end
    SnkEffectManager.autoRecyleCheckObjList[obj:GetGID()] = nil
end

-- isDestroy 直接删除资源不放入缓存池
function SnkEffectManager.deleteEffect(gid, isDestroy)
    local eo = SnkEffectManager.allUsingObjList[gid]
    if nil == eo then
        ----app.log_error("nfx 删除特效的时候已经不存在了. GID:"..tostring(gid)..debug.traceback())
        return
    end
    eo:set_active(false);
    -- ui特效中有些资源需要即时删除避免报错（战队挑战竞技界面特效）
    if not isDestroy then
        SnkEffectManager.__putObjectIntoPool(eo)
    end
    SnkEffectManager.__removeFromUsingList(eo)
    SnkEffectManager.__removeFromAutoRecyleList(eo)

    if isDestroy then
        SnkEffectManager.__disposeEffect(eo);
    end
end

function SnkEffectManager.__disposeEffect(eo)
    local gid = eo.GID;
    eo:__Dispose();
    if SnkEffectManager.pending_loading_effect_obj[eo:GetFilePath()] then
        for k, v in pairs(SnkEffectManager.pending_loading_effect_obj[eo:GetFilePath()]) do
            if v.obj.GID == gid then
                SnkEffectManager.pending_loading_effect_obj[eo:GetFilePath()][k] = nil;
                break;
            end
        end
    end
end

--切换场景的时候需要立刻回收 ‘托管’ 的特效对象
function SnkEffectManager.__ClearAutoReleaseEffectObj()
    SnkEffectManager.checkRelease(true)
end

function SnkEffectManager.DestroyRes(force)
    SnkEffectManager.__ClearAutoReleaseEffectObj();
    SnkEffectManager.__ClearEffectPoolObj();
end

function SnkEffectManager.__ClearEffectPoolObj()
    for k, v in pairs(SnkEffectManager.standByObjPool) do
        for kk, vv in pairs(v) do
            vv:__Dispose();
        end
        v = {}
    end
    SnkEffectManager.standByObjPool = {}
end