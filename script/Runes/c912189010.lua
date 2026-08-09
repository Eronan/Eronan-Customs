--Tresyllt the Heartholder
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_HEARTHOLDRITCH=0x1fbc
local SET_HEARTHOLD=0xfbc
function s.initial_effect(c)
	-- Rune Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOHAND|CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rtg)
	e1:SetOperation(s.rop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- Set Spell/Trap + Special Summon itself
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

	--Special Summon 1 "Fallen of Albaz" or 1 monster that mentions it from the GY
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCode(EVENT_MOVE)
	e4:SetCondition(s.spcon2)
	c:RegisterEffect(e4)
end
s.listed_series={SET_HEARTHOLD,SET_HEARTHOLDRITCH}

--Rune Summon a "Heartholdritch" monster from Deck.
function s.create_rune_location_effect(c,tp)
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_RUNE_LOCATION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HEARTHOLDRITCH))
    e1:SetTargetRange(LOCATION_DECK|LOCATION_GRAVE,0)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e1)
    return e1
end

function s.rfilter(c,mg,ec)
	return c:IsSetCard(SET_HEARTHOLDRITCH) and c:IsType(TYPE_RUNE) and c:IsRuneSummonable(ec,mg,2,2)
end

function s.mtfilter(c)
    return c:IsSpellTrap() and c:IsSetCard(SET_HEARTHOLD)
end

function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local mg=Duel.GetMatchingGroup(s.mtfilter,tp,LOCATION_DECK,0,nil,e,tp)
    mg:AddCard(c)
	local e1=s.create_rune_location_effect(c,tp)
	if chk==0 then
		local tgexists=Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_DECK,0,1,nil,mg,c)
		e1:Reset()
		return tgexists
	end
    local tc=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_DECK,0,1,1,nil,mg,c):GetFirst()
	e1:Reset()
    Duel.ConfirmCards(1-tp,tc)
    e:SetLabelObject(tc)
    tc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local rc=e:GetLabelObject()

	-- Restrict Extra Deck summons by Attribute and Type
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(te,ec)
		return ec:IsLocation(LOCATION_EXTRA) and ec:GetAttribute()~=rc:GetAttribute() and ec:GetRace()~=rc:GetRace()
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)

    -- Rune Summon immediately after this effect resolves
    local mg=Duel.GetMatchingGroup(s.mtfilter,tp,LOCATION_DECK,0,nil,e,tp)
    mg:AddCard(c)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RUNE_LOCATION)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e2)
	if rc and rc:IsRelateToEffect(e) and rc:IsRuneSummonable(c,mg,2,2) then
		Duel.RuneSummon(tp,rc,c,mg,2,2)
	end
end

-- Set a "Hearthold" Spell/Trap from GY and Special Summon itself from hand or GY
function s.spcfilter(c,tp)
    return c:IsType(TYPE_RUNE) and (c:IsPreviousPosition(POS_FACEUP) or c:IsFaceup())
        and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- A Rune monster you control must have left the field
	return rp==1-tp and eg:IsExists(s.spcfilter,1,nil,tp)
end

function s.spcfilter2(c,tp)
	return c:IsPreviousLocation(LOCATION_EXTRA) and c:IsPreviousControler(1-tp)
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter2,1,nil,tp)
end

function s.stfilter(c)
	return c:IsSetCard(SET_HEARTHOLD) and c:IsAbleToDeck()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false,POS_FACEUP_DEFENSE)
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,0,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- Special Summon
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false,POS_FACEUP_DEFENSE) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP_DEFENSE)

	-- Bottom Deck
	local g=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	Duel.BreakEffect()

	local tc=g:Select(tp,1,1,nil):GetFirst()
    if tc then
		Duel.SendtoDeck(tc,tp,0,REASON_EFFECT)
	end
end