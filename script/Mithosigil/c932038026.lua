--Hounds of Mithosigil
local s,id=GetID()
if not Rune then Duel.LoadScript("proc_rune.lua") end
function s.initial_effect(c)
    --Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsRuneCode,932038020),1,1,Rune.STFunction(nil),1,1,LOCATION_GRAVE)
    --Neither player can activate cards that negate or disable for the next two turns
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE) end)
	e1:SetTarget(s.limtg)
	e1:SetOperation(s.limop)
	c:RegisterEffect(e1)
    --Special Summon 'Mithosigil, Bringer of Storm'
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(Cost.SelfTribute)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={932038020}
function s.matfilter(c,sc,sumtyp,tp)
    return c:IsSummonCode(sc,sumtyp,tp,932038020)
end
--Neither player can activate cards that negate or disable for the next two turns
function s.limtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetTargetRange(1,1)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,2)
	Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE|PHASE_END,0,2)
end
function s.aclimit(e,re,tp)
	return re:IsActivated()
        and (re:IsHasCategory(CATEGORY_DISABLE) or re:IsHasCategory(CATEGORY_NEGATE))
end
--Special Summon 'Mithosigil, Bringer of Storm'
function s.spfilter(c,e,tp)
	return c:IsCode(932038020) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.fsfilter(c,tp)
	return c:IsFieldSpell() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then
		return Duel.GetMZoneCount(tp,c)>0
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.IsExistingTarget(s.fsfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,tp,0)
    local g2=Duel.SelectTarget(tp,s.fsfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
    if #tg<2 then return end
    local spg=tg:Filter(s.spfilter,nil,e,tp):Filter(Card.IsRelateToEffect,nil,e)
	if #spg~=1 then return end
    local spc=spg:GetFirst()
    if not spc:IsRelateToEffect(e) then return end
    local tfg=tg:Filter(s.fsfilter,nil,tp):Filter(Card.IsRelateToEffect,nil,e)
    if #tfg~=1 then return end
    local tfc=tfg:GetFirst()
	if not tfc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
        Duel.ActivateFieldSpell(tfc,e,tp,eg,ep,ev,re,r,rp)
    end
end