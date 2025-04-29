-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Range = false
local Accuracy = 800.0
local ConfigTimer = 15000
local ActiveAlarm = false
local ExplosionCooldown = 300
local ActiveExplosions = false
local Locate = vec3(1680.02, 2573.79, 46.15)
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLYINACCURACY
-----------------------------------------------------------------------------------------------------------------------------------------
local function ApplyInaccuracy(TargetCoords)
	local Offset = math.random(-Accuracy, Accuracy) / 100
	local XOffset = Offset
	local YOffset = Offset
	local ZOffset = Offset
	return vec3(TargetCoords["x"] + XOffset, TargetCoords["y"] + YOffset, TargetCoords["z"] + ZOffset)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local WaitTime = 2000 

		local Ped = PlayerPedId()
		local PedCoords = GetEntityCoords(Ped)
		local Distance = #(PedCoords - Locate)
		local HeightAboveGround = GetEntityHeightAboveGround(Ped)
		local IsFlyingVehicle = IsPedInFlyingVehicle(Ped)
		local IsAuthorized = LocalPlayer["state"]["Paramedico"] or LocalPlayer["state"]["Policia"]
		local PlayerIsDead = IsEntityDead(Ped)

		if Distance < 260 and HeightAboveGround > 5.0 and IsFlyingVehicle and not IsAuthorized then
			if not Range then
				Range = true
				ActiveAlarm = false
				ActiveExplosions = false
			end

			if not ActiveAlarm then
				TriggerEvent("sounds:Private", "warning", 0.7)
				TriggerEvent("Notify", "amarelo", "Você entrou em uma <b>Área Privada</b>, você precisa sair em <b>15 Segundos</b>.", "Atenção", ConfigTimer)
				ActiveAlarm = true
				Wait(ConfigTimer)

				TriggerEvent("Notify", "azul", "O sistema aéreo de defesa foi ativado.", false, 5000)
				ActiveExplosions = true
			end

			if ActiveExplosions then
				local ExplosionTimer = GetGameTimer()
				while ActiveExplosions and GetEntityHealth(Ped) > 100 do
					local CurrentTime = GetGameTimer()
					if CurrentTime - ExplosionTimer >= ExplosionCooldown then
						local TargetCoords = ApplyInaccuracy(PedCoords)
						AddExplosion(TargetCoords.x, TargetCoords.y, TargetCoords.z, 18, 2.0, true, false, 1.0)
						ExplosionTimer = CurrentTime
					end

					PedCoords = GetEntityCoords(Ped)
					Distance = #(PedCoords - Locate)
					if Distance >= 260 then
						ActiveExplosions = false
					end

					Wait(ExplosionCooldown)
				end
			end

			WaitTime = 500 
		else
			if Range then
				Range = false
				ActiveAlarm = false
				ActiveExplosions = false
			end

			if PlayerIsDead then
				Range = false
				ActiveAlarm = false
				ActiveExplosions = false
				WaitTime = 1000
			end
		end

		Wait(WaitTime)
	end
end)