---@class UiBaseClass  ui base
---@field showSceneCamera
---@field luaBehavior
local UiBaseClass = Class('UiBaseClass');
_G["UiBaseClass"] = UiBaseClass

UiBaseClass.showSceneCamera = false;
--------------------------------------------------

------------------------------------ LuaBehavior 组件方法 start ------------------------------------
UiBaseClass.Awake = function(obj)
    --this.gameObject = obj;
    --this.transform = obj.transform;
    log("Awake luaBehavior ===== " .. tostring(obj))
end
--------------------------------------- LuaBehavior 组件方法   end------------------------------------



function UiBaseClass.PreLoadUIRes(ui_class, call_back)
    if nil ~= ui_class and ui_class.GetResList ~= nil and type(ui_class.GetResList) == "function" then
        local res_list = ui_class.GetResList()
        for k, v in pairs(res_list) do
            ResourceLoader.LoadAsset(v, call_back, v);
        end

        return res_list;
    end

    return nil
end

function UiBaseClass.PreLoadTexture(texture_file, call_back)
    if nil ~= texture_file and type(texture_file) == 'string' then
        ResourceLoader.LoadTexture(texture_file, call_back);
        return true;
    end

    return false;
end

---初始化
function UiBaseClass:Init(data)
    self.showed = true
    self.panel_name = self._className
    self.load_res_cnt = 0
    self:InitData(data);
    self:Restart(data);
end

---重新开始
function UiBaseClass:Restart(data)
    if self.ui then
        return false;
    end

    self.loadedCallBack = nil
    self.isCallNow = true
    self.showed = true;    
    self._isLoadAsset = false;

    self._initData = data
    self.is_destroyed = false
    self:RegistFunc();
    self:MsgRegist();
    self:RestartData(data)
    self:LoadUI();
    return true;
end

---设置重入数据 -- InitData()之后, LoadUI()之前
function UiBaseClass:RestartData(data)
    --根据需要重写该函数
end

function UiBaseClass:GetInitData()
    return self._initData
end

function UiBaseClass:SetInitData(data)
    self._initData = data
end

---初始化数据
function UiBaseClass:InitData(data)
    self.ui = nil;
    self.bindfunc = {};
    self.showLock = true;
end

---析构函数
function UiBaseClass:DestroyUi(is_pop)
    if self.is_destroyed then
        return
    end
    self.is_destroyed = true
    self._initData = nil
    if self.ui and self._isLoadAsset then
        self._isLoadAsset = false;
        self.ui:set_active(false)
        self.ui:set_parent(nil)
        self.ui = nil
    end
    PublicFunc.ClearUserDataRef(self)
    self:MsgUnRegist();
    self:UnRegistFunc();
    ResourceLoader.ClearGroupCallBack(self.panel_name)
    if self.showLock then
        g_ScreenLockUI.Hide()
    end
    self:__HideUiLoading()
end

--显示ui
function UiBaseClass:Show()
    self.showed = true
    if not self.ui then
        return false;
    end
    self.ui:set_active(true);
    return true;
end

function UiBaseClass:ShowParam(param)
end

function UiBaseClass:IsShow()
     if not self.ui then
         return false;
     end
    -- return self.ui:get_active();

    return self.showed
end
--隐藏ui
function UiBaseClass:Hide()
    self.showed = false
    if not self.ui then
        return false;
    end
    self.ui:set_active(false);
    return true;
end

--注册回调函数
function UiBaseClass:RegistFunc()
end

--注销回调函数
function UiBaseClass:UnRegistFunc()
    for k,v in pairs(self.bindfunc) do
        if v ~= nil then
            Utility.unbind_callback(self, v);
        end
    end
end

--注册消息分发回调函数
function UiBaseClass:MsgRegist()
end

--注销消息分发回调函数
function UiBaseClass:MsgUnRegist()
end

--加载UI
function UiBaseClass:LoadUI()

    if type(self._initData) == 'table' and self._initData.uiNode then
        self.ui = self._initData.uiNode
        self:InitUIUseExistNode()
        return
    end

    if self.ui or not self.pathRes then
        return false;
    end
    --
    --if app.get_time_scale() > 0 then
    --    if self.showLock then
    --        g_ScreenLockUI.Show()
    --    end
    --end
    --app.log_error("加载资源 "..self.panel_name.." "..debug.traceback())
    self:OnLoadUI()
    self:___LoadUI()
    return true;
end


function UiBaseClass:OnLoadUI()
    -- SkillTips.EnableSkillTips(false);
end

--加载函数
function UiBaseClass:___LoadUI()
    --self.__loadingUIId = GLoading.Show(GLoading.EType.loading);
    --ResourceLoader.LoadAsset(self.pathRes, self.bindfunc['on_main_ui_loaded'], self.panel_name);
    panelMgr:CreatePanel(self.pathRes, self, Utility.handler(self, self.on_main_ui_loaded));
    --self.load_res_cnt = self.load_res_cnt + 1
end

function UiBaseClass:__HideUiLoading()
    if self.__loadingUIId then
        GLoading.Hide(GLoading.EType.loading, self.__loadingUIId);
        self.__loadingUIId = nil
    end
end

function UiBaseClass:InitUIUseExistNode()
    self:__HideUiLoading()
end

--初始化UI
function UiBaseClass:InitUI(asset_obj)

end

function UiBaseClass:GetParent()
    return self.ui:get_parent()
end

function UiBaseClass:SetParent(parent)
    if self.ui == nil then return end

    self.ui:set_parent(parent)
end

function UiBaseClass:SetLoadedCallback(cb)
    if self:IsLoaded() then
        cb()
    else
        self.loadedCallBack = cb;
    end
end

function UiBaseClass:SetIsCallNow(v)
    self.isCallNow = v
end

function UiBaseClass:IsMainResLoaded()
    return self.ui ~= nil
end

function UiBaseClass:IsExtraResLoaded()
    return true;
end

function UiBaseClass:IsLoaded()
    return self:IsMainResLoaded() and self:IsExtraResLoaded()
end


--资源加载回调
function UiBaseClass:on_main_ui_loaded(obj)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.panel = self.transform:GetComponent('UIPanel');
    self.luaBehavior = self.transform:GetComponent('LuaBehaviour');
    log("on_main_ui_loaded luaBehavior ===== " .. tostring(self.luaBehavior))

    self:OnLoadedCallBack()
    self:InitUI(obj)
end

function UiBaseClass:OnLoadedCallBack()
    if self.loadedCallBack then
        self.loadedCallBack()
        self.loadedCallBack = nil
    end
end

---帧更新
function UiBaseClass:Update(dt)
	if not self.ui then
		return false
	end
    return true;
end

function UiBaseClass:UpdateUi()
    if not self.ui then
		return false
	end
    return true;
end