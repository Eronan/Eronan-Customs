--Elysiance Engine
local s,id=GetID()
function s.initial_effect(c)
    --Apply one of these effects OR both of them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0xfc5}
function s.cfilter(c,rit)
	return c:IsFaceup() and c:IsRitualMonster() and c:IsType(TYPE_PENDULUM)
end
function s.thfilter(c)
	return c:IsMonster() and (c:IsSetCard(0xfc5) or (c:IsRitualMonster() and c:IsType(TYPE_PENDULUM))) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0xfc5) and c:IsType(TYPE_PENDULUM)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	e:SetLabel(Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,true) and 1 or 0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,nil,e,tp)
	local bp=e:GetLabel()==1
	local op=nil
	if not bp then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
	end
	local breakeffect=false
	if (op and op==1) or (bp and b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,3)))) then
		--Add 1 Elysiance monster or Ritual Pendulum from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
			b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,nil,e,tp)
		end
		breakeffect=true
	end
	if (op and op==2) or (bp and b2 and (not breakeffect or Duel.SelectYesNo(tp,aux.Stringid(id,4)))) then
		--Special Summon 1 Elysiance monster from your hand or face-up Extra Deck
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			if breakeffect then Duel.BreakEffect() end
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end