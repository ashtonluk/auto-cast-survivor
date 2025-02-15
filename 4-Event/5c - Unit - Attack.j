struct Unit_Attack 
    static method attack takes unit caster , integer abicode , integer pid returns nothing
        local Attack_Controller atk 
        local Bow_Controller bow 
        local Staff_Fire_Controller sf 
        local Wand_Lightning_Controller wl
        local CrossBow_Controller cb
        local Axe_Controller axe
        local Claw_Controller cl
        local Rod_Controller rod
        local Dagger_Controller dg
        local Shield_Controller sc
        
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
        if abicode == 'A006' then //Cross Bow attack
            if Boo.hasitem(caster, 'I003') then //Bow item 
                set cb = CrossBow_Controller.create()
                set cb.time_bow = 30
                set cb.caster = caster 
                set cb.DMG_TYPE = DAMAGE_TYPE_NORMAL
                set cb.ATK_TYPE = ATTACK_TYPE_HERO
                set cb.dmg = (Hero.str(caster) * 1 ) + (Hero.agi(caster) * 1) + (Hero.int(caster) * 0.15 )
                set cb.speed = 20
                set cb.aoe = 65 
                set cb.z = 100 
                set cb.missle_path = "Abilities\\Weapons\\Arrow\\ArrowMissile.mdl" 
                set cb.missle_size = 1.5
                set cb.anim = "attack"
                set cb.attach = "chest"
                set cb.attach_path = "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl"
                call cb.spell_now()
            else 
                set GAME.Survivor_Weapon[pid] = 'A000'
                call .attack(caster, GAME.Survivor_Weapon[pid] , pid)
            endif
           
        endif
        if abicode == 'A007' then //Axe
            if Boo.hasitem(caster, 'I004') then //Axe item 
                set axe = Axe_Controller.create()
                set axe.caster = caster 
                set axe.time = 20 
                set axe.DMG_TYPE = DAMAGE_TYPE_NORMAL
                set axe.ATK_TYPE = ATTACK_TYPE_HERO
                set axe.dmg = (Hero.str(caster) * 1.85 ) + (Hero.agi(caster) * 0.55) + (Hero.int(caster) * 0.35 )
                set axe.aoe = 100 
                set axe.z = 100 
                set axe.missle_path = "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl"
                set axe.missle_size = 2.5
                set axe.anim = "attack"
                set axe.attach = "chest"
                set axe.attach_path = "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl"
                call axe.spell_now()
            else 
                set GAME.Survivor_Weapon[pid] = 'A000'
                call .attack(caster, GAME.Survivor_Weapon[pid] , pid)
            endif
           
        endif
        if abicode == 'A008' then //Claw
            if Boo.hasitem(caster, 'I005') then //Claw item 
                set cl = Claw_Controller.create()
                set cl.caster = caster 
                set cl.time = 20 
                set cl.DMG_TYPE = DAMAGE_TYPE_NORMAL
                set cl.ATK_TYPE = ATTACK_TYPE_HERO
                set cl.dmg = (Hero.str(caster) * 0.45 ) + (Hero.agi(caster) * 0.9) + (Hero.int(caster) * 0.25 )
                set cl.aoe = 120 
                set cl.z = 100 
                set cl.missle_path = ""
                set cl.missle_size = 1
                set cl.anim = "attack"
                set cl.attach = "chest"
                set cl.attach_path = "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl"
                call cl.spell_now()
            else 
                set GAME.Survivor_Weapon[pid] = 'A000'
                call .attack(caster, GAME.Survivor_Weapon[pid] , pid)
            endif
           
        endif
        if abicode == 'A009' then //Rod
            if Boo.hasitem(caster, 'I006') then //Rod item 
                set rod = Rod_Controller.create()
                set rod.caster = caster 
                set rod.time = 32
                set rod.dmg = (Hero.str(caster) * 0.25 ) + (Hero.agi(caster) * 0.25) + (Hero.int(caster) * 1.00 )
                set rod.anim = "spell"
                call rod.spell_now()
                // call BJDebugMsg("lightning")
            else 
                set GAME.Survivor_Weapon[pid] = 'A000'
                call .attack(caster, GAME.Survivor_Weapon[pid] , pid)
            endif
        endif
        if abicode == 'A00C' then //Dagger
            if Boo.hasitem(caster, 'I007') then //Dagger item 
                set dg = Dagger_Controller.create()
                set dg.caster = caster 
                set dg.time = 20
                set dg.dmg = (Hero.str(caster) * 0.85 ) + (Hero.agi(caster) * 1.05) + (Hero.int(caster) * 0.85 )
                set dg.anim = "spell"
                call dg.spell_now()
                // call BJDebugMsg("lightning")
            else 
                set GAME.Survivor_Weapon[pid] = 'A000'
                call .attack(caster, GAME.Survivor_Weapon[pid] , pid)
            endif
        endif
        if abicode == 'A00D' then //Shield
            if Boo.hasitem(caster, 'I008') then //Shield item 
                set sc = Shield_Controller.create()
                set sc.time = 20
                set sc.caster = caster 
                set sc.DMG_TYPE = DAMAGE_TYPE_NORMAL
                set sc.ATK_TYPE = ATTACK_TYPE_HERO
                set sc.dmg = (Hero.str(caster) * 0.165 ) + (Hero.agi(caster) * 0.55) + (Hero.int(caster) * 0.55 )
                set sc.speed = 150
                set sc.aoe = 165
                set sc.missle_path = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireMissile.mdl" 
                set sc.missle_size = 0.65
                set sc.anim = "attack"
                set sc.attach = "chest"
                set sc.attach_path = "Objects\\Spawnmodels\\Critters\\Albatross\\CritterBloodAlbatross.mdl"
                call sc.spell_now()
            else 
                set GAME.Survivor_Weapon[pid] = 'A000'
                call .attack(caster, GAME.Survivor_Weapon[pid] , pid)
            endif
       
        endif
    endmethod
endstruct