--Insigniate Charm
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    aux.AddEquipProcedure(c)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_MAIN_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(function()return Duel.IsMainPhase()end)
	e2:SetTarget(s.runtg)
	e2:SetOperation(s.runop)
	c:RegisterEffect(e2)
	--Extra Material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EFFECT_EXTRA_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetOperation(s.extracon)
	e3:SetValue(s.extraval)
	e3:SetTarget(s.sendloc)
	c:RegisterEffect(e3)
	if s.flagmap==nil then
		s.flagmap={}
	end
	if s.flagmap[c]==nil then
		s.flagmap[c] = {}
	end
	--Rune Subsitute
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_RUNE_SUBSTITUTE)
    c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.subcon)
	c:RegisterEffect(e5)
end
function s.runfilter(c,must,mg)
	--return c:IsSetCard(0xffa) and c:IsRuneSummonable(Group.FromCards(ec))
	return c:IsType(TYPE_RUNE) and c:IsRuneSummonable(must,mg)
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
		local ec=e:GetHandler():GetEquipTarget()
		mg:AddCard(ec)
		return Duel.IsExistingMatchingCard(s.runfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,Group.FromCards(ec),mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		local mg=Duel.GetMatchingGroup(Card.IsCanBeRuneGroup,tp,LOCATION_ONFIELD,0,nil,Duel.GetCurrentChain())
		local must=Group.FromCards(tc)
		mg:AddCard(tc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.runfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,must,mg)
		local sc=g:GetFirst()
		if sc then
			Duel.RuneSummon(tp,sc,must,mg)
		end
	end
	--Add Restriction
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
--
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return not sg or sg:FilterCount(s.flagcheck,nil)<2
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 and Duel.GetFlagEffect(tp,id)==0 then
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
function s.sendloc(c,e,tp,sg,ug,rc,chk)
	return LOCATION_REMOVED
end
function s.subcon(e)
    return e:GetHandler():GetEquipTarget()
end