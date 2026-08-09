--Corvfew Grand Corvid
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()

local SET_CORVFEW=0xfbb
local SET_HEARTHOLD=0xfbc

function s.initial_effect(c)
	c:EnableReviveLimit()

	-- Fusion Materials:
	-- 1 "Corvfew" Fusion or Rune monster + 1 "Hearthold" monster + 1 Effect monster
    Fusion.AddProcMix(c,true,true,s.mat1,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HEARTHOLD),aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT))

	-- (1) Delay opponent's non-targeting activated effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.chcon)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)

	-- (2) Destroy 1 card you control and prevent battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	-- (3) Special Summon up to 2 "Corvfew" monsters during
	-- the End Phase if this card was sent from the field
	-- to the GY by an opponent's card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CORVFEW,SET_HEARTHOLD}

--------------------------------------------------
-- Fusion Materials
--------------------------------------------------

function s.mat1(c,fc,sumtype,tp)
	return c:IsSetCard(SET_CORVFEW,fc,sumtype,tp)
		and (c:IsType(TYPE_FUSION,fc,sumtype,tp) or c:IsType(TYPE_RUNE,fc,sumtype,tp))
end

--------------------------------------------------
-- (1) Delay opponent's non-targeting effect
--------------------------------------------------

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and re:GetOperation()
end

function s.chop(e,tp,eg,ep,ev,re,r,rp)
	-- Replace the original chain operation with a delayed one.
	Duel.ChangeChainOperation(ev,s.newdelayop(re))
end

function s.tgascon(tg)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)
	end
end

function s.newdelayop(oge)
	return function(e,tp,eg,ep,ev,re,r,rp)
		-- Register the original operation to resolve during the End Phase.
		local de=Effect.CreateEffect(e:GetHandler())
		de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		de:SetCode(EVENT_PHASE+PHASE_END)
		de:SetCountLimit(1)
		de:SetLabel(oge:GetLabel())
		de:SetLabelObject(oge:GetLabelObject())
		de:SetCondition(s.tgascon(oge:GetTarget()))
		de:SetOperation(oge:GetOperation())
		de:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(de,tp)
	end
end

--------------------------------------------------
-- (2) Destroy 1 card you control
--------------------------------------------------

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc then return end

	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
        -- You do not take battle damage for the rest of this turn.
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
	end
end

--------------------------------------------------
-- (3) Special Summon up to 2 "Corvfew" monsters
--------------------------------------------------

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFusionSummoned()
		and rp==1-tp and c:IsPreviousControler(tp)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Destroy all monsters your opponent controls
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1,{id,3})
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_CORVFEW) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false,POS_FACEUP)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	ct=math.min(ct,2)

	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	g=g:Select(tp,1,ct,nil)

	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
	end
end