# ATM
Accurate Threat Meter - A locally calculated threat meter with API sync for real time updates for Classic WoW


### Methodology

* Track threat events per player
  * Global threat events (healing, buffing, power gains)
  * Direct threat events per target (damage, debuffs)
* Transmit threat modifiers (talents, gear, enchants, runes, spell ranks) on joining group or change or on request
* Sync against threat API (this event arrives out of order and is ignored if the player has generated threat that frame)





### EVENTS
* UNIT_TARGET
    * Everytime a unit changes their target
    * Check the combat status when a unit changes their target
    * Track player target for meter
* NAME_PLATE_UNIT_ADDED
    * Check combat status and target

* SWING_DAMAGE
    * Melee white damage by all players
* RANGE_DAMAGE
    * Ranged white damage by all players

* SPELL_CAST_SUCCESS
    * Tracking casts by players (sunder armor)
* SPELL_MISSED
    * Track spell misses (sunder armor)

* SPELL_HEAL
* SPELL_PERIODIC_HEAL
    * Apply global threat

* SPELL_AURA_APPLIED
    * Everytime a unit spawns or an aura is applied
    * Ignore if no corresponding spell cast
* SPELL_AURA_REFRESH
    * Everytime an aura is refreshed


# Special cases
## Sunder Armor
* no SPELL_AURA_APPLIED at 5 stacks
* track SPELL_CAST_SUCCESS and remove via SPELL_CAST_MISS

## Lava Annihilator
* Reduce threat on melee

## Ragnaros
* Ignore ranged threat


# Technical challenges:
* Tracking who is in combat with what
    * For applying global threat to targets
    * For tracking when threat actually counts (heals/buffs)
* Heals against friendlies in combat that put you in combat cause threat but +combat event is delayed
* You can sometimes drop combat for a moment (how long?) when a mob dies




# Things we need to track:
* Global threat
    * Buff applications
    * Healing
* Target threat
    * Debuff applications
    * Damage (melee and spells)

Handlers:
* Threat on DMG (Heroic Strike, Revenge, Cleave)
* Threat on debuff (Hamstring, FF, Revenge Stun)
* Threat on buff
* Cast can miss (sunder)





UNIT_TARGET
UnitGUID("targettargettarget")
on target change event check the ToT for taint tracking



# API

-- Add threat to a target, or all known alive and in-combat targets if target not specified
player:addThreat(amount, target=nil)

-- When a player dies or goes out of combat wipe their threat from all targets (feign death resists? UnitIsFeignDeath
player:wipeThreat()


# Usage goals
- Display threat of all groups members and their pets
- Display threat of all friendly players not in group (no threat api data if can't find unit for targetting)

- Display threat for target when not incombat with (no threat api data)
- Display threat of friendly NPCs (no threat api data if can't find unit for targetting)
    - Requires tracking mind control style updates and hostility changes (think razuv)


# TODO

* UI
    - always show tank in top 3
    - color border of frame for stoplight system
    - identify tanks based on tank stances

* API syncing
    - determine what events arrive pre vs post API values
    - pre event is safe to use API value
    - post event ignores API value

* combat
    - update combat scanning code and events that set +combat for enemies
    - set threat to 0 when entering combat with an enemy
* rewrite talent code to be more dynamic
    - transmit threatBuffs table
* track global threat added between api updates
    - store global threat split mod per player/enemy
    - you can have multiple different values per enemy
* garbage collection
    - track last seen of Players and NPCs for garbage collection
    - test garbage collection (weak vs strong tables)
* rewrite away from Players and NPCs to generic Units
    - track pet/npc threat (hunter pets, random NPCs, Razuvious)
    - supports switching between friendly and enemy (mind control)
* rewrite Tranq totem code
* track threat generation rate of targets for stoplight system
    - cpu usage style system TPS over last 30 seconds, 10 seconds, 2 seconds (average, cds, burst)
    - updating every CLEU w/ 1s throttling? recording median and max for each

documentation
* update README
* threat explanation page
* UI