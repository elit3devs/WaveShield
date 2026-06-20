fx_version 'cerulean'
game 'gta5'
lua54 'yes'

version '4.0.0'
author 'Elit3'
description 'WaveShield FiveM Anti-Cheat'

shared_scripts {
    'config.lua',
    'shared/data.lua',
    'shared/main.lua',
}

server_scripts {
    'server/cache.lua',
    'server/bans.lua',
    'server/utils.lua',
    'server/webhooks.lua',
    'server/autoWhiteList.lua',
    'server/player.lua',
    'server/playerManager.lua',
    'server/resourcesHandler.lua',
    'server/anti-backdoors.lua',
    'server/installer.lua',
    'server/configUpdater.lua',
    'server/heartbeat.lua',
    'server/commands.lua',
    'server/events/chatMessage.lua',
    'server/events/clearPedTasksEvent.lua',
    'server/events/entityCreated.lua',
    'server/events/entityCreating.lua',
    'server/events/entityRemoved.lua',
    'server/events/explosionEvent.lua',
    'server/events/fireEvent.lua',
    'server/events/givePedScriptedTaskEvent.lua',
    'server/events/giveWeaponEvent.lua',
    'server/events/playerConnecting.lua',
    'server/events/playerDropped.lua',
    'server/events/premiumEvents.lua',
    'server/events/ptFxEvent.lua',
    'server/events/removeAllWeaponsEvent.lua',
    'server/events/removeWeaponEvent.lua',
    'server/events/startNetworkSyncedSceneEvent.lua',
    'server/events/startProjectileEvent.lua',
    'server/events/weaponDamageEvent.lua',
    'server/exploits-fixed.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
    'client/modules/afkTasks.lua',
    'client/modules/antiExec.lua',
    'client/modules/commands.lua',
    'client/modules/entities.lua',
    'client/modules/events.lua',
    'client/modules/execution.lua',
    'client/modules/freecam.lua',
    'client/modules/godMode.lua',
    'client/modules/infiniteStamina.lua',
    'client/modules/inputBox.lua',
    'client/modules/invisible.lua',
    'client/modules/misc.lua',
    'client/modules/nightVisions.lua',
    'client/modules/noclip.lua',
    'client/modules/noRagdoll.lua',
    'client/modules/pedModel.lua',
    'client/modules/resourcesHandler.lua',
    'client/modules/sounds.lua',
    'client/modules/spectate.lua',
    'client/modules/speedHack.lua',
    'client/modules/superJump.lua',
    'client/modules/teleport.lua',
    'client/modules/textures.lua',
    'client/modules/weapons/aimbot.lua',
    'client/modules/weapons/ammos.lua',
    'client/modules/weapons/hitbox.lua',
    'client/modules/weapons/pickups.lua',
    'client/modules/weapons/weaponDamages.lua',
    'client/modules/weapons/weaponSpawn.lua',
    'client/modules/vehicles/teleportInVehicle.lua',
    'client/modules/vehicles/vehicleModifications.lua',
    'client/modules/vehicles/vehicleSpeed.lua',
    'client/heartbeat.lua',
    'client/configUpdater.lua',
    'client/debug.lua',
    'client/screenshots.lua',
    'client/spawner.lua',
    'client/actorLoop.lua',
}

files {
    'resource/include.lua',
    'resource/client/main.lua',
}

dependencies {
    '/server:14317',
    '/onesync',
}
