if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))


------------------------------
------- SPELL HANDLERS -------
------- SELF is PLAYER -------
------------------------------
function ATM:Taunt(...)
	local _, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...

	if subevent == "SPELL_AURA_APPLIED" then
		local enemy = ATM:getEnemy(destGUID)
		if enemy and enemy.tankGUID and enemy.tankGUID ~= self.guid then
			local tank = ATM:getPlayer(enemy.tankGUID)
			if tank then
				self:setThreat(tank:getThreat(destGUID), destGUID)
			end
		end
	end
end

-- 3/26 01:05:06.962  SPELL_CAST_START,Player-4410-01C994F7,"Player-Server",0x512,0x0,0000000000000000,nil,0x80000000,0x80000000,10912,"Mind Control",0x20
-- 3/26 01:05:09.971  SPELL_CAST_SUCCESS,Player-4410-01C994F7,"Player-Server",0x512,0x0,Creature-0-4411-469-23151-14401-00007C376C,"Master Elemental Shaper Krixix",0x10a48,0x0,10912,"Mind Control",0x20,Player-4410-01C994F7,0000000000000000,100,100,0,0,0,-1,0,0,0,-7404.37,-946.61,0,5.0527,62
-- 3/26 01:05:09.971  SPELL_MISSED,Player-4410-01C994F7,"Player-Server",0x512,0x0,Creature-0-4411-469-23151-14401-00007C376C,"Master Elemental Shaper Krixix",0x10a48,0x0,10912,"Mind Control",0x20,RESIST,nil,0

-- 3/26 01:05:11.159  SPELL_CAST_START,Player-4410-01C994F7,"Player-Server",0x512,0x0,0000000000000000,nil,0x80000000,0x80000000,10912,"Mind Control",0x20
-- 3/26 01:05:14.170  SPELL_AURA_APPLIED,Player-4410-01C994F7,"Player-Server",0x512,0x0,Player-4410-01C994F7,"Player-Server",0x512,0x0,10912,"Mind Control",0x20,BUFF
-- 3/26 01:05:14.170  SPELL_CAST_SUCCESS,Player-4410-01C994F7,"Player-Server",0x512,0x0,Creature-0-4411-469-23151-14401-00007C376C,"Master Elemental Shaper Krixix",0x10a48,0x0,10912,"Mind Control",0x20,Player-4410-01C994F7,0000000000000000,100,100,0,0,0,-1,0,0,0,-7404.37,-946.61,0,5.0527,62
-- 3/26 01:05:14.346  SPELL_AURA_APPLIED,Player-4410-01C994F7,"Player-Server",0x512,0x0,Creature-0-4411-469-23151-14401-00007C376C,"Master Elemental Shaper Krixix",0x10a48,0x0,10912,"Mind Control",0x20,DEBUFF
-- 3/26 01:05:22.320  SPELL_AURA_REMOVED,Player-4410-01C994F7,"Player-Server",0x512,0x0,Player-4410-01C994F7,"Player-Server",0x512,0x0,10912,"Mind Control",0x20,BUFF
-- 3/26 01:05:22.445  SPELL_AURA_REMOVED,Player-4410-01C994F7,"Player-Server",0x512,0x0,Creature-0-4411-469-23151-14401-00007C376C,"Master Elemental Shaper Krixix",0x11112,0x0,10912,"Mind Control",0x20,DEBUFF

-- Update 11/6/23 : 69905 destFlags

function ATM:MindControl(...)
	local _, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
	ATM:print("ATM:MindControl", subevent, sourceGUID, destGUID, destFlags, COMBATLOG_OBJECT_TYPE_NPC)

	local enemy = ATM:getEnemy(destGUID)
	if not enemy then return end

	if not enemy.maxHP then
		local t = ATM:EnemyGUIDToTarget(destGUID, true)
		if not t then return ATM:print("[ATM] failed to identify target") end
	
		enemy.maxHP = UnitHealthMax(t)
		ATM:print("[ATM] Got max HP of enemy", enemy.maxHP)
	end

	if subevent == "SPELL_AURA_REMOVED" then
		-- Wipe threat table and set source threat
		ATM:print("[ATM] setting mind control threat", self.name, enemy.maxHP)
		ATM:wipeThreat(destGUID)
		if enemy.maxHP then
			self:setThreat(enemy.maxHP, destGUID)
		end
	end
end


--Dispels does target threat and a global threat component
function ATM:Dispel(...)
    local _, subevent, spellSchool, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _ = ...
    local spellID, spellName = select(12, ...)
    if subevent == "SPELL_CAST_SUCCESS" then
        local threat = ATM.spells[spellID].threat * self.threatBuffs[spellSchool]
        self:addThreat(threat)

        local enemy = ATM:getEnemy(destGUID)
        if enemy then
            self:addThreat(threat, destGUID)
        end
    end
end