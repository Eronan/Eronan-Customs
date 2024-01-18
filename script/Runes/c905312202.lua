--Celsitial Confinement
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    aux.AddPersistentProcedure(c,1,nil,CATEGORY_POSITION,EFFECT_FLAG_DAMAGE_STEP,TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP,s.condition,nil,s.target,s.activate,true)
    --damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.ctcost)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
end
s.listed_series={0xfce}
--activate
function s.cfilter(c)
    return c:IsSetCard(0xfce) and c:IsType(TYPE_RUNE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
   return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chkc,chk)
    if chk==0 then return true end
    if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(function(te,etp,p) return te:GetHandler()~=chkc end)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
        Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)

        --eff
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
        e1:SetReset(RESETS_STANDARD)
        e1:SetCondition(s.tccon)
        e1:SetLabel(c:GetFieldID())
        e1:SetValue(1)
        tc:RegisterEffect(e1)
        --cannot tribute
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UNRELEASABLE_SUM)
        e2:SetValue(1)
        tc:RegisterEffect(e2)
        local e3=e2:Clone()
        e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
        tc:RegisterEffect(e3)
        --Targeted monster cannot be targeted for attack
        local e4=e1:Clone()
        e4:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
        tc:RegisterEffect(e4)
    end
end
function s.tccon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetOwner():GetFieldID()==e:GetLabel()
end
--control
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetCardTarget():GetFirst())
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then
        local tc=e:GetHandler():GetCardTarget():GetFirst()
        return tc and tc:IsControler(1-tp) and tc:IsControlerCanBeChanged()
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetLabelObject(),1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc and tc:IsControler(1-tp) and tc:IsControlerCanBeChanged() then
        Duel.GetControl(tc,tp,PHASE_END,1)
    end
    e:SetLabelObject(nil)
end