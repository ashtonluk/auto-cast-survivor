struct WAVE 
    static integer lv = 0 
    static integer array utype 
    static integer array utype2 
    static integer array btype 
    static integer array spawn 
    static integer delay = 0 
    static string array note 
    
    static method AlertMsg takes nothing returns nothing 
        call PLAYER.msgforce(GetPlayersAll(), "Wave " + I2S(.lv), 10) 
    endmethod 
    static method CookUnit takes integer id, integer number , real angle returns nothing 
        local integer n = 0 
        set n = 1 
        loop 
            exitwhen n > number 
            set bj_unit = CreateUnit(Player(10), id, GetLocationX(bj_loc), GetLocationY(bj_loc), angle) 
            call QueueUnitAnimation(bj_unit, "birth") 
            set n = n + 1 
        endloop 
    endmethod 
    static method executed takes nothing returns nothing 
        local integer n = 1
        set WAVE.lv = WAVE.lv + 1 
        if WAVE.lv == 1 then 
            call PLAYER.msgforce(GetPlayersAll(), "Day 1: Outbreak [Zombie] ", 30) 
            call MoveLocation(bj_loc, GetRectCenterX(gg_rct_Spawn_Top), GetRectCenterY(gg_rct_Spawn_Top)) 
            call WAVE.CookUnit(.utype[0], 8, 270)
            call MoveLocation(bj_loc, GetRectCenterX(gg_rct_Spawn_Bottom), GetRectCenterY(gg_rct_Spawn_Bottom)) 
            call WAVE.CookUnit(.utype[0], 8, 90)

            call MoveLocation(bj_loc, GetRectCenterX(gg_rct_Spawn_Left), GetRectCenterY(gg_rct_Spawn_Left)) 
            call WAVE.CookUnit(.utype[0], 8, 180)

            call MoveLocation(bj_loc, GetRectCenterX(gg_rct_Spawn_Right), GetRectCenterY(gg_rct_Spawn_Right)) 
            call WAVE.CookUnit(.utype[0], 8, 0)
        endif
    endmethod
    
    private static method onInit takes nothing returns nothing 
        set.utype[0] = 'n001' //Zombie
        set.utype[1] = 'n001' 
        set.utype[2] = 'u000' 
    endmethod 
endstruct 