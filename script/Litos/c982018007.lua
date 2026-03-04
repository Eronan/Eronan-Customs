--Litos Transform Boundary
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    --------------------------------------------------
    --(1) Litos monsters cannot be targeted or destroyed by effects
    --------------------------------------------------
    -- Cannot be targeted
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfbf))
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- Cannot be destroyed by effects
    local e1b=e1:Clone()
    e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1b:SetValue(s.indval)
    c:RegisterEffect(e1b)

    --------------------------------------------------
    --(2) Opponent cannot chain to their own effects
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCode(EVENT_CHAINING)
    e2:SetCondition(s.chcon)
    e2:SetOperation(s.chop)
    c:RegisterEffect(e2)

    --------------------------------------------------
    --(3) GY: When opponent activates a card or effect,
    --       banish this card to take control of 1 opponent monster until End Phase
    -- Hard once per turn, triggered
    --------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_CONTROL)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.gycon)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.cttg)
    e3:SetOperation(s.ctop)
    c:RegisterEffect(e3)
end

s.listed_series={0xfbf}

--------------------------------------------------
--(1) Protection filter
--------------------------------------------------
function s.indval(e,re,tp)
    return tp~=e:GetHandlerPlayer()
end

--------------------------------------------------
--(2) Opponent cannot chain to their own effects
--------------------------------------------------
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
    return ep==tp
end

--------------------------------------------------
--(3) GY take control
--------------------------------------------------
-- Triggers when opponent activates any card or effect,
-- requires controlling a Litos Rune monster
function s.litosrunefilter(c)
    return c:IsSetCard(0xfbf) and c:IsType(TYPE_RUNE)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsExistingMatchingCard(s.litosrunefilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.ctfilter(c)
    return c:IsControlerCanBeChanged()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
    local tc=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end