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
    --allow summon from deck
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(id)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(1,0)
    c:RegisterEffect(e2)
	--[[
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_DECK)
	e2:SetCondition(s.runcon)
	e2:SetTarget(s.runtg)
	e2:SetOperation(s.runop)
	e2:SetValue(SUMMON_TYPE_LINK)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(s.sumtg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--]]
	--Extra Rune Material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_DECK)
	e4:SetCode(EFFECT_EXTRA_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetOperation(s.extracon)
	e4:SetValue(s.extraval)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_DECK,0)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	aux.GlobalCheck(s,function()
		s.flagmap={}
	end)
	--place on field
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e6:SetCondition(s.tfcon)
	e6:SetTarget(s.tftg)
	e6:SetOperation(s.tfop)
	c:RegisterEffect(e6)
end
s.listed_series={0xfcf}
function s.runcon(e,c,must,og,min,max)
	if Duel.GetFlagEffect(e:GetHandler(),id)>0 then return false end
	local mt=c:GetMetatable()
	if mt.rune_parameters then
		local rune_table = mt.rune_parameters[1]
		local cond=Rune.Condition(rune_table[1],rune_table[2],rune_table[3],rune_table[4],rune_table[5],rune_table[6],rune_table[8],rune_table[9],rune_table[10],rune_table[11])
		return cond(e,c,must,og,min,max)
	else return false end
end
function s.runtg(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
	local mt=c:GetMetatable()
	local rune_table = mt.rune_parameters[1]
	local target=Rune.Target(rune_table[1],rune_table[2],rune_table[3],rune_table[4],rune_table[5],rune_table[6],rune_table[8],rune_table[10],rune_table[11])
	target(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
end
function s.runop(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
	local mt=c:GetMetatable()
	local rune_table = mt.rune_parameters[1]
	local operation=Rune.Operation(rune_table[1],rune_table[2],rune_table[3],rune_table[4],rune_table[5],rune_table[6],rune_table[8])
	operation(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.sumtg(e,c)
	return c:IsSetCard(0xfcf) and c:IsType(TYPE_RUNE)
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
