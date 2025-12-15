--Phasmica Ember-Sealed Oath
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    --(1) Opponent must change an Extra-Deck Special Summoned monster to face-down Defense Position as a cost to activate its effect
    local eact=Effect.CreateEffect(c)
    eact:SetType(EFFECT_TYPE_FIELD)
    eact:SetCode(EFFECT_ACTIVATE_COST)
    eact:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    eact:SetRange(LOCATION_SZONE)
    eact:SetTargetRange(0,1)
    eact:SetCondition(s.actcon)
    eact:SetTarget(s.costtg)
    eact:SetCost(s.costchk)
    eact:SetOperation(s.costop)
    c:RegisterEffect(eact)

    --(2) If a face-up monster(s) is sent to the GY: target 1 card in either GY; Rune Summon 1 "Phasmica" Rune monster using that card as material and cards you control
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(s.rscon)
    e2:SetTarget(s.rstg)
    e2:SetOperation(s.rsop)
    c:RegisterEffect(e2)

    --(3) If this card is sent from the field to the GY: place 1 other Phasmica Continuous Spell from your GY to your S/T Zone
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
    e3:SetTarget(s.restore_tg)
    e3:SetOperation(s.restore_op)
    c:RegisterEffect(e3)
end

s.listed_series={0xfc1}

-- mark monsters summoned from Extra Deck
function s.markop(e,tp,eg,ep,ev,re,r,rp)
    for tc in aux.Next(eg) do
        if tc:IsSummonLocation(LOCATION_EXTRA) then
            tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        end
    end
end

-- activation limit condition: you control a Phasmica Rune monster
function s.actcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsType(TYPE_RUNE) and c:IsSetCard(0xfc1) end,tp,LOCATION_MZONE,0,1,nil)
end
-- cannot activate if effect's handler was summoned from Extra Deck and is not face-down defense
function s.costtg(e,te,tp)
    local rc=te:GetHandler()
    if not rc then return false end
    return te:IsActiveType(TYPE_MONSTER) and rc:IsLocation(LOCATION_MZONE) and rc:IsSpecialSummoned()
end
function s.costchk(e,te,tp)
    return te:GetHandler():IsCanTurnSet()
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c and c:IsRelateToEffect(e) then
        Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
    end
end

-- (2) Rune Summon trigger
function s.rscon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.rstgfilter(c,tp)
    return c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end

function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.rstgfilter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.rstgfilter,tp,0,LOCATION_GRAVE,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectTarget(tp,s.rstgfilter,tp,0,LOCATION_GRAVE,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,tp,0)
end
function s.rune_summon_filter(sc)
    return sc:IsSetCard(0xfc1) and sc:IsRuneSummonable()
end
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if not c or not c:IsRelateToEffect(e) then return end
    if not tc or not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
    Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    --Banish it if it leaves the field
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(3300)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
    e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
    e2:SetValue(LOCATION_REMOVED)
    tc:RegisterEffect(e2,true)
    --setcode
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetValue(0xfc1)
	tc:RegisterEffect(e3)

    -- Select Rune Summonable card
    local g=Duel.GetMatchingGroup(s.rune_summon_filter,tp,0x3ff~LOCATION_MZONE,0,nil)
    if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if sc then
        Duel.RuneSummon(tp,sc)
    end
end

-- (3) restore Phasmica Continuous Spell from GY
function s.restore_filter(c)
    return c:IsSetCard(0xfc1) and c:IsContinuousSpell() and not c:IsCode(id) and not c:IsForbidden()
end
function s.restore_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.restore_filter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.restore_filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    Duel.SelectTarget(tp,s.restore_filter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.restore_op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    if tc and tc:IsRelateToEffect(e) then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
