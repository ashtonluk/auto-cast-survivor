
struct Aiming 
    static method ally_filter takes unit u , unit e returns boolean 
        if not Boo.isdead(e) and IsUnitAlly(e, GetOwningPlayer(u)) and Boo.ishero(e) then 
            return true 
        endif 
        return false
    endmethod
    static method enemy_filter takes unit u , unit e returns boolean 
        if not Boo.isdead(e) and IsUnitEnemy(u, GetOwningPlayer(e)) and BlzIsUnitInvulnerable(e) == false then 
            return true 
        endif 
        return false
    endmethod
    static method enemy_nearest takes unit caster, real x , real y , real aoe returns nothing  
        local real Nearest = aoe
        local unit e = null
        local real db = 0 
        local real xx = 0 
        local real yy = 0 
        local integer n = 0 
        set bj_group = CreateGroup()
        call Group.enum(bj_group, x, y, aoe) 
        loop 
            set e = FirstOfGroup(bj_group) 
            exitwhen e == null 
            set db = Math.db(x, y, GetUnitX(e) , GetUnitY(e)) 
            if.enemy_filter(caster, e) and db < Nearest then 
                set Nearest = db 
                set bj_unit = e 
            endif 
            call Group.remove(e, bj_group) 
        endloop 
        set e = null 
        call Group.release(bj_group) 
        set bj_group = null
    endmethod 
    static method enemy_lesshp takes unit u, real range returns nothing 
        local real lowerestPercentHP = 100 
        local unit e = null 
        local real db = 0 
        set bj_group = CreateGroup()
        call Group.enum(bj_group, GetUnitX(u) , GetUnitY(u) , range) 
        loop 
            set e = FirstOfGroup(bj_group) 
            exitwhen e == null 
            if.enemy_filter(u, e) and GetUnitLifePercent(u) <= lowerestPercentHP then 
                set lowerestPercentHP = GetUnitLifePercent(e) 
                set bj_unit = e 
            endif 
            call Group.remove(e, bj_group) 
        endloop 
        call Group.release(bj_group) 
        set e = null 
    endmethod 
    static method lesshp takes unit u, real x, real y , real range returns nothing 
        local real lowerestPercentHP = 100 
        local unit e = null 
        local real db = 0 
        set bj_group = CreateGroup()
        call Group.enum(bj_group, x, y, range) 
        loop 
            set e = FirstOfGroup(bj_group) 
            exitwhen e == null 
            if not Boo.isdead(e) and not IsUnitType(e, UNIT_TYPE_STRUCTURE) and GetUnitLifePercent(u) <= lowerestPercentHP then 
                set lowerestPercentHP = GetUnitLifePercent(e) 
                set bj_unit = e 
            endif 
            call Group.remove(e, bj_group) 
        endloop 
        call Group.release(bj_group) 
        set e = null 
    endmethod 
    static method reset takes nothing returns nothing 
        set bj_unit = null
    endmethod
endstruct