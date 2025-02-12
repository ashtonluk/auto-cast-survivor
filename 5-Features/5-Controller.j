

// struct GAME_CONTROLLER 
//     static unit looter = null
//     static boolean b = false
//     static method is_driving takes unit u returns boolean 
//         return LoadBoolean(ht, GetHandleId(u), StringHash("IsDrive"))
//     endmethod
//     static method attack takes nothing returns nothing 
//         local player p = GetTriggerPlayer() 
//         local integer pid = Num.pid(p) 
//         call Controller.attack(pid) 
//         // call BJDebugMsg("1")      

//         set p = null 
//     endmethod 

//     static method lootone takes nothing returns nothing 
//         local item i = GetEnumItem()
//         if not .b and Boo.islive(.looter)and GetWidgetLife(i) > 0.405  and UnitAddItem(.looter, i) then
//             set .b = true
//         endif
//         set i = null
//     endmethod
//     static method space takes nothing returns nothing 
//         local player p = GetTriggerPlayer() 
//         local integer pid = Num.pid(p) 
//         local rect r = null 
//         set .looter = GAME.Survivor[pid]
//         set r = Rect(Unit.x(.looter) - 128, Unit.y(.looter) - 128, Unit.x(.looter) + 128, Unit.y(.looter) + 128 )
//         set .b = false
//         call EnumItemsInRect(r, null, function thistype.lootone)
//         set .looter = null
//         call RemoveRect(r)
//         set p = null 
//     endmethod 

//     static method start takes nothing returns nothing 
//         call REGISTER_EVENT.regKey(OSKEY_A, function thistype.attack) //hot key                                                                                                                                                                                                                
//         call REGISTER_EVENT.regKey(OSKEY_SPACE, function thistype.space) //hot key                                                                                                        
//     endmethod 
// endstruct 


