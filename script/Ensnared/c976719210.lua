--Unensnared CelsiApus Overwing
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --rune summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(s.mfilter),1,1,Rune.STFunctionEx(Card.IsType,TYPE_CONTINUOUS),3,99)
    --cannot special summon
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.runlimit)
    c:RegisterEffect(e1)
    --Cannot be battle or effect target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.tglimit)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
    --place as continuous trap
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetTarget(s.sttg)
	e4:SetOperation(s.stop)
	c:RegisterEffect(e4)
    --Rune Summon from hand
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_HAND)
    e5:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e5:SetCondition(s.runcon)
    e5:SetTarget(s.runtg)
    e5:SetOperation(s.runop)
    c:RegisterEffect(e5)
end
s.listed_names={976719204}
--Rune Filter
function s.mfilter(c,rc,sumtyp,tp)
    return c:IsAttribute(ATTRIBUTE_EARTH,rc,sumtyp,tp) and c:IsType(TYPE_RUNE,rc,sumtyp,tp)
end
--target
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
function s.tglimit(e,c)
	return c~=e:GetHandler()
end
--place as continuous trap
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_SZONE,e:GetHandler():GetSequence())
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsControler(1-tp) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		--Remove non-S/T Zones
		local seq=bit.rshift(c:GetColumnZone(LOCATION_SZONE,0,0,tp),8)
		if not Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true,seq) then return end
		--Treated as a Continuous Trap
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		--give immune effect
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetRange(LOCATION_SZONE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e3:SetTarget(s.immtarget)
		e3:SetValue(s.immfilter)
		tc:RegisterEffect(e3)
	end
end
function s.immtarget(e,c)
	return e:GetHandler():GetColumnGroup():IsContains(c)
end
function s.immfilter(e,re)
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--Rune Summon
function s.runcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function s.runfilter(c,rc)
    return rc:IsRuneSummonable(c) and c:IsCode(976719204)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.runfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RMATERIAL)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
