--Dynachant Chanteuse
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_DYNACHANT=0xfe5
local TOKEN_DYNACHANT=986900019

function s.initial_effect(c)
	--Fusion materials: 1 Token + 1 monster
	Fusion.AddProcMix(c,true,true,TOKEN_DYNACHANT,aux.FilterBoolFunction(Card.IsMonster))
    c:EnableReviveLimit()

	--(1) On Special Summon: search + Rune Summon from GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	--(2) Tribute to summon Token (Quick Effect)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.tokencost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_DYNACHANT}
s.listed_names={TOKEN_DYNACHANT}

--------------------------------------------------
--(1) Search + Rune Summon from GY
--------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(SET_DYNACHANT) and c:IsAbleToHand()
		and (c:IsFaceup() or c:IsLocation(LOCATION_DECK|LOCATION_GRAVE))
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	--Search
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if tc:IsAbleToHand() then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
	end

    local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_RUNE_LOCATION)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_DYNACHANT))
    e2:SetTargetRange(LOCATION_GRAVE,0)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
end

--------------------------------------------------
--(2) Tribute → Token Summon
--------------------------------------------------
function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DYNACHANT,SET_DYNACHANT,TYPES_TOKEN,500,1850,3,RACE_FAIRY,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DYNACHANT,SET_DYNACHANT,TYPES_TOKEN,500,1850,3,RACE_FAIRY,ATTRIBUTE_FIRE) then return end

	local token=Duel.CreateToken(tp,TOKEN_DYNACHANT)
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetLabel(fid)
	e2:SetLabelObject(token)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	Duel.RegisterEffect(e2,tp)
	Duel.SpecialSummonComplete()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end