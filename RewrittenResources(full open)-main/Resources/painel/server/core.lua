-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Hensa = {}
Tunnel.bindInterface("painel", Hensa)
vCLIENT = Tunnel.getInterface("painel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Panel = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function Premium(Org)
	local Infos = vRP.Query("panel/GetInformations",{ name = tostring(Org) })[1]
	if Infos["premium"] > 0 then
		local Premium = Infos["premium"] - os.time()

		local Days = math.floor(Premium / 86400)

		if Infos["buff"] == true and Days < 1 then
			vRP.Query("panel/UpdateBuff",{ buff = false, name = tostring(Org) })
			vRP.Query("chests/DowngradeChests",{ Name = tostring(Org) })
			vRP.Query("panel/SetPremium",{ premium = 0, name = tostring(Org) })

			local Entitys = vRP.DataGroups(Panel[Passport])
			for Number,v in pairs(Entitys) do
				local Number = parseInt(Number)
				TriggerEvent("Salary:Remove", tostring(Number), "Buff")
			end
		end

		return Days
	else
		return 0
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAINEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("painel", function(source, Message)
	local Passport = vRP.Passport(source)
	if Passport and Message[1] and Message[1] ~= "Premium" then
		if vRP.HasGroup(Passport, Message[1]) then
			Panel[Passport] = Message[1]

			local Members = {}
			local Sources = vRP.Players()
			local Entitys = vRP.DataGroups(Panel[Passport])
			local Hierarchy = vRP.Hierarchy(Panel[Passport])
			for Number,v in pairs(Entitys) do
				local Number = parseInt(Number)
				local Identity = vRP.Identity(Number)
				if Identity then
					if vRP.HasPermission(Number, Panel[Passport], 1) then
						Members[#Members + 1] = {
							["name"] = Identity["Name"].." "..Identity["Lastname"],
							["phone"] = Identity["Phone"],
							["online"] = Sources[Number],
							["id"] = Number,
							["role"] = Hierarchy[1] or Hierarchy,
							["role_id"] = 1
						}
					else
						Members[#Members + 1] = {
							["name"] = Identity["Name"].." "..Identity["Lastname"],
							["phone"] = Identity["Phone"],
							["online"] = Sources[Number],
							["id"] = Number,
							["role"] = Hierarchy[v] or Hierarchy
						}
					end
				end
			end

			local Data = {
				groupName = Panel[Passport],
				members = Members,
				client_role = Entitys[tostring(Passport)]
			}

			vCLIENT.Open(source, Data, Premium(Panel[Passport]), Price)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DIMISS
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Dismiss(Number)
	local source = source
	local Number = parseInt(Number)
	local Passport = vRP.Passport(source)
	if Passport and Panel[Passport] and Number > 1 and Passport ~= Number then
		if vRP.HasPermission(Passport, Panel[Passport], 1) then
			vRP.RemovePermission(Number, Panel[Passport])

			TriggerClientEvent("Notify", source, "verde", "Passaporte removido.", "Sucesso", 5000)

			local Members = {}
			local Sources = vRP.Players()
			local Entitys = vRP.DataGroups(Panel[Passport])
			local Hierarchy = vRP.Hierarchy(Panel[Passport])
			for Number,v in pairs(Entitys) do
				local Number = parseInt(Number)
				local Identity = vRP.Identity(Number)
				if Identity then
					if vRP.HasPermission(Number, Panel[Passport], 1) then
						Members[#Members + 1] = {
							["name"] = Identity["Name"].." "..Identity["Lastname"],
							["phone"] = Identity["Phone"],
							["online"] = Sources[Number],
							["id"] = Number,
							["role"] = Hierarchy[1] or Hierarchy,
							["role_id"] = 1
						}
					else
						Members[#Members + 1] = {
							["name"] = Identity["Name"].." "..Identity["Lastname"],
							["phone"] = Identity["Phone"],
							["online"] = Sources[Number],
							["id"] = Number,
							["role"] = Hierarchy[v] or Hierarchy
						}
					end
				end
			end

			return Members
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVITE
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Invite(Number)
	local source = source
	local Number = parseInt(Number)
	local Passport = vRP.Passport(source)
	local Identity = vRP.Identity(Passport)
	if Passport and Panel[Passport] and Number > 1 and Passport ~= Number and vRP.Identity(Number) then
		if vRP.HasPermission(Passport, Panel[Passport], 1) then
			if not vRP.HasPermission(Number, Panel[Passport]) then
				if vRP.Request(Number, Panel[Passport], "Você deseja se juntar ao grupo <b>"..Panel[Passport].."</b>?") then
					vRP.SetPermission(Number, Panel[Passport])

					local Sources = vRP.Players()
					local Entitys = vRP.DataGroups(Panel[Passport])
					local Identity = vRP.Identity(Number)

					return {
						["name"] = Identity["Name"].." "..Identity["Lastname"],
						["phone"] = Identity["Phone"],
						["online"] = Sources[Number],
						["id"] = Number,
						["role"] = vRP.Hierarchy(Panel[Passport])[Entitys[tostring(Number)]]
					}
				else
					TriggerClientEvent("Notify", source, "vermelho", "Passaporte <b>"..parseInt(Number).."</b> recusou o convite.", "Aviso", 5000)
				end
			else
				TriggerClientEvent("Notify", source, "amarelo", "Passaporte <b>"..parseInt(Number).."</b> já pertence ao grupo.", "Atenção", 5000)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HIERARCHY
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Hierarchy(OtherPassport, Mode)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Panel[Passport] and OtherPassport > 1 and Passport ~= OtherPassport and vRP.Identity(OtherPassport) then
		if vRP.HasPermission(Passport, Panel[Passport], 1) then
			if (not vRP.HasPermission(OtherPassport, Panel[Passport], 1) and not vRP.HasPermission(OtherPassport, Panel[Passport], 2)) or (Mode == "Demote" and not vRP.HasPermission(OtherPassport, Panel[Passport], 1)) then
				vRP.SetPermission(OtherPassport, Panel[Passport], nil, Mode)

				local Entitys = vRP.DataGroups(Panel[Passport])
				return { vRP.Hierarchy(Panel[Passport])[Entitys[tostring(OtherPassport)]] }
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Transactions()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Panel[Passport] then
		local Infos = vRP.Query("panel/GetInformations",{ name = Panel[Passport] })
		local Bank = 0

		if Infos and Infos[1] then
			Bank = Infos[1]["bank"] or 0
		end

		local Transactions = vRP.Query("panel/GetTransactions",{ name = Panel[Passport] }) or {}
		return {
			["Balance"] = Bank,
			["Transactions"] = Transactions
		}
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WITHDRAW
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Withdraw(value)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Panel[Passport] and (vRP.HasPermission(Passport, Panel[Passport], 1) or vRP.HasPermission(Passport, Panel[Passport], 2)) then
		local value = tonumber(value)
		if value and value > 0 then
			local result = vRP.Query("panel/GetInformations", { name = Panel[Passport] })[1]
			local bankBalance = result and result["bank"] or 0

			if value <= bankBalance then
				vRP.Query("panel/InsertTransaction", { name = Panel[Passport], Type = "exit", Value = value })
				vRP.Query("panel/DowngradeBank", { name = Panel[Passport], Value = value })

				vRP.GenerateItem(Passport, DefaultDollars1, value, true)

				local updatedBankInfo = vRP.Query("panel/GetInformations", { name = Panel[Passport] })[1]
				local updatedBank = updatedBankInfo and updatedBankInfo["bank"] or 0
				local transactions = vRP.Query("panel/GetTransactions", { name = Panel[Passport] })

				return {
					["Balance"] = updatedBank,
					["Transactions"] = transactions
				}
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPOSIT
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Deposit(value)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Panel[Passport] and (vRP.HasPermission(Passport, Panel[Passport], 1) or vRP.HasPermission(Passport, Panel[Passport], 2)) then
		local value = tonumber(value)

		if value and value > 0 then
			local inventory = vRP.ItemAmount(Passport, DefaultDollars1)

			if value <= inventory then
				if vRP.PaymentFull(Passport, value) then
					vRP.Query("panel/InsertTransaction", { name = Panel[Passport], Type = "entry", Value = value })
					vRP.Query("panel/UpgradeBank", { name = Panel[Passport], Value = value })

					local updatedBankInfo = vRP.Query("panel/GetInformations", { name = Panel[Passport] })[1]
					local updatedBank = updatedBankInfo and updatedBankInfo["bank"] or 0
					local transactions = vRP.Query("panel/GetTransactions", { name = Panel[Passport] })

					return {
						["Balance"] = updatedBank,
						["Transactions"] = transactions
					}
				end
			else
				TriggerClientEvent("Notify", source, "vermelho", "<b>"..itemName(DefaultDollars1).."</b> insuficientes.", "Aviso", 5000)
				return
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Buy()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Panel[Passport] and vRP.HasPermission(Passport, Panel[Passport]) then
		if vRP.PaymentFull(Passport, tonumber(Price)) then
			local seconds = os.time() + (86400 * 30)

			vRP.Query("panel/UpdateBuff", { buff = true, name = Panel[Passport] })
			vRP.Query("chests/DowngradeChests", { Name = Panel[Passport] })
			vRP.Query("panel/SetPremium", { premium = seconds, name = Panel[Passport] })

			local entities = vRP.DataGroups(Panel[Passport])
			for number, _ in pairs(entities) do
				local number = tonumber(number)
				TriggerEvent("Salary:Add", tostring(number), "Buff")

				TriggerClientEvent("painel:Update", source, Panel[Passport])

				local PanelName = vRP.NumPermission(Panel[Passport])
				for Passports, Sources in pairs(PanelName) do
					async(function()
						TriggerClientEvent("Notify", Sources, "azul", "<b>"..vRP.FullName(Passport).."</b> assinou o <b>Boost</b>.", "Painel "..Panel[Passport], 10000)
					end)
				end
			end
		end
	end

	return Premium(Panel[Passport])
end