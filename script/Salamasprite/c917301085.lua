--Salamasprites
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.AddProcEqual({handler=c,filter=aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),extrafil=s.extrafil,location=LOCATION_HAND+LOCATION_GRAVE,forcedselection=s.ritcheck})
	e1:SetTarget(s.target(e1))
end
s.listed_names={917301099}
function s.mfilter(c)
    return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) and c:HasLevel() and c:IsRace(RACE_PYRO)
        and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
    return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.ritcheck(e,tp,g,sc)
	return (g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==1 and #g==1)
		or g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==0
end
function s.target(eff)
    local tg = eff:GetTarget()
    return function(e,tp,...)
        local ret = tg(e,tp,...)
        if ret then return ret end
        if e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,917301099) then
            Duel.SetChainLimit(s.chlimit)
        end
    end
end
function s.chlimit(e,ep,tp)
    return tp==ep
end
