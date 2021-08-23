mission "translateMission213"
{//Himalaje baza LC
    consts
    {
        findLostPlatoon = 0;
        findEnemy = 1;
        destroyEnemyMines = 2;
        sendToBase10000 = 3;
    }
    
    player pEnemy;
    player pMines;
    player pPlayer;
    
    int n_PlatoonX;
    int n_PlatoonY;
    int n_EnemyPosX;
    int n_EnemyPosY;
    int bCheckEndMission;  
    int bAiEnabled;
    
    state Initialize;
    state ShowBriefing;
    state FindLostPlatoon;
    state FindEnemy;
    state DestroyEnemy;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        
        if(!PointExist(0))AddBriefing("translateMarkPointDosntExist",0);
        if(!PointExist(1))AddBriefing("translateMarkPointDosntExist",1);
        if(!PointExist(2))AddBriefing("translateMarkPointDosntExist",2);
        if(!PointExist(3))AddBriefing("translateMarkPointDosntExist",3);
        
        RegisterGoal(findLostPlatoon,"translateGoal213a");
        RegisterGoal(findEnemy,"translateGoal213b");
        RegisterGoal(destroyEnemyMines,"translateGoal213c");
        RegisterGoal(sendToBase10000,"translateGoalSend10000",0);
        EnableGoal(findLostPlatoon,true);           
        
        pPlayer = GetPlayer(2);
        pEnemy = GetPlayer(3);
        pMines = GetPlayer(5);
        pPlayer.SetMoney(10000);
        
        
        if(GetDifficultyLevel()==0)
        {
            pEnemy.LoadScript("single\\singleEasy");
            pEnemy.EnableAIFeatures(aiUpgradeCannons,false);
            pEnemy.SetMoney(20000);
        }
        if(GetDifficultyLevel()==1)
        {
            pEnemy.LoadScript("single\\singleMedium");
            pEnemy.SetMoney(30000);
        }
        
        if(GetDifficultyLevel()==2)
        {
            pEnemy.LoadScript("single\\singleHard");
            pEnemy.SetMoney(100000);
        }
        
        pMines.LoadScript("single\\singleEasy");
        pMines.EnableAIFeatures(aiEnabled,false);
        
        pEnemy.EnableAIFeatures(aiDefenseTowers,false);
        pEnemy.EnableAIFeatures(aiControlOffense,false);
        pEnemy.EnableAIFeatures(aiBuildBuildings,false);
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        n_PlatoonX = GetPointX(0);
        n_PlatoonY = GetPointY(0);
        n_EnemyPosX = GetPointX(1);
        n_EnemyPosY = GetPointY(1);
        
        pEnemy.SetPointToAssemble(0,GetPointX(2),GetPointY(2),0);
        pEnemy.SetPointToAssemble(1,GetPointX(3),GetPointY(3),0);
        
        pEnemy.EnableResearch("RES_LC_BMD",false);
        pEnemy.EnableResearch("RES_LC_WCH2",true);
        pEnemy.EnableResearch("RES_MCH2",true);
        pEnemy.EnableResearch("RES_LC_UME1",true);
        
        pPlayer.EnableResearch("RES_MCH2",true);
        pPlayer.EnableResearch("RES_ED_UST3",true);
        pPlayer.EnableResearch("RES_ED_UA11",true);
        pPlayer.EnableResearch("RES_ED_UA12",true);
        
        // 1st tab
        pPlayer.EnableBuilding("EDBPP",false);
        pPlayer.EnableBuilding("EDBBA",false);
        pPlayer.EnableBuilding("EDBFA",false);
        pPlayer.EnableBuilding("EDBWB",false);
        pPlayer.EnableBuilding("EDBAB",false);
        // 2nd tab
        pPlayer.EnableBuilding("EDBRE",false);
        pPlayer.EnableBuilding("EDBMI",false);
        pPlayer.EnableBuilding("EDBTC",false);
        // 3rd tab
        pPlayer.EnableBuilding("EDBST",false);
        // 4th tab
        pPlayer.EnableBuilding("EDBRC",false);
        pPlayer.EnableBuilding("EDBHQ",false);
        pPlayer.EnableBuilding("EDBRA",false);
        pPlayer.EnableBuilding("EDBEN1",false);
        pPlayer.EnableBuilding("EDBLZ",false);
        
        bAiEnabled=false;
        
        SetTimer(0,100);
        SetTimer(1,6000);
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing213a");
        return FindLostPlatoon,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state FindLostPlatoon
    {
        if(pPlayer.IsPointLocated(n_PlatoonX,n_PlatoonY,0))
        {
            // 1st tab
            pPlayer.EnableBuilding("EDBPP",true);
            pPlayer.EnableBuilding("EDBBA",true);
            pPlayer.EnableBuilding("EDBFA",true);
            pPlayer.EnableBuilding("EDBWB",false);
            pPlayer.EnableBuilding("EDBAB",true);
            // 2nd tab
            pPlayer.EnableBuilding("EDBRE",true);
            pPlayer.EnableBuilding("EDBMI",true);
            pPlayer.EnableBuilding("EDBTC",true);
            // 3rd tab
            pPlayer.EnableBuilding("EDBST",false);
            // 4th tab
            pPlayer.EnableBuilding("EDBRC",true);
            pPlayer.EnableBuilding("EDBHQ",true);
            pPlayer.EnableBuilding("EDBRA",false);
            pPlayer.EnableBuilding("EDBEN1",true);
            pPlayer.EnableBuilding("EDBLZ",true);
            
            SetGoalState(findLostPlatoon, goalAchieved);
            EnableGoal(findEnemy,true);
            CallCamera();
            pPlayer.LookAt(n_PlatoonX,n_PlatoonY,10,0,20,0);
            AddBriefing("translateBriefing213b");
            return FindEnemy,200; 
        }
        
        return FindLostPlatoon,100;
    }
    //-----------------------------------------------------------------------------------------
    state FindEnemy
    {
        if(pPlayer.IsPointLocated(n_EnemyPosX,n_EnemyPosY,0))
        {
            EnableGoal(destroyEnemyMines,true);
            EnableGoal(sendToBase10000,true);
            SetGoalState(findEnemy, goalAchieved);
            AddBriefing("translateBriefing213c");
            pEnemy.SetMoney(pEnemy.GetMoney()+30000);
            return DestroyEnemy,200; 
        }
        return FindEnemy,100;
    }
    //-----------------------------------------------------------------------------------------
    state DestroyEnemy
    {
        
        if((ResourcesLeftInMoney()+pPlayer.GetMoney()+pPlayer.GetMoneySentToBase())<10000)
        {
            SetGoalState(sendToBase10000, goalFailed);
            AddBriefing("translateFailed213a");
            EnableEndMissionButton(true);
            return Evacuate;
        }
        if(GetGoalState(destroyEnemyMines)!=goalAchieved && !pMines.GetNumberOfBuildings(buildingMine))
        {
            SetGoalState(destroyEnemyMines, goalAchieved);
        }
        if(!bAiEnabled && pPlayer.GetMoneySentToBase()>1000)
        {
            bAiEnabled=true;
            pEnemy.EnableAIFeatures(aiControlOffense,true);
        }
        if(GetGoalState(sendToBase10000)!=goalAchieved && pPlayer.GetMoneySentToBase()>=10000)
        {
            SetGoalState(sendToBase10000, goalAchieved);
        }
        if(GetGoalState(destroyEnemyMines)==goalAchieved && 
            GetGoalState(sendToBase10000)==goalAchieved)
        {
            AddBriefing("translateAccomplished213");
            EnableEndMissionButton(true);
            return Evacuate;
        }
        return DestroyEnemy,100;
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        return Evacuate,500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        RegisterGoal(sendToBase10000,"translateGoalSend10000",pPlayer.GetMoneySentToBase());
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed213b");
                EndMission(false);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli = 5 min
    {
        Snow(n_EnemyPosX,n_EnemyPosY,30,400,2500,800,8); 
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
    
}
