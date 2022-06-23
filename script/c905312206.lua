--Ever-Runic Incantation
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
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xfe3}
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_RUNE)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.filter2(c,e,tp,mc)
	return (c:GetLevel()>mc:GetLevel() and c:GetLevel()<=mc:GetLevel()+3) and c:IsType(TYPE_RUNE) and c:IsRace(mc:GetRace()) and c:IsSetCard(0xfe3)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RUNE,tp,false,true) and c:IsRuneCustomCheck(Group.FromCards(e:GetHandler(),mc),tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=Group.FromCards(tc,e:GetHandler())
		sc:SetMaterial(mg)
		Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_RUNE)
		Duel.BreakEffect()
		if c:IsRuneCustomCheck(Group.FromCards(e:GetHandler(),mc),tp) and Duel.SpecialSummonStep(sc,SUMMON_TYPE_RUNE,tp,tp,false,true,POS_FACEUP) then
			--cannot be battle target
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.atkcon)
			e1:SetValue(aux.imval1)
			sc:RegisterEffect(e1)
			Duel.SpecialSummonComplete()
		end
		sc:CompleteProcedure()
		mg:DeleteGroup()
	end
end
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
