--Nuclithoforge Crystal Core
local s,id=GetID()
function s.initial_effect(c)
    --Place in Spell & Trap instead of destroying
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.reptg)
    e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
    --to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    --place on field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.tfcon)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfc8}
--Place monster as Continuous Spell
function s.dfilter(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.dfilter,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    if not Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then return false end
    local g=eg:Filter(s.dfilter,nil,tp)
    local sg=g
    if #g>1 then
        local max=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),#g)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        sg=g:Select(tp,1,max,nil)
    end
    e:SetLabelObject(sg)
    sg:KeepAlive()
	return true
end
function s.repval(e,c)
	return e:GetLabelObject():IsContains(c)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local sg=e:GetLabelObject()
    for tc in aux.Next(sg) do
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        --Treated as a Continuous Spell
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
        tc:RegisterEffect(e1)
    end
    sg:DeleteGroup()
    e:SetLabelObject(nil)
end
--to hand
function s.thfilter(c)
    return c:IsFaceup() and c:IsSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
--place on field
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetHandler():GetReasonCard()
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsLocation(LOCATION_GRAVE) and c:CheckUniqueOnField(tp)
        and rc:IsSummonType(SUMMON_TYPE_RUNE) and rc:IsSetCard(0xfc8)
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
