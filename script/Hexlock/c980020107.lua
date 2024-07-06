--Hexlocked Puppetry
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(aux.PersistentTgCon)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
    --control
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(aux.PersistentTargetFilter)
	e3:SetValue(s.tg)
	c:RegisterEffect(e3)
	--cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e4)
	--cannot activate
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_TRIGGER)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e5)
    --Cannot be material
    local e6=e3:Clone()
    e6:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e6:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
    c:RegisterEffect(e6)
    --Rune Summon from Deck
    local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_RUNE_LOCATION)
    e7:SetRange(LOCATION_SZONE)
	e7:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfc7))
    e7:SetTargetRange(LOCATION_DECK,0)
    e7:SetValue(function (e,tp,sg,rc) return sg:IsContains(e:GetHandler()) end)
    c:RegisterEffect(e7)
    --Take Control on Summon
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetCategory(CATEGORY_CONTROL)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	e8:SetRange(LOCATION_GRAVE)
    e8:SetCost(aux.bfgcost)
	e8:SetTarget(s.cttg)
	e8:SetOperation(s.ctop)
	c:RegisterEffect(e8)
    --act in hand
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e9:SetCondition(s.handcon)
	c:RegisterEffect(e9)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_END)
		ge2:SetOperation(s.regop)
        ge1:SetLabelObject(ge2)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_series={0xfc7}
--Activate
function s.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetRange(LOCATION_SZONE)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
        e1:SetCondition(s.descon)
        e1:SetOperation(s.desop)
        e1:SetLabel(0)
        e1:SetLabelObject(tc)
        c:RegisterEffect(e1)
	end
end
--Destroy on 2nd End Phase
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	e:GetHandler():SetTurnCounter(ct+1)
	if ct==1 then
		Duel.Destroy(e:GetHandler(),REASON_RULE)
	else e:SetLabel(1) end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):GetFirst()
	if c:IsRelateToEffect(re) and tc and tc:IsRelateToEffect(re) then
		c:SetCardTarget(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_OWNER_RELATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetCondition(s.con)
		tc:RegisterEffect(e1)
	end
end
--Control
function s.con(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
function s.tg(e,c)
	return e:GetHandlerPlayer()
end
--Take Control on Summon
function s.ctfilter(c,e,tp)
    return c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_EXTRA)
        and c:IsControlerCanBeChanged() and c:IsCanBeEffectTarget(e)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return eg:IsExists(s.cfilter,1,nil,e,1-tp) and rp==1-tp end
    local g=eg:Filter(s.ctfilter,nil,e,1-tp)
    local tc=g:GetFirst()
    if #g>1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
        tc=g:Select(tp,1,1,nil):GetFirst()
    end
    Duel.SetTargetCard(tc)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END|RESET_SELF_TURN,1) then
        --Negate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
    end
end
--activate card from hand
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.handcon(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if eg:IsExists(s.cfilter,1,nil,rp) then
        s[1-rp]=1
    end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if s[0]>0 then
		s[0]=0
		Duel.RegisterFlagEffect(0,id,RESET_CHAIN,0,0)
	end
	if s[1]>0 then
		s[1]=0
		Duel.RegisterFlagEffect(1,id,RESET_CHAIN,0,0)
	end
end