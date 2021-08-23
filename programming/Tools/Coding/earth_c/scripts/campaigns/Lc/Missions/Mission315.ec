mission "translateMission315"
{
    consts
    {
        destroyEnemyBase = 0;
    }
    
    player pEnemy1;
    player pEnemy2;
    player pPlayer;
    
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(destroyEnemyBase,"translateGoal315");
        EnableGoal(destroyEnemyBase,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy1 = GetPlayer(2);
        pEnemy2 = GetPlayer(8);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            pEnemy1.LoadScript("single\\singleEasy");
            pEnemy2.LoadScript("single\\singleEasy");
            pEnemy2.EnableAIFeatures(aiControlDefense,false);
            pEnemy2.EnableAIFeatures(aiBuildBuildings,false);
        }
        if(GetDifficultyLevel()==1)
        {
            pEnemy1.LoadScript("single\\singleMedium");
            pEnemy2.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            pEnemy1.LoadScript("single\\singleHard");
            pEnemy2.LoadScript("single\\singleHard");
        }
        
        pEnemy2.EnableAIFeatures(aiControlOffense,false);
        pPlayer.EnableAIFeatures(aiEnabled,false);    
        //----------- Money ------------------
        if(GetDifficultyLevel()==2)
            pPlayer.SetMoney(10000);
        else
            pPlayer.SetMoney(20000);
        pEnemy1.SetMoney(20000);
        pEnemy2.SetMoney(20000);
        //----------- Researches -------------
        
        pPlayer.EnableResearch("RES_LC_WSR2",true);
        pPlayer.EnableResearch("RES_LC_UMO2",true);
        pPlayer.EnableResearch("RES_LC_BMD",true);
        
        pEnemy1.EnableResearch("RES_ED_WCA2",true);
        pEnemy1.EnableResearch("RES_ED_MSC2",true);
        pEnemy1.EnableResearch("RES_ED_UMT1",true);
        
        pEnemy2.CopyResearches(pEnemy1);
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bCheckEndMission=false;
        
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;//5 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing315",pPlayer.GetName());
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(GetGoalState(destroyEnemyBase)!=goalAchieved && !pEnemy2.GetNumberOfBuildings())
            {
                SetGoalState(destroyEnemyBase, goalAchieved);
                AddBriefing("translateAccomplished315",pPlayer.GetName());
                EnableEndMissionButton(true);
            }
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailedNoUnits",pPlayer.GetName());
                EndMission(false);
            }
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
    }
}

