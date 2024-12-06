--Etherune Vortex of Subjugation
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Rune Summon
    local re=Rune.CreateSecondProcedure(c,Rune.MonFunction(s.mnfilter(c)),1,1,Rune.STFunction(function (tc,rc,sumtyp,tp) return c==tc end),1,1,LOCATION_DECK,nil,nil,s.exchk)
    re:SetDescription(aux.Stringid(id,0))
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_DECK,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_R))
	e3:SetLabelObject(re)
	c:RegisterEffect(e3)
    --be material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCondition(s.ccon)
	e4:SetOperation(s.cop)
	c:RegisterEffect(e4)
    --Set to field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e5:SetCondition(s.tfcon)
	e5:SetTarget(s.tftg)
	e5:SetOperation(s.tfop)
	c:RegisterEffect(e5)
end
s.listed_names={918100320}
s.listed_series={0xfce,0xfe3}
--Rune Summon
function s.mnfilter(c)
    return function (tc,rc,sumtyp,tp)
        return c:GetColumnGroup():IsContains(tc) and rc:IsType(TYPE_RUNE) and rc:GetLevel()==tc:GetLevel()+3
            and tc:IsAttribute(rc:GetAttribute()) and tc:IsRace(rc:GetRace())
    end
end
function s.exchk(e,tp,chk,mg)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.eftg(e,c)
	return c:IsType(TYPE_RUNE) and (c:IsSetCard(0xfce) or c:IsSetCard(0xfe3))
end
--be material
function s.ccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSummonType(SUMMON_TYPE_RUNE)
end
function s.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--immune effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)
end
--immune effect
function s.efilter(e,re,rp)
    if not re:IsActiveType(TYPE_MONSTER) then return false end
    local c=e:GetHandler()
    local rc=re:GetHandler()
    if rc:IsAttribute(c:GetAttribute()) then return true end
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local atts=g:GetBitwiseOr(Card.GetAttribute)
    return rc:IsAttribute(atts)
end
--Set to field
function s.tfcfilter(c)
    return c:IsFaceup() and c:IsCode(918100320)
end
function s.tfcon(e,tp)
    return Duel.IsTurnPlayer(tp) and Duel.IsExistingMatchingCard(s.tfcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
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