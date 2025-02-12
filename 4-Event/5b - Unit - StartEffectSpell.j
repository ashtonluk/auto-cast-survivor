struct EV_START_SPELL_EFFECT 
    static real max_reduce_cd = 0.45
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
        local real timed = BlzGetAbilityCooldown(abicode, GetUnitAbilityLevel(caster, abicode) - 1)
        local real max_CD = 0.00 // Chhir số giảm hồi chiêu
        if max_CD > .max_reduce_cd then
            set max_CD = .max_reduce_cd
        endif


        if abicode == 'A000' then 
            if(timed > 1.00) then // các đòn đánh có ít nhất 1s cooldown
                call BlzSetAbilityRealLevelField(GetSpellAbility() , ABILITY_RLF_COOLDOWN, GetUnitAbilityLevel(caster, abicode) - 1, (timed * (1.00 - max_CD)     ))
            endif
            call .attack(caster, Hero.str(caster) + Hero.agi(caster), Math.ppx(xc, 150, ac), Math.ppy(yc, 150, ac), 165, abicode )
        endif
    
        set target = null 
        set caster = null 
        set it = null 
        return false 
    endmethod 
    static method attack takes unit caster , real dmg , real x , real y , real aoe , integer abicode returns nothing
        local Attack_Controller atk 
        if abicode == 'A000' then 
            set atk = Attack_Controller.create()
            set atk.time = 20
            set atk.caster= caster 
            set atk.DMG_TYPE= DAMAGE_TYPE_NORMAL
            set atk.ATK_TYPE = ATTACK_TYPE_HERO
            set atk.dmg = dmg 
            set ak.aoe = aoe 
            
            call atk.spell_now()
        endif
        local unit e = null 
        local group g = CreateGroup() 
        call Eff.new( "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl", x, y, Math.pz(x, y))
        call Eff.size(bj_eff, 0.45)
        call DestroyEffect(bj_eff)
        call Group.enum(g, x, y, aoe) 
        loop 
            set e = FirstOfGroup(g) 
            exitwhen e == null 
            if not Boo.isdead(e)  and IsUnitEnemy(caster, GetOwningPlayer(e)) and BlzIsUnitInvulnerable(e) == false then 
                call UnitDamageTarget(caster, e, dmg, true, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, null) 
            endif 
            call Group.remove(e, g) 
        endloop 
        call Group.release(g) 
        set e = null 
    endmethod
    static method f_SetupEvent takes nothing returns nothing 
        local trigger t = CreateTrigger() 
        call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT) 
        call TriggerAddAction(t, function thistype.f_Checking) 
    endmethod 
endstruct 

