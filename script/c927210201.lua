--Catenicorum Shadow
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Extra Rune Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_DECK,0)
	e2:SetTarget(s.eftg)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		s.flagmap={}
	end)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfcf}
--extra material
function s.eftg(e,c)
	return c:IsSetCard(0xfcf) and c:IsSpellTrap() and c:IsCanBeRuneMaterial()
end
function s.extrafilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	if tp==nil then return true end
	if c==rc then return false end
	local ct=sg:FilterCount(s.flagcheck,nil)
	return Duel.GetFlagEffect(tp,id)==0 and sg:Filter(s.extrafilter,nil,e:GetHandlerPlayer()):IsExists(Card.IsCode,1,og,id) and ct<2
end
function s.flagcheck(c)
	return c:GetFlagEffect(id)>0
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfcf) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			s.flagmap[c]=c:RegisterFlagEffect(id,0,0,1)
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE==SUMMON_TYPE_RUNE and #sg>0 and Duel.GetFlagEffect(tp,id)==0 then
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
--to hand
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and rc:IsSummonType(SUMMON_TYPE_RUNE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end