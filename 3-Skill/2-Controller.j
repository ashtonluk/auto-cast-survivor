struct Attack_Controller extends SKILL 
    string attach = ""
    string attach_path = ""
    string anim = ""
    integer start_anim = 0
    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            // call PauseUnit(.caster, false)
            call Unit.enabledmove(this.caster)
            // call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        if.time == .start_anim then 
            call SetUnitAnimation(.caster, .anim)
        endif

        call SetUnitFacingTimed(.caster, quickcast.getUA(.caster), 0.03125 * 2)
        // set bj_real = quickcast.getUA(.caster)
        // if .a > bj_real then 
        //     set .a = .a - 5
        // elseif .a < bj_real then 
        //     set .a = .a + 5
        // endif
        // call SetUnitFacing(.caster, .a)
        set.time = .time - 1 
        if.time <= 0  then 
            set.x = Math.ppx( Unit.x(.caster), .speed, GetUnitFacing(.caster)) 
            set.y = Math.ppy( Unit.y(.caster), .speed, GetUnitFacing(.caster)) 
            set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z) 
            call Eff.angle( .missle, GetUnitFacing(.caster)) 
            call Eff.size(.missle, .missle_size)
            call Eff.pos( .missle, .x, .y, Math.pz( .x, .y) + .z) 
            call DestroyEffect( .missle) 
            
            set g = CreateGroup() 
            call Group.enum(g, .x, .y, .aoe) 
            loop 
                set e = FirstOfGroup(g) 
                exitwhen(e == null)
                if .FilterUnit( .caster, e) then 
                    call Eff.attach( .attach_path, e, .attach)
                    call UnitDamageTarget(.caster, e, .dmg, true, true, .ATK_TYPE, .DMG_TYPE, null) 
                endif 
                call Group.remove(e, g) 
            endloop 
            call Group.release(g) 
            set e = null 
            call Unit.enabledmove(this.caster)
            // call PauseUnit(.caster, false)
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        set .start_anim = .time - 1
        call Unit.disablemove(this.caster)
        // call PauseUnit(.caster, true)
        set .a = GetUnitFacing(.caster)
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct
struct Bow_Controller extends SKILL 
    string attach = ""
    string attach_path = ""
    string anim = ""
    integer start_anim = 0
    integer time_bow = 0
    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        local Missle_Touch mt
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            // call PauseUnit(.caster, false)
            call Unit.enabledmove(this.caster)
            // call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        if.time == .start_anim then 
            call SetUnitAnimation(.caster, .anim)
        endif

        call SetUnitFacingTimed(.caster, quickcast.getUA(.caster), 0.03125 * 2)
        // set bj_real = quickcast.getUA(.caster)
        // if .a > bj_real then 
        //     set .a = .a - 5
        // elseif .a < bj_real then 
        //     set .a = .a + 5
        // endif
        // call SetUnitFacing(.caster, .a)
        set.time = .time - 1 
        if.time <= 0  then 
            // set.x = Math.ppx( Unit.x(.caster), .speed, GetUnitFacing(.caster)) 
            // set.y = Math.ppy( Unit.y(.caster), .speed, GetUnitFacing(.caster)) 
            set bj_int = 1
            loop
                exitwhen bj_int > 5
                set mt = Missle_Touch.create()
                set mt.caster = .caster
                set mt.time = .time_bow
                set mt.is_touch = false
                set mt.speed = .speed
                set mt.aoe = .aoe
                set mt.a = GetUnitFacing(.caster) - (15 * 3) + (15 * bj_int)
                call mt.setxyz(GetUnitX( .caster) , GetUnitY( .caster) , .z)
                set mt.DMG_TYPE = .DMG_TYPE 
                set mt.ATK_TYPE = .ATK_TYPE 
                set mt.dmg = .dmg
                set mt.missle_path = .missle_path
                set mt.attach = .attach
                set mt.attach_path = .attach_path
                call mt.spell_now()
    
                set bj_int = bj_int + 1
            endloop
  
            call Unit.enabledmove(this.caster)
            // call PauseUnit(.caster, false)
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        set .start_anim = .time - 1
        call Unit.disablemove(this.caster)
        // call PauseUnit(.caster, true)
        set .a = GetUnitFacing(.caster)
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct

struct Staff_Fire_Controller extends SKILL 
    string attach = ""
    string nova_path = "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl"
    string attach_path = ""
    real nova_size = 1.00
    string anim = ""
    integer start_anim = 0
    integer time_bow = 0
    real aoe_nova = 0
    
    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        local Missle_Touch_Nova mt
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            // call PauseUnit(.caster, false)
            call Unit.enabledmove(this.caster)
            // call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        if.time == .start_anim then 
            call SetUnitAnimation(.caster, .anim)
        endif

        call SetUnitFacingTimed(.caster, quickcast.getUA(.caster), 0.03125 * 2)
        // set bj_real = quickcast.getUA(.caster)
        // if .a > bj_real then 
        //     set .a = .a - 5
        // elseif .a < bj_real then 
        //     set .a = .a + 5
        // endif
        // call SetUnitFacing(.caster, .a)
        set.time = .time - 1 
        if.time <= 0  then 
            // set.x = Math.ppx( Unit.x(.caster), .speed, GetUnitFacing(.caster)) 
            // set.y = Math.ppy( Unit.y(.caster), .speed, GetUnitFacing(.caster)) 
            set mt = Missle_Touch_Nova.create()
            set mt.caster = .caster
            set mt.time = .time_bow
            set mt.is_touch = false
            set mt.speed = .speed
            set mt.aoe = .aoe
            set mt.aoe_nova = .aoe_nova
            set mt.a = GetUnitFacing(.caster) 
            call mt.setxyz(GetUnitX( .caster) , GetUnitY( .caster) , .z)
            set mt.DMG_TYPE = .DMG_TYPE 
            set mt.ATK_TYPE = .ATK_TYPE 
            set mt.dmg = .dmg
            set mt.missle_path = .missle_path
            set mt.missle_size = .missle_size
            set mt.nova_path = .nova_path
            set mt.nova_size = .nova_size
            set mt.attach = .attach
            set mt.attach_path = .attach_path
            call mt.spell_now()
  
            call Unit.enabledmove(this.caster)
            // call PauseUnit(.caster, false)
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        set .start_anim = .time - 1
        call Unit.disablemove(this.caster)
        // call PauseUnit(.caster, true)
        set .a = GetUnitFacing(.caster)
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct


struct Wand_Lightning_Controller extends SKILL 
    string anim = ""
    integer start_anim = 0
    
    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        local integer n = 1
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            // call PauseUnit(.caster, false)
            call Unit.enabledmove(this.caster)
            // call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        if.time == .start_anim then 
            call SetUnitAnimation(.caster, .anim)
        endif

        call SetUnitFacingTimed(.caster, quickcast.getUA(.caster), 0.03125 * 2)
        // set bj_real = quickcast.getUA(.caster)
        // if .a > bj_real then 
        //     set .a = .a - 5
        // elseif .a < bj_real then 
        //     set .a = .a + 5
        // endif
        // call SetUnitFacing(.caster, .a)
        set.time = .time - 1 
        if.time <= 0  then 
            // set.x = Math.ppx( Unit.x(.caster), .speed, GetUnitFacing(.caster)) 
            // set.y = Math.ppy( Unit.y(.caster), .speed, GetUnitFacing(.caster)) 
            loop
                exitwhen n > 6
                call Aiming.enemy_nearest( .caster, Math.ppx(Unit.x(.caster), 100 * n, GetUnitFacing(.caster)) , Math.ppy(Unit.y(.caster), 100 * n, GetUnitFacing(.caster)) , 200) // set bj_unit = enemy gần nhất
                if bj_unit != null then 
                    call SetUnitX(DummyX.load[Num.uid( .caster)] , GetUnitX(.caster))
                    call SetUnitY(DummyX.load[Num.uid( .caster)] , GetUnitY(.caster))
                    call DummyX.chain_lightning(DummyX.load[Num.uid( .caster)] , bj_unit, 0.15, .dmg, 3) 
                    exitwhen true
                endif
                set n = n + 1
            endloop
            call Aiming.reset() // set bj_u == null
  
            call Unit.enabledmove(this.caster)
            // call PauseUnit(.caster, false)
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        set .start_anim = .time - 1
        call Unit.disablemove(this.caster)
        // call PauseUnit(.caster, true)
        set .a = GetUnitFacing(.caster)
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct

struct Rod_Controller extends SKILL 
    string anim = ""
    integer start_anim = 0
    
    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        local integer n = 1
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            // call PauseUnit(.caster, false)
            call Unit.enabledmove(this.caster)
            // call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        if.time == .start_anim then 
            call SetUnitAnimation(.caster, .anim)
           
        endif

        call SetUnitFacingTimed(.caster, quickcast.getUA(.caster), 0.03125 * 2)
        // set bj_real = quickcast.getUA(.caster)
        // if .a > bj_real then 
        //     set .a = .a - 5
        // elseif .a < bj_real then 
        //     set .a = .a + 5
        // endif
        // call SetUnitFacing(.caster, .a)
        set.time = .time - 1 
        if .time == 1 then 
            loop
                exitwhen n > 6
                call Aiming.enemy_nearest( .caster, Math.ppx(Unit.x(.caster), 100 * n, GetUnitFacing(.caster)) , Math.ppy(Unit.y(.caster), 100 * n, GetUnitFacing(.caster)) , 200) // set bj_unit = enemy gần nhất
                if bj_unit != null then 
                    call Eff.attach("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", bj_unit, "origin")
                    call SetUnitX(DummyX.load[Num.uid( .caster)] , GetUnitX(bj_unit))
                    call SetUnitY(DummyX.load[Num.uid( .caster)] , GetUnitY(bj_unit))
                    call DummyX.slow(DummyX.load[Num.uid( .caster)], bj_unit, 4.00, 0.25, 0.25)
             
                    call UnitDamageTarget(.caster, bj_unit, .dmg, true, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, null) 
                    exitwhen true
                endif
                set n = n + 1
            endloop
            call Aiming.reset() // set bj_u == null
        endif
        if.time <= 0  then 
            // set.x = Math.ppx( Unit.x(.caster), .speed, GetUnitFacing(.caster)) 
            // set.y = Math.ppy( Unit.y(.caster), .speed, GetUnitFacing(.caster)) 
            call SetUnitX(DummyX.load[Num.uid( .caster)] , GetUnitX(.caster))
            call SetUnitY(DummyX.load[Num.uid( .caster)] , GetUnitY(caster))
            call DummyX.raise_dead(DummyX.load[Num.uid( .caster)], 'uske', 1, 0, 0, 18.00)
       
  
            call Unit.enabledmove(this.caster)
            // call PauseUnit(.caster, false)
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        set .start_anim = .time - 1
        call Unit.disablemove(this.caster)
        // call PauseUnit(.caster, true)
        
        set .a = GetUnitFacing(.caster)
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct

struct CrossBow_Controller extends SKILL 
    string attach = ""
    string attach_path = ""
    string anim = ""
    integer start_anim = 0
    integer time_bow = 0

    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        local Missle_Touch mt
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            // call PauseUnit(.caster, false)
            call Unit.enabledmove(this.caster)
            call SetUnitTimeScale(.caster, 1)

            // call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        if.time == .start_anim then 
            call SetUnitAnimation(.caster, .anim)
        endif

        call SetUnitFacingTimed(.caster, quickcast.getUA(.caster), 0.03125 * 2)
        // set bj_real = quickcast.getUA(.caster)
        // if .a > bj_real then 
        //     set .a = .a - 5
        // elseif .a < bj_real then 
        //     set .a = .a + 5
        // endif
        // call SetUnitFacing(.caster, .a)
        if.time == 64 then 
            call Unit.enabledmove(this.caster)
            call SetUnitTimeScale(.caster, 3)
        endif
        if .time <= 64  and ModuloInteger(.time, 16) == 0 then 
            call QueueUnitAnimation(.caster, "attack")
            set mt = Missle_Touch.create()
            set mt.caster = .caster
            set mt.time = .time_bow
            set mt.is_touch = false
            set mt.speed = .speed
            set mt.aoe = .aoe
            set mt.a = GetUnitFacing(.caster) + (RAbsBJ(GetUnitFacing(.caster)) - RAbsBJ(GetUnitFacing(.caster)))
            call mt.setxyz(GetUnitX( .caster) , GetUnitY( .caster) , .z)
            set mt.DMG_TYPE = .DMG_TYPE 
            set mt.ATK_TYPE = .ATK_TYPE 
            set mt.dmg = .dmg
            set mt.missle_path = .missle_path
            set mt.missle_size = .missle_size
            set mt.attach = .attach
            set mt.attach_path = .attach_path
            call mt.spell_now()
        endif
        set.time = .time - 1 
        if.time <= 0  then 
            // set.x = Math.ppx( Unit.x(.caster), .speed, GetUnitFacing(.caster)) 
            // set.y = Math.ppy( Unit.y(.caster), .speed, GetUnitFacing(.caster)) 
            call SetUnitTimeScale(.caster, 1)
            // call PauseUnit(.caster, false)
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        set .time = 84
        set .start_anim = .time - 1
        call Unit.disablemove(this.caster)
        // call PauseUnit(.caster, true)
        set .a = GetUnitFacing(.caster)
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct
struct Axe_Controller extends SKILL 
    string anim = ""
    integer start_anim = 0
    string attach = ""
    string attach_path = ""
    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        local integer n = 1
        local RotatingBulletPierce rbp
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            // call PauseUnit(.caster, false)
            call Unit.enabledmove(this.caster)
            // call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        
        call SetUnitFacingTimed(.caster, quickcast.getUA(.caster), 0.03125 * 2)
        if.time == .start_anim then 
            call SetUnitAnimation(.caster, .anim)
            set rbp = RotatingBulletPierce.create()
            set rbp.caster = .caster
            set rbp.a = quickcast.getUA(.caster) - 60
            set rbp.rotationSpeed = 240
            set rbp.ATK_TYPE = .ATK_TYPE
            set rbp.DMG_TYPE = .DMG_TYPE
            set rbp.aoe = .aoe
            set rbp.radius = 195
            set rbp.dmg = .dmg
            set rbp.time = 24
            set rbp.z = 100
            set rbp.missle_path = .missle_path
            set rbp.missle_size = .missle_size
            set rbp.attach = .attach
            set rbp.attach_path = .attach_path
            call rbp.spell_now()
        endif

        set.time = .time - 1 
        if.time <= 0  then 
           
            call Unit.enabledmove(this.caster)
            // call PauseUnit(.caster, false)
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        set .start_anim = .time - 1
        call Unit.disablemove(this.caster)
        // call PauseUnit(.caster, true)
        set .a = GetUnitFacing(.caster)
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct
struct Claw_Controller extends SKILL 
    string anim = ""
    integer start_anim = 0
    string attach = ""
    string attach_path = ""
    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        local integer n = 1
        local RotatingBulletPierce rbp
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            // call PauseUnit(.caster, false)
            call Unit.enabledmove(this.caster)
            // call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        
        call SetUnitFacingTimed(.caster, quickcast.getUA(.caster), 0.03125 * 2)
        if.time == .start_anim then 
            set bj_lastCreatedEffect = AddSpecialEffect("Weapon\\Claws.mdx", Unit.x(.caster), Unit.y(.caster)) 
            // call BlzSetSpecialEffectOrientation(bj_lastCreatedEffect, Deg2Rad(GetUnitFacing( .caster)) , 0, Deg2Rad(- 45)) 
            call BlzSetSpecialEffectHeight(bj_lastCreatedEffect, Math.pz( Unit.x(.caster), Unit.y(.caster)) - 50) 
            call BlzSetSpecialEffectTimeScale(bj_lastCreatedEffect, 0.8) 
            call DestroyEffect(bj_lastCreatedEffect) 
        
            call SetUnitAnimation(.caster, .anim)
            set rbp = RotatingBulletPierce.create()
            set rbp.caster = .caster
            set rbp.a = quickcast.getUA(.caster) - 60
            set rbp.rotationSpeed = 240
            set rbp.ATK_TYPE = .ATK_TYPE
            set rbp.DMG_TYPE = .DMG_TYPE
            set rbp.aoe = .aoe
            set rbp.radius = 195
            set rbp.dmg = .dmg
            set rbp.time = 24
            set rbp.z = 100
            set rbp.missle_path = .missle_path
            set rbp.missle_size = .missle_size
            set rbp.attach = .attach
            set rbp.attach_path = .attach_path
            call rbp.spell_now()
        endif

        set.time = .time - 1 
        if.time <= 0  then 
            set bj_lastCreatedEffect = AddSpecialEffect("Weapon\\Claws.mdx", Unit.x(.caster), Unit.y(.caster)) 
            // call BlzSetSpecialEffectOrientation(bj_lastCreatedEffect, Deg2Rad(GetUnitFacing( .caster)) , 0, Deg2Rad(- 135)) 
            call BlzSetSpecialEffectHeight(bj_lastCreatedEffect, Math.pz( Unit.x(.caster), Unit.y(.caster)) - 50) 
            call BlzSetSpecialEffectTimeScale(bj_lastCreatedEffect, 0.65) 
            call DestroyEffect(bj_lastCreatedEffect) 

            call SetUnitAnimation(.caster, .anim)
            call Unit.enabledmove(this.caster)
            set rbp = RotatingBulletPierce.create()
            set rbp.caster = .caster
            set rbp.a = quickcast.getUA(.caster) - 60
            set rbp.rotationSpeed = 240
            set rbp.ATK_TYPE = .ATK_TYPE
            set rbp.DMG_TYPE = .DMG_TYPE
            set rbp.aoe = .aoe
            set rbp.radius = 165
            set rbp.dmg = .dmg
            set rbp.time = 24
            set rbp.z = 100
            set rbp.missle_path = .missle_path
            set rbp.missle_size = .missle_size
            set rbp.attach = .attach
            set rbp.attach_path = .attach_path
            call rbp.spell_now()
            // call PauseUnit(.caster, false)
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        set .start_anim = .time - 1
        call Unit.disablemove(this.caster)
        // call PauseUnit(.caster, true)
        set .a = GetUnitFacing(.caster)
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct