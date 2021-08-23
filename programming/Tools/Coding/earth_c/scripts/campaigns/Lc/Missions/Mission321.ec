mission "translateMission321"
{
    consts
    {
        destroyEnemyBase = 0;
        backToBase = 1;
    }
    
    player pEnemy;
    player pPlayer;
    
    unitex uHero;
    
    int bBlowUpBase;  
    int nBlowUpCounter;
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(destroyEnemyBase,"translateGoal321");
        RegisterGoal(backToBase,"translateGoalHeroBackToBase");
        EnableGoal(destroyEnemyBase,true);
        
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy = GetPlayer(2);
        
        //----------- AI ---------------------
        pPlayer.EnableAIFeatures(aiEnabled,false);
        if(GetDifficultyLevel()==0)
            pEnemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            pEnemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            pEnemy.LoadScript("single\\singleHard");
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        //pEnemy.AddToMainTargetList();
        
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        pEnemy.SetMoney(20000);
        
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WSL1",true);
        pPlayer.EnableResearch("RES_LC_BHD",true);
        
        pEnemy.EnableResearch("RES_ED_WSL1",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        uHero=pPlayer.GetScriptUnit(0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,10000);
        //----------- Variables --------------
        bCheckEndMission=false;
        bBlowUpBase=true;
        nBlowUpCounter=0;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,200;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing321a",pPlayer.GetName());
        return Fighting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        int timeToExplode;
        if(bBlowUpBase &&
            uHero.IsInWorld(GetWorldNum()) &&
            uHero.DistanceTo(GetPointX(0),GetPointY(0))<10 && 
            !uHero.GetLocationZ())
        {
            bBlowUpBase=false;
            if(GetDifficultyLevel()==0)
                nBlowUpCounter=30;
            if(GetDifficultyLevel()==1)
                nBlowUpCounter=20;
            if(GetDifficultyLevel()==2)
                nBlowUpCounter=10;
            AddBriefing("translateBriefing321b",pPlayer.GetName());
            return Fighting,20; 
        }
        
        if(nBlowUpCounter)
        {
            nBlowUpCounter=nBlowUpCounter-1;
            if(!nBlowUpCounter)
            {
                KillArea(4,GetPointX(0),GetPointY(0),0,20-(GetDifficultyLevel()*5));
                SetConsoleText("");
            }
            else
                SetConsoleText("translateMessage321",nBlowUpCounter);
            return Fighting,20; 
        }
        
        return Fighting,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(GetGoalState(backToBase)!=goalAchieved && !uHero.IsInWorld(GetWorldNum()))
        {
            SetGoalState(backToBase,goalAchieved);
            EnableEndMissionButton(true);
        }
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(GetGoalState(destroyEnemyBase)!=goalAchieved && !pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailedNoUnits",pPlayer.GetName());
                EndMission(false);
            }
            
            if(GetGoalState(destroyEnemyBase)!=goalAchieved && !pEnemy.GetNumberOfBuildings())
            {
                SetGoalState(destroyEnemyBase, goalAchieved);
                EnableGoal(backToBase,true);
                AddBriefing("translateAccomplished321",pPlayer.GetName());
                state Nothing;
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli
    {
        Snow(GetPointX(0),GetPointY(0),30,400,2500,800,3); 
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
}

