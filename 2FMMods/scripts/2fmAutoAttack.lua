local offset = 0x56450E
local Sys3Cmd = 0x00
local CmdPointer = 0x02AE2CB0 - offset

local canExecute = false
function _OnInit()
	if GAME_ID == 0x431219CC and ENGINE_TYPE == "BACKEND" then
		canExecute = true
		ConsolePrint("KH2 detected, running script")
		if ReadInt(ReadLong(CmdPointer+0x1B6, true)) > 0 and ReadInt(0x2A59056-offset) == 0 then
			offset = 0x56550E
			ConsolePrint("Detected JP version. If this is incorrect, try reloading at a different time")
		else
			ConsolePrint("Detected GLOBAL version. If this is incorrect, try reloading at a different time")
		end
	else
		ConsolePrint("KH2 not detected, not running script")
	end
end

function _OnFrame()
	if canExecute then
		if Sys3Cmd == 0 then
			Sys3Cmd = ReadLong(CmdPointer)
		end
		local attackButton = ReadByte(0x7804C1-offset-0x40)
		local input = ReadByte(0x71148B-offset-0x40) == attackButton
		local command = ReadByte(0x2A0DD7C-offset) == 0
		local dialog = ReadByte(0x2A139D0-offset) == 0
		local inCombat = ReadByte(0x2A0EAC4-offset) & 3 > 0

		if (input and command and dialog and inCombat) then 
			WriteByte(Sys3Cmd+0x1B6, 0x1, true)
		else
			WriteByte(Sys3Cmd+0x1B6, 0, true)
		end
	end
end
