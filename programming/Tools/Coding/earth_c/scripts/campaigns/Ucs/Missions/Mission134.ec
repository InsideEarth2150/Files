mission "translateMission134"
{//Projekt Teleport - last stage
    consts
    {
        testTeleport = 0;
    }
    
    
    player p_Player;
    player p_Security;
    
    unitex p_Tester1;
    
    int n_TeleportInX;
    int n_TeleportInY;
    int n_TeleportOutX;
    int n_TeleportOutY;
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state TestTeleport;
    state TeleportBriefing;
    state TestTeleport2;
    state LastBriefing;
    state Final;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(testTeleport,"translateGoal134");
        EnableGoal(testTeleport,true);               
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(2); 
        tmpPlayer.EnableStatistics(false);
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        p_Security = GetPlayer(4);
        //----------- AI ---------------------
        p_Security.EnableStatistics(false);
        
        p_Player.SetNeutral(p_Security);
        p_Security.SetNeutral(p_Player);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Security.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        p_Player.SetMoney(5000);
        //----------- Researches -------------
        //----------- Buildings --------------
        if(p_Player.GetScriptData(5)!=12)
            p_Player.EnableBuilding("UCSBTE",false);
        //----------- Units ------------------
        p_Tester1 = GetUnit(GetPointX(0),GetPointY(0),0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,6000);
        //----------- Variables --------------
        n_TeleportInX = GetPointX(1);
        n_TeleportInY = GetPointY(1);
        n_TeleportOutX = GetPointX(2);
        n_TeleportOutY = GetPointY(2);
        bCheckEndMission = false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),8,0,20,0);
        SelectUnit(p_Tester1,false);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        Rain(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),40,400,2500,800,5); 
        AddBriefing("translateBriefing134a");
        return TestTeleport,20;
    }
    
    //-----------------------------------------------------------------------------------------
    state TestTeleport
    {
        if(p_Tester1.DistanceTo(n_TeleportOutX,n_TeleportOutY)<4)
        {
            p_Player.DelayedLookAt(n_TeleportOutX,n_TeleportOutY,8,0,20,0,20,1);  
            return TeleportBriefing,100; 
        }
        return TestTeleport,20;
    }
    //-----------------------------------------------------------------------------------------
    state TeleportBriefing
    {
        AddBriefing("translateBriefing134b");
        return TestTeleport2,50;
    }
    
    //-----------------------------------------------------------------------------------------
    state TestTeleport2
    {
        if(p_Tester1.DistanceTo(n_TeleportInX,n_TeleportInY)<4)
        {
            p_Player.DelayedLookAt(n_TeleportInX,n_TeleportInY,8,0,20,0,20,1);  
            return LastBriefing,80;
        }
        return TestTeleport2,20;
    }
    //-----------------------------------------------------------------------------------------
    state LastBriefing
    {
        SetGoalState(testTeleport,goalAchieved);
        AddBriefing("translateAccomplished134");
        p_Player.SetScriptData(5,12);//to oznacza ze wynaleziono teleport
        EnableEndMissionButton(true);
        return Final,500;
    }
    //-----------------------------------------------------------------------------------------
    state Final
    {
        return Final,500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            AddBriefing("translateFailed134");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit u_Unit)
    {
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit u_Unit)
    { 
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_Player.SetEnemy(p_Security);
        p_Security.SetEnemy(p_Player);
    }
}
