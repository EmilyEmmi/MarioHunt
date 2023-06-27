-- name: MarioHunt API Demonstration
-- description: This is a demonstration of the MarioHunt API.\n\nMod By EmilyEmmi.

-- This displays a popup of what team you've attacked.
function on_pvp_attack(attacker,victim)
  if attacker.playerIndex == 0 and _G.mhExists then
    local team = _G.mhApi.getTeam(victim.playerIndex)
    local text = "Hunter"
    if team == 1 then text = "Runner" end
    djui_popup_create("Attacked a "..text,2)
  end
end
hook_event(HOOK_ON_PVP_ATTACK, on_pvp_attack)

-- This grants the killer the Metal Cap, the new runner the Vanish cap, and instantly warps the killed player
function on_mh_kill(killer,killed,runner,death,time,newRunnerID)
  if killer ~= nil then
    local np = network_player_from_global_index(killer)
    local m = gMarioStates[np.localIndex]
    m.flags = m.flags | MARIO_METAL_CAP
    m.capTimer = 300 -- 5 seconds
  end
  if newRunnerID ~= nil then
    local np = network_player_from_global_index(newRunnerID)
    local m = gMarioStates[np.localIndex]
    m.flags = m.flags | MARIO_VANISH_CAP
    m.capTimer = 300 -- 5 seconds
  end
  if killed ~= nil then
    local np = network_player_from_global_index(killed)
    local m = gMarioStates[np.localIndex]
    set_mario_action(m, ACT_LAVA_BOOST, 0)
  end
end
_G.mhApi.onKill = on_mh_kill
