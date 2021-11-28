Citizen.CreateThread(function()
  local prompted = false
  while not prompted do
    Citizen.Wait(1e3)
    if IsArmed() then
      prompted = true
      ShowNotification('Your gun is on ~g~Safety~s~ with ~y~SEMI-AUTO~s~ fire.')
      ShowNotification('Toggle ~g~Safety~s~ with <C>K</C>~n~and ~y~Firing Mode~s~ with <C>L</C>.')
    end
  end
end)

Citizen.CreateThread(function()
  SetWeaponsNoAutoreload(true)
  SetWeaponsNoAutoswap(true)
  while true do
    Citizen.Wait(1)

    if IsArmed() then
      local ped = PlayerPedId()
      local _, weapon = GetCurrentPedWeapon(ped)
      local Weapon = GetWeapon(weapon)

      if Weapon.Safety then
        DisablePlayerFiring(ped, true)
        if (IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24)) and math.random(1, 5) == 1 then
          ShowNotification('You attempt to pull the trigger but it doesn\'t retract. (~g~SAFETY~s~)')
        end
      else
        if IsPedShooting(ped) then
          if not IsPedInAnyVehicle(ped) then
            local iter = 2
            if IsPedSprinting(ped) then
              iter = iter + 1
            end
            CreateThread(function()
              local last = GetGameplayCamRelativePitch()
              for _ = 1, iter do
                local camera = GetGameplayCamRelativePitch()
                local amount = camera - last
                if GetFollowPedCamViewMode() == 4 then
                  amount = -amount
                end
                print(amount)
                SetGameplayCamRelativePitch(camera - amount, 1.0)
                last = camera
                Wait(1)
              end
            end)
          end
          if AllowedAuto[GetWeapontypeGroup(weapon)] then
            ({
              function()
                repeat
                  DisablePlayerFiring(PlayerId(), true)
                  Wait(0)
                until not (IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24))
              end,
              function()
                Wait(300)
                while IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24) do
                  DisablePlayerFiring(PlayerId(), true)
                  Wait(0)
                end
              end,
              function() end,
            })[Weapon.FiringMode]()
          end

          local _, clipAmmo = GetAmmoInClip(ped, weapon)
          -- 1 in 1000 chance to jam for each bullet
          -- that's 40 mags of a carbine rifle or 100 mags of a pistol
          if math.random(1, 1.2e3) == 1 and clipAmmo > 0 then
            SetAmmoInClip(ped, weapon, 0)
            AddAmmoToPed(ped, weapon, clipAmmo)
            ShowNotification('You attempt to pull the trigger but nothing happens. (~r~JAMMED~s~)')
          end
        end
      end
    end
  end
end)

-- maximum clips and carrying capacity
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1e4)
    local ped = PlayerPedId()
    if IsArmed() then
      local _, hash = GetCurrentPedWeapon(ped)
      local totalAmmo = GetAmmoInPedWeapon(ped, hash)
      local clipSize = GetWeaponClipSize(hash)
      local totalClips = totalAmmo / clipSize
      local weight = GetWeaponDamage(hash) * .385 -- in grams, per bullet. roughly based on 9MM rounds
      local totalAmmoWeight = weight * totalAmmo
      if totalAmmoWeight > 1201.2 then -- maxmimum carrying capacity of 1.2KGs
        local bullets = math.floor(1201.2 / weight)
        local mags = math.floor(bullets / clipSize)
        if mags > 0 then
          SetPedAmmo(ped, hash, mags * clipSize)
        else
          SetPedAmmo(ped, hash, bullets)
        end
      end
      if clipSize <= 8 and totalClips > 5 then
        -- assume clips aren't magazines
        SetPedAmmo(ped, hash, clipSize * 5)
      end
    end
  end
end)

RegisterKeyMapping('safety', 'Toggle weapon safety', 'keyboard', 'k')
RegisterCommand('safety', function()
  local ped = PlayerPedId()
  if DoesEntityExist(ped) and not IsEntityDead(ped) and IsArmed() then
    local _, weapon = GetCurrentPedWeapon(ped)
    local Weapon = GetWeapon(weapon)
    Weapon.Safety = not Weapon.Safety
    ShowNotification(({
      [true]  = 'Safety ~g~on~s~.',
      [false] = 'Safety ~r~off~s~.',
    })[Weapon.Safety])
    PlaySoundFromEntity(-1, 'Faster_Click', ped, 'RESPAWN_ONLINE_SOUNDSET', true)
  end
end)

RegisterKeyMapping('firingmode', 'Next firing mode', 'keyboard', 'l')
RegisterCommand('firingmode', function()
  local ped = PlayerPedId()
  if DoesEntityExist(ped) and not IsEntityDead(ped) and IsArmed() then
    local _, weapon = GetCurrentPedWeapon(ped)
    if AllowedAuto[GetWeapontypeGroup(weapon)] then
      local Weapon = GetWeapon(weapon)
      Weapon.FiringMode = ({ 2, 3, 1 })[Weapon.FiringMode]
      ShowNotification(({
        [Constants.SEMI_AUTO]  = 'Firing mode ~y~SEMI-AUTO~s~.',
        [Constants.BURST_FIRE] = 'Firing mode ~y~BURST FIRE~s~.',
        [Constants.FULL_AUTO]  = 'Firing mode ~y~FULL-AUTO~s~.',
      })[Weapon.FiringMode])
      PlaySoundFromEntity(-1, 'Faster_Click', ped, 'RESPAWN_ONLINE_SOUNDSET', true)
    end
  end
end)