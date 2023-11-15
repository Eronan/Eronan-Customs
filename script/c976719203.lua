--Unensnared Beast Under-Dragon
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--rune summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,1,Rune.STFunction(nil),2,99)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sttg)
	e1:SetOperation(s.stop)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
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
		e3:SetTarget(s.etarget)
		e3:SetValue(s.efilter)
		tc:RegisterEffect(e3)
	end
end
function s.etarget(e,c)
	return e:GetHandler():GetColumnGroup():IsContains(c)
end
function s.efilter(e,re)
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsContinuousTrap()
end
function s.atkcon(e)
	return e:GetHandler():GetColumnGroup():IsExists(s.cfilter,1,nil)
end
function s.atkfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*500
end
