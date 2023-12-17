--Catenicorum Sanctum
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
	--Prevent negation of Normal/Special Summons
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfcf))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e3)
	--immune
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.immtg)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	--Extra Rune Material
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_DECK)
	e6:SetCode(EFFECT_EXTRA_MATERIAL)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetOperation(s.extracon)
	e6:SetValue(s.extraval)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_DECK,0)
	e7:SetTarget(s.eftg)
	e7:SetLabelObject(e6)
	c:RegisterEffect(e7)
	aux.GlobalCheck(s,function()
		s.flagmap={}
	end)
	--place on field
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_BE_MATERIAL)
	e8:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e8:SetCondition(s.tfcon)
	e8:SetTarget(s.tftg)
	e8:SetOperation(s.tfop)
	c:RegisterEffect(e8)
end
s.listed_series={0xfcf}
--immune
function s.efilter(e,re,rp)
	return re:GetHandlerPlayer()~=e:GetHandlerPlayer()
		and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
function s.immtg(e,c)
	return c:IsSetCard(0xfcf) and c:IsType(TYPE_RUNE)
end
--extra material
function s.eftg(e,c)
	return c:IsSetCard(0xfcf) and c:IsCanBeRuneMaterial()
end
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	if tp==nil then return true end
	local ct=sg:FilterCount(s.flagcheck,nil)
	return sg:IsExists(Card.IsControler,1,nil,e:GetHandlerPlayer()) and ct<2
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if Duel.GetFlagEffect(tp,id)>0 or summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfcf) then
			return Group.CreateGroup()
		else
			s.flagmap[c]=c:RegisterFlagEffect(id,0,0,1)
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if Duel.GetFlagEffect(tp,id)==0 and summon_type&SUMMON_TYPE_RUNE==SUMMON_TYPE_RUNE and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif chk==2 then
		if s.flagmap[c] then
			s.flagmap[c]:Reset()
			s.flagmap[c]=nil
		end
	end
end
--activate this field spell
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetHandler():GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSummonType(SUMMON_TYPE_RUNE)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.ActivateFieldSpell(c,e,tp,eg,ep,ev,re,r,rp)
	end
end
