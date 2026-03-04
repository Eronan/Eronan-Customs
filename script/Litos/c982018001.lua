--Litos Twinmass Archon
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()

	--Fusion Materials
	Fusion.AddProcMix(c,true,true,
		aux.FilterBoolFunction(Card.IsSetCard,0xfbf),
		aux.FilterBoolFunction(Card.IsRace,RACE_ROCK)
	)

	--Alternative Special Summon (Tribute 1 Effect Monster while you control a "Litos" Field Spell)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.altcon)
	e0:SetOperation(s.altop)
	c:RegisterEffect(e0)

	--Search on Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	--Quick Rune Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(_,tp) return Duel.IsMainPhase() end)
	e2:SetTarget(s.rntg)
	e2:SetOperation(s.rnop)
	c:RegisterEffect(e2)

	--GY revive Rune
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spcon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={0xfbf}

--------------------------------------------------
-- Alternative Summon Condition
--------------------------------------------------

function s.fsfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xfbf) and c:IsType(TYPE_FIELD)
end

function s.altcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.fsfilter,tp,LOCATION_FZONE,0,1,nil)
		and Duel.CheckReleaseGroup(tp,Card.IsType,1,false,1,true,c,c:GetControler(),nil,false,nil,TYPE_EFFECT)
end

function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,false,true,true,c,nil,nil,false,nil,TYPE_EFFECT)
	c:SetMaterial(g)
	Duel.Release(g,REASON_COST)
end

--------------------------------------------------
-- Search
--------------------------------------------------

function s.thfilter(c)
	return c:IsSetCard(0xfbf) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------------------------
-- Quick Rune
--------------------------------------------------

function s.rnfilter(c,e)
	return c:IsSetCard(0xfbf) and c:IsType(TYPE_RUNE)
		and c:IsRuneSummonable(e:GetHandler())
end
function s.rntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rnfilter,tp,LOCATION_ALL-LOCATION_MZONE,0,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x3ff~LOCATION_MZONE)
end
function s.rnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.rnfilter,tp,0x3ff-LOCATION_MZONE,0,1,1,nil,e)
	local tc=g:GetFirst()
	if tc then
		Duel.RuneSummon(tp,tc,c)
	end
end

--------------------------------------------------
-- GY revive Rune
--------------------------------------------------

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

function s.spfilter(c,e,tp)
	return c:IsType(TYPE_RUNE)
		and c:IsSetCard(0xfbf)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end