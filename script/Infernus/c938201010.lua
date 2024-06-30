--Infernus, Armor of Storm
local s,id=GetID()
function s.initial_effect()
    aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),false)
    --cannot be synchro material
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(s.synlimit)
    c:RegisterEffect(e1)
    --immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
    --Send 1 Normal Trap from the Deck to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO end)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
--synchro limit
function s.synlimit(e,c)
    if not c then return false end
    return c:GetLevel()%2==1
end
--immune
function s.efilter(e,re)
    local ec=e:GetHandler():GetEquipTarget()
	if e:GetHandlerPlayer()==re:GetOwnerPlayer() or not ec then return false end
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(ec)
end
--equip
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local sync=c:GetReasonCard()
    if not sync or sync:IsFacedown() or not sync:IsLocation(LOCATION_MZONE) or sync:IsControler(1-tp) then return end
    if c:IsRelateToEffect(e) and Duel.Equip(tp,c,sync) then
        aux.SetUnionState(c)
        --Cannot be Special Summoned this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
    end
end