--Cyroglyph Regus
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsType,TYPE_RUNE),2,99,Rune.STFunctionEx(Card.IsSetCard,0xfeb),1,1)
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
	--remove
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,0xff)
	e3:SetValue(LOCATION_REMOVED)
	e3:SetTarget(s.rmtg)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(TIMING_MAIN_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.runcon)
	e4:SetOperation(s.runop)
	c:RegisterEffect(e4)
	--use opponent's monsters as material
	--Extra Material
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_EXTRA_MATERIAL)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetOperation(s.extracon)
	e6:SetValue(s.extraval)
	c:RegisterEffect(e6)
	--[[
	if s.flagmap==nil then
		s.flagmap={}
	end
	if s.flagmap[c]==nil then
		s.flagmap[c] = {}
	end
	--]]
end
s.listed_series={0xfeb}
function s.checkfilter(c,rc,sumtype,tp)
	return c:IsType(TYPE_RUNE) and c:IsLocation(LOCATION_MZONE)
end
function s.rune_custom_check(g,rc,sumtype,tp)
	return g:IsExists(s.checkfilter,1,nil,rc,sumtype,tp)
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and rc:IsType(TYPE_RUNE) and rc:IsSummonType(SUMMON_TYPE_RUNE) and rc:IsSetCard(0xfeb)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--cannot special summon
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetAbsoluteRange(ep,1,1)
	e1:SetTarget(s.sumlimit)
	rc:RegisterEffect(e1,true)
	rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
		and c:IsType(TYPE_MONSTER)
end
function s.runcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.GetTurnPlayer()~=tp
end
function s.runfilter(c,mg)
	return c:IsOriginalType(TYPE_RUNE) and c:IsRuneSummonable(nil,mg)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp)
	local exg=Duel.GetMatchingGroup(s.eqfilter,tp,0,LOCATION_EXTRA,nil,tp)
	if #exg>0 then Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)) end
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil):Merge(exg)
	if #mg>=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.runfilter,tp,LOCATION_HAND,0,1,1,nil,mg)
		local sc=g:GetFirst()
		if sc then
			Duel.RuneSummon(tp,sc,nil,mg)
		end
	end
end
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	return rc~=c
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfeb) or c:GetFlagEffect(id)>0 then
			return Group.CreateGroup()
		else
			local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
			--table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return g
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
