--Queen of the Ashened City
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Rune Summon procedure
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsRace,RACE_PYRO),2,2,Rune.STFunctionEx(Card.IsSetCard,SET_ASHENED),1,1,nil,s.exgroup,nil,nil,nil,s.customop)
    --(1) Protection for DARK Pyro monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.protect_target)
    e1:SetValue(s.protect_val)
    c:RegisterEffect(e1)
    --(2) Rune Summon effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_RUNE_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(s.set_target)
    e2:SetOperation(s.set_operation)
    c:RegisterEffect(e2)
    --(3) Quick Rune Summon from hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetRange(LOCATION_HAND)
    e3:SetCondition(s.rs_condition)
    e3:SetTarget(s.rs_target)
    e3:SetOperation(s.rs_operation)
    c:RegisterEffect(e3)
end
s.listed_series={SET_ASHENED}
--(0) Rune Summon
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ex)
end
function s.customop(g,e,tp,eg,ep,ev,re,r,rp,pc)
    local gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local mg=g-gy
    Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_RUNE)
    Duel.Remove(gy,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
end
--(1) Protect DARK Pyro monsters
function s.protect_target(e,c)
    return c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.protect_val(e,re)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return #g==0
end

--(2) Set card face down
function s.set_target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanChangePosition() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local tg=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,tg,1,0,0)

    if Duel.GetCurrentChain() > 1 then
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
        Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
        e:SetLabel(1)
    else
        e:SetLabel(0)
    end
end
function s.set_operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    --Set target face-down
    if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)==0 then return end
    -- Now prompt for optional negation, if Chain Link 2 or higher
    if e:GetLabel()~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
        for nc in g:Iter() do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            nc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            nc:RegisterEffect(e2)
        end
    end
end


--(3) Rune Summon from hand if cards sent to GY
function s.rs_cfilter(c,tp)
    return c:IsControler(tp) and c:IsReason(REASON_EFFECT)
end
function s.rs_condition(e,tp,eg,ep,ev,re,r,rp)
    return re and eg:IsExists(s.rs_cfilter,1,nil,tp)
end
function s.rs_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsRuneSummonable() end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.rs_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        -- Successfully Rune Summoned
        Duel.RuneSummon(tp,c)
    end
end
