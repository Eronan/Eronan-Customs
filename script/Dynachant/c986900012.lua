--Dyanchantress Sprite
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_DYNACHANT=0xfe5
local TOKEN_DYNACHANT=986900019

function s.initial_effect(c)
	--Rune Summon procedure: 1 Normal Monster + 1 Spell/Trap
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsType,TYPE_NORMAL),1,1,Rune.STFunction(nil),1,1)
	c:EnableReviveLimit()

	--(1) Quick Effect: revive Dynachant monster by tributing Token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--(2) Opponent reveals hand if you control a Normal Monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_PUBLIC)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.revealcon)
    e2:SetTargetRange(0,LOCATION_HAND)
    c:RegisterEffect(e2)
end

s.listed_series={SET_DYNACHANT}
s.listed_names={TOKEN_DYNACHANT}

--------------------------------------------------
--(1) Token Tribute Revival
--------------------------------------------------
function s.costfilter(c)
	return c:IsCode(TOKEN_DYNACHANT) and c:IsReleasable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DYNACHANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

--------------------------------------------------
--(2) Opponent hand reveal condition
--------------------------------------------------
function s.normfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function s.revealcon(e)
	return Duel.IsExistingMatchingCard(s.normfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end