--Corvfew Sundown Verdict
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_CORVFEW=0xfbb

function s.initial_effect(c)
	-- Activate as Chain Link 2 or higher
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end

s.listed_series={SET_CORVFEW}

--------------------------------------------------
-- Activation condition
--------------------------------------------------

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_CORVFEW)
		and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_RUNE))
end

--------------------------------------------------
-- Target
--------------------------------------------------

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)

	if chk==0 then return #g>0 end

	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,LOCATION_MZONE)
end

--------------------------------------------------
-- Operation
--------------------------------------------------

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end

	-- Banish all monsters on the field.
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)

	-- Mark every monster that is being banished by this effect.
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
	end

	-- Neither player can activate cards/effects
	-- in the banishment for the rest of this turn.
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.banactlimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- Neither player can take battle damage.
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)

	-- Return the monsters during the End Phase.
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.rtcon)
	e3:SetOperation(s.rtop)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
end

--------------------------------------------------
-- Banishment activation lock
--------------------------------------------------

function s.banactlimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_REMOVED
end

--------------------------------------------------
-- End Phase return
--------------------------------------------------

function s.rtfilter(c,e)
	return c:GetFlagEffect(id)>0 and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,0,false,false)
		and not c:IsReason(REASON_REDIRECT)
end

function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e)
end

function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local your_ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local opp_ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)

	local your_sg=Duel.GetMatchingGroup(s.rtfilter,tp,LOCATION_REMOVED,0,nil,e)
	local opp_sg=Duel.GetMatchingGroup(s.rtfilter,tp,0,LOCATION_REMOVED,nil,e)
	if (your_ft==0 or #your_sg==0) and (opp_ft==0 or #opp_sg==0) then return end

	if #your_sg>your_ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		your_sg=your_sg:Select(tp,your_ft,your_ft,nil)
	end
	if #opp_sg>opp_ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		opp_sg=opp_sg:Select(tp,opp_ft,opp_ft,nil)
	end

	local sg=opp_sg+your_sg
	for sc in sg:Iter() do
		local owner=sc:GetOwner()
		if sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,owner) then
			Duel.SpecialSummonStep(sc,0,tp,owner,false,false,POS_FACEUP)
		end
	end
	Duel.SpecialSummonComplete()
end