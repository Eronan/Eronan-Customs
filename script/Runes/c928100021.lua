--Etherunetation Saqalypse Sigil
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_SAQA=0xfbe
function s.initial_effect(c)
	--Activate (Rune Summon)
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetLabel(0)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-------------------------------------------------
--Generic Filter Functions
-------------------------------------------------
function s.mustbematerialsallowed(tp,mg)
	local pg=aux.GetMustBeMaterialGroup(tp,mg,tp,nil,nil,REASON_RUNE)
	if #pg>#mg then return false
	elseif #pg==#mg then return pg:Equal(mg)
	elseif #pg==0 then return true
	elseif #pg==1 then return mg:IsContains(pg:GetFirst())
	else return not mg:IsExists(function (c) return not pg:IsContains(c) end,1,nil) end
end
function s.spfilter(c,e,tp,mc,code)
    return c:IsType(TYPE_RUNE) and c:GetLevel()>mc:GetLevel() and c:ListsCode(mc:GetCode()) and (code==0 or c:IsCode(code))
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RUNE,tp,false,true) and c:IsRuneCustomCheck(Group.FromCards(mc,e:GetHandler()),tp)
end
function s.tgfilter(c,e,tp)
    return c:IsFaceup() and c:IsType(TYPE_RUNE) and s.mustbematerialsallowed(tp,Group.FromCards(c,e:GetHandler()))
end
-------------------------------------------------
--Condition (Main Phase only)
-------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local phase=Duel.GetCurrentPhase()
	return phase==PHASE_MAIN1 or phase==PHASE_MAIN2
end

-------------------------------------------------
--Reveal Cost
-------------------------------------------------
function s.rvtgfilter(c,e,tp,rc)
    return s.spfilter(rc,e,tp,c,0) and s.tgfilter(c,e,tp)
end
function s.rvfilter(c,e,tp)
    return c:IsSetCard(SET_SAQA) and Duel.IsExistingMatchingCard(s.rvtgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    e:SetLabel(0)
    local g=Duel.GetMatchingGroup(s.rvfilter,tp,LOCATION_DECK,0,nil,e,tp)
    if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    if tc then
        Duel.ConfirmCards(1-tp,tc)
        Duel.ShuffleDeck(tp)
        e:SetLabel(tc:GetCode())
    end
end

-------------------------------------------------
--Target Material
-------------------------------------------------
function s.sptgfilter(c,e,tp,code)
	return s.tgfilter(c,e,tp) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c,code)
end
function s.chlimit(e,ep,tp)
    return tp==ep
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.sptgfilter(chkc) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.sptgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,e:GetLabel()) end
    local code=e:GetLabel()
    if code~=0 then Duel.SetChainLimit(s.chlimit) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.sptgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,code)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-------------------------------------------------
--Operation
-------------------------------------------------
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) then return end
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not c:IsControler(tp) or c:IsImmuneToEffect(e) then return end
	local mg=Group.FromCards(tc,e:GetHandler())
	if not mg:IsContains(tc) or not s.mustbematerialsallowed(tp,mg) then
		mg:DeleteGroup()
		return
	end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc,e:GetLabel())
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(mg)
		Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_RUNE)
		Duel.SpecialSummon(sc,SUMMON_TYPE_RUNE,tp,tp,false,true,POS_FACEUP)
        c:SetCardTarget(sc)
		sc:CompleteProcedure()
	end
	mg:DeleteGroup()
end