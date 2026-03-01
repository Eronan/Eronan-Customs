--Caraphron Chrysalith
local s,id=GetID()
function s.initial_effect(c)
    --Link summon procedure
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,1,1) -- 1 Level 4+ Insect monster

    --(1) On Special Summon: discard 1, send up to 2 "Caraphron" cards from Deck to GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- prompt for effect 1
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.tgcost)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)
    
    --(2) Quick revive from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.revcon)
	e2:SetCost(s.revcost)
	e2:SetTarget(s.revtg)
	e2:SetOperation(s.revop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc0}
--==========================
--Link Material Filter
--==========================
function s.matfilter(c,lc,sumtype,tp)
    return c:IsLevelAbove(4) and c:IsRace(RACE_INSECT)
end

--==========================
--Effect 1: Send Caraphron cards to GY
--==========================
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.tgfilter1(c)
    return c:IsSetCard(0xfc0) and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.tgfilter1,tp,LOCATION_DECK,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local sg=g:Select(tp,1,2,nil)
        Duel.SendtoGrave(sg,REASON_EFFECT)
    end
end

--=================================
-- Effect (2): Quick revive from
--=================================
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.revcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_INSECT) end
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_INSECT)
	Duel.Release(g,REASON_COST)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end