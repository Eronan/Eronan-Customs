--Etherune Zenith - Runic Ascendance
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
end
s.listed_series={0xfe3}
--activate: special summon rune monster
function s.cfilter(c)
	return c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,3,3,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.mustbematerialsallowed(tp,mg)
	local pg=aux.GetMustBeMaterialGroup(tp,mg,tp,nil,nil,REASON_RUNE)
	if #pg>#mg then return false
	elseif #pg==#mg then return pg:Equal(mg)
	elseif #pg==0 then return true
	elseif #pg==1 then return mg:IsContains(pg:GetFirst())
	else return not mg:IsExists(function (c) return not pg:IsContains(c) end,1,nil) end
end
function s.filter1(c,e,tp)
	return s.mustbematerialsallowed(tp,Group.FromCards(c,e:GetHandler())) and c:IsFaceup() and c:IsType(TYPE_RUNE)
		and c:IsSetCard(0xfe3) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.filter2(c,e,tp,mc)
	return c:IsAttribute(mc:GetAttribute()) and c:GetLevel()>mc:GetLevel() and c:IsType(TYPE_RUNE) and c:IsSetCard(0xfe3) and mc:IsCanBeRuneMaterial(c,tp)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RUNE,tp,false,true) and c:IsRuneCustomCheck(Group.FromCards(e:GetHandler(),mc),tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)

	if g:IsExists(Card.IsSetCard,1,nil,0xfe3) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function s.relatefilter(c,e,tp)
	return c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local mg=Group.FromCards(tc,c):Filter(s.relatefilter,nil,e,tp)
	if not mg:IsContains(tc) or not s.mustbematerialsallowed(tp,mg) then
		mg:DeleteGroup()
		return
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(mg)
		Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_RUNE)
		if Duel.SpecialSummonStep(sc,SUMMON_TYPE_RUNE,tp,tp,false,true,POS_FACEUP) then
			--immune
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.efilter)
			sc:RegisterEffect(e1)
			Duel.SpecialSummonComplete()
		end
		sc:CompleteProcedure()
	end
	mg:DeleteGroup()
end
--immune effect
function s.efilter(e,re,rp)
	if e:GetOwnerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
--activate from hand
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfe3) and c:IsLevelAbove(9)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end