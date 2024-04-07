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
    --Extra Material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EFFECT_EXTRA_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetOperation(s.extracon)
	e2:SetValue(s.extraval)
	c:RegisterEffect(e2)
	if s.flagmap==nil then
		s.flagmap={}
	end
	if s.flagmap[c]==nil then
		s.flagmap[c] = {}
	end
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
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_SZONE,1,nil,e,tp)
        and Duel.IsExistingTarget(s.plfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_SZONE,1,1,nil,e,tp)
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
--Extra Material
function s.extrafilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup()
end
function s.extracon(c,e,tp,sg,mg,sc,og,chk)
    if sg then
        return (sg+mg):IsExists(s.extrafilter,nil,e:GetHandlerPlayer()) and sg:FilterCount(s.flagcheck,nil)<2
    else
        return mg:IsExists(s.extrafilter,nil,e:GetHandlerPlayer())
    end
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
        local sumtyp=summon_type&(SUMMON_TYPE_RUNE|SUMMON_TYPE_LINK)
		if (sumtyp~=SUMMON_TYPE_RUNE and sumtyp~=SUMMON_TYPE_LINK) or not sc:IsSetCard(0xfd1) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
        local sumtyp=summon_type&(SUMMON_TYPE_RUNE|SUMMON_TYPE_LINK)
		if (sumtyp==SUMMON_TYPE_RUNE or sumtyp==SUMMON_TYPE_LINK) and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif chk==2 then
		for _,eff in ipairs(s.flagmap[c]) do
			eff:Reset()
		end
		s.flagmap[c]={}
	end
end