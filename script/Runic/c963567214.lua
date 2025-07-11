--Sovereign Fang of Zerunic Void
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),2,99,s.stfilter,2,99,nil,s.exgroup,nil,nil,nil,s.customop)
	c:EnableReviveLimit()
	--Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.sumlimit)
	c:RegisterEffect(e1)
    --check materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
    --All your monsters gain 100 ATK/DEF for each "Magician" pendulum monster in your face-up extra deck
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetValue(s.atkval)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e7)
    --Special Summon
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,1))
    e8:SetCategory(CATEGORY_TOEXTRA|CATEGORY_SPECIAL_SUMMON)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e8:SetProperty(EFFECT_FLAG_DELAY)
    e8:SetCode(EVENT_TO_GRAVE|EVENT_REMOVE)
    e8:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e8:SetTarget(s.sptg)
    e8:SetOperation(s.spop)
    c:RegisterEffect(e8)
end
s.listed_series={0xfe3}
--Rune Summon
function s.rune_custom_check(g,rc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_RUNE)
end
function s.stfilter(c,rc,sumtyp,tp)
    return c:IsType(TYPE_PENDULUM,rc,sumtyp,tp) and (c:IsSpellTrap() or c:IsLocation(LOCATION_GRAVE))
        and Rune.IsCanBeMaterial(rc,sumtyp,tp)
end
function s.exgroup(tp,ex,c)
	return Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,ex)
end
function s.customop(g,e,tp,eg,ep,ev,re,r,rp,pc)
    local gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local mg=g-gy
    Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_RUNE)
    Duel.Remove(gy,POS_FACEUP,REASON_MATERIAL+REASON_RUNE)
end
--Summon Limit
function s.sumlimit(e,se,sp,st)
	return aux.runlimit(e,se,sp,st) or se:GetHandler()==e:GetHandler()
end
--material check, cannot be tribute or targeted
function s.mchkfilter(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsSetCard(0xfe3)
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(s.mchkfilter,1,nil) then
		--Cannot be Tributed
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		c:RegisterEffect(e2)
		--cannot be target
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e3:SetValue(aux.tgoval)
		c:RegisterEffect(e3)
	end
end
--attack filter
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,c:GetControler(),LOCATION_EXTRA,0,nil)
	return g:GetClassCount(Card.GetCode)*100
end
--special summon and add to extra
function s.tedfilter(c)
    return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToExtra()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.tedfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tedfilter,tp,LOCATION_REMOVED,0,1,nil) 
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
    local g=Duel.SelectTarget(tp,s.tedfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoExtraP(tc,tp,REASON_EFFECT) then
        --Special Summon
		local c=e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
	end
end
