
//Constant : A constant value does not change, and you use it to set fixed parameters in the game.         
globals 
    //We will define bj_ as a type of variable that is used and processed at a specific moment,         
    // is always redefined when it starts being used, and is assigned a null value when finished.         
    //Number          
    integer bj_int = 0 // Typically used for a single loop or assigning a random value.         
    real bj_real = 0.00 //Typically used for a single loop or assigning a random value.         
    //Objective          
    item bj_item = null // instead of bj_lastCreatedItem           
    unit bj_unit = null // instead of bj_lastCreatedUnit           
    effect bj_eff = null // instead of bj_lastCreatedEffect          
    group bj_group = null // instead of bj_lastCreatedEffect          
    location bj_loc = Location(0, 0) //Warning: Don't set bj_loc = Location() use MoveLocation instead  
    rect bj_rect = Rect(0, 0, 0, 0) //Warning: Don't set bj_loc = Location() use MoveLocation instead  
    texttag bj_texttag = null 
    timer bj_timer = null 
    //Storage          
    hashtable ht = InitHashtable() // This is the hashtable you will use in most situations of the game.            
    hashtable stats = InitHashtable() // For damage system    
    //Timer          
    constant real TIME_SETUP_EVENT = 0.2 // The time to start setting up events for the game.      
    constant real TIME_INTERVAL = 1.00 // You can use this varible for setting timer checking in game   (check file 6-Timers/1-Interval.j)  
    constant real P32 = 0.03125 // Explore this number; it truly has significance.         
    constant real P64 = 0.03125 * 2 // Explore this number; it truly has significance.       
    //Environment Dev      
    constant boolean ENV_DEV = true // Are u on a testing mode ?        
    constant real MAX_RANGE = 10.
    constant integer DUMMY_ITEM_ID = 'wolg'
    item ItemChecker = null
    rect Find = null
    item array Hid
    integer HidMax = 0
    //Utils          
    constant string SYSTEM_CHAT = "[SYSTEM]: |cffffcc00" 

    //Constant text       
    //===Example: set str = str + N       
    constant string N = "|n" 
    //===Example: set str = color + str + R       
    constant string R = "|r" 
    //===Example: set str = color + str + RN       
    constant string RN = "|r|n" 
    //Setting Game        
    constant real ARMOR_CONSTANT = 0.03 // Assign it with the value you set in the gameplay constant.    
    constant real STR_HP = 25 // Assign it with the value you set in the gameplay constant.    
    constant real STR_REGEN = 0.05 // Assign it with the value you set in the gameplay constant.    
    constant real AGI_AR = 0.3 // Assign it with the value you set in the gameplay constant.    
    constant real AGI_MS = 1 // Assign it with the value you set in the gameplay constant.    
    constant real INT_MP = 15 // Assign it with the value you set in the gameplay constant.    
    constant real INT_REGEN = 0.05 // Assign it with the value you set in the gameplay constant.   
    constant integer MAX_PLAYER = 6 
    constant integer MAX_SIZE_DIALOG_BUTTON = 24 
    constant boolean CREEP_SLEEP = false 
    constant boolean LOCK_RESOURCE_TRADING = true 
    constant boolean SHARED_ADVANCED_CONTROL = false 
    constant real GAME_PRELOAD_TIME = 0.01 
    constant real GAME_STATUS_TIME = 1.00 
    constant real GAME_SETTING_TIME = 3.00 
    constant real GAME_START_TIME = 5.00 
    constant string green = "|cff0afd2b" 
    constant string purple = "|cffb308b3" 
    constant string blue = "|cff5264ff" 
    constant string yellow = "|cffFFCC00" 
    constant string cyan = "|cff00d9ff" 
endglobals 

