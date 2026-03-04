--Litos Convergent Boundary
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    --------------------------------------------------
    --(1) Add 1 "Litos" monster from Deck or GY to hand
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --------------------------------------------------
    --(2) Rune Summon from Deck or GY
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_RUNE_LOCATION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfbf))
    e2:SetTargetRange(LOCATION_DECK|LOCATION_GRAVE,0)
    e2:SetCountLimit(1,{id,1})
    c:RegisterEffect(e2)

    --------------------------------------------------
    --(3) GY Effect: When opponent Special Summons, banish self to flip 1 card face-down
    -- Hard once per turn, triggered
    --------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_POSITION)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.gycon)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.fdgtg)
    e3:SetOperation(s.fdgop)
    c:RegisterEffect(e3)
end

s.listed_series={0xfbf}

--------------------------------------------------
--(1) Search
--------------------------------------------------
function s.thfilter(c)
    return c:IsSetCard(0xfbf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--------------------------------------------------
--(3) GY flip
--------------------------------------------------
-- Only triggers on opponent's Special Summon
function s.litosrunefilter(c)
    return c:IsSetCard(0xfbf) and c:IsType(TYPE_RUNE)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.litosrunefilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.fdgfilter(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end
function s.fdgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.fdgfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.fdgfilter,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.SelectTarget(tp,s.fdgfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.fdgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
    end
end