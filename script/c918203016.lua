--Avilia, Aquatic Surface Subshifter
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsSummonLocation,LOCATION_EXTRA),1,99,s.mfilter)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--special summon limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.sumlimit)
	c:RegisterEffect(e2)
	--Equip 1 of opponent's monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetLabelObject(e3)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),s.equipop,e3)
	aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),s.equipop,e4)
	--atkup
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
	--rune summon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e6:SetCondition(s.runcon)
	e6:SetTarget(s.runtg)
	e6:SetOperation(s.runop)
	c:RegisterEffect(e6)
end
s.listed_series={0xfd4}
function s.mfilter(c,fc,sumtype,tp)
	return c:IsSetCard(0xfd4,fc,sumtype,tp) and c:IsType(TYPE_RUNE,fc,sumtype,tp)
		and c:IsLocation(LOCATION_ONFIELD)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.eqfilter(c,e,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and (not c:IsControler(tp))
		and c:IsCanBeEffectTarget(e) and (not c:IsSummonPlayer(tp))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.eqfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eg:IsExists(s.eqfilter,1,nil,e,tp) end
end
function s.equipop(c,e,tp,tc)
	c:EquipByEffectAndLimitRegister(e,tp,tc,id)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	tc:RegisterEffect(e2)
end
function s.repval(e,re,r,rp)
	return (r&REASON_BATTLE)~=0 or (r&REASON_EFFECT)~=0
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=eg:FilterSelect(tp,s.eqfilter,1,1,nil,e,tp)
	if #g>0 then
		local c=e:GetHandler()
		local ec=g:GetFirst()
		s.equipop(c,e,tp,ec)
	end
end
function s.atkfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*300
end
function s.runcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.runfilter(c,mg)
	return c:IsType(TYPE_RUNE) and c:IsAbleToHand()
		and c:IsRuneSummonable(nil,mg,nil,nil,LOCATION_HAND)
end
function s.runmfilter(c,tp,ec,chain)
	return c:IsCanBeRuneGroup(chain) and not (c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c~=ec)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=Duel.GetMatchingGroup(s.runmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp,e:GetHandler(),ev)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.runfilter(chkc,mg) end
	if chk==0 then return Duel.IsExistingTarget(s.runfilter,tp,LOCATION_GRAVE,0,1,nil,mg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.runfilter,tp,LOCATION_GRAVE,0,1,1,nil,mg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_HAND)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,tc)
		local mg=Duel.GetMatchingGroup(s.runmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp,e:GetHandler(),Duel.GetCurrentChain())
		if tc:IsRuneSummonable(nil,mg) then
			Duel.RuneSummon(tp,tc,nil,mg)
		end
	end
end
