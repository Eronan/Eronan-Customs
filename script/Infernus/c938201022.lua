--Kinetic TelEscaper Seer
local s,id=GetID()
function s.initial_effect(c)
    --synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
    --special summon synchro monster from extra
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e1:SetCost(s.exspcost)
	e1:SetTarget(s.exsptg)
	e1:SetOperation(s.exspop)
	c:RegisterEffect(e1)
    --special summon tuner and then synchro
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_names={938201010}
s.listed_series={0xffb}
--special summon synchro monster from extra
function s.exspcfilter(c,e,tp)
	return c:IsFaceup() and (c:IsCode(938201010) or (c:IsType(TYPE_TUNER) and c:IsSetCard(0xffb))) and c:IsControler(tp)
        and Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel())
end
function s.exspfilter(c,e,tp,lv)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:GetLevel()==lv+1
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.exspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.exspcfilter,1,nil,e,tp) end
    local g=eg:Filter(s.exspcfilter,nil,e,tp)
    local tc
    if #g==1 then tc=g:GetFirst()
    else tc=g:Select(tp,1,1,nil) end

    if tc then
        Duel.SendtoGrave(tc,REASON_COST)
        e:SetLabel(tc:GetLevel())
    end
end
function s.exsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.exspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--special summon tuner and then synchro
function s.spfilter(c,e,tp)
    return c:IsPreviousPosition(POS_FACEUP) and c:IsOriginalType(TYPE_TUNER) and c:IsPreviousLocation(LOCATION_ONFIELD)
        and c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
        and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
function s.scfilter(c,mc)
	return c:IsSynchroSummonable(mc,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return eg:IsContains(chkc) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(s.spfilter,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=eg:FilterSelect(tp,aux.NecroValleyFilter(s.spfilter),1,1,nil,e,tp)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or not Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then return end
    local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,tc)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SynchroSummon(tp,sg:GetFirst(),tc,nil)
    end
end