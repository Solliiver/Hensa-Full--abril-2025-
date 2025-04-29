-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local CityBankCooldown = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:SEETAXS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:SeeTaxs")
AddEventHandler("inventory:SeeTaxs", function()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		TriggerClientEvent("Notify", source, "default", "O cofre possúi atualmente <b>$"..parseFormat(vRP.Banks("See", false, "City")).."</b> "..ItemName(DefaultDollars1)..".", "Cofre da Prefeitura", 10000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:TAXS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Taxs")
AddEventHandler("inventory:Taxs", function()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and not Active[Passport] then
		if vRP.Banks("See", false, "City") > 0 then
			if GlobalState["Blackout"] then
				local Service,Total = vRP.NumPermission("Policia")
				if Total >= 5 then
					if vRP.Request(source, "Cofre", "Você realmente deseja roubar <b>$"..parseFormat(vRP.Banks("See", false, "City")).."</b> do <b>Cofre da Prefeitura</b>?") then
						if not CityBankCooldown["City"] or os.time() > CityBankCooldown["City"] then
							if vRP.Device(source, 60) then
								CityBankCooldown["City"] = os.time() + 900

								local Coords = vRP.GetEntityCoords(source)
								for Passports,Sources in pairs(Service) do
									async(function()
										TriggerClientEvent("sounds:Private",Sources,"crime",0.5)
										TriggerClientEvent("NotifyPush",Sources,{ code = 31, title = "Roubo ao Cofre", x = Coords["x"], y = Coords["y"], z = Coords["z"], color = 22 })
									end)
								end

								vRPC.AnimActive(source)
								Player(source)["state"]["Buttons"] = true
								Active[Passport] = os.time() + 30
								TriggerEvent("Wanted",source,Passport,30 * 3)
								vRPC.PlayAnim(source,false,{"oddjobs@shop_robbery@rob_till","loop"},true)
								TriggerClientEvent("Progress",source,"Roubando",30 * 1000)

								repeat
									if Active[Passport] and os.time() >= parseInt(Active[Passport]) then
										vRPC.Destroy(source)
										Active[Passport] = nil
										Player(source)["state"]["Buttons"] = false
										vRP.PaymentService(Passport, vRP.Banks("See", false, "City"), "Legal", true)
										vRP.Banks("Rem", vRP.Banks("See", false, "City"), "City")
									end

									Wait(100)
								until not Active[Passport]
							end
						else
							TriggerClientEvent("Notify", source, "azul", "Aguarde <b>"..CityBankCooldown["City"] - os.time().."</b> segundos.", false, 5000)
						end
					end
				else
					TriggerClientEvent("Notify", source, "amarelo", "Contingentes indisponíveis.", "Atenção", 5000)
				end
			else
				TriggerClientEvent("Notify", source, "default", "Você só conseguirá tamanha façanha se a cidade estiver sem <b>Energia Elétrica</b>.", "Cofre", 10000)
			end
		else
			TriggerClientEvent("Notify", source, "amarelo", "O cofre está vázio.", "Cofre", 5000)
		end
	end
end)