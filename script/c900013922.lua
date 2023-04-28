--Duplicity Assassin Feli
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune
	Rune.AddProcedure(c,s.monmtfilter,1,1,nil,1,99)
	c:EnableReviveLimit()
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Force Activation
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.listed_series={0xfe8}
function s.monmtfilter(c)
	return not c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.stmatfilter(c,scard,sumtype,tp)
	return c:GetOriginalType()==TYPE_SPELL or c:GetOriginalType()==TYPE_TRAP
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.setfilter(c)
	return c:IsSetCard(0xfe8) and c:IsSSetable(true)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0) 
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		local plyr=(tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		local opp=(tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0)
		if plyr and (not opp or Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0) then
			Duel.SSet(tp,tc)
		elseif opp then
			Duel.SSet(tp,tc,1-tp)
		end
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFaceup() then return end
	--
	local te=tc:GetActivateEffect()
	local tep=tc:GetControler()
	local condition
	local cost
	local target
	local operation
	if te then
		condition=te:GetCondition()
		cost=te:GetCost()
		target=te:GetTarget()
		operation=te:GetOperation()
	end
	
	--act in set turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	tc:RegisterEffect(e1)
	
	local chk=te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep)
		and (not condition or condition(te,tep,eg,ep,ev,re,r,rp))
		and (not cost or cost(te,tep,eg,ep,ev,re,r,rp,0))
		and (not target or target(te,tep,eg,ep,ev,re,r,rp,0))
	Duel.ChangePosition(tc,POS_FACEUP)
	Duel.ConfirmCards(tp,tc)
	if chk then
		Duel.ClearTargetCard()
		e:SetProperty(te:GetProperty())
		Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
		if not tc:IsType(TYPE_CONTINUOUS) and not tc:IsType(TYPE_FIELD) and not tc:IsType(TYPE_EQUIP) then
			tc:CancelToGrave(false)
		end
		tc:CreateEffectRelation(te)
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		if target~=te:GetTarget() then
			target=te:GetTarget()
		end
		if target then target(te,tep,eg,ep,ev,re,r,rp,1) end
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		for tg in aux.Next(g) do
			tg:CreateEffectRelation(te)
		end
		tc:SetStatus(STATUS_ACTIVATED,true)
		if tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
			tc:SetStatus(STATUS_LEAVE_CONFIRMED,false)
		end
		if operation~=te:GetOperation() then
			operation=te:GetOperation()
		end
		if operation then operation(te,tep,eg,ep,ev,re,r,rp) end
		tc:ReleaseEffectRelation(te)
		for tg in aux.Next(g) do
			tg:ReleaseEffectRelation(te)
		end
		
		local seq=tc:GetSequence()
		if tep~=tp and seq<=4 then seq=4-seq end
		Duel.RaiseEvent(tc,EVENT_CUSTOM+900013920,e,REASON_EFFECT,tp,tep,seq)
	else
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.SendtoGrave(tc,REASON_RULE)
		end
	end
	--
end
