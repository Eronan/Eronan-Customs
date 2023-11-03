--Inscriber of Mastery, Shujinmoji
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Pendulum.AddProcedure(c)
	Xyz.AddProcedure(c,nil,6,2,nil,nil,99)
	c:EnableReviveLimit()
	--gemini status
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_PZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,928190100))
    e1:SetCode(EFFECT_GEMINI_STATUS)
    c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Extra Material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_EXTRA)
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
	
end
s.listed_names={928190100}
--special summon "Vesta of Parasitic Bloom"
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function s.spfilter(c,e,tp)
	return (c:IsCode(928190100) or c:IsType(TYPE_RUNE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
		--place in pendulum zone
		local c=e:GetHandler()
		if Duel.CheckPendulumZones(tp) and c:IsType(TYPE_PENDULUM)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
--extra material
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	return (not sg or sg:FilterCount(s.flagcheck,nil)<2)
		and e:GetHandler():IsFaceup()
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