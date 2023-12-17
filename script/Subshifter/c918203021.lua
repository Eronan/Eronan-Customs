--Ulano, Subshifter Operative
local s,id=GetID()
function s.initial_effect(c)
	--Link summon
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	--target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tglimit)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--ritual summon
	local e3=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0xfd3),matfilter=aux.FilterBoolFunction(Card.IsOnField),
		desc=aux.Stringid(id,2),location=LOCATION_HAND|LOCATION_GRAVE,requirementfunc=s.ritrequirement,forcedselection=s.ritcheck})
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(function(e,tp) return not Duel.IsMainPhase() end)
    c:RegisterEffect(e3)
	--[[
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e3:SetCost(s.ritcost)
	e3:SetCondition(function(e,tp) return not Duel.IsMainPhase() end)
	e3:SetTarget(s.rittg)
	e3:SetOperation(s.ritop)
	c:RegisterEffect(e3)
	--]]
end
s.listed_series={0xfd3}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xfd3,lc,sumtype,tp)
end
function s.tglimit(e,c)
	return c~=e:GetHandler()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xfd3) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.ritrequirement(c,rc)
	if c:GetRitualLevel(rc)>0 then return aux.RitualCheckAdditionalLevel(c,rc)
	elseif c:GetLink()>0 then return c:GetLink()
	else return 0 end
end
function s.ritcheck(e,tp,g,sc)
	return g:IsContains(e:GetHandler())
		and #g==2
end
--[[
function s.ritcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroupCost(tp,s.relfilter,1,false,aux.ReleaseCheckMMZ,c,e,tp) end
	local rg=Duel.SelectReleaseGroupCost(tp,s.relfilter,1,1,false,aux.ReleaseCheckMMZ,c,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	rg:AddCard(c)
	Duel.Release(rg,REASON_COST)
end
function s.relfilter(c,e,tp)
	return c:GetLevel()>0
		and Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel()+2)
end
function s.ritfilter(c,e,tp,lv)
	return c:IsSetCard(0xfd3) and c:IsType(TYPE_RITUAL) and c:GetLevel()<=lv
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,POS_FACEUP_DEFENSE)
end
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	local ritg=Duel.GetMatchingGroup(s.ritfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,lv+2)
	if #ritg>0 then
		local rc=ritg:Select(tp,tp,1,1)
		Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP_DEFENSE)
	end
end
--]]