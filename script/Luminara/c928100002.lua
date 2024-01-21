--Luminaras Mirror Chanter
local s,id=GetID()
function s.initial_effect(c)
    --pendulum summon
    Pendulum.AddProcedure(c,false)
    Link.AddProcedure(c,nil,2,4,s.lcheck)
    c:EnableReviveLimit()
end
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_EFFECT,lc,sumtype,tp)
end
