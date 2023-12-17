--Interlocker Shadow
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	aux.AddUnionProcedure(c,nil,true,false)
	--equip change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--add type
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_ADD_TYPE)
    e2:SetValue(TYPE_TUNER)
    c:RegisterEffect(e2)
	--synchromaterial
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SYNCHRO_MATERIAL)
	c:RegisterEffect(e3)
	--synchromaterial
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e4:SetOperation(s.matop)
	c:RegisterEffect(e4)
	--cannot be target
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(aux.tgoval)
	e5:SetCondition(s.eqcon)
	c:RegisterEffect(e5)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget())
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.eqfilter(chkc,e:GetHandler()) end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		local tg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetEquipTarget())
		Duel.Equip(tp,tc,tg:GetFirst())
		--Add New Equip Limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tg:GetFirst())
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
	end
end
function s.matop(e,tg,ntg,sg,lv,sc,tp)
	return sc:IsControler(e:GetHandlerPlayer())
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
function s.eqcon(e)
	local eg=e:GetHandler():GetEquipGroup()
	return #eg>0
end
