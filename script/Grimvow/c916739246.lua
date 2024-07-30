--Curse of Grimvow Greed
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    aux.AddEquipProcedure(c)
    --Add counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
    --
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_MUST_BE_MATERIAL)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetCondition(s.mandmatcon)
    e3:SetValue(REASON_FUSION|REASON_SYNCHRO|REASON_XYZ|REASON_LINK|REASON_RUNE)
    --Grant the above effect to an Xyz Monster equipped with this card
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(function(e,tc) return e:GetHandler():GetEquipTarget()==tc end)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
    --Equip Spell to opponent's monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(function(e) return c:IsLocation(LOCATION_GRAVE) and c:GetEquipTarget()~=nil end)
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_TO_GRAVE)
    e6:SetCondition(s.eqcon)
    c:RegisterEffect(e6)
end
--Draw after activating effect
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    if not rc or rc~=c:GetEquipTarget() then return end
    c:RegisterFlagEffect(id)
    local ec=c:GetEquipTarget()
    ec:RegisterFlagEffect(id)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=e:GetHandler():GetEquipTarget()
    local rc=re:GetHandler()
    if c:GetFlagEffect(id)>0 and rc and rc==ec then
        Duel.Draw(1-ec:GetControler(),1,REASON_EFFECT)
    end
end
--Must be material
function s.mandmatcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)==0
end
--Equip from GY to opponent's monster
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetEquipTarget()~=nil or (c:IsReason(REASON_EFFECT) and rp==1-tp)
end
function s.tcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
function s.ecfilter(c,tp)
	return c:IsType(TYPE_EQUIP) and not c:IsCode(id)
        and Duel.IsExistingMatchingCard(s.tcfilter,tp,0,LOCATION_MZONE,1,nil,c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.ecfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.ecfilter,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local g=Duel.SelectTarget(tp,s.ecfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local ec=g:GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,ec,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local ec=Duel.GetFirstTarget()
    if not ec or not ec:IsRelateToEffect(e) then return end
    local tc=Duel.SelectMatchingCard(tp,s.tcfilter,tp,0,LOCATION_MZONE,1,1,nil,ec):GetFirst()
    Duel.Equip(tp,ec,tc)
end
