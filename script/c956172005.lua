--Luminereid of Song Laraine
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(s.MonMatFilter),1,1,Rune.STFunction(nil),1,1)
	--destroy replace
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.desreptg)
    e1:SetValue(s.desrepval)
    e1:SetOperation(s.desrepop)
    c:RegisterEffect(e1)
	-- Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.spcost)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CHAIN_DISABLED)
	c:RegisterEffect(e3)
end
function s.MonMatFilter(c,rc,sumtyp,tp)
	return c:IsRace(RACE_FISH,rc,sumtyp,tp) and c:IsAttribute(ATTRIBUTE_LIGHT,rc,sumtyp,tp)
end
function s.repfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
end
function s.tgfilter(c,e,tp)
    return c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_EXTRA,0,nil)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
        and g:IsExists(s.tgfilter,1,nil,e,tp) end
    if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
        local sg=g:FilterSelect(tp,s.tgfilter,1,1,nil,e,tp)
        e:SetLabelObject(sg:GetFirst())
        Duel.HintSelection(sg)
        return true
    else return false end
end
function s.desrepval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REPLACE)
end
--Check for Special Summon Target
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xfd7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	return re:GetHandlerPlayer()==e:GetHandlerPlayer()
		and (tc:IsRace(RACE_FISH) or (tc:IsSetCard(0xfd7) and tc:IsType(TYPE_SPELL+TYPE_TRAP)))
end
--Activation legality
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
--Special Summon "Luminereid" monster and then Rune Summon
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	if c:IsRuneSummonable() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.RuneSummon(tp,c)
	else
		Duel.SendtoGrave(c,REASON_EFFECT+REASON_DISCARD)
	end
end
