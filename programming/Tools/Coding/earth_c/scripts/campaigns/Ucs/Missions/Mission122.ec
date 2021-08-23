mission "translateMission122"
{//Projekt Teleport - part II
    consts
    {
        testTunnelEntrance = 0;
        testTeleport = 1;
        destroyMech = 2;
    }
    
    
    player pPlayer;
    player pNeutral;
    player pSecurity;
    
    unitex uTester1;
    unitex uTeleport;
    
    int n_TeleportOutX;
    int n_TeleportOutY;
    int bCheckEndMission;
    int bShowBriefing;
    
    state Initialize;
    state ShowBriefing;
    state TestEntrance1;
    state TestEntrance2;
    state TestEntranceBriefing;
    state TestTeleport;
    state TeleportBriefing;
    state DestroyMech;
    state LastBriefing;
    state Final;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(testTunnelEntrance,"translateGoal122a");
        RegisterGoal(testTeleport,"translateGoal122b");
        RegisterGoal(destroyMech,"translateGoal122c");
        
        EnableGoal(testTunnelEntrance,true);               
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        tmpPlayer = GetPlayer(2); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(1);
        pNeutral = GetPlayer(6);
        pSecurity = GetPlayer(4);
        //----------- AI ---------------------
        pNeutral.EnableStatistics(false);
        pSecurity.EnableStatistics(false);
        
        pPlayer.SetNeutral(pNeutral);
        pNeutral.SetNeutral(pPlayer);
        
        pPlayer.SetNeutral(pSecurity);
        pSecurity.SetNeutral(pPlayer);
        
        pNeutral.SetNeutral(pSecurity);
        pSecurity.SetNeutral(pNeutral);
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        pNeutral.EnableAIFeatures(aiEnabled,false);
        pSecurity.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        //----------- Researches -------------
        //----------- Buildings --------------
        pPlayer.EnableBuilding("UCSBBA",false);
        pPlayer.EnableBuilding("UCSBFA",false);
        pPlayer.EnableBuilding("UCSBPP",false);
        pPlayer.EnableBuilding("UCSBPR",false);
        pPlayer.EnableBuilding("UCSBTB",false);
        pPlayer.EnableBuilding("UCSBET",false);
        pPlayer.EnableBuilding("UCSBRF",false);
        pPlayer.EnableBuilding("UCSBRC",false);
        pPlayer.EnableBuilding("UCSBAB",false);
        pPlayer.EnableBuilding("UCSBWB",false);
        pPlayer.EnableBuilding("UCSBFO",false);
        pPlayer.EnableBuilding("UCSBST",false);
        pPlayer.EnableBuilding("UCSBBT",false);
        pPlayer.EnableBuilding("UCSBPB",false);
        pPlayer.EnableBuilding("UCSBPC",false);
        pPlayer.EnableBuilding("UCSBHQ",false);
        pPlayer.EnableBuilding("UCSBSD",false);
        pPlayer.EnableBuilding("UCSBSH",false);
        pPlayer.EnableBuilding("UCSBTE",false);
        pPlayer.EnableBuilding("UCSBEN1",true);
        pPlayer.EnableBuilding("UCSBSS",false);
        pPlayer.EnableBuilding("UCSBLZ",false);
        pPlayer.EnableBuilding("UCSBTE",false);
        //----------- Units ------------------
        uTester1 = GetUnit(GetPointX(0),GetPointY(0),0);
        uTeleport= GetUnit(GetPointX(1),GetPointY(1),0);
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
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),8,0,20,0);
        SelectUnit(uTester1,false);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        EnableNextMission(1,true);
        AddBriefing("translateBriefing122a");
        return TestEntrance1,20;
    }
    
    //-----------------------------------------------------------------------------------------
    state TestEntrance1
    {
        if(bShowBriefing)
        {
            bShowBriefing = false;
            AddBriefing("translateBriefing122b");
            return TestEntrance2,20; 
        }
        if(uTester1.GetLocationZ()==1)
        {
            bShowBriefing = true;
            pPlayer.LookAt(uTester1.GetLocationX(),uTester1.GetLocationY(),8,0,20,1);
        }
        return TestEntrance1,80;
    }
    //-----------------------------------------------------------------------------------------
    state TestEntrance2
    {
        if(uTester1.GetLocationZ()==0)
        {
            pPlayer.LookAt(uTester1.GetLocationX(),uTester1.GetLocationY(),8,0,20,0);
            return TestEntranceBriefing,100;
        }
        return TestEntrance2,20;
    }
    //-----------------------------------------------------------------------------------------
    state TestEntranceBriefing
    {
        SetGoalState(testTunnelEntrance,goalAchieved);
        EnableGoal(testTeleport,true);               
        AddBriefing("translateBriefing122c");//OK it works
        pNeutral.GiveAllBuildingsTo(pPlayer);
        return TestTeleport,20; 
    }
    //-----------------------------------------------------------------------------------------
    state TestTeleport
    {
        if(uTester1.DistanceTo(n_TeleportOutX,n_TeleportOutY)<4)
        {
            pPlayer.DelayedLookAt(n_TeleportOutX,n_TeleportOutY,8,0,20,0,20,1);  
            return TeleportBriefing,100; 
        }
        return TestTeleport,20;
    }
    //-----------------------------------------------------------------------------------------
    state TeleportBriefing
    {
        uTester1.ChangePlayer(GetPlayer(2));
        uTeleport.ChangePlayer(GetPlayer(6));
        pSecurity.GiveAllUnitsTo(pPlayer);
        SetGoalState(testTeleport,goalAchieved);
        EnableGoal(destroyMech,true);               
        AddBriefing("translateBriefing122d");
        return DestroyMech,50;
    }
    //-----------------------------------------------------------------------------------------
    state DestroyMech
    {
        if(!uTester1.IsLive())
            return LastBriefing,80;
        return DestroyMech,50;
    }
    //-----------------------------------------------------------------------------------------
    state LastBriefing
    {
        SetGoalState(destroyMech,goalAchieved);
        AddBriefing("translateAccomplished122");
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
            if(!pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed122");
                EndMission(false);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli 5min
    {
        Snow(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),40,400,2500,800,5); 
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
        pPlayer.SetEnemy(pNeutral);
        pNeutral.SetEnemy(pPlayer);
        
        pPlayer.SetEnemy(pSecurity);
        pSecurity.SetEnemy(pPlayer);
        
        pNeutral.SetEnemy(pSecurity);
        pSecurity.SetEnemy(pNeutral);
    }
}
