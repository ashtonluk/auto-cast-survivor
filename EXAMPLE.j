// COUNTDOWN TIMER EXAMPLE  If not use then delete this                                                                                                                            
struct COUNTDOWN_TIMER
    static CountdownTimer ev 
    static method start_timer takes real time returns nothing 
        set COUNTDOWN_TIMER.ev = CountdownTimer.create() 
        call COUNTDOWN_TIMER.ev.newdialog("Wave is Coming", time, true, function thistype.tensec) 
        call COUNTDOWN_TIMER.ev.titlecolor(255, 0, 0, 255) 
        call COUNTDOWN_TIMER.ev.timercolor(255, 0, 0, 255) 
    endmethod 
    private static method tensec takes nothing returns nothing 
        call COUNTDOWN_TIMER.ev.destroytd() 
        call COUNTDOWN_TIMER.ev.destroy() 
    endmethod 
endstruct 


struct EXAMPLE_LEADERBOARD 
    static Leaderboard LB 
    static integer array value 
    static method update takes integer id, integer value returns nothing 
        call.LB.setvalue(Player(id), value) 
    endmethod 
    static method start takes nothing returns nothing 
        set.LB = Leaderboard.create() 
        call.LB.new("Ogre Zombie Day v0.1") 
        set bj_int = 0 
        loop 
            exitwhen bj_int > MAX_PLAYER - 1 
            if not PLAYER.IsDisconect[bj_int] then 
                call.LB.additem(Player(bj_int), GetPlayerName(Player(bj_int)), 0) 
                call.LB.style(Player(bj_int), true, true, false) 
            endif 
            set bj_int = bj_int + 1 
        endloop 
        call.LB.additem(Player(10), "Day:", 0) 
        call.LB.coloritem(Player(10), 255, 255, 255, 0) 
        call.LB.colorvalue(Player(10), 255, 255, 255, 0) 
        call.LB.style(Player(10), true, true, false) 

        call.LB.additem(Player(11), "Current unit count:", 0) 
        call.LB.coloritem(Player(11), 255, 255, 255, 0) 
        call.LB.colorvalue(Player(11), 255, 255, 255, 0) 
        call.LB.style(Player(11), true, true, false) 

        call.LB.setforce(GetPlayersAll(), true) 
        call.LB.display(true) 
    endmethod 
endstruct