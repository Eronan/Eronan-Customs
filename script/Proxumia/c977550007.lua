--Proxumia Rift Compression
local s,id=GetID()
function s.initial_effect(c)
    -- Ritual Summon
    local e1=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_EQUAL,
        filter=aux.FilterBoolFunction(Card.IsSetCard,0xfc3),
        extrafil=s.extragroup,
        matfilter=aux.FilterBoolFunction(Card.IsOnField),
        location=LOCATION_HAND|LOCATION_DECK,
        requirementfunc=s.ritual_material_requirement,
        specificmatfilter=s.ritual_specific_requirement,
        forcedselection=s.ritcheck
    })
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)

    -- Shuffle all into the Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH) -- separate once per turn limit
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost) -- banish self as cost
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end
--Ritual Summon
function s.mfilter(c,e)
    return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsReleasable()
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroup(s.mfilter,tp,0,LOCATION_MZONE,nil,e)
end
-- function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,sc)
--     Duel.ReleaseRitualMaterial(mat)
-- end
function s.ritual_material_requirement(c,rc)
    if c:IsSummonLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or c:IsType(TYPE_XYZ)) then
        return Ritual.SummoningLevel
    end
    return aux.RitualCheckAdditionalLevel(c,rc)
end
function s.ritual_specific_requirement(c,rc,mg,tp)
	return s.ritual_material_requirement(c,rc)>0
end
function s.ritcheck(e,tp,g,sc)
    if #g~=1 then return false end
    return sc:IsLocation(LOCATION_HAND) or g:FilterCount(Card.IsControler,nil,tp)==1
end
-- Shuffle all into the Deck
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0xfc3) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0xfc3)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end
