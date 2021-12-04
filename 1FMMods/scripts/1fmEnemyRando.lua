LUAGUI_NAME = "EnemyRando"
LUAGUI_AUTH = "denhonator"
LUAGUI_DESC = "Randomizes enemies"

local offset = 0x3A0606
local world = 0x233CADC - offset
local room = world + 0x68
local blackfade = 0x4D93B8 - offset
local whitefade = 0x233C49C - offset
local cutsceneFlags = 0x2DE65D0-0x200 - offset
local worldFlagBase = 0x2DE79D0+0x6C - offset
local ardOff = 0x2394BB0 - offset
local OCard = 0x23A23B0 - offset
local OCseed = 0x2389480 - offset
local state = 0x2863958 - offset
local bittestRender = 0x232A470 - offset
local combo = 0x2DE24B4 - offset
local soraPointer = 0x2534680 - offset
local bossPointer = 0x2D338D0 - offset
local malPointer = 0x2D338A8 - offset
local warpTrigger = 0x22E86DC - offset
local warpType1 = 0x233C240 - offset
local warpType2 = 0x22E86E0 - offset
local worldWarp = 0x233CB70 - offset
local roomWarp = worldWarp + 4
local counter = 0
local fallcounter = 0
local monitor = 0
local lastMonitor = 0
local hasChanged = false
local lastAddr = 0
local replaced = false
local lastBlack = 0
local bossLastHP = 0
local endfightTimer = 0
local antisorabeaten = false
local addBreakout = false
local heightAdjust = 0
local adjustAddr = 0
local hpScale = 1

local normal = {"xa_ew_2010", "xa_ew_2020", "xa_ew_2030",
				"xa_ex_2010", "xa_ex_2020", "xa_ex_2030", "xa_ex_2040",
				"xa_ex_2050", "xa_ex_2060", "xa_ex_2070", "xa_ex_2080", "xa_ex_2090",
				"xa_ex_2100", "xa_ex_2110", "xa_ex_2120", "xa_ex_2130", "xa_ex_2140",
				"xa_ex_2150", "xa_ex_2160", "xa_ex_2170", "xa_ex_2180",
				"xa_ex_2190", "xa_ex_2200", "xa_ex_2210",
				"xa_ex_2220", "xa_ex_2230", "xa_ex_2250", "xa_ex_2270",
				"xa_ex_2290", "xa_ex_2320", "xa_ex_2330", "xa_ex_2340",
				"xa_pp_3020"}
				
local lite = {"xa_ew_2010", "xa_ew_2020", "xa_ew_2030",
				"xa_ex_2010", "xa_ex_2020", "xa_ex_2030", "xa_ex_2040",
				"xa_ex_2050", "xa_ex_2060", "xa_ex_2070", "xa_ex_2080", "xa_ex_2090",
				"xa_ex_2100", "xa_ex_2110", "xa_ex_2120", "xa_ex_2130", "xa_ex_2140",
				"xa_ex_2160", "xa_ex_2170", "xa_ex_2180",
				"xa_ex_2190", "xa_ex_2200", "xa_ex_2210",
				"xa_ex_2220", "xa_ex_2230", "xa_ex_2240",
				"xa_ex_2250", "xa_ex_2270",
				"xa_ex_2290", "xa_ex_2320", "xa_ex_2330",
				"xa_ex_2340", "xa_ex_2350", "xa_pp_3020"}
				
local bandit = {"xa_ew_2010", "xa_ew_2020", "xa_ew_2030",
				"xa_ex_2010", "xa_ex_2020", "xa_ex_2030", "xa_ex_2040",
				"xa_ex_2050", "xa_ex_2060", "xa_ex_2070", "xa_ex_2080", "xa_ex_2090",
				"xa_ex_2150", "xa_ex_2160", "xa_ex_2170", "xa_ex_2180",
				"xa_ex_2190", "xa_ex_2200", "xa_ex_2210",
				"xa_ex_2220", "xa_ex_2230",
				"xa_ex_2250", "xa_ex_2270", "xa_ex_2280",
				"xa_ex_2290", "xa_ex_2320", "xa_ex_2330",
				"xa_ex_2340", "xa_ex_2380",
				"xa_ex_2390", "xa_pp_3020"}
				
local boss = {"xa_he_3020", "xa_di_3000", "xa_ew_3020", "xa_al_3010", "xa_nm_3000",
			  "xa_al_3050", "xa_ex_1580", "xa_ex_1160", "xa_ex_1150", "xa_ex_1030",
			  "xa_ex_1630", "xa_he_1010", "xa_he_3000", "xa_pc_3000",
			  "xa_pi_3000", "xa_pp_3000", "xa_pp_3030", "xa_tz_3010", "xa_ex_1040",
			  "xa_ex_3000", "xa_ex_3010", "xa_pc_3020", "xa_tz_3020"}
			  
local cloud = {"xa_he_3020", "xa_di_3000", "xa_al_3010", "xa_nm_3000",
			  "xa_al_3050", "xa_ex_1580", "xa_ex_1160", "xa_ex_1150", "xa_ex_1030",
			  "xa_ex_1630", "xa_he_1010", "xa_he_3000", "xa_pc_3000",
			  "xa_pi_3000", "xa_pp_3000", "xa_tz_3010", "xa_ex_1040",
			  "xa_ex_3000", "xa_ex_3010", "xa_tz_3020"}
	  
local duo = {"xa_ex_1150", "xa_ex_1030", "xa_ex_1040", "xa_tz_3020"}
			  
local parasite = {"xa_he_1000"}
local pc1riku = {"xa_ex_1160", "xa_di_1010", "xa_di_1030", "xa_ex_1010", 
				"xa_ex_1030", "xa_ex_1040", "xa_ex_1580"}
			  
local jafar = {"xa_di_3000", "xa_nm_3000", "xa_di_1010", "xa_di_1020",
			  "xa_ex_1160", "xa_ex_1150", "xa_ex_1030", "xa_di_1030",
			  "xa_pc_3000", "xa_he_1030", "xa_ex_1010",
			  "xa_pi_3000", "xa_pp_3000", "xa_ex_1040", "xa_ex_1580"}
			  
local genie = {"xa_ex_1150", "xa_ex_1030", "xa_tz_3010", "xa_tz_3000",
			  "xa_he_1030", "xa_pi_3000", "xa_ex_1040", "xa_ex_4010",
			  "xa_ex_2310", "xa_ex_1010", "xa_di_1030", "xa_di_1020",
			  "xa_di_1010", "xa_aw_1030"}
  
local trick = {"xa_he_3020", "xa_ex_2310", "xa_he_3000", "xa_pi_3000", "xa_nm_3000",
				"xa_ew_2040", "xa_di_1010", "xa_di_1020", "xa_di_1030", "xa_al_3020"}
				
local antisora = {"xa_pi_3000", "xa_nm_3000", "xa_di_1010", "xa_di_1020", 
					"xa_di_1030", "xa_ex_1010", "xa_ex_1160", "xa_ex_1150",
					"xa_ex_1030", "xa_ex_1040", "xa_pp_3000", "xa_ew_2040",
					"xa_al_3010", "xa_ex_1580"}
					
local hook = {"xa_pi_3000", "xa_nm_3000", "xa_di_1010", "xa_di_1020", 
				"xa_di_1030", "xa_ex_1010", "xa_ex_1160", "xa_ex_1150",
				"xa_ex_1030", "xa_ex_1040", "xa_pp_3030", "xa_ew_2040",
				"xa_al_3010", "xa_pc_3000", "xa_di_3000", "xa_al_3020",
				"xa_ew_2050", "xa_he_1010", "xa_pc_3020", "xa_tz_3000",
				"xa_pp_3010", "xa_lm_3030", "xa_ex_1580"}
				
local mal = {"xa_pi_3000", "xa_nm_3000", "xa_di_1010", "xa_di_1020", 
				"xa_di_1030", "xa_ex_1010", "xa_ex_1160", "xa_ex_1580",
				"xa_ex_1030", "xa_ex_1040", "xa_ew_2040",
				"xa_pc_3000", "xa_di_3000", "xa_he_3000",
				"xa_ew_2050", "xa_pc_3020", "xa_tz_3000",
				"xa_pp_3010", "xa_lm_3030", "xa_ex_1010"}
				
local dragmal = {"xa_ex_3010", "xa_tz_3010", "xa_ex_1040", "xa_ex_1580",
				"xa_he_3000", "xa_nm_3000", "xa_pp_3000", "xa_di_3000",
				"xa_di_1020", "xa_pc_3020", "xa_ex_1030", "xa_ex_1160", 
				"xa_di_1010", "xa_lm_3030", "xa_pi_3000", "xa_ex_1010",
				"xa_di_1030"}
				
local chern = {"xa_lm_3030", "xa_ex_3010", "xa_he_3000", "xa_pi_3000", 
				"xa_ex_1040", "xa_pp_3000", "xa_ex_1580", "xa_ex_1030",
				"xa_di_1010", "xa_di_1020", "xa_di_1030", "xa_ex_1010",
				"xa_ex_1160", "xa_pc_3000", "xa_he_3020", "xa_al_3010",
				"xa_ew_2040", "xa_ew_2050"}
		
local behe = {"xa_lm_3030", "xa_ew_2040", "xa_ex_2310"}
					
local lsb = {"xa_ex_2010", "xa_ex_2030", "xa_ex_2070", "xa_ex_2090", "xa_ex_2100"}

local riku1 = {"xa_ex_1010", "xa_di_1010", "xa_di_1020", "xa_di_1030",
				"xa_ex_1030", "xa_ex_1040", "xa_ex_1150", "xa_pi_3000",
				"xa_pp_3000", "xa_ew_2040", "xa_ew_2050", "xa_he_3000",
				"xa_tz_3000", "xa_ex_1580"}
				
local riku2 = {"xa_ex_1010", "xa_di_1010", "xa_di_1020", "xa_di_1030",
				"xa_ex_1030", "xa_ex_1040", "xa_ex_1150", "xa_pi_3000",
				"xa_pp_3000", "xa_ew_2040", "xa_ew_2050", "xa_he_3000",
				"xa_tz_3000", "xa_ex_1160", "xa_ex_3010", "xa_lm_3030",
				"xa_al_3010"}

local leon = {"xa_ex_1010", "xa_di_1010", "xa_di_1020", "xa_di_1030",
				"xa_ex_1160", "xa_ex_1040", "xa_pi_3000",
				"xa_pp_3000", "xa_ew_2040", "xa_ew_2050", "xa_he_3000",
				"xa_tz_3000", "xa_he_3020", "xa_lm_3030", "xa_ex_1580"}

local test = {"pc_6730.moa"}
				
local addrs = {}

local canExecute = false

function _OnInit()
	if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
		ConsolePrint("KH1 detected, running script")
		canExecute = true
		AddAddrs()
	else
		ConsolePrint("KH1 not detected, not running script")
	end
end

function RoomWarp(w, r)
	WriteByte(warpType1, 5)
	WriteByte(warpType2, 10)
	WriteByte(worldWarp, w)
	WriteByte(roomWarp, r)
	WriteByte(warpTrigger, 2)
end

function AddAddrs()
	for i=1,0x10 do
		addrs[i] = {}
	end
	--addrs[3][0xAC0980-offset] = normal[math.random(#normal)] --2nd district yellow
	--addrs[3][0xAC0940-offset] = normal[math.random(#normal)] --2nd district blue
	--addrs[3][0xAC0900-offset] = normal[math.random(#normal)] --2nd district red
	addrs[3][0xAC0800-offset] = normal[math.random(#normal)] --2nd district shadow
	addrs[3][0xB17240-offset] = leon[math.random(#leon)] --tt leon
	--addrs[3][0xAC0840-offset] = normal[math.random(#normal)] --2nd district soldier
	addrs[3][0xA97840-offset] = normal[math.random(#normal)] --alleyway shadow
	addrs[3][0xA97800-offset] = normal[math.random(#normal)] --alleyway soldier
	addrs[3][0xB16D80-offset] = normal[math.random(#normal)] --1st district shadow
	addrs[3][0xB0AC00-offset] = normal[math.random(#normal)] --3rd district shadow
	addrs[3][0xB0ABC0-offset] = normal[math.random(#normal)] --3rd district soldier
	addrs[3][0x9CAB80-offset] = normal[math.random(#normal)] --gizmo shadow
	--addrs[3][0xB0ACA0-offset] = test[math.random(#test)] --guard armor
	--addrs[5][0xA20480-offset] = boss[math.random(#boss)] --treehouse sabor
	addrs[5][0x9F4600-offset] = normal[math.random(#normal)] --camp powerwild
	addrs[5][0x9E3820-offset] = normal[math.random(#normal)] --climbing trees powerwild
	addrs[5][0xA20400-offset] = normal[math.random(#normal)] --treehouse powerwild
	addrs[5][0x992F00-offset] = normal[math.random(#normal)] --cliffs powerwild
	addrs[5][0xA8CF80-offset] = lite[math.random(#lite)] --bamboo powerwild
	--addrs[5][0xA8D0C0-offset] = boss[math.random(#boss)] --bamboo sabor
	--addrs[5][0x992F40-offset] = boss[math.random(#boss)] --cliff clayton
	--addrs[5][0x992F80-offset] = test[math.random(#test)] --cliff clayton & stealth sneak
	--addrs[4][0x851EC0-offset] = normal[math.random(#normal)] --rabbithole shadow
	--addrs[4][0x8E0E40-offset] = normal[math.random(#normal)] --lotus forest soldier
	addrs[4][0x9F8100-offset] = trick[math.random(#trick)] --trickmaster
	--addrs[11][0xAD05C0-offset] = normal[math.random(#normal)] --oc shadow
	addrs[11][0xAD0540-offset] = cloud[math.random(#cloud)] --oc cloud
	addrs[11][0xAD0800-offset] = boss[math.random(#boss)] --oc herc
	addrs[11][0x95CDC0-offset] = duo[math.random(#duo)] --oc leon
	addrs[11][0x95CE80-offset] = duo[math.random(#duo)] --oc yuffie
	--addrs[11][0xAD08A0-offset] = cerb[math.random(#cerb)] --oc cerb
	--addrs[11][0xAD0580-offset] = normal[math.random(#normal)] --oc soldier
	--addrs[11][0xAD0600-offset] = normal[math.random(#normal)] --oc large body
	--addrs[11][0xAD0640-offset] = normal[math.random(#normal)] --oc red
	--addrs[11][0xAD0680-offset] = normal[math.random(#normal)] --oc blue
	--addrs[11][0xAD06C0-offset] = normal[math.random(#normal)] --oc blue
	addrs[8][0x95C2C0-offset] = normal[math.random(#normal)] --alley bandit
	addrs[8][0x953940-offset] = normal[math.random(#normal)] --mainstreet bandit
	addrs[8][0xA826C0-offset] = normal[math.random(#normal)] --plaza bandit
	addrs[8][0x9E0180-offset] = normal[math.random(#normal)] --desert: cave bandit
	addrs[8][0x91ABC0-offset] = normal[math.random(#normal)] --bazaar bandit
	--addrs[8][0x9C4440-offset] = test[math.random(#test)] --pot cent 1
	--addrs[8][0x9C4480-offset] = test[math.random(#test)] --pot cent 2
	--addrs[8][0x9C43C0-offset] = test[math.random(#test)] --pot cent pot spider
	--addrs[8][0x9C44C0-offset] = test[math.random(#test)] --pot cent pot spider
	--addrs[8][0x9E0240-offset] = test[math.random(#test)] --tiger head
	addrs[8][0x9B32C0-offset] = normal[math.random(#normal)] --cave entrance bandit
	addrs[8][0x9ACC40-offset] = bandit[math.random(#bandit)] --cave hall air soldier
	addrs[8][0x972C40-offset] = normal[math.random(#normal)] --bottomless shadow
	addrs[8][0x97BBC0-offset] = jafar[math.random(#jafar)] --jafar
	addrs[8][0x97BC00-offset] = genie[math.random(#genie)] --genie
	--addrs[8][0x99C3C0-offset] = test[math.random(#test)] --genie jafar
	--addrs[12][0x9800C0-offset] = normal[math.random(#normal)] --chamber 1 ghost
	--addrs[12][0x9D2BC0-offset] = normal[math.random(#normal)] --chamber 2 airsoldier
	--addrs[12][0x9D78C0-offset] = normal[math.random(#normal)] --chamber 5 ghost
	addrs[12][0x9CF300-offset] = parasite[math.random(#parasite)] --pc1
	addrs[12][0x9CF440-offset] = pc1riku[math.random(#pc1riku)] --pc1 riku
	--addrs[12][0x9CB700-offset] = test[math.random(#test)] --pc2
	addrs[10][0xA62BC0-offset] = normal[math.random(#normal)] --square ghost
	addrs[10][0xA01FC0-offset] = normal[math.random(#normal)] --graveyard ghost
	addrs[10][0xA22500-offset] = normal[math.random(#normal)] --moonlight hill whight
	addrs[10][0x9A8440-offset] = normal[math.random(#normal)] --bridge whight
	addrs[10][0xB195C0-offset] = lite[math.random(#lite)] --manor whight
	--addrs[10][0x8A4E40-offset] = test[math.random(#test)] --lock
	--addrs[10][0x8A4E80-offset] = test[math.random(#test)] --shock
	--addrs[10][0x8A4EC0-offset] = test[math.random(#test)] --barrel
	--addrs[10][0x9A5280-offset] = test[math.random(#test)] --oogie
	--addrs[10][0x9A5200-offset] = test[math.random(#test)] --oogie gargoyles
	addrs[13][0x993B00-offset] = normal[math.random(#normal)] --ship hold anti sora
	addrs[13][0x959A40-offset] = normal[math.random(#normal)] --ship hold anti sora
	addrs[13][0x959C40-offset] = normal[math.random(#normal)] --ship hold anti sora
	addrs[13][0x9C0900-offset] = normal[math.random(#normal)] --ship galley anti sora
	addrs[13][0x9A4B20-offset] = antisora[math.random(#antisora)] --anti sora
	--addrs[13][0x9D1580-offset] = normal[math.random(#normal)] --ship pirate
	addrs[13][0x9D18E0-offset] = hook[math.random(#hook)] --hook
	addrs[15][0x9F33C0-offset] = riku1[math.random(#riku1)] --riku1
	addrs[15][0x9DE6A0-offset] = normal[math.random(#normal)] --tower wyvern
	addrs[15][0x950640-offset] = normal[math.random(#normal)] --gates wyvern
	addrs[15][0x94DD00-offset] = normal[math.random(#normal)] --base level darkball
	addrs[15][0xB5AAC0-offset] = normal[math.random(#normal)] --waterway defender
	--addrs[15][0x9B8AC0-offset] = normal[math.random(#normal)] --lift stop defender
	addrs[15][0xA2AAC0-offset] = mal[math.random(#mal)] --maleficent
	addrs[15][0xA07040-offset] = dragmal[math.random(#dragmal)] --dragon maleficent
	addrs[15][0xBB0BC0-offset] = riku2[math.random(#riku2)] --riku2
	addrs[15][0x9CA840-offset] = behe[math.random(#behe)] --HB behemoth
	addrs[16][0xA54540-offset] = normal[math.random(#normal)] --EotW Invisible
	addrs[16][0xA48740-offset] = normal[math.random(#normal)] --EotW Darkball
	addrs[16][0xAE5C80-offset] = normal[math.random(#normal)] --TT Terminal Solider
	addrs[16][0x7E10C0-offset] = normal[math.random(#normal)] --WL Terminal Wizard
	addrs[16][0x8C7100-offset] = normal[math.random(#normal)] --OC Terminal Air Solider
	addrs[16][0x8D1100-offset] = normal[math.random(#normal)] --DJ Terminal Powerwild
	addrs[16][0x914B40-offset] = normal[math.random(#normal)] --AG Terminal Bandit
	addrs[16][0x9FA700-offset] = normal[math.random(#normal)] --AT Terminal Neon
	addrs[16][0x8CF9C0-offset] = normal[math.random(#normal)] --HT Terminal Ghost
	addrs[16][0x922D80-offset] = normal[math.random(#normal)] --NL Terminal Pirate
	addrs[16][0x8357C0-offset] = normal[math.random(#normal)] --HB Terminal Invisible
	addrs[16][0x96CE40-offset] = chern[math.random(#chern)] --chernabog
end

function WriteString(addr, s)
	local existed = true
	for i=0,#s-1 do
		if ReadByte(addr+i) ~= string.byte(s, i+1) then
			existed = false
		end
		WriteByte(addr+i, string.byte(s, i+1))
	end
	return existed
end

function Exceptions(addr)
	local input = ReadInt(0x233D034-offset)
	if input == 8 then
		return true
	elseif ReadByte(cutsceneFlags+0xB05) >= 0x49 and addr == 0x992F00-offset then
		return true
	elseif addr == 0xA54540-offset and (ReadByte(room) == 5 or ReadByte(room) == 11) then
		return true
	end
	return not (ReadByte(addr) == 120 and ReadByte(addr+1) == 97)
end

function Fixes()
	local bossHP = 0x2D595CC - offset
	if ReadByte(0x2DE5E5F - offset) == 0xFF and ReadByte(0x2DE5E60 - offset) == 0xFF then
		bossHP = 0x2D593CC - offset
	end
	if ReadByte(world) == 0xD and ReadByte(room) == 8 then
		bossHP = 0x2D596CC - offset
	end

	local addr = 0xAD0800-offset
	
	adjustAddr = 0x2D34BF4 - offset
	-- if ReadFloat(adjustAddr) ~= -20 then
		-- adjustAddr = 0x2D35554 - offset
	-- end
	local charIDP = 0x2967CB0 - offset
	if ReadFloat(adjustAddr) == -20 and ReadInt(bossHP) > 1000 
	and ReadInt(OCseed) == 0x0909 and ReadInt(OCseed-8) == 0x210 then
		WriteFloat(adjustAddr, heightAdjust)
	end

	if ReadByte(world) == 3 and ReadByte(room) == 0 then
		if ReadShort(bossHP+4) ~= 120*hpScale then
			WriteShort(bossHP, 120*hpScale)
			WriteShort(bossHP+4, 120*hpScale)
			WriteShort(bossHP+0x10, 8) --str
			WriteShort(bossHP+0x14, 8) --def
		end
		if ReadByte(cutsceneFlags+0xB04) == 0x17 and ReadByte(ardOff) == 0x60 and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteByte(cutsceneFlags+0xB04, 0x1A)
			endfightTimer = 0
			ConsolePrint("Fight end")
			RoomWarp(3, 0x21)
		end
	end
	
	if ReadByte(world) == 4 and ReadByte(room) == 1 then
		if ReadShort(bossHP+4) ~= 600*hpScale then
			WriteShort(bossHP, 600*hpScale)
			WriteShort(bossHP+4, 600*hpScale)
			WriteShort(bossHP+0x10, 9) --str
			WriteShort(bossHP+0x14, 9) --def
		end
		if ReadByte(cutsceneFlags+0xB07) == 0x2B and ReadByte(ardOff) == 0xC3 and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteByte(ardOff, 0xC4)
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
	end
	
	if ReadByte(world) == 8 and ReadByte(room) == 0x10 then
		if ReadShort(bossHP+4) ~= 500*hpScale then
			WriteShort(bossHP, 500*hpScale)
			WriteShort(bossHP+4, 500*hpScale)
			WriteShort(bossHP+0x10, 0x11) --str
			WriteShort(bossHP+0x14, 0xF) --def
		end
		if ReadShort(bossHP+0x104) ~= 500*hpScale then
			WriteShort(bossHP+0x100, 500*hpScale)
			WriteShort(bossHP+0x104, 500*hpScale)
			WriteShort(bossHP+0x110, 0x11) --str
			WriteShort(bossHP+0x114, 0xF) --def
		end
		if ReadByte(cutsceneFlags+0xB08) == 0x46 and ReadByte(ardOff) < 0xC8 and
			(ReadInt(bossHP) == 0 or ReadInt(bossHP+0x100) == 0) 
								and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteByte(ardOff, 0xC8)
			endfightTimer = 0
			ConsolePrint("Cutscene started")
		elseif ReadByte(ardOff) == 0xF2 then
			WriteByte(ardOff, 0xF3)
			ConsolePrint("Give magic")
		end
	end
	
	if ReadByte(world) == 0xC and ReadByte(worldFlagBase+0x9E) == 2 then
		WriteByte(worldFlagBase+0x9E, 0)
	end
	
	if ReadByte(world) == 0xC and ReadByte(room) == 4 then
		if ReadShort(bossHP+4) ~= 450*hpScale then
			WriteShort(bossHP, 450*hpScale)
			WriteShort(bossHP+4, 450*hpScale)
			WriteShort(bossHP+0x10, 0x14) --str
			WriteShort(bossHP+0x14, 0x11) --def
		end
		if ReadByte(cutsceneFlags+0xB09) == 0x2B and ReadByte(ardOff) == 0x4A and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 100 then
			WriteByte(ardOff, 0x54)
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
	end
	
	if ReadByte(world) == 0xD and ReadByte(room) == 6 then
		if ReadShort(bossHP+4) ~= 750*hpScale then
			WriteShort(bossHP, 750*hpScale)
			WriteShort(bossHP+4, 750*hpScale)
			WriteShort(bossHP+0x10, 0x1B) --str
			WriteShort(bossHP+0x14, 0x15) --def
		end
		if ReadByte(cutsceneFlags+0xB0D) == 0x32 and ReadByte(ardOff) < 0xC2 and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteByte(cutsceneFlags+0xB0D, 0x28)
			WriteByte(ardOff, 0x42)
			antisorabeaten = true
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
		if antisorabeaten and ReadByte(ardOff) == 0x8C then
			WriteByte(ardOff, 0xC3)
			ConsolePrint("Cutscene start")
			antisorabeaten = false
		end
	end
	
	if ReadByte(world) == 0xD and ReadByte(room) == 8 then
		if ReadShort(bossHP+4) ~= 900*hpScale then
			WriteShort(bossHP, 900*hpScale)
			WriteShort(bossHP+4, 900*hpScale)
			WriteShort(bossHP+0x10, 0x1B) --str
			WriteShort(bossHP+0x14, 0x15) --def
		end
		if ReadByte(cutsceneFlags+0xB0D) == 0x50 and ReadShort(ardOff) == 0x36D and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteShort(ardOff, 0x389)
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
		if ReadShort(ardOff) == 0x3D3 then
			WriteByte(ardOff, 0x3D4)
			ConsolePrint("Give reward")
		end
	end
	
	if ReadByte(world) == 0xF and ReadByte(room) == 4 then
		if ReadShort(bossHP+4) ~= 500*hpScale then
			WriteShort(bossHP, 500*hpScale)
			WriteShort(bossHP+4, 500*hpScale)
			WriteShort(bossHP+0x10, 0x1F) --str
			WriteShort(bossHP+0x14, 0x18) --def
		end
		if ReadByte(cutsceneFlags+0xB0E) == 0x28 and ReadShort(ardOff) == 0x56 and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteShort(ardOff, 0x57)
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
	end
	
	if ReadByte(world) == 0xF and ReadByte(room) == 0xB then
		if ReadShort(bossHP+4) ~= 900*hpScale then
			WriteShort(bossHP, 900*hpScale)
			WriteShort(bossHP+4, 900*hpScale)
			WriteShort(bossHP+0x10, 0x1F) --str
			WriteShort(bossHP+0x14, 0x18) --def
		end
		if ReadByte(cutsceneFlags+0xB0E) == 0x50 and ReadShort(ardOff) == 0x54 and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteShort(ardOff, 0x55)
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
	end
	
	if ReadByte(world) == 0xF and ReadByte(room) == 0xE then
		bossHP = 0x2D593CC - offset
		if ReadShort(bossHP+4) ~= 900*hpScale then
			WriteShort(bossHP, 900*hpScale)
			WriteShort(bossHP+4, 900*hpScale)
			WriteShort(bossHP+0x10, 0x1F) --str
			WriteShort(bossHP+0x14, 0x18) --def
		end
		if ReadByte(cutsceneFlags+0xB0E) == 0x6E and ReadShort(ardOff) == 0x67 and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteShort(ardOff, 0x68)
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
	end
	
	local bossAddr = ReadLong(bossPointer)
	if bossAddr == 0 then
		bossAddr = ReadLong(malPointer)
	end
	
	if ReadByte(world) == 0xF and ReadByte(room) == 0xC then
		addr = 0xA07040-offset
		if ReadShort(bossHP+4) ~= 1200*hpScale then
			WriteShort(bossHP, 1200*hpScale)
			WriteShort(bossHP+4, 1200*hpScale)
			WriteShort(bossHP+0x10, 0x1F) --str
			WriteShort(bossHP+0x14, 0x18) --def
		end
		local dragonmal = 0x2D35540 - offset
		if ReadByte(addr) == 120 and ReadByte(addr+1) == 97
		and ReadByte(addr+4) == 99 and ReadByte(addr+6) == 51
		and ReadByte(addr+8) == 50 and ReadFloat(dragonmal+0x14) == 0 then
			WriteFloat(dragonmal+0x14, 1000)
			WriteInt(bittestRender, 0x00400000)
		end
		if ReadShort(dragonmal+0x4B0) == 32768 then
			ConsolePrint("Disabling collision")
			for i=1,45 do --disable collision
				WriteShort(dragonmal+0x4B0*i, 0)
			end
		end
		if ReadByte(cutsceneFlags+0xB0E) == 0x5A and ReadShort(ardOff) == 0x4F and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 200 then
			WriteShort(ardOff, 0x50)
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
	end
	
	if ReadByte(world) == 0xF and ReadByte(room) == 0xF then
		if ReadShort(bossHP+4) ~= 1350*hpScale then
			WriteShort(bossHP, 1350*hpScale)
			WriteShort(bossHP+4, 1350*hpScale)
			WriteShort(bossHP+0x10, 0x23) --str
			WriteShort(bossHP+0x14, 0x1B) --def
		end
		local behemoth = 0x2D34730 - offset
		if ReadShort(behemoth+0x4B0) == 32768 then
			ConsolePrint("Disabling collision")
			for i=1,24 do --disable collision
				WriteShort(behemoth+0x4B0*i, 0)
			end
		end
		if ReadByte(cutsceneFlags+0xB0E) == 0xAA and ReadShort(ardOff) == 0x4A and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteShort(ardOff, 0x4B)
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
	end
	
	if ReadByte(world) == 0x10 and ReadByte(room) == 0x1A then
		if ReadShort(bossHP+4) ~= 1500*hpScale then
			WriteShort(bossHP, 1500*hpScale)
			WriteShort(bossHP+4, 1500*hpScale)
			WriteShort(bossHP+0x10, 0x23) --str
			WriteShort(bossHP+0x14, 0x1B) --def
		end
		local chernabog = 0x2D34730 - offset
		local wall = 0x6D8374 - offset
		if ReadShort(chernabog+0x4B0) == 32768 then
			ConsolePrint("Disabling collision")
			for i=1,15 do --disable collision
				WriteShort(chernabog+0x4B0*i, 0)
			end
			local glideBarrier = 0x503948 - offset
			local floorStatus = 0x5258FC - offset
			WriteFloat(glideBarrier, 2000)
			for i=0,3 do
				WriteByte(floorStatus+i*12, 0)
			end
		end
		if ReadByte(wall) == 0x18 then
			WriteByte(wall, 0x19)
		end
		if ReadByte(chernabog+0x70) == 2 then
			fallcounter = fallcounter + 1
			if fallcounter > 120 then
				fallcounter = 0
				WriteByte(chernabog+0x70, 0)
			end
		end
		if ReadByte(cutsceneFlags+0xB0F) == 0x32 and ReadShort(ardOff) == 0x57 and
			ReadInt(bossHP) == 0 and ReadByte(state) & 1 == 1 then
			endfightTimer = endfightTimer + 1
		else
			endfightTimer = 0
		end
		if endfightTimer > 300 then
			WriteShort(ardOff, 0x58)
			endfightTimer = 0
			ConsolePrint("Fight end")
		end
	end

	-- if ReadByte(world) == 0xD and ReadByte(room) == 8 and ReadLong(soraPointer) then
		-- local soraYPos = ReadFloat(ReadLong(soraPointer)+0x14, true)
		-- if soraYPos == 0 then
			-- if ReadByte(state) == 0x31 then
				-- WriteByte(state, ReadByte(state) - 0x20)
			-- end
			-- local airGround = ReadLong(soraPointer)+0x70
			-- if ReadInt(ReadLong(soraPointer)+0xB0, true) > 0 then
				-- WriteByte(airGround, 2, true)
			-- end
		-- end
	-- end
	
	--herc scaling
	if ReadByte(world) == 0xB and ReadByte(room) == 2 
	and ReadByte(OCard) == 0x24 and ReadShort(OCseed) == 0x0909 then
		WriteShort(bossHP, 750*hpScale)
		WriteShort(bossHP+4, 750*hpScale)
		WriteShort(bossHP+0x10, 0x23) --str
		WriteShort(bossHP+0x14, 0x1B) --def
	end
	
	if addBreakout then
		if bossAddr and ReadByte(combo) > 4 and ReadShort(bossHP) < bossLastHP then
			WriteFloat(bossAddr+0x28C, 0, true)
			ConsolePrint("Breakout")
		end
	end

	bossLastHP = ReadShort(bossHP)
	if counter > 0 then
		counter = counter - 1
	end
end

function _OnFrame()
	local w = ReadByte(world)
	
	if canExecute and (ReadInt(blackfade) == 0 or ReadInt(whitefade) == 0x80) and w > 0 then
		local s = ""
		for addr, v in pairs(addrs[w]) do
			if not Exceptions(addr) then
				local existed = WriteString(addr, v)
				if addr == 0xB0ABC0-offset then
					existed = WriteString(addr+0xC0, v)
				else
					existed = WriteString(addr+0x20, v)
				end
				if not existed then
					s = s .. string.format("Replaced with %s at %x\n", v, addr+offset)
				end
			end
		end
		if s~="" then
			addBreakout = string.find(s, "xa_di_") ~= nil
			hpScale = string.find(s, "xa_pp_3010") ~= nil and 0.4 or 1
			hpScale = (addBreakout or string.find(s, "xa_ex_1010")) ~= nil and 0.6 or hpScale
			heightAdjust = string.find(s, "xa_ew_3020") ~= nil and 1200 or 0
			heightAdjust = string.find(s, "xa_pc_3020") ~= nil and 900 or heightAdjust
			local logfile = io.open("enemyrandolog.txt", "w+")
			logfile:write(s)
			ConsolePrint(s)
			logfile:close()
		end
		lastBlack = ReadInt(blackfade)
	end
	Fixes()
end