struct quickcast // by dhguardianes ver: 1.20 2024-09-09 22:17:41
    static real array QcastX
    static real array QcastY
    static real array QcastCX
    static real array QcastCY
    static boolean array QcastZero
    static method getUA takes unit u returns real//get unit to xy
        local real x = GetUnitX(u)
        local real y = GetUnitY(u)
        local integer i = Num.uid(u)
        if (QcastZero[i]) or (Math.db(x, y, QcastX[i], QcastY[i]) < 1.00) then
            return GetUnitFacing(u)
        endif
        return Math.ab(x, y, QcastX[i], QcastY[i])
    endmethod
    static method getCA takes integer pid returns real
        return Math.ab(QcastCX[pid], QcastCY[pid], QcastX[pid], QcastY[pid])
    endmethod
    static method getCAX takes integer pid returns real
        return QcastX[pid]
    endmethod
    static method getCAY takes integer pid returns real
        return QcastY[pid]
    endmethod
    private static method f takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer i = Num.pid(p)
        local real x = BlzGetTriggerPlayerMouseX()
        local real y = BlzGetTriggerPlayerMouseY()
        local boolean b = false
        set QcastX[i] = x
        set QcastY[i] = y
        set p = null
    endmethod
    private static method SyncCamDataRead takes nothing returns nothing
        local integer id = GetPlayerId(GetTriggerPlayer())
        if BlzGetTriggerSyncPrefix() == "SyncCamX" then
            set QcastCX[id] = S2R(BlzGetTriggerSyncData())
        else
            set QcastCY[id] = S2R(BlzGetTriggerSyncData())
        endif
    endmethod
    private static method SyncCamDataSend takes nothing returns nothing
        call BlzSendSyncData("SyncCamX", R2S(GetCameraTargetPositionX()))
        call BlzSendSyncData("SyncCamY", R2S(GetCameraTargetPositionY()))
    endmethod
    private static method onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger trig = CreateTrigger()
        local integer i = 0
        loop
            if PLAYER.IsPlayerOnline(Player(i)) then
                call TriggerRegisterPlayerMouseEventBJ( t, Player(i), bj_MOUSEEVENTTYPE_MOVE )
                call BlzTriggerRegisterPlayerSyncEvent(trig, Player(i), "SyncCamX", false)
                call BlzTriggerRegisterPlayerSyncEvent(trig, Player(i), "SyncCamY", false)
                set QcastX[i] = 0
                set QcastY[i] = 0
                set QcastCX[i] = 0
                set QcastCY[i] = 0
                set QcastZero[i] = false
            endif
            set i = i + 1
            exitwhen i == bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction(t, function thistype.f)
        call TriggerAddAction(trig, function thistype.SyncCamDataRead)
        call TimerStart(CreateTimer(), 1, true, function thistype.SyncCamDataSend)
        set t = null
    endmethod
endstruct