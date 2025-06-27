--Hexlock Disaster
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunction(s.mtfilter),1,1,Rune.STFunctionEx(Card.IsTrap),1,1)
    c:EnableReviveLimit()
    --act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)
    --Lockdown face-down cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE) end)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
    --Search "Hexlock" card
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL|EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAIN_DISABLED)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e3:SetCost(s.thcost)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfc7}
--Rune Summon
function s.mtfilter(c,rc,sumtype,tp)
    return c:IsSummonType(SUMMON_TYPE_SPECIAL) and not c:IsType(TYPE_TOKEN,rc,sumtype,tp)
end
--act limit
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    local mg=g:Filter(Card.IsControler,nil,1-tp)
    for tc in aux.Next(mg) do
        Duel.SetChainLimit(s.chainlm(tc))
    end
end
function s.chainlm(tc)
    return function (e,rp,tp)
        return e==tc
    end
end
--Lockdown face-down cards
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFacedown() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
    Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,2,nil)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    for tc in aux.Next(g) do
        if tc:IsRelateToEffect(e) and tc:IsFacedown() then
            c:SetCardTarget(tc)
            --Cannot activate
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(aux.Stringid(id,1))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_TRIGGER)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetCondition(s.actcon)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
            tc:RegisterEffect(e2)
            local e3=e1:Clone()
            e3:SetCode(EFFECT_CANNOT_RELEASE)
            tc:RegisterEffect(e3)
            local e4=e1:Clone()
            e4:SetCode(EFFECT_CANNOT_RELEASE)
            tc:RegisterEffect(e4)
            local e5=e1:Clone()
            e5:SetCode(EFFECT_CANNOT_BE_MATERIAL)
            e5:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION))
            e5:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            tc:RegisterEffect(e5)
        end
    end
end
function s.actcon(e)
    local c=e:GetOwner()
    local h=e:GetHandler()
    return c:IsHasCardTarget(h)
end
--Search "Hexlock" card
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0xfc7) and re:IsActivated()
end
function s.thfilter(c)
	return c:IsSetCard(0xfc7) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)

    local tc=g:GetFirst()
    if tc:IsRuneSummonable() and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.RuneSummon(tp,tc)
    end
end