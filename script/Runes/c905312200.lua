--Celsitial Etherune Circle
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
	--Destruction replacement
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfce}
--special summon
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
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.filter2(c,e,tp,mc)
	return c:GetLevel()>mc:GetLevel() and c:IsType(TYPE_RUNE) and c:IsRace(mc:GetRace()) and c:IsAttribute(mc:GetAttribute()) and c:IsSetCard(0xfce)
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
		Duel.SpecialSummon(sc,SUMMON_TYPE_RUNE,tp,tp,false,true,POS_FACEUP)
		sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
		sc:CompleteProcedure()
	end
	mg:DeleteGroup()
end
--destruction replacement
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and c:GetFlagEffect(id)>0
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
end