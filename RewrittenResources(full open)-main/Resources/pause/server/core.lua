-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Hensa = {}
Tunnel.bindInterface("pause",Hensa)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local BoxPayment = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETCAROUSEL
-----------------------------------------------------------------------------------------------------------------------------------------
local function getCarousel()
	local Carousel = {}
	local Counter = 0
	for Number,v in pairs(ShopItens) do
		if (#Carousel + 1) > 3 then break end

		if v["Discount"] ~= 0 then
			Carousel[#Carousel + 1] = {
				["id"] = Counter,
				["Index"] = Number,
				["Image"] = ItemIndex(Number),
				["Name"] = ItemName(Number),
				["Amount"] = 1,
				["Price"] = v["Price"],
				["Discount"] = v["Price"] * (1 - (v["Discount"] / 100))
			}

			Counter += 1
		end
	end
    
	return Carousel
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETSHOPPING
-----------------------------------------------------------------------------------------------------------------------------------------
local function getShopping()
	local Shopping = {}
	for Number,v in pairs(ShopItens) do
		if (#Shopping + 1) > 5 then break end

		Shopping[#Shopping + 1] = {
			["Image"] = ItemIndex(Number),
			["Name"] = ItemName(Number),
			["Index"] = Number,
			["Amount"] = 1,
			["Price"] = v["Price"],
			["Discount"] = v["Discount"]
		}
	end

	return Shopping
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETEXPERIENCE
-----------------------------------------------------------------------------------------------------------------------------------------
local function getExperience(Passport)
	local Experience = {}
	for Number,v in pairs(Works) do
		Experience[#Experience + 1] = { v, vRP.GetExperience(Passport, Number) or 0 }
	end

	return Experience
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HOME
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Home()
    local source = source
    local Passport = vRP.Passport(source)
    local Identity = vRP.Identity(Passport)
    if Identity then
        local Identities = vRP.Identities(source)
        local Account = vRP.Account(Identities)
        local Home = {
            ["Information"] = {
                ["Passport"] = Passport,
                ["Name"] = vRP.FullName(Passport),
                ["Bank"] = Identity["Bank"],
                ["Sex"] = Identity["Sex"],
                ["Blood"] = Sanguine(Identity["Blood"]),
                ["Phone"] = vRP.GetPhone(Passport),
                ["Diamonds"] = Account["Gemstone"] or 0,
                ["Medic"] = "Hensa"
            },

            ["Premium"] = PremiumRenew,
            ["Carousel"] = getCarousel(),
            ["Shopping"] = getShopping(),
            ["Experience"] = getExperience(Passport),
            ["Box"] = Boxes[1]
        }

        return Home
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DIAMONDSLIST
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.DiamondsList()
	local DiamondsList = {}

	for Number,v in pairs(ShopItens) do
		DiamondsList[#DiamondsList + 1] = {
			["Index"] = Number,
			["Description"] = ItemDescription(Number),
			["Image"] = ItemIndex(Number),
			["Name"] = ItemName(Number),
			["Price"] = v["Price"],
			["Discount"] = v["Discount"]
		}
	end

	return DiamondsList
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DIAMONDSBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.DiamondsBuy(Item, Amount)
	local source = source
	local Passport = vRP.Passport(source)
	if ShopItens[Item] then
		local Price = ShopItens[Item]["Price"] * ((100 - ShopItens[Item]["Discount"]) / 100)
		if vRP.PaymentGems(Passport, Amount * Price) then
			vRP.GenerateItem(Passport, Item, Amount, true)

			return true
		else
			TriggerClientEvent("Notify", source, "vermelho", "<b>"..ItemName(DefaultSpecialMoney).."s</b> insuficiente.", "Aviso", 5000)
		end
	end
    
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENBOXES
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.OpenBoxes(Number)
	local source = source
	local Passport = vRP.Passport(source)
	if Number then
		if vRP.PaymentGems(Passport, tonumber(Boxes[Number]["Price"])) then
			BoxPayment = true
			return math.random(#ContentBoxes[Number])
		else
			TriggerClientEvent("Notify", source, "vermelho", "<b>"..ItemName(DefaultSpecialMoney).."s</b> insuficiente.", "Aviso", 5000)
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENTBOXES
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.PaymentBoxes(Number, Index)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		if not BoxPayment then
			TriggerClientEvent("Notify", source, "vermelho", "Infelizmente a caixa não abriu.", "Aviso", 5000)
			return
		else
			vRP.GenerateItem(Passport, ContentBoxes[Number][Index]["Item"], ContentBoxes[Number][Index]["Amount"], true)
			BoxPayment = false
		end

		return "Ok"
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
function Hensa.Disconnect()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		vRP.Kick(source, "Você se desconectou.")
	end
end