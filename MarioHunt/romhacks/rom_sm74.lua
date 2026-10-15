romhack_data["sm74"] = {
    name = "Super Mario 74 (+EE)",
    default_stars = 110,
    max_stars = 157, -- impossible in normal, but not in ee
    ommColorStar = true,
    requirements = {
        [LEVEL_BITDW] = 10,
        [LEVEL_BITFS] = 50,
        [LEVEL_BITS] = 110,
        [LEVEL_BOWSER_3] = 157,
        [LEVEL_SA] = 150,
    },
    noLobby = true,

    star_data = {
        [COURSE_COTMC] = { 8, 8, 8, 8, 8 },  -- Toxic-Switch of Danger
        [COURSE_BITDW] = { 8, 8, 8, 8 },     -- Bowser's Badlands-Battlefield
        [COURSE_WMOTR] = { 8, 8, 8, 8, 8, 8 }, -- Tower of the East
        [COURSE_TOTWC] = { 8, 8, 8 },        -- Lava-Switch of Eruption
        [COURSE_VCUTM] = { 8, 8, 8, 8, 8, 8 }, -- Dust-Switch of Identity
        [COURSE_PSS] = { 8, 8, 8, 8 },       -- Frozen Slide
        [COURSE_BITFS] = { 8, 8, 8, 8, 8 },  -- Bowser's Aquatic Castle
        [COURSE_SA] = { 8 },                 -- Champion's Challenge (there's another star but it is hard to get so we ignore in the time)
        [COURSE_BITS] = { 8, 8, 8, 8, 8, 8 }, -- Bowser's Crystal Palace
    },

    -- EE has some different counts
    star_data_ee = {
        [COURSE_COTMC] = { 8, 8, 8, 8, 8, 8 }, -- Toxic Terrace
        [COURSE_SA] = { 8, 8, 8, 8, 8, 8, 8 }, -- Triarc-Bridge
    },

    -- custom star names!
    starNames = {
        [161] = "The Tower's Top",
        [162] = "Hidden In The Towers",
        [163] = "Climbing The Scaffold",
        [164] = "Red Coins In Battle",
        [171] = "The Central Mountain",
        [172] = "Bowels Of The Castle",
        [173] = "Rush Along The Cliffside",
        [174] = "Cliffside Hike",
        [175] = "Diving For Red Coins",
        [181] = "Don't Look Down",
        [182] = "The Palace's Side Tower",
        [183] = "Slip Through The Cracks",
        [184] = "Among The Palace Rooftops",
        [185] = "The Thin Walkway",
        [186] = "16 Sinister Coins",
        [191] = "Steady Sliding Wins The Race",
        [192] = "Slippery Platforming!",
        [193] = "Off The Slide, Onto The Ledge",
        [194] = "Red Coins in The Frost",
        [201] = "Wheezing Wall Kicks",
        [202] = "Bright Down Low",
        [203] = "Secret In The Toxins",
        [204] = "A Breathtaking View",
        [205] = "Toxic Red Coins",
        [211] = "Tower Flight for Red Coins",
        [212] = "Secret Tower Storage",
        [213] = "Low, But Not Too Low",
        [221] = "Sunken In The Dust",
        [222] = "Tip-Toe Through The Dust",
        [223] = "8 Coins Of Identity",
        [224] = "Quick As A Hare",
        [225] = "Light As A Feather",
        [226] = "Highest of All",
        [231] = "Alcove Of The East",
        [232] = "Roof Of The Slide",
        [233] = "Bowser's Secret Treat",
        [234] = "East And West For Red Coins",
        [235] = "A Quick Climb",
        [236] = "The Central Tower's Loot",
        [241] = "A Super Champion",
        [243] = "The Champion Of All",
    },

    starNames_ee = {
        [161] = "Peeking Out The Tower",
        [162] = "Off In The Distance",
        [163] = "Trapped In The Towers",
        [164] = "Flowering Red Coins",
        [171] = "Breaking And Entering",
        [172] = "Surfin' On Sand Mountain",
        [173] = "Wall Kicks In The Pit",
        [174] = "Timed Jumps And Tricky Platforms",
        [175] = "The Pit's Crimson Coins",
        [181] = "Broken Burning Walkway",
        [182] = "Leaps O'er The Void",
        [183] = "THIRTY ????ING RED COINS",
        [184] = "Hole In The Wall",
        [185] = "Thin Wall Ledges",
        [186] = "Down The Deadly Slide",
        [191] = "End Of The Supply Chain",
        [192] = "Another Star In The Wall",
        [193] = "Tight Jumps Needed!",
        [194] = "8 Red Deliveries",
        [201] = "Tiny Platforms, Huge Jumps",
        [202] = "Scaling The Lava",
        [203] = "In The Terrace Depths",
        [204] = "Thread The Needle",
        [205] = "Atop The Terrace",
        [206] = "Coin Search In The Terrace",
        [211] = "How Low Can You Go?",
        [212] = "The Height Of Hell",
        [213] = "Devilish Red Coins",
        [221] = "Under The Arches",
        [222] = "Fast-Paced Delivery",
        [223] = "Slip Under The Mist",
        [224] = "Final Destination",
        [225] = "Dive Through The Dust",
        [226] = "Red Coins in The Fog",
        [231] = "The Lord's Red Coins",
        [232] = "Top Of The Broken Tower",
        [233] = "Corner In the Sky",
        [234] = "Long Leaps Above The Lake",
        [235] = "Sloped Triple Jumps",
        [236] = "Hidden Corner Of The Cave",
        [241] = "Red Coin Stroll",
        [242] = "Below The Hanging Floor",
        [243] = "Troll Under The Bridge",
        [244] = "Hidden in The Tower",
        [245] = "Towers Over The Void",
        [246] = "Under The Castle Wall",
        [247] = "Literally Under Ground",
    },
    
    mini_exclude = {
        [221] = 1, -- also excludes its equivalent in ee, unintentionally (I don't care that much)
    },

    -- extra hub stages (that aren't part of the castle)
    hubStages = {
        [COURSE_WMOTR] = 1, -- Tower Of The East
    },

    runner_victory = function(m)
        return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,

    -- prevent swap except by host
    special_run = function(m, gotStar)
        if m.playerIndex ~= 0 then return end
        --- @type NetworkPlayer
        local np = gNetworkPlayers[0]
        if gotStar and gGlobalSyncTable.ee and np.currLevelNum == LEVEL_SA then
            m.pos.x, m.pos.y, m.pos.z = 6044, 136, -5564 -- make this level possible without dying
            set_mario_action(m, ACT_SPAWN_NO_SPIN_AIRBORNE, 0)
        end
        if (np.currAreaIndex == 1) == gGlobalSyncTable.ee and gPlayerSyncTable[0].spectator ~= 1 then
            if network_is_server() then
                gGlobalSyncTable.ee = (np.currAreaIndex ~= 1)
                warpCooldown = 0
                close_menu()
            else
                if gGlobalSyncTable.ee then
                    djui_chat_message_create(trans("using_ee"))
                else
                    djui_chat_message_create(trans("not_using_ee"))
                end
                close_menu()
                warp_to_level(np.currLevelNum, np.currAreaIndex ~ 3, np.currActNum)
            end
        end
    end,
}
