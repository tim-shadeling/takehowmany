GLOBAL.setmetatable(env, {__index = function(a, b) return GLOBAL.rawget(GLOBAL, b) end})
rawset(GLOBAL, "takehowmany_suppress_inv", false)

local TakeHowManySlider = require "widgets/remi_takehowmanyslider"

local config = {
	fast_scrolling = GetModConfigData("fast_scrolling"),
	scale = GetModConfigData("widget_scale"),
}

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
	                -- HELLO
	                local hud = self.owner.HUD
	                hud.takehowmany = hud:AddChild(TakeHowManySlider(container_item, slot_number, container, config))
	                hud.takehowmany:SetPosition(TheInput:GetScreenPosition()+Vector3(0,50,0))
	                --container:TakeActiveItemFromHalfOfSlot(slot_number)
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

--------------------------------- Taken from Item Scroller --------------------------------------
-- ♥ :D
local function IsCursorOnHUD()
	local input = TheInput
	return input.hoverinst and input.hoverinst.Transform == nil
end
local function playercontroller_postinit(self)
	local old_DoCameraControl = self.DoCameraControl
	function self:DoCameraControl()
		if not ((TheInput:IsControlPressed(CONTROL_ZOOM_IN) or TheInput:IsControlPressed(CONTROL_ZOOM_OUT)) and IsCursorOnHUD() ) then
			if old_DoCameraControl ~= nil then old_DoCameraControl(self) end
		end
	end
end
AddComponentPostInit("playercontroller",playercontroller_postinit)
---------------------------------- End of borrowed code -----------------------------------------

AddClassPostConstruct("screens/playerhud", function(self)
	local oldfn = self.OnControl
	self.OnControl = function(self, control, down)
		if control >= _G.CONTROL_INV_1 and control <= _G.CONTROL_INV_10 and GLOBAL.takehowmany_suppress_inv and self.takehowmany then
			return self.takehowmany:OnControl(control, down)
		end
		return oldfn(self, control, down)
	end
end)