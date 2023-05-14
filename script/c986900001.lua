--Dynachantment Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
	--inactivatable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.inactcon)
	e2:SetValue(s.effectfilter)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_DISEFFECT)
	c:RegisterEffect(e3)
	--fusion summon
	local params={s.fusfilter}
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCost(s.cost)
	e4:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e4:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e4)
end
s.listed_series={0xfe5}
s.listed_names={986900019}
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,986900019,0xfe5,TYPES_TOKEN,500,1850,3,RACE_FAIRY,ATTRIBUTE_FIRE)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0))then
		local token=Duel.CreateToken(tp,986900019)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local c=e:GetHandler()
		token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,0)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTarget(s.splimit)
		e2:SetLabelObject(token)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_MUST_BE_MATERIAL)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
		e3:SetValue(REASON_SYNCHRO+REASON_XYZ+REASON_LINK)
		token:RegisterEffect(e3)
		Duel.SpecialSummonComplete()
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return (sumtype==SUMMON_TYPE_SYNCHRO or sumtype==SUMMON_TYPE_XYZ or sumtype==SUMMON_TYPE_LINK) and e:GetLabelObject():GetFlagEffect(id)==0
end
function s.inactcon(e)
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsCode,Card.IsFaceup),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,986900019)
end
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0xfe5) and loc&LOCATION_MZONE~=0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.fusfilter(c,tp)
	return c:IsSetCard(0xfe5) or Duel.IsExistingMatchingCard(aux.AND(Card.IsCode,Card.IsFaceup),tp,LOCATION_MZONE,0,1,nil,986900019)
end
