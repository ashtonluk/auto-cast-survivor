struct SKILL 
    unit caster = null 
    unit target = null 
    unit u = null 
    group g = null 
    damagetype DMG_TYPE = null 
    attacktype ATK_TYPE = null 
    integer time = 0 
    real increment = 0.00
    real speed = 0.00 
    real dmg = 0.00 
    real aoe = 0.00 
    real a = 0.00 
    real p = 0.00 
    real x = 0.00 
    real y = 0.00 
    real xt = 0.00 
    real yt = 0.00 
    real z = 0.00 
    real h = 0.00
    integer buff_id 
    integer buff_lv 
    integer buff_dur 

    effect missle = null 
    string missle_path = "" 
    real missle_size = 1.00
    real missle_speed = 1.00
    boolean is_touch = false 
    integer count = 0


    lightning light = null 
    string light_name = ""
    lightning light2 = null 
    string light_name2 = ""

    real t = 0.00 // Giá trị tham số (0.0 -> 1.0)
    real startX = 0.00 
    real startY = 0.00 
    real startZ = 0.00 
    real midX = 0.00 
    real midY = 0.00 
    real midZ = 0.00 
    real endX = 0.00  
    real endY = 0.00 
    real endZ = 0.00 
    method setxyz takes real x, real y, real z returns nothing 
        set.x = x 
        set.y = y 
        set.z = z 
    endmethod 
    method Ally takes unit u , unit e returns boolean 
        if not Boo.isdead(e) and IsUnitAlly(u, GetOwningPlayer(e)) and Boo.ishero(e) then 
            return true 
        endif 
        return false
    endmethod
    method FilterUnit takes unit u, unit e returns boolean 
        if not Boo.isdead(e)  and IsUnitEnemy(u, GetOwningPlayer(e)) and BlzIsUnitInvulnerable(e) == false then 
            return true 
        endif 
        return false
    endmethod
endstruct 

struct Missle_Touch extends SKILL 
    string attach = ""
    string attach_path = ""
    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        set.x = Math.ppx( .x, .speed, .a) 
        set.y = Math.ppy( .y, .speed, .a) 
        call Eff.angle( .missle, .a) 
        call Eff.pos( .missle, .x, .y, Math.pz( .x, .y) + .z) 

        set g = CreateGroup() 
        call Group.enum(g, .x, .y, .aoe) 
        loop 
            set e = FirstOfGroup(g) 
            exitwhen(e == null or.is_touch == true)
            if not.is_touch and.FilterUnit( .caster, e) then 
                set.is_touch = true 
                call Eff.attach( .attach_path, e, .attach)
                call UnitDamageTarget(.caster, e, .dmg, true, true, .ATK_TYPE, .DMG_TYPE, null) 
            endif 
            call Group.remove(e, g) 
        endloop 
        call Group.release(g) 
        set e = null 

        set.time = .time - 1 
        if.time <= 0 or.is_touch then 
            call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        // set mt = Missle_Touch.create()
        set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z) 
        call Eff.size( .missle, .missle_size) 
        call Eff.angle( .missle, .a) 
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct
struct Missle_Touch_Nova extends SKILL 
    real aoe_nova = 0
    string nova_path = "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl"
    string attach_path = ""
    real nova_size = 1.00
    string attach = ""
    private static method spell_update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        if Boo.isdead( .caster) then // Unit chết thì ko làm gì
            call DestroyEffect( .missle) 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance 
        endif
        set.x = Math.ppx( .x, .speed, .a) 
        set.y = Math.ppy( .y, .speed, .a) 
        call Eff.angle( .missle, .a) 
        call Eff.pos( .missle, .x, .y, Math.pz( .x, .y) + .z) 

        set g = CreateGroup() 
        call Group.enum(g, .x, .y, .aoe) 
        loop 
            set e = FirstOfGroup(g) 
            exitwhen(e == null or.is_touch == true)
            if not.is_touch and.FilterUnit( .caster, e) then 
                set.is_touch = true 
                call Eff.attach( .attach_path, e, .attach)
                call UnitDamageTarget(.caster, e, .dmg, true, true, .ATK_TYPE, .DMG_TYPE, null) 
            endif 
            call Group.remove(e, g) 
        endloop 
        call Group.release(g) 
        set e = null 

        set.time = .time - 1 
        if.time <= 0 or.is_touch then 
            call DestroyEffect( .missle) 
            set bj_lastCreatedEffect = AddSpecialEffect(.nova_path, .x, .y) 
            call Eff.size( bj_lastCreatedEffect, .nova_size) 
            call DestroyEffect(bj_lastCreatedEffect)
            
            set g = CreateGroup() 
            call Group.enum(g, .x, .y, .aoe_nova) 
            loop 
                set e = FirstOfGroup(g) 
                exitwhen(e == null )
                if .FilterUnit( .caster, e) then 
                    call UnitDamageTarget(.caster, e, .dmg, true, true, .ATK_TYPE, .DMG_TYPE, null) 
                endif 
                call Group.remove(e, g) 
            endloop 
            call Group.release(g) 
            set e = null 
            call runtime.end() // End the timer                                                                                                                                                                                                       
            call.destroy() // Destroy the instance                                                                   
        endif 
    endmethod 
    method spell_now takes nothing returns boolean 
        // set mt = Missle_Touch.create()
        set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z) 
        call Eff.size( .missle, .missle_size) 
        call Eff.angle( .missle, .a) 
        call runtime.new(this, P32, true, function thistype.spell_update) 
        return false 
    endmethod 
endstruct


// struct Missle_Pierce extends SKILL 
//     string attach = ""
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster) then // Unit chết thì ko làm gì
//             call DestroyEffect( .missle) 
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         set.x = Math.ppx( .x, .speed, .a) 
//         set.y = Math.ppy( .y, .speed, .a) 
//         call Eff.angle( .missle, .a) 
//         call Eff.pos( .missle, .x, .y, Math.pz( .x, .y) + .z) 

//         set g = CreateGroup() 
//         call Group.enum(g, .x, .y, .aoe) 
//         loop 
//             set e = FirstOfGroup(g) 
//             exitwhen(e == null)
//             if not IsUnitInGroup(e, .g) and.FilterUnit( .caster, e) then 
//                 call Group.add(e, .g)
//                 call Eff.chest(.attach, e)
//                 call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//             endif 
//             call Group.remove(e, g) 
//         endloop 
//         call Group.release(g) 
//         set e = null 

//         set.time = .time - 1 
//         if.time <= 0  then 
//             call Group.release(.g)
//             call DestroyEffect( .missle) 
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         set.g = CreateGroup()
//         set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z) 
//         call Eff.size( .missle, .missle_size) 
//         call Eff.angle( .missle, .a) 
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct
// struct Missle_Find extends SKILL 
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster)  or Boo.isdead(.target) then // Unit chết thì ko làm gì
//             call DestroyEffect( .missle) 
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         set .a = Math.ab(.x, .y, GetUnitX(.target), GetUnitY(.target))
//         set.x = Math.ppx( .x, .speed, .a) 
//         set.y = Math.ppy( .y, .speed, .a) 
//         call Eff.angle( .missle, .a) 
//         call Eff.pos( .missle, .x, .y, Math.pz( .x, .y) + .z) 

//         set g = CreateGroup() 
//         call Group.enum(g, .x, .y, .aoe) 
//         loop 
//             set e = FirstOfGroup(g) 
//             exitwhen(e == null or.is_touch == true)
//             if not.is_touch and.FilterUnit( .caster, e) and e ==.target then 
//                 set.is_touch = true 
//                 call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//             endif 
//             call Group.remove(e, g) 
//         endloop 
//         call Group.release(g) 
//         set e = null 

//         set.time = .time - 1 
//         if.time <= 0 or.is_touch then 
//             call DestroyEffect( .missle) 
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z) 
//         call Eff.size( .missle, .missle_size) 
//         call Eff.angle( .missle, .a) 
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct
// struct Missle_Rain extends SKILL
//     real gravity = 5.00
//     string nova_path = "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl"
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster) then // Unit chết thì ko làm gì
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         set.z = .z - .gravity
//         // call BJDebugMsg(R2S(.z))
//         call BlzSetSpecialEffectZ( .missle, Math.pz( .x, .y) + .z) 
//         if.z <= 0 then 
//             call Eff.nova( .nova_path, .x, .y)
//             set g = CreateGroup() 
//             call Group.enum(g, .x, .y, .aoe) 
//             loop 
//                 set e = FirstOfGroup(g) 
//                 exitwhen e == null 
//                 if.FilterUnit( .caster, e) then 
//                     call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//                 endif 
//                 call Group.remove(e, g) 
//             endloop 
//             call Group.release(g) 
//             set e = null 
//             call DestroyEffect( .missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance   
//         endif
      
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z)
//         call Eff.size( .missle, .missle_size) 
//         set.p = 180
//         call Eff.pitch( .missle, .p)
//         call Eff.angle( .missle, .a)
//         call Eff.speed( .missle, .missle_speed)
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct

// //🎀 Gán u là một unit missle, cho nó di chuyển tới target chỉ định và gây dmg kết thúc
// struct Missle_Unit_Find extends SKILL 
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster)  or Boo.isdead(.target) then // Unit chết thì ko làm gì
//             call RemoveUnit(.u)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         set .a = Math.ab(.x, .y, GetUnitX(.target), GetUnitY(.target))
//         set .speed = .speed + .increment
//         set.x = Math.ppx( .x, .speed, .a) 
//         set.y = Math.ppy( .y, .speed, .a) 
//         call SetUnitFacing(.u, .a)
//         call SetUnitX(.u, .x)
//         call SetUnitY(.u, .y)
//         call SetUnitFlyHeight(.u, Math.pz( .x, .y) + .z, 0)
//         set g = CreateGroup() 
//         call Group.enum(g, .x, .y, .aoe) 
//         loop 
//             set e = FirstOfGroup(g) 
//             exitwhen(e == null or.is_touch == true)
//             if not.is_touch and.FilterUnit( .caster, e) and e ==.target then 
//                 set.is_touch = true 
//                 call Eff.chest(.missle_path, e)
//                 call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//             endif 
//             call Group.remove(e, g) 
//         endloop 
//         call Group.release(g) 
//         set e = null 

//         set.time = .time - 1 
//         if.time <= 0 or.is_touch then 
//             call RemoveUnit(.u)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         call SetUnitPathing(.u, false)
//         call UnitAddAbility(.u, 'Arav')
//         call UnitRemoveAbility(.u, 'Arav')
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct

// //🎀 Gọi ra 1 cái bẫy tồn tại X giây, khi có kẻ địch trong phạm vi thì phát nổ
// struct Trap_AoE extends SKILL 
//     string nova_path = ""
//     string attach_path = ""
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster)  then // Unit chết thì ko làm gì
//             call DestroyEffect(.missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif

//         set g = CreateGroup() 
//         call Group.enum(g, .x, .y, .aoe) 
//         loop 
//             set e = FirstOfGroup(g) 
//             exitwhen(e == null)
//             if .FilterUnit( .caster, e) then 
//                 set.is_touch = true 
//                 call Eff.chest(.attach_path, e)
//                 call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//             endif 
//             call Group.remove(e, g) 
//         endloop 
//         call Group.release(g) 
//         set e = null 

//         if .is_touch then 
//             call Eff.nova(.nova_path, .x, .y)
//         endif

//         set.time = .time - 1 
//         if.time <= 0 or.is_touch then 
//             call DestroyEffect(.missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z) 
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct

// //🎀 AoE DPS : Mỗi X time gọi ra effect và gây dmg aoe | tick: Mỗi x time sẽ gọi , increment : Giảm x time mỗi lần gọi
// struct AoE_DPS extends SKILL 
//     string nova_path = ""
//     string attach_path = ""
//     integer tick = 0
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster)  then // Unit chết thì ko làm gì
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         if ModuloInteger(.time , .tick) == 0 then 
//             set .tick = .tick - R2I(.increment)
//             call Eff.nova(.nova_path, .x, .y)
//             set g = CreateGroup() 
//             call Group.enum(g, .x, .y, .aoe) 
//             loop 
//                 set e = FirstOfGroup(g) 
//                 exitwhen(e == null)
//                 if .FilterUnit( .caster, e)  then 
//                     call Eff.chest(.attach_path, e)
//                     call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//                 endif 
//                 call Group.remove(e, g) 
//             endloop 
//             call Group.release(g) 
//             set e = null 
//         endif

//         set.time = .time - 1 
//         if.time <= 0 then 
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct
// //🎀 DPS : Mỗi X time gọi ra effect và gây dmg target | tick: Mỗi x time sẽ gọi , increment : Giảm x time mỗi lần gọi
// struct DPS extends SKILL 
//     string nova_path = ""
//     string attach_path = ""
//     integer tick = 0
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster)  then // Unit chết thì ko làm gì
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         if ModuloInteger(.time , .tick) == 0 then 
//             set .tick = .tick - R2I(.increment)
//             call Eff.chest(.attach_path, .target)
//             call dmg.mag( .caster, .target, .DMG_TYPE, .dmg)
//         endif

//         set.time = .time - 1 
//         if.time <= 0 then 
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct
// //Gây sát thương đơn lẻ lên target sau X giây
// struct DE extends SKILL 
//     string attach_path = ""
//     integer tick = 0
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster)  then // Unit chết thì ko làm gì
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         set.time = .time - 1 
//         if.time <= 0 then 
//             call Eff.chest(.attach_path, .target)
//             call dmg.mag( .caster, .target, .DMG_TYPE, .dmg)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct
// //🎀 Missle_Nova: Di chuyển missle từ caster tới vị trí chỉ định và gây sát thương sau khi tới vị trí chỉ định
// struct Missle_Nova extends SKILL 
//     string nova_path = "Objects\\Spawnmodels\\NightElf\\NECancelDeath\\NECancelDeath.mdl"
//     string attach_path = ""
//     real nova_size = 1.00
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster)  then // Unit chết thì ko làm gì
//             call DestroyEffect(.missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif

//         set.x = Math.ppx( .x, .speed, .a) 
//         set.y = Math.ppy( .y, .speed, .a) 
//         call Eff.angle( .missle, .a) 
//         call Eff.pos( .missle, .x, .y, Math.pz( .x, .y) + .z) 

    

//         set.time = .time - 1 
//         if.time <= 0 then 
//             call DestroyEffect(.missle)

//             set bj_lastCreatedEffect = AddSpecialEffect(.nova_path, .x, .y) 
//             call Eff.size( bj_lastCreatedEffect, .nova_size) 
//             call DestroyEffect(bj_lastCreatedEffect)

//             set g = CreateGroup() 
//             call Group.enum(g, .x, .y, .aoe) 
//             loop 
//                 set e = FirstOfGroup(g) 
//                 exitwhen(e == null )
//                 if .FilterUnit( .caster, e) then 
//                     call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//                 endif 
//                 call Group.remove(e, g) 
//             endloop 
//             call Group.release(g) 
//             set e = null 

//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         set .time = R2I( (Math.db (.x, .y, .xt, .yt)) / .speed)
//         set.missle = Eff.new( .missle_path, .x, .y, Math.pz( .x, .y) + .z) 
//         call Eff.size( .missle, .missle_size) 
//         call Eff.angle( .missle, .a)  
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct

// //🎀 AoE_Cone : Gây sát thương theo hình nón
// struct AoE_Cone extends SKILL 
//     string nova_path = ""
//     string attach_path = ""
//     real cone_angle = 35
//     method AngleBetween takes real a1, real a2 returns real
//         local real diff = RAbsBJ(a1 - a2)
//         if diff > 180 then
//             set diff = 360 - diff
//         endif
//         return diff
//     endmethod
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster)  then // Unit chết thì ko làm gì
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         set.time = .time - 1 
//         if.time <= 0 then 
//             call Eff.nova(.nova_path, .x, .y)
//             set g = CreateGroup() 
//             call Group.enum(g, .x, .y, .aoe) 
//             loop 
//                 set e = FirstOfGroup(g) 
//                 exitwhen(e == null)
//                 if .FilterUnit( .caster, e) and .AngleBetween(Math.ab(Math.ppx(.x, - 1 * (.aoe / 2), .a ), Math.ppy(.y, - 1 * (.aoe / 2), .a ), GetUnitX(e), GetUnitY(e)), .a) <= .cone_angle / 2 then 
//                     call Eff.chest(.attach_path, e)
//                     call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//                 endif 
//                 call Group.remove(e, g) 
//             endloop 
//             call Group.release(g) 
//             set e = null 
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct

// //🎀 VFX_Unit_Scale : Tăng hoặc giảm kích cỡ một unit trong time
// struct VFX_Unit_Scale extends SKILL 
//     real scale_increment = 0.025
//     boolean is_reverse = true 
//     boolean default_end = true
//     real scale_original = 1.00
//     real scale = 1.00
//     integer reverse_tick = 0 // 
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
     
//         if Boo.isdead( .caster)  then // Unit chết thì ko làm gì
//             if .default_end then 
//                 call SetUnitScale(.caster, .scale_original, .scale_original, .scale_original)
//             endif
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         if .time <= .reverse_tick and .is_reverse then 
//             set .scale = .scale - .scale_increment
//         else
//             set .scale = .scale + .scale_increment
//         endif
//         call SetUnitScale(.caster, .scale, .scale, .scale)
//         set.time = .time - 1 
//         if.time <= 0 then 
//             if .default_end then 
//                 call SetUnitScale(.caster, .scale_original, .scale_original, .scale_original)
//             endif
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         set .scale = .scale_original
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct
// struct SFX_VoHon extends SKILL 
//     real scale_increment = 0.025
//     real scale = 1.00
//     integer reverse_tick = 0 // 
//     integer alpha = 255
//     integer alpha_increment = - 5
//     real height = 100
//     real height_increment = 3
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         if Boo.isdead( .caster)  then // Unit chết thì ko làm gì
//             call RemoveUnit(.u)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         set .scale = .scale + .scale_increment
//         set .height = .height + .height_increment
//         set .alpha = .alpha + .alpha_increment
//         set .x = Math.ppx(.x, .speed, .a)
//         set .y = Math.ppy(.y, .speed, .a)
//         call SetUnitX(.u, .x)
//         call SetUnitY(.u, .y)
//         call SetUnitScale(.u, .scale, .scale, .scale)
//         call SetUnitFlyHeight(.u, .height, 0)
//         call SetUnitVertexColor(.u, 255, 255, 255, .alpha)
//         set.time = .time - 1 
//         if.time <= 0 then 
//             call RemoveUnit(.u)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         set .a = GetUnitFacing(.caster)
//         set .x = Math.ppx(GetUnitX(.caster), - 80, .a)
//         set .y = Math.ppy(GetUnitY(.caster), - 80, .a)
//         call PauseUnit(.u, true)
//         //
//         // set vh.caster = caster 
//         // set vh.u = CreateUnit(GetOwningPlayer(.caster), 'n000', .x, .y, .a)
//         // set vh.alpha = 200
//         // set vh.height = GetUnitDefaultFlyHeight(.u) + 100
//         // set vh.height_increment = 3
//         // set vh.speed = - 5
//         // set vh.time = 16
//         call UnitAddAbility(.u, 'Avul')
//         call UnitAddAbility(.u, 'Aloc')
//         call UnitAddAbility(.u, 'Arav')
//         call UnitRemoveAbility(.u, 'Arav')
//         call SetUnitFacing(.u, .a)
  

//         call SetUnitVertexColor(.u, 255, 255, 255, .alpha)
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct


// struct BezierMissile extends SKILL
//     method spell_now takes nothing returns nothing 
//         // set mss.missle = AddSpecialEffect(.missle_path, GetUnitX(.caster), GetUnitY(.caster))
//         // set mss.target = .target
//         // set mss.t = 0.0
//         // set mss.speed = 0.05
//         // set mss.DMG_TYPE = DOC
//         // set mss.dmg = .dmg
//         // set mss.is_lv20 = .is_lv20
//         // set mss.endX = GetUnitX(.target)
//         // set mss.endY = GetUnitY(.target)
//         // set mss.endZ = GetUnitFlyHeight(.target)
//         // set mss.startX = Math.ppx(GetUnitX(.caster), distance, angle)
//         // set mss.startY = Math.ppy(GetUnitY(.caster), distance, angle)
//         // set mss.startZ = Math.pz( GetUnitX(.caster), GetUnitY(.caster))
//         // set mss.midX = ((mss.startX + mss.endX) / 2.0 ) + GetRandomReal(- 200, 200)
//         // set mss.midY = ((mss.startY + mss.endY) / 2.0 ) + GetRandomReal(- 200, 200)
//         // set mss.midZ = GetRandomReal(200, 400)
//         // set mss.caster = .caster
//         call runtime.new(this, P32, true, function thistype.move) 
//     endmethod
//     private static method move takes nothing returns nothing
//         local timer t = GetExpiredTimer()
//         local thistype this = runtime.get() 
//         local real u = this.t
//         local real v = 1.0 - u
//         // Tính toán vị trí mới theo phương trình Bezier
//         local real x = v * v * this.startX + 2 * v * u * this.midX + u * u * this.endX
//         local real y = v * v * this.startY + 2 * v * u * this.midY + u * u * this.endY
//         local real z = v * v * this.startZ + 2 * v * u * this.midZ + u * u * this.endZ
//         // call BJDebugMsg(R2S(.t))

//         // Di chuyển hiệu ứng
//         call BlzSetSpecialEffectPosition(this.missle, x, y, z)
//         call Eff.angle(this.missle, Math.ab(x, y, GetUnitX(.target), GetUnitY(.target)))
//         // Tăng giá trị tham số
//         set this.t = (this.t + this.speed) 
//         // call BJDebugMsg(R2S(.t))

//         if this.t >= 1.0 then
//             call dmg.mag( .caster, .target, .DMG_TYPE, .dmg)
//             call DestroyEffect(this.missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance      
//         endif
//     endmethod
// endstruct



// struct RotatingBullet extends SKILL
//     real rotationSpeed   // Tốc độ quay
//     real radius

//     // Khởi tạo một viên đạn
//     method spell_now takes nothing returns nothing
//         local real x = GetUnitX(caster)
//         local real y = GetUnitY(caster)

//         // Thiết lập giá trị
//         // set this.caster = caster
//         // set this.a = angle
//         // set this.rotationSpeed = 360
//         // set this.aoe = 600
//         // set this.dmg = DAMAGE
//         // set this.time = 32

//         // Tạo hiệu ứng
//         set this.missle = AddSpecialEffect(.missle_path, x, y)

//         call runtime.new(this, P32, true, function thistype.move) 
//     endmethod
//     // Cập nhật vị trí và xử lý va chạm
//     private static method move takes nothing returns nothing
//         local timer t = GetExpiredTimer()
//         local thistype this = runtime.get() 
//         local real casterX = GetUnitX(this.caster)
//         local real casterY = GetUnitY(this.caster)
//         local real newX
//         local real newY
//         local group g = null 
//         local unit e = null
//         if Boo.isdead( .caster)  then // Unit chết thì ko làm gì
//             call DestroyEffect(.missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         // Cập nhật góc và tính toán vị trí mới
//         set this.a = this.a + this.rotationSpeed * P32
//         if this.a >= 360 then
//             set this.a = this.a - 360
//         endif

//         set newX = casterX + this.radius * Cos(this.a * bj_DEGTORAD)
//         set newY = casterY + this.radius * Sin(this.a * bj_DEGTORAD)

//         // Cập nhật vị trí hiệu ứng
//         call Eff.pos( .missle, newX, newY, Math.pz( newX, newY) + .z) 
//         call Eff.angle(.missle, .a + 90)

//         set g = CreateGroup() 
//         call Group.enum(g, newX, newY, .aoe) 
//         loop 
//             set e = FirstOfGroup(g) 
//             exitwhen(e == null or.is_touch == true)
//             if not.is_touch and.FilterUnit( .caster, e) then 
//                 set.is_touch = true 
//                 call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//             endif 
//             call Group.remove(e, g) 
//         endloop 
//         call Group.release(g) 
//         set e = null 
//         set .time = .time - 1 
 
//         if.time <= 0  or .is_touch then 
//             call DestroyEffect(.missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod
// endstruct


// struct Missile_Rain2 extends SKILL
//     real targetX
//     real targetY
//     real currentX
//     real currentY
//     real height
//     real angleYaw   // Góc xoay ngang (roll)
//     real anglePitch // Góc nghiêng (pitch)
//     real distance
//     real progress
//     string nova_path = ""
//     real h_start = 0.00
//     real h_end = 0.00
//     method spell_now takes nothing returns nothing
//         // set .targetX = targetX
//         // set .targetY = targetY
//         // set .caster = caster
//         // set .speed = 600
//         // set .dmg = 20
//         // set .DMG_TYPE = HOA
//         // set .height = 400.00
//         // set .missle_path = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl"
//         // set .aoe = 200
//         // set .nova_path = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl" 
//         // set .h_start = 400
//         // set .h_end = 0
//         set .startX = GetUnitX(.caster)
//         set .startY = GetUnitY(.caster)

//         set .currentX = .startX
//         set .currentY = .startY
//         set .distance = SquareRoot((targetX - .startX) * (targetX - .startX) + (targetY - .startY) * (targetY - .startY))
//         set .angleYaw = Atan2(targetY - .startY, targetX - .startX)
//         set .progress = 0.0
//         set .missle = AddSpecialEffect(.missle_path, .startX, .startY)
//         call runtime.new(this, P32, true, function thistype.move) 

//     endmethod

//     private static method move takes nothing returns nothing
//         local thistype this = runtime.get() 
//         local real speed = .speed * P32
//         local real dz
//         local unit e = null 
//         local group g = null
//         if Boo.isdead( .caster)   then // Unit chết thì ko làm gì
//             call DestroyEffect(.missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         // Tăng tiến độ và vị trí
//         set .t = .t + speed / .distance
//         set .currentX = .startX + (.targetX - .startX) * .t
//         set .currentY = .startY + (.targetY - .startY) * .t
//         set .height = .h_start + (.h_end - .h_start) * .t

//         // Tính góc pitch
//         set dz = .height - Math.pz(.currentX, .currentY)  // Độ chênh lệch chiều cao
//         set .anglePitch = Atan2(dz, speed * P32)

//         // Di chuyển và xoay hiệu ứng
//         call Eff.pos(.missle, .currentX, .currentY, .height)
//         call Eff.pitch(.missle, .anglePitch)
//         call Eff.roll(.missle, .angleYaw)

//         // Kiểm tra va chạm
//         if .t >= 1.0 then
//             call Eff.nova(.nova_path, .currentX, .currentY)
//             set g = CreateGroup() 
//             call Group.enum(g, .currentX, .currentY, .aoe) 
//             loop 
//                 set e = FirstOfGroup(g) 
//                 exitwhen(e == null )
//                 if .FilterUnit( .caster, e) then 
//                     call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//                 endif 
//                 call Group.remove(e, g) 
//             endloop 
//             call Group.release(g) 
//             set e = null 
//             call DestroyEffect(.missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance    
//         endif
//     endmethod

// endstruct


// struct Missle_Bouncing extends SKILL 
//     integer cliff = 0
//     private static method move takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         local real x = 0 
//         local real y = 0 
//         local boolean b = false 
//         if Boo.isdead( .caster)   then // Unit chết thì ko làm gì
//             call DestroyEffect(.missle)
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         set x = Math.ppx(.x, .speed, .a) 
//         set y = Math.ppy(.y, .speed, .a) 
//         if IsTerrainWalkable(x, y) and GetTerrainCliffLevel(x, y) <=.cliff then 
//             set .cliff = GetTerrainCliffLevel(x, y)
//             set b = true 
//         else 
//             set.a =.a + 180 
//         endif 

//         if b then 
//             set.x = x 
//             set.y = y 
//             call Eff.angle(.missle, .a) 
//             call Eff.pos(.missle, .x, .y, Math.pz(.x, .y) +.z) 
//         endif 

//         set g = CreateGroup() 
//         call Group.enum(g, .x, .y, .aoe) 
//         loop 
//             set e = FirstOfGroup(g) 
//             exitwhen (e == null or .is_touch)
//             if .FilterUnit(.caster, e) and not .is_touch then 
//                 call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//                 set .is_touch = true
//             endif 
//             call Group.remove(e, g) 
//         endloop 
//         call Group.release(g) 
//         set e = null 


//         set.time =.time - 1 
//         if.time <= 0 or .is_touch then 
//             call DestroyEffect(.missle) 
//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns nothing 
//         // set mb = Missle_Bouncing.create()
//         // set mb.time = 32*6 
//         // set mb.caster = caster
//         // call mb.setxyz(x,y,z)
//         // set mb.a = Math.ab(GetUnitX(caster),GetUnitY(caster),xt,yt)
//         // set mb.DMG_TYPE = LOI 
//         // set mb.dmg = 20 
//         // set mb.aoe = 50 
//         // set mb.speed = 15 
//         // set mb.missle_path = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl"
//         // set mb.missle_size = 0.75
//         // set mb.cliff = GetTerrainCliffLevel(.x, .y) 
//         // call mb.spell_now()

//         set.missle = Eff.new(.missle_path, .x, .y, Math.pz(.x, .y) +.z) 
//         call Eff.size(.missle, .missle_size) 
//         call Eff.angle(.missle, .a) 
//         call runtime.new(this, P32, true, function thistype.move) 
//     endmethod 
// endstruct

// // struct Missle_Volley_Touch extends SKILL 
// //     private static method VolleyTouchUpdate takes nothing returns nothing 
// //         local thistype this = getRT() 
// //         local group g 
// //         local unit e 
// //         local real r = 0 
// //         local real r2 = 0 

// //         set r =.a + 30 * Cos(.i * bj_PI / 20) 
// //         set r2 =.a + 30 * Sin(.i * bj_PI / 20) 
// //         // set.speed = ((.d / (25.00 + 15)) + ((15.00 / (800 + 50)) *.d))                                                                                                                                                                                                                                                        
// //         set.x = Math.ppx(.x, .speed, r) 
// //         set.y = Math.ppy(.y, .speed, r) 
// //         set.x2 = Math.ppx(.x2, .speed, r2) 
// //         set.y2 = Math.ppy(.y2, .speed, r2) 
// //         call angleEX(.ex, r) 
// //         call angleEX(.ex2, r2) 
// //         call setEX(.ex, .x, .y, Math.pz(.x, .y) +.z) 
// //         call setEX(.ex2, .x2, .y2, Math.pz(.x2, .y2) +.z) 

// //         set g = CreateGroup() 
// //         call Group.enum(g, .x, .y, .aoe) 
// //         loop 
// //             set e = FirstOfGroup(g) 
// //             exitwhen e == null 
// //             if not Boo.isdead(e) and IsUnitEnemy(e, GetOwningPlayer(.caster)) and not.is_touch and BlzIsUnitInvulnerable(e) == false then 
// //                 set.is_touch = true 
// //                 call UnitDamageTargetBJ(.caster, e, .dmg, .ATK_TYPE, .DAMAGE_TYPE) 
// //                 call EFFECT.GetEffect(.time, .caster, e, .eff, .x, .y, 0) 
// //             endif 
// //             call Group.remove(e, g) 
// //         endloop 
// //         call Group.release(g) 
// //         set e = null 

// //         set g = CreateGroup() 
// //         call Group.enum(g, .x2, .y2, .aoe) 
// //         loop 
// //             set e = FirstOfGroup(g) 
// //             exitwhen e == null 
// //             if not Boo.isdead(e) and IsUnitEnemy(e, GetOwningPlayer(.caster)) and not.is_touch2 and BlzIsUnitInvulnerable(e) == false then 
// //                 set.is_touch2 = true 
// //                 call UnitDamageTargetBJ(.caster, e, .dmg, .ATK_TYPE, .DAMAGE_TYPE) 
// //                 call EFFECT.GetEffect(.time, .caster, e, .eff, .x2, .y2, 0) 
// //             endif 
// //             call Group.remove(e, g) 
// //         endloop 
// //         call Group.release(g) 
// //         set e = null 

// //         set.t2 =.t2 + 1 
// //         // set this.t = R2I(.d /.speed) * 4                                                                                                                                                                                                                                                          
 
// //         set.i =.i - 1 
// //         if.i <= 0 or(.is_touch and.is_touch2) or GetUnitState(.caster, UNIT_STATE_LIFE) <= 0 then 
// //             call DestroyEffect(.ex) 
// //             call DestroyEffect(.ex2) 
// //             call breakRT() 
// //             call this.destroy() 
// //         endif 
// //     endmethod 
// //     public static method VolleyTouch takes unit caster, unit target, real x, real y, real z, real a, integer i, string path, real SizeMissleEff, real dmg, integer Effect, real time, damagetype dmgtype, attacktype atktype, real aoe, real speed returns boolean 
// //         local thistype this = thistype.create() 
// //         set.caster = caster 
// //         set.x = x 
// //         set.y = y 
// //         set.x2 = x 
// //         set.y2 = y 
// //         set.z = z 
// //         set.a = a 
// //         set.d = Math.dbU(caster, target) 
// //         set.t2 = 0 
// //         set.ex = newEX(path, .x, .y, Math.pz(.x, .y) +.z) 
// //         call sizeEX(.ex, SizeMissleEff) 
// //         call angleEX(.ex, a) 
// //         set.ex2 = newEX(path, .x, .y, Math.pz(.x, .y) +.z) 
// //         call sizeEX(.ex2, SizeMissleEff) 
// //         call angleEX(.ex2, a) 
// //         set.aoe = aoe 
// //         set.dmg = dmg 
// //         set.eff = eff 
// //         set.DAMAGE_TYPE = dmgtype 
// //         set.ATK_TYPE = atktype 
// //         set.time = time 
// //         set.speed = speed 
// //         set.is_touch = false 
// //         set.is_touch2 = false                                                                                                                                                                                                                                                   
// //         set.i = i 
// //         call addRT(this, P32, true, function thistype.VolleyTouchUpdate) 
// //         return false 
// //     endmethod 
// // endstruct


// struct Lightning_Link_DPS extends SKILL 
//     string nova_path = ""
//     string attach_path = ""
//     integer tick = 0
//     private static method spell_update takes nothing returns nothing 
//         local thistype this = runtime.get() 
//         local group g = null 
//         local unit e = null 
//         if Boo.isdead( .caster) or Boo.isdead( .target)   then // Unit chết thì ko làm gì
//             call DestroyLightningBJ( .light )
//             call DestroyLightningBJ( .light2 )

//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance 
//         endif
//         call MoveLightningEx(.light, true, .x, .y, Math.pz( .x, .y) + .z, .xt, .yt, Math.pz( .xt, .yt) + .z)
//         call MoveLightningEx(.light2, true, .x, .y, Math.pz( .x, .y) + .z, .xt, .yt, Math.pz( .xt, .yt) + .z)

//         if ModuloInteger(.time , .tick) == 0 then 
//             set .tick = .tick - R2I(.increment)
//             call Eff.nova(.nova_path, .x, .y)
//             set g = CreateGroup() 
//             call Group.enum(g, .x, .y, .aoe) 
//             loop 
//                 set e = FirstOfGroup(g) 
//                 exitwhen(e == null)
//                 if .FilterUnit( .caster, e)  then 
//                     call Eff.chest(.attach_path, e)
//                     call dmg.mag( .caster, e, .DMG_TYPE, .dmg)
//                 endif 
//                 call Group.remove(e, g) 
//             endloop 
//             call Group.release(g) 
//             set e = null 
//         endif

//         set.time = .time - 1 
//         if.time <= 0 then 
//             call DestroyLightningBJ( .light )
//             call DestroyLightningBJ( .light2 )

//             call runtime.end() // End the timer                                                                                                                                                                                                       
//             call.destroy() // Destroy the instance                                                                   
//         endif 
//     endmethod 
//     method spell_now takes nothing returns boolean 
//         //set light.caster = caster 
//         //set light.target = target 
//         //set light.light_name = CLPB 
//         //set light.light_name2 = CLSB 
//         //set light.z = 120
//         //set light.tick = 16
//         //set light.time = 32*3
        
//         //Chain Lighning Primary: CLPB
//         //Chain Lighning Secondary: CLSB
//         //Fork lightning: FORK
//         //Finger Of Death: AFOD
        
//         set .x = GetUnitX(.caster)
//         set .y = GetUnitY(.caster)
//         set .xt = GetUnitX(.target)
//         set .yt = GetUnitY(.target)
//         set .light = AddLightningEx(.light_name, true, .x, .y, Math.pz( .x, .y) + .z, .xt, .yt, Math.pz( .xt, .yt) + .z)
//         set .light2 = AddLightningEx(.light_name2, true, .x, .y, Math.pz( .x, .y) + .z, .xt, .yt, Math.pz( .xt, .yt) + .z)
//         // call SetLightningColorBJ( GetLastCreatedLightningBJ(), 1.00, 1.00, 1.00, 1.00 )
//         call runtime.new(this, P32, true, function thistype.spell_update) 
//         return false 
//     endmethod 
// endstruct


struct Es //Escape
    static key Dash
    static key AirBone 
    static key Knockback 
    static key Jumped 
    static key status 
    static key key_id 
    static hashtable ht = InitHashtable()
    static method change_status takes unit u, integer status_id , integer key_id returns boolean
        if status_id ==.Jumped then 
            call SaveInteger(.ht, GetHandleId(u), .status, status_id) 
            call SaveInteger(.ht, GetHandleId(u), .key_id, key_id)
            return true
        endif
        return false
    endmethod
    static method reset takes unit u returns nothing
        call SaveInteger(.ht, GetHandleId(u), .status, 0) 
        call SaveInteger(.ht, GetHandleId(u), .key_id, 0)
    endmethod
    static method is_stack takes unit u, integer status_id , integer key_id returns boolean 
        // call BJDebugMsg(I2S( LoadInteger(.ht, GetHandleId(u), .status)) + " - " + I2S(status_id) + " || " + I2S( LoadInteger(.ht, GetHandleId(u), .key_id)) + " - " + I2S(key_id) )
        if LoadInteger(.ht, GetHandleId(u), .status) == status_id and LoadInteger(.ht, GetHandleId(u), .key_id) == key_id then 
            return false
        endif
        return true
    endmethod
endstruct

struct JumpX 
    real x = 0.0
    real y = 0.0
    real x1 = 0.0
    real y1 = 0.0
    real a = 0.0
    real col = 0.0
    real g = 0.0
    real z0 = 0.0
    real zMax = 0.0
    real speed = 0.0
    boolean ALLOW_MOVE = false 
    boolean ALLOW_CONTROL = false 
    unit caster = null 
    real dfh = 0.0
    real time = 0
    real t = 0.0
    real tEnd = 0.0
    real dt = 0.0
    real sinZ = 0.0

    integer key_id = 0 
    integer status_id = 0

    static integer stack = - 8024
    private static method update takes nothing returns nothing 
        local thistype this = runtime.get() 
        local group g = null 
        local unit e = null 
        local real fh = 0.0
        local real z = 0.0
        if this.ALLOW_MOVE then 
            call SetUnitFacingTimed(.caster, quickcast.getUA(.caster), 0.03125 * 2)
            set this.a = GetUnitFacing(this.caster)
        endif
        set.x = Math.ppx(.x, .speed, this.a) 
        set.y = Math.ppy(.y, .speed, this.a) 
        set z = Math.pz(.x, .y) - this.z0
        set this.t = this.t + this.dt
        set fh = this.sinZ * this.t - this.g * this.t * this.t / 2. - z + this.dfh
        call BJDebugMsg("t: " + R2S(.t) + " || " + "tend: " + R2S(.tEnd))
        //
        if Es.is_stack(this.caster, .status_id, .key_id) then 
            call SetUnitPosition(this.caster, this.x, this.y)
            call SetUnitFlyHeight(this.caster, .dfh, 0)
            // if not this.ALLOW_MOVE then 
            //     call Unit.enabledmove(this.caster)
            // endif
            // if not this.ALLOW_CONTROL then 
            //     call Unit.enablecontrol(this.caster)
            // endif
            // call SaveBoolean(ht, GetHandleId(this.caster), StringHash("IsDrive"), false)
            call runtime.end() // End the timer                                                                                                                                                                                                        
            call.destroy() // Destroy the instance  
        else
            //Same id
        endif

        if this.t < this.tEnd and GetUnitState(this.caster, UNIT_STATE_LIFE) > 0   then 
            call SetUnitX(this.caster, .x)
            call SetUnitY(this.caster, .y)
            call SetUnitFlyHeight(this.caster, fh, 0)
        else
            call SetUnitPosition(this.caster, this.x, this.y)
            if not this.ALLOW_MOVE then 
                call Unit.enabledmove(this.caster)
            else
                call ResetUnitAnimation(this.caster)
            endif
            if not this.ALLOW_CONTROL then 
                call Unit.enablecontrol(this.caster)
            endif
            // call SaveBoolean(ht, GetHandleId(this.caster), StringHash("IsDrive"), false)
            call Es.reset(.caster)
            call runtime.end() // End the timer                                                                                                                                                                                                        
            call.destroy() // Destroy the instance   
        endif

    endmethod 
    method setxya takes real xt , real yt returns nothing
        // call BJDebugMsg(GetUnitName(.caster))
        set .x = GetUnitX(.caster)
        set .y = GetUnitY(.caster)
        set .x1 = xt 
        set .y1 = yt
        set .a = Math.ab(.x, .y, .x1, .y1)
        // call BJDebugMsg("x: " + R2S(.x) + " || " + "y: " + R2S(.y))
        // call BJDebugMsg("xt: " + R2S(.x1) + " || " + "yt: " + R2S(.x1))
        // call BJDebugMsg("a: " + R2S(.a) + " || " + "yt: " + R2S(.x1))

    endmethod
    method now takes nothing returns boolean 
        // set jump = JumpX.create()
        // set jump.caster = caster
        // call jump.setxya(xt,yt) 
        // set jump.time = 3.00
        // set jump.zMax = 300
        // set jump.key_id = key of skill
        // set jump.status_id = status of escape
        // set jump.ALLOW_MOVE = true
        // set jump.ALLOW_CONTROL = true
        // call jump.now()
        local real z1 = Math.pz(this.x1, this.y1)
        local boolean b = false
        // call IssueImmediateOrder(this.caster, "stop")
        set this.speed = (Math.db(.x, .y, .x1, .y1) / this.time) * P32
        // call BJDebugMsg("speed: " + R2S(this.speed))
        set this.dfh = GetUnitDefaultFlyHeight(this.caster)
        set this.z0 = Math.pz(.x, .y)
        set this.col = BlzGetUnitCollisionSize(this.caster)
        set this.g = this.col * 1
        set this.sinZ = SquareRoot(zMax * 2 * this.g)
        set this.tEnd = (this.sinZ + SquareRoot(this.sinZ * this.sinZ - 2 * this.g * (z1 - this.z0))) / this.g
        set this.dt = P32 * (this.tEnd - this.t) / this.time
        // call BJDebugMsg("t: " + R2S(.t) + " || " + "tend: " + R2S(.tEnd))

        set .status_id = Es.Jumped
        if not this.ALLOW_MOVE then 
            call Unit.disablemove(this.caster)
        endif
        if not this.ALLOW_CONTROL then 
            call Unit.disablecontrol(this.caster)
        endif
        if UnitAddAbility(.caster, 'Arav') and UnitRemoveAbility(.caster, 'Arav') then 
            if not Es.is_stack(.caster, .status_id, .key_id) then
                set .stack = .stack + 1
                set .key_id = .key_id + .stack
                set b = Es.change_status(.caster, .status_id, .key_id)
            else
                set b = Es.change_status(.caster, .status_id, .key_id)
            endif
        endif
        if b then 
            call runtime.new(this, P32, true, function thistype.update) 
        else
            call.destroy() // Destroy the instance   
        endif
        return false 
    endmethod 
endstruct

