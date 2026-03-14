--Etherune Saqa - Legend Mantle
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_SAQA=0xfbe
function s.initial_effect(c)
    -- Activate (Continuous Trap)
    -- Can be activated the turn it is Set when you Rune Summoned exactly 1 Level 9 or lower monster
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetTarget(s.acttg)
    e0:SetOperation(s.actop)
    c:RegisterEffect(e0)

    --------------------------------------------------
    -- (2) While face-up: opponent cannot target cards you control
    --     except the summoned monster
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetTarget(s.notgtfilter)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    --------------------------------------------------
    -- (3) When summoned monster leaves field: destroy this card
    --------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.leavecon)
    e3:SetOperation(function(e) Duel.Destroy(e:GetHandler(),REASON_EFFECT) end)
    c:RegisterEffect(e3)

    --------------------------------------------------
    -- (4) When this card leaves field: double summoned monster's ATK until End Phase
    --------------------------------------------------
    --When this card leaves the field, destroy that monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(function(e) e:SetLabel(e:GetHandler():IsDisabled() and 1 or 0) end)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetOperation(s.selfleaveop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)

    --Can be activated the turn it was Set
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,0))
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e6:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e6:SetCondition(s.actcon)
    c:RegisterEffect(e6)
end


--------------------------------------------------
-- Source: any Rune monster the controller controls (face-up)
--------------------------------------------------
function s.mustbematerialsallowed(tp,mg)
	local pg=aux.GetMustBeMaterialGroup(tp,mg,tp,nil,nil,REASON_RUNE)
	if #pg>#mg then return false
	elseif #pg==#mg then return pg:Equal(mg)
	elseif #pg==0 then return true
	elseif #pg==1 then return mg:IsContains(pg:GetFirst())
	else return not mg:IsExists(function (c) return not pg:IsContains(c) end,1,nil) end
end
function s.matfilter(c,e,tp)
    return s.mustbematerialsallowed(tp,Group.FromCards(c)) and c:IsType(TYPE_RUNE) and c:IsFaceup()
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,mc)
    return c:IsType(TYPE_RUNE) and c:IsSetCard(SET_SAQA) and c:GetLevel()>mc:GetLevel() and c:IsRace(mc:GetRace())
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RUNE,tp,false,true) and c:IsRuneCustomCheck(Group.FromCards(mc),tp)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.matfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) then return end
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not c:IsControler(tp) or c:IsImmuneToEffect(e) then return end
	local mg=Group.FromCards(tc)
	if not mg:IsContains(tc) or not s.mustbematerialsallowed(tp,mg) then
		mg:DeleteGroup()
		return
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(mg)
		Duel.SendtoGrave(mg,REASON_EFFECT+REASON_MATERIAL+REASON_RUNE)
		Duel.SpecialSummon(sc,SUMMON_TYPE_RUNE,tp,tp,false,true,POS_FACEUP)
        c:SetCardTarget(sc)
		sc:CompleteProcedure()
	end
	mg:DeleteGroup()
end

--------------------------------------------------
-- (2) Targeting protection: all your cards EXCEPT the summoned monster
--------------------------------------------------
function s.notgtfilter(e,tc)
    return tc~=e:GetHandler():GetFirstCardTarget()
end

--------------------------------------------------
-- (3) Summoned monster leaves field → destroy this card
--------------------------------------------------
function s.leavecon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end

--------------------------------------------------
-- (4) This card leaves field → double summoned monster's ATK until End Phase
--------------------------------------------------
function s.selfleaveop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabelObject():GetLabel()~=0 then return end
    local c=e:GetHandler()
    local tc=c:GetFirstCardTarget()
    if not tc or tc:IsFacedown() then return end
    local atk=tc:GetAttack()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(atk)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
end

--------------------------------------------------
-- Activate on the turn it was Set if a monster was Rune Summoned
--------------------------------------------------
function s.actcon(e)
    local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
    if res and #teg==1 then
        local tc=teg:GetFirst()
        return tc:IsSummonType(SUMMON_TYPE_RUNE) and tc:IsControler(e:GetHandlerPlayer()) and tc:IsLevelBelow(9)
    end
end