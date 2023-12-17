--Unensnared Cerberus
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	--Equip 1 face-up monster on field to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(s.stcon)
	e1:SetTarget(s.sttg)
	e1:SetOperation(s.stop)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle or card effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	--rune summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCost(s.cost)
	e4:SetTarget(s.runtg)
	e4:SetOperation(s.runop)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.stcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,e:GetHandler(),tp)
		and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 end
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,c,tp) or Duel.GetLocationCount(1-tp,LOCATION_SZONE)==0 then return end
	local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,c,tp):GetFirst()
	if not tc:IsImmuneToEffect(e) then
		if not Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true) then return end
		--Treated as a Continuous Trap
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		--special summon after leaving field
		c:SetCardTarget(tc)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,0)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e2:SetCode(EVENT_LEAVE_FIELD)
		e2:SetOperation(s.desop)
		e2:SetReset(RESET_EVENT+RESET_OVERLAY+RESET_TOFIELD)
		e2:SetLabelObject(e2)
		c:RegisterEffect(e2)
	end
end
function s.tgfilter(c)
	return c:IsLocation(LOCATION_SZONE) and c:GetFlagEffect(id)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget():Filter(s.tgfilter,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.indcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.runfilter(c,mg)
	--return c:IsSetCard(0xffa) and c:IsRuneSummonable(Group.FromCards(ec))
	return c:IsType(TYPE_RUNE) and c:IsRuneSummonable(nil,mg)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneGroup,tp,LOCATION_ONFIELD,0,nil,Duel.GetCurrentChain())
	local must=e:GetHandler():GetCardTarget():Filter(s.tgfilter,nil)
	mg:AddCard(must)
	if chk==0 then return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_HAND,0,1,nil,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneGroup,tp,LOCATION_ONFIELD,0,nil,Duel.GetCurrentChain())
	local must=c:GetCardTarget():Filter(s.tgfilter,nil)
	mg:AddCard(must)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.runfilter,tp,LOCATION_HAND,0,1,1,nil,mg)
	local sc=g:GetFirst()
	if sc then
		Duel.RuneSummon(tp,sc,nil,mg)
	end
end
