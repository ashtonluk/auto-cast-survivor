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