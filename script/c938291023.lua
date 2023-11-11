--Dark Sorcerer
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsType),TYPE_EFFECT),1,1,Rune.STFunction(nil),1,1,LOCATION_PZONE)
	Pendulum.AddProcedure(c)
end
