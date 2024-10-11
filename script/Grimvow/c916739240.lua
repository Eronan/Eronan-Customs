--Grimvow Artifact Dragon
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsType),TYPE_TOKEN),1,1,Rune.STFunctionEx(Card.IsEquipSpell),1,1,LOCATION_GRAVE)
    c:EnableReviveLimit()
    --Equip "Grimvow" Equip Spell to opponent's monster
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD) end)
	e1:SetCost(s.eqcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
    --Equip "Grimvow" to opponent's monster
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc6}
--equip
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.eqspfilter(c,ec)
	return c:IsSetCard(0xfc6) and c:IsEquipSpell()
        and c:CheckEquipTarget(ec)
end
function s.eqfilter(c,tp)
	return c:IsFaceup() and c:GetEquipCount()==0
        and Duel.IsExistingMatchingCard(s.eqspfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
    local ec=Duel.GetFirstTarget()
    if not ec or not ec:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local sc=Duel.SelectMatchingCard(tp,s.eqspfilter,tp,LOCATION_DECK,0,1,1,nil,ec):GetFirst()
    if not sc then return end
    Duel.HintSelection(ec,true)
    Duel.Equip(tp,sc,ec)
end
--Add Rune monster and Rune Summon
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp
end
function s.thfilter(c)
	return c:IsSetCard(0xfc6) and c:IsType(TYPE_RUNE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,g)
        local sc=g:GetFirst()
        if sc:IsRuneSummonable() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.RuneSummon(tp,sc)
        end
	end
end
