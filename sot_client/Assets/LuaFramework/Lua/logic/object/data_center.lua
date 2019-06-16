---@class DataCenter
local DataCenter = {}
_G["DataCenter"] = DataCenter

function DataCenter.Init()
    DataCenter.m_isInit = true;
    DataCenter.m_data = {};

    DataCenter.AddData(EDataCenter.player, PlayerData:new())
end

---@param _type EDataCenter
---@param data DataBase
function DataCenter.AddData(_type, data)
    if _type and data then
        if not DataCenter.m_data[_type] then
            DataCenter.m_data[_type] = data
        else
            logError("DataCenter AddData but data already set")
        end
    else
        logError("DataCenter AddData but _type or data is nil: " .. tostring(_type) .. tostring(data))
    end
end

--[[清除所有数据]]
function DataCenter.ClearAll()
    for k, v in pairs(DataCenter.m_data) do
        delete(v);
    end
    DataCenter.m_data = {};
end

-----------------------------------外部接口---------------------------------------------
---初始化
function DataCenterInit()
    if DataCenter.m_isInit then
        logError("DataCenter already Init ---- " .. debug.traceback())
    end
    DataCenter.Init()
end

------获取数据中心模块数据
---@param dataCenter EDataCenter 数据类型 参见EDataCenter枚举
---@return DataBase
function DataCenterGet(dataType, subType)
    if subType then
        return DataCenter.m_data[dataType][subType];
    else
        return DataCenter.m_data[dataType];
    end
end

function GetDataCenter()
    return DataCenter;
end

---------------------初始化
DataCenterInit()
