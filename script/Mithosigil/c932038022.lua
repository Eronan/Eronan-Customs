--Mithosigil Mountains
local s,id=GetID()
if not Rune then Duel.LoadScript("proc_rune.lua") end
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.reg)
	c:RegisterEffect(e1)
    --Rune Summon from Deck
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_RUNE_LOCATION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfc4))
    e2:SetTargetRange(LOCATION_DECK,0)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e2)
    --Cannot target or destroyed by card effects
    local e3=Effect.CreateEffect(c)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(aux.indoval)
    c:RegisterEffect(e4)
    --Destroy 1 card opponent controls
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY|CATEGORY_RECOVER)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
s.listed_names={932038020}
s.listed_series={0xfc4}
--Activate
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_OATH,1)
end
--Destroy 1 card opponent controls
function s.spconfilter(c,tp,rp)
	return c:IsSetCard(0xfc4) and c:IsPreviousPosition(POS_FACEUP)
        and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp,rp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e)
        and Duel.Destroy(tc,REASON_EFFECT) then
        Duel.BreakEffect()
        Duel.Recover(tp,500,REASON_EFFECT)
	end
end