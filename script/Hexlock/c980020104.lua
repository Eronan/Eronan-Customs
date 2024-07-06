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
	e2:SetTarget(s.mttg)
	e2:SetOperation(s.mtop)
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
function s.exfilter(c)
	return c:IsFaceup()
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.exfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) then
        local c=e:GetHandler()
        --Extra Material
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetRange(LOCATION_MZONE|LOCATION_SZONE)
        e1:SetCode(EFFECT_EXTRA_MATERIAL)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0,1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetValue(s.extraval)
        tc:RegisterEffect(e1)
	end
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfc7) or not c:IsControler(1-tp) then
			return Group.CreateGroup()
		else
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 and sc:IsSetCard(0xfc7) and c:IsControler(1-tp) then
			Duel.Hint(HINT_CARD,tp,id)
		end
	end
end
--Check that card can be activated from hand
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) then
		s[1-re:GetHandlerPlayer()]=1
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