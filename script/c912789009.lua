--Fusion of the Parafallen
local s,id=GetID()
function s.initial_effect(c)
	--Activate
    local e1=Fusion.CreateSummonEff(c,nil,nil,s.fextra)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.SummonEffOP(nil,nil,s.fextra))
    c:RegisterEffect(e1)
    if not AshBlossomTable then AshBlossomTable={} end
    table.insert(AshBlossomTable,e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={912789006}
function s.exfilter(c)
	return (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_FLIP)) and c:IsAbleToGrave()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.exfilter),tp,LOCATION_DECK,0,nil)
end
s.SummonEffOP = aux.FunctionWithNamedArgs(
function (fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				location=location or LOCATION_EXTRA
				chkf = chkf and chkf|tp or tp
				local sumlimit=(chkf&FUSPROC_NOTFUSION)~=0
				if not value then value=0 end
				if not sumlimit then
					value = value|SUMMON_TYPE_FUSION|MATERIAL_FUSION
				end
				local gc=gc2
				gc=type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc
				gc=type(gc)=="Card" and Group.FromCards(gc) or gc
				matfilter=matfilter or Card.IsAbleToGrave
				stage2 = stage2 or aux.TRUE
				local checkAddition
				local mg1=Duel.GetFusionMaterial(tp):Filter(matfilter,nil,e,tp,1)
				if extrafil then
					local ret = {extrafil(e,tp,mg1)}
					if ret[1] then
						mg1:Merge(ret[1])
					end
					checkAddition=ret[2]
				end
				mg1=mg1:Filter(Card.IsCanBeFusionMaterial,nil,nil,value)
				mg1=mg1:Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
				if gc and (not mg1:Includes(gc) or gc:IsExists(Fusion.ForcedMatValidity,1,nil,e)) then return false end
				Fusion.CheckExact=exactcount
				Fusion.CheckAdditional=checkAddition
				local effswithgroup={}
				local sg1=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck)
				if #sg1 > 0 then
					table.insert(effswithgroup,{e,aux.GrouptoCardid(sg1)})
				end
				Fusion.CheckAdditional=nil
				if not sumlimit then
					local extraeffs = {Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}
					for _,ce in ipairs(extraeffs) do
						local fgroup=ce:GetTarget()
						local mg2=fgroup(ce,e,tp,value)
						if #mg2>0 and (not Fusion.CheckExact or #mg2==Fusion.CheckExact) then
							local mf=ce:GetValue()
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
							end
							local sg2=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg2,gc,chkf,value,sumlimit,nosummoncheck)
							if #sg2 > 0 then
								table.insert(effswithgroup,{ce,aux.GrouptoCardid(sg2)})
								sg1:Merge(sg2)
							end
							Fusion.CheckAdditional=nil
						end
					end
				end
				if #sg1>0 then
					local sg=sg1:Clone()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local tc=sg:Select(tp,1,1,nil):GetFirst()
					if preselect and preselect(e,tc)==false then
						return
					end
					local sel=effswithgroup[Fusion.ChainMaterialPrompt(effswithgroup,tc:GetCardID(),tp,e)]
					local backupmat=nil
					if sel[1]==e then
						Fusion.CheckAdditional=checkAddition
						local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
						backupmat=mat1:Clone()
						tc:SetMaterial(mat1)
						if extraop then
							if extraop(e,tc,tp,mat1)==false then return end
						end
						if #mat1>0 then
							Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
						end
						Duel.BreakEffect()
						Duel.SpecialSummonStep(tc,value,tp,tp,sumlimit,false,POS_FACEDOWN_DEFENSE)
					else
						local ce=sel[1]
						local fcheck=nil
						if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
						if fcheck then
							if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
						end
						local mat2=Duel.SelectFusionMaterial(tp,tc,ce:GetTarget()(ce,e,tp,value),gc,chkf)
						Fusion.CheckAdditional=nil
						ce:GetOperation()(sel[1],e,tp,tc,mat2,value)
						backupmat=tc:GetMaterial():Clone()
					end
					stage2(e,tc,tp,backupmat,0)
					Duel.SpecialSummonComplete()
					stage2(e,tc,tp,backupmat,3)
					if not sumlimit then
						tc:CompleteProcedure()
					end
					stage2(e,tc,tp,backupmat,1)
				end
				stage2(e,nil,tp,nil,2)
				Fusion.CheckExact=nil
				Fusion.CheckAdditional=nil
			end
end,"fusfilter","matfilter","extrafil","extraop","gc","stage2","exactcount","value","location","chkf","preselect","nosummoncheck")
function s.thcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCode(912789006)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.thcfilter,1,nil) end
	local sg=Duel.SelectReleaseGroup(tp,s.thcfilter,1,1,nil)
	Duel.Release(sg,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT) then
		Duel.BreakEffect()
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end