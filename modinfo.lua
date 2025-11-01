---@diagnostic disable: lowercase-global
local function en_zh(en, zh)
	if zh == "" then return en end
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
	local lang = languages[locale] or en
    return lang == "zh" and zh or en
end

name = en_zh("Take How Many?","拿多少？")
description = en_zh(
	"Allows you to take any amount of item from stack instead of just half.\nAdjust the number by scrolling mouse wheel. Press Inv 1 or Inv 2 to set the number to smallest or largest possible values respectively.",
	"允许你从堆叠中拿出任意数量的物品，而不仅仅是一半。\n使用鼠标滚轮调整取出数量。按下物品栏数字键1或2，可快速将数量设置为最小或最大值。")
author = "Remi"
version = "0.4"

priority = 1e308

forumthread = ""

api_version = 10

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false
server_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local keys = {
    {description = en_zh("None", "无"), data = -1},
    {description = "F1", data = 282},
    {description = "F2", data = 283},
    {description = "F3", data = 284},
    {description = "F4", data = 285},
    {description = "F5", data = 286},
    {description = "F6", data = 287},
    {description = "F7", data = 288},
    {description = "F8", data = 289},
    {description = "F9", data = 290},
    {description = "F10", data = 291},
    {description = "F11", data = 292},
    {description = "F12", data = 293},
    {description = "Z", data = 122},
    {description = "X", data = 120},
    {description = "C", data = 99},
    {description = "V", data = 118},
    {description = "B", data = 98},
    {description = "N", data = 110},
    {description = "M", data = 109},
    {description = "A", data = 97},
    {description = "S", data = 115},
    {description = "D", data = 100},
    {description = "F", data = 102},
    {description = "G", data = 103},
    {description = "H", data = 104},
    {description = "J", data = 106},
    {description = "K", data = 107},
    {description = "L", data = 108},
    {description = "Q", data = 113},
    {description = "W", data = 119},
    {description = "E", data = 101},
    {description = "R", data = 114},
    {description = "T", data = 116},
    {description = "Y", data = 121},
    {description = "U", data = 117},
    {description = "I", data = 105},
    {description = "O", data = 111},
    {description = "P", data = 112},
    {description = "Num 1", data = 257},
    {description = "Num 2", data = 258},
    {description = "Num 3", data = 259},
    {description = "Num 4", data = 260},
    {description = "Num 5", data = 261},
    {description = "Num 6", data = 262},
    {description = "Num 7", data = 263},
    {description = "Num 8", data = 264},
    {description = "Num 9", data = 265},
    {description = "Num 0", data = 256},
    {description = "Num -", data = 269},
    {description = "Num +", data = 270},
    {description = "Num *", data = 268},
    {description = "Num /", data = 267},
    {description = "Num .", data = 266},
    {description = '\238\132\130', data = 1002}, -- mouse wheel
    {description = '\238\132\131', data = 1005}, -- mouse 4
    {description = '\238\132\132', data = 1006}, -- mouse 5
    {description = en_zh("None", "无"), data = -1},
}

--local keyboard_scrolling_speed_hover = en_zh([[Enter a number that will define how quickly the take amount will change, when holding a hotkey.

--The value is measured in FRAMES (30 frames = 1 second), and must be a positive integer.
--For example, a value of 3 will cause hotkeys to increase/decrease the take amount 10 times per second while held.

--Default is 7]]

configuration_options = {
	{ -- NEW, MACHINE TRANSLATED
		name = "scroll_with_mouse",
		label = en_zh("SCROLL WITH MOUSE", "用鼠标滚轮滚动"),
		options = {
			{
				description = en_zh("Yes", "是"),
				data = true, 
				-- no hover
			},
			{
				description = en_zh("No, use hotkeys", "不，使用快捷键。"),
				data = false, 
				hover = en_zh("Configure them right below.", "请在下一个设置中选择它们。"),
			},
		},
		default = true,
		hover = en_zh(
			"Choose whether you'd like to use the mouse wheel or hotkeys to change the take amount.", 
			"选择您是想使用鼠标滚轮还是快捷键来更改拾取物品的数量。"
		),
	},

	{ -- NEW, MACHINE TRANSLATED
		name = "key_scroll_up",
		label = en_zh("Scroll Up key", "向上滚动快捷键"),
		options = keys,
		default = 101,
		hover = en_zh(
			"WORKS ONLY IF SCROLLING WITH HOTKEYS\nChoose the key to increase the take amount.", 
			"仅在使用快捷键时有效\n选择按键以增加拾取物品的数量。"
		),
		is_keybind = true,
	},	

	{ -- NEW, MACHINE TRANSLATED
		name = "key_scroll_down",
		label = en_zh("Scroll Down key", ""),
		options = keys,
		default = 113,
		hover = en_zh(
			"WORKS ONLY IF SCROLLING WITH HOTKEYS\nChoose the key to decrease the take amount.", 
			"仅在使用快捷键时有效\n选择按键以减少可拾取物品的数量。"
		),
		is_keybind = true,
	},

	--[[
	{
		name = "fast_scrolling",
		label = en_zh("Fast scrolling", "快速滚动"),
		options = {
			{description = en_zh("Enabled", "启用"), data = true},
			{description = en_zh("Disabled", "禁用"), data = false},
		},
		default = true,
		hover = en_zh(
			"If enabled, the mod will change the take amount faster if you scroll quickly enough.",
			"启用后，当你足够快地滚动鼠标时，取出数量将加快变化。"
		),
	},

	{
		name = "keyboard_scrolling_speed",
		label = "Hotkey scroll rate",
		options = {{description = "Need mod!", data = "7", hover = "You need Configs Extended in order to edit this."}},
		default = "7",
		hover = keyboard_scrolling_speed_hover,
		is_text_config = true,
	},
	--]]

	{
		name = "widget_scale",
		label = en_zh("Widget scale", "窗口缩放比例"),
		options = {
			{description = "50%", data  =  .5},
			{description = "60%", data  =  .6},
			{description = "70%", data  =  .7},
			{description = "80%", data  =  .8},
			{description = "90%", data  =  .9},
			{description = "100%", data = 1.0},
			{description = "110%", data = 1.1},
			{description = "120%", data = 1.2},
			{description = "130%", data = 1.3},
			{description = "140%", data = 1.4},
			{description = "150%", data = 1.5},
		},
		default = 1.0,
		hover = en_zh(
			"Select the desired scale for the mod's exclusive widget.",
			"选择该模组专属窗口的显示缩放比例。"
		),
	},

	{
		name = "sound_volume",
		label = en_zh("Sound volume", "音效音量"),
		options = {
			{description =   "0%", data =   0},
			{description =  "10%", data =  .1},
			{description =  "20%", data =  .2},
			{description =  "30%", data =  .3},
			{description =  "40%", data =  .4},
			{description =  "50%", data =  .5},
			{description =  "60%", data =  .6},
			{description =  "70%", data =  .7},
			{description =  "80%", data =  .8},
			{description =  "90%", data =  .9},
			{description = "100%", data = 1.0},
		},
		default = 1.0,
		hover = en_zh(
			"Select the desired volume for sounds played by the mod's widget.",
			"选择此模组小部件播放音效时的音量大小"
		),
	},

	{
		name = "lmb_handler",
		label = en_zh("LMB handling", "鼠标左键操作方式"),
		options = {
			{
				description = en_zh("Hold and release", "按住并松开"),
				data = "hold_release",
				hover = en_zh("Click and hold LMB to start, release to finish.", "按住鼠标左键开始，松开结束"),
			},
			{
				description = en_zh("Click and click again", "点击并再次点击"),
				data = "click_click",
				hover = en_zh("Click LMB to start, click again to finish.", "点击鼠标左键开始，再次点击结束"),
			},
		},
		default = "hold_release",
		hover = en_zh(
			"Select the desired way for handling LMB.",
			"选择你希望的鼠标左键操作方式"
		),
	},

	{
		name = "inv_handler",
		label = en_zh("Inv keys handling", "物品栏数字键模式"),
		options = {
			{
				description = en_zh("One/Full", "1个 / 全部"),
				data = "one_full",
				hover = en_zh("Press Inv 1 to set take amount to 1, or Inv 2 to set it to max.", "按下物品栏数字键1可设为1个，数字键2可设为最大数量。")
			},
			{
				description = en_zh("One/Half/Full", "1个 / 一半 / 全部"),
				data = "one_half_full",
				hover = en_zh("Press Inv 1 to set take amount to 1, Inv 2 for half, Inv 3 for max.", "按下物品栏数字键1设为1个，数字键2为一半，数字键3为最大数量。")
			},
			{
				description = en_zh("Set to the number", "设为对应数字"),
				data = "set_exact",
				hover = en_zh("Inv keys will set take amount to their corresponding number.", "物品栏数字键将设置为对应的数量。")
			},
			{
				description = en_zh("Type the amount", "输入数量"),
				data = "typing",
				hover = en_zh("Use Inv keys to type the amount you need.", "使用物品栏数字键逐位输入你想要的数量。")
			},
		},
		default = "one_full",
		hover = en_zh(
			"Select the desired way for handling inventory keys 1 to 10.", 
			"选择如何使用物品栏数字键（1~10）设置数量。"
		),
	},
}