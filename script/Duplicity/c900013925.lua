--Saqa of Psyche - Duplicity Feli
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local CARD_FELI=900013922
local SET_DUPLICITY=0xfe8
function s.initial_effect(c)
	--Rune Summon procedure
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunction(Card.IsOnField),2,99)
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.runlimit)
	c:RegisterEffect(e0)
	
	--(1) Special Summon Duplicity Twister Desa from GY when this leaves field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--(2) Set a Duplicity Spell/Trap on opponent's field when Spell/Trap is activated
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_CHAINING)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetOperation(aux.chainreg)
	c:RegisterEffect(e2a)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(2)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	--(3) Quick Effect: Force Set Spell/Trap activation with negation if incorrect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.qetg)
	e3:SetOperation(s.qeop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_FELI}
s.listed_series={SET_DUPLICITY}
--========================
--Rune Materials
--========================
function s.monfilter(c,rc,sumtype,tp)
	return c:IsSetCard(SET_DUPLICITY,rc,sumtype,tp) and c:IsLevelAbove(5)
end
--========================
--(1) Special Summon "Duplicity Twister Desa" from GY
--========================
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_FELI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--========================
--(2) Set "Duplicity" Spell/Trap from GY on opponent's field
--========================
function s.setfilter(c)
	return c:IsSetCard(SET_DUPLICITY) and c:IsSSetable()
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(1)>0 and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellTrapEffect()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
    local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	Duel.SSet(1-tp,tc) -- set to opponent's field
end

--========================
--(3) Quick Effect: Force activation of Set Spell/Trap
--========================
function s.qefilter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFacedown() and s.qefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.qefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.qefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
function s.qeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFaceup() then return end
	--
	local te=tc:GetActivateEffect()
	local tep=tc:GetControler()
	local condition
	local cost
	local target
	local operation
	if te then
		condition=te:GetCondition()
		cost=te:GetCost()
		target=te:GetTarget()
		operation=te:GetOperation()
	end
	--act in set turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	
	local chk=tc:IsTrap()
        and te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep)
		and (not condition or condition(te,tep,eg,ep,ev,re,r,rp))
		and (not cost or cost(te,tep,eg,ep,ev,re,r,rp,0))
		and (not target or target(te,tep,eg,ep,ev,re,r,rp,0))
	Duel.ChangePosition(tc,POS_FACEUP)
	Duel.ConfirmCards(tp,tc)
	if chk then
		Duel.ClearTargetCard()
		e:SetProperty(te:GetProperty())
		Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
		if not tc:IsType(TYPE_CONTINUOUS) and not tc:IsType(TYPE_FIELD) and not tc:IsType(TYPE_EQUIP) then
			tc:CancelToGrave(false)
		end
		tc:CreateEffectRelation(te)
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		if target~=te:GetTarget() then
			target=te:GetTarget()
		end
		if target then target(te,tep,eg,ep,ev,re,r,rp,1) end
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		for tg in aux.Next(g) do
			tg:CreateEffectRelation(te)
		end
		tc:SetStatus(STATUS_ACTIVATED,true)
		if tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
			tc:SetStatus(STATUS_LEAVE_CONFIRMED,false)
		end
		if operation~=te:GetOperation() then
			operation=te:GetOperation()
		end
		if operation then operation(te,tep,eg,ep,ev,re,r,rp) end
		tc:ReleaseEffectRelation(te)
		for tg in aux.Next(g) do
			tg:ReleaseEffectRelation(te)
		end
		
		local seq=tc:GetSequence()
		if tep~=tp and seq<=4 then seq=4-seq end
		Duel.RaiseEvent(tc,EVENT_CUSTOM+900013920,e,REASON_EFFECT,tp,tep,seq)
		
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.SendtoGrave(tc,REASON_RULE)
		end

        e1:Reset()
	else
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.SendtoGrave(tc,REASON_RULE)
		end
	end
	--
end