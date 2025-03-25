name = "Take How Many?"
description = "Allows you to take any amount of item from stack instead of just half.\nAdjust the number by scrolling mouse wheel. Press Inv 1 or Inv 2 to set the number to smallest or largest possible values respectively."
author = "Remi"
version = "0.1.1"

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
		label = "Fast scrolling",
		options = {
			{description = "Enabled", data = true},
			{description = "Disabled", data = false},
		},
		default = true,
		hover = "If enabled, the mod will change the take amount faster if you scroll quickly enough.",
	},

	{
		name = "widget_scale",
		label = "Widget scale",
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
		hover = "Select the desired scale for the mod's exclusive widget.",
	},



}