--Hexlock Ruins Knight
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsType),TYPE_TOKEN),1,1,Rune.STFunctionEx(Card.IsContinuousSpellTrap),1,1)
    Rune.AddSecondProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsType),TYPE_TOKEN),1,1,Rune.STFunctionEx(Card.IsOriginalCode,980020107),1,1)
end