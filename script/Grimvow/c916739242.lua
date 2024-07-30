--Grimvow Malicious Soul
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(),2,99,Rune.STFunction(),2,2)
    c:EnableReviveLimit()
   --activate cost
   local e1=Effect.CreateEffect(c)
   e1:SetType(EFFECT_TYPE_FIELD)
   e1:SetCode(EFFECT_SPSUMMON_COST)
   e1:SetRange(LOCATION_MZONE)
   e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
   e1:SetTargetRange(LOCATION_DECK|LOCATION_EXTRA,LOCATION_DECK|LOCATION_EXTRA)
   e1:SetCost(s.costchk)
   e1:SetOperation(s.costop)
   c:RegisterEffect(e1)
   --accumulate
   local e2=Effect.CreateEffect(c)
   e2:SetType(EFFECT_TYPE_FIELD)
   e2:SetCode(id)
   e2:SetRange(LOCATION_MZONE)
   e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
   e2:SetTargetRange(0,1)
   c:RegisterEffect(e2)
   --Add to hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
    --special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EVENT_BE_MATERIAL)
    e5:SetCondition(s.spcon2)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_RELEASE)
    e6:SetCondition(s.spcon3)
    c:RegisterEffect(e6)
end
s.listed_series={0xfc6}
--Activate cost
function s.costchk(e,te,tp,sumtyp)
    local ct=#{Duel.GetPlayerEffect(tp,id)}
    return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,0,LOCATION_EXTRA|LOCATION_HAND,ct,nil)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToRemoveAsCost,tp,0,LOCATION_EXTRA|LOCATION_HAND,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEDOWN,REASON_COST)
    end
end
--Add "Grimvow" to hand
function s.thcfilter(c,tp)
	return c:IsEquipSpell() and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.thcfilter,1,nil,tp)
end
function s.thfilter(c)
	return c:IsSetCard(0xfc6) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
--Special Summon from Extra Deck
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    --Left field by opponent's effect
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    --If used as material for opponent's monster
    local rc=e:GetHandler():GetReasonCard()
	return rc and rc:IsControler(tp)
end
function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
    --Released by opponent's card
    local rc=e:GetHandler():GetReasonCard()
    return rc and rc:IsControler(tp)
end
function s.spfilter(c,e,tp)
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end