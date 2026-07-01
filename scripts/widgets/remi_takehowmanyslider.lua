local Image = require "widgets/image"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"

local InventoryReplica = require "components/inventory_replica"

local lang = LanguageTranslator.defaultlang or "en"
local languages =
{
	zh = "zh", -- Chinese for Steam
	zhr = "zh", -- Chinese for WeGame
	ch = "zh", -- Chinese mod
	chs = "zh", -- Chinese mod
	sc = "zh", -- simple Chinese
	zht = "zh", -- traditional Chinese for Steam
	tc = "zh", -- traditional Chinese
	cht = "zh", -- Chinese mod
}

if languages[lang] ~= nil then
	lang = languages[lang]
else
	lang = "en"
end

local chinese = lang == "zh"
local TITLE_STRING = chinese and "拿多少？" or "Take how many?"
local TITLE_STRING_MOVE = chinese and "拿多少？" or "Move how many?"

local LMB_HANDLERS = {
	hold_release = function(self, key, down)
		if not down then self:TakeAndDestroy() end
	end,
	click_click = function(self, key, down)
		if not down then
			if self.clicked_once then self:TakeAndDestroy() else self.clicked_once = true end
		end
	end,
}

local NUMBER_KEY_HANDLERS = {
	one_full = function(self, key, down)
		if key == KEY_1 or key == KEY_KP_1 then
			self:PlaySound("dontstarve/HUD/toggle_off")
			self.takecount = 1
			self:UpdateNumber()
		elseif key == KEY_2 or key == KEY_KP_2 then
			self:PlaySound("dontstarve/HUD/toggle_on")
			self.takecount = self.maxtakecount
			self:UpdateNumber()
		end
	end,
	one_half_full = function(self, key, down)
		if key == KEY_1 or key == KEY_KP_1 then
			self:PlaySound("dontstarve/HUD/toggle_off")
			self.takecount = 1
			self:UpdateNumber()
		elseif key == KEY_2 or key == KEY_KP_2 then
			local newtakecount = math.floor(self.maxtakecount/2)
			if newtakecount == self.takecount then return true end
			self:PlaySound(self.takecount > newtakecount and "dontstarve/HUD/toggle_off" or "dontstarve/HUD/toggle_on")
			self.takecount = newtakecount
			self:UpdateNumber()
		elseif key == KEY_3 or key == KEY_KP_3 then
			self:PlaySound("dontstarve/HUD/toggle_on")
			self.takecount = self.maxtakecount
			self:UpdateNumber()
		end
	end,
	set_exact = function(self, key, down)
		local number = key >= KEY_KP_0 and key - KEY_KP_0 or key - KEY_0
		if number == 0 then number = 10 end -- no point setting it to 0 it will fallback to 1
		self.takecount = math.min(number, self.maxtakecount)
		self:UpdateNumber()
	end,
	typing = function(self, key, down)
		local digit = (key >= KEY_KP_0 and key - KEY_KP_0 or key - KEY_0)%10
		if self.typing then
			self.takecount = math.clamp(self.takecount*10+digit, 1, self.maxtakecount)
		else
			self.takecount = math.clamp(digit, 1, self.maxtakecount)
		end
		self.typing = true
		self:UpdateNumber()
	end,
}

local function calc_keyboard_scroll_speed(maxtakecount)
	return math.floor(4 - (maxtakecount/120)*3)
end

local config, key_scroll_up, key_scroll_down
local TakeHowManySlider = Class(Screen, function(self, owner, item, slot, container, _config, move_dest) -- yeah it's not a slider actually hehe
	Screen._ctor(self, "TakeHowManySlider")

	config = _config
	if config.scroll_with_mouse then
		key_scroll_up = MOUSEBUTTON_SCROLLUP
		key_scroll_down = MOUSEBUTTON_SCROLLDOWN
	else
		key_scroll_up = config.key_scroll_up
		key_scroll_down = config.key_scroll_down
	end

	self.HandleNumberKey = NUMBER_KEY_HANDLERS[config.inv_handler]
	self.pressed_num_keys = {}
	self.HandleLMB = LMB_HANDLERS[config.lmb_handler]

	self.owner = owner
	self.item = item
	self.slot = slot
	self.container = container -- this is inventory replica OR container replica
	self.move_dest = move_dest
	self.stackable = item.replica.stackable
	self.maxtakecount = math.min(self.stackable:StackSize(), self.stackable:OriginalMaxSize())
	self.takecount = math.floor(self.maxtakecount/2)
	self.lastscrolltime = -999
	if config.scroll_with_mouse == false then self.lastscrolltime = calc_keyboard_scroll_speed(self.maxtakecount) end
	self.fastscrolls = 0
	self.typing = false
	self.clicked_once = false

	self:SetScaleMode(SCALEMODE_PROPORTIONAL)
	local root = Widget("root") -- root is now supposed to be child of player's hud

	self.bg = root:AddChild(TEMPLATES.RectangleWindow(80,80)) -- Image("images/global.xml", "square.tex")
	--self.bg:SetSize(80,80)
	self.bg:SetTint(0,0,0,1)
	self.bg:SetBackgroundTint(0,0,0,.7)

	self.filler = root:AddChild(TEMPLATES.BackgroundTint(0.001))

	self.title = root:AddChild(Text(BODYTEXTFONT, 25, move_dest and TITLE_STRING_MOVE or TITLE_STRING, UICOLOURS.WHITE))
	self.title:SetPosition(0,25,0)
	self.number = root:AddChild(Text(HEADERFONT, 40, tostring(self.takecount), UICOLOURS.WHITE))
	self.number:SetPosition(0,-15,0)

	local scale = config.scale or 1
	root:SetScale(scale, scale)
	self.root = root

	self:StartUpdating()
end)

function TakeHowManySlider:PlaySound(sound, vol)
	TheFrontEnd:GetSound():PlaySound(sound, nil, (vol or 1)*config.sound_volume)
end

function TakeHowManySlider:OnMouseButton(button, down, x, y)
	-- Scrolling
	if --[[down and]] (button == key_scroll_up or button == key_scroll_down) then
		self.typing = false
		self:Scroll(button == key_scroll_up)
		return true
	end

	-- Number keys -- see OnRawKey

	-- Taking the item
	if button == MOUSEBUTTON_LEFT then
		self:HandleLMB(button, down)
		return true
	end

--	if not down and button == MOUSEBUTTON_RIGHT and config.move_on_rmb then
--		self:TakeAndDestroy(true)
--		return true
--	end

	return false
end

function TakeHowManySlider:OnRawKey(key, down)
	-- Scrolling
	if key == key_scroll_up or key == key_scroll_down then
		if down then
			self.typing = false
			self:KeyScroll(key == key_scroll_up)
		else
			self.fastscrolls = self.lastscrolltime
		end
		return true
	end

	-- Number keys
	if (key >= KEY_0 and key <= KEY_9 or key >= KEY_KP_0 and key <= KEY_KP_9) then
		if down and not self.pressed_num_keys[key] then
			self.pressed_num_keys[key] = true
			self:HandleNumberKey(key, down)
		elseif not down then
			self.pressed_num_keys[key] = nil
		end
		return true
	end

	-- Taking the item -- see OnMouseButton

	return false
end

function TakeHowManySlider:KeyScroll(up)
	self.fastscrolls = self.fastscrolls + 1 -- repurposing
	if self.fastscrolls < self.lastscrolltime then return end -- also repurposing
	self.fastscrolls = 0

	local newtakecount = math.clamp(self.takecount + (up and 1 or -1), 1, self.maxtakecount)
	if newtakecount ~= self.takecount then self:PlaySound(up and "dontstarve/HUD/toggle_on" or "dontstarve/HUD/toggle_off", self.lastscrolltime > 0 and .3 or .55) end
	self.takecount = newtakecount
	self:UpdateNumber()
end

function TakeHowManySlider:Scroll(up)
	local time = GetStaticTime()
	local delta = time - self.lastscrolltime
	if delta < .07 then
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

	local volume = delta > 1 and .3 or .55
	if not up then delta = -delta end

	local newtakecount = math.clamp(self.takecount + delta, 1, self.maxtakecount)
	if newtakecount ~= self.takecount then self:PlaySound(up and "dontstarve/HUD/toggle_on" or "dontstarve/HUD/toggle_off", volume) end
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
		return
	end

	local newmaxtakecount = math.min(self.stackable:StackSize(), self.stackable:OriginalMaxSize())
	if newmaxtakecount ~= self.maxtakecount then
		self.maxtakecount = newmaxtakecount
		if config.scroll_with_mouse == false then self.lastscrolltime = calc_keyboard_scroll_speed(newmaxtakecount) end
		self.takecount = math.min(self.takecount, newmaxtakecount)
		self:UpdateNumber()
	end
end

function TakeHowManySlider:Destroy()
	self.root:Kill()
	TheFrontEnd:PopScreen(self)
end

function TakeHowManySlider:TakeAndDestroy()
	if self.move_dest then -- move
		self.container:MoveItemFromCountOfSlot(self.slot, self.move_dest, self.takecount)
	else -- take
		-- self.container:TakeActiveItemFromCountOfSlot(self.slot, self.takecount) -- did you know? there's no count parameter in there!

		--[[ -- inventory_replica.lua
		
		function Inventory:TakeActiveItemFromCountOfSlot(slot)
			if self.inst.components.inventory ~= nil then
				self.inst.components.inventory:TakeActiveItemFromCountOfSlot(slot)
			elseif self.classified ~= nil then
				self.classified:TakeActiveItemFromCountOfSlot(slot)
			end
		end
		
		--]]
		
		-- let's work around it i guess
		if self.container.is_a and self.container:is_a(InventoryReplica) then
			if self.owner.components.inventory ~= nil then
				self.owner.components.inventory:TakeActiveItemFromCountOfSlot(self.slot, self.takecount)
			elseif self.container.classified ~= nil then
				-- self.container.classified:TakeActiveItemFromCountOfSlot(self.slot, self.takecount) -- did you know? the problems don't end here!

				--[[ -- inventory_classified.lua

				local function TakeActiveItemFromCountOfSlot(inst, slot, count)
					if not IsBusy(inst) and inst._activeitem == nil then
						local item = inst:GetItemInSlot(slot)
						if item ~= nil then
							local takeitem = SlotItem(item, slot)
							local stackable = item.replica.stackable
							local fullstacksize = stackable and (stackable:IsOverStacked() and stackable:OriginalMaxSize() or stackable:StackSize()) or 1
							count = math.clamp(count, 1, fullstacksize)
							if stackable and stackable:StackSize() > count then
								PushNewActiveItem(inst, takeitem, inst, slot)
								local stacksize = stackable:StackSize()
								PushStackSize(inst, item, stacksize - count, true, count, false)
							else
								PushItemLose(inst, takeitem)
								PushNewActiveItem(inst, takeitem, inst, slot)
							end
							SendRPCToServer(RPC.TakeActiveItemFromCountOfSlot, slot, count) -- !!! incorrect parameter order, container (nil) is missing before count gg rip
						end
					end
				end

				]]
				-- redoing the whole function is too cumbersome, let's just send the rpc
				TheNet:SendRPCToServer(RPC.TakeActiveItemFromCountOfSlot, self.slot, nil, self.takecount)
			end
		else -- container_replica does have the count parameter btw, safe to use
			self.container:TakeActiveItemFromCountOfSlot(self.slot, self.takecount)
		end
	end

	--TheNet:SendRPCToServer(rpc, self.slot, container, self.takecount) 
	-- self.inst:DoTaskInTime(0, function() self:Destroy() end)
	self:Destroy()
end

return TakeHowManySlider