--Proxumia Mindweaver - Seralith
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Cannot be destroyed by battle or effects while you control a Token
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
    --Link Summon "Proxumia" monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0)) -- Optional: use your string ID
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_HAND)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e3:SetCondition(function(_) return Duel.IsMainPhase() end)
    e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e3:SetCost(s.lscost)
    e3:SetTarget(s.lstg)
    e3:SetOperation(s.lsop)
    c:RegisterEffect(e3)
    -- Trigger when sent to GY as Link material for "Proxumia" OR Ritual Summoned
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_CONTROL)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCondition(s.ctmatcon)
    e4:SetTarget(s.cttg)
    e4:SetOperation(s.ctop)
    e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetCondition(function (e) return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) end)
    c:RegisterEffect(e5)
end
s.listed_series={0xfc3}
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
--Take control of monster until the End Phase
function s.ctmatcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0xfc3)
end
function s.ctfilter(c)
    return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsControlerCanBeChanged()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.ctfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
