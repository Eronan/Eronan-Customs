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
    --activate cost
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_ACTIVATE_COST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(0,1)
    e2:SetTarget(s.costtg)
    e2:SetCost(s.costchk)
    e2:SetOperation(s.costop)
    c:RegisterEffect(e2)
    --accumulate
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(id)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(0,1)
    c:RegisterEffect(e3)
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
--Activate cost
function s.costtg(e,te,tp)
    return te:IsHasCategory(CATEGORY_REMOVE)
end
function s.costchk(e,te,tp)
    local ct=#{Duel.GetPlayerEffect(tp,id)}
    return Duel.CheckLPCost(tp,ct*500)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
    Duel.PayLPCost(tp,500)
end