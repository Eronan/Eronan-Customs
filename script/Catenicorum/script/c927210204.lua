--Catenicorum Ethereal Beast
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(aux.NOT(Card.IsType),TYPE_TOKEN),2,99,Rune.STFunction(nil),2,99,LOCATION_DECK,nil,nil,s.runchk,s.matcheck)
	--actlimit
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,1)
    e1:SetValue(1)
    e1:SetCondition(s.actcon)
    c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--use opponent monster as rune materials
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.matcon)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfcf}
--must use rune materials
function s.matcheck(g,rc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xfcf,rc,sumtype,tp)
end
--Catenicorum Portal effect
function s.runchk(e,tp,chk,mg)
	if chk==0 then return Duel.IsPlayerAffectedByEffect(tp,927210205) and Duel.GetFlagEffect(tp,927210205)==0 end
	Duel.RegisterFlagEffect(tp,927210205,RESET_PHASE+PHASE_END,0,1)
	return true
end
--act limit
function s.actcon(e)
    return Duel.GetCurrentChain(true)==2
end
--banish from opponent's extra deck
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)>=2 and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local mg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
	if #mg>0 then
		Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
	end
	Duel.ShuffleExtra(1-tp)
end
--use opponent monsters as rune materials
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	e:SetLabel(0)
	if c:IsPreviousLocation(LOCATION_ONFIELD) and rc:IsSetCard(0xfcf) then e:SetLabel(1) end
	return rc:IsSummonType(SUMMON_TYPE_RUNE)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(e:GetLabel())
	e1:SetValue(s.extraval)
	Duel.RegisterEffect(e1,tp)
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfcf) then
			return Group.CreateGroup()
		else
			local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
			return g
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE then
			if e:GetLabel()==0 then e:Reset() end
			if #sg>0 then Duel.Hint(HINT_CARD,tp,id) end
		end
	end
end
