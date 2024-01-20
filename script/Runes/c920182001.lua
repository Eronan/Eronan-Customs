--Snake-Eyes Pyrostellar CelsiDraco
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
    --Rune Summon
	Rune.AddProcedure(c,Rune.MonFunction(s.mfilter),1,1,Rune.STFunctionEx(Card.IsContinuousSpell),2,99)
	c:EnableReviveLimit()
    --cannot special summon
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
    --Special Summon 1 monster that is treated as a Continuous Spell
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
    --Place 2 monsters in the Spell/Trap Zone as a Continuous Spells
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e4:SetLabelObject(e2)
	e4:SetTarget(s.pltg)
	e4:SetOperation(s.plop)
	c:RegisterEffect(e4)
end
s.listed_names={920182000}
function s.mfilter(c,rc,sumtyp,tp)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_FIRE,rc,sumtyp,tp)
end
--material check
function s.matcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(0)
	if g:IsExists(Card.IsCode,1,nil,920182000) then
		e:SetLabel(1)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	end
end
--special summon
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsOriginalType(TYPE_MONSTER) and c:IsContinuousSpell()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--place as Continuous Spell
function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsFaceup() and c:IsMonster() and Duel.GetLocationCount(p,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(p,LOCATION_SZONE)
		and (c:IsLocation(LOCATION_MZONE) or not c:IsForbidden())
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.plfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.plfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,2,nil)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g:Filter(Card.IsLocation,nil,LOCATION_GRAVE),1,0,0)
	end
end
function s.opfilter(c,e)
    return not c:IsImmuneToEffect(e) and c:IsRelateToEffect(e)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.opfilter,nil,e)
    for tc in aux.Next(g) do
        if Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
            --Treat it as a Continuous Spell
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
            tc:RegisterEffect(e1)

			--grant effects
			if e:GetLabelObject():GetLabel()==1 and tc:IsControler(1-tp) then
				Duel.BreakEffect()
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetDescription(aux.Stringid(id,1))
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetRange(LOCATION_SZONE)
				e2:SetCode(EFFECT_DISABLE_FIELD)
				e2:SetProperty(EFFECT_FLAG_REPEAT+EFFECT_FLAG_CLIENT_HINT)
				e2:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
				e2:SetOperation(s.disop)
				tc:RegisterEffect(e2)
			end
        end
    end
end
function s.disop(e,tp)
	local c=e:GetHandler()
	local seq=c:GetSequence()
	if Duel.CheckLocation(c:GetControler(),LOCATION_MZONE,seq) then
		return 0x1<<seq
	end
	return 0
end