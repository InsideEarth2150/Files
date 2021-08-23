mission "translateMission212"
{//Antarktyka klif
    consts
    {
        findEnemy = 0;
        findEnemyBase = 1;
        destroyEnemyBase = 2;
    }
    player p_Enemy;
    player p_Neutral;
    player p_Player;
    int n_Enemy1X;
    int n_Enemy1Y;
    int n_Enemy2X;
    int n_Enemy2Y;
    int n_EnemyBaseX;
    int n_EnemyBaseY;
    int n_OldBaseX;
    int n_OldBaseY;
    int bCheckEndMission;
    state Initialize;
    state ShowBriefing;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        if(!PointExist(0))AddBriefing("translateMarkPointDosntExist",0);
        if(!PointExist(1))AddBriefing("translateMarkPointDosntExist",1);
        if(!PointExist(2))AddBriefing("translateMarkPointDosntExist",2);
        if(!PointExist(3))AddBriefing("translateMarkPointDosntExist",3);
        //----------- Goals ------------------
        RegisterGoal(findEnemy,"translateGoal212a");
        RegisterGoal(findEnemyBase,"translateGoalFindEnemyBase");
        RegisterGoal(destroyEnemyBase,"translateGoalDestroyEnemyBase");
        EnableGoal(findEnemy,true);           
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);    
        tmpPlayer = GetPlayer(6); 
        tmpPlayer.EnableStatistics(false);    
        tmpPlayer.EnableAIFeatures(aiEnabled,false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy = GetPlayer(1);
        p_Neutral = GetPlayer(4);
        
        //----------- AI ---------------------
        p_Neutral.EnableStatistics(false);
        
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        p_Enemy.SetNeutral(p_Neutral);
        if(GetDifficultyLevel()==0)
        {
            p_Enemy.LoadScript("single\\singleEasy");
            p_Enemy.EnableAIFeatures(aiUpgradeCannons,false);
        }
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
            p_Enemy.CreateDefaultUnit(p_Enemy.GetStartingPointX(),p_Enemy.GetStartingPointY(),0);
        }
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        
        
        //----------- Money ------------------
        p_Player.SetMoney(15000);
        p_Enemy.SetMoney(10000);
        //----------- Researches -------------
        p_Enemy.EnableResearch("RES_UCS_WSR1",true);
        
        p_Player.EnableResearch("RES_ED_WCH2",true);
        p_Player.EnableResearch("RES_MCH2",true);
        p_Player.EnableResearch("RES_ED_UA11",true);
        p_Player.EnableResearch("RES_ED_UST3",true);
        //----------- Buildings --------------
        // 1st tab
        p_Player.EnableBuilding("EDBPP",true);
        p_Player.EnableBuilding("EDBBA",true);
        p_Player.EnableBuilding("EDBFA",true);
        p_Player.EnableBuilding("EDBWB",false);
        p_Player.EnableBuilding("EDBAB",true);
        // 2nd tab
        p_Player.EnableBuilding("EDBRE",true);
        p_Player.EnableBuilding("EDBMI",true);
        p_Player.EnableBuilding("EDBTC",true);
        // 3rd tab
        p_Player.EnableBuilding("EDBST",false);
        // 4th tab
        p_Player.EnableBuilding("EDBRC",true);
        p_Player.EnableBuilding("EDBHQ",true);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBEN1",true);
        p_Player.EnableBuilding("EDBLZ",true);
        //----------- Units ------------------
        //----------- Artefacts --------------
        CreateArtefact("NEASPECIAL1",GetPointX(3),GetPointY(3),0,0,artefactSpecialAINewAreaLocation);
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,1000);
        //----------- Variables --------------
        n_Enemy1X = GetPointX(0);
        n_Enemy1Y = GetPointY(0);
        n_Enemy2X = GetPointX(1);
        n_Enemy2Y = GetPointY(1);
        n_EnemyBaseX = GetPointX(2);
        n_EnemyBaseY = GetPointY(2);
        n_OldBaseX = p_Neutral.GetStartingPointX();
        n_OldBaseY = p_Neutral.GetStartingPointY();
        bCheckEndMission=false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,15,0);
        return ShowBriefing,280;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),20,50,5000,30,7); 
        EnableNextMission(0,true);
        AddBriefing("translateBriefing212a");
        return Nothing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    { 
        
        if(GetGoalState(findEnemy) != goalAchieved)
        {  
            if(p_Player.IsPointLocated(n_Enemy1X,n_Enemy1Y,0))
            {
                SetGoalState(findEnemy, goalAchieved);
                EnableGoal(findEnemyBase,true);
                CallCamera();
                AddBriefing("translateBriefing212b");
            }
            if(p_Player.IsPointLocated(n_Enemy2X,n_Enemy2Y,0))
            {
                SetGoalState(findEnemy, goalAchieved);
                EnableGoal(findEnemyBase,true);
                CallCamera();
                AddBriefing("translateBriefing212b");
            }
        }
        if(GetGoalState(findEnemyBase)!=goalAchieved && 
            p_Player.IsPointLocated(n_EnemyBaseX,n_EnemyBaseY,0))
        {
            Snow(n_EnemyBaseX,n_EnemyBaseY,20,50,8000,50,7);
            SetGoalState(findEnemyBase, goalAchieved);
            EnableGoal(destroyEnemyBase,true);
            CallCamera();
            AddBriefing("translateBriefing212c");
        }
        if(n_OldBaseX && p_Player.IsPointLocated(n_OldBaseX,n_OldBaseY,0))
        {
            n_OldBaseX=0;
            AddBriefing("translateBriefing212d");
        }
        return Nothing,100;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed212");
                EndMission(false);
            }
            if(GetGoalState(destroyEnemyBase)!=goalAchieved && 
                (p_Enemy.GetNumberOfUnits()<5) && 
                !p_Enemy.GetNumberOfBuildings(buildingPowerPlant)&&
                !p_Enemy.GetNumberOfBuildings(buildingRefinery)&&
                p_Enemy.GetNumberOfBuildings() < 5)
            {
                SetGoalState(destroyEnemyBase, goalAchieved);
                AddBriefing("translateAccomplished212");
                EnableEndMissionButton(true);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 1000 cykli
    {
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
        p_Neutral.SetEnemy(p_Player);
        p_Player.SetEnemy(p_Neutral);
        p_Enemy.SetEnemy(p_Neutral);
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        EnableNextMission(1,true);
        return true; //usuwa sie 
    }
}
