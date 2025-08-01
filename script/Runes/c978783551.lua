--Celsitial Cassiopeia of the Ashened City
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Rune Summon Procedure
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsRace,RACE_PYRO),4,99,Rune.STFunctionEx(Card.IsRuneCode,CARD_OBSIDIM_ASHENED_CITY),1,1,nil,s.exgroup,nil,nil,nil,s.customop)
    --(1) Unaffected by non-targeting effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetValue(s.immune_val)
    c:RegisterEffect(e1)
    --(2) Apply disable & race change to Special Summoned monsters
    --2.1 Disable effects
    local e2a=Effect.CreateEffect(c)
    e2a:SetType(EFFECT_TYPE_FIELD)
    e2a:SetCode(EFFECT_DISABLE)
    e2a:SetRange(LOCATION_MZONE)
    e2a:SetTargetRange(0,LOCATION_MZONE)
    e2a:SetTarget(s.disable_target)
    c:RegisterEffect(e2a)

    --2.2 Change race to Pyro
    local e2b=Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD)
    e2b:SetCode(EFFECT_CHANGE_RACE)
    e2b:SetRange(LOCATION_MZONE)
    e2b:SetTargetRange(0,LOCATION_MZONE)
    e2b:SetTarget(s.disable_target)
    e2b:SetValue(RACE_PYRO)
    c:RegisterEffect(e2b)

    --(3) Revival on Opponent's turn
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.revive_condition)
    e3:SetTarget(s.revive_target)
    e3:SetOperation(s.revive_operation)
    c:RegisterEffect(e3)
end
s.listed_names={CARD_OBSIDIM_ASHENED_CITY,CARD_VEIDOS_ERUPTION_DRAGON,978783550} -- Replace with actual "Queen of the Ashened City" code
--GY usage group
function s.exgroup(tp,ex,c)
    return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ex)
end
function s.customop(g,e,tp,eg,ep,ev,re,r,rp,pc)
    local gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local mg=g-gy
    Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_RUNE)
    Duel.Remove(gy,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
end
--(1) Unaffected by non-targeting effects
function s.immune_val(e,re)
    if re:GetHandlerPlayer()==e:GetHandlerPlayer() then
        return re:GetHandler():IsCode(CARD_VEIDOS_ERUPTION_DRAGON)
    else
        if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
        local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
        return #g==0
    end
end
--(2) Disable and Convert opponent’s Special Summoned monsters
function s.disable_target(e,c)
    return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSpecialSummoned()
end
--(3) Revival of Queen if this card leaves during opponent’s turn
function s.revive_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
function s.revive_filter(c,e,tp)
    return c:IsCode(978783550) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.revive_target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.revive_filter(chkc,e,tp) end -- replace with Queen's actual code
    if chk==0 then return Duel.IsExistingTarget(s.revive_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.revive_filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.revive_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
    if c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED) then
        Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
    end
end
