local ATM, C, L, _ = unpack(select(2, ...))

C.PREFIX = "ATM1"
C.DISPLAY = "vA1"

-- Version used for sync
C.VERSION = 1
-- The oldest sync version we support
C.MINVER = 1

C.debug = true
C.enabled = true

C.UIInterval = 0.1

-- NPC must be out of combat for x seconds before we wipe threat after we called enemy:setCombat(false)
C.npcCombatDropTime = 0.5
