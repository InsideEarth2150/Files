mission "translateMission224"
{
    consts
    {
        destroyEnemy1 = 0;
        destroyEnemy2 = 1;
        destroyEnemy3 = 2;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Player;
    int bShitchOnAI;
    int bCheckEndMission;
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state Evacuate;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        
        
        RegisterGoal(destroyEnemy1,"translateGoal224a");
        RegisterGoal(destroyEnemy2,"translateGoal224b");
        RegisterGoal(destroyEnemy3,"translateGoal224c");
        EnableGoal(destroyEnemy1,true);
        EnableGoal(destroyEnemy2,true);
        EnableGoal(destroyEnemy3,true);
        
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(3);
        p_Enemy2 = GetPlayer(4);
        p_Enemy3 = GetPlayer(5);
        
        p_Player.SetMoney(20000);
        p_Enemy1.SetMoney(20000);
        p_Enemy2.SetMoney(20000);
        p_Enemy3.SetMoney(20000);
        
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy3.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Enemy3.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Enemy3.LoadScript("single\\singleHard");
        }
        
        p_Enemy2.SetNumberOfOffensiveTankPlatoons(0);
        p_Enemy2.SetNumberOfOffensiveShipPlatoons(0);
        p_Enemy2.SetNumberOfOffensiveHelicopterPlatoons(0);
        
        p_Enemy3.SetNumberOfDefensiveTankPlatoons(0);
        p_Enemy3.SetNumberOfDefensiveShipPlatoons(0);
        p_Enemy3.SetNumberOfDefensiveHelicopterPlatoons(0);
        
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy3.EnableAIFeatures(aiControlOffense,false);
        
        p_Enemy1.EnableResearch("RES_LC_WSR2",true);
        p_Enemy1.EnableResearch("RES_MSR2",true);
        p_Enemy1.EnableResearch("RES_LC_REG1",true);
        p_Enemy1.EnableResearch("RES_LC_SGEN",true);
        p_Enemy1.EnableResearch("RES_LC_BWC",true);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        p_Enemy3.CopyResearches(p_Enemy1);
        
        
        p_Player.EnableResearch("RES_ED_WSR2",true);
        p_Player.EnableResearch("RES_ED_UA21",true);
        p_Player.EnableResearch("RES_ED_USS2",true);
        p_Player.EnableResearch("RES_ED_UMW1",true);
        p_Player.EnableResearch("RES_ED_BMD",true);
        
        // 1st tab
        p_Player.EnableBuilding("EDBPP",true);
        p_Player.EnableBuilding("EDBBA",true);
        p_Player.EnableBuilding("EDBFA",true);
        p_Player.EnableBuilding("EDBWB",true);
        p_Player.EnableBuilding("EDBAB",true);
        // 2nd tab
        p_Player.EnableBuilding("EDBRE",true);
        p_Player.EnableBuilding("EDBMI",true);
        p_Player.EnableBuilding("EDBTC",true);
        // 3rd tab
        p_Player.EnableBuilding("EDBST",true);
        // 4th tab
        p_Player.EnableBuilding("EDBRC",true);
        p_Player.EnableBuilding("EDBHQ",true);
        p_Player.EnableBuilding("EDBRA",true);
        p_Player.EnableBuilding("EDBEN1",true);
        p_Player.EnableBuilding("EDBLZ",true);
        
        bShitchOnAI=true;
        bCheckEndMission = false;
        
        SetTimer(0,100);
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),10,500,5000,500,10);
        EnableNextMission(1,true); //nie wlaczac 0 bo generuje to trudny do uchwycenia blad
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing224");
        return Fighting,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        
        if(bShitchOnAI && 
            (p_Player.IsPointLocated(p_Enemy1.GetStartingPointX(),p_Enemy1.GetStartingPointY(),0)||
            p_Player.IsPointLocated(p_Enemy2.GetStartingPointX(),p_Enemy2.GetStartingPointY(),0)||
            p_Player.IsPointLocated(p_Enemy3.GetStartingPointX(),p_Enemy3.GetStartingPointY(),0)))
        {
            bShitchOnAI=false;
            p_Enemy1.EnableAIFeatures(aiControlOffense,true);
            p_Enemy3.EnableAIFeatures(aiControlOffense,true);
        }
        
        if(GetGoalState(destroyEnemy1)!=goalAchieved && !p_Enemy1.GetNumberOfBuildings())
        {
            SetGoalState(destroyEnemy1, goalAchieved);
        }
        if(GetGoalState(destroyEnemy2)!=goalAchieved && !p_Enemy2.GetNumberOfBuildings())
        {
            SetGoalState(destroyEnemy2, goalAchieved);
        }
        if(GetGoalState(destroyEnemy3)!=goalAchieved && !p_Enemy3.GetNumberOfBuildings())
        {
            SetGoalState(destroyEnemy3, goalAchieved);
        }
        
        if(GetGoalState(destroyEnemy1)==goalAchieved && 
            GetGoalState(destroyEnemy2)==goalAchieved && 
            GetGoalState(destroyEnemy3)==goalAchieved)
        {
            AddBriefing("translateAccomplished224");
            
            EnableEndMissionButton(true);
            return Evacuate;
        }
        return Fighting, 100; 
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        return Evacuate, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0()
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed224");
                EndMission(false);
            }
        }
    }
    
    
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit u_Unit)
    {
        bCheckEndMission=true;
        if(bShitchOnAI)
        {
            bShitchOnAI=false;
            p_Enemy1.EnableAIFeatures(aiControlOffense,true);
            p_Enemy3.EnableAIFeatures(aiControlOffense,true);
        }
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit u_Unit)
    { 
        bCheckEndMission=true;
        if(bShitchOnAI)
        {
            bShitchOnAI=false;
            p_Enemy1.EnableAIFeatures(aiControlOffense,true);
            p_Enemy3.EnableAIFeatures(aiControlOffense,true);
        }
    }
}

