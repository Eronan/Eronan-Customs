--Ekhoir Encore
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
local SET_EKHOIR=0xffd
function s.initial_effect(c)
    --Activate 1 of these effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCost(aux.RemainFieldCost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
--Filters
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_EKHOIR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tribute_filter(c,tp)
	return Duel.GetMZoneCount(tp,c)>0
end
--Target function
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local option1=not Duel.HasFlagEffect(tp,id) and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    local option2=not Duel.HasFlagEffect(tp,id+1) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    if chk==0 then return option1 or option2 end

    --Select effect
    local op=Duel.SelectEffect(tp,
        {option1,aux.Stringid(id,1)},
        {option2,aux.Stringid(id,2)})
    e:SetLabel(op)
    
    --Handle costs/targets immediately
    if op==1 then
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
        --Effect 1: tribute 1 monster from your MZONE
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp)
	    Duel.Release(g,REASON_COST)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    elseif op==2 then
        Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
        --Effect 2: target 1 Ekhoir in GY to summon + equip
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,LOCATION_GRAVE)
        Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,LOCATION_GRAVE)
    end
end

--Operation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    local c=e:GetHandler()
    local op=e:GetLabel()
    if op==1 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetRange(LOCATION_SZONE)
        e1:SetCountLimit(1)
        e1:SetCondition(s.descon)
        e1:SetOperation(s.desop)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        c:RegisterEffect(e1)

        --Cannot be destroyed
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e2:SetRange(LOCATION_SZONE)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetTarget(aux.PersistentTargetFilter)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        e2:SetValue(1)
        c:RegisterEffect(e2)
        local e3=e2:Clone()
        e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        c:RegisterEffect(e3)

        --Effect 1: Special Summon up to 2 monsters from GY
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,math.min(2,ft),nil,e,tp)
        
        for tc in aux.Next(tg) do
            if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
                --Link monster to Trap for later destruction
                c:SetCardTarget(tc)
            end
        end
        Duel.SpecialSummonComplete()
    elseif op==2 then
        --Effect 2: Special Summon + Equip
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
            if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
            Duel.Equip(tp,c,tc)
            --Add Equip limit
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            e1:SetValue(s.eqlimit)
            e1:SetLabelObject(tc)
            c:RegisterEffect(e1)
            --Add Equip effects
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_EQUIP)
            e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e2:SetValue(1)
            e2:SetReset(RESET_EVENT|RESETS_STANDARD)
            c:RegisterEffect(e2)
            local e3=e2:Clone()
            e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            c:RegisterEffect(e3)
        elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
            c:CancelToGrave(false)
        end
    end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Destroy(e:GetHandler(),REASON_EFFECT) then e:Reset() end
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end