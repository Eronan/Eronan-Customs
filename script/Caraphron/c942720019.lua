--Caraphron CelsiMusca Sigmoth Queen
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon procedure
    c:EnableReviveLimit()
    Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsRace,RACE_INSECT),2,2,Rune.STFunction(nil),2,99)
    --must rune summon
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.runlimit)
	c:RegisterEffect(e0)
    
    --Check material
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_MATERIAL_CHECK)
    e1:SetLabel(2) --Default maximum of equip cards to select
    e1:SetValue(s.valcheck)
    c:RegisterEffect(e1)

    --(1) Equip on Rune Summon or sent to GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    e2:SetCountLimit(1,id)
    e2:SetLabelObject(e1)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2b:SetCondition(s.eqcon)
    c:RegisterEffect(e2b)

    --(2) Send 1 Equip Spell to send 1 card on field to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e3:SetCost(s.tgcost)
    e3:SetTarget(s.tgtg)
    e3:SetOperation(s.tgop)
    e3:SetCountLimit(1,{id,1})
    c:RegisterEffect(e3)

    --(3) Tribute 1 monster; banish up to 2 from opponent's GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e4:SetCost(s.rmcost)
    e4:SetTarget(s.rmtg)
    e4:SetOperation(s.rmop)
    e4:SetCountLimit(1,{id,2})
    c:RegisterEffect(e4)
end
s.listed_series={0xfc0}
s.listed_names={942720012} --Caraphron Sigmoth
--(0) Check if Sigmoth was used as material
function s.valcheck(e,c)
    local mg=c:GetMaterial()
    if mg:IsExists(Card.IsCode,1,nil,942720012) then
        --Equip 3 cards maximum if Sigmoth was used as material
        e:SetLabel(3)
    else
        -- Equip 2 cards maximum otherwise
        e:SetLabel(2)
    end
end

--(1) Equip on Rune Summon or sent to GY
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_RUNE)
end

function s.eqfilter(c)
    return c:IsSetCard(0xfc0) and not c:IsForbidden()
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,LOCATION_DECK|LOCATION_GRAVE)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- Get upper maximum of equip cards to select
    local stct=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if stct<=0 then return end
    local max=e:GetLabelObject():GetLabel()
    max=math.min(max,stct)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,max,nil)

    for tc in aux.Next(g) do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local ec=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
        if ec then
            Duel.Equip(tp,tc,ec,true)

            -- Equip limit so it stays attached
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(function(e,c) return c==ec end)
            tc:RegisterEffect(e1)
        end
    end
end

--(2) Cost: Send Equip Spell
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsEquipSpell,tp,LOCATION_SZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsEquipSpell,tp,LOCATION_SZONE,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    Duel.SelectTarget(tp,Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

--(3) Cost: Tribute 1 monster
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,nil) end
    local sg=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,nil)
    Duel.Release(sg,REASON_COST)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local sg=g:Filter(Card.IsRelateToEffect,nil,e)
    if #sg>0 then
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    end
end