--Astagraphy Thunder Reliquary
local s,id=GetID()
local SET_ASTAGRAPHY=0xfef
function s.initial_effect(c)
	--Activate and become Trap Monster
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--Rune Summon effect
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetTarget(s.runtg)
	e2:SetOperation(s.runop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ASTAGRAPHY}
--Trap Monster Summon
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0xfef,0x11,1000,2500,5,RACE_THUNDER,ATTRIBUTE_WIND) then return end
	if Duel.SelectYesNo(tp, aux.Stringid(id,0)) then
		c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		c:AddMonsterAttributeComplete()
		Duel.SpecialSummonComplete()
	end
end

--Rune Summon target
function s.rnfilter(c,mc)
    return c:IsSetCard(SET_ASTAGRAPHY) and c:IsRuneSummonable(mc)
end
function s.ctfilter(c,tp)
	return c:IsFaceup() and c:IsContinuousTrap()
        and Duel.IsExistingMatchingCard(s.rnfilter,tp,LOCATION_ALL-LOCATION_MZONE,0,1,nil,c)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_ALL-LOCATION_MZONE)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
    --Rune Summon
    local rc=Duel.SelectMatchingCard(tp,s.rnfilter,tp,LOCATION_ALL-LOCATION_MZONE,0,1,1,nil,tc):GetFirst()
    if not rc then return end
    Duel.RuneSummon(tp,rc,tc)
end