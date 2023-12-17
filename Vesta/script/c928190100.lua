--Vesta of Parasitic Bloom
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--Any Xyz Level
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_XYZ_LEVEL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(Gemini.EffectStatusCondition)
	e3:SetValue(s.xyzlevel)
	c:RegisterEffect(e3)
end
--xyz summon
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Gemini.EffectStatusCondition(e) and Duel.IsMainPhase()
end
function s.ctfilter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup() and c:HasLevel()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1) then
		local mg=Group.FromCards(e:GetHandler(),tc)
		local xyzg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,mg,mg)
		if xyzg and #xyzg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
			Duel.XyzSummon(tp,xyz,mg,mg)
			--immune
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			e1:SetValue(s.efilter)
			xyz:RegisterEffect(e1)
		end
	end
end
--immune
function s.efilter(e,re,rp)
	if te:GetOwnerPlayer()==e:GetOwnerPlayer() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
--Xyz Level
function s.xyzlevel(e,c,rc)
    return rc:GetRank()
end
