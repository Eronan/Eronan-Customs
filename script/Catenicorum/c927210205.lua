--Catenicorum Portal
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Rune Summon from Deck
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_RUNE_LOCATION)
    e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfcf))
    e2:SetTargetRange(LOCATION_DECK,0)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e2)
	--Extra Rune Material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_DECK)
	e3:SetCode(EFFECT_EXTRA_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetOperation(s.extracon)
	e3:SetValue(s.extraval)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_DECK,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		s.flagmap={}
	end)
	--place on field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.tfcon)
	e5:SetTarget(s.tftg)
	e5:SetOperation(s.tfop)
	c:RegisterEffect(e5)
end
s.listed_series={0xfcf}
--Rune from deck
function s.sumtg(e,c)
	return c:IsSetCard(0xfcf) and c:IsType(TYPE_RUNE)
end
function s.runcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0
end
--extra material
function s.eftg(e,c)
	return c:IsSetCard(0xfcf) and c:IsMonster() and c:IsCanBeRuneMaterial()
end
function s.extrafilter(c,tp)
	return c:IsLocation(LOCATION_SZONE) and c:IsControler(tp)
end
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	if tp==nil then return true end
	if c==rc then return false end
	local ct=sg:FilterCount(s.flagcheck,nil)
	return sg:Filter(s.extrafilter,nil,e:GetHandlerPlayer()):IsExists(Card.IsCode,1,og,id) and ct<2
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0 or sc:IsLocation(LOCATION_DECK) or not sc:IsSetCard(0xfcf) then
			return Group.CreateGroup()
		else
			s.flagmap[c]=c:RegisterFlagEffect(id,0,0,1)
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if Duel.GetFlagEffect(tp,id)==0 and summon_type&SUMMON_TYPE_RUNE==SUMMON_TYPE_RUNE and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(e:GetHandlerPlayer(),id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif chk==2 then
		if s.flagmap[c] then
			s.flagmap[c]:Reset()
			s.flagmap[c]=nil
		end
	end
end
--place on field
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetHandler():GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSummonType(SUMMON_TYPE_RUNE) and c:CheckUniqueOnField(tp)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
