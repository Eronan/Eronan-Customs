--Litos Divergent Boundary
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    --------------------------------------------------
    --(1) Rune Summon cannot be negated; Opponent cannot respond
    --------------------------------------------------
    -- Cannot disable summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetRange(LOCATION_FZONE)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSummonType,SUMMON_TYPE_RUNE))
    e1:SetTargetRange(1,0)
    c:RegisterEffect(e1)
    local e1b=Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1b:SetRange(LOCATION_FZONE)
    e1b:SetCondition(s.limcon)
    e1b:SetOperation(s.limop)
    c:RegisterEffect(e1b)
    local e1c=Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1c:SetRange(LOCATION_FZONE)
    e1c:SetCode(EVENT_CHAIN_END)
    e1c:SetOperation(s.limop2)
    c:RegisterEffect(e1c)

    --------------------------------------------------
    --(2) Rune Summon from Deck/GY
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_RUNE_LOCATION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfbf))
    e2:SetTargetRange(LOCATION_DECK|LOCATION_GRAVE,0)
    e2:SetCountLimit(1,{id,1})
    c:RegisterEffect(e2)

    --------------------------------------------------
    --(3) GY: When a "Litos" monster you control leaves the field,
    --       banish this card to Special Summon 1 Rune monster from GY
    -- Hard once per turn, triggered
    --------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.gycon)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

s.listed_series={0xfbf}

--------------------------------------------------
--(1b) Opponent cannot activate in response to Rune Summon
--------------------------------------------------
function s.limfilter(c,tp)
    return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_RUNE)
end
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.limfilter,1,nil,tp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetCurrentChain()==0 then
        Duel.SetChainLimitTillChainEnd(s.chainlm)
    elseif Duel.GetCurrentChain()==1 then
        e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_CHAINING)
        e1:SetOperation(s.resetop)
        Duel.RegisterEffect(e1,tp)
        local e2=e1:Clone()
        e2:SetCode(EVENT_BREAK_EFFECT)
        e2:SetReset(RESET_CHAIN)
        Duel.RegisterEffect(e2,tp)
    end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():ResetFlagEffect(id)
    e:Reset()
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():GetFlagEffect(id)~=0 then
        Duel.SetChainLimitTillChainEnd(s.chainlm)
    end
    e:GetHandler():ResetFlagEffect(id)
end
function s.chainlm(e,rp,tp)
    return tp==rp
end

--------------------------------------------------
--(3) GY: Trigger condition and Special Summon
--------------------------------------------------
-- Triggers when a Litos monster you control leaves the field
function s.gycfilter(c,tp)
        return c:IsSetCard(0xfbf) and c:GetPreviousControler()==tp
            and c:IsPreviousLocation(LOCATION_MZONE)
    end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.gycfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xfbf) and c:IsType(TYPE_RUNE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end