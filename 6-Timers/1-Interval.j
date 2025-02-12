struct Interval 
    static integer times = 0 
    static method tick takes nothing returns nothing 
        set.times =.times + 1 
        //Comment if not use   
        // call MULTILBOARD_EXAMPLE.update() 

        // if ModuloInteger(.times, 5) == 0 then 
        //     call ROADLINE_EXAMPLE.summon() 
        // endif 
        // call ROADLINE_EXAMPLE.order()


      
    endmethod 
    static method start takes nothing returns nothing 
        call TimerStart(CreateTimer(), TIME_INTERVAL, true, function thistype.tick) 
    endmethod 
endstruct
struct IntervalP32 
    static real time = 0                           
    static method tick takes nothing returns nothing 
        call EXAMPLE_LEADERBOARD.LB.setvalue(Player(11), PLAYER.food(10)) 
        call EXAMPLE_LEADERBOARD.LB.setvalue(Player(10), WAVE.lv) 
        // call WAVE.spawnx()   
        call BJDebugMsg(R2S(.time))
        if PLAYER.food(10) == 0 and .time == 0 then 
            set .time = 3.20 * 15
            call WAVE.executed()
            
        endif   
        if .time > 0 then 
            set .time = .time -1
        endif        
    endmethod 
    static method start takes nothing returns nothing 
        call TimerStart(CreateTimer(), 0.3125, true, function thistype.tick) 
    endmethod 
endstruct