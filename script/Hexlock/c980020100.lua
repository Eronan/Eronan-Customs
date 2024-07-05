--Hexlock Archivist
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Gemini.AddProcedure(c)
    --Search "Hexlock" card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --Rune Summon "Hexlock" Rune monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.runtg)
    e2:SetOperation(s.runop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc7}
--Search "Hexlock" card
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and eg:IsExists(Card.IsPreviousPosition,1,nil,LOCATION_MZONE)
end
function s.thfilter(c)
	return c:IsSetCard(0xfc7) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--Rune Summon "Hexlock" Rune monster
function s.runfilter(c)
	return c:IsType(TYPE_RUNE) and c:IsSetCard(0xfc7) and c:IsAbleToHand()
		and c:IsRuneSummonable(nil,mg,nil,nil,LOCATION_HAND)
end
function s.extrafilter(c)
    return (c:IsFaceup() and c:IsOnField()) or (c:IsSetCard(0xfc7) and c:IsContinuousTrap() and c:IsLocation(LOCATION_DECK))
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        local mg=Duel.GetMatchingGroup(s.extrafilter,tp,LOCATION_ONFIELD|LOCATION_DECK,0,nil)
        return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_DECK,0,1,nil,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetMatchingGroup(s.extrafilter,tp,LOCATION_ONFIELD|LOCATION_DECK,0,nil)
    local g=Duel.GetMatchingGroup(s.runfilter,tp,LOCATION_DECK,0,nil,mg)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local rc=g:Select(tp,1,1,nil):GetFirst()
        Duel.RuneSummon(tp,rc)
    end
end
