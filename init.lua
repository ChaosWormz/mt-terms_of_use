--originally by keaza
local FORMNAME = "tos:tos_fs"

local TOS = [[
Griefing, vandalism and Stealing are prohibited.
swearing is prohibited.

Please respect other players.
When cutting down trees please replant your saplings.
usage of hacked clients is disalowed.
Respect protected areas.

Don't ask or beg admins for items.
Don't Ask to be part of the staff.

this server always shuts down at 10PM GMT+2.
please don't afk or idle.
do not request extra privs.
]]
local TOS_list = { } -- list[paragraph][word]
local par_wordlist
par_wordlist = { }
for line in TOS:gmatch("(.-)\n") do
	if line == "" then
		table.insert(TOS_list, par_wordlist)
		par_wordlist = { }
	end
	for word in line:gmatch("[%w][%w'_-]*") do
		table.insert(par_wordlist, word)
	end
end

local ord_suffix = { "st", "nd", "rd", [11] = "th", [12] = "th", [13] = "th" }
local function ordinal(n)
	return n..(ord_suffix[n % 100] or ord_suffix[n % 10] or "th")
end

local function rnditem(list)
	local i = math.floor(math.random(1, #list))
	return list[i], i
end

local function make_formspec()
	local par, pindex = rnditem(TOS_list)
	local word, windex = rnditem(par)
	local fs = { "size[9,8]" }
	table.insert(fs, "textarea[0.5,0.5;8,7;TOS;Terms of Service;"..TOS.."]")
	table.insert(fs, "field[0.5,7.5;6,1;entry;Please enter the "
		..ordinal(windex).." word of the "..ordinal(pindex).." paragraph.;]")
	table.insert(fs, "button_exit[6,7.4;1.5,0.5;ok;Accept]")
	table.insert(fs, "button[7.5,7.4;1.5,0.5;no;Decline]")
	table.insert(fs, "field[10,10;0.1,0.1;hidden_word;;"..word.."]")
	return table.concat(fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then return end
	local name = player:get_player_name()
	if fields.quit then
		local privs = minetest.get_player_privs(name)
		if not privs.tos_accepted then
			minetest.chat_send_player(name, "Please read the terms of use.")
			minetest.show_formspec(name, FORMNAME, make_formspec())
			return
		end
	elseif fields.ok then
		if fields.hidden_word == fields.entry then
			minetest.chat_send_player(name, "Have Fun!")
			minetest.chat_send_player(name, "You've been Granted Interact.")
			local privs = minetest.get_player_privs(name)
			privs.tos_accepted = true
			privs.interact = true
			minetest.set_player_privs(name, privs)
		else
			minetest.chat_send_player(name, "Incorrect, Please try again.")
			minetest.show_formspec(name, FORMNAME, make_formspec())
			return
		end
	
	elseif fields.no then
		minetest.kick_player(name, "All players must read and agree to the rules.")
		return
	end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local privs = minetest.get_player_privs(name)
	if not privs.tos_accepted then
		minetest.after(1, function()
			minetest.show_formspec(name, FORMNAME, make_formspec())
		end)
	end
end)

minetest.register_privilege("tos_accepted", "TOS Accepted")
