--Absolute Shroudis Control
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunction(nil),1,1,Rune.STFunction(nil),1,1,LOCATION_GRAVE,nil,nil,s.runchk)
    --Place "Shroudis" Link monster as Link Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.plcost)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
end
s.listed_series={0xfd1}
--Rune Summon
function s.runchk(e,tp,chk,mg)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
--Place "Shroudis" Link monster as Link Spell
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.plfilter(c,tp)
	return c:IsSetCard(0xfd1) and c:IsLinkMonster()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            --Treat it as a Link Spell
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetValue(TYPE_SPELL|TYPE_LINK)
            e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
            tc:RegisterEffect(e1)
        end
    end
end
