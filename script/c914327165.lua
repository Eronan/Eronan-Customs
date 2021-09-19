--Petrified Squale Temple
function c914327165.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c914327165.ctcon)
	e2:SetOperation(c914327165.ctop)
	c:RegisterEffect(e2)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c914327165.thcost)
	e3:SetTarget(c914327165.thtg)
	e3:SetOperation(c914327165.thop)
	c:RegisterEffect(e3)
end
function c914327165.cfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT)
end
function c914327165.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c914327165.cfilter,1,nil)
end
function c914327165.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c914327165.cfilter,nil)
	e:GetHandler():AddCounter(0x10fe,ct)
end
function c914327165.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(e:GetHandler():GetControler(),1,1,0x10fe,3,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x10fe,3,REASON_COST)
end
function c914327165.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToHand()
end
function c914327165.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c914327165.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c914327165.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c914327165.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
