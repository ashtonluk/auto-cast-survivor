
//About code : https://docs.google.com/document/d/1WXxXdxNFZzz-QFSk-mtlMsDn1jJUn9v5NOE83cVnAC8/edit?usp=sharing  
//Uses check example in 4-Event/10- Player - Chat.j 
//====Variables in struct  
//  static Randompool pool1  
//====Setting  
// set.pool1 = Randompool.create()  
// call.pool1.new_value(1, 50, 0, 0)  
// call.pool1.new_value(2, 30, 0, 5)  
// call.pool1.new_value(3, 20, 0, 2)  
//====Call when want random 
// set random_value = .pool1.random()  
//====Destroy => use one time 
// call .pool1.destroy()  

//Set size array 10 to higher if u have more value             
struct Randompool 
    integer array value[99] //Use for raw or number or id item                                 
    real array rate_default[99] //Constant rate default                                 
    real array rate[99] // Rate now of item                                 
    real array increase[99] //When drop call a time, rate = rate + increase                                 
    integer times //When the drop call a time, it increase 1                                  
    integer size = - 1 
    method add_rare takes Randompool rp returns nothing 
        call rp.new_value('I00F', 1, 0, 0)  //Amulet of Spell Shield
        call rp.new_value('I00E', 1, 0, 0)  //Ancient Janggo of Endurance
        call rp.new_value('I00K', 1, 0, 0)  //Legion Doom-Horn
        call rp.new_value('I00J', 1, 0, 0)  //Scourge Bone Chimes
        call rp.new_value('I00G', 1, 0, 0)  //Staff of Teleportation
        call rp.new_value('I00H', 1, 0, 0)  //The Lion Horn of Stormwind
        call rp.new_value('I00I', 1, 0, 0)  //Warsong Battle Drums
    endmethod
    method is_rare takes integer id returns boolean 
        local Randompool pool_item_rare
        local integer n = 0
        local boolean b = false
        set pool_item_rare = Randompool.create()
        call .add_rare(pool_item_rare)
        loop
            exitwhen n > pool_item_rare.size
            if id == pool_item_rare.value[n] then 
                set b = true 
                exitwhen true 
            endif
            set n = n + 1
        endloop
        call pool_item_rare.destroy()
        return b
    endmethod
    method rare_drop takes nothing returns integer 
        local Randompool pool_item_rare
        local integer v = 0
        set pool_item_rare = Randompool.create()
        call pool_item_rare.add_rare(pool_item_rare)
        set v = pool_item_rare.random()
        call pool_item_rare.destroy()
        return v
    endmethod
    method new_value takes integer value, integer rate_default, integer rate, integer increase returns nothing 
        set.size =.size + 1 
        set.value[.size] = value 
        set.rate_default[.size] = rate_default 
        set.rate[.size] = rate + rate_default 
        set.increase[.size] = increase 
    endmethod 
    method update_rate takes nothing returns nothing 
        set bj_int = 0 
        loop 
            exitwhen bj_int >.size 
            set.rate[bj_int] =.rate[bj_int] +.increase[bj_int] 
            set bj_int = bj_int + 1 
        endloop 
    endmethod 
    method total takes nothing returns real 
        local real total = 0 
        set bj_int = 0 
        loop 
            exitwhen bj_int >.size 
            set total = total +.rate[bj_int] 
            set bj_int = bj_int + 1 
        endloop 
        return total 
    endmethod 
    method random takes nothing returns integer 
        local integer v = - 1 
        local real total = 0 
        local real random_val = 0 
        local real accumulated = 0 
        set total =.total() 
  
        set random_val = GetRandomReal(0, total) 
        if ENV_DEV then 
            call BJDebugMsg("random_val: " + R2S(random_val) + " / " + "Total: " + R2S(total)) 
            call BJDebugMsg("Number of Value Random: " + I2S(.size + 1)) 
        endif 
        set bj_int = 0 
        loop 
            exitwhen bj_int >.size 
            set accumulated = accumulated +.rate[bj_int] 
            if random_val <= accumulated then 
                set v =.value[bj_int] 
                call.action(bj_int) // Make some stupid code                
                call.update_rate() 
                set.times =.times + 1 
                if (ModuloInteger(.times, 25) == 0 and .times != 0 ) then 
                    set v = .rare_drop()
                    // set bj_lastCreatedItem = CreateItem(v, 0, 0)
                    // call BJDebugMsg("times:" + I2S(.times) + " || index: " + I2S(-5) + " - " + GetItemName(bj_lastCreatedItem))
                    // call RemoveItem(bj_lastCreatedItem)
                    // call BJDebugMsg(I2S(v))
                endif
                exitwhen true 
            endif 
            set bj_int = bj_int + 1 
        endloop 
        if ENV_DEV then 
            call BJDebugMsg(".accumulated: " + R2S(accumulated) + " [] Values: " + R2S(v) + "[] Times: " + R2S(times)) 
        endif 

        return v 
    endmethod 
    method action takes integer index returns nothing 
        //Code for example                  
        if (ModuloInteger(.times, 25) == 0 and .times != 0 )  then 
            set bj_lastCreatedItem = CreateItem(.value[index], 0, 0)
            call BJDebugMsg("25 Times! Critical drop rare item ! [[" + GetItemName(bj_lastCreatedItem) + "]]") 
            // call BJDebugMsg("times:" + I2S(.times) + " || index: " + I2S(index) + " - " + GetItemName(bj_lastCreatedItem))
            call RemoveItem(bj_lastCreatedItem)
            //Reset when the value [9] drop                 
            set bj_int = 0 
            loop 
                exitwhen bj_int >.size 
                set.rate[bj_int] =.rate_default[bj_int] 
                set bj_int = bj_int + 1 
            endloop 
        endif 
        if .is_rare(.value[index]) and not (ModuloInteger(.times, 25) == 0 and .times != 0 )then 
            // call BJDebugMsg("Critical DROP! reset rate to default") 
            // call BJDebugMsg("Critical drop rare item !") 
            set bj_lastCreatedItem = CreateItem(.value[index], 0, 0)

            call BJDebugMsg("Critical drop rare item ! [[" + GetItemName(bj_lastCreatedItem) + "]]") 

            // call BJDebugMsg("times:" + I2S(.times) + " || index: " + I2S(index) + " - " + GetItemName(bj_lastCreatedItem))
            call RemoveItem(bj_lastCreatedItem)
        endif 
    endmethod 
endstruct 
