--Mirrivound Binate Pact
local s,id=GetID()
function s.initial_effect(c)
	--(1) Prevent opponent's monster effects that banish
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.banicon)
	e1:SetValue(s.banival)
	c:RegisterEffect(e1)

	--(2) Ritual Summon if opponent activated monster effect in hand or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RITUAL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.ritcon)
	e2:SetTarget(s.rittg)
	e2:SetOperation(s.ritop)
	c:RegisterEffect(e2)

	--(3) Place this card face-up if sent from field/deck to GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.setcon)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_names={947292100}
s.listed_series={0xfff}
--(1) Lockout condition: You control Level 9+ Ritual Monster
function s.cfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsLevelAbove(9) and c:IsFaceup()
end

function s.banicon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

--(1) Effect lock filter
function s.banival(e,re,tp)
	return re:IsHasCategory(CATEGORY_REMOVE)
end

--(2) Ritual Summon trigger condition
function s.ritcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp
		and (re:GetActivateLocation()==LOCATION_HAND or re:GetActivateLocation()==LOCATION_GRAVE)
end

--(2) Ritual Summon target
function s.ritfilter(c,e,tp)
	return (c:IsCode(947292100) or c:IsSetCard(0xfff)) and c:IsRitualMonster()
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
function s.matfilter(c,rc)
	local lv=rc:GetLevel()
	return c:GetLevel()==lv or c:GetRank()==lv
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

--(2) Ritual Summon operation
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local rc=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if not rc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local mat=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_EXTRA,0,1,1,nil,rc):GetFirst()
	if mat then
		Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		rc:CompleteProcedure()
	end
end

--(3) Re-set itself if sent from field or deck
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) or c:IsPreviousLocation(LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
