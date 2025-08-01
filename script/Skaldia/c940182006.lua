-- Skaldia Monolith Sigil
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    -- (1) Activate: Search + Rune Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- (2) Additional Rune Summon from GY/banishment
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_RUNE_LOCATION)
    e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfc2))
    e2:SetTargetRange(LOCATION_GRAVE|LOCATION_REMOVED,0)
	e2:SetCountLimit(1)
    c:RegisterEffect(e2)

    -- (3) Set itself from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCost(s.setcost)
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
end
s.listed_series={0xfc2}

-- (1) Search target
function s.thfilter(c)
    return c:IsSetCard(0xfc2) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RUNE) and c:IsAbleToHand()
end
function s.rune_filter(c)
    return c:IsSetCard(0xfc2) and c:IsRuneSummonable()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    --Add to hand
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tc=g:Select(tp,1,1,nil)
    if not Duel.SendtoHand(tc,nil,REASON_EFFECT) then return end
    Duel.ConfirmCards(1-tp,tc)

    -- After resolving, optional Rune Summon from hand/GY/banishment
    local rg=Duel.GetMatchingGroup(s.rune_filter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
    if #rg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rc=rg:Select(tp,1,1,nil):GetFirst()
    Duel.RuneSummon(tp,rc)
end

-- (3) Set this card from GY
function s.setcostfilter(c)
    return c:IsSetCard(0xfc2) and c:IsAbleToRemoveAsCost() and c:IsMonster()
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.setcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SSet(tp,c)

    if Duel.GetTurnPlayer()~=tp then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
