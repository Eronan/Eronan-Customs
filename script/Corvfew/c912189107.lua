--Corvfew Hour
local s,id=GetID()
local SET_CORVFEW=0xfbb

function s.initial_effect(c)
	-- Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Can be activated during the turn it was Set
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCondition(s.actcon)
    c:RegisterEffect(e2)
end

s.listed_series={SET_CORVFEW}

--------------------------------------------------
-- (1) Fusion Summon using Deck materials
--------------------------------------------------

function s.deckfilter(c)
	return c:IsSetCard(SET_CORVFEW) and c:IsType(TYPE_FUSION)
end

function s.deckmatfilter(c)
	return c:IsMonster() and c:IsAbleToGrave()
end

function s.deckextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.deckmatfilter,tp,LOCATION_DECK,0,nil)
end

local params1={aux.FilterBoolFunction(Card.IsSetCard,SET_CORVFEW),aux.FALSE,s.deckextra}

--------------------------------------------------
-- (2) Fusion Summon using hand/field materials
--------------------------------------------------

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)-- and tg1(e,tp,eg,ep,ev,re,r,rp,0)

    local tg2=Fusion.SummonEffTG()
	local b2=not Duel.HasFlagEffect(tp,id+1) and Duel.GetCurrentPhase()==PHASE_END and tg2(e,tp,eg,ep,ev,re,r,rp,0)

	if chk==0 then return b1 or b2 end

	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(op)

	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
		-- tg1(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		tg2(e,tp,eg,ep,ev,re,r,rp,1)
	end
end

--------------------------------------------------
-- Operation
--------------------------------------------------
function s.fustgascon(params)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return Fusion.SummonEffTG(table.unpack(params))(e,tp,eg,ep,ev,re,r,rp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(s.fustgascon(params1))
		e1:SetOperation(Fusion.SummonEffOP(table.unpack(params1)))
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		Fusion.SummonEffOP()(e,tp,eg,ep,ev,re,r,rp)
	end
end


--------------------------------------------------
-- (2) Activate on the turn it was Sets
--------------------------------------------------
function s.actcon(e,tp,eg,ep,ev,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END
end