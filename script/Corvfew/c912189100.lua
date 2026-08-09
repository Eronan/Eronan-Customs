--Corvfew Pyrrhocorax
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()

local SET_CORVFEW=0xfbb
local CARD_TRESYLLT=912189010
local CARD_CORVFEW_MASTERMIND=912189011

function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,
		aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CORVFEW),
		aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WIND))

	-- (1) Special Summon 1 "Corvfew" monster and
	-- 1 "Tresyllt the Heartholder" during the End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.retg)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)

	-- (2) Rune Summon "Heartholdritch Corvfew Mastermind" during the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
	end)
	e2:SetTarget(s.rtg)
	e2:SetOperation(s.rop)
	c:RegisterEffect(e2)

	-- (3) Search a "Corvfew" monster
	  --to grave
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetOperation(s.regop2)
    c:RegisterEffect(e3)
end

s.listed_series={SET_CORVFEW}
s.listed_names={CARD_TRESYLLT,CARD_CORVFEW_MASTERMIND}

--------------------------------------------------
-- (1) Special Summon during the End Phase
--------------------------------------------------

function s.ssfilter(c,e,tp)
	return c:IsSetCard(SET_CORVFEW) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tresfilter(c,e,tp)
	return c:IsCode(CARD_TRESYLLT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Only activate the delayed effect if the monsters
	-- can actually be Special Summoned.

	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.sscon)
	e1:SetOperation(s.ssop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.sscon(e,tp)
	return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.tresfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- Need two available Monster Zones.
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end

	-- Available targets
	local g1=Duel.GetMatchingGroup(s.ssfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.tresfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g1==0 or #g2==0 then return end

	-- First Summon
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc1=g1:Select(tp,1,1,nil):GetFirst()
	if not tc1 then return end

	-- Second Summon
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc2=g2:Select(tp,1,1,nil):GetFirst()
	if not tc2 then return end

	-- Special Summon both monsters
	local g=Group.FromCards(tc1,tc2)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

--------------------------------------------------
-- (2) Rune Summon during the End Phase
--------------------------------------------------

function s.rfilter(c,mg)
	return c:IsCode(CARD_CORVFEW_MASTERMIND) and c:IsRuneSummonable(nil,mg)
end

function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
		return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	local tc=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,mg):GetFirst()
	if not tc then return end

	-- Face-down cards you control are deliberately included,
	-- since this effect allows them to be used as material.
	if not tc:IsRuneSummonable(nil,mg) then return end

	-- Rune Summon immediately after this effect resolves.
	Duel.RuneSummon(tp,tc,nil,mg)
end

--------------------------------------------------
-- (3) Add a "Corvfew" monster
--------------------------------------------------
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsPreviousLocation(LOCATION_ONFIELD) then
        local e1=Effect.CreateEffect(c)
        e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetRange(LOCATION_GRAVE)
        e1:SetCountLimit(1,{id,2})
        e1:SetTarget(s.thtg)
        e1:SetOperation(s.thop)
        e1:SetReset(RESETS_STANDARD_PHASE_END)
        c:RegisterEffect(e1)
    end
end
function s.filter(c)
    return c:IsSetCard(SET_CORVFEW) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
