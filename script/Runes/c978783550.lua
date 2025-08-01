--Queen of the Ashened City
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Rune Summon procedure
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsRace,RACE_PYRO),2,99,Rune.STFunctionEx(Card.IsSetCard,SET_ASHENED),1,99,nil,s.exgroup,nil,nil,nil,s.customop)
    --(1) Protection for DARK Pyro monsters
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PYRO))
    e1:SetValue(s.protect_val)
    c:RegisterEffect(e1)
    --(2) Negate effects unless discard
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.negcon)
    e2:SetOperation(s.handes)
    c:RegisterEffect(e2)
    --(3) Quick Rune Summon from hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_HAND)
    e3:SetCondition(s.rs_condition)
    e3:SetTarget(s.rs_target)
    e3:SetOperation(s.rs_operation)
    c:RegisterEffect(e3)
end
s.listed_series={SET_ASHENED}
s.listed_names={CARD_VEIDOS_ERUPTION_DRAGON}
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
function s.protect_val(e,re)
    if re:GetHandlerPlayer()==e:GetHandlerPlayer() then
        return re:GetHandler():IsCode(CARD_VEIDOS_ERUPTION_DRAGON)
    else
        if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
        local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
        return #g==0
    end
end

--(2) Set card face down
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.handes(e,tp,eg,ep,ev,re,r,rp)
    local chain_id=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
    if not (ep==1-tp and chain_id~=s[0] and re:IsMonsterEffect()) then return end
    s[0]=chain_id
    if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
        Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
        Duel.BreakEffect()
    else Duel.NegateEffect(ev) end
end

--(3) Rune Summon from hand if cards sent to GY
function s.rs_cfilter(c,tp)
    return c:IsControler(tp) and c:IsReason(REASON_EFFECT)
end
function s.rs_condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.rs_cfilter,1,nil,tp)
end
function s.rs_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsRuneSummonable() end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.rs_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        -- Successfully Rune Summoned
        Duel.RuneSummon(tp,c)
    end
end
