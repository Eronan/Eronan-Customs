--Caraphron Larvion
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --turn 0 special summon effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- effect 1 prompt
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.lscon)
    e1:SetCost(s.lscost)
    e1:SetTarget(s.lstg)
    e1:SetOperation(s.lsop)
    c:RegisterEffect(e1)

    --effect negation recovery
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1)) -- effect 2 prompt
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAIN_DISABLED)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost) -- banish self from GY as cost
    e2:SetCondition(s.reccon)
    e2:SetTarget(s.rectg)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)
end
s.listed_series={0xfc0}
s.listed_names={942720011} -- "Caraphron Chrysalith"
--====================
--Turn 0 special summon
--====================
function s.lsfilter(c,tp)
    return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
end
function s.lscon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.lsfilter,1,nil,tp) and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
        and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.lscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not e:GetHandler():IsPublic() end
    Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.lkfilter(c,ec,tp)
	return c:IsCode(942720011)
		and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
		and c:IsLinkSummonable(ec,ec)
end
function s.lstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        local c=e:GetHandler()
		return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,c,tp)
	end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,c,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.LinkSummon(tp,tc,c,c,1,1)
	end
end
--====================
--Effect negation recovery
--====================
function s.rune_filter(c)
    return c:IsRace(RACE_INSECT) and c:IsType(TYPE_RUNE)
end

function s.equip_filter(c)
    return c:IsEquipSpell()
end

function s.reccon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc:IsSetCard(0xfc0)
end

function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.rune_filter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.equip_filter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.rune_filter,tp,LOCATION_DECK,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,s.equip_filter,tp,LOCATION_DECK,0,1,1,nil)
    g1:Merge(g2)
    Duel.SendtoGrave(g1,REASON_EFFECT)
end
