GLOBAL.setmetatable(env, {__index = function(a, b) return GLOBAL.rawget(GLOBAL, b) end})

local TakeHowManySlider = require "widgets/remi_takehowmanyslider"
local takehowmany = nil

local config
local function Reconfigure(silent)
	config = {
		scroll_with_mouse = GetModConfigData("scroll_with_mouse"),
		key_scroll_up = GetModConfigData("key_scroll_up"),
		key_scroll_down = GetModConfigData("key_scroll_down"),
		-- fast_scrolling = GetModConfigData("fast_scrolling"),
		--keyboard_scrolling_speed = math.max(tonumber(GetModConfigData("keyboard_scrolling_speed") or 1), 1),
		scale = GetModConfigData("widget_scale"),
		sound_volume = GetModConfigData("sound_volume"), 
		lmb_handler = GetModConfigData("lmb_handler"), 
		inv_handler = GetModConfigData("inv_handler"),
	}

	if takehowmany and takehowmany.inst:IsValid() then takehowmany:Destroy() end

	if not silent and ThePlayer then ThePlayer.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/learn_map") end
end
Reconfigure(true)

AddClassPostConstruct("widgets/invslot", function(InvSlot)
	function InvSlot:Click(stack_mod)
		-- I mean I could make this into an "oldfn" and call that from the mod, but...
		-- I would need to recalculate all these so idk
		local slot_number = self.num
		local character = ThePlayer
		local inventory = character and character.replica.inventory or nil
		local active_item = inventory and inventory:GetActiveItem() or nil
		local container = self.container
		local container_item = container and container:GetItemInSlot(slot_number) or nil
		--

		if active_item ~= nil or container_item ~= nil then
			if container_item == nil then
				--Put active item into empty slot
				if container:CanTakeItemInSlot(active_item, slot_number) then
					if active_item.replica.stackable ~= nil and
						active_item.replica.stackable:IsStack() and
						(stack_mod or not container:AcceptsStacks()) then
						--Put one only
						container:PutOneOfActiveItemInSlot(slot_number)
					else
						--Put entire stack
						container:PutAllOfActiveItemInSlot(slot_number)
					end
					TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
				else
					TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
				end
			elseif active_item == nil then
				--Take active item from slot
				local takecount
				if inventory and inventory ~= container then -- Variable character cannot be nil from above.
					local maxtakecountfunction = GetDesiredMaxTakeCountFunction(container_item.prefab)
					if maxtakecountfunction then
						takecount = maxtakecountfunction(character, inventory, container_item, container)
					end
				end
				if takecount then
					if takecount > 0 then
						-- Take a set number from a slot if possible.
						if stack_mod then
							takecount = math.max(math.floor(takecount / 2), 1)
						end
						container:TakeActiveItemFromCountOfSlot(slot_number, takecount)
						TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
					else
						-- Block taking anything if this override exists.
						TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
					end
				elseif stack_mod and
				container_item.replica.stackable ~= nil and
				container_item.replica.stackable:IsStack() then
					takehowmany = TakeHowManySlider(container_item, slot_number, container, config)
					-- Thinking out of the box or a bad mod practice??
					ThePlayer.HUD:AddChild(takehowmany.root) -- ADOPTED LMAO
					takehowmany.root:SetPosition(self:GetWorldPosition()+Vector3(0,80*config.scale,0))
					--
					TheFrontEnd:PushScreen(takehowmany)
					TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
				else
					--Take entire stack
					container:TakeActiveItemFromAllOfSlot(slot_number)
					TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
				end
			elseif container:CanTakeItemInSlot(active_item, slot_number) then
				if container_item.prefab == active_item.prefab and container_item:StackableSkinHack(active_item) and container_item.replica.stackable ~= nil and container:AcceptsStacks() then
					--Add active item to slot stack
					if stack_mod and
						active_item.replica.stackable ~= nil and
						active_item.replica.stackable:IsStack() and
						not container_item.replica.stackable:IsFull() then
						--Add only one
						container:AddOneOfActiveItemToSlot(slot_number)
					else
						--Add entire stack
						container:AddAllOfActiveItemToSlot(slot_number)
					end
					TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")

				elseif active_item.replica.stackable ~= nil and active_item.replica.stackable:IsStack() and not container:AcceptsStacks() then
					container:SwapOneOfActiveItemWithSlot(slot_number)

				elseif (container:AcceptsStacks() or not (active_item.replica.stackable and active_item.replica.stackable:IsStack()))
					and not (container_item.replica.stackable and container_item.replica.stackable:IsOverStacked())
				then
					--Swap active item with slot item
					container:SwapActiveItemWithSlot(slot_number)
					TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
				else
					TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
				end
			else
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
			end
		end
	end
end)

-- There used to be a chunk of code borrowed from Item Scroller (13 lines).
-- It has served well for a very long time ♥ :D

AddUserCommand("thmcfg", { -- Take How Many ConFiG lul
	prettyname = "Take How Many Config",
	desc = "Reconfigure the mod without having to reload the game!",
	permission = COMMAND_PERMISSION.USER,
	slash = true,
	usermenu = false,
	servermenu = false,
	params = {},
	vote = false,
	localfn = function() -- params, caller
		local success, result = pcall(function() return require "widgets/remi_newmodconfigurationscreen" end)
		if success then
			TheFrontEnd:PushScreen(result(modname, true, Reconfigure))
		else
			response("Failed to open the configuration panel", result)
		end
	end,
})