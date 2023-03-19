--Charjing Crimson
local s,id=GetID()
function s.initial_effect(c)
	--Gemini status
    Gemini.AddProcedure(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Level 4 Xyz Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(aux.IsGeminiState)
	e2:SetTarget(s.xyztg)
	e2:SetValue(s.xyzlv)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsRace(RACE_THUNDER)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.xyztg(e,c)
	return c:IsType(TYPE_GEMINI)
end
function s.xyzlv(e,c,rc)
	return 0x40000+c:GetLevel()
end
