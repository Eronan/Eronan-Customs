--Sky Shroudis Angel
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(nil),1,1,Rune.STFunction(Card.IsLinkSpell),1,1)
    --spsummon link & place link spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Place Link monster as Link Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.plcon)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfd1}
--spsummon link & place link spell
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RUNE)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsLinkSpell()
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.plfilter(c,tp)
	return c:IsLinkMonster() and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
        and Duel.IsExistingTarget(s.plfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_LEAVE_GRAVE)
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
    local tc=g1:GetFirst()
    --Place as Link Spell
    if not tc:IsRelateToEffect(e) or not Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then return end
    --Treat it as a Link Spell
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetValue(TYPE_SPELL|TYPE_LINK)
    e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
    tc:RegisterEffect(e1)
    --Special Summon
    local sc=g2:GetFirst()
	if not sc:IsRelateToEffect(e) then return end
    Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
end
--Place Link monster as Link Spell
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and (r==REASON_LINK or e:GetHandler():GetReasonCard():IsSummonType(SUMMON_TYPE_RUNE))
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,tp)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            --Treat it as a Link Spell
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetValue(TYPE_SPELL|TYPE_LINK)
            e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
            tc:RegisterEffect(e1)
        end
    end
end
