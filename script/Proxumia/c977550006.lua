--Ascendance Proxumia Spiral
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
    local e1=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_EQUAL,
        filter=aux.FilterBoolFunction(Card.IsSetCard,0xfc3),
        location=LOCATION_HAND|LOCATION_GRAVE,
        requirementfunc=s.ritual_material_requirement,
		specificmatfilter=s.ritual_specific_requirement
    })
	c:RegisterEffect(e1)

	--Use activation effect if added to hand (not by drawing)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e2:SetTarget(e1:GetTarget())
	e2:SetOperation(e1:GetOperation())
	c:RegisterEffect(e2)
end
s.listed_series={0xfc3}
--Ritual Summon
function s.ritual_material_requirement(c,rc)
    if c:IsLinkMonster() and c:GetMutualLinkedGroupCount()>0 then
        return Ritual.SummoningLevel
    end
    return aux.RitualCheckAdditionalLevel(c,rc)
end
function s.ritual_specific_requirement(c,rc,mg,tp)
	return s.ritual_material_requirement(c,rc)>0
end