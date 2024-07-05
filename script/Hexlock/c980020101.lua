--Hexlock Ruins Knight
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsType),TYPE_TOKEN),1,1,Rune.STFunctionEx(Card.IsContinuousSpellTrap),1,1)
    --special summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.runcon)
	e1:SetTarget(s.runtg)
	e1:SetOperation(s.runop)
	c:RegisterEffect(e1)
    --search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc7}
--Rune Summon from hand
function s.runcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and re:IsActiveType(TYPE_CONTINUOUS)
end
function s.matfilter(c)
    return c:IsFaceup() or c:IsLocation(LOCATION_HAND)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil)
        return e:GetHandler():IsRuneSummonable(nil,mg,nil,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil)
	if c:IsRelateToEffect(e) and c:IsRuneSummonable(nil,mg,nil,nil) then
		Duel.RuneSummon(tp,c,nil,mg,nil,nil)
	end
end
--Search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.filter(c)
    return c:IsSetCard(0xfc7) and c:IsContinuousTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
    if #sg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=sg:Select(tp,1,1,nil)
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
    --disable effect
    local tc=g:GetFirst()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,tc:GetCode()))
    e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
