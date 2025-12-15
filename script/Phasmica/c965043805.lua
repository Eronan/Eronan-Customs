--Phasmica Chained Spirit 
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- (1) Additional Rune Summon from GY/banishment
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_RUNE_LOCATION)
    e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfc1))
    e1:SetTargetRange(LOCATION_GRAVE|LOCATION_REMOVED,0)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)

    --(2) When opponent Special Summons: target 1 of those monsters; immediately after this effect resolves, Rune Summon 1 "Phasmica" using it as material
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e2:SetTarget(s.spstg)
    e2:SetOperation(s.spsop)
    c:RegisterEffect(e2)

    --(3) If this card is sent from the field to the GY: target 1 "Phasmica" Rune monster in your GY; Special Summon it.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
    e3:SetTarget(s.summon_tg)
    e3:SetOperation(s.summon_op)
    c:RegisterEffect(e3)
end

s.listed_series={0xfc1}

-- (2) opponent Special Summon condition
function s.tgfilter(c,e,tp)
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
    mg:AddCard(c)
    return c:IsControler(1-tp) and Duel.IsExistingMatchingCard(s.runfilter,tp,0x3ff~LOCATION_MZONE,0,1,nil,c,mg)
        and c:IsCanBeEffectTarget(e)
end
function s.runfilter(c,must,mg)
    return c:IsSetCard(0xfc1) and c:IsRuneSummonable(must,mg)
end
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e,tp) and eg:IsContains(chkc) end
    if chk==0 then return eg:IsExists(s.tgfilter,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=eg:FilterSelect(tp,s.tgfilter,1,1,nil,e,tp)
    Duel.SetTargetCard(g)
end

function s.spsop(e,tp,eg,ep,ev,re,r,rp)
    --Continuous Spell must be on field
    local c=e:GetHandler()
    if not c or not c:IsRelateToEffect(e) then return end
    --Target card must be related to effect.
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsLocation(LOCATION_MZONE) then return end
    -- attempt immediate Rune Summon using tc as a required material
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
    mg:AddCard(tc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.runfilter,tp,0x3ff~LOCATION_MZONE,0,1,1,nil,tc,mg):GetFirst()
    if not sc then return end
    Duel.RuneSummon(tp,sc,tc,mg)
end

-- (3) GY revive
function s.summon_filter(c,e,tp)
    return c:IsSetCard(0xfc1) and c:IsType(TYPE_RUNE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.summon_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.summon_filter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.summon_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.summon_filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.summon_op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
