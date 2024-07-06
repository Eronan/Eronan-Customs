--Hexlock Seal
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(aux.PersistentTgCon)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
    --Cannot change battle positions
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(aux.PersistentTargetFilter)
    c:RegisterEffect(e3)
    --Cannot be material
    local e4=e3:Clone()
    e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e4:SetValue(aux.AND(s.matlimit,aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK)))
    c:RegisterEffect(e4)
    --cannot release
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCode(EFFECT_CANNOT_RELEASE)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetTarget(aux.PersistentTargetFilter)
    e5:SetTargetRange(0,1)
    c:RegisterEffect(e5)
    --Extra Material
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetRange(LOCATION_SZONE)
    e6:SetCode(EFFECT_EXTRA_MATERIAL)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e6:SetTargetRange(1,0)
    e6:SetOperation(s.extracon)
    e6:SetValue(s.extraval)
    e6:SetLabelObject(c)
    c:RegisterEffect(e6)
    --Change target monster to face-down Defense Position
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_POSITION)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetRange(LOCATION_GRAVE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetCondition(s.poscon)
	e7:SetCost(aux.bfgcost)
	e7:SetTarget(s.postg)
	e7:SetOperation(s.posop)
	c:RegisterEffect(e7)
    --act in hand
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e8:SetCondition(s.handcon)
	c:RegisterEffect(e8)
end
s.listed_series={0xfc7}
--Persistent Target Procedure
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,2,nil)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(re) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,re)
	for tc in aux.Next(g) do
		if tc:IsFaceup() then
			c:SetCardTarget(tc)
            c:CreateRelation(tc,RESET_EVENT+RESETS_STANDARD)
		end
	end
end
--Cannot be material
function s.matlimit(e,c,sumtype,tp)
    if tp==PLAYER_NONE then tp=c:GetControler() end
	return e:GetHandlerPlayer()==1-tp
end
--extra material
function s.extracon(c,e,tp,sg,mg,rc,og,chk)
	if tp==nil then tp=rc:GetControler() end
	return ct==0 or (sg:IsContains(e:GetLabelObject()) and ct<2)
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_RUNE or not sc:IsSetCard(0xfc7) or not c:IsControler(1-tp) then
			return Group.CreateGroup()
		else
			return c:GetCardTarget()
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_RUNE == SUMMON_TYPE_RUNE and #sg>0 and sc:IsSetCard(0xfc7) and c:IsControler(1-tp) then
			Duel.Hint(HINT_CARD,tp,id)
		end
	end
end
--Change target monster to face-down Defense Position
function s.poscfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc7) and c:IsType(TYPE_RUNE)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.poscfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.posfilter(c)
    return c:IsFaceup() and (c:IsCanTurnSet() or c:IsSSetable(true))
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.posfilter(chkc) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if tc:IsSSetable(true) then
		Duel.ChangePosition(tc,POS_FACEDOWN)
	elseif tc:IsCanTurnSet() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
--activate from hand
function s.handcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)>Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)
end