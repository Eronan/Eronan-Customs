--Elysiance Melody
local s,id=GetID()
function s.initial_effect(c)
    --Ritual Summon
    Ritual.AddProcGreater({
        handler=c,
        filter=s.ritualfil,
        location=LOCATION_HAND|LOCATION_EXTRA,
        lv=s.getscale,
        requirementfunc=s.getscale,
        forcedselection=s.exselect,
        matfilter=s.matfilter,
        extrafil=s.extrafil,
        extraop=s.extraop
    })
    --Set itself from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
end
--Ritual Summon
function s.ritualfil(c)
	return c:IsType(TYPE_PENDULUM) and c:IsRitualMonster()
end
function s.getscale(c)
    local lscale=c:GetLeftScale()
    local rscale=c:GetRightScale()
    return math.max(lscale,rscale)
end
function s.matfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_PENDULUM) and s.getscale(c)>0 and c:IsDestructable(e)
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD,0,nil,e)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(mg,REASON_EFFECT)
end
function s.exselect(e,tp,sg,sc)
    return sc:IsLocation(LOCATION_HAND) or Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
end
--Set itself from GY
function s.setcfilter(c,tp)
	return c:IsRitualMonster() and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
        and eg:IsExists(s.setcfilter,1,nil,tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp,c)
    end
end