local Image = require "widgets/image"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"


local INV_CONTROL_HANDLERS = {
    one_full = function(self, control)
        if control == CONTROL_INV_1 then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/toggle_off")
            self.takecount = 1
            self:UpdateNumber()
        elseif control == CONTROL_INV_2 then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/toggle_on")
            self.takecount = self.maxtakecount
            self:UpdateNumber()
        end
    end,
    one_half_full = function(self, control)
        if control == CONTROL_INV_1 then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/toggle_off")
            self.takecount = 1
            self:UpdateNumber()
        elseif control == CONTROL_INV_2 then
            local newtakecount = math.floor(self.maxtakecount/2)
            if newtakecount == self.takecount then return true end
            TheFrontEnd:GetSound():PlaySound(self.takecount > newtakecount and "dontstarve/HUD/toggle_off" or "dontstarve/HUD/toggle_on")
            self.takecount = newtakecount
            self:UpdateNumber()
        elseif control == CONTROL_INV_3 then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/toggle_on")
            self.takecount = self.maxtakecount
            self:UpdateNumber()
        end
    end,
    set_exact = function(self, control)
        local digit = control - CONTROL_INV_1 + 1
        self.takecount = math.min(digit, self.maxtakecount)
        self:UpdateNumber()
    end,
    typing = function(self, control)
        local digit = control - CONTROL_INV_1 + 1
        if self.typing then
            self.takecount = math.min(self.takecount*10+digit, self.maxtakecount)
        else
            self.takecount = math.min(digit, self.maxtakecount)
        end
        self.typing = true
        self:UpdateNumber()
    end,
}

local TakeHowManySlider = Class(Widget, function(self, item, slot, container, config)
    Widget._ctor(self, "TakeHowManySlider")
    self.config = config

    self.HandleInvControl = INV_CONTROL_HANDLERS[config.inv_handler]

    self.item = item
    self.slot = slot
    self.container = container.inst ~= ThePlayer and container.inst or nil
    self.maxtakecount = math.min(GetStackSize(item), item.replica.stackable and item.replica.stackable:OriginalMaxSize())
    self.takecount = math.floor(self.maxtakecount/2)
    self.lastscrolltime = -999
    self.fastscrolls = 0
    self.typing = false

    local root = self:AddChild(Widget("root"))

    self.bg = root:AddChild(TEMPLATES.RectangleWindow(80,80)) -- Image("images/global.xml", "square.tex")
    --self.bg:SetSize(80,80)
    self.bg:SetTint(0,0,0,1)
    self.bg:SetBackgroundTint(0,0,0,.7)

    self.filler = root:AddChild(TEMPLATES.BackgroundTint(0.001))

    self.title = root:AddChild(Text(BODYTEXTFONT, 25, "Take how many?", UICOLOURS.WHITE))
    self.title:SetPosition(0,25,0)
    self.number = root:AddChild(Text(HEADERFONT, 40, tostring(self.takecount), UICOLOURS.WHITE))
    self.number:SetPosition(0,-15,0)

    self.root = root
    local scale = self.config.scale or 1
    self:SetScale(scale, scale)
    takehowmany_suppress_inv = true
    self:StartUpdating()
end)

function TakeHowManySlider:OnControl(control, down)
    if not down then
        if control == CONTROL_ACCEPT then
            TheNet:SendRPCToServer(RPC.TakeActiveItemFromCountOfSlot, self.slot, self.container, self.takecount) 
            self:Kill()
            takehowmany_suppress_inv = false
            return true
        end
    else
        if control == CONTROL_ZOOM_IN or control == CONTROL_ZOOM_OUT then
            self:Scroll(control == CONTROL_ZOOM_IN)
            self.typing = false
            self:UpdateNumber()
            return true
        elseif control >= CONTROL_INV_1 and control <= CONTROL_INV_10 then
            self:HandleInvControl(control)
            return true
        end
    end
    return false
end

function TakeHowManySlider:Scroll(up)
    local time = GetStaticTime()
    local delta = time - self.lastscrolltime
    if self.config.fast_scrolling and delta < .07 then
        self.fastscrolls = self.fastscrolls + 1
        if self.fastscrolls >= 2 then
            delta = 1 + math.min(math.floor(self.maxtakecount/30),10)
        else
            delta = 1
        end
    else
        self.fastscrolls = 0
        delta = 1
    end
    --print("[TAKEHOWMANY] Time delta:", time - self.lastscrolltime, "Scroll delta:", delta)
    local volume = delta > 1 and .3 or .7
    if not up then delta = -delta end

    local newtakecount = math.clamp(self.takecount + delta, 1, self.maxtakecount)
    if newtakecount ~= self.takecount then TheFrontEnd:GetSound():PlaySound(up and "dontstarve/HUD/toggle_on" or "dontstarve/HUD/toggle_off", nil, volume) end
    self.takecount = newtakecount
    self:UpdateNumber()

    self.lastscrolltime = time
end

function TakeHowManySlider:UpdateNumber()
    self.number:SetString(tostring(self.takecount))
    if self.typing then self.number:SetColour(1,1,0,1) else self.number:SetColour(1,1,1,1) end
end

function TakeHowManySlider:OnUpdate(dt)
    if not self.item:IsValid() or not self.item.replica.inventoryitem.classified then
        self:Kill()
        takehowmany_suppress_inv = false
        return
    end

    local newmaxtakecount = math.min(GetStackSize(self.item), self.item.replica.stackable and self.item.replica.stackable:OriginalMaxSize())
    if newmaxtakecount ~= self.maxtakecount then
        self.maxtakecount = newmaxtakecount
        self.takecount = math.min(self.takecount, newmaxtakecount)
        self:UpdateNumber()
    end
end

return TakeHowManySlider