-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("initial")
-----------------------------------------------------------------------------------------------------------------------------------------
-- INITIAL:OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("initial:Open")
AddEventHandler("initial:Open", function()
	SetNuiFocus(true, true)
	TriggerEvent("hud:Active", false)
	SendNUIMessage({ name = "Open" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Save", function(Data, Callback)
	SetNuiFocus(false, false)
	vSERVER.Save(Data["name"])
	TriggerEvent("hud:Active", true)

	Callback("Save")
end)
