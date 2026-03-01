--Caraphron Molting
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Can be activated the turn it was set if you control a Caraphron Rune monster
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e0:SetCondition(s.actcon)
    c:RegisterEffect(e0)

    --(1) Tribute 1 Insect monster; negate up to 2 face-up opponent cards until End Phase
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.discost)
    e1:SetTarget(s.distg)
    e1:SetOperation(s.disop)
    c:RegisterEffect(e1)

	--GY: equip from GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end

s.listed_series={0xfc0}

--==========================
--Effect 0: can activate the turn it's set
--==========================
function s.cfilter(c)
    return c:IsSetCard(0xfc0) and c:IsType(TYPE_RUNE) and c:IsFaceup()
end
function s.actcon(e)
    return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--==========================
--Effect 1: Tribute and negate opponent cards
--==========================
function s.disfilter(c)
    return c:IsFaceup() and not c:IsDisabled()
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_INSECT) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_INSECT)
    Duel.Release(g,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.disfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    for tc in aux.Next(tg) do
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)
    end
end

--==========================
--Effect 2: Equip Spell to appropriate Insect monster
--==========================
function s.eqfilter(c,tp)
    return c:IsEquipSpell() and Duel.IsExistingTarget(s.eqcheck,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
function s.eqcheck(c,ec)
    return c:IsRace(RACE_INSECT) and ec:CheckEquipTarget(c)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local mg=Duel.SelectMatchingCard(tp,s.eqcheck,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc)
        if #mg>0 then
            Duel.Equip(tp,tc,mg:GetFirst())
        end
    end
end