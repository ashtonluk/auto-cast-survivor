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
    static method regKey takes oskeytype hotkey, code func returns nothing
        local trigger t = CreateTrigger( )
        local integer i = 0
        loop
            exitwhen i == MAX_PLAYER - 1
            call BlzTriggerRegisterPlayerKeyEvent( t, Player(i), hotkey, 0, true )
            set i = i + 1
        endloop
        call TriggerAddAction( t, func )
        set t = null
    endmethod
    private static method onInit takes nothing returns nothing 
        call TimerStart(CreateTimer(), TIME_SETUP_EVENT, false, function thistype.SetupAllEvent) 
    endmethod 
endstruct 
