--Tempusloom
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
    --All effects change to apply during the End Phas
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.chcon)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
	--Flip face-down
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetHintTiming(TIMING_END_PHASE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e4:SetCondition(s.rncon)
	e4:SetTarget(s.rntg)
	e4:SetOperation(s.rnop)
	c:RegisterEffect(e4)
end
s.listed_series={0xfcd}
--Activate from hand
function s.handcon(e)
    local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_CHAINING,true)
    if res then
        local tretyp=tre:GetActiveType()
        return (tretyp==TYPE_SPELL or tretyp==TYPE_TRAP) and trp~=e:GetHandlerPlayer()
    end
end
--replace effect
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return re:IsSpellTrapEffect() and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
        and re:GetOperation() and not Duel.IsPhase(PHASE_END)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeChainOperation(ev,s.repop(re))
end
function s.repop(te)
    return function(e,tp,eg,ep,ev,re,r,rp)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        local condition=function (ne,ntp,neg,nep,nev,nre,nr,nrp) return not te:GetTarget() or te:GetTarget()(ne,tp,eg,ep,ev,re,r,rp,0) end
        local operation=function (ne,ntp,neg,nep,nev,nre,nr,nrp)
            Duel.Hint(HINT_CARD,1-te:GetHandlerPlayer(),te:GetHandler():GetCode())
			Duel.SetTargetPlayer(p)
            Duel.SetTargetParam(d)
			ne:GetHandler():CreateEffectRelation(ne)
            te:GetOperation()(ne,tp,eg,ep,ev,re,r,rp)
        end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetLabel(te:GetLabel())
        e1:SetLabelObject(te:GetLabelObject())
        e1:SetCondition(condition)
        e1:SetOperation(operation)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,te:GetHandlerPlayer())
    end
end
--rune summon
function s.rncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END
end
function s.rnfilter(c,tp)
    return c:IsRuneSummonable() and c:IsSetCard(0xfcd)
end
function s.rntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rnfilter,tp,0x3ff~LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x3ff~LOCATION_MZONE)
end
function s.rnop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.rnfilter,tp,0x3ff~LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local sc=g:Select(tp,1,1,nil):GetFirst()
		Duel.RuneSummon(tp,sc)
	end
end
