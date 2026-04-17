--Ekhoir Overture
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_EKHOIR=0xffd
local CARD_VIRTUOSO=971929101
function s.initial_effect(c)
    --Activate 1: Special Summon self + Rune Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCost(aux.RemainFieldCost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --Activate 2: Banish from GY to take control
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.ctcon)
    e2:SetCost(aux.bfgcost) -- banish self as cost
    e2:SetTarget(s.cttg)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
end

--Filter for Special Summon
function s.spfilter(c,e,tp)
    return c:IsCode(CARD_VIRTUOSO) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

--Effect 1 Target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

--Effect 1 Operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
        --Keep card on field
        c:CancelToGrave()
        --Destroy at End Phase
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetRange(LOCATION_SZONE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        e1:SetOperation(function(te,tp,eg,ep,ev,re,r,rp)
            if te:GetHandler():IsRelateToEffect(e) then
                Duel.Destroy(te:GetHandler(),REASON_EFFECT)
            end
        end)
        c:RegisterEffect(e1)
        --Link this Trap as Rune material
        c:SetCardTarget(tc)
        --Give a temporary effect to allow Rune Summon using this card + summoned monster
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_RUNE_LOCATION)
        e2:SetRange(LOCATION_SZONE)
        e2:SetTargetRange(LOCATION_DECK|LOCATION_REMOVED,0)
        e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_EKHOIR))
        e2:SetCondition(s.runloccon)
        e2:SetLabelObject(tc)
        e2:SetValue(s.runlocval)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    end
end
function s.runloccon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler():GetFirstCardTarget()
    return tc==e:GetLabelObject()
end
function s.runlocval(e,tp,sg,rc)
    local c=e:GetHandler()
    local tc=c:GetFirstCardTarget()
    return tc and sg:IsContains(tc) and sg:IsContains(c)
end
--Filter for controllable monsters.
function s.ctrlfilter(c)
    return c:IsFaceup() and c:IsControlerCanBeChanged()
end

--Effect 2 Condition: control an Ekhoir monster
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,SET_EKHOIR)
end

--Effect 2 Target
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

--Effect 2 Operation
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.GetControl(tc,tp,PHASE_END,1) then
            --Negate its effects until end phase
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2)
        end
    end
end