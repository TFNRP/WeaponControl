Constants = {
  SEMI_AUTO = 1,
  BURST_FIRE = 2,
  FULL_AUTO = 3,
}

AllowedAuto = {
  [GetHashKey('GROUP_RIFLE')] = true,
  [GetHashKey('GROUP_SMG')] = true,
}

Weapons = {}

function WeaponStub()
  return {
    Safety = false,
    FiringMode = 1,
  }
end

function GetWeapon(hash)
  if not Weapons[hash] then
    Weapons[hash] = WeaponStub()
  end
  return Weapons[hash]
end

function IsArmed()
  return IsPedArmed(PlayerPedId(), 4)
end

function PlayClick(ped)
  PlaySoundFromEntity(-1, 'Faster_Click', ped, 'RESPAWN_ONLINE_SOUNDSET', true)
end

function ShowNotification(message)
  SetNotificationTextEntry('STRING')
  AddTextComponentSubstringPlayerName(message)
  DrawNotification(true, true)
end