--Contaminet Trojan
local s,id=GetID()
if not Rune then Duel.LoadScript("proc_rune.lua") end
function s.initial_effect(c)
	--Rune Summon
	c:EnableReviveLimit()
	Rune.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1fe7),2,2,aux.FilterBoolFunction(Card.IsCode,912389041),1,nil,nil,s.getGroup)
	--disable zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.zcon)
	e1:SetTarget(s.ztg)
	e1:SetOperation(s.zop)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
s.listed_series={0x1fe7}
s.listed_names={912389041}
function s.getGroup(tp,ex)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ex)
end
function s.zfilter(c)
	--Face-up "Contaminet-" card or face-down monster
	if c:IsFaceup() then return c:IsSetCard(0x1fe7)
	else return c:IsLocation(LOCATION_MZONE) end
end
function s.zcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetMatchingGroupCount(s.zfilter,c:GetControler(),0,LOCATION_ONFIELD,nil)>e:GetLabel()
end
function s.ztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)+Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 end
	local dis=Duel.SelectDisableField(tp,1,0,LOCATION_ONFIELD,0)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetLabel(dis)
	e:SetLabelObject(e1)
end
function s.zop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=e:GetLabelObject()
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	e:SetLabel(e:GetLabel()+1)
end
function s.disop(e,tp)
	return e:GetLabel()
end
