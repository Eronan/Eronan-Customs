--Subshifter Metamorphosis
local s,id=GetID()
function s.initial_effect(c)
    --Fusion
    local e1=Fusion.CreateSummonEff({handler=c,filter=aux.FilterBoolFunction(Card.IsSetCard,0xfd5),desc=aux.Stringid(id,0)})
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCost(s.costhint)
    c:RegisterEffect(e1)
    --Ritual
    local e2=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0xfd5),
		matfilter=aux.FilterBoolFunction(Card.IsLocation,LOCATION_HAND+LOCATION_DECK),extrafil=s.extragroup,extraop=s.extraop,forcedselection=s.ritcheck})
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCost(s.costhint)
    c:RegisterEffect(e2)
end
s.listed_series={0xfd5}
function s.costhint(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.matfilter1(c)
	return c:IsAbleToGrave() and c:IsLevelAbove(1)
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_DECK,0,nil)
end
function s.ritcheck(e,tp,g,sc)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
