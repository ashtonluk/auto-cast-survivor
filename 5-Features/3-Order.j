struct ORDER 
    static integer Move = 851986 
    static integer Almove = 851988 
    static integer Attack = 851983 
    static integer Drain = 852487 
    static integer Target = StringHash("Target") 
    static method IO takes unit u, integer order returns boolean 
        return GetUnitCurrentOrder(u) == order // Returns true or false when comparing the input order id value with the current unit's order value                                                                
    endmethod 
    static method IsFear takes unit u returns boolean 
        return not(.IO(u, .Move) or.IO(u, .Almove)) 
    endmethod 
    static method IsCrowControl takes unit u returns boolean 
        // if skill.have(u, 'BEer') or skill.have(u, 'B005') then                                                                
        //     return true                                                                
        // endif                                                                
        return false 
    endmethod 
    //IsNotAction is check a unit not action or not do something.                                                                
    static method IsNotAction takes unit u returns boolean 
        return not(.IO(u, .Move) or.IO(u, .Almove) or.IO(u, .Attack) or.IO(u, .Drain) or IsUnitPaused(u)) 
    endmethod 
    // Order Attack :                                                                
    //I use a timer to make a process check if the enemy is attacking towards the base or not? If it doesn't do anything or isn't the type of unit that can attack, I'll order it to attack again.                                                                
    private static method OrderAttack takes nothing returns nothing 
        local group g = null 
        local unit e = null 
        local unit m = null 
        local integer pos = 0 
        local integer way = 0 
        local integer id = 0 
        // I need to group the enemy player's units and check each enemy one by one.                                                                
        set g = CreateGroup() // Then i create a group                                                                 
        call GroupEnumUnitsOfPlayer(g, Player(10), null) // GroupEnumUnitsOfPlayer Collect all of player 11 current enemies into group g                                                                
        //Basically loop is used to iterate within its container, you need exitwhen condition for it to exit. If you use a GUI, its mechanism is in the ForEach function                                                                
        loop 
            set e = FirstOfGroup(g) 
            exitwhen e == null 
            if ORDER.IsNotAction(e) then 
                set m =.GetATarget() 
                if m != null and GetUnitState(e, UNIT_STATE_LIFE) > 0 and IsUnitType(e, UNIT_TYPE_STRUCTURE) == false and GetPlayerId(GetOwningPlayer(e)) == 10 then 
                    //IssuePointOrder: unit whichUnit, string order, real x, real y  => Here I order the enemy to attack the TheRevive region, it is near TheBase, so the unit will also attack TheBase.                                                                
                    call IssuePointOrder(e, "attack", GetUnitX(m), GetUnitY(m)) 
                    // call IssueTargetOrder(e, "attack", m) 
                endif 
                set m = null 
            endif
            call GroupRemoveUnit(g, e) // By removing units from the group in the loop, the number of units in the group will gradually decrease, and when unit e == null means when the group is empty, you end the loop you just processed.                                                                
        endloop 
        //One action to do when you finish processing groups if you don't use them anymore is groupclear and destroygroup, assign the value unit e = null although sometimes it is not necessary                                                                
        call GroupClear(g) //                                                                
        call DestroyGroup(g) 
        set e = null 
    endmethod 
    static method GetATarget takes nothing returns unit 
        local integer i = 0 
        local integer x = 1 
        local unit array u 
        local unit e = null 

        set x = 0 
        loop 
            exitwhen x > MAX_PLAYER - 1 
            if GAME.Survivor[x] != null and Boo.islive(GAME.Survivor[x]) and not PLAYER.IsDisconect[x] then 
                set i = i + 1 
                set u[i] = GAME.Survivor[x] 
            endif 
            set x = x + 1 
        endloop 
        set e = u[GetRandomInt(1, i)] 
        // call BJDebugMsg(GetUnitName(e))       
        set x = 1 
        loop 
            exitwhen x > i 
            set u[x] = null 
            set x = x + 1 
        endloop 
            
        return e 
    endmethod 
    private static method onInit takes nothing returns nothing 
        call TimerStart(CreateTimer(), (0.03125 * 4), true, function thistype.OrderAttack) // if true it become every 2 second call OrderAttack one time                                                                
    endmethod 
endstruct 
    