--Phasmica Shade Zephyra
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon procedure: 1 monster that cannot be Normal Summoned/Set + 1 "Phasmica" Spell
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsSummonableCard)),1,1,Rune.STFunction(s.stfilter),1,1)

    --(1) During your opponent's turn, if they activated a card that started a Chain (Quick Effect): discard this card; place 1 "Phasmica" Continuous Spell from your Deck face-up in your S/T Zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_CHAIN_SOLVED)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.hcond)
    e1:SetTarget(s.htg)
    e1:SetOperation(s.hop)
    c:RegisterEffect(e1)

    --(2) If this card is Rune Summoned: add 1 "Phasmica" card from your Deck to your hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE) end)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    --(3) During the Main Phase (Quick): shuffle 1 "Phasmica" in your GY into the Deck; if you do, negate 1 face-up card's effects until the End Phase
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_OATH)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCondition(function() return Duel.IsMainPhase() end)
    e3:SetTarget(s.neg_tg)
    e3:SetOperation(s.neg_op)
    c:RegisterEffect(e3)
end

s.listed_series={0xfc1}

-- Rune material filters
function s.stfilter(c,rc,sumtype,tp)
    return c:IsSetCard(0xfc1) and c:IsType(TYPE_SPELL)
end

-- Effect (1) handlers
function s.hcond(e,tp,eg,ep,ev,re,r,rp)
    -- only when opponent's turn resolved as Chain Link 1
    return Duel.GetTurnPlayer()~=tp and rp~=tp and ev==1
end
function s.placefilter(c)
    return c:IsSetCard(0xfc1) and c:IsContinuousSpell() and not c:IsForbidden()
end
function s.htg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.hop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    if not c:IsDiscardable() then return end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.placefilter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

-- Effect (2) search
function s.thfilter(c)
    return c:IsSetCard(0xfc1) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Effect (3) negate
function s.gyfilter(c)
    return c:IsSetCard(0xfc1) and c:IsAbleToDeck()
end
function s.neg_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.neg_op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
    if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        local face=g:GetFirst()
        if face and face:IsFaceup() then
            Duel.NegateRelatedChain(face,RESET_TURN_SET)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            face:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            face:RegisterEffect(e2)
            if face:IsType(TYPE_TRAPMONSTER) then
                local e3=Effect.CreateEffect(e:GetHandler())
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                face:RegisterEffect(e3)
            end
        end
    end
end
