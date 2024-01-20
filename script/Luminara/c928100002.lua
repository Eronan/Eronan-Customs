--Luminaras Mirror Chanter
local s,id=GetID()
function s.initial_effect(c)
    --pendulum summon
    Pendulum.AddProcedure(c,false)
    Link.AddProcedure(c,nil,2,4,s.lcheck)
    c:EnableReviveLimit()
    --Treat as Link Spell
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_TYPE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetValue(TYPE_LINK)
    c:RegisterEffect(e1)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_EFFECT,lc,sumtype,tp)
end
