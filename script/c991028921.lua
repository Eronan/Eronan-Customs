--Sacrament in the Volcanic Temple
local s,id=GetID()
function s.initial_effect(c)
    Ritual.AddProcEqual(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
end
