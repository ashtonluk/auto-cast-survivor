//--- Content from folder: ./1-Variables Library System Func/1-GlobalsVariables.j ---

//Constant : A constant value does not change, and you use it to set fixed parameters in the game.         
globals 
    //We will define bj_ as a type of variable that is used and processed at a specific moment,         
    // is always redefined when it starts being used, and is assigned a null value when finished.         
    //Number          
    integer bj_int = 0 // Typically used for a single loop or assigning a random value.         
    real bj_real = 0.00 //Typically used for a single loop or assigning a random value.         
    //Objective          
    item bj_item = null // instead of bj_lastCreatedItem           
    unit bj_unit = null // instead of bj_lastCreatedUnit           
    effect bj_eff = null // instead of bj_lastCreatedEffect          
    location bj_loc = Location(0, 0) //Warning: Don't set bj_loc = Location() use MoveLocation instead  
    rect bj_rect = Rect(0, 0, 0, 0) //Warning: Don't set bj_loc = Location() use MoveLocation instead  
    texttag bj_texttag = null 
    timer bj_timer = null 
    //Storage          
    hashtable ht = InitHashtable() // This is the hashtable you will use in most situations of the game.            
    hashtable stats = InitHashtable() // For damage system    
    //Timer          
    constant real TIME_SETUP_EVENT = 0.2 // The time to start setting up events for the game.      
    constant real TIME_INTERVAL = 1.00 // You can use this varible for setting timer checking in game   (check file 6-Timers/1-Interval.j)  
    constant real P32 = 0.03125 // Explore this number; it truly has significance.         
    constant real P64 = 0.03125 * 2 // Explore this number; it truly has significance.       
    //Environment Dev      
    constant boolean ENV_DEV = false // Are u on a testing mode ?        

    //Utils          
    constant string SYSTEM_CHAT = "[SYSTEM]: |cffffcc00" 

    //Constant text       
    //===Example: set str = str + N       
    constant string N = "|n" 
    //===Example: set str = color + str + R       
    constant string R = "|r" 
    //===Example: set str = color + str + RN       
    constant string RN = "|r|n" 
    //Setting Game        
    constant real ARMOR_CONSTANT = 0.03 // Assign it with the value you set in the gameplay constant.    
    constant integer MAX_PLAYER = 24 
    constant integer MAX_SIZE_DIALOG_BUTTON = 24 
    constant boolean CREEP_SLEEP = false 
    constant boolean LOCK_RESOURCE_TRADING = true 
    constant boolean SHARED_ADVANCED_CONTROL = false 
    constant real GAME_PRELOAD_TIME = 0.01 
    constant real GAME_STATUS_TIME = 1.00 
    constant real GAME_SETTING_TIME = 3.00 
    constant real GAME_START_TIME = 5.00 

endglobals 



//--- Content from folder: ./1-Variables Library System Func/2-Library.j ---


//--- Content from folder: ./1-Variables Library System Func/2-Runtime.j ---
//I will use this for the skill writing section, so don’t worry about it if you don’t want to rewrite the library.
struct runtime
    static method new takes integer i, real timeout, boolean periodic, code func returns timer
        local timer t = CreateTimer()
        local integer id = GetHandleId(t)
        call SaveInteger(ht, id, 0, i)
        call SaveInteger(ht, id, 2, 0) 
        call SaveReal(ht, id, 1, timeout)
        call TimerStart(t, timeout, periodic, func)
        return t
    endmethod
    static method tick takes nothing returns integer 
        return LoadInteger(ht, GetHandleId(GetExpiredTimer()) , 2)
    endmethod
    static method get takes nothing returns integer 
        local integer id = GetHandleId(GetExpiredTimer())
        call SaveInteger(ht, id, 2, LoadInteger(ht, id, 2) + 1)
        return LoadInteger(ht, id, 0)
    endmethod
    static method count takes nothing returns real 
        local integer id = GetHandleId(GetExpiredTimer())
        return I2R(LoadInteger(ht, id, 2)) * LoadReal(ht, id, 1)
    endmethod
    static method end takes nothing returns nothing
        local timer t = GetExpiredTimer()
        call PauseTimer(t)
        call FlushChildHashtable(ht, GetHandleId(t))
        call DestroyTimer(t)
        set t = null
    endmethod
    static method endx takes timer t returns nothing
        call PauseTimer(t)
        call FlushChildHashtable(ht, GetHandleId(t))
        call DestroyTimer(t)
        set t = null
    endmethod
endstruct

//--- Content from folder: ./1-Variables Library System Func/3-Utils.j ---

///======= Preload Function   
// === When creating a new ability or unit that hasn't been used in the map,he game may experience a slight lag.   
// === Therefore, you should initialize them at the start of the game to ensure a smooth gameplay experience.  

function Preload_Unit takes integer id returns nothing 
    call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE) , id, 0, 0, 270)) 
endfunction 
   
function Preload_Item takes integer id returns nothing 
    call RemoveItem(CreateItem(id, 0, 0)) 
endfunction 
   
function Preload_Ability takes integer id returns nothing 
    local unit u = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE) , 'nzin', 0, 0, 270) 
    call UnitAddAbility(u, id) 
    call UnitRemoveAbility(u, id) 
    call RemoveUnit(u) 
    set u = null 
endfunction 
   
function Preload_Sound takes unit u, string path returns nothing 
    local sound s = CreateSound(path, false, true, true, 12700, 12700, "") 
    call SetSoundVolume(s, 100) 
    call AttachSoundToUnit(s, u) 
    call StartSound(s) 
    call KillSoundWhenDone(s) 
endfunction 

//====================================================================================  
///======= Ultils   






//--- Content from folder: ./1-Variables Library System Func/4a-DamageTextTag.j ---

struct TextDmg 
    static real text_size = 10 
    static real zOffset = 0 
    static real lifespan = 0.725 
    static real speed = 96 
    static real angle = 120 
    static boolean permanent = false 
    static real fadepoint = 1.00 
    static method setting takes texttag tt returns nothing 
        call Texttag.velocity(tt, .speed, .angle) 
        call Texttag.permanent(tt, .permanent) 
        call Texttag.fadepoint(tt, .fadepoint) 
        call Texttag.lifespan(tt, .lifespan) 
    endmethod 
    static method run takes string colorName, real dmg, unit victim, unit caster returns boolean 
        local integer cid = GetPlayerId(GetOwningPlayer(caster)) 
        local integer vid = GetPlayerId(GetOwningPlayer(victim)) 
        local texttag tt = null 
        if colorName == "Physical" then 
            set tt = Texttag.unit("-" + Num.ri2s(dmg) , victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 100.00, 100, 100, 0) 
        elseif colorName == "Spell" then
            set tt = Texttag.unit("-" + Num.ri2s(dmg) , victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 10.00, 50, 80, 0) 
        elseif colorName == "Cold" then
            set tt = Texttag.unit("-" + Num.ri2s(dmg) , victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 0.00, 60.00, 80.00, 0) 
        elseif colorName == "Poison" then
            set tt = Texttag.unit("-" + Num.ri2s(dmg) , victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 10.00, 100, 10.00, 0) 
        elseif colorName == "Fire" then
            set tt = Texttag.unit("-" + Num.ri2s(dmg) , victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 100.00, 20.00, 0.00, 0) 
        elseif colorName == "Lightning" then
            set tt = Texttag.unit("-" + Num.ri2s(dmg) , victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 93.00, 93.00, 0, 0)
        elseif colorName == "Crit" then
            set tt = Texttag.unit("-" + Num.ri2s(dmg) , victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 89.00, 51.00, 6.00, 0)
        elseif colorName == "Miss" then
            set tt = Texttag.unit("Miss !", victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 30.00, 74.00, 20.00, 0) 
        elseif colorName == "Block" then
            set tt = Texttag.unit("Block !", victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 70.00, 70.00, 70.00, 0) 
        elseif colorName == "Heal" then
            set tt = Texttag.unit("+" + Num.ri2s(dmg) , victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 0, 60, 0, 0) 
        elseif colorName == "HealMana" then
            set tt = Texttag.unit("+" + Num.ri2s(dmg) , victim, .zOffset, .text_size) 
            call Texttag.colorpercent(tt, 0, 0, 153, 0) 
        endif
        if tt != null then 
            call.setting(tt) 
            if(colorName == "Crit") then 
                call Texttag.text(tt, Num.ri2s(dmg) , .text_size + 3) 
            endif 
        endif 
        return false 
    endmethod 
endstruct 


//--- Content from folder: ./1-Variables Library System Func/4b-Damage.j ---
struct BSTAT 
    static integer crit_chance = StringHash("CritChance") 
    static integer crit_dmg = StringHash("CritDmg") 
    static real crit_dmg_default = 135 
    static real crit_chance_default = 0 

    static integer evasion = StringHash("Evasion") 
    static integer resist_spell = StringHash("ResistSpell") 
    static integer pierce_spell = StringHash("PierceSpell") 
endstruct 
struct DMGSTAT 
    static real dmg = 0.00 
    static unit victim 
    static unit caster 
    static attacktype ATK_TYPE 
    static damagetype DMG_TYPE 
    static integer uidc = 0 
    static integer uidv = 0 
    static integer idv = 0 
    static integer idc = 0 
    static real armor = 0.00 
    static real crit_dmg = 0.00 
    static real crit_chance = 0.00 
    static real evasion = 0.00 
    static real resist_spell = 0.00 
    static real pierce_spell = 0.00 

    static method f_Get_DMGSTAT takes nothing returns nothing 
        set.armor = BlzGetUnitArmor(DMGSTAT.victim) 
        set.uidc = GetUnitTypeId(DMGSTAT.caster) 
        set.uidv = GetUnitTypeId(DMGSTAT.victim) 
        set.idv = GetHandleId(DMGSTAT.victim) 
        set.idc = GetHandleId(DMGSTAT.caster) 
        set.crit_dmg = BSTAT.crit_dmg_default + (LoadReal(stats, .idc, BSTAT.crit_dmg)) 
        set.crit_chance = BSTAT.crit_chance_default + LoadReal(stats, .idc, BSTAT.crit_chance) 
        set.evasion = 0 + LoadReal(stats, .idv, BSTAT.evasion) 
        set.resist_spell = 0 + LoadReal(stats, .idv, BSTAT.resist_spell) 
        set.pierce_spell = 0 + LoadReal(stats, .idc, BSTAT.pierce_spell) 

    endmethod 
    static method f_Reset_DMGSTAT takes nothing returns nothing 
        set.uidc = 0 
        set.uidv = 0 
        set.idv = 0 
        set.idc = 0 
        set.armor = 0.00 
        set.crit_dmg = 0.00 
        set.crit_chance = 0.00 
        set.evasion = 0.00 
        set.resist_spell = 0.00 
        set.pierce_spell = 0.00 
      
    endmethod 
endstruct 
struct DMGEVENT 
    static trigger t = CreateTrigger() 
    private static method DamageEvent takes nothing returns nothing 
        call DisableTrigger(GetTriggeringTrigger()) 
        set DMGSTAT.caster = GetEventDamageSource() 
        set DMGSTAT.victim = BlzGetEventDamageTarget() 
        set DMGSTAT.dmg = GetEventDamage() 
        
        call TriggerExecute( .t) 
        set DMGSTAT.caster = null 
        set DMGSTAT.victim = null 
        call EnableTrigger(GetTriggeringTrigger()) 
    endmethod 
    static method Damaged takes nothing returns nothing 
        local string color_dmg_type 
        local real chance_hit = 0 
        // local boolean IsBoss = LoadBoolean(road, DMGSTAT.idv, StringHash("Boss")) 
        call DMGSTAT.f_Reset_DMGSTAT() 
        call DMGSTAT.f_Get_DMGSTAT() 
        set DMGSTAT.ATK_TYPE = BlzGetEventAttackType() 
        set DMGSTAT.DMG_TYPE = BlzGetEventDamageType() 
        if DMGSTAT.dmg > 0.00 then 
            //Text Damage                                        
            call Proc.BSTAT() 
            // if Math.rate(RMaxBJ(0, DMGSTAT.evasion - DMGSTAT.attack_rating)) then        
            if Math.rate(RMaxBJ(0, DMGSTAT.evasion)) then 
                // call BJDebugMsg("miss")                                        
                set chance_hit = 0 
            else 
                set chance_hit = 1 
            endif 

            if BlzGetEventAttackType() != ATTACK_TYPE_NORMAL then 
                set color_dmg_type = "Physical" 
                if BlzGetEventAttackType() == ATTACK_TYPE_CHAOS then 
                    set color_dmg_type = "Chao" 
                endif 
                if BlzGetEventAttackType() == ATTACK_TYPE_HERO then 

                endif 
                if BlzGetEventDamageType() == DAMAGE_TYPE_NORMAL then 
                

                    if(chance_hit > 0 and DMGSTAT.dmg > 0) then 
                      
                        call Proc.onHit() 

                        ///                                        
                        // call BJDebugMsg(R2S(DMGSTAT.crit_chance))                                        
                        if Math.rate(DMGSTAT.crit_chance) then 
                            // call BJDebugMsg(R2S(DMGSTAT.crit_dmg))                                        
                            set DMGSTAT.dmg = DMGSTAT.dmg * (DMGSTAT.crit_dmg / 100) 
                            set color_dmg_type = "Crit" 
                        endif 
                        call Proc.onStuck() 
                    else 
                        if(chance_hit == 0) then 
                            set DMGSTAT.dmg = 0 
                            set color_dmg_type = "Miss" 
                        endif 
                    endif 

                

                    if BlzGetEventAttackType() == ATTACK_TYPE_CHAOS then 
              
                    endif 
                    // if DMGSTAT.life_steal > 0 then   
                    //     // call BJDebugMsg("heal" + R2S(DMGSTAT.dmg * DMGSTAT.v_LifeSteal_DMGSTAT))                                        
                    //     // call EFFECT.Heal(DMGSTAT.dmg * DMGSTAT.v_LifeSteal_DMGSTAT, DMGSTAT.caster, DMGSTAT.caster)                                        
                    // endif   
                    if DMGSTAT.dmg <= 0 and color_dmg_type != "Miss" then 
                        set color_dmg_type = "Block" 
                    endif 
                endif 
               
            endif 
            // ATTACK TYPE : SPELL                                        
            if BlzGetEventAttackType() == ATTACK_TYPE_NORMAL then 
                //Calc Damage & Text                                        
                call Proc.SpellStat() 
                set color_dmg_type = "Spell" 
                // DAMAGE TYPE : COLD                                        
                if BlzGetEventDamageType() == DAMAGE_TYPE_COLD then 
                    set color_dmg_type = "Cold" 
                endif 
                // DAMAGE TYPE : POISON                                        
                if BlzGetEventDamageType() == DAMAGE_TYPE_POISON then 
                    set color_dmg_type = "Poison" 
                endif 
                if BlzGetEventDamageType() == DAMAGE_TYPE_SHADOW_STRIKE then 
                    set color_dmg_type = "Poison" 
                endif 
                if BlzGetEventDamageType() == DAMAGE_TYPE_DEATH then 
                    set color_dmg_type = "" 
                endif 
                if BlzGetEventDamageType() == DAMAGE_TYPE_DEMOLITION then 
                    set color_dmg_type = "" 
                endif 
                // DAMAGE TYPE : FIRE                                        
                if BlzGetEventDamageType() == DAMAGE_TYPE_FIRE then 
                    set color_dmg_type = "Fire" 
                endif 
                // DAMAGE TYPE: CHAIN OF LIGHNING                                        
                if BlzGetEventDamageType() == DAMAGE_TYPE_LIGHTNING then 
                    set color_dmg_type = "Lightning" 
                    //Healing Wave                        
                    if GetOwningPlayer(DMGSTAT.caster) == GetOwningPlayer(DMGSTAT.victim) then 
                        set color_dmg_type = "Heal" 
                        // Trick healing wave set - damage on ally then detect healing wave now 
                        // set DMGSTAT.dmg = 0  
                    endif 
                endif 
                // DAMAGE TYPE: Unknown                                        
                if BlzGetEventDamageType() == DAMAGE_TYPE_MAGIC then 
                    // Mana burn                                        
                endif 
                set DMGSTAT.resist_spell = DMGSTAT.resist_spell - DMGSTAT.pierce_spell 
                set DMGSTAT.dmg = RMaxBJ(0, DMGSTAT.dmg - (DMGSTAT.dmg * (DMGSTAT.resist_spell / 100))) 
            endif 
            
            if DMGSTAT.dmg <= 0 then 
                if color_dmg_type != "Miss" then 
                    set color_dmg_type = "Block" 
                endif 
            endif 
            // call BJDebugMsg(R2S(DMGSTAT.dmg))                                        
        endif 
       

        if Unit.life(DMGSTAT.victim) <= DMGSTAT.dmg + 1 or Unit.life(DMGSTAT.victim) <= DMGSTAT.dmg then 
            call Proc.onLastHit() 
        endif 
       
        call BlzSetEventDamage(DMGSTAT.dmg) 
        if(GetOwningPlayer(DMGSTAT.caster) != Player(10) and GetOwningPlayer(DMGSTAT.caster) != Player(11)) or((GetOwningPlayer(DMGSTAT.caster) == Player(10) or GetOwningPlayer(DMGSTAT.caster) == Player(11)) and(GetOwningPlayer(DMGSTAT.victim) != Player(10) and GetOwningPlayer(DMGSTAT.victim) != Player(11)) ) then 
            call TextDmg.run(color_dmg_type, DMGSTAT.dmg, DMGSTAT.victim, DMGSTAT.caster)     
        endif
    endmethod 
    private static method onInit takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, ConvertPlayerUnitEvent(308)) 
        call TriggerAddAction(t, function thistype.DamageEvent) 
        set t = null 
        call DisableTrigger( .t) 
        call TriggerAddAction( .t, function thistype.Damaged) 
    endmethod 
endstruct

//--- Content from folder: ./1-Variables Library System Func/4c-DamageProc.j ---
struct Proc 
    static method BSTAT takes nothing returns nothing 
        // call ItemStat.BonusRequire() //Item Stat          
        // call PassiveSkill.BSTATCalc()   
        // call BuffSkill.BSTATCalc()   
          
        if DMGSTAT.ATK_TYPE == ATTACK_TYPE_NORMAL then 
               
        endif 
    endmethod 
    static method SpellStat takes nothing returns nothing 
        if IsUnitType(DMGSTAT.caster, UNIT_TYPE_HERO) then 
            // set DMGSTAT.dmg = DMGSTAT.dmg + 100  
        endif 
    endmethod 
     
    static method onHit takes nothing returns nothing 
        local real d = 0 
        local real d2 = 0 
        local integer m = 0 
        // call HeroSkill.onHit()    
          
            
    endmethod 
    static method onStuck takes nothing returns nothing 
        local real r = 0 
        local string p = "" 
            
    endmethod 
    static method onLastHit takes nothing returns nothing 
        local real d = 0 
        local real x = 0 
        local real y = 0 
        
    endmethod 
endstruct 

//--- Content from folder: ./1-Variables Library System Func/MyCustomCode.j ---


//--- Content from folder: ./2-Objective/1a-PLAYER.j ---
struct PLAYER 
    static boolean array IsDisconect 


    //============PLAYER STATUS ==========
    static method IsPlayerOnline takes player p returns boolean 
        return GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(p) == MAP_CONTROL_USER 
    endmethod 
    //=============GOLD=================== 
    static method gold takes integer id returns integer 
        return GetPlayerState(Player(id) , PLAYER_STATE_RESOURCE_GOLD) 
    endmethod 
    static method setgold takes integer id, integer value returns nothing 
        call SetPlayerStateBJ(Player(id) , PLAYER_STATE_RESOURCE_GOLD, value) 
    endmethod 
    static method addgold takes integer id, integer value returns nothing 
        call AdjustPlayerStateBJ(value, Player(id) , PLAYER_STATE_RESOURCE_GOLD) 
    endmethod 
    //=============LUMBER=================== 
    static method lumber takes integer id returns integer 
        return GetPlayerState(Player(id) , PLAYER_STATE_RESOURCE_LUMBER) 
    endmethod 
    static method setlumber takes integer id, integer value returns nothing 
        call SetPlayerStateBJ(Player(id) , PLAYER_STATE_RESOURCE_LUMBER, value) 
    endmethod 
    static method addlumber takes integer id, integer value returns nothing 
        call AdjustPlayerStateBJ(value, Player(id) , PLAYER_STATE_RESOURCE_LUMBER) 
    endmethod 
    //=============FOODCAP=================== 
    static method food takes integer id returns integer 
        return GetPlayerState(Player(id) , PLAYER_STATE_RESOURCE_FOOD_USED) 
    endmethod 
    static method foodcap takes integer id returns integer 
        return GetPlayerState(Player(id) , PLAYER_STATE_RESOURCE_FOOD_CAP) 
    endmethod 
    static method setfoodcap takes integer id, integer value returns nothing 
        call SetPlayerStateBJ(Player(id) , PLAYER_STATE_RESOURCE_FOOD_CAP, value) 
    endmethod 
    static method addfoodcap takes integer id, integer value returns nothing 
        call AdjustPlayerStateBJ(value, Player(id) , PLAYER_STATE_RESOURCE_FOOD_CAP) 
    endmethod 
    //=============FLAG=================== 
    static method bountyflag takes integer id, boolean flag returns nothing 
        call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, flag, Player(id)) 
    endmethod 
    //=============RESEARCH=================== 
    static method SetResearchLevel takes integer tech_id, integer level, integer pid returns nothing 
        call SetPlayerTechResearchedSwap(tech_id, level, Player(pid)) 
    endmethod 
    //=============ALLIANCE=================== 
    static method SetAllyWith takes integer pid, integer to_pid returns nothing 
        call SetPlayerAllianceStateBJ(Player(pid) , Player(to_pid) , bj_ALLIANCE_ALLIED_VISION) 
    endmethod 
    static method SetEnemyWith takes integer pid, integer to_pid, boolean share_vision returns nothing 
        if share_vision then 
            call SetPlayerAllianceStateBJ(Player(pid) , Player(to_pid) , bj_ALLIANCE_UNALLIED_VISION) 
        else 
            call SetPlayerAllianceStateBJ(Player(pid) , Player(to_pid) , bj_ALLIANCE_UNALLIED) 
        endif 
    endmethod 
    static method SetNeutralWith takes integer pid, integer to_pid, boolean share_vision returns nothing 
        if share_vision then 
            call SetPlayerAllianceStateBJ(Player(pid) , Player(to_pid) , bj_ALLIANCE_NEUTRAL_VISION) 
        else 
            call SetPlayerAllianceStateBJ(Player(pid) , Player(to_pid) , bj_ALLIANCE_NEUTRAL) 
        endif 
    endmethod 
    //=============CHAT=================== 
    // You want to notify a specific player in the form of a system message. Use this:          
    static method systemchat takes player ForPlayer, string message returns nothing 
        local string msg = "" 
        set msg = SYSTEM_CHAT + message + "|r" 
        if(GetLocalPlayer() == ForPlayer) then 
            // call ClearTextMessages()                 
            call DisplayTimedTextToPlayer(ForPlayer, 0, 0, 2.00, message) 
        endif 
    endmethod 
    static method questmsgplayer takes player p, string msg, integer msgtype returns nothing 
        if GetLocalPlayer() == p then 
            call.questmsg(GetLocalPlayer() , msg, msgtype) 
        endif 
    endmethod 

    static method questmsgforce takes force f, string msg, integer msgtype returns nothing 
        if(IsPlayerInForce(GetLocalPlayer() , f)) then 
            call.questmsg(GetLocalPlayer() , msg, msgtype) 
        endif 
    endmethod 
    static method questmsg takes player p, string message, integer msgtype returns nothing 
        if(msgtype == Questmsg.DISCOVERED) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_QUEST, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_QUEST, message) 
            call StartSound(bj_questDiscoveredSound) 
            call FlashQuestDialogButton() 
        elseif(msgtype == Questmsg.UPDATED) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_QUESTUPDATE, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_QUESTUPDATE, message) 
            call StartSound(bj_questUpdatedSound) 
            call FlashQuestDialogButton() 
        elseif(msgtype == Questmsg.COMPLETED) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_QUESTDONE, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_QUESTDONE, message) 
            call StartSound(bj_questCompletedSound) 
            call FlashQuestDialogButton() 
        elseif(msgtype == Questmsg.FAILED) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_QUESTFAILED, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_QUESTFAILED, message) 
            call StartSound(bj_questFailedSound) 
            call FlashQuestDialogButton() 
        elseif(msgtype == Questmsg.REQUIREMENT) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_QUESTREQUIREMENT, message) 
        elseif(msgtype == Questmsg.MISSIONFAILED) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_MISSIONFAILED, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_MISSIONFAILED, message) 
            call StartSound(bj_questFailedSound) 
        elseif(msgtype == Questmsg.HINT) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_HINT, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_HINT, message) 
            call StartSound(bj_questHintSound) 
        elseif(msgtype == Questmsg.ALWAYSHINT) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_ALWAYSHINT, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_ALWAYSHINT, message) 
            call StartSound(bj_questHintSound) 
        elseif(msgtype == Questmsg.SECRET) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_SECRET, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_SECRET, message) 
            call StartSound(bj_questSecretSound) 
        elseif(msgtype == Questmsg.UNITACQUIRED) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_UNITACQUIRED, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_UNITACQUIRED, message) 
            call StartSound(bj_questHintSound) 
        elseif(msgtype == Questmsg.UNITAVAILABLE) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_UNITAVAILABLE, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_UNITAVAILABLE, message) 
            call StartSound(bj_questHintSound) 
        elseif(msgtype == Questmsg.ITEMACQUIRED) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_ITEMACQUIRED, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_ITEMACQUIRED, message) 
            call StartSound(bj_questItemAcquiredSound) 
        elseif(msgtype == Questmsg.WARNING) then 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_WARNING, " ") 
            call DisplayTimedTextToPlayer(p, 0, 0, bj_TEXT_DELAY_WARNING, message) 
            call StartSound(bj_questWarningSound) 
        else 
            // Unrecognized message type - ignore the request.                                      
        endif 
    endmethod 
    //=============MISC=================== 
    //Force player use a key in board
    static method ForceUIKeyBJ takes player whichPlayer, string key, unit u returns nothing 
        if(GetLocalPlayer() == whichPlayer) then 
            // Use only local code (no net traffic) within this block to avoid desyncs.        
            call ClearSelection() 
            call SelectUnit(u, true) 
            call ForceUIKey(key) 
        endif 
    endmethod 
    //Ping minimap     
    static method PingMinimapExe takes player p, real x, real y, real duration, integer red, integer green, integer blue, boolean extraEffects returns nothing 
        if IsPlayerAlly(GetLocalPlayer() , p) then 
            call PingMinimapEx(x, y, duration, red, green, blue, extraEffects) 
        endif 
        set p = null 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/1b-TIMERDIALOG.j ---
  
//Uses : see code in file EXAMPLE.j
struct CountdownTimer 
    timer t = null 
    timerdialog td = null 
    method newdialog takes string title, real timeout, boolean periodic, code func returns nothing 
        set.t = CreateTimer() 
        call TimerStart( .t, timeout, periodic, func) 
        set.td = CreateTimerDialog( .t) 
        call TimerDialogSetTitle( .td, title) 
        call TimerDialogDisplay( .td, true) 
    endmethod 
    method pause takes boolean status returns nothing 
        if status then 
            call PauseTimer( .t) 
        else 
            call ResumeTimer( .t) 
        endif 
    endmethod 
    method title takes string title returns nothing 
        call TimerDialogSetTitle( .td, title) 
    endmethod 
    method titlecolor takes integer red, integer green, integer blue, integer transparency returns nothing 
        call TimerDialogSetTitleColor( .td, red, green, blue, transparency) 
    endmethod 
    method timercolor takes integer red, integer green, integer blue, integer transparency returns nothing 
        call TimerDialogSetTimeColor( .td, red, green, blue, transparency) 
    endmethod 
    method display takes boolean status returns nothing 
        call TimerDialogDisplay( .td, status) 
    endmethod 
    method displayx takes boolean status, player p returns nothing 
        if(GetLocalPlayer() == p) then 
            // Use only local code (no net traffic) within this block to avoid desyncs.       
            call TimerDialogDisplay( .td, status) 
        endif 
    endmethod 
    method destroytd takes nothing returns nothing 
        call DestroyTimerDialog( .td) 
        call DestroyTimer( .t) 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/1c-MULTIBOARD.j ---
//Uses : see code in file EXAMPLE.j
struct Multiboard 
    multiboard mb 
    multiboarditem mbitem = null 

    method new takes integer rows, integer cols, string title returns nothing 
        set.mb = CreateMultiboard() 
        call MultiboardSetRowCount( .mb, rows) 
        call MultiboardSetColumnCount( .mb, cols) 
        call MultiboardSetTitleText( .mb, title) 
        call MultiboardDisplay( .mb, true) 
    endmethod 
    method display takes boolean status returns nothing 
        call MultiboardDisplay( .mb, status) 
    endmethod 
    method displayx takes boolean status, player p returns nothing 
        if(GetLocalPlayer() == p) then 
            // Use only local code (no net traffic) within this block to avoid desyncs.                  
            call MultiboardDisplay( .mb, status) 
        endif 
    endmethod 
    method minimize takes boolean minimize returns nothing 
        call MultiboardMinimize( .mb, minimize) 
    endmethod 
    method clear takes nothing returns nothing 
        call MultiboardClear( .mb) 
    endmethod 
    method title takes string title returns nothing 
        call MultiboardSetTitleText( .mb, title) 
    endmethod 
    method colortitle takes integer red, integer green, integer blue, integer transparency returns nothing 
        call MultiboardSetTitleTextColor( .mb, red, green, blue, transparency) 
    endmethod 
    method rowcount takes integer row returns nothing 
        call MultiboardSetRowCount( .mb, row) 
    endmethod 
    method colcount takes integer col returns nothing 
        call MultiboardSetColumnCount( .mb, col) 
    endmethod 
    //Dont use it.    
    method finditem takes integer col, integer row returns nothing 
        local integer curRow = 0 
        local integer curCol = 0 
        local integer numRows = MultiboardGetRowCount( .mb) 
        local integer numCols = MultiboardGetColumnCount( .mb) 
        loop 
            set curRow = curRow + 1 
            exitwhen curRow > numRows 
            if(row == 0 or row == curRow) then 
                set curCol = 0 
                loop 
                    set curCol = curCol + 1 
                    exitwhen curCol > numCols 
                    if(col == 0 or col == curCol) then 
                        set.mbitem = MultiboardGetItem( .mb, curRow - 1, curCol - 1) 
                    endif 
                endloop 
            endif 
        endloop 
    endmethod 
    //Show value and icon in col of row     
    method setstyle takes integer col, integer row, boolean showValue, boolean showIcon returns nothing 
        call.finditem(col, row) 
        call MultiboardSetItemStyle( .mbitem, showValue, showIcon) 
        call MultiboardReleaseItem( .mbitem) 
    endmethod 
    method setvalue takes integer col, integer row, string val returns nothing 
        call.finditem(col, row) 
        call MultiboardSetItemValue( .mbitem, val) 
        call MultiboardReleaseItem( .mbitem) 
    endmethod 
    method setcolor takes integer col, integer row, integer red, integer green, integer blue, integer transparency returns nothing 
        call.finditem(col, row) 
        call MultiboardSetItemValueColor( .mbitem, red, green, blue, transparency) 
        call MultiboardReleaseItem( .mbitem) 
    endmethod 
    method setwidth takes integer col, integer row, real width returns nothing 
        call.finditem(col, row) 
        call MultiboardSetItemWidth( .mbitem, width / 100.0) 
        call MultiboardReleaseItem( .mbitem) 
    endmethod 
    method seticon takes integer col, integer row, string path returns nothing 
        call.finditem(col, row) 
        call MultiboardSetItemIcon( .mbitem, path) 
        call MultiboardReleaseItem( .mbitem) 
    endmethod 
    method destroymb takes nothing returns nothing 
        call DestroyMultiboard( .mb)
    endmethod
endstruct

//--- Content from folder: ./2-Objective/1d-FRAMEHANDLE.j ---

//Frame is in a higher category of map editing; I only provide a simple solution for this section.
struct Frame 
    static key KEY_FF 
    static method init takes nothing returns nothing 
        call BlzLoadTOCFile("war3mapImported\\ek_frame2.toc") 
    endmethod 
    static method hidex takes integer id, framehandle f returns nothing 
        if GetLocalPlayer() == Player(id) then 
            call BlzFrameSetVisible(f, false) 
        endif 
    endmethod 
    static method showx takes integer id, framehandle f returns nothing 
        if GetLocalPlayer() == Player(id) then 
            call BlzFrameSetVisible(f, true) 
        endif 
    endmethod 
    static method hide takes framehandle f returns nothing 
        call BlzFrameSetVisible(f, false) 
    endmethod 
    static method show takes framehandle f returns nothing 
        call BlzFrameSetVisible(f, true) 
    endmethod 
    static method fixed takes integer id returns nothing 
        local framehandle f = null 
        if GetHandleId(GetTriggerEventId()) == 310 then    
            set f = BlzGetTriggerFrame() 
            if f != null then 
                if GetLocalPlayer() == Player(id) then 
       
                    call BlzFrameSetEnable(f, false) 
                    call BlzFrameSetEnable(f, true) 
                endif 
            endif 
            set f = null 
        endif 
    endmethod 
    static method debug takes nothing returns nothing 
        call.fixed(Num.pid(GetTriggerPlayer())) 
    endmethod 
    static method get takes nothing returns framehandle 
        return BlzGetTriggerFrame() 
    endmethod 
    static method texts takes integer id, framehandle f, string txt returns nothing 
        if GetLocalPlayer() == Player(id) then 
            call BlzFrameSetText(f, txt) 
        endif 
    endmethod 
    static method text takes string s returns framehandle 
        local framehandle ff = BlzCreateSimpleFrame("TextUnitLevel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) , 0) 
        call BlzFrameSetLevel(ff, 6) 
        set ff = BlzGetFrameByName("TextUnitLevelValue", 0) 
        call BlzFrameSetText(ff, s) 
        return ff 
    endmethod 
    static method text_noshadow takes string s returns framehandle 
        local framehandle ff = BlzCreateSimpleFrame("TextUnitLevelNS", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) , 0) 
        call BlzFrameSetLevel(ff, 6) 
        set ff = BlzGetFrameByName("TextUnitLevelValueNS", 0) 
        call BlzFrameSetText(ff, s) 
        return ff 
    endmethod 

    static method imagex takes string s, integer level returns framehandle 
        local framehandle ff 
        local framehandle f_goc = BlzCreateSimpleFrame("TestTexture", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) , 0) 
        set ff = BlzGetFrameByName("TestTextureValue", 0) 
        call BlzFrameSetTexture(ff, s, 0, true) 
        call BlzFrameSetLevel(f_goc, level) 
        call BlzFrameClearAllPoints(f_goc) 
        call SaveFrameHandle(ht, .KEY_FF, GetHandleId(f_goc) , ff) 
        set ff = null 
        return f_goc 
    endmethod 
    static method base takes framehandle A, framehandle theparent returns nothing 
        call BlzFrameSetPoint(A, FRAMEPOINT_BOTTOMLEFT, theparent, FRAMEPOINT_BOTTOMLEFT, 0, 0) 
        call BlzFrameSetPoint(A, FRAMEPOINT_TOPRIGHT, theparent, FRAMEPOINT_TOPRIGHT, 0, 0) 
    endmethod 
    static method movex takes framehandle ff, real X, real Y, real x, real y returns nothing 
        call BlzFrameSetAbsPoint(ff, FRAMEPOINT_TOPRIGHT, x + X, y + Y) 
        call BlzFrameSetAbsPoint(ff, FRAMEPOINT_BOTTOMLEFT, x, y) 
    endmethod 
    static method changetexture takes framehandle ff, string icon returns nothing 
        call BlzFrameSetTexture(LoadFrameHandle(ht, .KEY_FF, GetHandleId(ff)) , icon, 0, true) 
    endmethod 
    static method changetexturex takes integer id, framehandle ff, string icon returns nothing 
        local framehandle f = LoadFrameHandle(ht, .KEY_FF, GetHandleId(ff)) 
        if f != null then 
            if GetLocalPlayer() == Player(id) then 
                call BlzFrameSetTexture(f, icon, 0, true) 
            endif 
        endif 
        set f = null 
    endmethod 
    static method button takes string path returns framehandle 
        local framehandle ff 
        local framehandle ff2 
        set ff2 = BlzCreateFrameByType("GLUEBUTTON", "FaceButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) , "ScoreScreenTabButtonTemplate", 0) 
        set ff = BlzCreateFrameByType("BACKDROP", "FaceButtonIcon", ff2, "", 0) 
        call BlzFrameSetAllPoints(ff, ff2) 
        call BlzFrameSetTexture(ff, path, 0, true) 
        call SaveFrameHandle(ht, .KEY_FF, GetHandleId(ff2) , ff) 
        set ff = null 
        return ff2 
    endmethod 
    static method buttonNoTexture takes nothing returns framehandle 
        local framehandle ff2 
        set ff2 = BlzCreateFrameByType("GLUEBUTTON", "FaceButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) , "ScoreScreenTabButtonTemplate", 0) 
        return ff2 
    endmethod
    static method texture takes string path returns framehandle 
        local framehandle ff 
        local framehandle ff2 
        set ff2 = BlzCreateFrameByType("GLUECHECKBOX", "FaceButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) , "ScoreScreenTabButtonTemplate", 0) 
        set ff = BlzCreateFrameByType("BACKDROP", "FaceButtonIcon", ff2, "", 0) 
        call BlzFrameSetAllPoints(ff, ff2) 
        call BlzFrameSetTexture(ff, path, 0, true) 
        call SaveFrameHandle(ht, .KEY_FF, GetHandleId(ff2) , ff) 
        set ff = null 
        return ff2 
    endmethod 
    static method tooltip takes framehandle btn, real size, string desc returns framehandle 
        local framehandle bg = BlzCreateFrame("BoxedTextVH", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) , 0, 0) 
        local framehandle txt = BlzCreateFrameByType("TEXT", "MyScriptDialogButtonTooltip", bg, "", 0) 
        call BlzFrameSetLevel(bg, 9) 
        call BlzFrameSetSize(txt, size, 0) 
        call BlzFrameSetPoint(bg, FRAMEPOINT_BOTTOMLEFT, txt, FRAMEPOINT_BOTTOMLEFT, -0.01, -0.01) 
        call BlzFrameSetPoint(bg, FRAMEPOINT_TOPRIGHT, txt, FRAMEPOINT_TOPRIGHT, 0.01, 0.01) 
        call BlzFrameSetTooltip(btn, bg) 
        call BlzFrameSetPoint(txt, FRAMEPOINT_BOTTOM, btn, FRAMEPOINT_TOP, 0, 0.01) 
        call BlzFrameSetText(txt, desc) 
        call BlzFrameSetEnable(txt, false) 
        return txt 
    endmethod 
    static method click takes framehandle ff, code youfunc returns trigger 
        local trigger t = CreateTrigger() 
        call BlzTriggerRegisterFrameEvent(t, ff, FRAMEEVENT_CONTROL_CLICK) 
        call TriggerAddCondition(t, Condition(youfunc)) 
        return t 
    endmethod 
    static method enter takes framehandle ff, code youfunc returns trigger 
        local trigger t = CreateTrigger() 
        call BlzTriggerRegisterFrameEvent(t, ff, FRAMEEVENT_MOUSE_ENTER) 
        call TriggerAddCondition(t, Condition(youfunc)) 
        return t 
    endmethod 
    static method leave takes framehandle ff, code youfunc returns trigger 
        local trigger t = CreateTrigger() 
        call BlzTriggerRegisterFrameEvent(t, ff, FRAMEEVENT_MOUSE_LEAVE) 
        call TriggerAddCondition(t, Condition(youfunc)) 
        return t 
    endmethod 
    // units\NightElf\SpiritOfVengeance\Black128.blp //Black background    
    static method TOOLTIPBG takes framehandle fparent returns framehandle 
        local framehandle bg = BlzCreateFrameByType("BACKDROP", "BACKDROP" + I2S( .KEY_FF) , BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) , "", 1) 
        call BlzFrameSetVisible(bg, false) 
        call BlzFrameSetTexture(bg, "war3mapImported\\tooltipBG.blp", 0, true) 
        return bg 
    endmethod 
    static method TOOLTIPICON takes framehandle fparent, string path returns framehandle 
        local framehandle bg = BlzCreateFrameByType("BACKDROP", "BACKDROP" + I2S( .KEY_FF) , fparent, "", 1) 
        call BlzFrameSetTexture(bg, path, 0, true) 
        return bg 
    endmethod 
    static method TOOLTIPTXT takes framehandle bg, real size, string desc returns framehandle 
        local framehandle txt = BlzCreateFrameByType("TEXT", "TEXT" + I2S( .KEY_FF) , bg, "", 0) 
        call BlzFrameSetEnable(txt, false) 
        call BlzFrameSetSize(txt, size, 0) 
        call BlzFrameSetText(txt, desc) 
        return txt 
    endmethod 
    static method TOOLTIPTITLE takes framehandle bg, real size, string desc returns framehandle 
        local framehandle txt = BlzCreateFrameByType("TEXT", "TEXT" + I2S( .KEY_FF) , bg, "", 0) 
        call BlzFrameSetEnable(txt, false) 
        call BlzFrameSetSize(txt, size, 0) 
        call BlzFrameSetText(txt, desc) 
        return txt 
    endmethod 
    static method TOOLTIPCOMBINE takes framehandle fparent, framehandle txt, framehandle bg returns nothing 
        call BlzFrameSetPoint(bg, FRAMEPOINT_BOTTOMLEFT, txt, FRAMEPOINT_BOTTOMLEFT, -0.01, -0.01) 
        call BlzFrameSetPoint(bg, FRAMEPOINT_TOPRIGHT, txt, FRAMEPOINT_TOPRIGHT, 0.01, 0.01) 
        call BlzFrameSetTooltip(fparent, bg) 
        call BlzFrameSetPoint(txt, FRAMEPOINT_TOP, fparent, FRAMEPOINT_BOTTOM, 0.010, -0.02) 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/1e-LEADERBOARD.j ---
//I don't use leaderboard and not have experience for do it...

// call CreateLeaderboardBJ( GetPlayersAll(), "TRIGSTR_040" )    
// call DestroyLeaderboardBJ( GetLastCreatedLeaderboard() )    
// call LeaderboardSortItemsBJ( GetLastCreatedLeaderboard(), bj_SORTTYPE_SORTBYVALUE, false )    
// call LeaderboardDisplayBJ( false, GetLastCreatedLeaderboard() )    
// call LeaderboardSetLabelBJ( GetLastCreatedLeaderboard(), "TRIGSTR_042" )    
// call LeaderboardSetLabelColorBJ( GetLastCreatedLeaderboard(), 100, 80, 20, 0 )    
// call LeaderboardSetValueColorBJ( GetLastCreatedLeaderboard(), 100, 80, 20, 0 )    
// call LeaderboardSetStyleBJ( GetLastCreatedLeaderboard(), true, true, true, true )    
// call LeaderboardAddItemBJ( Player(0), GetLastCreatedLeaderboard(), "TRIGSTR_044", 0 )    
// call LeaderboardRemovePlayerItemBJ( Player(0), GetLastCreatedLeaderboard() )    
// call LeaderboardSetPlayerItemLabelBJ( Player(0), GetLastCreatedLeaderboard(), "TRIGSTR_046" )    
// call LeaderboardSetPlayerItemLabelColorBJ( Player(0), GetLastCreatedLeaderboard(), 100, 80, 20, 0 )    
// call LeaderboardSetPlayerItemValueBJ( Player(0), GetLastCreatedLeaderboard(), 0 )    
// call LeaderboardSetPlayerItemValueColorBJ( Player(0), GetLastCreatedLeaderboard(), 100, 80, 20, 0 )    
// call LeaderboardSetPlayerItemStyleBJ( Player(0), GetLastCreatedLeaderboard(), true, true, true )  

//Uses : see code in file EXAMPLE.j
// struct Leaderboard 
//     leaderboard lb 
//     method new takes string title returns nothing 
//         set.lb = CreateLeaderboard() 
//         call LeaderboardSetLabel(.lb, title) 
//     endmethod 
//     method setforce takes force f, boolean display returns nothing 
//         call ForceSetLeaderboardBJ(.lb, f) 
//         call LeaderboardDisplay(.lb, display) 
//     endif 
//     method display takes boolean status returns nothing 
//         call LeaderboardDisplay(.lb, status) 
//     endmethod 
//     method displayx takes boolean status, player p returns nothing 
//         if(GetLocalPlayer() == p) then 
//             // Use only local code (no net traffic) within this block to avoid desyncs.                     
//             call LeaderboardDisplay(.lb, status) 
//         endif 
//     endmethod 
//     method setlabel takes string label returns nothing 
//         local integer size = LeaderboardGetItemCount(lb) 
//         call LeaderboardSetLabel(.lb, label) 
//         if(LeaderboardGetLabelText(.lb) == "") then 
//             set size = size - 1 
//         endif 
//         call LeaderboardSetSizeByItemCount(lb, size) 
//     endmethod 

//     method destroylb takes boolean status returns nothing 
//         call DestroyLeaderboard(.lb) 
//     endmethod 
// endstruct

//--- Content from folder: ./2-Objective/1e-Quest.j ---
struct Questmsg 
    static integer DISCOVERED = 0 
    static integer UPDATED = 1 
    static integer COMPLETED = 2 
    static integer FAILED = 3 
    static integer REQUIREMENT = 4 
    static integer MISSIONFAILED = 5 
    static integer ALWAYSHINT = 6 
    static integer HINT = 7 
    static integer SECRET = 8 
    static integer UNITACQUIRED = 9 
    static integer UNITAVAILABLE = 10 
    static integer ITEMACQUIRED = 11 
    static integer WARNING = 12 
endstruct 
struct Questtype 
    static integer REQ_DISCOVERED = 0 
    static integer OPT_DISCOVERED = 2 
    static integer REQ_UNDISCOVERED = 1 
    static integer OPT_UNDISCOVERED = 3 
endstruct 
//Make only one time with .new () deafeat condition in quest tab , change it with .desc if you change condition to defeat                
struct DeafeatQuest 
    static method new takes string desc returns nothing 
        set bj_lastCreatedDefeatCondition = CreateDefeatCondition() 
        call DefeatConditionSetDescription(bj_lastCreatedDefeatCondition, desc) 
        call FlashQuestDialogButton() 
    endmethod 
    static method desc takes string str returns nothing 
        call DefeatConditionSetDescription(bj_lastCreatedDefeatCondition, str) 
        call FlashQuestDialogButton() 
    endmethod 
    static method destroydq takes string desc returns nothing 
        call DestroyDefeatCondition(bj_lastCreatedDefeatCondition) 
    endmethod 
endstruct 

struct Quest 
    quest q = null 
    //new ( questType,  title,  description,  iconPath)   
    method new takes integer questType, string title, string description, string iconPath returns nothing 
        local boolean required = (questType == 0) or(questType == 1) 
        local boolean discovered = (questType == 0) or(questType == 2) 
        set.q = CreateQuest() 
        call QuestSetTitle( .q, title) 
        call QuestSetDescription( .q, description) 
        call QuestSetIconPath( .q, iconPath) 
        call QuestSetRequired( .q, required) 
        call QuestSetDiscovered( .q, discovered) 
        call QuestSetCompleted( .q, false) 
    endmethod 
 
  
    //GET       
    //======Status    
    method enabled takes nothing returns boolean 
        return IsQuestEnabled( .q) 
    endmethod 
    method completed takes nothing returns boolean 
        return IsQuestCompleted( .q) 
    endmethod 
    method failed takes nothing returns boolean 
        return IsQuestFailed( .q) 
    endmethod 
    method discovered takes nothing returns boolean 
        return IsQuestDiscovered( .q) 
    endmethod 
    method required takes nothing returns boolean 
        return IsQuestRequired( .q) 
    endmethod 
    //SET       
    //=====Status    
    method setenabled takes boolean status returns nothing 
        call QuestSetEnabled( .q, status) 
    endmethod 
    method setcompleted takes boolean status returns nothing 
        call QuestSetCompleted( .q, status) 
    endmethod 
    method setfailed takes boolean status returns nothing 
        call QuestSetFailed( .q, status) 
    endmethod 
    method setdiscovered takes boolean status returns nothing 
        call QuestSetDiscovered( .q, status) 
    endmethod 
    method setrequired takes boolean status returns nothing 
        call QuestSetRequired( .q, status) 
    endmethod 
    //=====Content    
    method title takes string str returns nothing 
        call QuestSetTitle( .q, str) 
    endmethod 
    method desc takes string str returns nothing 
        call QuestSetDescription( .q, str) 
    endmethod 

    /////////////       
    method flash takes nothing returns nothing 
        call FlashQuestDialogButton() 
    endmethod 
    method destroyq takes nothing returns nothing 
        call DestroyQuest( .q) 
    endmethod 
   
endstruct 

struct Questitem 
    questitem qi = null 
    method new takes quest q, string description returns nothing 
        set.qi = QuestCreateItem(q) 
        call QuestItemSetDescription( .qi, description) 
        call QuestItemSetCompleted( .qi, false) 
    endmethod 
    method desc takes string str returns nothing 
        call QuestItemSetDescription( .qi, str) 
    endmethod 
    method completed takes nothing returns boolean 
        return IsQuestItemCompleted( .qi) 
    endmethod 
    method setcompleted takes boolean status returns nothing 
        call QuestItemSetCompleted( .qi, status) 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/1f-DIALOG-BUTTON.j ---
struct Dialog 
    dialog d = DialogCreate() 
    button array btn[MAX_SIZE_DIALOG_BUTTON] 
    integer i = -1 
    trigger t = null 
    method displayx takes boolean flag, player p returns nothing 
        call DialogDisplay(p, .d, flag) 
    endmethod 
    method title takes string str returns nothing 
        call DialogSetMessage( .d, str) 
    endmethod 
    method event takes code func returns nothing 
        set.t = CreateTrigger() 
        call TriggerRegisterDialogEventBJ( .t, .d) 
        call TriggerAddAction( .t, func) 
    endmethod 
    //hotkey default 0    
    method addbtn takes string btn_text, integer hotkey returns button 
        set.i = .i + 1 
        set.btn[ .i] = DialogAddButton( .d, btn_text, hotkey) 
        return.btn[i] 
    endmethod 
    method find takes button btn returns integer 
        local integer res = -1 
        set bj_int = 0 
        loop 
            exitwhen bj_int > .i 
            if.btn[bj_int] == btn then 
                set res = bj_int 
                exitwhen true 
            endif 
            set bj_int = bj_int + 1 
        endloop 
        return res 
    endmethod 
    //When button click u end the game, careful to use :))   
    method addbtnquit takes string btn_text, boolean endgame, integer hotkey returns nothing 
        set.i = .i + 1 
        set.btn[ .i] = DialogAddQuitButton( .d, endgame, btn_text, hotkey) 
    endmethod 
    method destroyd takes nothing returns nothing 
        call DialogClear( .d) 
        call DialogDestroy( .d) 
        call DestroyTrigger( .t) 
        call.destroy() 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/1g----------------------.j ---


//--- Content from folder: ./2-Objective/3a-UNIT.j ---
//Call struct then Unit instead UNIT        
struct Unit 
    //=================Position================================           
    static method x takes unit u returns real 
        return GetUnitX(u) 
    endmethod 
    static method y takes unit u returns real 
        return GetUnitY(u) 
    endmethod 
    static method z takes unit u returns real 
        return GetUnitFlyHeight(u) 
    endmethod 
    method setx takes unit u, real x returns nothing 
        call SetUnitX(u, x) 
    endmethod 
    method sety takes unit u, real y returns nothing 
        call SetUnitY(u, y) 
    endmethod 
    // Set Flying Height (Required unit have crow form or fly)              
    // Use: Unit.setz(u,height)              
    method setz takes unit u, real height returns nothing 
        call SetUnitFlyHeight(u, height, 0.) 
    endmethod 

    
    //==================Movespeed=========================           
    // Reset MoveSpeed of unit to default           
    method resetms takes unit whichUnit returns nothing 
        call SetUnitMoveSpeed(whichUnit, GetUnitDefaultMoveSpeed(whichUnit)) 
    endmethod 
    // Get MoveSpeed of unit           
    // Use: Unit.ms(u)             
    method ms takes unit whichUnit returns real 
        return GetUnitMoveSpeed(whichUnit) 
    endmethod 

    //==================Vertex Color=========================           
    //Reset Vertex Color [Change Color and Alpha of Unit]           
    //Use:  Unit.resetvertexcolor(u)            
    method resetvertexcolor takes unit u returns nothing 
        call SetUnitVertexColor(u, 255, 255, 255, 255) 
    endmethod 

    //Set Vertex Color [Change Color and Alpha of Unit]           
    //Use:  Unit.vertexcolor(u)            
    method vertexcolor takes unit u, integer red, integer green, integer blue, integer alpha returns nothing 
        call SetUnitVertexColor(u, red, green, blue, alpha) 
    endmethod 

    //==================Misc=========================         
    //Get scaling value of unit      
    static method size takes unit u returns real 
        return BlzGetUnitRealField(u, UNIT_RF_SCALING_VALUE) 
    endmethod 
    //Set scaling value of unit      
    static method setsize takes unit u, real r returns nothing 
        call BlzSetUnitRealField(u, UNIT_RF_SCALING_VALUE, r) 
        call SetUnitScale(u, r, r, r) 
    endmethod 
    //Get level unit or hero       
    static method lv takes unit u returns integer 
        local integer i = GetHeroLevel(u) 
        if i < 0 then 
            return GetUnitLevel(u) 
        endif 
        return i 
    endmethod 

    // Get Collision of unit u              
    // Use: Unit.collision(u)              
    method collision takes unit u returns real 
        local real l = 0 
        local real h = 300 
        local real m = 150 
        local real nm = 0 
        local real x = GetUnitX(u) 
        local real y = GetUnitY(u) 
        loop 
            if(IsUnitInRangeXY(u, x + m, y, 0)) then 
                set l = m 
            else 
                set h = m 
            endif 
            set nm = (l + h) / 2 
            exitwhen nm + .001 > m and nm - .001 < m 
            set m = nm 
        endloop 
        return R2I(m * 10) / 10. 
    endmethod 
    //==================== Ability =======================       
    static method abilv takes unit u, integer a returns integer 
        local integer i = 0 
        set i = GetUnitAbilityLevel(u, a) 
        return i 
    endmethod 
    static method setabilv takes unit u, integer a, integer lv returns nothing 
        call SetUnitAbilityLevel(u, a, lv) 
    endmethod 
    static method removeabi takes unit u, integer a returns nothing 
        call UnitRemoveAbility(u, a) 
    endmethod 
    static method haveabi takes unit u, integer a returns boolean 
        return GetUnitAbilityLevel(u, a) > 0 
    endmethod 
    static method addabi takes unit u, integer a returns nothing 
        call UnitAddAbility(u, a) 
        call UnitMakeAbilityPermanent(u, true, a) 
    endmethod 
    static method hideabi takes unit u, integer a returns nothing 
        call BlzUnitHideAbility(u, a, true) 
    endmethod 
    static method showabi takes unit u, integer a returns nothing 
        call BlzUnitDisableAbility(u, a, false, false) 
    endmethod 
    static method disabledabi takes unit u, integer a returns nothing 
        call BlzUnitDisableAbility(u, a, true, false) 
    endmethod 
    //===========================STATS========================    
    static method damage_reduce takes unit u returns real 
        return(BlzGetUnitArmor(u) * ARMOR_CONSTANT) / (1 + ARMOR_CONSTANT * BlzGetUnitArmor(u)) 
    endmethod 
    static method mana takes unit u returns real 
        return GetUnitState(u, UNIT_STATE_MANA) 
    endmethod 
    static method life takes unit u returns real 
        return GetUnitState(u, UNIT_STATE_LIFE) 
    endmethod 
    static method maxlife takes unit u returns real 
        return GetUnitState(u, UNIT_STATE_MAX_LIFE) 
    endmethod 
    static method maxmana takes unit u returns real 
        return GetUnitState(u, UNIT_STATE_MAX_MANA) 
    endmethod 
    static method setlife takes unit v, real newVal returns nothing 
        call SetUnitState(v, UNIT_STATE_LIFE, newVal) 
    endmethod 
    static method addlife takes unit v, real newVal returns nothing 
        call SetUnitState(v, UNIT_STATE_LIFE, GetUnitState(v, UNIT_STATE_LIFE) + newVal) 
    endmethod 
    static method setmana takes unit v, real newVal returns nothing 
        call SetUnitState(v, UNIT_STATE_MANA, newVal) 
    endmethod 
    static method addmana takes unit v, real newVal returns nothing 
        call SetUnitState(v, UNIT_STATE_MANA, GetUnitState(v, UNIT_STATE_MANA) + newVal) 
    endmethod 
    //Status   
    static method ispause takes unit u returns boolean 
        return IsUnitPaused(u) 
    endmethod 
    //Item   
    //Return inventory size of unit (0-6) 0 is not have
    static method invsize takes unit u returns integer 
        return UnitInventorySize(u) 
    endmethod 

    private static method onInit takes nothing returns nothing 
        local thistype this = thistype.create() 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/3b-HERO.j ---

struct Hero extends Unit 
    static method str takes unit u returns integer 
        return GetHeroStr(u, true) 
    endmethod 
    static method setstr takes unit u, integer value, boolean flag returns nothing 
        call SetHeroStr(u, value, flag) 
    endmethod 
    static method int takes unit u returns integer 
        return GetHeroInt(u, true) 
    endmethod 
    static method setint takes unit u, integer value, boolean flag returns nothing 
        call SetHeroInt(u, value, flag) 
    endmethod 
    static method agi takes unit u returns integer 
        return GetHeroAgi(u, true) 
    endmethod 
    static method setagi takes unit u, integer value, boolean flag returns nothing 
        call SetHeroAgi(u, value, flag) 
    endmethod 
    static method all takes unit u returns integer 
        return GetHeroAgi(u, true) + GetHeroInt(u, true) + GetHeroStr(u, true) 
    endmethod 
    static method revive takes unit u, real x, real y, boolean flag returns nothing 
        call ReviveHero(u, x, y, flag) 
    endmethod 
    static method addexp takes unit u, integer value, boolean flag returns nothing 
        call AddHeroXP(u, value, flag) 
    endmethod 
    static method setlv takes unit u, integer level, boolean flag returns nothing 
        call SetHeroLevel(u, level, flag) 
    endmethod 
    static method propername takes unit u, integer level, boolean flag returns nothing 
        call GetHeroProperName(u) 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/3c-ITEM.j ---
struct Item 
    // Charge Item     
    static method removecharge takes item i, integer req returns nothing 
        call SetItemCharges(i, GetItemCharges(i) -req) 
        if GetItemCharges(i) <= 0 then 
            call RemoveItem(i) 
        endif 
    endmethod 
endstruct 


//--- Content from folder: ./2-Objective/3d-DESTRUCTABLE.j ---
struct DESTRUCTABLE //Destructable  
    static method OpenGate takes destructable d returns nothing 
        call KillDestructable(d) 
        call SetDestructableAnimation(d, "death alternate") 
        set d = null 
    endmethod 
    
    static method DestroyGate takes destructable d returns nothing 
        call KillDestructable(d) 
        call SetDestructableAnimation(d, "death") 
        set d = null 
    endmethod 
    
    static method CloseGate takes destructable d returns nothing 
        call DestructableRestoreLife(d, GetDestructableMaxLife(d) , true) 
        call SetDestructableAnimation(d, "stand") 
        set d = null 
    endmethod 
endstruct 


//--- Content from folder: ./2-Objective/3e-GROUP.j ---
struct Group 
    static method pick takes group g returns unit 
        return FirstOfGroup(g) 
    endmethod 
    static method get takes group whichGroup, integer index returns unit 
        return BlzGroupUnitAt(whichGroup, index) 
    endmethod 
    static method size takes group whichGroup returns integer 
        return BlzGroupGetSize(whichGroup) 
    endmethod 
    static method add takes unit whichUnit, group whichGroup returns boolean 
        return GroupAddUnit(whichGroup, whichUnit) 
    endmethod 
    static method remove takes unit whichUnit, group whichGroup returns boolean 
        return GroupRemoveUnit(whichGroup, whichUnit) 
    endmethod 
    static method have takes unit whichUnit, group whichGroup returns boolean 
        return IsUnitInGroup(whichUnit, whichGroup) 
    endmethod 
    static method release takes group whichGroup returns nothing 
        call GroupClear(whichGroup) 
        call DestroyGroup(whichGroup) 
    endmethod 
    static method enum takes group whichGroup, real x, real y, real radius returns nothing 
        call GroupEnumUnitsInRange(whichGroup, x, y, radius, null) 
    endmethod 
    static method enump takes group whichGroup, player p returns nothing 
        call GroupEnumUnitsOfPlayer(whichGroup, p, null) 
    endmethod 
    static method new takes nothing returns group 
        return CreateGroup() 
    endmethod 
endstruct 

//--- Content from folder: ./2-Objective/4-TEXTTAG.j ---

struct Texttag 
    //Use:                    
    //set bj_loc = MoveLocation(x,y)                    
    //call TEXTTAG.newloc(str, bj_loc, z , size)                      
    static method new takes string str, location loc, real zoffset, real size returns texttag 
        set bj_texttag = CreateTextTag() 
        call SetTextTagText(bj_texttag, str, (size * 0.023) / 10) 
        call SetTextTagPos(bj_texttag, GetLocationX(loc) , GetLocationY(loc) , zoffset) 
        call SetTextTagColor(bj_texttag, 255, 255, 255, 255) 
        return bj_texttag 
    endmethod 
    static method unit takes string str, unit u, real zoffset, real size returns texttag 
        set bj_texttag = CreateTextTag() 
        call SetTextTagText(bj_texttag, str, (size * 0.023) / 10) 
        call SetTextTagPosUnit(bj_texttag, u, zoffset) 
        call SetTextTagColor(bj_texttag, 255, 255, 255, 255) 
        return bj_texttag 
    endmethod 
    static method last takes nothing returns texttag 
        return bj_texttag 
    endmethod 
    //Use: call TEXTTAG.color(tt,0-255,0-255,0-255,0-255,0-255)                      
    static method color takes texttag tt, integer red, integer green, integer blue, integer transparency returns nothing 
        call SetTextTagColor(tt, red, green, blue, transparency) 
    endmethod 
    static method colorpercent takes texttag tt, real red, real green, real blue, real transparency returns nothing 
        call SetTextTagColor(tt, PercentToInt(red, 255) , PercentToInt(green, 255) , PercentToInt(blue, 255) , PercentToInt((100.0 - transparency) , 255)) 
    endmethod 
    static method age takes texttag tt, real age returns nothing 
        call SetTextTagAge(tt, age) 
    endmethod 
    static method lifespan takes texttag tt, real lifespan returns nothing 
        call SetTextTagLifespan(tt, lifespan) 
    endmethod 
    static method fadepoint takes texttag tt, real fadepoint returns nothing 
        call SetTextTagFadepoint(tt, fadepoint) 
    endmethod 
    static method velocity takes texttag tt, real speed, real angle returns nothing 
        local real vel = (speed * 0.071) / 128 
        local real xvel = vel * Cos(angle * bj_DEGTORAD) 
        local real yvel = vel * Sin(angle * bj_DEGTORAD) 
        call SetTextTagVelocity(tt, xvel, yvel) 
    endmethod 
    static method permanent takes texttag tt, boolean flag returns nothing 
        call SetTextTagPermanent(tt, flag) 
    endmethod 
    static method suspended takes texttag tt, boolean flag returns nothing 
        call SetTextTagSuspended(tt, flag) 
    endmethod 
    static method text takes texttag tt, string str, real size returns nothing 
        call SetTextTagText(tt, str, (size * 0.023) / 10) 
    endmethod 
    //Uses: Move texttag to point of unit           
    static method posunit takes texttag tt, unit u, real zoffset returns nothing 
        call SetTextTagPosUnit(tt, u, zoffset) 
    endmethod 
    //Uses: Move texttag to point x ,y           
    //set bj_loc = MoveLocation(x,y)                    
    //call TEXTTAG.posloc(str, bj_loc, z , size)                
    static method posloc takes texttag tt, location loc, real zoffset returns nothing 
        call SetTextTagPos(tt, GetLocationX(loc) , GetLocationY(loc) , zoffset) 
    endmethod 
    static method showforce takes texttag tt, force whichForce, boolean show returns nothing 
        if(IsPlayerInForce(GetLocalPlayer() , whichForce)) then 
            // Use only local code (no net traffic) within this block to avoid desyncs.         
            call SetTextTagVisibility(tt, show) 
        endif 
    endmethod 
    static method destroytt takes texttag tt returns nothing 
        call DestroyTextTag(tt) 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/5-EFFECT.j ---
struct Eff
    static method new takes string path, real x, real y, real z returns effect 
        set bj_eff = AddSpecialEffect(path, x, y) 
        call BlzSetSpecialEffectZ(bj_eff, z) 
        return bj_eff 
    endmethod
    static method add takes unit u, string s returns effect //su dung attach effect vao unit        
        return AddSpecialEffectTarget(s, u, "chest") 
    endmethod
    static method nova takes string s, real x, real y returns nothing //nova effect of XY        
        call DestroyEffect(AddSpecialEffect(s, x, y)) 
    endmethod
    static method attach takes string s, unit u , string attach returns nothing //nova effect attach unit chest        
        call DestroyEffect(AddSpecialEffectTarget(s, u, attach)) 
    endmethod
    static method pos takes effect e, real x, real y, real z returns nothing //move XYZ        
        call BlzSetSpecialEffectPosition(e, x, y, z) 
    endmethod
    static method angle takes effect e, real angle returns nothing //set goc'        
        call BlzSetSpecialEffectYaw(e, angle * bj_DEGTORAD) 
    endmethod
    static method pitch takes effect e, real angle returns nothing //set do ngieng        
        call BlzSetSpecialEffectPitch(e, angle * bj_DEGTORAD) 
    endmethod
    static method roll takes effect e, real angle returns nothing //set do lang        
        call BlzSetSpecialEffectRoll(e, angle * bj_DEGTORAD) 
    endmethod
    static method size takes effect e, real size returns nothing //set size        
        call BlzSetSpecialEffectScale(e, size) 
    endmethod
    static method height takes effect e, real height returns nothing //255        
        call BlzSetSpecialEffectHeight(e, height) 
    endmethod
    static method speed takes effect e, real speed returns nothing //animation speed        
        call BlzSetSpecialEffectTimeScale(e, speed) 
    endmethod
    static method alpha takes effect e, integer alpha returns nothing //255        
        call BlzSetSpecialEffectAlpha(e, alpha) 
    endmethod
    static method pc takes effect e, player p returns nothing //color player        
        call BlzSetSpecialEffectColorByPlayer(e, p) 
    endmethod
    static method color takes effect e, integer r, integer g, integer b returns nothing //color R G B        
        call BlzSetSpecialEffectColor(e, r, g, b) //color        
    endmethod
    static method remove takes effect e returns nothing //destroy        
        call DestroyEffect(e) 
    endmethod
    static method time takes effect e, real time returns nothing //destroy        
        call BlzSetSpecialEffectTime(e, time / 32) 
    endmethod
endstruct

//--- Content from folder: ./2-Objective/6a-DUMMY.j ---

//Use :                               
// Order :                           
//==> call DUMMY.target("thunderbolt",target, ability_id , level_of_ability) [Search order name of spell u add]                            
// But it's only work for use make some effect to enemy (please select target allow in skill is Air,Ground )  
//when you use freedom dummy then u need use newx, it's will return new dummy  
struct Dummy 
    static integer dummy_id = 'e000' //Set your id dummy                                 
    static unit load = null 
    static method new takes nothing returns nothing 
        set.load = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE) , .dummy_id, 0, 0, 0) 
        call UnitAddAbility( .load, 'Avul') 
        call UnitAddAbility( .load, 'Aloc') 
        call DestroyTimer(GetExpiredTimer()) 
    endmethod 
    static method newx takes integer pid returns unit 
        set bj_unit = CreateUnit(Player(pid) , .dummy_id, 0, 0, 0) 
        call UnitAddAbility(bj_unit, 'Avul') 
        call UnitAddAbility(bj_unit, 'Aloc') 
        return bj_unit 
    endmethod 
    static method target takes string ordername, unit dummy, unit u, integer spell_id, integer level returns nothing 
        call SetUnitX(dummy, GetUnitX(u)) 
        call SetUnitY(dummy, GetUnitY(u)) 
        call UnitAddAbility(dummy, spell_id) 
        call SetUnitAbilityLevel(dummy, spell_id, level) 
        call IssueTargetOrder(dummy, ordername, u) 
        call UnitRemoveAbility(dummy, spell_id) 
    endmethod 
    static method point takes string ordername, unit dummy, real x, real y, integer level, integer spell_id returns nothing 
        call SetUnitX(dummy, x) 
        call SetUnitY(dummy, y) 
        call UnitAddAbility(dummy, spell_id) 
        call SetUnitAbilityLevel(dummy, spell_id, level) 
        call MoveLocation(bj_loc, x, y) 
        call IssuePointOrderLoc(dummy, ordername, bj_loc) 
        call UnitRemoveAbility(dummy, spell_id) 
    endmethod 
    static method notarget takes string ordername, unit dummy, real x, real y, integer level, integer spell_id returns nothing 
        call SetUnitX(dummy, x) 
        call SetUnitY(dummy, y) 
        call UnitAddAbility(dummy, spell_id) 
        call SetUnitAbilityLevel(dummy, spell_id, level) 
        call IssueImmediateOrder(bj_unit, ordername) 
        call UnitRemoveAbility(dummy, spell_id) 
    endmethod 
    private static method onInit takes nothing returns nothing 
        call TimerStart(CreateTimer() , 1, false, function thistype.new) 
    endmethod 
endstruct 

//--- Content from folder: ./2-Objective/6b-DEBUFF.j ---
struct Buff 
    static boolean array is_target 
    static boolean array is_point 
    static boolean array is_notarget 
    static string array order_name 
    static integer array ability_id 
    static integer id = -1 
    static integer STUN = 0 
    static integer SLOW = 0 
    private static method newbuff takes boolean is_target, boolean is_point, boolean is_notarget, string order_name, integer ability_id returns nothing 
        set.id = .id + 1 
        set.is_target[ .id] = is_target 
        set.is_point[ .id] = is_point 
        set.is_notarget[ .id] = is_notarget 
        set.order_name[ .id] = order_name 
        set.ability_id[ .id] = ability_id 
        call Preload_Ability(ability_id) 
    endmethod 
    static method effect takes unit caster, unit target, integer buff_id, real x, real y, integer buff_lv, integer buff_dur returns boolean 
        if ENV_DEV then 
            call PLAYER.systemchat(Player(0) , "[] buff_id:" + I2S(buff_id) + " [] level: " + I2S(buff_lv)) 
        endif 
        //You can custom buff your rule, here is example                                       
        if buff_id > -1 and buff_id <= id then 
            if.is_target[buff_id] and not IsUnitDeadBJ(target) and target != null then 
                call Dummy.target( .order_name[buff_id] , Dummy.load, target, .ability_id[buff_id] , buff_lv) 
                // if ENV_DEV then         
                //     call PLAYER.systemchat(Player(0), "[] Target")         
                // endif         
                return false 
            endif 
            if.is_point[buff_id] then 
                call Dummy.newx(Num.pid(GetOwningPlayer(caster))) 
                call UnitApplyTimedLife(bj_unit, 'BTLF', buff_dur) // time for u finish cast or channeling spell then dummy will destroy      
                call Dummy.point( .order_name[buff_id] , Dummy.load, x, y, buff_lv, .ability_id[buff_id]) 

                return false 
            endif 
            if.is_notarget[buff_id] then 
                call Dummy.newx(Num.pid(GetOwningPlayer(caster))) 
                call UnitApplyTimedLife(bj_unit, 'BTLF', buff_dur) // time for u finish cast or channeling spell then dummy will destroy      
                call Dummy.notarget( .order_name[buff_id] , Dummy.load, x, y, buff_lv, .ability_id[buff_id]) 
                return false 
            endif 
        endif 
        return false 
    endmethod 
    private static method onInit takes nothing returns nothing 
        call.newbuff(true, false, false, "creepthunderbolt", 'A001') 
        set.STUN = .id 
        call.newbuff(true, false, false, "slow", 'A002') 
        set.SLOW = .id 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/6d----------------------.j ---


//--- Content from folder: ./2-Objective/7a-NUMBER.j ---
struct Num 
    // Percent to real :                   
    // Use: Math.p2r(100,60) = 60% of 100 = 60                   
    static method p2r takes real CurrentNumber, real Percent returns real 
        return CurrentNumber * (Percent / 100) 
    endmethod 
    static method r2i takes real r returns integer 
        return R2I(r) 
    endmethod 
    static method i2r takes integer i returns real 
        return I2R(i) 
    endmethod 
    static method ri2s takes real r returns string 
        return I2S(R2I(r)) 
    endmethod 
    //====================================================================================  
    ///======Player   
    static method pid takes player whichPlayer returns integer 
        return GetPlayerId(whichPlayer) 
    endmethod 
   
    static method uid takes unit u returns integer 
        return GetPlayerId(GetOwningPlayer(u)) 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/7b-BOOLEAN.j ---
struct Boo 
    //Boolean to String 
    static method b2s takes boolean b returns string 
        if b then 
            return "True" 
        endif 
        return "False" 
    endmethod 
endstruct

//--- Content from folder: ./2-Objective/7c-STRING.j ---
struct Str
    //Use:  Str.repeated(1234567,",",3,0) -> 123,456,7 
    static method repeated takes string s, string str, integer spacing, integer start returns string 
        local integer i = StringLength(s) 
        local integer p = 1 
        loop 
            exitwhen p * spacing + start >= i 
            set s = SubString(s, 0, p * spacing + p + start - 1) + str + SubString(s, p * spacing + p + start - 1, StringLength(s)) 
            set p = p + 1 
        endloop 
        return s 
    endmethod 
    //Use: Str.reverse("1234") -> 4321
    static method reverse takes string s returns string
        local integer i = StringLength(s)
        local string rs = ""
        loop
            set i = i - 1
            set rs = rs + SubString(s, i, i + 1)
            exitwhen i == 0
        endloop
        return rs
    endmethod
endstruct 

//--- Content from folder: ./2-Objective/7d.MATH.j ---
struct Math 
    static method rate takes real r returns boolean
        local real rand = 0 
        set rand = GetRandomReal(0, 100) 
        if rand != 0 and rand <= r then 
            return true 
        endif  
        return false 
    endmethod
    //Calculates the terrain height (Z-coordinate) at a specified (x, y) location in the game               
    //Use: Math.pz(x,y)              
    static method pz takes real x, real y returns real 
        call MoveLocation(bj_loc, x, y) 
        return GetLocationZ(bj_loc) 
    endmethod 

    //Calculate the angle between two points. Facing (x1,y1) to (x2,y2)               
    //Use: Math.ab(x1,y1,x2,y2)              
    static method ab takes real x1, real y1, real x2, real y2 returns real 
        return bj_RADTODEG * Atan2(y2 - y1, x2 - x1) 
    endmethod 

    //Calculate the angle between two units. Facing u to u2               
    //Use: Math.abu(u,u2)              
    static method abu takes unit u, unit u2 returns real 
        local real x1 = GetUnitX(u) 
        local real y1 = GetUnitY(u) 
        local real x2 = GetUnitX(u2) 
        local real y2 = GetUnitY(u2) 
        return bj_RADTODEG * Atan2(y2 - y1, x2 - x1) 
    endmethod 

    //Calculate the distance between two points         
    //Use: Math.db(x1,y1,x2,y2)            
    static method db takes real x1, real y1, real x2, real y2 returns real 
        local real dx = x2 - x1 
        local real dy = y2 - y1 
        return SquareRoot(dx * dx + dy * dy) 
    endmethod 
    
    //Calculate the distance between two units         
    //Use: Math.dbu(u,u2)         
    static method dbu takes unit u, unit u2 returns real 
        local real dx = GetUnitX(u2) -GetUnitX(u) 
        local real dy = GetUnitY(u2) -GetUnitY(u) 
        return SquareRoot(dx * dx + dy * dy) 
    endmethod 
    
    //calculates the new X-coordinate when moving a certain distance in a specified direction (angle) from a starting point    
    //Use: Math.ppx(currentX,distance,angle)       
    static method ppx takes real x, real dist, real angle returns real 
        return x + dist * Cos(angle * bj_DEGTORAD) 
    endmethod 

    //calculates the new Y-coordinate when moving a certain distance in a specified direction (angle) from a starting point       
    //Use: Math.ppy(currentY,distance,angle)       
    static method ppy takes real y, real dist, real angle returns real 
        return y + dist * Sin(angle * bj_DEGTORAD) 
    endmethod 

    //calculates the combined height of a unit in the game, which consists of the terrain height at the unit's location and the unit's flying height above the ground.     
    //Use: Math.uz(u)       
    static method uz takes unit u returns real 
        call MoveLocation(bj_loc, GetUnitX(u) , GetUnitY(u)) 
        return GetLocationZ(bj_loc) + GetUnitFlyHeight(u) 
    endmethod 

  
endstruct

//--- Content from folder: ./2-Objective/7e-RANDOM.j ---

//About code : https://docs.google.com/document/d/1WXxXdxNFZzz-QFSk-mtlMsDn1jJUn9v5NOE83cVnAC8/edit?usp=sharing  
//Uses check example in 4-Event/10- Player - Chat.j 
//====Variables in struct  
//  static Randompool pool1  
//====Setting  
// set.pool1 = Randompool.create()  
// call.pool1.new_value(1, 50, 0, 0)  
// call.pool1.new_value(2, 30, 0, 5)  
// call.pool1.new_value(3, 20, 0, 2)  
//====Call when want random 
// set random_value = .pool1.random()  
//====Destroy => use one time 
// call .pool1.destroy()  

//Set size array 10 to higher if u have more value             
struct Randompool 
    integer array value[99] //Use for raw or number or id item                                 
    real array rate_default[99] //Constant rate default                                 
    real array rate[99] // Rate now of item                                 
    real array increase[99] //When drop call a time, rate = rate + increase                                 
    integer times //When the drop call a time, it increase 1                                  
    integer size = - 1 
    method add_rare takes Randompool rp returns nothing 
        call rp.new_value('I00F', 1, 0, 0)  //Amulet of Spell Shield
        call rp.new_value('I00E', 1, 0, 0)  //Ancient Janggo of Endurance
        call rp.new_value('I00K', 1, 0, 0)  //Legion Doom-Horn
        call rp.new_value('I00J', 1, 0, 0)  //Scourge Bone Chimes
        call rp.new_value('I00G', 1, 0, 0)  //Staff of Teleportation
        call rp.new_value('I00H', 1, 0, 0)  //The Lion Horn of Stormwind
        call rp.new_value('I00I', 1, 0, 0)  //Warsong Battle Drums
    endmethod
    method is_rare takes integer id returns boolean 
        local Randompool pool_item_rare
        local integer n = 0
        local boolean b = false
        set pool_item_rare = Randompool.create()
        call.add_rare(pool_item_rare)
        loop
            exitwhen n > pool_item_rare.size
            if id == pool_item_rare.value[n] then 
                set b = true 
                exitwhen true 
            endif
            set n = n + 1
        endloop
        call pool_item_rare.destroy()
        return b
    endmethod
    method rare_drop takes nothing returns integer 
        local Randompool pool_item_rare
        local integer v = 0
        set pool_item_rare = Randompool.create()
        call pool_item_rare.add_rare(pool_item_rare)
        set v = pool_item_rare.random()
        call pool_item_rare.destroy()
        return v
    endmethod
    method new_value takes integer value, integer rate_default, integer rate, integer increase returns nothing 
        set.size = .size + 1 
        set.value[ .size] = value 
        set.rate_default[ .size] = rate_default 
        set.rate[ .size] = rate + rate_default 
        set.increase[ .size] = increase 
    endmethod 
    method update_rate takes nothing returns nothing 
        set bj_int = 0 
        loop 
            exitwhen bj_int > .size 
            set.rate[bj_int] = .rate[bj_int] + .increase[bj_int] 
            set bj_int = bj_int + 1 
        endloop 
    endmethod 
    method total takes nothing returns real 
        local real total = 0 
        set bj_int = 0 
        loop 
            exitwhen bj_int > .size 
            set total = total + .rate[bj_int] 
            set bj_int = bj_int + 1 
        endloop 
        return total 
    endmethod 
    method random takes nothing returns integer 
        local integer v = - 1 
        local real total = 0 
        local real random_val = 0 
        local real accumulated = 0 
        set total = .total() 
  
        set random_val = GetRandomReal(0, total) 
        if ENV_DEV then 
            call BJDebugMsg("random_val: " + R2S(random_val) + " / " + "Total: " + R2S(total)) 
            call BJDebugMsg("Number of Value Random: " + I2S( .size + 1)) 
        endif 
        set bj_int = 0 
        loop 
            exitwhen bj_int > .size 
            set accumulated = accumulated + .rate[bj_int] 
            if random_val <= accumulated then 
                set v = .value[bj_int] 
                call.action(bj_int) // Make some stupid code                
                call.update_rate() 
                set.times = .times + 1 
                if(ModuloInteger( .times, 25) == 0 and.times != 0) then 
                    set v = .rare_drop()
                    // set bj_lastCreatedItem = CreateItem(v, 0, 0)
                    // call BJDebugMsg("times:" + I2S(.times) + " || index: " + I2S(-5) + " - " + GetItemName(bj_lastCreatedItem))
                    // call RemoveItem(bj_lastCreatedItem)
                    // call BJDebugMsg(I2S(v))
                endif
                exitwhen true 
            endif 
            set bj_int = bj_int + 1 
        endloop 
        if ENV_DEV then 
            call BJDebugMsg(".accumulated: " + R2S(accumulated) + " [] Values: " + R2S(v) + "[] Times: " + R2S(times)) 
        endif 

        return v 
    endmethod 
    method action takes integer index returns nothing 
        //Code for example                  
        if(ModuloInteger( .times, 25) == 0 and.times != 0) then 
            set bj_lastCreatedItem = CreateItem( .value[index] , 0, 0)
            call BJDebugMsg("25 Times! Critical drop rare item ! [[" + GetItemName(bj_lastCreatedItem) + "]]") 
            // call BJDebugMsg("times:" + I2S(.times) + " || index: " + I2S(index) + " - " + GetItemName(bj_lastCreatedItem))
            call RemoveItem(bj_lastCreatedItem)
            //Reset when the value [9] drop                 
            set bj_int = 0 
            loop 
                exitwhen bj_int > .size 
                set.rate[bj_int] = .rate_default[bj_int] 
                set bj_int = bj_int + 1 
            endloop 
        endif 
        if.is_rare( .value[index]) and not(ModuloInteger( .times, 25) == 0 and.times != 0) then 
            // call BJDebugMsg("Critical DROP! reset rate to default") 
            // call BJDebugMsg("Critical drop rare item !") 
            set bj_lastCreatedItem = CreateItem( .value[index] , 0, 0)

            call BJDebugMsg("Critical drop rare item ! [[" + GetItemName(bj_lastCreatedItem) + "]]") 

            // call BJDebugMsg("times:" + I2S(.times) + " || index: " + I2S(index) + " - " + GetItemName(bj_lastCreatedItem))
            call RemoveItem(bj_lastCreatedItem)
        endif 
    endmethod 
endstruct 


//--- Content from folder: ./2-Objective/7f---------------------.j ---


//--- Content from folder: ./2-Objective/8-HASHTABLE.j ---


//--- Content from folder: ./3-Skill/1-SampleSkill.j ---
struct SKILL 
    unit caster = null 
    unit target = null 
    unit u = null 
    group g = null 
    damagetype DMG_TYPE = null 
    attacktype ATK_TYPE = null 
    integer time = 0 

    real speed = 0.00 
    real dmg = 0.00 
    real aoe = 0.00 
    real a = 0.00 
    real x = 0.00 
    real y = 0.00 
    real z = 0.00 

    integer buff_id 
    integer buff_lv 
    integer buff_dur 

    effect missle = null 
    string missle_path = "" 
    real missle_size = 0.00 
    boolean is_touch = false 

    boolean ALLOW_GROUND = true 
    boolean ALLOW_FLYING = true 

    boolean ALLOW_HERO = true 
    boolean ALLOW_STRUCTURE = true 
    boolean ALLOW_MECHANICAL = true 
    boolean ALLOW_ENEMY = true 
    boolean ALLOW_ALLY = true 
    boolean ALLOW_MAGIC_IMMUNE = true 

    boolean ALLOW_ALIVE = true 
    method FilterCompare takes boolean is, boolean yes, boolean no returns boolean 
        return(is and yes) or((not is) and no) 
    endmethod 
    method setxyz takes real x, real y, real z returns nothing 
        set.x = x 
        set.y = y 
        set.z = z 
    endmethod 
    method setallow takes boolean ALLOW_HERO, boolean ALLOW_STRUCTURE, boolean ALLOW_FLYING, boolean ALLOW_GROUND, boolean ALLOW_MECHANICAL, boolean ALLOW_ALIVE, boolean ALLOW_MAGIC_IMMUNE returns nothing 
        set.ALLOW_GROUND = ALLOW_GROUND 
        set.ALLOW_FLYING = ALLOW_FLYING 
        set.ALLOW_HERO = ALLOW_HERO 
        set.ALLOW_STRUCTURE = ALLOW_STRUCTURE 
        set.ALLOW_MECHANICAL = ALLOW_MECHANICAL 
        set.ALLOW_ENEMY = ALLOW_ENEMY 
        set.ALLOW_ALLY = ALLOW_ALLY 
        set.ALLOW_MAGIC_IMMUNE = ALLOW_MAGIC_IMMUNE 
        set.ALLOW_ALIVE = ALLOW_ALIVE 
    endmethod 
    method FilterUnit takes unit u, unit caster returns boolean 
        if not.FilterCompare(IsUnitAlly(u, GetOwningPlayer(caster)) , .ALLOW_ALLY, .ALLOW_ENEMY) then 
            return false 
        endif 
        if IsUnitType(u, UNIT_TYPE_HERO) and not.ALLOW_HERO then 
            return false 
        endif 
        if IsUnitType(u, UNIT_TYPE_STRUCTURE) and not.ALLOW_STRUCTURE then 
            return false 
        endif 
        if IsUnitType(u, UNIT_TYPE_FLYING) and not.ALLOW_FLYING then 
            return false 
        endif 
        if IsUnitType(u, UNIT_TYPE_GROUND) and not.ALLOW_GROUND then 
            return false 
        endif 
        if IsUnitType(u, UNIT_TYPE_MECHANICAL) and not.ALLOW_MECHANICAL then 
            return false 
        endif 
        if IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not.ALLOW_MAGIC_IMMUNE then 
            return false 
        endif 
        if GetUnitState(u, UNIT_STATE_LIFE) > 0 and not.ALLOW_ALIVE then 
            return false 
        endif 
        return true 
    endmethod 
endstruct 

struct SKILL_MISSLE extends SKILL 
    
    //=====================FireTouch========================================== 
    private static method FireTouchUpdate takes nothing returns nothing 
        local thistype this = runtime.get() 
        local timer t = GetExpiredTimer() 
        local group g = null 
        local unit e = null 
        set.x = Math.ppx( .x, .speed, .a) 
        set.y = Math.ppy( .y, .speed, .a) 
        call Eff.angle( .missle, .a) 
        call Eff.pos( .missle, .x, .y, Math.pz( .x, .y) + .z) 

        set g = CreateGroup() 
        call Group.enum(g, .x, .y, .aoe) 
        loop 
            set e = FirstOfGroup(g) 
            exitwhen e == null 
            if not.is_touch and.FilterUnit(e, .caster) and e != .caster then 
                set.is_touch = true 
                call UnitDamageTargetBJ( .caster, e, .dmg, .ATK_TYPE, .DMG_TYPE) 
                call Buff.effect( .caster, e, .buff_id, .x, .y, .buff_lv, .buff_dur) 
            endif 
            call Group.remove(e, g) 
        endloop 
        call Group.release(g) 
        set e = null 

        set.time = .time - 1 
        if.time <= 0 or GetUnitState( .caster, UNIT_STATE_LIFE) <= 0 or.is_touch then 
            call DestroyEffect( .missle) 
            call runtime.endx(t) // End the timer                                                                                                                                                                          
            call.destroy() // Destroy the instance                                      
        endif 
    endmethod 
    method FireTouch takes nothing returns boolean 
        // local thistype this = thistype.create()                  
        set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z) 
        call Eff.size( .missle, .missle_size) 
        call Eff.angle( .missle, .a) 
        if ENV_DEV then 
            call PLAYER.systemchat(Player(0) , "[SKILL] Fire Touch") 
            call PLAYER.systemchat(Player(0) , missle_path) 
        endif 
        call runtime.new(this, P32, true, function thistype.FireTouchUpdate) 
        return false 
    endmethod 
    //=================================================================================== 


    //=====================FirePierce========================================== 
    private static method FirePierceUpdate takes nothing returns nothing 
        local thistype this = runtime.get() 
        local timer t = GetExpiredTimer() 
        local group g = null 
        local unit e = null 
        set.x = Math.ppx( .x, .speed, .a) 
        set.y = Math.ppy( .y, .speed, .a) 
        call Eff.angle( .missle, .a) 
        call Eff.pos( .missle, .x, .y, Math.pz( .x, .y) + .z) 

        set g = CreateGroup() 
        call Group.enum(g, .x, .y, .aoe) 
        loop 
            set e = FirstOfGroup(g) 
            exitwhen e == null 
            if not IsUnitInGroup(e, .g) and.FilterUnit(e, .caster) and e != .caster then 
                call Group.add(e, .g) 
                call UnitDamageTargetBJ( .caster, e, .dmg, .ATK_TYPE, .DMG_TYPE) 
                call Buff.effect( .caster, e, .buff_id, .x, .y, .buff_lv, .buff_dur) 
            endif 
            call Group.remove(e, g) 
        endloop 
        call Group.release(g) 
        set e = null 

        set.time = .time - 1 
        if.time <= 0 or GetUnitState( .caster, UNIT_STATE_LIFE) <= 0 then 
            call Group.release( .g) 
            call DestroyEffect( .missle) 
            call runtime.endx(t) // End the timer                                                                                                                                                                          
            call.destroy() // Destroy the instance                                      
        endif 
    endmethod 
    method FirePierce takes nothing returns boolean 
        // local thistype this = thistype.create()                  
        set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z) 
        call Eff.size( .missle, .missle_size) 
        call Eff.angle( .missle, .a) 
        set.g = CreateGroup() 
        if ENV_DEV then 
            call PLAYER.systemchat(Player(0) , "[SKILL] Fire Touch") 
            call PLAYER.systemchat(Player(0) , missle_path) 
        endif 
        call runtime.new(this, P32, true, function thistype.FirePierceUpdate) 
        return false 
    endmethod 
    //=================================================================================== 

endstruct

//--- Content from folder: ./4-Event/1 - Unit - BeginConstruction.j ---
struct EV_BEGIN_STRUCTION 
    static method f_Checking takes nothing returns boolean 
        local unit builder = GetTriggerUnit() 
        local unit constructing = GetConstructingStructure() 
        local integer sid = GetUnitTypeId(constructing) 
        local integer pid = GetPlayerId(GetOwningPlayer(constructing)) 


        // commonly used sample trick : Cancel a build under construction with conditions  
        if sid == '0000' and false then //Make your condition  
            call TriggerSleepAction(0.01) //need for the trick  
            call IssueImmediateOrderById(constructing, 851976) //order cancel build  
            return false 
        endif 
        //===============================================================================  

        set builder = null 
        set constructing = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_CONSTRUCT_START) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 


//--- Content from folder: ./4-Event/10- Player - Chat.j ---

struct EV_PLAYER_CHAT 
    static Randompool pool1 //if u have more pool then add more line variables or set it array    
    static method f_Checking takes nothing returns boolean 
        local string s = GetEventPlayerChatString() 
        local player p = GetTriggerPlayer() 
        local integer id = GetPlayerId(p)
        local string n = SubString(s, 0, 3) 
        local string i = SubString(s, 3, 5) 
        
        if SubString(s, 0, 1) == "-" and n == "-cl" then 
            if ENV_DEV then 
                call BJDebugMsg("Command: Clear Chat") 
                call BJDebugMsg("Type: " + n) 
            endif 
            if(GetLocalPlayer() == p) then 
                call ClearTextMessages() 
            endif 
        endif 
        if SubString(s, 0, 1) == "-" and n == "-rd" then 
            if ENV_DEV then 
                call BJDebugMsg("Command: Random Pool") 
                call BJDebugMsg("Type: " + n) 
            endif 
            call.pool1.random() 
        endif 
        if SubString(s, 0, 1) == "-" and n == "-ct" then 
            if ENV_DEV then 
                call BJDebugMsg("Command: Cheat Test") 
                call BJDebugMsg("Type: " + n) 
                call PLAYER.addgold(id, 1000)
                call PLAYER.addlumber(id, 1000)
                call PLAYER.addfoodcap(id, 10)
            endif 
        endif 
        set p = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        set.pool1 = Randompool.create() 
        call.pool1.new_value(1, 50, 0, 0) 
        call.pool1.new_value(2, 30, 0, 5) 
        call.pool1.new_value(3, 20, 0, 2) 
        //This action everytime player chat, careful for use it.        
        call.add_chat("", true, function thistype.f_Checking) 
    endmethod 
    //You can use it for make more command in game instead my .add_chat("",true,function thistype.f_Checking)        
    static method add_chat takes string phase, boolean b, code actionfunc returns nothing 
        local integer index 
        local trigger trig = CreateTrigger() 
        set index = 0 
        loop 
            call TriggerRegisterPlayerChatEvent(trig, Player(index) , phase, b) 
            set index = index + 1 
            exitwhen index == (MAX_PLAYER - 1)
        endloop 
        call TriggerAddAction(trig, actionfunc) 
        set trig = null 
    endmethod 
endstruct

//--- Content from folder: ./4-Event/2a - Unit - AcquiresAnItem.j ---
//
struct EV_UNIT_ACQUIRES_ITEM 
    static method f_Checking takes nothing returns boolean 
        local item acquire_item = GetManipulatedItem() 
        local integer ItemID = GetItemTypeId(acquire_item) 
        local unit u = GetTriggerUnit() 
        local integer pid = GetPlayerId(GetOwningPlayer(u)) 
        local integer charge = GetItemCharges(acquire_item) 

  
        
        set acquire_item = null 
        set u = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_PICKUP_ITEM) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 

endstruct

//--- Content from folder: ./4-Event/2b - Unit - LoseAnItem.j ---
struct EV_UNIT_DROP_ITEM 
    static method f_Checking takes nothing returns boolean 
        local unit u = GetTriggerUnit() 
        local integer dropitem_id = GetItemTypeId(GetManipulatedItem()) 
        local item dropitem = GetManipulatedItem() 
        local integer pid = GetPlayerId(GetOwningPlayer(u)) 
        local integer charge = GetItemCharges(dropitem) 

        //commonly used sample trick :When you lose a fake item (power-up) and use it to increase resources 
        //that are not available in the game's UI or to craft equipment.
        if dropitem_id == '0000' and false then 
            call PLAYER.systemchat(Player(pid) , "=>[Loot] " + GetItemName(dropitem) + " x" + I2S(charge)) 
            return false
        endif
        //===========================================================================
        
        set dropitem = null 
        set u = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DROP_ITEM) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 

endstruct

//--- Content from folder: ./4-Event/3a - Unit - TargetOrder.j ---

struct EV_TARGET_ORDER 
    static method f_Checking takes nothing returns nothing 
        local unit u = GetTriggerUnit() 
        local item i = GetOrderTargetItem() 
        local unit e = GetOrderTargetUnit() 
        local integer w = GetUnitTypeId(e) 
        local integer d = GetUnitTypeId(u) 
        local integer id = Num.uid(u) 
        local integer orderid = GetIssuedOrderId() 
        //commonly used sample trick : Use item target spell  
        if i != null then 
            if orderid >= 852008 and orderid <= 852013 then 
                if ENV_DEV then 
                    call BJDebugMsg(I2S(GetIssuedOrderId())) 
                    call BJDebugMsg(GetItemName(i)) 
                endif 
            endif 
        endif 

        //commonly used sample trick :  smart (right click event) 
        if GetIssuedOrderId() == 851971 then 
              
        endif 
          
        set u = null 
        set i = null 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 



//--- Content from folder: ./4-Event/3b - Unit - TargetPoint.j ---
struct EV_POINT_ORDER 
    static method f_Checking takes nothing returns nothing 
        local unit u = GetTriggerUnit() 
        local real x = GetOrderPointX() 
        local real y = GetOrderPointY() 

   
          
        set u = null 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 



//--- Content from folder: ./4-Event/3c - Unit - NoTargetOrder.j ---
struct EV_NO_TARGET_ORDER 
    static method f_Checking takes nothing returns nothing 
        local unit u = GetTriggerUnit() 
          
        set u = null 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ISSUED_ORDER) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 



//--- Content from folder: ./4-Event/4 - Unit - Die.j ---


struct EV_UNIT_DEATH 
    static method f_Checking takes nothing returns boolean 
        local unit killer = GetKillingUnit() 
        local unit dying = GetDyingUnit() 
        local integer hdid = GetHandleId(dying) 
        local integer hkid = GetHandleId(killer) 
        local integer did = GetUnitTypeId(dying) 
        local integer kid = GetUnitTypeId(killer) 
        local integer pdid = Num.uid(dying) //Id player of dying    
        local integer pkid = Num.uid(killer) //Id player of killer    
        local integer rd = 0
        local integer n = 0
        //For EXAMPLE QUEST, comment it if not use   
        // if did == QUEST_EXAMPLE.archer_id then 
        //     call QUEST_EXAMPLE.kill_archer() 
        // endif 
        // if did == QUEST_EXAMPLE.warrior_id then 
        //     call QUEST_EXAMPLE.kill_warrior() 
        // endif 
        ////  
        // ROADLINE_EXAMPLE , comment it if not use   
        // call FlushChildHashtable(road, hdid) 
        // 
        if IsUnitType(dying, UNIT_TYPE_HERO) == true and pdid == 11 then 
            // loop
            //     exitwhen n > 20
            set rd = GAME.pool_item.random()  
            set bj_lastCreatedItem = CreateItem(rd, Unit.x(dying) , Unit.y(dying))
            // call BJDebugMsg(GetItemName(bj_lastCreatedItem))
            // set n = n + 1
            // endloop

        endif
        set killer = null 
        set dying = null 
        return false 
    endmethod 
 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct

//--- Content from folder: ./4-Event/5a - Unit - BeginCastingSpell.j ---

struct EV_CASTING_SPELL 
    static method f_Checking takes nothing returns boolean 
        local unit caster = GetTriggerUnit() 
        local integer idc = GetUnitTypeId(caster) 
        local unit target = GetSpellTargetUnit() 
        local integer spell_id = GetSpellAbilityId() 
        local item it = GetSpellTargetItem() 
        local integer pid = Num.uid(caster) 
        local real targetX = GetSpellTargetX() 
        local real targetY = GetSpellTargetY() 

                    
        set target = null 
        set caster = null 
        set it = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_CAST) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 

endstruct 


//--- Content from folder: ./4-Event/5b - Unit - StartEffectSpell.j ---
struct EV_START_SPELL_EFFECT 
    static method getReduceCD takes unit u returns real 
        return 0.50//giam 50%
    endmethod 

    static method isExclude takes unit u returns boolean 
        if Unit.haveabi(u, 'Z000') then //loai tru Z000
            return true 
        endif 
        return false
    endmethod 

    static constant real MAX_GIAM_CD = 0.50//toi da giam 90%
    static method f_Checking takes nothing returns boolean 
        local unit caster = GetTriggerUnit() 
        local integer idc = GetUnitTypeId(caster) 
        local unit target = GetSpellTargetUnit() 
        local integer idt = GetUnitTypeId(target) 
        local integer abicode = GetSpellAbilityId() 
        local item it = GetSpellTargetItem() 
        local real targetX = GetSpellTargetX() //Point X of skill                    
        local real targetY = GetSpellTargetY() //Point T of skill                    
        local integer pid = GetPlayerId(GetOwningPlayer(caster)) 
        local integer tpid = GetPlayerId(GetOwningPlayer(target)) 
        local real xc = GetUnitX(caster) 
        local real yc = GetUnitY(caster) 
        local real xt = GetUnitX(target) //Position X of target unit                   
        local real yt = GetUnitY(target) //Position T of target unit                   
        local SKILL_MISSLE Missle 
        local integer n = 1 
        local real timed = BlzGetAbilityCooldown(abicode, Unit.abilv(caster, abicode) - 1)
        local real max_CD = .getReduceCD(caster)
        if max_CD > MAX_GIAM_CD then
            set max_CD = MAX_GIAM_CD
        endif
        if GetPlayerController(GetOwningPlayer(caster)) == MAP_CONTROL_USER then 
            if not isExclude(caster) then 
                if(timed > 1.00) then
                    call BlzSetAbilityRealLevelField(GetSpellAbility() , ABILITY_RLF_COOLDOWN, Unit.abilv(caster, abicode) - 1, (timed * (1.00 - max_CD)     ))
                endif
            endif
        endif
        if abicode == 'A000' then 
            set n = 1 
            loop 
                exitwhen n > 5 
                set Missle = SKILL_MISSLE.create() 
                set Missle.caster = caster 
                call Missle.setxyz(xc, yc, 100) 
                //Angle       
                set Missle.a = (Math.ab(xc, yc, targetX, targetY) - (3 * 20)) + (n * 20) 
                //Speed per tick (1 second = speed *32)       
                set Missle.missle_path = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl" 
                set Missle.missle_size = 1.5 
                set Missle.speed = 15 
                set Missle.aoe = 50 
                set Missle.dmg = 35 
                set Missle.time = 32 * 2 // 32 tick per 1 seconds     

                if GetRandomInt(0, 1) == 0 then 
                    set Missle.buff_id = Buff.STUN 
                else 
                    set Missle.buff_id = Buff.SLOW 
                endif 
                set Missle.buff_lv = 1 
                set Missle.buff_dur = 3 

                set Missle.ATK_TYPE = ATTACK_TYPE_NORMAL 
                set Missle.DMG_TYPE = DAMAGE_TYPE_FIRE 
                call Missle.setallow(true, false, true, true, false, true, false) 
          
                call Missle.FireTouch() 
                set n = n + 1 
            endloop 
        
        endif 

        if abicode == 'A004' then //Fire pierce  
            set Missle = SKILL_MISSLE.create() 
            set Missle.caster = caster 
            call Missle.setxyz(xc, yc, 100) 
            //Angle       
            set Missle.a = Math.ab(xc, yc, targetX, targetY) 
            //Speed per tick (1 second = speed *32)       
            set Missle.missle_path = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl" 
            set Missle.missle_size = 2.5 
            set Missle.speed = 15 
            set Missle.aoe = 150 
            set Missle.dmg = 35 
            set Missle.time = 32 * 2 // 32 tick per 1 seconds     
            if GetRandomInt(0, 1) == 0 then 
                set Missle.buff_id = Buff.STUN 
            else 
                set Missle.buff_id = Buff.SLOW 
            endif 
            set Missle.buff_lv = 1 
            set Missle.buff_dur = 3 

            set Missle.ATK_TYPE = ATTACK_TYPE_NORMAL 
            set Missle.DMG_TYPE = DAMAGE_TYPE_FIRE 
            call Missle.setallow(true, false, true, true, false, true, false) 
          
            call Missle.FirePierce() 
        endif 
        set target = null 
        set caster = null 
        set it = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 



//--- Content from folder: ./4-Event/6 - Hero - LearnSpell.j ---
struct EV_LEARN_SKILL 
    static method f_Checking takes nothing returns boolean 
        local unit caster = GetLearningUnit() 
        local integer id = GetLearnedSkill()  //Ability ID learning spell
        local integer uid = GetUnitTypeId(caster) 
   
        set caster = null 
        return false 
    endmethod 

    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_HERO_SKILL) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 

//--- Content from folder: ./4-Event/7 - Unit - SoldUnit.j ---

struct EV_UNIT_SELL 
    static method f_Checking takes nothing returns boolean 
        local unit u = GetSoldUnit() 
        local unit caster = GetTriggerUnit() 
        local integer pid = GetPlayerId(GetOwningPlayer(GetSoldUnit())) 

        set u = null 
        set caster = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SELL) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 


//--- Content from folder: ./4-Event/8 - Player- Leave.j ---
struct EV_PLAYER_LEAVES 
    static method f_Checking takes nothing returns boolean 
        local player p = GetTriggerPlayer() 
        
        set PLAYER.IsDisconect[Num.pid(p)] = true 
        set GAME.CountPlayer = GAME.CountPlayer - 1 


        set p = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() // Create a trigger                                                                                                                             
        local integer n = 0 
        loop 
            exitwhen n > (MAX_PLAYER - 1) 
            call TriggerRegisterPlayerEventLeave(t, Player(n)) 
            set n = n + 1 
        endloop 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 

//--- Content from folder: ./4-Event/9 - Unit - Attacked.j ---



struct EV_UNIT_ATTACK
    static method f_Checking takes nothing returns boolean 
        local unit attacker = GetAttacker() 
        local unit attacked = GetTriggerUnit() 
        //Trick: Someone use it for stop attack to ally



        set attacker = null 
        set attacked = null 
        return false 
    endmethod 
 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_ATTACKED) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct

//--- Content from folder: ./4-Event/999 - Event Init.j ---
struct REGISTER_EVENT 
    private static method SetupAllEvent takes nothing returns nothing 
        //Comment if u don't use the event 
        call EV_BEGIN_STRUCTION.f_SetupEvent()
        // ITEM
        call EV_UNIT_ACQUIRES_ITEM.f_SetupEvent()
        call EV_UNIT_DROP_ITEM.f_SetupEvent()
        // ORDER
        call EV_TARGET_ORDER.f_SetupEvent()
        call EV_POINT_ORDER.f_SetupEvent()
        call EV_NO_TARGET_ORDER.f_SetupEvent()
        // SPELL
        call EV_CASTING_SPELL.f_SetupEvent()
        call EV_START_SPELL_EFFECT.f_SetupEvent()
        call EV_LEARN_SKILL.f_SetupEvent()
        // MISC
        call EV_UNIT_DEATH.f_SetupEvent()
        call EV_UNIT_ATTACK.f_SetupEvent()
        call EV_UNIT_SELL.f_SetupEvent()

        call EV_PLAYER_LEAVES.f_SetupEvent()
        call EV_PLAYER_CHAT.f_SetupEvent()

        call DestroyTimer(GetExpiredTimer()) 
    endmethod
    private static method onInit takes nothing returns nothing 
        call TimerStart(CreateTimer() , TIME_SETUP_EVENT, false, function thistype.SetupAllEvent) 
    endmethod 
endstruct 


//--- Content from folder: ./5-Features/1-UI.j ---


//--- Content from folder: ./5-Features/2-Roadline.j ---
globals 
    hashtable road = InitHashtable() // For damage system                                                        
    constant integer MAX_SIZE_ROADLINE = 99 //Max size you use for a region save a point with name difference           
endglobals 

struct Region 
    trigger t 
    rect r 
    region rg 
    string array name[MAX_SIZE_ROADLINE] 
    real array x[MAX_SIZE_ROADLINE] 
    real array y[MAX_SIZE_ROADLINE] 
    integer array delay[MAX_SIZE_ROADLINE] 
    integer size = -1 
    string array new_road[MAX_SIZE_ROADLINE] 
    boolean array is_teleport[MAX_SIZE_ROADLINE] 
    method name2id takes string name returns integer 
        local integer r = -1 
        local integer n = 0 
        loop 
            exitwhen n > .size 
            if.name[n] == name then 
                set r = n 
                exitwhen true 
            endif 
            set n = n + 1 
            
        endloop 
        return r 
    endmethod 
endstruct 
struct Roadline 
    static integer i = -1 
    static Region array regions 
    static integer ROAD = StringHash("road") 
    static integer DELAY = StringHash("delay") 
    static integer X = StringHash("x") 
    static integer Y = StringHash("y") 
    static integer IS_TELE = StringHash("tele") 

    static method LoadRoad takes integer hid returns string 
        local string r = "" 
        set r = LoadStr(road, hid, Roadline.ROAD) 
        return r 
    endmethod 
    
    static method SaveDelay takes integer hid, integer delaytime returns nothing 
        call SaveInteger(road, hid, Roadline.DELAY, delaytime) 
    endmethod 
    static method LoadDelay takes integer hid returns integer 
        local integer r = 0 
        set r = LoadInteger(road, hid, Roadline.DELAY) 
        return r 
    endmethod 
    static method IsTele takes integer hid returns boolean 
        local boolean r = false 
        set r = LoadBoolean(road, hid, Roadline.IS_TELE) 
        return r 
    endmethod 
    static method LoadX takes integer hid returns real 
        local real r = 0 
        set r = LoadReal(road, hid, Roadline.X) 
        return r 
    endmethod 
    static method LoadY takes integer hid returns real 
        local real r = 0 
        set r = LoadReal(road, hid, Roadline.Y) 
        return r 
    endmethod 
    static method is_have takes rect r returns boolean 
        local boolean res = false 
        local integer n = 0 
        if.i != -1 then 
            loop 
                exitwhen n > .i 
                if r == .regions[n] .r then 
                    set res = true 
                    exitwhen true 
                endif 
                set n = n + 1 
            endloop 
        endif 
        return res 
    endmethod 
    static method find takes region rg returns integer 
        local integer res = -1 
        local integer n = 0 
        if.i != -1 then 
            loop 
                exitwhen n > .i 
                if rg == .regions[n] .rg then 
                    set res = n 
                    exitwhen true 
                endif 
                set n = n + 1 
            endloop 
        endif 
        return res 
    endmethod 
    static method findbyrect takes rect r returns integer 
        local integer res = -1 
        local integer n = 0 
        if.i != -1 then 
            loop 
                exitwhen n > .i 
                if r == .regions[n] .r then 
                    set res = n 
                    exitwhen true 
                endif 
                set n = n + 1 
            endloop 
        endif 
        return res 
    endmethod 
    static method Runto takes nothing returns nothing 
        local region rg = GetTriggeringRegion() 
        local unit u = GetEnteringUnit() 
        local integer id = GetHandleId(u) 
        local integer rgid = .find(rg) 
        local string roadtype = LoadStr(road, id, Roadline.ROAD) 
        local integer n = 0 
        // call PLAYER.systemchat(Player(0),.regions[rgid].name[n])                            
        
        loop 
            exitwhen n > .regions[rgid] .size 
            if roadtype == .regions[rgid] .name[n] then 
                call SaveReal(road, id, Roadline.X, .regions[rgid] .x[n]) 
                call SaveReal(road, id, Roadline.Y, .regions[rgid] .y[n]) 
                call Roadline.SaveDelay(id, .regions[rgid] .delay[n]) 
                if.regions[rgid] .is_teleport[n] then 
                    call SaveBoolean(road, id, Roadline.IS_TELE, true) 
                else 
                    call SaveBoolean(road, id, Roadline.IS_TELE, false) 
                endif 
                if.regions[rgid] .new_road[n] != "" then 
                    call SaveStr(road, id, Roadline.ROAD, .regions[rgid] .new_road[n]) 
                endif 
            endif 
            set n = n + 1 
        endloop 
            

    endmethod 
    static method register takes unit u, rect r, string roadname returns nothing 
        local integer id = .findbyrect(r) 
        local integer size = -1 
        local integer hid = GetHandleId(u) 
        if id != -1 then 
            set size = .regions[id] .name2id(roadname) 
            if size != -1 then 
                call SaveStr(road, hid, Roadline.ROAD, .regions[id] .name[size]) 
                call SaveReal(road, hid, Roadline.X, .regions[id] .x[size]) 
                call SaveReal(road, hid, Roadline.Y, .regions[id] .y[size]) 
                call SaveInteger(road, hid, Roadline.DELAY, .regions[id] .delay[size]) 
                call SaveBoolean(road, hid, Roadline.IS_TELE, .regions[id] .is_teleport[size]) 
            endif 
        endif 
    endmethod 
    static method new takes rect r, rect r2, integer delay, string name, string new_road, boolean is_teleport returns nothing 
        local integer id = 0 
        local integer size = 0 
        local boolean b = false 
        if not.is_have(r) then 
            set.i = .i + 1 
            set.regions[ .i] = Region.create() 
            set.regions[ .i] .r = r 
            set.regions[ .i] .t = CreateTrigger() 
            set.regions[ .i] .rg = CreateRegion() 
            call RegionAddRect( .regions[ .i] .rg, r) 
            call TriggerRegisterEnterRegion( .regions[ .i] .t, .regions[ .i] .rg, null) 
            call TriggerAddAction( .regions[ .i] .t, function thistype.Runto) 
            set b = true 
        endif 

        if b then 
            set id = .i 
        else 
            set id = .findbyrect(r) 
        endif 

        set.regions[id] .size = .regions[id] .size + 1 
        set size = .regions[id] .size 
        set.regions[id] .name[size] = name 
        set.regions[id] .x[size] = GetRectCenterX(r2) 
        set.regions[id] .y[size] = GetRectCenterY(r2) 
        set.regions[id] .delay[size] = delay 
        set.regions[id] .new_road[size] = new_road 
        set.regions[id] .is_teleport[size] = is_teleport 

    endmethod 
endstruct 













//--- Content from folder: ./6-Timers/1-Interval.j ---
struct Interval 
    static integer times = 0 
    static method tick takes nothing returns nothing 
        set.times = .times + 1 
        //Comment if not use   
        // call MULTILBOARD_EXAMPLE.update() 

        // if ModuloInteger(.times, 5) == 0 then 
        //     call ROADLINE_EXAMPLE.summon() 
        // endif 
        // call ROADLINE_EXAMPLE.order()


      
    endmethod 
    static method start takes nothing returns nothing 
        call TimerStart(CreateTimer() , TIME_INTERVAL, true, function thistype.tick) 
    endmethod 
endstruct

//--- Content from individual file: ./GAME.j ---


struct GAME 
    static boolean IsSinglePlay = false 
    static integer CountPlayer = 0 
    static Randompool pool_item
    static Randompool pool_item_rare
    static Multiboard MB 
    private static method GameStart takes nothing returns nothing 
        local framehandle test1 = null 


        // call PauseGame(false)               
        // call CinematicModeBJ(false, GetPlayersAll()) 
        // call DisplayCineFilter(false) 
        if ENV_DEV then 
            call DisplayTextToForce(GetPlayersAll() , "Game Start ...") 
        endif 
        // COUNTDOWN TIMER EXAMPLE  If not use then delete this  
        // call COUNTDOWN_TIMER_EXAMPLE.start() 
        // call MULTILBOARD_EXAMPLE.start() 
        // call QUEST_EXAMPLE.start() 
        // call ROADLINE_EXAMPLE.start() 
        // call DIALOGBUTTON_EXAMPLE.start()
        // 
        // call Interval.start() 
    endmethod 

    private static method GameSetting takes nothing returns nothing 
        if ENV_DEV then 
            call DisplayTextToForce(GetPlayersAll() , "Setting Game ...") 
        endif 
        call SetMapFlag(MAP_LOCK_RESOURCE_TRADING, LOCK_RESOURCE_TRADING) 
        call SetMapFlag(MAP_SHARED_ADVANCED_CONTROL, SHARED_ADVANCED_CONTROL) 
        call EnableCreepSleepBJ(CREEP_SLEEP) 
        set pool_item = Randompool.create()
        //Normal Item
        call.pool_item.new_value('I005', 40, 0, 0)  //Claws of Attack
        call.pool_item.new_value('I008', 40, 0, 0)  //Cloak of Flames
        call.pool_item.new_value('I00B', 40, 0, 0)  //Gauntlets of Ogre Strength
        call.pool_item.new_value('I006', 40, 0, 0)  //Gloves of Haste
        call.pool_item.new_value('I00C', 40, 0, 0)  //Mantle of Intelligence
        call.pool_item.new_value('I00A', 40, 0, 0)  //Periapt of Vitality
        call.pool_item.new_value('I007', 40, 0, 0)  //Ring of Protection
        call.pool_item.new_value('I009', 40, 0, 0)  //Runed Bracers
        call.pool_item.new_value('I00D', 40, 0, 0)  //Slippers of Agility
        call.pool_item.new_value('IC61', 30, 0, 1)  //Tome of Health [300]
        call.pool_item.new_value('I00L', 30, 0, 1)  //Tome of Level [2]
        //Rare Item
        call.pool_item.add_rare( .pool_item)
  


   

        call DestroyTimer(GetExpiredTimer()) 
      
    endmethod 
    private static method GameStatus takes nothing returns nothing 
        local integer n = 0 
        if ENV_DEV then 
            call DisplayTextToForce(GetPlayersAll() , "Checking Status ...") 
        endif 
        // Check player is online in game                      
        set n = 0 
        loop 
            exitwhen n > (MAX_PLAYER - 1) 
            if PLAYER.IsPlayerOnline(Player(n)) then 
                set PLAYER.IsDisconect[n] = false 
                set GAME.CountPlayer = GAME.CountPlayer + 1 
            else 
                set PLAYER.IsDisconect[n] = true 
            endif 
            set n = n + 1 
        endloop 
        call DestroyTimer(GetExpiredTimer()) 
         
    endmethod 
    private static method PreloadMap takes nothing returns nothing 

        // call PauseGame(true)               
        // call CinematicModeBJ(true, GetPlayersAll()) 

        // call AbortCinematicFadeBJ() 
        // call SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\Black_mask.blp") 
        // call SetCineFilterBlendMode(BLEND_MODE_BLEND) 
        // call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE) 
        // call SetCineFilterStartUV(0, 0, 1, 1) 
        // call SetCineFilterEndUV(0, 0, 1, 1) 
        // call SetCineFilterStartColor(255, 255, 255, 255) 
        // call SetCineFilterEndColor(255, 255, 255, 255) 
        // call SetCineFilterDuration(GAME_START_TIME - GAME_PRELOAD_TIME) 
        // call DisplayCineFilter(true) 
    
        // call PanCameraToTimed(0, 0, 0) 
        if ENV_DEV then 
            call DisplayTextToForce(GetPlayersAll() , "Preload ...") 
        endif 
        //For setup framhandle setting, if u not use my code UI then delete it      
        call Frame.init() 
        //From to: https://www.hiveworkshop.com/threads/ui-showing-3-multiboards.316610/      
        //Will add more multilboard      
        call BlzLoadTOCFile("war3mapImported\\multiboard.toc") 
        call Preload_Ability('Amls') // Preload skill                                   
        call Preload_Unit('uloc') // Preload unit                                  
        call Preload_Unit('e000') // Preload dummy                                  
        call DestroyTimer(GetExpiredTimer()) 
    endmethod 

    private static method onInit takes nothing returns nothing 
        call TimerStart(CreateTimer() , GAME_PRELOAD_TIME, false, function thistype.PreloadMap) 
        call TimerStart(CreateTimer() , GAME_STATUS_TIME, false, function thistype.GameStatus) 
        call TimerStart(CreateTimer() , GAME_SETTING_TIME, false, function thistype.GameSetting) 
        call TimerStart(CreateTimer() , GAME_START_TIME, false, function thistype.GameStart) 
    endmethod 
endstruct 


//--- Content from individual file: ./EXAMPLE.j ---
// COUNTDOWN TIMER EXAMPLE  If not use then delete this                                                                                                                            
// struct COUNTDOWN_TIMER_EXAMPLE 
//     static CountdownTimer StartEvent 
//     static integer TimesStartEvent = 0 
//     static method start takes nothing returns nothing 
//         set COUNTDOWN_TIMER_EXAMPLE.StartEvent = CountdownTimer.create() 
//         call COUNTDOWN_TIMER_EXAMPLE.StartEvent.newdialog("10 secs event", 10, true, function thistype.tensec) 
//     endmethod 
//     private static method tensec takes nothing returns nothing 
//         set COUNTDOWN_TIMER_EXAMPLE.TimesStartEvent = COUNTDOWN_TIMER_EXAMPLE.TimesStartEvent + 1 
//         if ENV_DEV then 
//             call BJDebugMsg("Times:" + I2S(COUNTDOWN_TIMER_EXAMPLE.TimesStartEvent)) 
//         endif 
//         if COUNTDOWN_TIMER_EXAMPLE.TimesStartEvent == 1 then 
//             call COUNTDOWN_TIMER_EXAMPLE.StartEvent.title("Last time") 
//             call COUNTDOWN_TIMER_EXAMPLE.StartEvent.titlecolor(255, 0, 0, 255) 
//             call COUNTDOWN_TIMER_EXAMPLE.StartEvent.timercolor(255, 0, 0, 255) 
//         endif 
//         if COUNTDOWN_TIMER_EXAMPLE.TimesStartEvent == 2 then 
//             call COUNTDOWN_TIMER_EXAMPLE.StartEvent.destroytd() 
//             call COUNTDOWN_TIMER_EXAMPLE.StartEvent.destroy() 
//         endif 
//     endmethod 
// endstruct 

// struct MULTILBOARD_EXAMPLE 
//     static Multiboard MB 
//     static integer max_row = 1 
//     static string array hero_path 
//     static method setindex takes integer pid returns nothing 
//         call SaveInteger(ht, 0x63746264, GetHandleId(Player(pid)),.max_row) 
//         if ENV_DEV then 
//             call BJDebugMsg("Multiboard[]" + I2S(pid) + "[]" + I2S(.max_row)) 
//         endif 
//     endmethod 
//     static method I2Row takes integer pid returns integer 
//         local integer r = LoadInteger(ht, 0x63746264, GetHandleId(Player(pid))) 
//         return r 
//     endmethod 
//     static method start takes nothing returns nothing 
//         set MULTILBOARD_EXAMPLE.MB = Multiboard.create() 
//         //                                                                                                             
//         set bj_int = MAX_PLAYER 
//         loop 
//             set bj_int = bj_int - 1 
//             set.hero_path[bj_int - 1] = "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp" 
//             if(GetPlayerController(Player(bj_int - 1)) == MAP_CONTROL_USER) and(GetPlayerSlotState(Player(bj_int - 1)) == PLAYER_SLOT_STATE_PLAYING) then 
//                 call.setindex(.max_row) 
//                 set.max_row =.max_row + 1 
//             endif 
//             exitwhen bj_int == 1 
//         endloop 
//         call MULTILBOARD_EXAMPLE.MB.new(.max_row - 1, 4, "Multiboard") 

//         call.setup() 
//         call MULTILBOARD_EXAMPLE.MB.minimize(false) 
//     endmethod 
//     static method setup takes nothing returns nothing 
//         set bj_int = MAX_PLAYER - 1 
//         loop 
//             set bj_int = bj_int - 1 
//             if I2Row(bj_int + 1) > 0 then 
//                 call MULTILBOARD_EXAMPLE.MB.setstyle(1,.I2Row(bj_int + 1), true, true) 
//                 call MULTILBOARD_EXAMPLE.MB.setvalue(1,.I2Row(bj_int + 1), GetPlayerName(Player(bj_int))) 
//                 call MULTILBOARD_EXAMPLE.MB.seticon(1,.I2Row(bj_int + 1),.hero_path[bj_int]) 
//                 call MULTILBOARD_EXAMPLE.MB.setwidth(1,.I2Row(bj_int + 1), 8) 
                
//                 call MULTILBOARD_EXAMPLE.MB.setstyle(2,.I2Row(bj_int + 1), true, true) 
//                 call MULTILBOARD_EXAMPLE.MB.setvalue(2,.I2Row(bj_int + 1), I2S(PLAYER.gold(bj_int))) 
//                 call MULTILBOARD_EXAMPLE.MB.seticon(2,.I2Row(bj_int + 1), "UI\\Feedback\\Resources\\ResourceGold.blp") 
//                 call MULTILBOARD_EXAMPLE.MB.setwidth(2,.I2Row(bj_int + 1), 8) 
            
//                 call MULTILBOARD_EXAMPLE.MB.setstyle(3,.I2Row(bj_int + 1), true, true) 
//                 call MULTILBOARD_EXAMPLE.MB.setvalue(3,.I2Row(bj_int + 1), I2S(PLAYER.lumber(bj_int))) 
//                 call MULTILBOARD_EXAMPLE.MB.seticon(3,.I2Row(bj_int + 1), "UI\\Feedback\\Resources\\ResourceLumber.blp") 
//                 call MULTILBOARD_EXAMPLE.MB.setwidth(3,.I2Row(bj_int + 1), 8) 

//                 call MULTILBOARD_EXAMPLE.MB.setstyle(4,.I2Row(bj_int + 1), true, true) 
//                 call MULTILBOARD_EXAMPLE.MB.setvalue(4,.I2Row(bj_int + 1), I2S(PLAYER.food(bj_int)) + "/" + I2S(PLAYER.foodcap(bj_int))) 
//                 call MULTILBOARD_EXAMPLE.MB.seticon(4,.I2Row(bj_int + 1), "UI\\Feedback\\Resources\\ResourceSupply.blp") 
//                 call MULTILBOARD_EXAMPLE.MB.setwidth(4,.I2Row(bj_int + 1), 8) 
//             endif 
//             exitwhen bj_int == 0 
//         endloop 
//     endmethod 
//     static method update takes nothing returns nothing 
//         set bj_int = 0 
//         loop 
//             exitwhen bj_int > MAX_PLAYER - 1 
//             if I2Row(bj_int + 1) > 0 then 
//                 // call MULTILBOARD_EXAMPLE.MB.setvalue(1,.I2Row(bj_int), GetPlayerName(Player(bj_int)))                                                                               
//                 call MULTILBOARD_EXAMPLE.MB.seticon(1,.I2Row(bj_int + 1),.hero_path[bj_int]) 
                
//                 call MULTILBOARD_EXAMPLE.MB.setvalue(2,.I2Row(bj_int + 1), I2S(PLAYER.gold(bj_int))) 
            
//                 call MULTILBOARD_EXAMPLE.MB.setvalue(3,.I2Row(bj_int + 1), I2S(PLAYER.lumber(bj_int))) 

//                 call MULTILBOARD_EXAMPLE.MB.setvalue(4,.I2Row(bj_int + 1), I2S(PLAYER.food(bj_int)) + "/" + I2S(PLAYER.foodcap(bj_int))) 
//             endif 
//             set bj_int = bj_int + 1 
//         endloop 
//     endmethod 
// endstruct 


// struct QUEST_EXAMPLE 
//     static Quest Kill_SkeletonQuest 
//     static Questitem Kill_SkeletonArcher 
//     static integer archer_id = 'nska' 
//     static integer archer = 0 
//     static integer max_archer = 3 
//     static Questitem Kill_SkeletonWarrior 
//     static integer warrior_id = 'nskg' 
//     static integer warrior = 0 
//     static integer max_warrior = 3 
//     static method kill_archer takes nothing returns nothing 
//         local string str = "" 
//         if.Kill_SkeletonArcher.completed() == false then 
//             set.archer =.archer + 1 
//             set.archer = IMinBJ(.archer,.max_archer) 
//             set str = "Kill Skeleton Archer: " + I2S(.archer) + "/" + I2S(.max_archer) 
//             call.Kill_SkeletonArcher.desc(str) 
//             if.archer ==.max_archer then 
//                 call.Kill_SkeletonArcher.setcompleted(true) 
//                 call PLAYER.questmsgforce(GetPlayersAll(), str, Questmsg.COMPLETED) 
//             endif 
//             call.update() 
//         endif 
//     endmethod 
//     static method kill_warrior takes nothing returns nothing 
//         local string str = "" 
//         if.Kill_SkeletonWarrior.completed() == false then 
//             set.warrior =.warrior + 1 
//             set.warrior = IMinBJ(.warrior,.max_warrior) 
//             set str = "Kill Giant Skeleton Warrior: " + I2S(.warrior) + "/" + I2S(.max_warrior) 
//             call.Kill_SkeletonWarrior.desc(str) 
//             if.warrior ==.max_warrior then 
//                 call.Kill_SkeletonWarrior.setcompleted(true) 
//                 call PLAYER.questmsgforce(GetPlayersAll(), str, Questmsg.COMPLETED) 
//             endif 
//             call.update() 
//         endif 
//     endmethod 
//     static method update takes nothing returns nothing 
//         local string str = "" 
//         if.Kill_SkeletonQuest != null and.Kill_SkeletonQuest.completed() == false then 
//             if.Kill_SkeletonArcher.completed() == true and.Kill_SkeletonWarrior.completed() == true then 
//                 call.Kill_SkeletonQuest.setcompleted(true) 
//                 call.Kill_SkeletonQuest.desc("[Complete] Deafeat Skeleton in Forest ") 
//                 call PLAYER.questmsgforce(GetPlayersAll(), "Deafeat Skeleton in Forest", Questmsg.COMPLETED) 
//             endif 
//         endif 
//     endmethod 
//     static method start takes nothing returns nothing 
//         local string str = "" 
//         set.Kill_SkeletonQuest = Quest.create() 
//         set str = "Deafeat Skeleton in Forest" 
//         call.Kill_SkeletonQuest.new(Questtype.REQ_DISCOVERED, "Kill Skeleton", str, "ReplaceableTextures\\CommandButtons\\BTNSkeletonWarrior.tga") 
        
//         set.Kill_SkeletonArcher = Questitem.create() 
//         set str = "Kill Skeleton Archer: " + I2S(.archer) + "/" + I2S(.max_archer) 
//         call.Kill_SkeletonArcher.new(.Kill_SkeletonQuest.q, str) 

//         set.Kill_SkeletonWarrior = Questitem.create() 
//         set str = "Kill Giant Skeleton Warrior: " + I2S(.warrior) + "/" + I2S(.max_warrior) 
//         call.Kill_SkeletonWarrior.new(.Kill_SkeletonQuest.q, str) 
//     endmethod 
// endstruct 

// struct ROADLINE_EXAMPLE 
//     static integer Move = 851986 
//     static integer Almove = 851988 
//     static integer Attack = 851983 
//     static method io takes unit u, integer order returns boolean 
//         return GetUnitCurrentOrder(u) == order // Returns true or false when comparing the input order id value with the current unit's order value                                                                                                                  
//     endmethod 
//     static method IsNotAction takes unit u returns boolean 
//         return not(.io(u,.Move) or.io(u,.Almove) or.io(u,.Attack)) 
//     endmethod 
//     static method summon takes nothing returns nothing 
//         local integer roll = GetRandomInt(0, 2) 
//         if roll == 2 then 
//             set bj_unit = CreateUnit(Player(10), 'hpea', GetRectCenterX(gg_rct_r1), GetRectCenterY(gg_rct_r1), 0) 
//             call Roadline.register(bj_unit, gg_rct_r1, "road1") 
//         elseif roll == 1 then 
//             set bj_unit = CreateUnit(Player(10), 'hpea', GetRectCenterX(gg_rct_r3), GetRectCenterY(gg_rct_r3), 0) 
//             call Roadline.register(bj_unit, gg_rct_r3, "road2") 
//         else 
//             set bj_unit = CreateUnit(Player(10), 'hpea', GetRectCenterX(gg_rct_r4), GetRectCenterY(gg_rct_r4), 0) 
//             call Roadline.register(bj_unit, gg_rct_r4, "road3") 
          
//         endif 
//         call SetUnitPathing(bj_unit, false) 

//     endmethod 
//     static method start takes nothing returns nothing 
//         // new ( your_region_now, your_region_come, your_delay , your_road_name , new_road, teleport?)              
//         call Roadline.new(gg_rct_r1, gg_rct_r2, 3, "road1", "", false) 
//         call Roadline.new(gg_rct_r2, gg_rct_r3, 3, "road1", "", false) 
        
//         call Roadline.new(gg_rct_r3, gg_rct_r2, 3, "road1", "road2", false) 
//         //=>                
//         call Roadline.new(gg_rct_r3, gg_rct_r2, 3, "road2", "", false) 
//         call Roadline.new(gg_rct_r2, gg_rct_r1, 3, "road2", "road1", false) 

//         call Roadline.new(gg_rct_r4, gg_rct_r5, 3, "road3", "", true) 
//         call Roadline.new(gg_rct_r5, gg_rct_r4, 3, "road3", "", true) 

//     endmethod 
//     static method order takes nothing returns nothing 
//         local unit e = null 
//         local group g = null 
//         local integer id = -1 
//         set g = CreateGroup() 
//         call Group.enump(g, Player(10)) 
//         loop 
//             set e = FirstOfGroup(g) 
//             exitwhen e == null 
//             set id = GetHandleId(e) 
//             if GetUnitState(e, UNIT_STATE_LIFE) > 0 and IsUnitType(e, UNIT_TYPE_STRUCTURE) == false and.IsNotAction(e) then 
//                 if Roadline.LoadRoad(id) != "" then 
//                     if Roadline.LoadDelay(id) > 0 then 
//                         call Roadline.SaveDelay(id, Roadline.LoadDelay(id) -1) 
//                     else 
//                         // call BJDebugMsg(R2S(Roadline.LoadX(id)) + " [] " + R2S(Roadline.LoadY(id)))                         
//                         if Roadline.IsTele(id) then 
//                             call SetUnitPosition(e, Roadline.LoadX(id), Roadline.LoadY(id)) 
//                             call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl", Roadline.LoadX(id), Roadline.LoadY(id))) 
//                         else 
//                             //Change it to "move" or "attack" if attack is target then contact me for more custom                    
//                             call IssuePointOrder(e, "move", Roadline.LoadX(id), Roadline.LoadY(id)) 
//                         endif 
//                     endif 
//                 endif 
//             endif 
//             call Group.remove(e, g) 
//         endloop 
//         call Group.release(g) 
//         set e = null 
//     endmethod 
// endstruct 

// struct DIALOGBUTTON_EXAMPLE 
//     static Dialog SelectDifficult 
//     static button Normal 
//     static button Hard 
//     static button Nightmare 
//     static method click takes nothing returns nothing 
//         local button btnclicked = GetClickedButton() 
//         local dialog d = GetClickedDialog() 
//         local boolean is_select = false 
//         if btnclicked ==.Normal then 
//             call PLAYER.systemchat(Player(0), "You select difficult Normal ") 
//             set is_select = true 
//         elseif btnclicked ==.Hard then 
//             call PLAYER.systemchat(Player(0), "You select difficult Hard ") 
//             set is_select = true 
//         elseif btnclicked ==.Nightmare then 
//             call PLAYER.systemchat(Player(0), "You select difficult Nightmare ") 
//             set is_select = true 
//         endif 
//         if is_select then 
//             call.SelectDifficult.destroyd() 
//         endif 
//         set btnclicked = null 
//         set d = null 
//     endmethod 
//     //Careful, one dialog only use for one player , dont display a dialog for 2 or more than ( 2 player use a dialog instead one dialog per player), it's will make game confuse 
//     static method start takes nothing returns nothing 
//         set.SelectDifficult = Dialog.create() 
//         call.SelectDifficult.title("Select Difficult") 
//         //https://www.hiveworkshop.com/threads/extended-hotkeys-spacebar-etc.245278/          
//         //Or here : https://en.wikipedia.org/wiki/List_of_Unicode_characters          
//         //Find on column Decimal, character is uppercase with hotkey          
//         set.Normal =.SelectDifficult.addbtn("Normal [A]", 65) 
//         set.Hard =.SelectDifficult.addbtn("Hard [S]", 83) 
//         set.Nightmare =.SelectDifficult.addbtn("Nightmare [D]", 68) 
//         call.SelectDifficult.event(function thistype.click) 
//         call.SelectDifficult.displayx(true, Player(0)) 
        
//     endmethod 
// endstruct 


