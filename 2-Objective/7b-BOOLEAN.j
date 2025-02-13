struct Boo 
    //Boolean to String              
    static method b2s takes boolean b returns string 
        if b then 
            return "True" 
        endif 
        return "False" 
    endmethod 
    static method isdead takes unit u returns boolean 
        return(GetUnitTypeId(u) < 1 or IsUnitType(u, UNIT_TYPE_DEAD) == true) 
    endmethod 
    static method ishero takes unit u returns boolean 
        return(IsUnitType(u, UNIT_TYPE_HERO) == true) 
    endmethod 
    static method islive takes unit u returns boolean 
        return(GetUnitState(u, UNIT_STATE_LIFE) > 0) 
    endmethod 
    static method isenemy takes unit u, unit e returns boolean 
        return IsUnitEnemy(e, GetOwningPlayer(u)) 
    endmethod 
    static method iswalk takes real x, real y returns boolean 
        return IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) 
    endmethod 
    static method hasitem takes unit u, integer id returns boolean 
        return UnitHasItemOfTypeBJ(u, id)
    endmethod
        
    static method nounit takes unit u, real x, real y, real aoe returns boolean 
        local group g = CreateGroup() 
        local unit e = null 
        local boolean b = true 
        set g = CreateGroup() 
        call Group.enum(g, x, y, aoe) 
        loop 
            set e = FirstOfGroup(g) 
            exitwhen e == null 
            if Boo.islive(e) and e != u and Num.utid(e) != 'n000' then 
                set b = false 
            endif 
            call Group.remove(e, g) 
            if not b then 
                exitwhen true 
            endif 
        endloop 
        call Group.release(g) 
        set e = null 
        return b 
    endmethod 
endstruct