mission "translateMission113"
{//Projekt LASER - siberia
    consts
    {
        testTunnelEntrance = 0;
        testTeleport = 1;
    }
    
    
    player p_Player;
    player p_Neutral;
    unitex p_Tester1;
    unitex p_Tester2;
    
    int n_TeleportOutX;
    int n_TeleportOutY;
    int bCheckEndMission;
    int bShowBriefing;
    
    state Initialize;
    state ShowBriefing;
    state TestEntrance1;
    state TestEntrance2;
    state TestEntranceBriefing;
    state TestTeleportStart;
    state TestTeleport;
    state BlowUpTeleport;
    state LastBriefing;
    state Final;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(testTunnelEntrance,"translateGoal113a");
        RegisterGoal(testTeleport,"translateGoal113b");
        EnableGoal(testTunnelEntrance,true);               
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        tmpPlayer = GetPlayer(2); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        p_Neutral = GetPlayer(6);
        //----------- AI ---------------------
        p_Neutral.EnableStatistics(false);
        p_Player.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Player);
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        p_Player.SetMoney(0);
        //----------- Researches -------------
        //----------- Buildings --------------
        //----------- Units ------------------
        p_Tester1 = GetUnit(GetPointX(0),GetPointY(0),0);
        p_Tester2 = GetUnit(GetPointX(1),GetPointY(1),0);
        CallCamera();
        SelectUnit(p_Tester1,false);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,6000);
        //----------- Variables --------------
        n_TeleportOutX = GetPointX(2);
        n_TeleportOutY = GetPointY(2);
        bCheckEndMission = false;
        bShowBriefing = false;
        //----------- Camera -----------------
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),8,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        AddBriefing("translateBriefing113a");
        return TestEntrance1,20;
    }
    
    //-----------------------------------------------------------------------------------------
    state TestEntrance1
    {
        if(bShowBriefing)
        {
            bShowBriefing = false;
            AddBriefing("translateBriefing113b");
            return TestEntrance2,20; 
        }
        if(p_Tester1.GetLocationZ()==1)
        {
            bShowBriefing = true;
            p_Player.LookAt(p_Tester1.GetLocationX(),p_Tester1.GetLocationY(),8,0,20,1);
        }
        return TestEntrance1,80;
    }
    //-----------------------------------------------------------------------------------------
    state TestEntrance2
    {
        if(bShowBriefing)
        {
            bShowBriefing = false;
            KillArea(65535,p_Tester1.GetLocationX(),p_Tester1.GetLocationY(),0,1);
            return TestEntranceBriefing,100;
        }
        
        if(p_Tester1.GetLocationZ()==0)
        {
            bShowBriefing = true;
            p_Player.LookAt(p_Tester1.GetLocationX(),p_Tester1.GetLocationY(),8,0,20,0);
        }
        return TestEntrance2,20;
    }
    //-----------------------------------------------------------------------------------------
    state TestEntranceBriefing
    {
        SetGoalState(testTunnelEntrance,goalAchieved);
        EnableGoal(testTeleport,true);               
        AddBriefing("translateBriefing113c");
        p_Neutral.GiveAllBuildingsTo(p_Player);
        p_Neutral.GiveAllUnitsTo(p_Player);
        CallCamera();
        SelectUnit(p_Tester2,false);
        return TestTeleportStart,20; 
    }
    //-----------------------------------------------------------------------------------------
    state TestTeleportStart
    {
        p_Player.DelayedLookAt(GetPointX(1),GetPointY(1),6,0,20,0,60,1);
        return TestTeleport,20;
    }
    state TestTeleport
    {
        if(p_Tester2.DistanceTo(n_TeleportOutX,n_TeleportOutY)<4)
        {
            p_Player.DelayedLookAt(n_TeleportOutX,n_TeleportOutY,8,128,20,0,60,1);  
            return BlowUpTeleport,100; 
        }
        return TestTeleport,20;
    }
    //-----------------------------------------------------------------------------------------
    state BlowUpTeleport
    {
        KillArea(65535,n_TeleportOutX,n_TeleportOutY,0,8);
        return LastBriefing,200;
    }
    //-----------------------------------------------------------------------------------------
    state LastBriefing
    {
        SetGoalState(testTeleport,goalAchieved);
        AddBriefing("translateBriefing113d");
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
            if(!p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed113");
                EndMission(false);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli 5min
    {
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),40,400,2500,800,5); 
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
        p_Player.SetEnemy(p_Neutral);
        p_Neutral.SetEnemy(p_Player);
    }
}
