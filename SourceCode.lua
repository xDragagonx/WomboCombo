-- counter keeps adding to targets when mounting || Solved, was using https://alloder.pro/md/LuaApi/FunctionCommonUnRegisterEventHandler.html instead of https://alloder.pro/md/LuaApi/FunctionCommonUnRegisterEvent.html, so it would always register still. Ask pasidaips how it works with the if name == gift of tensess.
-- Make it only work when out of combat
--Use common.LogInfo("common", "-"..name.."-") --Log to mods.txt
--Use tostring() to concatenate non-string values in ChatLog()
-- Solved:
--  Error while running the chunk
--   [string "Mods/Addons/RessCounter/Script.luac"]:0: attempt to perform arithmetic on a nil value
--   func: __sub, metamethod, line: -1, defined: C, line: -1, [C]
--     func: ?, ?, line: 0, defined: Lua, line: 0, [string "Mods/Addons/RessCounter/Script.luac"]

--VARIABLES
local durationMin = 0
local durationSec = 0
local remainingMin = 0
local remainingSec = 0
local registerOnce = false
local spellName = ""

function Main()
	common.RegisterEventHandler(BuffFinder, "EVENT_OBJECT_BUFF_ADDED") --https://alloder.pro/md/LuaApi/EventObjectBuffAdded.html
	--GetPassiveAbilities() --https://alloder.pro/md/LuaApi/FunctionAvatarGetAbilityInfo.html
	--GetPassiveAbilityReplacementSpell() --https://alloder.pro/md/LuaApi/FunctionAvatarGetAbilityReplacementSpell.html
	--GetSpellsAvatar()
	--GetSpellsTarget()
	--GetCooldown()

end

function GetPassiveAbilities() 
	local abilities = avatar.GetAbilities()
	for i, ability in ipairs(abilities) do
		local abilityInfo = avatar.GetAbilityInfo(ability)
		if abilityInfo then
			local name = abilityInfo.name
			ChatLog(name)
		end
	end
end
function GetPassiveAbilityReplacementSpell()
	ChatLog("inside func")
	local abilities = avatar.GetAbilities()
	for i, ability in ipairs(abilities) do
		local abilityInfo = avatar.GetAbilityInfo( ability )
		local replacementAbility = abilityInfo.hasReplacementSpell
		ChatLog(replacementAbility)
	end
end
function GetSpellsAvatar()
	local spellbook = avatar.GetSpellBook()
	for i, id in pairs( spellbook ) do
	  local spellInfo = spellLib.GetDescription( id )
	  --ChatLog( userMods.FromWString(spellInfo.name),"ID:", spellInfo.objectId )
	end
end
function GetSpellsTarget()
	local targetId = avatar.GetTarget()
	local targetSpellBook = targetId.GetSpellBook()
	for i, id in pairs( targetSpellBook ) do
		local spellInfo = spellLib.GetDescription( id )
		ChatLog( userMods.FromWString(spellInfo.name),"ID:", spellInfo.objectId )
	  end
end
-- function GetCooldown()
-- 	local spellbook = avatar.GetSpellBook()
-- 	for i, id in pairs( spellbook ) do
-- 		local spellId = spellLib.GetObjectSpell( id )
-- 		local spellInfo = spellLib.GetDescription( id )
-- 		local spellName = userMods.FromWString(spellInfo.name)
-- 		local spellObjectId = spellInfo.objectId
-- 		--ChatLog(spellName)
-- 		--common.LogInfo("common", "-"..spellName.."-")
-- 		if spellName == "Judgment Day" then			
-- 			local spellCooldown = spellLib.GetCooldown( spellObjectId )
-- 			ChatLog(userMods.FromWString(spellInfo.name),"spellObjectID:", spellObjectId,"spellId", spellId)
-- 			ChatLog(spellCooldown)
-- 		end
-- 	  end
-- end
function GetCooldown()
	local spellbook = avatar.GetSpellBook()
	for k, v in pairs(spellbook) do
		local spellDesc = spellLib.GetDescription( v )
		spellName = userMods.FromWString(spellDesc.name)
		if spellName == "Judgment Day" then
			local spellCooldown = spellLib.GetCooldown( v )
			durationMin = math.floor(spellCooldown.durationMs / 1000 / 60)
			durationSec = math.floor(spellCooldown.durationMs / 1000 % 60)
			remainingMin = math.floor(spellCooldown.remainingMs / 1000 / 60)
			remainingSec = math.floor(spellCooldown.remainingMs / 1000 % 60)
			if registerOnce == false then
				registerOnce = true
				common.RegisterEventHandler(UpdateCooldowns, "EVENT_SECOND_TIMER")			
			end
			UpdateCooldowns()
			
		end
	end
end
function UpdateCooldowns()
	ChatLog("base cooldown: "..durationMin.."m "..durationSec.."s")
	ChatLog("Remaining cooldown:",remainingMin.."m", remainingSec.."s")
	GetCooldown()
end
function BuffFinder(params)
	local objectId = params.objectId --ObjectId - идентификатор объекта на который повесили баф
	local buffName = userMods.FromWString(params.buffName) --WString - имя бафа
	local buffId = params.buffId -- ObjectId - идентификатор бафа
	local sysName = params.sysName -- String - системное название бафа
	local resourceId = params.resourceId -- buffId - идентификатор ресурса бафа
	local buffOwner = userMods.FromWString(object.GetName(params.objectId))
	if buffOwner == "Dragagon" then
		if buffName == "Judgment Day" then
			ChatLog(buffOwner.." used",buffName)
			GetCooldown()
		end
		
	end
	
end


if (avatar.IsExist()) then
	ChatLog("Loaded.")
	Main()
else
	ChatLog("Loaded.")
	common.RegisterEventHandler(Main, "EVENT_AVATAR_CREATED")
end