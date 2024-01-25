if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_CLASSIC then return end
local ATM, C, L, _ = unpack(select(2, ...))
local s = ATM.spells


    --[[ Warlock Pets ]]--
--Voidwalker - Torment
s[3716]  = {onCast=true,threat=45}
s[7809]  = {onCast=true,threat=75}
s[7810]  = {onCast=true,threat=125}
s[7811]  = {onCast=true,threat=215}
s[11774] = {onCast=true,threat=300}
s[11775] = {onCast=true,threat=395}


--Voidwalker - Suffering
s[17735] = {onCast=true,threat=150}
s[17750] = {onCast=true,threat=300}
s[17751] = {onCast=true,threat=450}
s[17752] = {onCast=true,threat=600}


    --[[ Hunter Pets ]]--
--Growl
s[2649]  = {onCast=true,threat=50}
s[14916] = {onCast=true,threat=65}
s[14917] = {onCast=true,threat=110}
s[14918] = {onCast=true,threat=170}
s[14919] = {onCast=true,threat=240}
s[14920] = {onCast=true,threat=320}
s[14921] = {onCast=true,threat=415}
