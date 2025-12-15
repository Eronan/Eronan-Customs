--Bloom Phasmica Nymeria
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon: 1 "Phasmica" monster + 1 Continuous Spell
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsSetCard,0xfc1),1,1,Rune.STFunction(Card.IsContinuousSpell),1,1)

    --(1) During your opponent's Main Phase, if you control no monsters (Quick Effect): discard this card; place 1 "Phasmica" Continuous Spell from your Deck face-up in your S/T Zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.place_con)
    e1:SetTarget(s.place_tg)
    e1:SetOperation(s.place_op)
    c:RegisterEffect(e1)

    --(2) If this card is Rune Summoned: target 1 "Phasmica" monster in your GY; Special Summon it in face-down Defense Position
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE) end)
    e2:SetTarget(s.rsum_tg)
    e2:SetOperation(s.rsum_op)
    c:RegisterEffect(e2)

    --(3) During the Main Phase (Quick Effect): target 1 "Phasmica" card in your GY; shuffle that target into the Deck, and if you do, change 1 monster on the field to face-up or face-down Defense Position
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(function() return Duel.IsMainPhase() end)
    e3:SetTarget(s.gy_tg)
    e3:SetOperation(s.gy_op)
    c:RegisterEffect(e3)
end

s.listed_series={0xfc1}

--(1) place from Deck
function s.place_con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.place_filter(c)
    return c:IsSetCard(0xfc1) and c:IsContinuousSpell() and not c:IsForbidden()
end
function s.place_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.place_filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.place_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    if not c:IsDiscardable() then return end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.place_filter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

--(2) Rune Summon revive face-down
function s.rsum_filter(c,e,tp)
    return c:IsSetCard(0xfc1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.rsum_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rsum_filter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.rsum_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.rsum_filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.rsum_op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
end

--(3) shuffle from GY then change a monster's position
function s.gy_filter(c)
    return c:IsSetCard(0xfc1) and c:IsAbleToDeck()
end
function s.gy_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gy_filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.gy_filter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    Duel.SelectTarget(tp,s.gy_filter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.gy_op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
        local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
        if #g==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
        local postc=g:Select(tp,1,1,nil):GetFirst()
        if not postc then return end
        if postc:IsDefensePos() then
            Duel.ChangePosition(postc,POS_FACEDOWN_DEFENSE,nil,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE)
        else
            local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
            if op==0 then
                Duel.ChangePosition(postc,POS_FACEUP_DEFENSE)
            else
                Duel.ChangePosition(postc,POS_FACEDOWN_DEFENSE)
            end
        end
    end
end
