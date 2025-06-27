--Hexlock Mimic
local s,id=GetID()
function s.initial_effect(c)
   --Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Use opponent monster as rune material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.runtg)
	e2:SetOperation(s.runop)
	c:RegisterEffect(e2)
    --act in hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetCondition(s.handcon)
	c:RegisterEffect(e4)
    aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_ACTIVATING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_END)
		ge2:SetOperation(s.regop)
        ge1:SetLabelObject(ge2)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={0xfc7}
--Special Summon as Effect monster
function s.spfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.spfilter(chkc) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x10fc,TYPE_MONSTER|TYPE_EFFECT,0,0,5,RACE_ILLUSION,ATTRIBUTE_EARTH,POS_FACEUP,tp,1) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x10fc,TYPE_MONSTER|TYPE_EFFECT,0,0,5,RACE_ILLUSION,ATTRIBUTE_EARTH,POS_FACEUP,tp,1) then return end
    c:AddMonsterAttribute(TYPE_EFFECT|TYPE_TRAP)
    Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        c:CopyEffect(tc:GetCode(),RESET_EVENT+RESETS_STANDARD)
    end
    c:AddMonsterAttributeComplete()
	Duel.SpecialSummonComplete()
end
--use opponent's targeted monster as extra material
function s.matfilter(c,tp,mg)
	mg:AddCard(c)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.runfilter,tp,0x3ff~LOCATION_MZONE,0,1,nil,c,mg)
end
function s.runfilter(c,mc,mg)
	return c:IsSetCard(0xfc7) and c:IsRuneSummonable(mc,mg)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.matfilter(c,tp,mg) end
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,0,LOCATION_ONFIELD,1,nil,tp,mg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.matfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp,mg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x3ff~LOCATION_MZONE)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
	mg:AddCard(tc)
	local g=Duel.GetMatchingGroup(s.runfilter,tp,0x3ff~LOCATION_MZONE,0,nil,tc,mg)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,1175)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	Duel.RuneSummon(tp,sc,tc,mg)
end
--Check that card can be activated from hand
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) then
		s[1-rp]=1
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if s[0]>0 then
		s[0]=0
		Duel.RegisterFlagEffect(0,id,RESET_CHAIN,0,0)
	end
	if s[1]>0 then
		s[1]=0
		Duel.RegisterFlagEffect(1,id,RESET_CHAIN,0,0)
	end
end
--act trap in hand
function s.handcon(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end