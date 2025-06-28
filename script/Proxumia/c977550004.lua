-- Proxumia Flamecaller - Zhenira
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- ATK gain
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    --Link Summon "Proxumia" monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0)) -- Optional: use your string ID
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCondition(function(_) return Duel.IsMainPhase() end)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e2:SetCost(s.lscost)
    e2:SetTarget(s.lstg)
    e2:SetOperation(s.lsop)
    c:RegisterEffect(e2)
    -- Special summon monster from opponent's GY to Linked Zone
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(s.spcon_mat)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(function (e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) end)
    c:RegisterEffect(e4)
end
s.listed_series={0xfc3}
-- ATK gain
function s.atkval(e,c)
    return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)*200
end
--Link Summon "Proxumia" monster
function s.lscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.lkfilter(c,mg,tp,mat)
	return c:IsSetCard(0xfc3) and c:IsType(TYPE_LINK)
		and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
		and c:IsLinkSummonable(mat,mg)
end
function s.lstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        local c=e:GetHandler()
        local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
        mg:AddCard(c)
		return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,mg,tp,c)
	end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    mg:AddCard(c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg,tp,c)
	local tc=g:GetFirst()
	if tc then
		Duel.LinkSummon(tp,tc,c,mg)
	end
end
-- Special summon monster from opponent's GY to Linked Zone
function s.spcon_mat(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0xfc3)
end
function s.spcon_rit(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.spfilter(c,e,tp,zone)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local zone=aux.GetMMZonesPointedTo(tp)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp,zone) end
    if chk==0 then return zone~=0 and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local zone=aux.GetMMZonesPointedTo(tp)
    if tc and tc:IsRelateToEffect(e) and zone~=0 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
    end
end