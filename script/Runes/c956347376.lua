--Igknight Perseus, Celsitial Hero
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),2,2,Rune.STFunctionEx(Card.IsType,TYPE_PENDULUM),1,1)
    --cannot special summon
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.runlimit)
    c:RegisterEffect(e1)
    --check materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
    --immune effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_IGKNIGHT))
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetLabelObject(e2)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
    --(2) Redirect destruction to face-up Extra Deck
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(s.reptg)
    e4:SetValue(s.repval)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)
    --(3) Banish + Gain ATK
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_REMOVE|CATEGORY_ATKCHANGE)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
    e5:SetCode(EVENT_TO_DECK)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.rmcon)
    e5:SetTarget(s.rmtg)
    e5:SetOperation(s.rmop)
    c:RegisterEffect(e5)
end
s.listed_series={SET_IGKNIGHT}
s.listed_names={956347375}
--material check
function s.matcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(Card.IsCode,1,nil,956347375) then
		e:SetLabel(1)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	end
end
--immune
function s.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetOwnerPlayer() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(e:GetHandler())
end
--(2) Replace destruction with sending FIRE Pendulum to Extra Deck
function s.repcfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(Card.IsControler,1,nil,tp) and Duel.IsExistingMatchingCard(s.repcfilter,tp,LOCATION_HAND,0,1,nil) end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
    return c:IsControler(e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.repcfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.SendtoExtraP(g,tp,REASON_EFFECT)
    end
end
--#region
function s.cfilter(c,tp)
    return c:IsLocation(LOCATION_EXTRA) and c:IsControler(tp)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
        local c=e:GetHandler()
        if c:IsFaceup() and c:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
    end
end