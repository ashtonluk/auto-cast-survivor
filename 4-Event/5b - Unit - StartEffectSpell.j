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
            elseif GAME.Survivor_Weapon[pid] == 'A005' then //Crossbow
                set timed = 4.2
            endif
            if(timed > 1.00) then // các đòn đánh có ít nhất 1s cooldown
                call BlzSetAbilityRealLevelField(GetSpellAbility() , ABILITY_RLF_COOLDOWN, 0, (timed * (1.00 - max_CD)))
            endif
            call .attack(caster, GAME.Survivor_Weapon[pid], pid )
        endif
        if abicode == 'A001' then 
            call .jump(caster, abicode)
        endif

        /// Equip Weapon
        if abicode == 'A002' or abicode == 'A003' or abicode == 'A005' or abicode = 'A006' then 
            set GAME.Survivor_Weapon[pid] = abicode
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
    static method attack takes unit caster , integer abicode , integer pid returns nothing
        local Attack_Controller atk 
        local Bow_Controller bow 
        local Staff_Fire_Controller sf 
        local Wand_Lightning_Controller wl
        if abicode == 'A000' then //Normal attack
            set atk = Attack_Controller.create()
            set atk.time = 20
            set atk.caster = caster 
            set atk.DMG_TYPE = DAMAGE_TYPE_NORMAL
            set atk.ATK_TYPE = ATTACK_TYPE_HERO
            set atk.dmg = (Hero.all(caster) ) * 0.5
            set atk.speed = 150
            set atk.aoe = 165
            set atk.missle_path = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl" 
            set atk.missle_size = 0.65
            set atk.anim = "attack"
            set atk.attach = "chest"
            set atk.attach_path = "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl"
            call atk.spell_now()
        endif
        if abicode == 'A002' then //Bow attack
            if Boo.hasitem(caster, 'I000') then //Bow item 
                set bow = Bow_Controller.create()
                set bow.time = 20
                set bow.time_bow = 30
                set bow.caster = caster 
                set bow.DMG_TYPE = DAMAGE_TYPE_NORMAL
                set bow.ATK_TYPE = ATTACK_TYPE_HERO
                set bow.dmg = (Hero.str(caster) * 0.75 ) + (Hero.agi(caster) * 1.5) + (Hero.int(caster) * 0.35 )
                set bow.speed = 20
                set bow.aoe = 65 
                set bow.z = 100 
                set bow.missle_path = "Abilities\\Weapons\\MoonPriestessMissile\\MoonPriestessMissile.mdl" 
                set bow.missle_size = 0.65
                set bow.anim = "attack"
                set bow.attach = "chest"
                set bow.attach_path = "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl"
                call bow.spell_now()
            else 
                set GAME.Survivor_Weapon[pid] = 'A000'
                call .attack(caster, GAME.Survivor_Weapon[pid] , pid)
            endif
           
        endif

        if abicode == 'A003' then //Fire staff
            if Boo.hasitem(caster, 'I001') then //fire staff item 
                set sf = Staff_Fire_Controller.create()
                set sf.time = 20
                set sf.time_bow = 30
                set sf.caster = caster 
                set sf.DMG_TYPE = DAMAGE_TYPE_FIRE
                set sf.ATK_TYPE = ATTACK_TYPE_NORMAL
                set sf.dmg = (Hero.str(caster) * 0.65 ) + (Hero.agi(caster) * 0.5) + (Hero.int(caster) * 1.5 )
                set sf.speed = 20
                set sf.aoe = 65 
                set sf.aoe_nova = 200
                set sf.z = 100 
                set sf.missle_path = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl" 
                set sf.missle_size = 1.25
                set sf.anim = "attack"
                set sf.attach = "chest"
                set sf.attach_path = "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl"
                set sf.nova_size = 1.00
                set sf.nova_path = "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl"
                call sf.spell_now()
            else 
                set GAME.Survivor_Weapon[pid] = 'A000'
                call .attack(caster, GAME.Survivor_Weapon[pid] , pid)
            endif
           
        endif
        
        if abicode == 'A005' then //Fire staff
            if Boo.hasitem(caster, 'I002') then //fire staff item 
                set wl = Wand_Lightning_Controller.create()
                set wl.caster = caster 
                set wl.time = 20
                set wl.dmg = (Hero.str(caster) * 0.25 ) + (Hero.agi(caster) * 1.05) + (Hero.int(caster) * 1.15 )
                set wl.anim = "spell"
                call wl.spell_now()
                // call BJDebugMsg("lightning")
            else 
                set GAME.Survivor_Weapon[pid] = 'A000'
                call .attack(caster, GAME.Survivor_Weapon[pid] , pid)
            endif
           
        endif
        // local unit e = null 
        // local group g = CreateGroup() 
        // call Eff.new( "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y, Math.pz(x, y))
        // call Eff.size(bj_eff, 0.45)
        // call DestroyEffect(bj_eff)
        // call Group.enum(g, x, y, aoe) 
        // loop 
        //     set e = FirstOfGroup(g) 
        //     exitwhen e == null 
        //     if not Boo.isdead(e)  and IsUnitEnemy(caster, GetOwningPlayer(e)) and BlzIsUnitInvulnerable(e) == false then 
        //         call UnitDamageTarget(caster, e, dmg, true, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, null) 
        //     endif 
        //     call Group.remove(e, g) 
        // endloop 
        // call Group.release(g) 
        // set e = null 
    endmethod
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 

