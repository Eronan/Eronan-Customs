--Hearthold Corvfew Pieces
local s,id=GetID()

local SET_HEARTHOLDRITCH=0x1fbc
local SET_HEARTHOLD=0xfbc
local SET_CORVFEW=0xfbb
local CARD_TRESYLLT=912189010

function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)

	-- Activate this card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- (1) Fusion Summon during the End Phase
	local params={aux.FilterBoolFunction(Card.IsSetCard,SET_CORVFEW),nil,s.fextra,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg,nil,nil,nil}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)

	-- (2) Opponent cannot activate cards/effects in response
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)

	-- (3) Opponent cannot target cards in the GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end

s.listed_series={
	SET_HEARTHOLDRITCH,
	SET_HEARTHOLD,
	SET_CORVFEW
}

s.listed_names={CARD_TRESYLLT}
s.listed_series={SET_CORVFEW}

--------------------------------------------------
-- (1) Fusion Summon
--------------------------------------------------
function s.extrafilter(c)
    return c:IsAbleToGrave() and c:IsSetCard(SET_CORVFEW)
end

function s.fextra(e,tp,mg)
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,CARD_TRESYLLT) then
        return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.extrafilter),tp,LOCATION_DECK,0,nil)
    end
    return nil
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end

--------------------------------------------------
-- (2) Cannot activate cards/effects in response
--------------------------------------------------
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsMonsterEffect() and rc:IsSetCard(SET_CORVFEW) and (rc:IsType(TYPE_RUNE) or rc:IsType(TYPE_FUSION)) then
		Duel.SetChainLimit(s.chainlm)
	end
end

function s.chainlm(e,rp,tp)
	return tp==rp
end
