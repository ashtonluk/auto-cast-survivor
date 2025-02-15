
//Use :                               
// Order :                           
//==> call DUMMY.target("thunderbolt",target, ability_id , level_of_ability) [Search order name of spell u add]                            
// But it's only work for use make some effect to enemy (please select target allow in skill is Air,Ground )  
//when you use freedom dummy then u need use newx, it's will return new dummy  


struct DummyX 
    static integer dummy_id = 'e000' //Set your id dummy                                     
    // static integer dummy_id = 'edry' //Set your id dummy    
    static integer stun_id = 'A001'     
    static integer slow_id = 'A00A'     
    static integer chain_lightning_id = 'A004'                         
    static integer raise_dead_id = 'A00B'                         
    static unit array load 
    static method new takes nothing returns nothing 
        set bj_forLoopAIndex = 0 
        
        loop 
            exitwhen bj_forLoopAIndex > 11 
            set.load[bj_forLoopAIndex] = CreateUnit(Player(bj_forLoopAIndex), .dummy_id, 0, 0, 0) 
            call UnitAddAbility(.load[bj_forLoopAIndex], 'Avul') 
            call UnitAddAbility(.load[bj_forLoopAIndex], 'Aloc') 
            set bj_forLoopAIndex = bj_forLoopAIndex + 1 
        endloop 

        set.load[GetPlayerNeutralAggressive()] = CreateUnit(Player(GetPlayerNeutralAggressive()), .dummy_id, 0, 0, 0) 
        call UnitAddAbility(.load[GetPlayerNeutralAggressive()], 'Avul') 
        call UnitAddAbility(.load[GetPlayerNeutralAggressive()], 'Aloc') 

        call DestroyTimer(GetExpiredTimer()) 
    endmethod 
    static method newx takes integer pid returns unit 
        set bj_lastCreatedUnit = CreateUnit(Player(pid), .dummy_id, 0, 0, 0) 
        call UnitAddAbility(bj_lastCreatedUnit, 'Avul') 
        call UnitAddAbility(bj_lastCreatedUnit, 'Aloc') 
        return bj_lastCreatedUnit 
    endmethod 
    static method target takes string ordername, unit dummy, unit u, integer spell_id, integer level returns nothing 
        // call SetUnitX(dummy, GetUnitX(u)) 
        // call SetUnitY(dummy, GetUnitY(u)) 
        call UnitAddAbility(dummy, spell_id) 
        call SetUnitAbilityLevel(dummy, spell_id, level) 
        call IssueTargetOrder(dummy, ordername, u) 
        call UnitRemoveAbility(dummy, spell_id) 
    endmethod 
    static method stun takes unit dummy, unit u, real duration returns nothing 
        // call SetUnitX(dummy, GetUnitX(u)) 
        // call SetUnitY(dummy, GetUnitY(u)) 
        call UnitAddAbility(dummy, .stun_id) 
        // call SetUnitAbilityLevel(dummy, spell_id, 0) 
        call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility(dummy, .stun_id), ABILITY_RLF_DURATION_NORMAL, 0, duration )
        call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility(dummy, .stun_id), ABILITY_RLF_DURATION_HERO, 0, duration )
        call IssueTargetOrder(dummy, "thunderbolt", u) 
        call UnitRemoveAbility(dummy, .stun_id) 
    endmethod 
    static method slow takes unit dummy, unit u, real duration, real de_spd, real de_atk_spd returns nothing 
        // call SetUnitX(dummy, GetUnitX(u)) 
        // call SetUnitY(dummy, GetUnitY(u)) 
        call UnitAddAbility(dummy, .slow_id) 
        // call SetUnitAbilityLevel(dummy, spell_id, level) 
        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(dummy, .slow_id) , ABILITY_RLF_MOVEMENT_SPEED_FACTOR_SLO1, 0, de_spd)
        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(dummy, .slow_id) , ABILITY_RLF_ATTACK_SPEED_FACTOR_SLO2, 0, de_atk_spd)

        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(dummy, .slow_id) , ABILITY_RLF_DURATION_NORMAL, 0, duration)
        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(dummy, .slow_id) , ABILITY_RLF_DURATION_HERO, 0, duration)
        call IssueTargetOrder(dummy, "slow", u) 
        call UnitRemoveAbility(dummy, .slow_id) 
    endmethod 
    static method chain_lightning takes unit dummy, unit target, real reduce_by_target, real damage, integer num_target returns nothing 
        // call UnitAddAbility(dummy, .chain_lightning_id) 
        call SetUnitAbilityLevel(dummy, .chain_lightning_id, 0) 
        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(dummy, .chain_lightning_id) , ABILITY_RLF_DAMAGE_REDUCTION_PER_TARGET, 0, reduce_by_target )
        call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility(dummy, .chain_lightning_id), ABILITY_RLF_DAMAGE_PER_TARGET_OCL1, 0, damage )
        call BlzSetAbilityIntegerLevelFieldBJ( BlzGetUnitAbility(dummy, .chain_lightning_id), ABILITY_ILF_NUMBER_OF_TARGETS_HIT, 0, num_target )
        call IssueTargetOrder(dummy, "chainlightning", target) 
        // call UnitRemoveAbility(dummy, .chain_lightning_id) 
    endmethod
    static method raise_dead takes unit dummy , integer first_sum , integer num1, integer sec_sum , integer num2, real duration returns nothing 
        // call UnitAddAbility(dummy, .raise_dead_id) 
        call BlzSetAbilityIntegerLevelFieldBJ( BlzGetUnitAbility(dummy, .raise_dead_id), ABILITY_ILF_UNIT_TYPE_FOR_LIMIT_CHECK, 0, first_sum )
        call BlzSetAbilityStringLevelFieldBJ( BlzGetUnitAbility(dummy, .raise_dead_id), ABILITY_SLF_UNIT_TYPE_ONE, 0, I2S(first_sum) )
        call BlzSetAbilityIntegerLevelFieldBJ( BlzGetUnitAbility(dummy, .raise_dead_id), ABILITY_ILF_UNITS_SUMMONED_TYPE_ONE, 0, num1 )
        call BlzSetAbilityStringLevelFieldBJ( BlzGetUnitAbility(dummy, .raise_dead_id), ABILITY_SLF_UNIT_TYPE_TWO, 0, I2S(sec_sum) )
        call BlzSetAbilityIntegerLevelFieldBJ( BlzGetUnitAbility(dummy, .raise_dead_id), ABILITY_ILF_UNITS_SUMMONED_TYPE_TWO, 0, num2 )

        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(dummy, .raise_dead_id) , ABILITY_RLF_DURATION_NORMAL, 0, duration)
        call BlzSetAbilityRealLevelFieldBJ(BlzGetUnitAbility(dummy, .raise_dead_id) , ABILITY_RLF_DURATION_HERO, 0, duration)
        call IssueImmediateOrder(dummy, "instant") 
        // call UnitRemoveAbility(dummy, .raise_dead_id) 
    endmethod 
    static method point takes string ordername, unit dummy, real x, real y, integer level, integer spell_id returns nothing 
        // call SetUnitX(dummy, x)     
        // call SetUnitY(dummy, y)     
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
        call IssueImmediateOrder(bj_lastCreatedUnit, ordername) 
        call UnitRemoveAbility(dummy, spell_id) 
    endmethod 
    private static method onInit takes nothing returns nothing 
        call TimerStart(CreateTimer(), 1, false, function thistype.new) 
    endmethod 
endstruct 