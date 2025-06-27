--Apex Ruler of Zerunic Inferno
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),2,2,s.stfilter,2,99,nil,s.exgroup,nil,nil,nil,s.customop)
    c:EnableReviveLimit()
    --Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.runlimit)
	c:RegisterEffect(e1)
    --check materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
    --immune effect
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsEquipSpell))
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)
    --Equip from banishment
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e4:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
end
--Rune Summon
function s.rune_custom_check(g,rc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_RUNE)
end
function s.stfilter(c,rc,sumtyp,tp)
    return c:IsEquipSpell() or (c:IsType(TYPE_UNION,rc,sumtyp,tp) and c:IsLocation(LOCATION_GRAVE))
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
--material check, cannot be tribute or targeted
function s.mchkfilter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsSetCard(0xfe3)
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
--equip spells are immune to effects
function s.efilter(e,re)
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--Equip from banishment
function s.eqtfilter(c,ec)
	return c:IsFaceup() and (ec:CheckEquipTarget(c) or ec:CheckUnionTarget(c))
end
function s.eqfilter(c,e,tp)
	return (c:IsEquipSpell() or c:IsType(TYPE_UNION))
        and Duel.IsExistingMatchingCard(s.eqtfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
        and (c:CheckUniqueOnField(tp) or c:CheckUniqueOnField(1-tp))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.eqfilter(chkc,e,tp) end
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0)
        and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,PLAYER_ALL,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local ec=Duel.SelectMatchingCard(tp,s.eqtfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tc):GetFirst()
    
    local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:CheckUniqueOnField(tp)
    local b2=Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and tc:CheckUniqueOnField(1-tp)
    local op=0
    Duel.Hint(HINT_SELECTMSG,tp,0)
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,2))
	elseif b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
	else return end

	if op==1 then
		Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
	end

    Duel.Equip(tp,tc,ec)
    if tc:IsType(TYPE_UNION) then
        aux.SetUnionState(tc)
    end
end