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
    static method HideItem takes nothing returns nothing
        if IsItemVisible(GetEnumItem()) then
            set Hid[HidMax] = GetEnumItem()
            call SetItemVisible(Hid[HidMax] , false)
            set HidMax = HidMax + 1
        endif
    endmethod
    static method iswalk takes real x2, real y2 returns boolean 
        local real X = 0
        local real Y = 0
        call MoveRectTo(Find, x2, y2)
        call EnumItemsInRect(Find , null, function thistype.HideItem)
        call SetItemPosition(ItemChecker, x2, y2)
        set X = GetItemX(ItemChecker)
        set Y = GetItemY(ItemChecker)
        call SetItemVisible(ItemChecker, false)
        loop
            exitwhen HidMax <= 0
            set HidMax = HidMax - 1
            call SetItemVisible(Hid[HidMax] , true)
            set Hid[HidMax] = null
        endloop
        return(X - x2) * (X - x2) + (Y - y2) * (Y - y2) <= MAX_RANGE * MAX_RANGE and not IsTerrainPathable(x2, y2, PATHING_TYPE_WALKABILITY)
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