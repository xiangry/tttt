---@class SnkPlayer 用户数据
---@field guild GuildData
---@field story StoryData
SnkPlayer = Class("SnkPlayer")

function SnkPlayer:Init(data)
	--self.playerid = 0;
	--self.show_playerid = 0;
	--self.groupid = 0;
	--self.name = "ghoul";
	--self.image = 0;
	--self.ap = 0;
	--self.bp = 0;
	--self.exp = 0;
	--self.level = 1;
	
	-------------vip-------------
	self.oldData = {}
	self.oldData.vip = 0
	self.oldData.vip_heros = {}
	self.vip = 0
	self.vip_heros = {}
	self.level = 1;
	---------------------------

	self.lineups = {};
	self.shopList = {};
	self.recruitList = {};
	self.techInfo = {}
	self.story = StoryData:new({chapterList = {},sectionList = {}});
	self.guild =  GuildData:new();
	self.flagHelper = FlagHelper and FlagHelper:new() or nil;
	if data then
		self:UpdateData(data);
	end

	self.isInitData = false;
	self.loadHomeUIFinished = false;
end


function SnkPlayer:UpdatePlayerData(info)
	self.oldData.ap = info.ap or 0;
	self.oldData.bp = info.bp or 0;
	self.oldData.exp = tonumber(info.exp) or 0;
	self.oldData.level = info.level or 0;
	self.oldData.gold = tonumber(info.gold) or 0;
	self.oldData.crystal = tonumber(info.crystal) or 0;
	self.oldData.red_crystal = tonumber(info.red_crystal) or 0;
	self.playerid = info.playerid or 0;
	self.ap = info.ap or 0;
	self.bp = info.bp or 0;
	self.gold = tonumber(info.gold) or 0;
	self.crystal = tonumber(info.crystal) or 0;
	self.red_crystal = tonumber(info.red_crystal) or 0;
	self.exp = tonumber(info.exp) or 0;
	self.level = info.level or 1;
	self.show_playerid = info.show_playerid or 0;
	self.name = info.name or 0;
	self.image = info.image or 0;
	self.country_id = info.country_id;
	self.totalCostMoney = info.total_cost_money or 0;
	self.get_friend_ap_times = (info.get_friend_ap_times or 0);
	self.hero_dust = tonumber(info.hero_dust) or 0;
	self.equip_dust = tonumber(info.equip_dust) or 0;
	self.honor_point= tonumber(info.honor_point) or 0;
	self.guild_coin = tonumber(info.guild_coin) or 0;
	self.tech_point = tonumber(info.guild_technology_point) or 0;
	self.change_name_times = (info.change_name_times or 0);
	self.gmSwitch = info.gmSwitch or 0;
	self.isInitData = true
	self:SetFirstRechargeFlag(info.pay_flag);

	self:SetBlessLvl(info.star_blessing_level)
	GuideManager.CheckRecord(info.guide)			-- 初始化新手引导数据
end

function SnkPlayer:UpdateData(info)
	--self.playerid = info.playerid or 0;
	--self.show_playerid = info.show_playerid or 0;
	--self.groupid = info.groupid or 0;
	--self.name = info.name or 0;
	--self.image = info.image or 0;
	--self.ap = info.ap or 0;
	--self.bp = info.bp or 0;
	--self.exp = tonumber(info.exp) or 0;
	--self.level = info.level or 0;
	
	-----------------vip--------------
	
	self.vip = self:SumVip(info.vip_heros)
	self.vip_heros = info.vip_heros or {}
	self.oldData.vip_heros = self.vip_heros
	self.oldData.vip = self.vip 
	
	---------------------------------------
	self.techInfo = info.tech_datas or {}

	if info.lineups then
		for k,v in pairs(info.lineups) do
			self:UpdateLineUp(v);
		end
	end
	
	if info.shops then
		--self.lineups = info.lineups;
		for k,v in pairs(info.shops) do
			self:UpdateShop(v);
		end
	end
	-- self.shopList = info.shops;
	self.setData = true;
end

--EDC 更新活动入口数据
function SnkPlayer:UpdateActivityIntroData(info)
	DataCenterGet(ESnkDataCenter.snkActivity):UpdateActivityIntroData(info)
end

--EDC 七日登录相关-------------------------------
--获得相关数据，当前天数和领取记录
function SnkPlayer:UpdateSevenDayData(days, bits)
	DataCenterGet(ESnkDataCenter.snkActivity):UpdateSevenDayData(days, bits)
end

--更改某一天结果
function SnkPlayer:ChangeDayState(day, result)
	DataCenterGet(ESnkDataCenter.snkActivity):ChangeDayState(day, result)
end

function SnkPlayer:IsSevenDayTip()
	return DataCenterGet(ESnkDataCenter.snkActivity):IsSevenDayTip()
end
------------------------------------------------

--EDC 月签相关-----------------------------------
function SnkPlayer:GetMonthSignData(info)
	DataCenterGet(ESnkDataCenter.snkActivity):GetMonthSignData(info)
end

--[Comment]
--更新数据
function SnkPlayer:UpdateMonthSignData(checkGetAwardTimes)
	DataCenterGet(ESnkDataCenter.snkActivity):UpdateMonthSignData(checkGetAwardTimes)
end

function SnkPlayer:IsMonthSignTip()
	return DataCenterGet(ESnkDataCenter.snkActivity):IsMonthSignTip()
end

------------------------------------------------

--角色阵容数据
function SnkPlayer:UpdateLineUp(lineup)
	if self.lineups[lineup.id] then
		self.lineups[lineup.id]:UpdateData(lineup);
	else
		self.lineups[lineup.id] = LineupData:new(lineup);
		-- self.lineups.insert(lineup,lineup.id);
	end
end

function SnkPlayer:GetLineupHero()
	local tR = {};
	local tC = 1;

	if not self.lineups or not self.lineups[1] then
		return tR;
	end

	for key, value in ipairs(self.lineups[1].posInfo) do
		local tHero = DataCenterGet(ESnkDataCenter.package):FindCard(ESnkPackage.hero,value.dataid);
		if tHero then
			tR[tC] = tHero;
			tC = tC+1;
		end 
	end
	return tR;
end

function SnkPlayer:GetLineupHeroForPosition()
	local tR = {};
	if self.lineups[1] then
		for key, value in ipairs(self.lineups[1].posInfo) do
			local tHero = DataCenterGet(ESnkDataCenter.package):FindCard(ESnkPackage.hero,value.dataid);
			if tHero then
				tR[key] = tHero;
			end 
		end
	end
	return tR;
end

function SnkPlayer:GetLineupPositionForHeroCId(heroCId)
	for key, value in ipairs(self.lineups[1].posInfo) do
		local tHero = DataCenterGet(ESnkDataCenter.package):FindCard(ESnkPackage.hero,value.dataid);
		if tHero and tHero:GetCid() == heroCId then
			return value.posId;
		end 
	end
	return -1;
end

function SnkPlayer:CheckHeroIsLineUp(dataid)
	for key, value in pairs(self.lineups) do
		for i,tPos in pairs(value.posInfo) do
			if tPos.dataid == dataid then
				return {is = true,lineupId = key,posId = tPos.posId};
			end
		end
	end
	return {is = false};
end

function SnkPlayer:LineupPower()
	-- app.log("<color=red> tempSort: </color>.."..table.tostring(self.lineups));
	local power = 0
	local equip_power = 0
	for k , v in pairs(self.lineups[1].posInfo) do
		if v.dataid ~= nil then
			local package =  DataCenterGet(ESnkDataCenter.package)
			local cur_hero = package:FindCard(ESnkPackage.hero,v.dataid)
			-- local cur_equip = package:FindCard(ESnkPackage.equip,v.dataid)
			if cur_hero ~= nil then
				local cur_hero_power = cur_hero:GetCombat()	
				
				-- -- 怀疑装备战斗力计算重复了
				-- local cur_equip = cur_hero:GerEquip()				
				-- for kk,vv in pairs(cur_equip) do
				-- 	if vv ~= "0" then						
				-- 		local cur_equip_item = package:FindCard(ESnkPackage.equip,vv)
				-- 		local cur_hero_power = cur_equip_item:GetPower()						
				-- 		equip_power = cur_hero_power + equip_power
				-- 	end
				-- end
				-- -- app.log("<color=red> 玩家装备列表：</color>.."..table.tostring(cur_equip));	
				-- power = cur_hero_power + equip_power + power		

				power = cur_hero_power +  power				
			end
		end
	end
	return math.ceil(power)	
end

function SnkPlayer:LineupHeroIsTips(checkEquip)
	if self.lineups and self.lineups[1] then
		for k , v in pairs(self.lineups[1].posInfo) do
			if v.dataid ~= nil and not self:LineupPosIsLock(v.posId) then
				local cur_hero =  DataCenterGet(ESnkDataCenter.package):FindCard(ESnkPackage.hero,v.dataid)
				if cur_hero ~= nil then
					if cur_hero:TrainTip() or (checkEquip == true and cur_hero:EquipTip()) then
						return true;
					end
				end
			end
		end
	end
	return false;
end
--
function SnkPlayer:LineupPosIsEmpty()
	if self.lineups and self.lineups[1] then
		local isPosEmpty = false;
		local heroCount = 0;
		for k , v in pairs(self.lineups[1].posInfo) do
			if v.dataid == nil or DataCenterGet(ESnkDataCenter.package):FindCard(ESnkPackage.hero,v.dataid) == nil then
				isPosEmpty = true;
			else
				heroCount = heroCount+#DataCenterGet(ESnkDataCenter.package):FindCardByConfigId(ESnkPackage.hero,DataCenterGet(ESnkDataCenter.package):FindCard(ESnkPackage.hero,v.dataid):GetCid());
			end
		end
		
		if isPosEmpty and heroCount < DataCenterGet(ESnkDataCenter.package):GetCont(ESnkPackage.hero) then
			return true;
		else
			return false;
		end
	end
	return false;
end

--阵容位置锁定检查
function SnkPlayer:LineupPosIsLock(pos)
	local tPosInfo = ConfigManager.Get(EConfigIndex.t_position_lv,pos);
	if tPosInfo and tPosInfo.open_lv>self:GetLevel() then
		return true;
	else
		return false;
	end
end

--角色商店数据
function SnkPlayer:GetShopList()
	return self.shopList;
end

function SnkPlayer:GetShop(shopid)
	-- app.log("<color=aqua> shop：：：：：：：：：：</color>"..tostring(shopid)) 
	-- app.log("<color=aqua> self.shopList[shopid] ======== </color>"..table.tostring(self.shopList)) 
	-- app.log("<color=aqua> self.shopList[shopid] ===1===== </color>"..table.tostring(self.shopList[1])) 
	-- app.log("<color=aqua> self.shopList[shopid] ====2==== </color>"..table.tostring(self.shopList[2])) 
	-- app.log("<color=aqua> self.shopList[shopid] =====3=== </color>"..table.tostring(self.shopList[3])) 
	-- app.log("<color=aqua> self.shopList[shopid] =====4=== </color>"..table.tostring(self.shopList[4])) 
	return self.shopList[shopid];
end

function SnkPlayer:UpdateShop(shop)
	-- app.log("<color=aqua> shop：=：+：+：+：+：+：+：+： </color>"..table.tostring(shop)) 
	local tShop = self.shopList[shop.id];
	if not tShop then
		self.shopList[shop.id] = ShopData:new(shop);
	else
		tShop:UpdateData(shop);
    end
end

--角色招募数据

function SnkPlayer:GetRecruitList(idList)
	local tR = {};
	for k,v in pairs(idList) do
		if self.recruitList[v] then
			table.insert(tR,self.recruitList[v]);
		end
	end
	return tR;
end

function SnkPlayer:GetRecruit(recruitid)
	return self.recruitList[recruitid];
end

function SnkPlayer:UpdateRecruit(recruit)
	if self.recruitList[recruit.id] then
		self.recruitList[recruit.id]:UpdateData(recruit);
	else
		self.recruitList[recruit.id] = RecruitData:new(recruit);
		-- self.lineups.insert(lineup,lineup.id);
	end
end

function SnkPlayer:IsFreeRecruit()
	for k,v in pairs(self.recruitList) do
		if v:IsFree() and  k ~= 1 then				--屏蔽掉抽奖 隐藏的那个页签
			return true;
		end
	end
	return false;
end

---关卡数据
---@return StoryData
function SnkPlayer:GetStory()
	return self.story;
end

---@return GuildData
function SnkPlayer:GetGuild()
	return self.guild;
end

function SnkPlayer:UpdateGoldAndCrystal(gold, crystal,redCrystal)
	self:UpdateGoldAndCrystal(gold, crystal,redCrystal)	--TODO
end

--[[更新经验与等级]]
function SnkPlayer:UpdateExpLevel(exp, level)
	self.oldData.exp = tonumber(self.exp);
	self.oldData.level = self.level;
	if self.level ~= level then 
		self.advOldLevel = self.level;
	end 
	self.exp = tonumber(exp);
	self.level = level;
	--app.log_error("player oldLevel="..self.oldData.level.." oldExp="..self.oldData.exp.." level="..self.level.." exp="..self.exp);

	-- 玩家升级通知
	if self.oldData.level < self.level then
		g_SnkNoticeManager:Notice(ENUM.NoticeType.PlayerLevelUp, self.level);
        PublicFunc.msg_dispatch('TeamUpgrade', self.oldData.level, self.level)
        -- GNoticeGuideTip(Gt_Enum_Wait_Notice.Player_Levelup);
		--推送打标签
		-- PushTagManager.WhenLevelChange(self.level)
		-- PushLocalManager.WhenLevelChange(self.level)
	end
	-- g_dataCenter.player:UpdateExpLevel(exp, level);
end

--[[更新体力精力]]
function SnkPlayer:UpdateApAndBp(ap, bp)
	self.oldData.ap = tonumber(self.ap);
	self.oldData.bp = tonumber(self.bp);
	self.ap = tonumber(ap);
	self.bp = tonumber(bp);
end

------------------------------------- vip ---------------------------------
function SnkPlayer:GetVip()
	return self.vip
end

function SnkPlayer:SumVip(heros)
	if heros == nil then
		return
	end
	local num = 0
	for i = 1,#heros do
		if heros[i].isUnLock then
			num = num + heros[i].star
		end
	end
	return num
end

--更新VIP
function SnkPlayer:UpdateVIP(vip,vip_heros)-- vipexp, vip_reward_flag, vipstar, vip_every_get)
	self.oldData.vip = self.vip;
	self.oldData.vip_heros = self.vip_heros

	-- app.log_error(tostring(vip_heros).."		"..table.tostring(vip_heros))
	self.vip = self:SumVip(vip_heros)
	self.vip_heros = vip_heros or nil
	g_SnkNoticeManager:Notice(ENUM.NoticeType.VipDataChange);
	if self.vip > self.oldData.vip then
		-- GNoticeGuideTip(Gt_Enum_Wait_Notice.Vip_Level)		--TODO
		PublicFunc.msg_dispatch("SnkPlayer.OnLevelUp");
	end

end


--显示购买体力的流程提示
function SnkPlayer:ShowBuyAp()

	local vipData = self:GetVipData();
	if not vipData then
		app.log_error("vip 配置错误 level="..tostring(self.vip));
		return;
	end
	local curTimes = self:GetFlagHelper():GetNumberFlag(MsgEnum.eactivity_time.eActivityTime_apBuyTimes) or 0;
	local gbc = ConfigManager.Get(EConfigIndex.t_buy_cost_snk,curTimes);
	if not gbc then
		app.log_error("buy_cost 配置错误 curTimes="..tostring(curTimes));
		return;
	end
	CommonBuy.Show(curTimes, vipData.ex_can_buy_ap_times, gbc.cost, 
		gbc.get_ap, "体力", "今日购买体力次数已达到上限，不能购买体力！", msg_snk_player.cg_ap_buy);
		--TODO 改文字
end


--获取今日可购买体力次数最大限制
function SnkPlayer:GetMaxApBuyTimes()
	local basic_max_buy_ap_times = ConfigManager.Get(EConfigIndex.t_discrete,83000033).data;
	local extra_can_buy_ap_times = 0;
	if self:GetVipData() then
    	extra_can_buy_ap_times = self:GetVipData().ex_can_buy_ap_times;
	else
		extra_can_buy_ap_times = 0;
		app.log_error("当前vip=="..tostring(self.vip).."没有对应的额外购买体力次数配置表");
	end
	
	local max_buy_ap_times = basic_max_buy_ap_times + extra_can_buy_ap_times;
	return max_buy_ap_times;
end

--获取可以购买世界BOSS鼓舞的最大次数
function SnkPlayer:GetMaxBuyInspireTimes()
    if self:GetVipData() then
        return self:GetVipData().world_boss_inspire_limit
    end
    return 0
end

--获取当前VIP初始世界BOSS鼓舞次数
function SnkPlayer:GetStartInspireTimes()
    if self:GetVipData() then
        return self:GetVipData().world_boss_start_inspire
    end
    return 0
end

function SnkPlayer:GetVipData(heroIndex)
	if heroIndex == nil then
		heroIndex = self:GetVipCurHero()
	end
	-- app.log_error(table.tostring(self.vip_heros))
	if self.vip_heros[heroIndex+1] then
		return self:GetVipDataConfigByLevel(self.vip_heros[heroIndex+1].star,heroIndex);
	else
		return nil;
	end
end

function SnkPlayer:GetCurVipData(heroIndex)
	return self.vip_heros[heroIndex+1]
end

function SnkPlayer:GetNextVipData(heroIndex)
	if heroIndex == nil then
		heroIndex = self:GetVipCurHero()
	end
	local next_vip = self.vip_heros[heroIndex+1].star + 1
	local curCfg = self:GetVipDataConfigByLevel(self.vip_heros[heroIndex+1].star,heroIndex)
	local max_vip = self:GetCurHeroVipMaxLvl(curCfg.hero_id);
	if next_vip > max_vip then
		next_vip = max_vip;
	end
	return self:GetVipDataConfigByLevel(next_vip,heroIndex)
end

function SnkPlayer:GetVipCurHero()
	local _index = 0
	for i = 1, #self.vip_heros do
		if self.vip_heros[i].isUnLock then	
			_index = self.vip_heros[i].index
		end
	end
	return _index
end

function SnkPlayer:GetVipDataConfigByLevel(level,heroIndex)
	local vip_config = nil
	if heroIndex == nil then
		heroIndex = self:GetVipCurHero()
	end
	local id = (heroIndex+1) *100+level 
	vip_config = ConfigManager.Get(EConfigIndex.t_vip_data_snk, id);
	return vip_config;
end

function SnkPlayer:GetCurHeroVipMaxLvl(heroId)
	local maxLvl = 0
	local vip_table = ConfigManager._GetConfigTable(EConfigIndex.t_vip_data_snk);
	local heroTable = {}
	for k,v in pairs(vip_table) do
		if heroId == v.hero_id then
			table.insert(heroTable,v)
		end
	end
	if #heroTable > 0 then
		for i = 1, #heroTable do
			if heroTable[i].level > maxLvl then
				maxLvl = heroTable[i].level
			end
		end
	end
	return maxLvl
end

function SnkPlayer:GetVipMax( )
	local vip_table = ConfigManager._GetConfigTable(EConfigIndex.t_vip_data_snk);
	local count = -1
	for  k,v in pairs(vip_table) do
		count = count + 1
	end
	return count 	 -- 从0开始
end

function SnkPlayer:CheckRedPointVip()
	for i = 1, #self.vip_heros do
		if self.vip_heros[i].isUnLock and self.vip_heros[i].every_get == 0 then
			return true
		end
	end	
	return self:CheckUpFavorItem()
end

function SnkPlayer:CheckUpFavorItem()
	local curHeroIndex = self:GetVipCurHero()
	local vipData = self:GetCurVipData(curHeroIndex)
	if not vipData then
		return false
	end
	local vipCfg = self:GetVipDataConfigByLevel(vipData.star,curHeroIndex)
	local maxLvl = self:GetCurHeroVipMaxLvl(vipCfg.hero_id)
	local dis_item_data = ConfigManager.Get(EConfigIndex.t_value, MsgEnum.ediscrete_id.eDiscreteID_vip_up_item).data;
	
	if vipData.star < maxLvl then
		for i = 1, #dis_item_data do
			if SnkPublicFunc.GetNumByCid(dis_item_data[i].item_id) > 0 then
				return true
			end
		end
	end
	return false
end

function SnkPlayer:CheckVipIsBuyGift(_heroIndex,_level)
	local isBuy = false
	if self.vip_heros[_heroIndex+1] then
		if self.vip_heros[_heroIndex+1].vip_reward_flag == 1 then
			isBuy = true
		end
	end
	return isBuy
end

----------------------------------------------------------------------------------------------



---用户基础属性临时封装----------------------------------------------------------------------------------------------------------------------------------------------------
--用户id
function SnkPlayer:GetPlayerID()
	return self.playerid;
end
--用户展示id
function SnkPlayer:GetShowPlayerID()
	return self.show_playerid;
end

function SnkPlayer:GetGID()
	return self.playerid;
end

function SnkPlayer:GetName()
	return self.name;
end

--用户等级
function SnkPlayer:GetLevel()
	return self.level;
end

function SnkPlayer:GetGmSwitch()
	return self.gmSwitch;
end


--等级上限
function SnkPlayer:GetPlayerMaxLv()
	if self._maxLevel == nil then
		self._maxLevel = ConfigManager.GetDataCount(EConfigIndex.t_player_level);
	end
	return self._maxLevel;
end

--用户经验值
function SnkPlayer:GetPlayerExp()
	return self.exp;
end

--等级变化
function SnkPlayer:GetLvByExp( exp )
	local curLv = self:GetLevel();
	local curExp = self.exp + exp;
	local levelConfig = ConfigManager.Get(EConfigIndex.t_player_level, curLv);
	while curExp > levelConfig.exp do
		curExp = curExp - levelConfig.exp;
		curLv = curLv + 1;
		if curLv > self:GetPlayerMaxLv() then
			break;
		end
		levelConfig = ConfigManager.Get(EConfigIndex.t_player_level, curLv);
	end
	return curLv;
end

--获取老的经验比
function SnkPlayer:GetOldExpPro()
	local levelConfig = ConfigManager.Get(EConfigIndex.t_player_level,self.oldData.level);
	if levelConfig then
		return tonumber(self.oldData.exp) / levelConfig.exp;
	else
		app.log_error("获取玩家经验比失败   level="..tostring(self.oldData.level));
		return 0;
	end
end

function SnkPlayer:GetExp()
	return self.exp;
end

--获取最新经验比
function SnkPlayer:GetExpPro()
	local levelConfig = ConfigManager.Get(EConfigIndex.t_player_level,self.level);
	if levelConfig then
		return self.exp / levelConfig.exp;
	else
		app.log_error("获取玩家经验比失败   level="..tostring(self.level));
	end
end

--获取玩家上次状态等级与最新等级是否相等
function SnkPlayer:IsLevelUp()
	return self.oldData.level ~= self.level;
end

function SnkPlayer:SetImage(image)
	self.image = image;
end
--用户头像
function SnkPlayer:GetImage()
	return self.image;
end


 --获取标识
 function SnkPlayer:GetFlagHelper()
	return self.flagHelper;
 end
--用户国家id 
function SnkPlayer:GetCountryId()
	return self.country_id;
end
--设置首充标志
function SnkPlayer:SetFirstRechargeFlag(flag)
	self.firstRechargeFlag = flag;
	self:AnalysisFlag(flag);
end
function SnkPlayer:AnalysisFlag(flag)
	if not flag then return end
	self.firstRechargeType = {};
	-- local awards = ConfigManager._GetConfigTable(EConfigIndex.t_first_recharge_reward);

	for k = 1, 3 do
		local temp = bit.bit_lshift(1, ENUM.ETypeFirstRecharge.FLAG_IS_REWARD + 1 - k);
		local val = bit.bit_and(flag, temp);
		if val > 0 then
			self.firstRechargeType[k] = true;
		else
			self.firstRechargeType[k] = false;
		end
	end
end
 --得到首充标志
function SnkPlayer:GetFirstRechargeFlag()
	return self.firstRechargeFlag;
end

--得到首充状态
function SnkPlayer:GetFirstRechargeType(index)
	if index == nil then
		index = 1;
	end
	return self.firstRechargeType[index];
end

function SnkPlayer:GetNextFirstRechargeType()
	for k, v in ipairs(self.firstRechargeType) do
		if not v then
			return ENUM.ETypeFirstRecharge.FLAG_IS_REWARD + 1 - k, k;
		end
	end
	return 0, 0;
end

--首充提示检查
function SnkPlayer:IsFirstRechargeTip()
	local cost = self.totalCostMoney;
	if not cost then
		return false;
	end
	if cost>0 then
		if not self.firstRechargeType[1] then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

--用户体力
function SnkPlayer:GetAP()
    return self.ap;
end

---define
function SnkPlayer:GetOldAP()
	return self.oldData.ap;
end


function SnkPlayer:GetBP()
	return self.bp;
end

function SnkPlayer:GetMaxSP(level)
	if level == nil then
		level = self.level
	end
	local maxsp = 0
	local levelConfig = ConfigManager.Get(EConfigIndex.t_player_level,level)
	if levelConfig then
	    maxsp = maxsp + levelConfig.max_sp
	end
	return maxsp
end

function SnkPlayer:GetMaxFood(level)
	if level == nil then
		level = self.level
	end
	local maxsp = 0
	local levelConfig = ConfigManager.Get(EConfigIndex.t_player_level,level)
	if levelConfig then
	    maxsp = maxsp + levelConfig.max_food
	end
    
	return maxsp;
end

---define
function SnkPlayer:GetMaxAP(level)
	if level == nil then
        level = self.level
    end
    local maxap = 0
    local levelConfig = ConfigManager.Get(EConfigIndex.t_player_level_info,level)
    if levelConfig then
        maxap = maxap + levelConfig.max_energy
    end

    local vipCfg = self:GetVipData();
    if vipCfg then
    	maxap = maxap + vipCfg.max_ap
    end

    return maxap
end


--金币
function SnkPlayer:GetGolden()
	return self.gold;
end
--钻石
function SnkPlayer:GetCrystal()
	return self.crystal;
end
--红钻
function SnkPlayer:GetRedCrystal()
	return self.red_crystal;
end

---好友最大领取体力次数
---@return number 次数
function SnkPlayer:GetMaxFriendApTimes()
	return self.get_friend_ap_times
end

---可领取体力数
function SnkPlayer:LastCanGetFriendAP()
	local curTims = (self:GetMaxFriendApTimes() or 0);
	local max_times = ConfigManager.Get(EConfigIndex.t_discrete, MsgEnum.ediscrete_id.eDiscreteID_get_friend_ap_times_each_day).data
	local ap_value = ConfigManager.Get(EConfigIndex.t_discrete, MsgEnum.ediscrete_id.eDiscreteID_get_friend_ap_each_time).data
	if curTims >= max_times then
		return 0
	else
		return (max_times-curTims)*ap_value
	end
end

function SnkPlayer:GetTotalCostMoney()
	return self.totalCostMoney;
end

function SnkPlayer:GetWorldLevel()
	return self.worldLevel or 0;
end

---define 根据配置id返回人物身上的资源数量
function SnkPlayer:GetResourceCount(cid)
	local num = 0
	if cid == 1 then
		num = self:GetCrystal()  --钻石
	elseif cid == 2 then
		num = self:GetAP()       --体力
	elseif cid == 3	then         --金币
		num = self:GetGolden()
	end
	return num
end

function SnkPlayer:GetKofTeam(objList)
	local lineup = self:GetLineupHero();
	local obj = 
	{
		pos = 1,
		model_id = 1,
		property = 
		{
			10000,
			1000,
			1000,
			400,
			400,
			80,
			20,
			150,
			80,
			20,
			20,
			20,
			40,
			20,
			200,
			3,
			3,
			40,
			20,
			25,
		},
		skill = { [0] = 1, [1] = 2, [2] = 3, [3] = 4},
	}
	for i, v in pairs(lineup) do
		local tempObj = table.deepcopy(obj);
		tempObj.model_id = v:GetModelId();
		tempObj.pos = i;
		tempObj.property[ESnkProperty.speed] = tempObj.property[ESnkProperty.speed] + math.random(-2, 4)
		table.insert(objList, tempObj);
	end
end

---define 返回player的旧的数据
function SnkPlayer:GetOldData()
	return self.oldData
end

---define 获取战斗力
function SnkPlayer:GetFightValue()
	return 0;
end

---define 获取旧的战斗力
function SnkPlayer:GetOldFightValue()
	return self.oldData.old_fight_value;
end

function SnkPlayer:SetHeroDust(hero_dust)
	self.hero_dust = hero_dust;
end

function SnkPlayer:GetHeroDust()
	return self.hero_dust
end

function SnkPlayer:SetEquipDust(equip_dust)
	self.equip_dust = equip_dust;
end

function SnkPlayer:GetEquipDust()
	return self.equip_dust
end

function SnkPlayer:SetHonorPoint(honor_point)
	self.honor_point = honor_point;
end

function SnkPlayer:GetHonorPoint()
	return self.honor_point
end

function SnkPlayer:SetGuildCoin(guild_coin)
	if guild_coin then self.guild_coin = guild_coin end
end

function SnkPlayer:GetGuildCoin()
	return self.guild_coin
end
function SnkPlayer:SetTechPoint(techP)
	if techP then self.tech_point = techP end
end

function SnkPlayer:GetTechPoint()
	return self.tech_point
end


function SnkPlayer:GetChangeNameTimes()
	return self.change_name_times
end

function SnkPlayer:GetIsWaitingPlayerData()
	if self.isInitData then
		return false
	else
		return true
	end
end

function SnkPlayer:SetHomeLoadFinished(isFinished)
	self.loadHomeUIFinished = isFinished;
end

function SnkPlayer:GetHomeLoadFinished()
	return self.loadHomeUIFinished;
end

function SnkPlayer:UpdateGoldAndCrystal(gold, crystal, red_crystal)
	self.oldData.gold = tonumber(self.gold);
	self.oldData.crystal = tonumber(self.crystal);
	self.oldData.red_crystal = tonumber(self.red_crystal);
	self.gold = tonumber(gold);
	self.crystal = tonumber(crystal);
	self.red_crystal = tonumber(red_crystal);

	-- if self.oldData.crystal ~= self.crystal then
	-- 	GNoticeGuideTip(Gt_Enum_Wait_Notice.Crystal)
	-- end
end

--服务器来了一批名字后缓存下来
function SnkPlayer:SetRollNameList( list )
	self.rollnamelist = list
end

function SnkPlayer:getRollNameList()
	return self.rollnamelist	
end

function SnkPlayer:GetBlessLvl()
	return self.star_blessing_level
end

function SnkPlayer:SetBlessLvl(lvl)
	self.star_blessing_level = lvl or 0
	DataCenterGet(ESnkDataCenter.bless):SetData(lvl)
end

function SnkPlayer:SetTechLvl(type,lvl)
	if self.techInfo[type] and self.techInfo[type].id == type then
		self.techInfo[type].level = lvl
	end
end

function SnkPlayer:GetTechInfo()
	return self.techInfo
end