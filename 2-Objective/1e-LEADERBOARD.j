//I don't use leaderboard and not have experience for do it...         

// call CreateLeaderboardBJ( GetPlayersAll(), "TRIGSTR_040" )             
// call DestroyLeaderboardBJ( GetLastCreatedLeaderboard() )             
// call LeaderboardSortItemsBJ( GetLastCreatedLeaderboard(), bj_SORTTYPE_SORTBYVALUE, false )             
// call LeaderboardDisplayBJ( false, GetLastCreatedLeaderboard() )             
// call LeaderboardSetLabelBJ( GetLastCreatedLeaderboard(), "TRIGSTR_042" )             
// call LeaderboardSetLabelColorBJ( GetLastCreatedLeaderboard(), 100, 80, 20, 0 )             
// call LeaderboardSetValueColorBJ( GetLastCreatedLeaderboard(), 100, 80, 20, 0 )             
// call LeaderboardSetStyleBJ( GetLastCreatedLeaderboard(), true, true, true, true )             

// call LeaderboardAddItemBJ(Player(0), GetLastCreatedLeaderboard(), "TRIGSTR_044", 0)     
// call LeaderboardRemovePlayerItemBJ(Player(0), GetLastCreatedLeaderboard())     

// call LeaderboardSetPlayerItemLabelBJ( Player(0), GetLastCreatedLeaderboard(), "TRIGSTR_046" )             
// call LeaderboardSetPlayerItemLabelColorBJ( Player(0), GetLastCreatedLeaderboard(), 100, 80, 20, 0 )             
// call LeaderboardSetPlayerItemValueBJ( Player(0), GetLastCreatedLeaderboard(), 0 )             
// call LeaderboardSetPlayerItemValueColorBJ( Player(0), GetLastCreatedLeaderboard(), 100, 80, 20, 0 )             

// call LeaderboardSetPlayerItemStyleBJ( Player(0), GetLastCreatedLeaderboard(), true, true, true )           

//Uses : see code in file EXAMPLE.j         
struct Leaderboard 
    leaderboard lb 
    method new takes string title returns nothing 
        set.lb = CreateLeaderboard() 
        call LeaderboardSetLabel(.lb, title) 
    endmethod 
    method setforce takes force f, boolean display returns nothing 
        call ForceSetLeaderboardBJ(.lb, f) 
        call LeaderboardDisplay(.lb, display) 
    endmethod 
    method display takes boolean status returns nothing 
        call LeaderboardDisplay(.lb, status) 
    endmethod 
    method displayx takes boolean status, player p returns nothing 
        if(GetLocalPlayer() == p) then 
            // Use only local code (no net traffic) within this block to avoid desyncs.                              
            call LeaderboardDisplay(.lb, status) 
        endif 
    endmethod 
    method setlabel takes string label returns nothing 
        local integer size = LeaderboardGetItemCount(lb) 
        call LeaderboardSetLabel(.lb, label) 
        if(LeaderboardGetLabelText(.lb) == "") then 
            set size = size - 1 
        endif 
        call LeaderboardSetSizeByItemCount(lb, size) 
    endmethod 
    method additem takes player p, string label, integer value returns nothing 
        if(LeaderboardHasPlayerItem(.lb, p)) then 
            call LeaderboardRemovePlayerItem(.lb, p) 
        endif 
        call LeaderboardAddItem(.lb, label, value, p) 
        call LeaderboardResizeBJ(.lb) 
    endmethod 
    method removeitem takes player p returns nothing 
        call LeaderboardRemovePlayerItem(.lb, p) 
        call LeaderboardResizeBJ(.lb) 
    endmethod 
    method style takes player p, boolean showLabel, boolean showValue, boolean showIcon returns nothing 
        call LeaderboardSetItemStyle(lb, LeaderboardGetPlayerIndex(.lb, p), showLabel, showValue, showIcon) 
    endmethod 
    method setlabelp takes player p, string str returns nothing 
        call LeaderboardSetPlayerItemLabelBJ(p,.lb, str) 
    endmethod 
    method setvalue takes player p, integer value returns nothing 
        call LeaderboardSetItemValue(.lb, LeaderboardGetPlayerIndex(.lb, p), value) 
    endmethod 
    method coloritem takes player p, integer r, integer g, integer b, integer a returns nothing 
        call LeaderboardSetPlayerItemLabelColorBJ(p,.lb, r, g, b, a) 
    endmethod 
    method colorvalue takes player p, integer r, integer g, integer b, integer a returns nothing 
        call LeaderboardSetPlayerItemValueColorBJ(p,.lb, r, g, b, a) 
    endmethod 
    method sort takes leaderboard lb, integer sortType, boolean ascending returns nothing 
        if(sortType == bj_SORTTYPE_SORTBYVALUE) then 
            call LeaderboardSortItemsByValue(lb, ascending) 
        elseif(sortType == bj_SORTTYPE_SORTBYPLAYER) then 
            call LeaderboardSortItemsByPlayer(lb, ascending) 
        elseif(sortType == bj_SORTTYPE_SORTBYLABEL) then 
            call LeaderboardSortItemsByLabel(lb, ascending) 
        else 
            // Unrecognized sort type - ignore the request.   
        endif 
    endmethod 
    method destroylb takes boolean status returns nothing 
        call DestroyLeaderboard(.lb) 
    endmethod 
endstruct