--Duplicity Telekinetic Arrows
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_series={0xfe8}
function s.confilter(c)
	return c:IsSetCard(0xfe8) and c:IsType(TYPE_RUNE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler())
	local costgroup=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tg=costgroup:GetMaxGroup(Card.GetAttack)
	local b2=tg and tg:IsExists(Card.IsReleasable,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else 
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1 
	end
	if op==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.desop)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
		Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	else
		--Cost
		local tc=tg:GetFirst()
		if #tg>1 then
			tc=tg:Select(tp,1,1,nil)
		end
		Duel.Release(tc,REASON_COST)
		--Set Operation
		e:SetOperation(s.drop)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	end
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
		if tep~=tp then seq=5-seq end
		Duel.RaiseEvent(tc,EVENT_CUSTOM+900013920,e,REASON_EFFECT,tp,tep,seq)
	else
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.SendtoGrave(tc,REASON_RULE)
		end
	end
	--
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local d1=Duel.Draw(tp,1,REASON_EFFECT)
	local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
end
