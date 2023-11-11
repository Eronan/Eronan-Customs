--Divinis, Crimson Runic Wings
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Rune.AddProcedure(c,Rune.MonFunction(nil),2,99,Rune.STFunction(nil),2,99,nil)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.runlimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e4:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK,SUMMON_TYPE_RUNE))
	c:RegisterEffect(e4)
	--activate
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.gycon)
	e5:SetTarget(s.gytg)
	e5:SetOperation(s.gyop)
	c:RegisterEffect(e5)
	--disable
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.discon)
	e6:SetOperation(s.disop)
	c:RegisterEffect(e6)
end
--rune summon functions
function s.rccheck(c,tp)
	return c:IsType(TYPE_RUNE) and c:IsControler(tp)
end
function s.rune_custom_check(g,rc,sumtype,tp)
	local rccheck=0
	if #g~=5 then return false end
	for mc in Group.Iter(g) do
		if not mc:IsOnField() then return false end
		if s.rccheck(mc,tp) then rccheck=rccheck+1 end
		--if rccheck>1 then return false end
	end
	return rccheck>1
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,LOCATION_EXTRA)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandlerPlayer()==1-e:GetHandlerPlayer() and
		(re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP)) and
		(re:GetActivateLocation()&LOCATION_ONFIELD==0 or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
