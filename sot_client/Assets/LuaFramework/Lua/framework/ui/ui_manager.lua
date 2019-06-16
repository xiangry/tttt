---ui管理
---@class UiManager
local UiManager = Class("UiManager");
_G["UiManager"] = UiManager

EUI  = {
	BattleUICtrl                     = "BattleUICtrl";
}

local uiInformation = {};
uiInformation[EUI.BattleUICtrl] = { btnBack = false, background = false, showLast = false, };

-------------------------导航条栏目图片标题(没有设置则不显示)---------------
uiInformation[EUI.BattleUICtrl].sp_title = "title_1"
uiInformation[EUI.BattleUICtrl].coin = { id = 21, get_way = false, }
------------------------ 隐藏 导航条（默认0全部显示 1隐藏 2隐藏三个货币栏） ----------------------
uiInformation[EUI.BattleUICtrl].showState = 1
------------------------ 导航条公用底图（默认底图 ENUM.PublicBgImage.DLD 可不配置） ----------------------
uiInformation[EUI.BattleUICtrl].resBg = ""
------------------------ ui界面的背景音乐，不配置的话就不改变 ----------------------
uiInformation[EUI.BattleUICtrl].backAudioId = ENUM.EUiAudioBGM.MainCityBgm;

require("ui/battle/BattleUICtrl")

UiManager.ClassList = {
	[EUI.BattleUICtrl] = { BattleUICtrl },
}

function UiManager:InitData()
	self.destroy_stack_mark = {}
	self.ui_stack           = {};
	self.scene_list         = {};
	self.have_destroy       = false;
	self.curBackAudioId     = 81000003;

	-- 把没有在ui_stack中的ui，放入global_uis中，在场景切换的时候统一销毁这些全局ui
	self.global_uis         = {};

	self.ui_animation       = {};
end

function UiManager:createUI(id, param)
	local new_info = uiInformation[id];
	app.log("show UI:"..id)
	if self.scene_list[id] == nil then
		self.scene_list[id] = {};
		if self.ClassList[id] == nil then
			app.log_error("UiManager:createUI id=" .. tostring(id))
		end
		if self.ClassList[id][1] == nil then
			app.log_error("UiManager:createUI2 id=" .. tostring(id))
		end
		self.scene_list[id].scene = self.ClassList[id][1]:new(param);
	else
		if self.scene_list[id].scene then
			if self.scene_list[id].scene.Restart and not self.scene_list[id].scene.ui then
				self.scene_list[id].scene:Restart(param);
			else
				if self.scene_list[id].scene.ShowParam then
					self.scene_list[id].scene:ShowParam(param);
				end
				self.scene_list[id].scene:Show();
				self.scene_list[id].scene:UpdateUi();
			end
		else
			app.log_error("#lhf#self.scene_list[" .. id .. "].scene is nil. info:" .. table.tostring(self.scene_list[id]) .. debug.traceback());
		end
	end
	self.scene_list[id].isShow = true;
	return self.scene_list[id], new_info;
end

function UiManager:Init()
	self:InitData();
end

function UiManager:RemoveUi(push_uid)
	if self.ui_stack[#self.ui_stack] == push_uid then
		self:PopUi()
		return ;
	end
	for index, uid in ipairs(self.ui_stack) do
		if uid == push_uid then
			local ui = self.scene_list[push_uid];
			if ui then
				ui.scene:DestroyUi(true);
			end
			self.scene_list[push_uid] = nil;
			table.remove(self.ui_stack, index);

			g_SnkNoticeManager:Notice(ENUM.NoticeType.PopUi, push_uid)
			return
		end
	end
end

---@param scene_id string
---@param param table	功能需要的参数
function UiManager:PushUi(scene_id, param)
	app.log(tostring(scene_id) .. "....." .. debug.traceback())
	local cur_scene_id = nil;
	if #self.ui_stack ~= 0 then
		cur_scene_id = self.ui_stack[#self.ui_stack];
	end
	--[[push相同ui时，栈顶与push的id相同时，直接跳过]]
	if cur_scene_id == scene_id then
		return self.scene_list[scene_id].scene;
	end
	self:PushUIStack(scene_id)

	--如果管理器已经销毁，则只进行栈操作，不显示ui
	if self.have_destroy == true then
		if cur_scene_id and self.scene_list[cur_scene_id] and self.scene_list[cur_scene_id].scene then
			self:_HideLastUi(scene_id, true);
		end
		self.ClassList[scene_id].temp_param = param
		return ;
	end

	self:_HideLastUi(scene_id, false);

	-- 显示当前界面
	param           = param or self.ClassList[scene_id][2];
	local new_scene = self:createUI(scene_id, param);
	local cur_scene = new_scene;

	g_SnkNoticeManager:Notice(ENUM.NoticeType.PushUi, scene_id, new_scene)
	cur_scene.scene:SetLoadedCallback(
				function()
					g_SnkNoticeManager:Notice(ENUM.NoticeType.PushUiLoadOk, scene_id)
					self:ChangeBackAudio(scene_id)
				end
	);

	return self.scene_list[scene_id].scene
end

function UiManager:PopUi(param, bOnlyStack)
	if self.isPoping then
		return ;
	end
	--隐藏tips
	if #self.ui_stack <= 1 then
		app.log_error("UiManager PopUi but #ui_stack < 1 " .. tostring(param))
	else
		local cur_scene_id = self.ui_stack[#self.ui_stack];
		app.log("PopUi ui:" .. tostring(cur_scene_id));
		-- self.scene_list[cur_scene_id].isDestroy = true;
		self.ui_stack[#self.ui_stack] = nil;

		-- 显示后面的界面
		local scene_id                = self.ui_stack[#self.ui_stack];
		local new_scene, new_info, new_id;
		for i = #self.ui_stack, 1, -1 do
			local id         = self.ui_stack[i];
			local cf         = uiInformation[id];
			local scene_info = self.scene_list[id];
			if scene_info then
				if bOnlyStack then
					scene_info.isShow = true;
				else
					if scene_id == id then
						new_id              = id;
						new_scene, new_info = self:createUI(id, param);
					else
						new_id              = id;
						new_scene, new_info = self:createUI(id);
					end
				end
				if not cf.showLast then
					break ;
				end
			else
				break ;
			end
		end
		if not bOnlyStack then
			self.isPoping = true;
			if new_info.background then
				local cur_scene_info = self.scene_list[cur_scene_id];
				self.isPoping        = false;
				if cur_scene_info then
					if not bOnlyStack then
						if cur_scene_info.scene then
							-- 销毁当前界面
							cur_scene_info.scene:DestroyUi(true);
						else
							app.log_error("#lhf#cur_scene_id:" .. tostring(cur_scene_id) .. " info:" .. table.tostring(cur_scene_info) .. debug.traceback());
						end
					end
				end
			end
			new_scene.scene:SetLoadedCallback(
						function()
							self:ChangeBackAudio(scene_id)
							if not new_info.background then
								self.isPoping = false;
								local cur_scene_info = self.scene_list[cur_scene_id];
								if cur_scene_info then
									if not bOnlyStack then
										if cur_scene_info.scene then
											-- 销毁当前界面
											cur_scene_info.scene:DestroyUi(true);
										else
											app.log_error("#lhf#cur_scene_id:" .. tostring(cur_scene_id) .. " info:" .. table.tostring(cur_scene_info) .. debug.traceback());
										end
									end
								end
							end
						end
			);
		end

		g_SnkNoticeManager:Notice(ENUM.NoticeType.PopUi, cur_scene_id)
	end
end

--增加UI栈计数
function UiManager:PushUIStack(scene_id)
	self.ui_stack[#self.ui_stack + 1] = scene_id
	app.log("PushUi " .. tostring(scene_id));
end

function UiManager:PopUIStack()
	self.ui_stack[#self.ui_stack] = nil;
end

function UiManager:GetUICount()
	return #self.ui_stack
end

function UiManager:ReplaceUi(scene_id, param)
	local cur_scene_id = nil;
	if #self.ui_stack ~= 0 then
		cur_scene_id = self.ui_stack[#self.ui_stack];
	else
		self:PushUi(scene_id, param);
		return ;
	end
	self.ui_stack[#self.ui_stack] = scene_id;
	app.log("<color=yellow>ReplaceUi " .. tostring(cur_scene_id) .. " to " .. tostring(scene_id) .. "</color>");
	-- 销毁当前界面
	local cur_scene_info = self.scene_list[cur_scene_id];
	if cur_scene_info then
		cur_scene_info.scene:DestroyUi(true);
		cur_scene_info.isShow = false;
	end

	-- 显示后面的界面
	local new_scene, new_info, new_id;
	local cur_scene;
	local needShowIndex = {}
	local stackCount    = #self.ui_stack
	for i = stackCount, 1, -1 do
		local id = self.ui_stack[i];
		local cf = uiInformation[id];
		table.insert(needShowIndex, i)
		if not cf.showLast then
			break
		end
	end
	local needShowCount = #needShowIndex
	for i = needShowCount, 1, -1 do
		local id = self.ui_stack[needShowIndex[i]];
		--app.log_error("repalceui " .. tostring(id))
		if scene_id == id then
			new_id              = id
			new_scene, new_info = self:createUI(id, param);
			cur_scene           = new_scene;
		else
			new_id              = id
			new_scene, new_info = self:createUI(id);
		end
	end

	cur_scene.scene:SetLoadedCallback(
				function()
					self:ChangeBackAudio(scene_id)
					if not uiInformation[scene_id].showLast then
						for i = #self.ui_stack - 1, 1, -1 do
							local id         = self.ui_stack[i];
							local scene_info = self.scene_list[id];
							if scene_info and scene_info.scene and scene_info.scene:IsShow() then
								scene_info.scene:Hide();
								scene_info.isShow = false;
							end
						end
					end
				end
	);
	return self.scene_list[scene_id].scene
end

function UiManager:ClearStack()
	local cur_scene_id = self.ui_stack[#self.ui_stack];
	if cur_scene_id == self.ui_stack[1] then
		self.ui_stack    = {};
		self.ui_stack[1] = cur_scene_id;
	else
		local main_scene_id = self.ui_stack[1];
		self.ui_stack       = {};
		self.ui_stack[1]    = main_scene_id;
		self.ui_stack[2]    = cur_scene_id;
	end

	for k, v in pairs(self.scene_list) do
		if k ~= self.ui_stack[1]
					and k ~= self.ui_stack[2]
		then
			v.scene:DestroyUi(true);
			v.isShow = false
		end
	end
end

function UiManager:SetStackSize(size)
	self.isPoping = nil

	if size < 1 or self:GetUICount() <= size then
		return
	end

	local oldStatck = self.ui_stack
	self.ui_stack   = {}

	for i = 1, size do
		self.ui_stack[i] = oldStatck[i]
	end

	for k, v in pairs(self.scene_list) do
		local destroy = true
		for uik, uiv in pairs(self.ui_stack) do
			if k == uiv then
				destroy = false;
				break ;
			end
		end

		if v.scene then
			if destroy == true then
				v.scene:Hide()
				v.scene:DestroyUi(true)
				self.scene_list[k] = nil
			end
		else
			app.log_error("#lhf#k:" .. tostring(k) .. " v:" .. table.tostring(v) .. " " .. debug.traceback());
		end

	end

	local sceneid             = self.ui_stack[#self.ui_stack]
	local new_id              = sceneid;
	local new_scene, new_info = self:createUI(sceneid);
	if new_info.showLast then
		for i = #self.ui_stack - 1, 1, -1 do
			local id  = self.ui_stack[i];
			new_id    = id;
			new_info  = uiInformation[id];
			new_scene = self.scene_list[id];
			if not new_info.showLast then
				break ;
			end
		end
	end
end

function UiManager:DestroyAll(delete_all)
	for k, v in pairs(self.scene_list) do
		if v.scene then
			v.scene:Hide();
			if v.scene.DestroyUi then
				v.scene:DestroyUi(false);
				if delete_all then
					self.scene_list[k] = nil;
				end
			end
		else
			app.log_error("#lhf#k:" .. tostring(k) .. " v:" .. table.tostring(v) .. debug.traceback());
		end
	end

	self.have_destroy = true;

	if self.global_uis then
		for k, v in pairs(self.global_uis) do
			k:DestroyUi()
		end
		self.global_uis = {}
	end

	if table.get_num(self.destroy_stack_mark) > 0 then
		if not delete_all then
			-- 设置恢复的UI栈数据
			local count = 0
			for i = #self.ui_stack, 1, -1 do
				local scene_id = self.ui_stack[i]
				if self.destroy_stack_mark[scene_id] then
					table.remove(self.ui_stack, i)
					count = count + 1
				end
			end
			if count > 0 then
				local scene_id = self.ui_stack[#self.ui_stack]
				if self.scene_list[scene_id] then
					self.scene_list[scene_id].isShow = true
					if self.scene_list[scene_id].scene then
						self:_HideLastUi(scene_id, true);
					end
				end
			end
		end
		self.destroy_stack_mark = {}
	end

	self.curBackAudioId = nil;
end

function UiManager:Restart()
	if #self.ui_stack == 0 then
		return
	end
	app.log("UiManager:Restart");
	self.have_destroy = false;

	local scene_id = self.ui_stack[#self.ui_stack];
	local new_id   = scene_id;
	local new_scene, new_info;
	local num      = 0;
	local loadList = {};
	local top_eui;
	local top_scene;
	for i = #self.ui_stack, 1, -1 do
		local v = self.ui_stack[i]
		if self.scene_list[v] == nil or self.scene_list[v].isShow then
			new_id                       = v
			new_scene, new_info          = self:createUI(v, self.ClassList[v].temp_param or self.ClassList[v][2]);
			num                          = num + 1;
			loadList[#loadList + 1]      = new_scene.scene;
			self.ClassList[v].temp_param = nil
			--new_scene.scene:Show();
		end
		if i == #self.ui_stack then
			top_eui = v
			top_scene = new_scene
		end
	end

	local function loadOkCallback()
		self:ChangeBackAudio(scene_id)
		num = num - 1;
		if num == 0 then
			g_SnkNoticeManager:Notice(ESnkEvent.UiManagerRestartDone, top_eui, top_scene)
		end
	end
	for k, v in pairs(loadList) do
		v:SetLoadedCallback(loadOkCallback);
	end
	-- self:UpdateUi(scene_id);

	g_SnkNoticeManager:Notice(ENUM.NoticeType.UiManagerRestart, top_eui, top_scene)
end

function UiManager:SetDestroyStackMark(scene_id)
	if self.destroy_stack_mark then
		if type(scene_id) == "table" then
			for k, v in pairs(scene_id) do
				self.destroy_stack_mark[v] = true
			end
		else
			self.destroy_stack_mark[scene_id] = true
		end
	end
end

---@return UiBaseClass
function UiManager:GetCurScene()
	local cur_scene_id = self.ui_stack[#self.ui_stack];
	if self.scene_list[cur_scene_id] then
		return self.scene_list[cur_scene_id].scene;
	end
end

function UiManager:UpdateCurScene(info_type)
	local scene = self:GetCurScene();
	if scene and scene.UpdateSceneInfo then
		scene:UpdateSceneInfo(info_type);
	end
end

function UiManager:Begin()
	self.have_destroy                         = false;
end

function UiManager:FindUI(sceneID)
	if self.scene_list[sceneID] then
		return self.scene_list[sceneID].scene;
	else
		return nil;
	end
end

--[[ 传递消息数据到UiManager保存的UI对象
uiName      定义的UI命名
funcName    调用的函数名
--]]
function UiManager:UpdateMsgData(uiName, funcName, ...)
	local ui = self:FindUI(uiName);
	if ui and ui[funcName] and ui.ui then
		ui[funcName](ui, ...);
	end
end

--[[ 传递消息数据到UiManager保存的UI对象(该对象资源释放了也发送)
uiName      定义的UI命名
funcName    调用的函数名
--]]
function UiManager:UpdateMsgDataEx(uiName, funcName, ...)
	local ui = self:FindUI(uiName);
	if ui and ui[funcName] then
		ui[funcName](ui, ...);
	end
end

function UiManager:Update(dt)
	local size = #self.ui_stack
	for i = size, 1, -1 do
		local sceneid   = self.ui_stack[i];
		local sceneInfo = self.scene_list[sceneid]
		if sceneInfo and sceneInfo.scene and sceneInfo.scene:IsShow() and sceneInfo.scene.Update then
			sceneInfo.scene:Update(dt)
		else
			break
		end
	end

	for ui, needUpdate in pairs(self.global_uis) do
		if needUpdate and ui:IsShow() then
			ui:Update(dt)
		end
	end
end

function UiManager:GetCurSceneID()
	local len = #self.ui_stack
	if len == 0 then
		return nil
	else
		return self.ui_stack[len];
	end
end

function UiManager:GetPrevSceneID()
	local len = #self.ui_stack
	if len > 1 then
		return self.ui_stack[len - 1];
	else
		return nil;
	end
end

function UiManager:GetSceneID(index)
	if index < #self.ui_stack then
		return self.ui_stack[index];
	else
		return nil;
	end
end

function UiManager:OnPanelLoadOK(name)
	--g_ScreenLockUI.Hide()
end

function UiManager:_HideLastUi(new_scene_id, is_logic)
	local new_cf = uiInformation[new_scene_id];
	-- local needHideList = {};
	if not new_cf.showLast then
		for i = #self.ui_stack - 1, 1, -1 do
			local id         = self.ui_stack[i];
			local cf         = uiInformation[id];
			local scene_info = self.scene_list[id];
			if scene_info then
				-- if not is_logic then
				--同时push两个界面，上个界面还未创建好(scene == nil)
				-- if scene_info.scene then
				-- scene_info.scene:Hide();
				-- 存储需要隐藏的界面，在新界面显示后，再隐藏
				-- table.insert(needHideList, id);
				-- end
				-- scene_info.scene:MsgUnRegist();
				-- end
				scene_info.isShow = false;
				if not cf.showLast then
					break ;
				end
			else
				break ;
			end
		end
	end
	-- return needHideList;
end

function UiManager:Hide()
	for k, v in pairs(self.scene_list) do
		v.scene:Hide();
	end
end

function UiManager:Show()
	local new_scene, new_info, new_id;
	for k, v in pairs(self.ui_stack) do
		if self.scene_list[v] == nil or self.scene_list[v].isShow then
			new_id              = v
			new_scene, new_info = self:createUI(v, self.ClassList[v][2]);
		end
	end
end

function UiManager:AddGlobalUi(ui, needUpdate)
	self.global_uis[ui] = needUpdate
end

function UiManager:DelGlobalUi(ui)
	if self.global_uis[ui] then
		self.global_uis[ui] = nil
	end
end

function UiManager:ChangeBackAudio(cur_ui_id)
	if uiInformation[cur_ui_id].backAudioId ~= nil then
		if self.curBackAudioId == nil or self.curBackAudioId ~= uiInformation[cur_ui_id].backAudioId then
			self.curBackAudioId = uiInformation[cur_ui_id].backAudioId;
		end
	end
end

function UiManager:GetBackAudioId(cur_ui_id)
	if uiInformation[cur_ui_id] and uiInformation[cur_ui_id].backAudioId then
		return uiInformation[cur_ui_id].backAudioId
	end
	return nil;
end