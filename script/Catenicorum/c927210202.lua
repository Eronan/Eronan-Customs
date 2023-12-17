--Catenicorum Manipulator
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(nil),1,1,Rune.STFunctionEx(Card.IsSetCard,0xfcf),1,1,LOCATION_DECK,nil,nil,s.runchk)
	--to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfcf}
--Catenicorum Portal effect
function s.runchk(e,tp,chk,mg)
	if chk==0 then return Duel.IsPlayerAffectedByEffect(tp,927210205) and Duel.GetFlagEffect(tp,927210205)==0 end
	Duel.RegisterFlagEffect(tp,927210205,RESET_PHASE+PHASE_END,0,1)
	return true
end
--to deck
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)>=2 and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return c~=chkc and chkc:IsLocation(LOCATION_GRAVE) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
    if not g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then return end
	Duel.ShuffleDeck(tp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
--negate
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	e:SetLabel(0)
	if c:IsPreviousLocation(LOCATION_ONFIELD) and rc:IsSetCard(0xfcf) then e:SetLabel(1) end
	return rc:IsSummonType(SUMMON_TYPE_RUNE)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
		--negate
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e2)
		end
		
		--remove
		if e:GetLabel()==1 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end