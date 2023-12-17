--Duplicity Executioner
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	e1:SetLabelObject(e1)
	--Force Activation
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.listed_series={0xfe8}
function s.egfilter(c,ec,tp)
	
	return c:IsType(TYPE_TRAP)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return eg:IsExists(Card.IsType,1,nil,TYPE_TRAP) and rc:IsControler(tp) and rc:IsSetCard(0xfe8)
		and e:GetHandler():IsSequence(ev)
end
function s.thfilter(c)
	return c:IsSetCard(0xfe8) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.filter(c)
	return c:IsType(TYPE_TRAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.filter(chkc) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,0,1,nil) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFaceup() then return end
	if tc:IsType(TYPE_TRAP) then
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
			if tc:GetType()==TYPE_TRAP then
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
			Duel.RaiseEvent(tc,EVENT_CUSTOM+id,e,REASON_EFFECT,tp,tep,seq)
		else
			if Duel.Destroy(tc,REASON_EFFECT)~=0 then
				Duel.SendtoGrave(tc,REASON_RULE)
			end
		end
	else
		Duel.ConfirmCards(tp,tc)
	end
end
