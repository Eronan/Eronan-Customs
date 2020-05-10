--Calling Duplicity Breeze
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_series={0xfe8}
function s.thfilter(c)
	return c:IsSetCard(0xfe8) and c:IsAbleToHand()
end
function s.setfilter(c,e)
	return c:IsSetCard(0xfe8) and c:IsType(TYPE_TRAP) and c:IsSSetable(true) and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local tg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	local b2=tg:GetClassCount(Card.GetCode)>=2 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
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
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetOperation(s.thop)
	else
		--Cost
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
		--Target
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=aux.SelectUnselectGroup(tg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
		Duel.SetTargetCard(g)
		e:SetOperation(s.setop)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>=1 and Duel.GetLocationCount(tp,LOCATION_SZONE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
		local tg=g:Select(tp,1,1,nil)
		--Set to your side of the field
		Duel.SSet(tp,tg)
		
		if g:GetCount()>=2 and Duel.GetLocationCount(1-tp,LOCATION_SZONE) then
			g:Sub(tg)
			--Set to your opponent's side of the field
			Duel.SSet(tp,g,1-tp)
		end
	end
end
