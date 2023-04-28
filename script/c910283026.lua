--Virutalia Designation
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreater({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0xfde),extrafil=s.extrafil,stage2=s.ritop,matfilter=aux.FilterBoolFunction(Card.IsOnField),forcedselection=s.ritcheck,requirementfunc=s.ritrequirement,location=LOCATION_HAND+LOCATION_GRAVE})
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_names={910283020}
s.listed_series={0xfde}
function s.mfilter(c,e)
    return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsReleasable()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroup(s.mfilter,tp,0,LOCATION_MZONE,nil,e)
end
--Equip Filter
function s.eqfilter(c,rc)
	return c:IsCode(910283020) and c:IsType(TYPE_UNION)
		and c:CheckUnionTarget(rc) and aux.CheckUnionEquip(c,rc)
end
function s.ritop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	--Equip "Virutalia"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tc)
	local ec=g:GetFirst()
	if ec and aux.CheckUnionEquip(ec,tc) and Duel.Equip(tp,ec,tc) then
		aux.SetUnionState(ec)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
function s.ritcfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(910283020)
end
function s.ritcheck(e,tp,g,sc)
	local oppcount=g:FilterCount(Card.IsControler,nil,1-tp)
	return (oppcount<=1 and g:IsExists(s.ritcfilter,1,nil,tp))
		or oppcount==0
end
function s.ritrequirement(c,rc)
	if c:GetRitualLevel(rc)>0 then return aux.RitualCheckAdditionalLevel(c,rc)
	elseif c:GetRank()>0 then return c:GetRank()
	elseif c:GetLink()>0 then return c:GetLink()
	else return 0 end
end
function s.cfilter(c,tp)
	return c:IsCode(910283020) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
	--Activation legality
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
	--Set itself back to S/T zone, banish it if it leaves the field
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
