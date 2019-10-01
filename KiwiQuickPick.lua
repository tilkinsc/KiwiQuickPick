--[[
 * KiwiQuickPick
 * 
 * MIT License
 * 
 * Copyright (c) 2017-2019 Cody Tilkins
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
--]]


-- helper functions
local printi = function(type, ...)
	print((type == 0) and (KiwiQuickPick_Vars["text_print"] .. table.concat({...}, "  ") .. "|r")
		or (type == 1) and (KiwiQuickPick_Vars["text_warning"] .. table.concat({...}, "  ") .. "|r")
		or (type == 2) and (KiwiQuickPick_Vars["text_error"] .. table.concat({...}, "  ") .. "|r")
		or "")
end



-- Public table for macro usage
KiwiQuickPick = {}
KiwiQuickPick._VERSION = "1.0.0"

local DEFAULT_VARS = {
	["VERSION"] = "1.0.0",
	["text_error"] = "|cFFFF0000",
	["text_print"] = "|cFF0FFF0F",
	["text_warning"] = "|cFF00CC22",
	["vars"] = {
		["button"] = "LCTRL",
		["amount"] = 1
	}
}



-- Booleans if any bag slot is open
local TestBagOpen = function()
	
	for i=0, NUM_BAG_SLOTS do
		if(IsBagOpen(i)) then
			return true
		end
	end
	
	return false
end



-- Handles all key events
local OnKeyEvent = function(key, state)
	
	if(key == KiwiQuickPick_Vars.vars["button"] and state == 1) then
		
		if(TestBagOpen()) then
			
			local container = GetMouseFocus()
			if(container) then
				local object = container:GetObjectType()
				local name = container:GetName()
				if(object) then
					if(object == "Button" and name:find("ContainerFrame", 1) == 1) then
						
						container:SplitStack(KiwiQuickPick_Vars.vars["amount"])
						
					end
				end
			end
			
		end
		
		return
	end
	
end



-- Handles commands
local KiwiiiCommand = function(msg)
	
	-- split message into arguments
	local args = {string.split(" ", msg)}
	if(#args < 1) then
		printi(2, "Kiwi Quick Pick: Invalid argument length.")
		return
	end
	
	-- help message
	if(args[1] == "help" or msg == "") then
		printi(0, "Kiwi Quick Pick " .. KiwiQuickPick._VERSION .. " -- help")
		printi(0, "https://github.com/tilkinsc/KiwiQuickPick - for issue/bug reports")
		print("Usage: /kiwiqp [reload] [reset] [vars]")
		print("               [set variable_name value]")
		print("    > |cFF888888help|r -- for this message")
		print("    > |cFF888888reload|r -- reloads plugin")
		print("    > |cFF888888reset|r -- resets all saved variables, also reloads")
		print("    > |cFF888888vars|r -- shows all setting variables")
		print("    > |cFF888888set|r -- toggles a setting")
		print("        * |cFFBBBBBBvariable_name|r -- variable shown in /kiwiii vars")
		print("        * |cFFBBBBBBvalue|r -- either true, false, string, or number")
		return
	end
	
	-- reload plugin
	if(args[1] == "reload") then
		printi(2, "Reloading KiwiQuickPick...")
		KiwiQuickPick:Disable()
		KiwiQuickPick:Enable()
		printi(0, "All done! :D Kiwi is functioning!")
		return
	end
	
	-- hard reset of plugin
	if(args[1] == "reset") then
		printi(2, "Resetting KiwiQuickPick...")
		KiwiQuickPick:Disable()
		KiwiQuickPick_Vars = DEFAULT_VARS
		KiwiQuickPick:Enable()
		printi(0, "All done! :D Kiwi is functioning!")
		return
	end
	
	-- displays variables user can change
	if(args[1] == "vars") then
		printi(2, "Dumping user settings...")
		for i, v in next, KiwiQuickPick_Vars.vars do
			print("   >", i, "=", v)
		end
		printi(0, "All done!")
		return
	end
	
	-- sets variables the user can change
	if(args[1] == "set") then
		if(args[2]) then
			if(args[3]) then
				local var = KiwiQuickPick_Vars.vars[args[2]]
				if(var ~= nil) then
					
					local val
					if(tonumber(args[3])) then
						val = tonumber(args[3])
					elseif(args[3] == "true") then
						val = true
					elseif(args[3] == "false") then
						val = false
					else -- string
						val = table.concat(args, " ", 3, #args)
					end
					
					if(type(var) == "boolean") then
						if(type(val) == "boolean") then
							KiwiQuickPick_Vars.vars[args[2]] = val
						else
							printi(2, "Kiwi expects a boolean value (true/false). Sorry.")
							return
						end
					elseif(type(var) == "number") then
						if(type(val) == "number") then
							KiwiQuickPick_Vars.vars[args[2]] = val
						else
							printi(2, "Kiwi expects a number value. Sorry.")
							return
						end
					elseif(type(var) == "string") then
						if(type(val) == "string") then
							KiwiQuickPick_Vars.vars[args[2]] = val
						else
							printi(2, "Kiwi expects a string value (words). Sorry.")
							return
						end
					end
				else
					printi(2, "Kiwi doesn't have such a variable. Sorry.")
					return
				end
			else
				printi(2, "Kiwi needs a value to set to the variable...")
				return
			end
		else
			printi(2, "Kiwi needs a variable to set...")
			return
		end
		return
	end
	
end



-- Disables the plugin
KiwiQuickPick.Disable = function(self)
	
	SlashCmdList["KIWIQUICKPICK_CMD"] = nil
	SLASH_KIWIQUICKPICK_CMD1 = nil
	
	KiwiQuickPick.EventFrame:UnregisterEvent("MODIFIER_STATE_CHANGED")
	KiwiQuickPick.Events["MODIFIER_STATE_CHANGED"] = nil
	
end

-- Enables the plugin
KiwiQuickPick.Enable = function(self)
	
	if(not KiwiQuickPick_Vars) then
		
		KiwiQuickPick_Vars = DEFAULT_VARS
		
		printi(0, "Kiwi thanks you for installing KiwiQuickPick! <3")
	else
		if(KiwiQuickPick_Vars.VERSION ~= KiwiQuickPick._VERSION) then
			-- check if anything is new
			for i, v in next, DEFAULT_VARS do
				if(i ~= "vars" and not KiwiQuickPick_Vars[i]) then
					KiwiQuickPick_Vars[i] = v
				end
			end
			for i, v in next, DEFAULT_VARS.vars do
				if(not KiwiQuickPick_Vars.vars[i]) then
					KiwiQuickPick_Vars.vars[i] = v
				end
			end
			-- check if anything removed
			for i, v in next, KiwiQuickPick_Vars do
				if(i ~= "vars" and not DEFAULT_VARS[i]) then
					KiwiQuickPick_Vars[i] = nil
				end
			end
			for i, v in next, KiwiQuickPick_Vars.vars do
				if(not DEFAULT_VARS.vars[i]) then
					KiwiQuickPick_Vars.vars[i] = nil
				end
			end
			KiwiQuickPick_Vars.VERSION = KiwiQuickPick._VERSION
		end
	end
	
	-- commands
	SlashCmdList["KIWIQUICKPICK_CMD"] = KiwiiiCommand
	SLASH_KIWIQUICKPICK_CMD1 = "/kiwiqp"
	
	-- bag events
	KiwiQuickPick.Events["MODIFIER_STATE_CHANGED"] = OnKeyEvent
	KiwiQuickPick.EventFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
	
end



-- Default event dispatcher
local ADDON_LOADED = function(addon)
	if(addon ~= "KiwiQuickPick") then
		return
	end
	
	KiwiQuickPick:Enable()
end

-- hooks and events
KiwiQuickPick.Events = {
	["ADDON_LOADED"] = ADDON_LOADED
}


local KiwiQuickPick_Frame = CreateFrame("Frame")
KiwiQuickPick.EventFrame = KiwiQuickPick_Frame
KiwiQuickPick_Frame:RegisterEvent("ADDON_LOADED")
KiwiQuickPick_Frame:SetScript("OnEvent", function(self, event, ...)
	KiwiQuickPick.Events[event](...)
end)
