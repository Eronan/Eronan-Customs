--Celsitial Etherune Armory
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_RUNE))
    --Untargetable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    --Rune Summon
    local re=Rune.CreateSecondProcedure(c,Rune.MonFunction(function (tc,rc,sumtyp,tp) return tc==c:GetEquipTarget() end),1,1,Rune.STFunction(function (tc,rc,sumtyp,tp) return c==tc end),1,1,LOCATION_DECK,nil,nil,s.exchk)
    re:SetDescription(aux.Stringid(id,0))
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_DECK,0)
    e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(re)
	c:RegisterEffect(e3)
    --re-equip
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.eqcon)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
end
s.listed_series={0xfce}
--Rune Summon
function s.exchk(e,tp,chk,mg)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.efcon(e,c)
    local ec=e:GetHandler():GetEquipTarget()
	return ec:IsType(TYPE_RUNE) and ec:IsControler(e:GetHandlerPlayer())
end
function s.eftg(e,c)
    local ec=e:GetHandler():GetEquipTarget()
	return c:IsType(TYPE_RUNE) and c:ListsCode(ec:GetCode()) and c:GetLevel()>ec:GetLevel()
end
--re-equip
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSummonType(SUMMON_TYPE_RUNE) and rc:IsSetCard(0xfce)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
	if chk==0 then return rc:IsOnField() and rc:IsFaceup() end
    rc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetReasonCard()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end
