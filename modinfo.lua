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
version = "0.3"

priority = 1e308

forumthread = ""

api_version = 10

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false
server_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options = {
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

	{ -- new, needs translation
		name = "sound_volume",
		label = en_zh("Sound volume", ""),
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
			""
		),
	},

	{ -- new, needs translation
		name = "lmb_handler",
		label = en_zh("LMB handling", ""),
		options = {
			{
				description = en_zh("Hold and release", ""), 
				data = "hold_release",
				hover = en_zh("Click and hold LMB to start, release to finish.", ""),
			},
			{
				description = en_zh("Click and click again", ""), 
				data = "click_click",
				hover = en_zh("Click LMB to start, click again to finish.", ""),
			},
		},
		default = "hold_release",
		hover = en_zh(
			"Select the desired way for handling LMB.",
			""
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