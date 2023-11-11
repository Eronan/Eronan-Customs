--Dynachanter Spectre
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Rune.AddProcedure(c,Rune.MonFunctionEx(Card.IsRuneCode,986900019),1,1,Rune.STFunctionEx(Card.IsType,TYPE_CONTINUOUS),2,99)
	--Must use Material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.matcon)
	e1:SetTarget(s.mattg)
	e1:SetOperation(s.matop)
	c:RegisterEffect(e1)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(s.con)
	e2:SetValue(s.tglimit)
	c:RegisterEffect(e2)
	--cannot be effect target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetCondition(s.con)
	e3:SetTarget(s.tglimit)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
--s.listed_series={0xfe5}
s.listed_names={986900019}
--If a monster is special summoned to its zones
function s.matcfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_TOKEN)
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.matcfilter,1,nil,tp)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,0)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTarget(s.splimit)
		e2:SetLabelObject(tc)
		Duel.RegisterEffect(e2,1-tp)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_MUST_BE_MATERIAL)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END)
		e3:SetTargetRange(1,0)
		e3:SetValue(REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK)
		tc:RegisterEffect(e3)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return ((sumtype==SUMMON_TYPE_SYNCHRO or sumtype==SUMMON_TYPE_XYZ or sumtype==SUMMON_TYPE_LINK) and e:GetLabelObject():GetFlagEffect(id)==0)
		 or (sumtype==SUMMON_TYPE_FUSION and e:GetLabelObject():GetFlagEffect(id)==0 and e:GetLabelObject():GetReasonEffect()~=se)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsType,Card.IsFaceup),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler(),TYPE_TOKEN)
end
function s.tglimit(e,c)
	return c~=e:GetHandler()
end
