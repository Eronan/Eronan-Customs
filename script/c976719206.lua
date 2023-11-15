--Ensnarement
local s,id=GetID()
function s.initial_effect(c)
	--Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
	--cannot release
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EFFECT_CANNOT_RELEASE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(0,1)
	e2:SetTarget(s.relval)
    c:RegisterEffect(e2)
	--equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sttg)
	e3:SetOperation(s.stop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfd9}
function s.sumlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer())
end
function s.relfilter(c)
	return c:IsFaceup() and c:IsContinuousTrap()
end
function s.relval(e,c)
	return c:IsFaceup() and c:IsSetCard(0xfd9)
		and c:GetColumnGroup():IsExists(s.relfilter,1,nil)
end
function s.stfilter(c,tp)
	local seq=c:GetSequence()
	if seq==5 then seq=1
	elseif seq==6 then seq=3 end
	return c:IsFaceup() and c:IsSetCard(0xfd9) and Duel.CheckLocation(tp,LOCATION_SZONE,seq)
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(s.stfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,s.stfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabelObject(g1:GetFirst())
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=e:GetLabelObject()
    local tpc=g:GetFirst()
	if tpc==tc then tpc=g:GetNext() end
	if tc:IsControler(1-tp) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		and tpc:IsControler(tp) and tpc:IsRelateToEffect(e) then
		--Remove non-S/T Zones
		local seq=bit.rshift(tpc:GetColumnZone(LOCATION_SZONE,0,0,tp),8)
		if not Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true,seq) then return end
		--Treated as a Continuous Trap
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		--special summon after leaving field
		tpc:SetCardTarget(tc)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_LEAVE_FIELD_P)
		e2:SetOperation(s.checkop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tpc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e3:SetCode(EVENT_LEAVE_FIELD)
		e3:SetOperation(s.spop)
		e3:SetReset(RESET_EVENT+RESET_OVERLAY+RESET_TOFIELD)
		e3:SetLabelObject(e2)
		tpc:RegisterEffect(e3)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_SZONE) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) then
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
