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

ENUM.EHeroAttribute =
{
	cur_hp                      = ENUM.min_property_id + 1,	--当前生命值
    max_hp                      = ENUM.min_property_id + 2,	--最大生命值
    atk_power                   = ENUM.min_property_id + 3,	--攻击力
    def_power                   = ENUM.min_property_id + 4,	--防御力
    crit_rate                   = ENUM.min_property_id + 5,	--暴击率
    anti_crite                  = ENUM.min_property_id + 6,	--免爆率
    crit_hurt                   = ENUM.min_property_id + 7,	--暴击伤害加成
    broken_rate                 = ENUM.min_property_id + 8, --破击率
    parry_rate                  = ENUM.min_property_id + 9, --格挡率
    parry_plus                  = ENUM.min_property_id + 10,--格挡伤害加成
    move_speed                  = ENUM.min_property_id + 11,--移动速度
    move_speed_plus             = ENUM.min_property_id + 12,--移动速度加成
    bloodsuck_rate              = ENUM.min_property_id + 13,--吸血率
    rally_rate                  = ENUM.min_property_id + 14,--反弹率
    attack_speed                = ENUM.min_property_id + 15,--攻击速度加成
    dodge_rate                  = ENUM.min_property_id + 16,--闪避率
    res_hp                      = ENUM.min_property_id + 17,--生命恢复率
    cool_down_dec               = ENUM.min_property_id + 18,--技能冷却缩减
    treat_plus                  = ENUM.min_property_id + 19,--治疗效果加成
    restraint1_damage_plus      = ENUM.min_property_id + 20,--对锐属性英雄伤害加成 (已废)
	restraint2_damage_plus      = ENUM.min_property_id + 21,--对坚属性英雄伤害加成 (已废)
	restraint3_damage_plus      = ENUM.min_property_id + 22,--对疾属性英雄伤害加成 (已废)
	restraint4_damage_plus      = ENUM.min_property_id + 23,--对特属性英雄伤害加成 (已废)
    restraint_all_damage_plus   = ENUM.min_property_id + 24,--对全属性英雄伤害加成 (已废)
    restraint1_damage_reduct    = ENUM.min_property_id + 25,--对锐属性英雄伤害减免 (已废)
	restraint2_damage_reduct    = ENUM.min_property_id + 26,--对坚属性英雄伤害减免 (已废)
	restraint3_damage_reduct    = ENUM.min_property_id + 27,--对疾属性英雄伤害减免 (已废)
	restraint4_damage_reduct    = ENUM.min_property_id + 28,--对特属性英雄伤害减免 (已废)
    restraint_all_damage_reduct = ENUM.min_property_id + 29,--对全属性英雄伤害减免 (已废)
    normal_attack_1             = ENUM.min_property_id + 30,--普通攻击1段
    normal_attack_2             = ENUM.min_property_id + 31,--普通攻击2段
    normal_attack_3             = ENUM.min_property_id + 32,--普通攻击3段
    quan_neng					= ENUM.min_property_id + 33,--全能
    normal_attack_4             = ENUM.min_property_id + 34,--普通攻击4段
	normal_attack_5             = ENUM.min_property_id + 35,--普通攻击5段
	restraint_def_plus			= ENUM.min_property_id + 36,--对防职业英雄伤害加成
	restraint_attack_plus		= ENUM.min_property_id + 37,--对攻职业英雄伤害加成
	restraint_skill_plus		= ENUM.min_property_id + 38,--对技职业英雄伤害加成
	restraint_def_reduct		= ENUM.min_property_id + 39,--对防职业英雄伤害减免
	restraint_attack_reduct		= ENUM.min_property_id + 40,--对攻职业英雄伤害减免
	restraint_skill_reduct		= ENUM.min_property_id + 41,--对技职业英雄伤害减免
	restraint_def_plus_per		= ENUM.min_property_id + 42,--对防职业英雄伤害加成 百分比
	restraint_attack_plus_per	= ENUM.min_property_id + 43,--对攻职业英雄伤害加成 百分比
	restraint_skill_plus_per	= ENUM.min_property_id + 44,--对技职业英雄伤害加成 百分比
	restraint_def_reduct_per	= ENUM.min_property_id + 45,--对防职业英雄伤害减免 百分比
	restraint_attack_reduct_per	= ENUM.min_property_id + 46,--对攻职业英雄伤害减免 百分比
	restraint_skill_reduct_per	= ENUM.min_property_id + 47,--对技职业英雄伤害减免 百分比
	def_pierce = ENUM.min_property_id + 48,--防御穿透
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
