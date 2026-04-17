--Ekhoir Verdant Chorus
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_EKHOIR=0xffd

function s.initial_effect(c)
	--Rune Summon procedure
    c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsSetCard,SET_EKHOIR),1,1,Rune.STFunctionEx(Card.IsSetCard,SET_EKHOIR),1,1)

	--(1) Set Ekhoir S/T from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	--(2) Bounce 3 cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.bncost)
	e2:SetTarget(s.bntg)
	e2:SetOperation(s.bnop)
	c:RegisterEffect(e2)

end

s.listed_series={SET_EKHOIR}

-------------------------------------------------
-- Effect (1)
-------------------------------------------------

function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsControler(tp) and c:IsSetCard(SET_EKHOIR)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.setfilter(c)
	return c:IsSetCard(SET_EKHOIR) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
    local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.SSet(tp,tc) and tc:IsType(TYPE_TRAP) and Duel.GetTurnPlayer()~=tp then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-------------------------------------------------
-- Effect (2)
-------------------------------------------------
function s.bnfilter(c)
    return c:IsSpellTrap() and c:IsAbleToRemoveAsCost()
end
function s.bncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.bnfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.bnfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.ekfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_EKHOIR) and c:IsSpellTrap() and c:IsAbleToHand()
end

function s.anyfilter(c)
	return c:IsOnField() and c:IsCanBeEffectTarget() and c:IsAbleToHand()
end

function s.bntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.ekfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingTarget(s.anyfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.ekfilter,tp,LOCATION_ONFIELD,0,1,1,nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,s.anyfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,g1:GetFirst())

	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,3,0,0)
end

function s.bnop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end