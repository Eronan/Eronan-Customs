--Grimvow Malicious Soul
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunction(nil),2,99,Rune.STFunctionEx(Card.IsEquipSpell),2,99,nil,s.exgroup)
    c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.runlimit)
	c:RegisterEffect(e1)
	--activate cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_DECK|LOCATION_EXTRA,LOCATION_DECK|LOCATION_EXTRA)
	e2:SetCost(s.costchk)
	e2:SetOperation(s.costop)
	c:RegisterEffect(e2)
	--accumulate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
	--Add to hand
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
    --special summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.rmcon)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_BE_MATERIAL)
    e6:SetCondition(s.rmcon2)
    c:RegisterEffect(e6)
    local e7=e6:Clone()
    e7:SetCode(EVENT_RELEASE)
    e7:SetCondition(s.rmcon3)
    c:RegisterEffect(e7)
end
s.listed_series={0xfc6}
--Rune Summon
function s.rune_custom_check(g,rc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end
function s.excfilter(c)
	return c:IsEquipSpell() or c:GetEquipCount()>0
end
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(s.excfilter,tp,0,LOCATION_ONFIELD,ex)
end
--Activate cost
function s.costchk(e,te,tp,sumtyp)
    local ct=#{Duel.GetPlayerEffect(tp,id)}
    return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_EXTRA|LOCATION_HAND,0,ct,nil)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_EXTRA|LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEDOWN,REASON_COST)
    end
end
--Add "Grimvow" to hand
function s.eqfilter(c,tp)
	return c:IsEquipSpell() and Duel.IsExistingMatchingCard(s.eqcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
function s.eqcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
function s.tgfilter(c,tp)
	return c:IsSetCard(0xfc6) and (c:IsAbleToHand() or s.eqfilter(c,tp))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	if s.eqfilter(g:GetFirst(),tp) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	aux.ToHandOrElse(tc,tp,
	function (etc)
		return s.eqfilter(etc,tp)
	end,
	function (etc)
		local ec=Duel.SelectMatchingCard(tp,s.eqcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,etc):GetFirst()
		Duel.Equip(tp,etc,ec)
	end,aux.Stringid(id,2))
end
--Special Summon from Extra Deck
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    --Left field by opponent's effect
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
    --If used as material for opponent's monster
    local rc=e:GetHandler():GetReasonCard()
	return rc and rc:IsControler(1-tp)
end
function s.rmcon3(e,tp,eg,ep,ev,re,r,rp)
    --Released by opponent's card
    local rc=e:GetHandler():GetReasonCard()
    return rc and rc:IsControler(1-tp)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_EXTRA,LOCATION_EXTRA,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end