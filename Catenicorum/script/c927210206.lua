--Catenicorum Chains
if not Rune then Duel.LoadScript("proc_rune.lua") end
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,1,aux.CheckStealEquip,s.eqlimit,nil,s.target)
	--Atk,def
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e1)
	--atk,def
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_SET_ATTACK)
    e2:SetValue(100)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_SET_DEFENSE)
    e3:SetValue(100)
    c:RegisterEffect(e3)
	--negate
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_DISABLE)
    c:RegisterEffect(e4)
	--use equipped monster as rune material
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_EXTRA_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetOperation(s.extracon)
	e5:SetValue(s.extraval)
	c:RegisterEffect(e5)
	--place on field
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_BE_MATERIAL)
	e6:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e6:SetCondition(s.eqcon)
	e6:SetTarget(s.eqtg)
	e6:SetOperation(s.eqop)
	c:RegisterEffect(e6)
end
s.listed_series={0xfcf}
--equip
function s.eqlimit(e,c)
    return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc)
    e:SetCategory(CATEGORY_EQUIP)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
    return tp==ep
end
--extra material
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	if tp==nil then return true end
	return sg:IsContains(e:GetHandler())
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfcf) then
			return Group.CreateGroup()
		else
			return Group.FromCards(c:GetEquipTarget())
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
		end
	end
end
--equipped
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetHandler():GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and rc:IsSummonType(SUMMON_TYPE_RUNE) and c:CheckUniqueOnField(tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) then
		Duel.Equip(tp,c,tc)
	end
end
