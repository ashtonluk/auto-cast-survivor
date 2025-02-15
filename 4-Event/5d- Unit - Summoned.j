
struct EV_UNIT_SUMMON
    static key owner 
    static method f_Checking takes nothing returns boolean 
        local unit summoned = GetSummonedUnit()
        local integer idc = GetUnitTypeId(summoned) 
        local integer pid = Num.uid(summoned) 
        local integer id = GetUnitTypeId(summoned)
        local integer hid = GetHandleId(summoned)

        local RaiseWeapon rw
        call SaveUnitHandle(ht, hid, .owner , GAME.Survivor[pid])
        if id == 'uske' then //Skeleton Warrior
            call BlzSetUnitName(summoned, "Skeleton Warrior - " + GetUnitName(LoadUnitHandle(ht, hid, .owner )))
            call BlzSetUnitBaseDamage( summoned, R2I(0.55 * Hero.int(LoadUnitHandle(ht, hid, .owner ))), 0 )
            call BlzSetUnitMaxHP( summoned, R2I(20 * Hero.int(LoadUnitHandle(ht, hid, .owner ))))
            call BlzSetUnitRealFieldBJ( summoned, UNIT_RF_HP, 20 * Hero.int(LoadUnitHandle(ht, hid, .owner ))) 
            call BlzSetUnitArmor( summoned, 0.5 * Hero.int(LoadUnitHandle(ht, hid, .owner )) )
            call BlzSetUnitRealFieldBJ( summoned, UNIT_RF_DEFENSE, 0.5 * Hero.int(LoadUnitHandle(ht, hid, .owner )))
            call Unit.setlife(summoned, 20 * Hero.int(LoadUnitHandle(ht, hid, .owner )))

            set rw = RaiseWeapon.create()
            set rw.u = summoned
            set rw.caster = GAME.Survivor[pid]
            set rw.weapon = 'A009'
            set rw.count = 'I006'  //Item ID
            call rw.set_now()
        endif
        set summoned = null 
        return false 
    endmethod 
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SUMMON ) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 

endstruct 

