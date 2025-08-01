--Skaldia Chronicler
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Effect 1: Search or send to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.stgtg)
	e1:SetOperation(s.stgop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	
	--Effect 2: Negate & banish on being used as Synchro/Rune material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc2}

--Effect 1: Search or send Skaldia card
function s.stgfilter(c)
	return c:IsSetCard(0xfc2) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.stgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.stgfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.stgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g=Duel.SelectMatchingCard(tp,s.stgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	aux.ToHandOrElse(tc,tp)
end

--Effect 2: Negate + banish
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r & REASON_MATERIAL ~=0
		and (c:GetReasonCard():IsType(TYPE_SYNCHRO) or c:GetReasonCard():IsType(TYPE_RUNE))
		and c:GetReasonCard():IsSetCard(0xfc2)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if Duel.GetTurnPlayer()~=tp and tc:IsMonster() then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
			local fid=tc:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_PHASE+PHASE_END)
			e3:SetReset(RESET_PHASE+PHASE_END)
			e3:SetLabelObject(tc)
			e3:SetCountLimit(1)
			e3:SetCondition(s.retcon)
			e3:SetOperation(s.retop)
			Duel.RegisterEffect(e3,tp)
		end
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject() and e:GetLabelObject():GetFlagEffect(id)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
