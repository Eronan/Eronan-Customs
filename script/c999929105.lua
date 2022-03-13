--Witch of Runic Descendant
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.runtg)
	e2:SetOperation(s.runop)
	c:RegisterEffect(e2)
end
function s.runfilter(c,mg)
	return c:IsOriginalType(TYPE_RUNE) and c:IsRuneSummonable(nil,mg)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=e:GetHandler():GetColumnGroup(1,1):AddCard(e:GetHandler())
	if chk==0 then return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_ALL-LOCATION_MZONE,0,1,nil,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_ALL-LOCATION_MZONE)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsLocation(LOCATION_MZONE) or not c:IsFaceup() then return false end
	local mg=c:GetColumnGroup(1,1):AddCard(e:GetHandler())
	if #mg>=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.runfilter,tp,LOCATION_ALL-LOCATION_MZONE,0,1,1,nil,mg)
		local sc=g:GetFirst()
		if sc then
			Duel.RuneSummon(tp,sc,must,mg)
		end
	end
end
