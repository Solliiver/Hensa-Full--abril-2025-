-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Cooldown = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REGISTER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Register")
AddEventHandler("inventory:Register",function(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		if not vCLIENT.CheckWeapon(source,"WEAPON_CROWBAR") then
			TriggerClientEvent("Notify",source,"amarelo","<b>Pé de Cabra</b> não encontrado.","Atenção",5000)
			return false
		end

		if not Cooldown[Number] or os.time() > Cooldown[Number] then
			if vRP.Task(source,3,7500) then
				Active[Passport] = os.time() + 15
				Player(source)["state"]["Buttons"] = true
				TriggerClientEvent("inventory:Close",source)
				TriggerClientEvent("Progress",source,"Roubando",15000)
				vRPC.PlayAnim(source,false,{"oddjobs@shop_robbery@rob_till","loop"},true)

				repeat
					if Active[Passport] and os.time() >= parseInt(Active[Passport]) and Number and (not Cooldown[Number] or os.time() > Cooldown[Number]) then
						vRPC.Destroy(source)
						Active[Passport] = nil
						Cooldown[Number] = os.time() + 3600
						Player(source)["state"]["Buttons"] = false

						local Rand = math.random(365,725)
						vRP.GenerateItem(Passport,"dollars2",Rand,true)

						vRP.UpgradeStress(Passport,2)
						TriggerEvent("Wanted",source,Passport,300)
						TriggerClientEvent("player:Residuals",source,"Resíduo de Arrombamento.")

						vRP.GiveUnLikes(Passport, 1)
						TriggerClientEvent("Notify",source,"roxo","Você conseguiu <b>+ 1</b> Voto <b>Negativo</b>.","Reputação",5000)

						if math.random(100) >= 50 then
							local Ped = GetPlayerPed(source)
							local Coords = GetEntityCoords(Ped)

							local Service = vRP.NumPermission("Policia")
							for Passports,Sources in pairs(Service) do
								async(function()
									TriggerClientEvent("NotifyPush", Sources,{ code = 31, title = "Caixa Registradora", x = Coords["x"], y = Coords["y"], z = Coords["z"], criminal = "Alarme de segurança", blipColor = 16 })
								end)
							end
						end
					end

					Wait(100)
				until not Active[Passport]
			end
		else
			TriggerClientEvent("Notify",source,"vermelho","A <b>Caixa Registradora</b> está vazia.","Aviso",5000)
		end
	end
end)