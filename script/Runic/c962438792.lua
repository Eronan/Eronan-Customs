--Unbound Serpent of Zerunic Plantations
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),2,99,Rune.STFunctionEx(Card.IsContinuousTrap),2,99,nil,s.exgroup,nil,nil,nil,s.customop)
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
    --cannot be target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.tgtg)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
    --Attach top deck card during the Standby Phase
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
--Rune Summon
function s.rune_custom_check(g,rc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_RUNE)
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
    return c:IsRace(RACE_WYRM) and c:IsSetCard(0xfe3)
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
--Cannot target other cards
function s.tgtg(e,c)
	return c~=e:GetHandler()
end
--Add to hand
function s.thfilter(c)
    return c:IsContinuousTrap() and c:IsFaceup() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT) then
        --Can activate Traps from your hand with the same name
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetTargetRange(LOCATION_HAND,0)
        e1:SetLabel(tc:GetCode())
        e1:SetTarget(s.acttg)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.acttg(e,c)
    return c:IsCode(e:GetLabel())
end
