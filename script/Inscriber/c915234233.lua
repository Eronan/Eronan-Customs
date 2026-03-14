--Inscriber Mizumoji, Saqa of Charybdis
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local INSCRI_SETCODE=0xff0
local CARD_MIZUMOJI=915234232

function s.initial_effect(c)
    --pendulum summon
	Pendulum.AddProcedure(c)
    -- Standard Rune Summon: 2+ monsters + 2+ "Inscri-" Spell/Trap
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunction(aux.TRUE),2,99,Rune.STFunctionEx(Card.IsSetCard,INSCRI_SETCODE),2,99,LOCATION_PZONE)

    --Summon Limit
    local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.runlimit)
    c:RegisterEffect(e0)

    --------------------------------------------------
    -- [Pendulum Effect]
    -- (P2) If you would Rune Summon an "Inscri-" monster from your Extra Deck,
    --      you can also use another Pendulum monster in your Extra Deck as material.
    --------------------------------------------------
    local ep2=Effect.CreateEffect(c)
    ep2:SetType(EFFECT_TYPE_FIELD)
    ep2:SetCode(EFFECT_EXTRA_MATERIAL)
    ep2:SetRange(LOCATION_PZONE)
    ep2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ep2:SetTargetRange(1,0)
    ep2:SetValue(s.extval)
    c:RegisterEffect(ep2)

    --------------------------------------------------
    -- [Monster Effect]
    -- (1) If Rune Summoned using "Inscriber Mizumoji" as material:
    --     gain 1 additional Pendulum Summon this Main Phase. HOPT.
    --------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_MATERIAL_CHECK)
    e1:SetValue(s.matcheck)
    c:RegisterEffect(e1)

    --------------------------------------------------
    -- (2) If opponent Special Summons a monster(s):
    --     Change all to DEF; if not banished this turn, banish those not changed.
    --------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetCategory(CATEGORY_POSITION+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(s.sstg)
    e2:SetOperation(s.ssop)
    c:RegisterEffect(e2)
end

s.listed_series={INSCRI_SETCODE}
s.listed_names={CARD_MIZUMOJI}

--------------------------------------------------
-- Pendulum Extra Material: allow Pendulum monster from Extra Deck as material
-- when Rune Summoning an "Inscri-" monster from Extra Deck
--------------------------------------------------
function s.extval(chk,summon_type,e,...)
    local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(INSCRI_SETCODE) or not sc:IsType(TYPE_RUNE) then
			return Group.CreateGroup()
		else
            table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_PENDULUM)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE==SUMMON_TYPE_RUNE and #sg>0 and c:GetFlagEffect(id)==0 then
			Duel.Hint(HINT_CARD,tp,id)
            c:RegisterFlagEffect(id,RESET_EVENT+RESET_CHAIN,0,1)
		end
    elseif chk==2 then
		for _,eff in ipairs(s.flagmap[c]) do
			eff:Reset()
		end
		s.flagmap[c]={}
	end
end

--------------------------------------------------
-- (1) Material check: grant additional Pendulum Summon if self was material
--------------------------------------------------
function s.matcheck(e,c)
    local g=c:GetMaterial()
    if g:IsExists(function(tc) return tc:IsCode(CARD_MIZUMOJI) end,1,nil) then
        --Create additional Pendulum Summon effect
        local extra_pendulum_effect=Pendulum.CreateAdditionalPendulumSummonEffect(c,aux.TRUE,LOCATION_HAND|LOCATION_EXTRA,aux.Stringid(id,2),id,RESETS_STANDARD_PHASE_END)
        --Grant the above effect to cards in your Pendulum Zones
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(LOCATION_SZONE,0)
        e1:SetCondition(function(te) return Pendulum.PlayerCanGainAdditionalPendulumSummon(te:GetHandlerPlayer(),id) end)
        e1:SetTarget(function(te,tc) return tc:IsLocation(LOCATION_PZONE) end)
        e1:SetLabelObject(extra_pendulum_effect)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
        c:RegisterEffect(e1)
        --Create an equivalent effect for "Harmonic Oscillation"
        local harmonic_effect=Pendulum.CreateHarmonicOscillationEffect(c,aux.TRUE,aux.Stringid(id,2),id)
        --Grant the above effect to cards in your opponent's Pendulum Zones
        local e2=e1:Clone()
        e2:SetTargetRange(0,LOCATION_SZONE)
        e2:SetLabelObject(harmonic_effect)
        c:RegisterEffect(e2)
    end
end

--------------------------------------------------
-- (2) Opponent Special Summons → change to DEF, banish those not changed
--------------------------------------------------
function s.ssfilter(c,tp)
    return c:IsSummonPlayer(1-tp) and c:IsAttackPos()
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.ssfilter,1,nil,tp) end
    local g=eg:Filter(s.ssfilter,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.ssfilter,nil,tp)

    -- Change to Defence Position.
    if #g==0 then return end
    Duel.ChangePosition(g,POS_FACEUP_DEFENSE)

    -- Banish what was not changed to Defence Position.
    local c=e:GetHandler()
    if c:GetFlagEffect(id)>0 then return end
    local rg=g:Filter(Card.IsAttackPos,nil)
    if #rg==0 then return end
    if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT) then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end