ENUM = {};

---玩家状态
ENUM.EOnlineState =
{
	online = 0,				--在线
	disconnection = 1,		--断线（只是断线，但还在服务器内存中）
	offline = 2,			--2离线（不在服务器内存了）
}

--性别
ENUM.ESex =
{
	Boy = 1, 	--男
	Girl = 2,	--女
}

--普通攻击类型
ENUM.EAttackType =
{
	Melee = 1,		--近战
	Remote = 2,		--远程
}

ENUM.min_property_id = 0
ENUM.EHeroAttribute =
{
	cur_hp                      = ENUM.min_property_id + 1,	--当前生命值
}

--Loading类型
ENUM.ELoadingType =
{
	Single = 1,			--单一
	FullScreen = 2,		--全屏
}

--Loading大小
ENUM.ELoadingScale =
{
	Small = 1,			--小
	Middle = 2,			--中
	Big = 3,			--大
}

--音乐播放模式
ENUM.EAudioPlayMode =
{
	Order = 1,      --顺序播放
	Loop = -1,		--列表循环
	Random = -2,    --随机播放
}

--音乐类型
ENUM.EAudioType =
{
	_2d = 1,
	_3d = 2,
	UI = 3,
}

--背景音乐播放器
ENUM.EAudioPlayer =
{
	p1 = 1,
	p2 = 2,
}

ENUM.EPackageType =
{
	Empty = 0,				--无类型
	Hero = 1,				--[[英雄]]
	Equipment = 2,			--[[装备]]
	Item = 3,				--[[道具]]
	Skill = 4,				--[[技能]]
	Other = 5,				--[[杂项]]
}

ENUM.EUiAudioBGM = {
	MainCityBgm = 1,
}

EDataCenter = {

}