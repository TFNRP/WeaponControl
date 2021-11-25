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
    Safety = true,
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

function ShowNotification(message)
  SetNotificationTextEntry('STRING')
  AddTextComponentSubstringPlayerName(message)
  DrawNotification(true, true)
end