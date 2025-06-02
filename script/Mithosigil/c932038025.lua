--Medium of Mithosigil
local s,id=GetID()
if not Rune then Duel.LoadScript("proc_rune.lua") end
function s.initial_effect(c)
    --Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsRuneCode,932038020),1,1,Rune.STFunction(nil),1,1,LOCATION_GRAVE)
    --Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --Special Summon 'Mithosigil, Bringer of Storm'
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
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
--Add to hand
function s.thfilter1(c)
    return c:IsCode(932038020) and c:IsAbleToHand()
end
function s.thfilter2(c)
    return c:ListsCode(932038020) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
        and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,nil)
    local g2=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
    if #g1>0 and #g2>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg1=g1:Select(tp,1,1,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg2=g2:Select(tp,1,1,sg1)
        sg1:Merge(sg2)
        Duel.SendtoHand(sg1,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg1)
    end
end
--Special Summon 'Mithosigil, Bringer of Storm'
function s.spfilter(c,e,tp)
	return c:IsCode(932038020) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ecfilter(c,tc)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,tp,0)
    local etc=g1:GetFirst()
    local g2=Duel.SelectTarget(tp,s.ecfilter,tp,LOCATION_GRAVE,0,1,1,nil,etc)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,s1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
    if #tg<2 then return end
    local spg=tg:Filter(s.spfilter,nil,e,tp)
	if #spg~=1 then return end
    local spc=spg:GetFirst()
    if not spc:IsRelateToEffect(e) then return end
    local eqg=tg:Filter(s.ecfilter,nil,spc)
    if #eqg~=1 then return end
    local eqc=eqg:GetFirst()
	if not eqc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
        if eqc:CheckEquipTarget(spc) then
           Duel.Equip(tp,eqc,spc)
        end
    end
end