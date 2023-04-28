--Ulano, Subshifter
local s,id=GetID()
function s.initial_effect(c)
	Gemini.AddProcedure(c)
	--special summon (itself)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--link summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(Gemini.EffectStatusCondition)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
	--ritual summon
	local e3=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0xfd3),extrafil=s.extragroup,
		desc=aux.Stringid(id,2),location=LOCATION_DECK|LOCATION_GRAVE,forcedselection=s.ritcheck})
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(Gemini.EffectStatusCondition)
	c:RegisterEffect(e3)
	--[[
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(Gemini.EffectStatusCondition)
	e3:SetTarget(s.rittg)
	e3:SetOperation(s.ritop)
	c:RegisterEffect(e3)
	--]]
end
s.listed_series={0xfd3}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.lkfilter(c,mg)
	return c:IsSetCard(0xfd3) and c:IsLinkSummonable(nil,mg,2,2)
end
function s.tgfilter(tc,c,tp)
	local mg=Group.FromCards(c,tc)
	return tc:IsFaceup() and tc:IsCanBeLinkMaterial() and Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc,e:GetHandler(),tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsControler(tp) and c:IsFaceup() and tc and tc:IsControler(1-tp) and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)then
		local mg=Group.FromCards(c,tc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
		local sc=g:GetFirst()
		if sc then
			Duel.LinkSummon(tp,sc,nil,mg,2,2)
		end
	end
end
function s.mfilter(c,e)
    return c:IsFaceup() and c:GetLevel()>0 and not c:IsImmuneToEffect(e) and c:IsReleasable()
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroup(s.mfilter,tp,0,LOCATION_MZONE,nil,e)
end
function s.ritcheck(e,tp,g,sc)
	return g:IsContains(e:GetHandler())
		and #g:Filter(Card.IsControler,nil,1-tp)==1
		and #g==2
end
--[[
function s.ritcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.relfilter(c,e,tp)
	return c:GetLevel()>0
		and Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel()+2)
end
function s.ritfilter(c,e,tp,lv)
	return c:IsType(TYPE_RITUAL) and c:GetLevel()<=lv and c:IsSetCard(0xfd3)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,false)
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	Debug.Message("Reached")
    if chk==0 then return Duel.CheckReleaseGroup(1-tp,s.relfilter,1,nil,e,tp)
		and ft>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectReleaseGroup(1-tp,s.relfilter,1,1,nil,e,tp)
    if g then
		local lv=g:GetFirst():GetLevel()
        Duel.Release(g,REASON_EFFECT)
		local ritg=Duel.GetMatchingGroup(s.ritfilter,tp,LOCATION_DECK,0,nil,e,tp,lv+2)
		if #ritg>0 then
			local rc=ritg:Select(tp,tp,1,1)
			Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,false,POS_FACEUP)
		end
    end
end
--]]