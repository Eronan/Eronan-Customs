--Virutali Takeover
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0xfde),extrafil=s.extrafil,matfilter=aux.FilterBoolFunction(Card.IsOnField),location=LOCATION_HAND+LOCATION_DECK,forcedselection=s.ritcheck,requirementfunc=s.ritrequirement})
	e1:SetTarget(s.target(e1))
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0xfde}
function s.target(eff)
    local tg = eff:GetTarget()
    return function(e,...)
        local ret = tg(e,...)
        if ret then return ret end
        if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
            Duel.SetChainLimit(s.chlimit)
        end
    end
end
function s.chlimit(e,ep,tp)
    return tp==ep
end
function s.mfilter(c,e)
    return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsReleasable()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroup(s.mfilter,tp,0,LOCATION_MZONE,nil,e)
end
function s.ritcfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0xfde)
end
function s.ritcheck(e,tp,g,sc)
	local oppcount=g:FilterCount(Card.IsControler,nil,1-tp)
	return (oppcount<=1 and g:IsExists(s.ritcfilter,1,nil,tp))
		or oppcount==0
end
function s.ritrequirement(c,rc)
	if c:GetRitualLevel(rc)>0 then
		return aux.RitualCheckAdditionalLevel(c,rc)
	elseif c:GetRank()>0 then
		return c:GetRank()
	elseif c:GetLink()>0 then
		return c:GetLink()
	else
		return 0
	end
end
