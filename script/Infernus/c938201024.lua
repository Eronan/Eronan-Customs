--Shimzu Infernus Sewanin
local s,id=GetID()
function s.initial_effect(c)
    --synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,nil,nil,nil,nil,s.syncheck)
	c:EnableReviveLimit()
    --cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
    --Cannot Special Summon from same Location
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.limcon)
	e2:SetOperation(s.limop)
	c:RegisterEffect(e2)
end
s.listed_names={938201010}
s.listed_series={0xfcf}
--Synchro Summon
function s.syncheck(g,sc,tp)
	return g:IsExists(Card.IsType,sc,TYPE_SYNCHRO|TYPE_RUNE,SUMMON_TYPE_SYNCHRO,tp)
end
--Cannot be target
function s.tgcfilter(c,tp)
    return c:IsControler(tp) and (c:IsCode(938201010) or c:IsSetCard(0xfcf))
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetColumnGroup():IsExists(s.tgcfilter,1,nil,tp)
end
function s.tgtg(e,c)
    local ec=e:GetHandler()
	return ec:GetColumnGroup():IsContains(c)
end
--Cannot Special Summon from same Location
function s.epcfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and not c:IsSummonLocation(LOCATION_ONFIELD)
end
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.epcfilter,1,nil,tp)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
    local location=0
    for tc in aux.Next(g) do
        location=location|tc:GetSummonLocation()
    end
	-- Neither player can Special Summon from the same locations
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
    e1:SetLabel(location)
	e1:SetTarget(function(te,c) return c:IsLocation(te:GetLabel()) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end