--Lithoforge Ruby Chimera
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsType,TYPE_EFFECT),1,1,Rune.STFunctionEx(Card.IsSetCard,0xfc8),2,2,nil,s.exgroup)
	c:EnableReviveLimit()
    --destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetCondition(s.repcon)
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
    --immune effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfc8))
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
    --place in spell & trap zone from banishment
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(function(e) return not e:GetHandler():IsStatus(STATUS_SUMMON_TURN|STATUS_FLIP_SUMMON_TURN|STATUS_SPSUMMON_TURN) end)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfc8}
--Rune Summon Group
function s.exrnfilter(c)
	return c:IsSetCard(0xfc8) and c:IsFacedown() and c:IsContinuousSpell()
end
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(s.exrnfilter,tp,LOCATION_SZONE,0,ex)
end
--Destroy replace
function s.repcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.repfilter(c,e)
	return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_ONFIELD,0,1,c,e) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_ONFIELD,0,1,1,c,e)
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
--immune effect
function s.efilter(e,te)
	if e:GetOwnerPlayer()==te:GetOwnerPlayer() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return #g==0
end
--place in spell & trap from gy
function s.tffilter(c,e,tp)
    return c:IsSetCard(0xfc8) and c:IsContinuousSpellTrap() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tffilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tffilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.SelectTarget(tp,s.tffilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end