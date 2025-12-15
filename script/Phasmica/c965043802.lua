--Ashbound Phasmica, Pyrelion
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon: 1 Level 5+ monster + 1 "Phasmica" Spell/Trap
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsLevelAbove,5),1,1,Rune.STFunctionEx(Card.IsSetCard,0xfc1),1,1)

    --(1) During your opponent's Main Phase, if opponent controls more monsters than you (Quick): discard this card; place 1 "Phasmica" Continuous Spell from Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.hcon)
    e1:SetCost(s.hcost)
    e1:SetTarget(s.htg)
    e1:SetOperation(s.hop)
    c:RegisterEffect(e1)

    --(2) If Rune Summoned: target 1 Rune monster in your GY; add it to your hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE) end)
    e2:SetTarget(s.th2tg)
    e2:SetOperation(s.th2op)
    c:RegisterEffect(e2)

    --(3) During the Main Phase (Quick): target 1 opponent card and 1 Phasmica in your GY; shuffle both into the Deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_OATH)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCondition(function() return Duel.IsMainPhase() end)
    e3:SetTarget(s.both_tg)
    e3:SetOperation(s.both_op)
    c:RegisterEffect(e3)
end

s.listed_series={0xfc1}

-- Effect place Continuous Spell on field
function s.hcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase() and Duel.GetTurnPlayer()==1-tp
        and Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function s.hcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.placefilter(c)
    return c:IsSetCard(0xfc1) and c:IsContinuousSpell() and not c:IsForbidden()
end
function s.htg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.hop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.placefilter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end

-- Effect add Rune monster from GY to hand
function s.rune_filter(c)
    return c:IsType(TYPE_RUNE) and c:IsAbleToHand()
end
function s.th2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rune_filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.rune_filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.rune_filter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.th2op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end

-- Effect shuffle two targets into the Deck
function s.gy_phasmica_filter(c)
    return c:IsSetCard(0xfc1) and c:IsAbleToDeck()
end
function s.both_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
        and Duel.IsExistingTarget(s.gy_phasmica_filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g1=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g2=Duel.SelectTarget(tp,s.gy_phasmica_filter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g1+g2,2,0,0)
end
function s.both_op(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if not tg or #tg<2 then return end
    Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
