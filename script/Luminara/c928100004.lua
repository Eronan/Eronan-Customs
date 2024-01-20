--CrysLupus CelsiLuminara
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsSetCard,0xfca),1,1,Rune.STFunction(nil),2,2)
    c:EnableReviveLimit()
    --cannot special summon
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.runlimit)
    c:RegisterEffect(e1)
    --check materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
    --Special Summon non-Effect monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
    --Gain 1000 ATK
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.atkfilter)
    e4:SetValue(1000)
    c:RegisterEffect(e4)
    --Cannot be Tributed or affected by opponent's card effects
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_UNRELEASABLE_SUM)
    e5:SetCondition(s.econ)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e6)
    --immune
	local e7=e5:Clone()
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetValue(s.efilter)
	c:RegisterEffect(e7)
end
s.listed_series={0xfca}
s.listed_names={928100003}
--Special Summon non-Effect monsters
function s.matcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(Card.IsCode,1,nil,928100003) then
		e:SetLabel(1)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	end
end
function s.spcon(e,c)
	return e:GetLabelObject():GetLabel()==1 and e:GetHandler():GetSummonType()==SUMMON_TYPE_RUNE
end
function s.spfilter(c,e,sp)
	if not c:IsCanBeSpecialSummoned(e,0,sp,false,false) or c:IsType(TYPE_EFFECT) then return false end
	return (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.exfilter(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsFaceup() and c:IsType(TYPE_PENDULUM))
end
function s.rescon(ft1,ft2,ft)
	return function(sg,e,tp,mg)
			local expct=sg:FilterCount(s.exfilter,nil,LOCATION_EXTRA)
			local mct=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
			local res=ft2>=expct and ft1>=mct
			return res,not res
		end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	local ft=Duel.GetUsableMZoneCount(tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		ft=1
	end
	local ect=aux.CheckSummonGate(tp)
	if ect then
		ft1=math.min(ect,ft1)
		ft2=math.min(ect,ft2)
	end
	local loc=0
	if ft1>0 then loc=loc+LOCATION_GRAVE end
	if ft2>0 then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,loc,0,nil,e,tp)
	if #sg==0 then return end
	local rg=aux.SelectUnselectGroup(sg,e,tp,1,ft,s.rescon(ft1,ft2,ft),1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)
end
--Gain ATK
function s.atkfilter(e,c)
    return not c:IsType(TYPE_EFFECT)
end
--Cannot be tributed & immune
function s.econ(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsOriginalType,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,TYPE_NORMAL)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end