
struct EV_UNIT_SUMMON
    static method f_Checking takes nothing returns boolean 
        local unit summoned = GetSummonedUnit()
        local integer idc = GetUnitTypeId(summoned) 
        local integer pid = Num.uid(summoned) 
        call SaveUnitHandle(ht, GetHandleId(summoned), StringHash("owner"), GAME.Survivor[pid])
        call BJDebugMsg(GetUnitName(summoned))
        set summoned = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SUMMON ) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 

endstruct 
