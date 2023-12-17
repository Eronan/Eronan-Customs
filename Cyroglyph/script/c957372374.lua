--Sacred Cyroglyph Beast Hyperyton
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(s.monfilter),1,1,Rune.STFunction(nil),2,99)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.runlimit)
	c:RegisterEffect(e1)
	--Add Effects when used as Material
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.matcon)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
	--Extra Material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EFFECT_EXTRA_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetOperation(s.extracon)
	e3:SetValue(s.extraval)
	c:RegisterEffect(e3)
	if s.flagmap==nil then
		s.flagmap={}
	end
	if s.flagmap[c]==nil then
		s.flagmap[c] = {}
	end
	--check materials
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.matcheck)
	c:RegisterEffect(e4)
	--Negate activation of a card/effect
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.negcon)
	e5:SetTarget(s.negtg)
	e5:SetOperation(s.negop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	--aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
s.listed_series={0xfeb}
function s.monfilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_RUNE) and c:IsSetCard(0xfeb,fc,sumtype,tp)
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	e:SetLabel(0)
	if c:IsPreviousLocation(LOCATION_ONFIELD) then e:SetLabel(1) end
	return rc:IsType(TYPE_RUNE) and rc:IsSummonType(SUMMON_TYPE_RUNE) and rc:IsSetCard(0xfeb)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--
	--cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3061)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	rc:RegisterEffect(e1,true)
	if e:GetLabel()==1 then
		--Cannot be tributed
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3303)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		rc:RegisterEffect(e3,true)
	end
end
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	return (not sg or sg:FilterCount(s.flagcheck,nil)<2)
		and rc~=c
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfeb) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 then
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
function s.matcheck(e,c)
	local g=c:GetMaterial()
	local types=0
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		types=types+TYPE_MONSTER
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_SPELL) then
		types=types+TYPE_SPELL
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
	if g:IsExists(Card.IsType,1,nil,TYPE_TRAP) then
		types=types+TYPE_TRAP
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
	e:SetLabel(types)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local rt=re:GetActiveType()&(TYPE_SPELL|TYPE_MONSTER|TYPE_TRAP)
		return rt&e:GetLabelObject():GetLabel()~=0 and re:GetHandlerPlayer()==1-e:GetHandlerPlayer()
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end
