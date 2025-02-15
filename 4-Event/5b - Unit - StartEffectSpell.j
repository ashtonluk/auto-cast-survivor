struct EV_START_SPELL_EFFECT 
    static real max_reduce_cd = 0.50
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
        local real ac = GetUnitFacing(caster)           
        local integer n = 1 
        local real timed = BlzGetAbilityCooldown(abicode, 0)
        local real max_CD = 0.00 // Chhir số giảm hồi chiêu
        if max_CD > .max_reduce_cd then
            set max_CD = .max_reduce_cd
        endif


        if abicode == 'A000' then 
            if GAME.Survivor_Weapon[pid] == 'A002' then //Bow
                set timed = 2.0
            elseif GAME.Survivor_Weapon[pid] == 'A002' then //Normal attack
                set timed = 1.80
            elseif GAME.Survivor_Weapon[pid] == 'A003' then //Staff of Fire
                set timed = 2.2
            elseif GAME.Survivor_Weapon[pid] == 'A005' then //Wand of lightning
                set timed = 2.2
            elseif GAME.Survivor_Weapon[pid] == 'A006' then //Crossbow
                set timed = 4.2
            elseif GAME.Survivor_Weapon[pid] == 'A007' then //Axe
                set timed = 2.5
            elseif GAME.Survivor_Weapon[pid] == 'A008' then //Claw
                set timed = 2.0
            elseif GAME.Survivor_Weapon[pid] == 'A009' then //Rod
                set timed = 10.0
            elseif GAME.Survivor_Weapon[pid] == 'A00C' then //Dagger
                set timed = 1.8
            elseif GAME.Survivor_Weapon[pid] == 'A00D' then //Shield
                set timed = 3.2
            endif
            if(timed > 1.00) then // các đòn đánh có ít nhất 1s cooldown
                call BlzSetAbilityRealLevelField(GetSpellAbility() , ABILITY_RLF_COOLDOWN, 0, (timed * (1.00 - max_CD)))
            endif
            call Unit_Attack.attack(caster, GAME.Survivor_Weapon[pid], pid )
        endif
        if abicode == 'A001' then 
            call .jump(caster, abicode)
        endif

        /// Equip Weapon
        if abicode == 'A002' or abicode == 'A003' or abicode == 'A005' or abicode == 'A006' or abicode == 'A007' or abicode == 'A008'  or abicode == 'A009' or abicode == 'A00C' or abicode == 'A00D' then 
            set GAME.Survivor_Weapon[pid] = abicode
            // call SaveInteger(ht, GetHandleId(caster), GAME.Weapon, abicode)
        endif


        set target = null 
        set caster = null 
        set it = null 
        return false 
    endmethod 
    static key key_jump
    static method jump takes unit caster, integer abicode returns nothing 
        local JumpX jump 
        // Test 
        if abicode == 'A001' then
            set jump = JumpX.create()
            set jump.caster = caster
            call jump.setxya( Math.ppx(Unit.x(caster), 500, GetUnitFacing(caster) ), Math.ppy(Unit.y(caster), 500, GetUnitFacing(caster) )) 
            set jump.time = 1.50
            set jump.zMax = 350
            set jump.key_id = .key_jump
            set jump.ALLOW_MOVE = true
            set jump.ALLOW_CONTROL = false
            call jump.now()
        endif
    endmethod
   
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 

