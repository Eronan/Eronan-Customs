--Hydranic Lord - Daedalus Zenith
Duel.LoadScript("proc_rune.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),1,1,aux.FilterBoolFunctionEx(Card.IsCode,22702055),1,99)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetTarget(s.cdtg)
	e2:SetValue(22702055)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(s.desval)
	e3:SetValue(s.valcon)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetLabelObject(e3)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end
s.listed_names={22702055}
function s.cdtg(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c~=e:GetHandler()
end
function s.desval(e)
	return e:GetLabel()
end
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSummonType()==SUMMON_TYPE_RUNE then
		local ct=c:GetMaterialCount()-1
		e:GetLabelObject():SetLabel(ct)
	end
end
