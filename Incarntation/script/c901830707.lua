--Incarntation Rites
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,filter=s.ritualfil,lvtype=RITPROC_EQUAL,extraop=s.extraop,extrafil=s.extrafil,location=LOCATION_DECK|LOCATION_PZONE,matfilter=s.mfilter})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
    --if not AshBlossomTable then AshBlossomTable={} end
    --table.insert(AshBlossomTable,e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={0xfea}
function s.ritualfil(c)
    return c:IsSetCard(0xfea)
end
function s.mfilter(c)
    return c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_EXTRA)
end
function s.exfilter0(c)
    return c:IsFaceup() and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_EXTRA,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
    local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
    mg:Sub(mat2)
    Duel.ReleaseRitualMaterial(mg)
    Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
function s.thfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
