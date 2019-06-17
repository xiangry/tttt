---@class UIStack 模拟ui堆栈
local UIStack = Class("UIStack")
_G["UIStack"] = UIStack

function UIStack:Init(data)
    self.ui_stack = {}
end

function UIStack:PushUI(name)
    self.ui_stack[#self.ui_stack + 1] = scene_id
end

function UIStack:PopUI(name)
    self.ui_stack[#self.ui_stack] = nil;
end

function UIStack:GetCount(name)
    return #self.ui_stack
end

