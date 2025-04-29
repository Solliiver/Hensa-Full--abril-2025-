-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Objects = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHAKECONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
local ShakeWait = 50
local ShakeIntensity = 0.2
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKEDAMAGE
-----------------------------------------------------------------------------------------------------------------------------------------
function TakeDamage()
	local PlayerPed = GetPlayerPed(-1)

	if not IsEntityDead(PlayerPed) then
		ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", ShakeIntensity)

		Wait(ShakeWait)

		StopGameplayCamShaking(false)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:TAKEDAMAGE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:TakeDamage")
AddEventHandler("inventory:TakeDamage", function()
	TakeDamage()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHAKETHREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local EntityHealth = GetEntityHealth(GetPlayerPed(-1))

	while true do
		Wait(0)

		local PlayerPed = GetPlayerPed(-1)
		local CurrentHealth = GetEntityHealth(PlayerPed)

		if EntityHealth > CurrentHealth then
			EntityHealth = CurrentHealth
			TriggerEvent("inventory:TakeDamage")
		else
			EntityHealth = CurrentHealth
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADRECOIL
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Ped = PlayerPedId()

		if IsPedArmed(Ped, 6) then
			DisableControlAction(1, 140, true)
			DisableControlAction(1, 141, true)
			DisableControlAction(1, 142, true)

			Wait(1)
		else
			Wait(1000)
		end

		if IsPedShooting(Ped) then
			local Cam = GetFollowPedCamViewMode()
			local InVehicle = IsPedInAnyVehicle(Ped)

			local Speed = math.ceil(GetEntitySpeed(Ped))
			if Speed > 70 then
				Speed = 70
			end

			local _,Weapon = GetCurrentPedWeapon(Ped)
			local Class = GetWeapontypeGroup(Weapon)
			local Pitch = GetGameplayCamRelativePitch()
			local CameraDistance = #(GetGameplayCamCoord() - GetEntityCoords(Ped))

			local Recoil = math.random(110, 120 + (math.ceil(Speed * 0.5))) / 100
			local Rifle = false

			if Class == 970310034 or Class == 1159398588 then
				Rifle = true
			end

			if CameraDistance < 5.3 then
				CameraDistance = 1.5
			else
				if CameraDistance < 8.0 then
					CameraDistance = 4.0
				else
					CameraDistance =  7.0
				end
			end

			if InVehicle then
				Recoil = Recoil + (Recoil * CameraDistance)
			else
				Recoil = Recoil * 0.1
			end

			if Cam == 4 then
				Recoil = Recoil * 0.6

				if Rifle then
					Recoil = Recoil * 0.1
				end
			end

			if Rifle then
				Recoil = Recoil * 0.6
			end

			local Spread = math.random(4)
			local Head = GetGameplayCamRelativeHeading()
			local HeadSpeed = math.random(10, 40 + Speed) / 100

			if InVehicle then
				HeadSpeed = HeadSpeed * 2.0
			end

			if Spread == 1 then
				SetGameplayCamRelativeHeading(Head + HeadSpeed)
			elseif Spread == 2 then
				SetGameplayCamRelativeHeading(Head - HeadSpeed)
			end

			local Set = Pitch + Recoil
			SetGameplayCamRelativePitch(Set, 0.8)
		end
	end
end)