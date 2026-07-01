GLOBAL.setmetatable(env, {__index = function(a, b) return GLOBAL.rawget(GLOBAL, b) end})

local TakeHowManySlider = require "widgets/remi_takehowmanyslider"
local takehowmany = nil

local config
local function Reconfigure(settings, silent)
	local getconfig = settings and function(k) return settings[k] end or GetModConfigData
	config = {
		scroll_with_mouse = getconfig("scroll_with_mouse"),
		key_scroll_up = getconfig("key_scroll_up"),
		key_scroll_down = getconfig("key_scroll_down"),
		scale = getconfig("widget_scale"),
		sound_volume = getconfig("sound_volume"), 
		lmb_handler = getconfig("lmb_handler"), 
		inv_handler = getconfig("inv_handler"),
	}

	if takehowmany and takehowmany.inst:IsValid() then takehowmany:Destroy() end

	if not silent and TheFocalPoint then TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/learn_map") end
end
Reconfigure(nil, true)

AddClassPostConstruct("widgets/invslot", function(InvSlot)
	local oldclickfn = InvSlot.Click
	function InvSlot:Click(stack_mod, ...)
		local slot_number = self.num
		local character = self.owner
		local inventory = character and character.replica.inventory or nil
		local active_item = inventory and inventory:GetActiveItem() or nil
		local container = self.container
		local container_item = container and container:GetItemInSlot(slot_number) or nil

		if character and inventory and container_item and not active_item then
			local takecount
			if inventory and inventory ~= container then -- Variable character cannot be nil from above.
				local maxtakecountfunction = GetDesiredMaxTakeCountFunction(container_item.prefab)
				if maxtakecountfunction then takecount = maxtakecountfunction(character, inventory, container_item, container) end
			end
			if not takecount and stack_mod and container_item.replica.stackable ~= nil and container_item.replica.stackable:IsStack() then
				takehowmany = TakeHowManySlider(character, container_item, slot_number, container, config)
				ThePlayer.HUD:AddChild(takehowmany.root) -- thinking out of the box or a bad mod practice??
				takehowmany.root:SetPosition(self:GetWorldPosition()+Vector3(0,80*config.scale,0))
				TheFrontEnd:PushScreen(takehowmany)
				--
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
				--
				return
			end
		end

		oldclickfn(self, stack_mod, ...)
	end

	-- obtain the function that determines the most suitable container when moving items
	local function getupvalue(fn, target_name)
		local i = 1
		local name, val = debug.getupvalue(fn, i)
		while name and name ~= target_name do
			i = i+1
			name, val = debug.getupvalue(fn, i)
		end
		return val, i
	end
	local FindBestContainer = getupvalue(InvSlot.TradeItem, "FindBestContainer") -- fun fact: this is the only upvalue there, still gotta dig it out the correct way in case things get changed
	--

	local oldtradefn = InvSlot.TradeItem
	function InvSlot:TradeItem(stack_mod, ...)
		local slot_number = self.num
		local character = self.owner
		local inventory = character and character.replica.inventory or nil
		local container = self.container
		local container_item = container and (container.IsReadOnlyContainer == nil or not container:IsReadOnlyContainer()) and container:GetItemInSlot(slot_number) or nil

		if character and inventory and container_item then
			local opencontainers = inventory:GetOpenContainers()
			local haswriteablecontainer = false
			for opencontainer, _ in pairs(opencontainers) do
				if opencontainer.replica.container and not opencontainer.replica.container:IsReadOnlyContainer() then
					haswriteablecontainer = true
					break
				end
			end
			if not haswriteablecontainer then
				return
			end

			local overflow = inventory:GetOverflowContainer()
			local backpack = nil
			if overflow ~= nil and overflow:IsOpenedBy(character) then
				backpack = overflow.inst
				overflow = backpack.replica.container
				if overflow == nil then
					backpack = nil
				end
			else
				overflow = nil
			end

			--find our destination container
			local dest_inst = nil
			if container == inventory then
				local playercontainers = backpack ~= nil and { [backpack] = true } or nil
				dest_inst = FindBestContainer(self, container_item, opencontainers, playercontainers)
					or FindBestContainer(self, container_item, playercontainers)
			elseif container == overflow then
				dest_inst = FindBestContainer(self, container_item, opencontainers, { [backpack] = true })
					or (inventory:IsOpenedBy(character)
						and FindBestContainer(self, container_item, { [character] = true })
						or nil)
			else
				local exclude_containers = { [container.inst] = true }
				if backpack ~= nil then
					exclude_containers[backpack] = true
				end
				dest_inst = FindBestContainer(self, container_item, opencontainers, exclude_containers) or
					(inventory:IsOpenedBy(character) and character or backpack)
			end

			--if a destination container/inv is found...
			if dest_inst ~= nil then
				local takecount
				if inventory and inventory ~= container then -- Variable character cannot be nil from above.
					local maxtakecountfunction = GetDesiredMaxTakeCountFunction(container_item.prefab)
					if maxtakecountfunction then
						takecount = maxtakecountfunction(character, inventory, container_item, container)
					end
				end
				if not takecount and stack_mod and container_item.replica.stackable ~= nil and container_item.replica.stackable:IsStack() then
					takehowmany = TakeHowManySlider(character, container_item, slot_number, container, config, dest_inst) -- schmoovin'
					ThePlayer.HUD:AddChild(takehowmany.root) -- hehe get adopted
					takehowmany.root:SetPosition(self:GetWorldPosition()+Vector3(0,80*config.scale,0))
					TheFrontEnd:PushScreen(takehowmany)
					--
					TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
					--
					return
				end
			end
		end

		oldtradefn(self, stack_mod, ...)
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
--
AddGamePostInit(function()
	local mods = REMI_RECONFIGURABLE_MODS
	if mods then mods[modname] = Reconfigure end
end)