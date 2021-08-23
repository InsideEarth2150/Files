mission "translateMission211"
{
    consts
    {
        findResource = 0;
        sendToBase20000 = 1;
        destroyEnemyUnits = 2;
        destroyEnemyBase = 3;
        buildLandingZone = 4;
        callContTran = 5;
    }
    
    player p_Enemy;
    player p_Player;
    
    int n_ResourceX;
    int n_ResourceY;
    int n_BaseLCX;
    int n_BaseLCY;
    int n_BaseLCX2;
    int n_BaseLCY2;
    int bShowFailed;  
    int bCheckEndMission;
    int bVictory;
    state Initialize;
    state ShowBriefing;
    state Mining;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        
        RegisterGoal(findResource,"translateGoalFindResources");
        RegisterGoal(sendToBase20000,"translateGoalSend20000",0);
        RegisterGoal(destroyEnemyUnits,"translateGoalDestroyEnemyUnits");
        RegisterGoal(destroyEnemyBase,"translateGoalDestroyEnemyBase");
        RegisterGoal(buildLandingZone,"translateGoal211a");
        RegisterGoal(callContTran,"translateGoal211b");
        EnableGoal(findResource,true);
        EnableGoal(buildLandingZone,true);
        EnableGoal(callContTran,true);
        
        n_ResourceX = GetPointX(0);
        n_ResourceY = GetPointY(0);
        n_BaseLCX = GetPointX(1);
        n_BaseLCY = GetPointY(1);
        
        n_BaseLCX2 = GetPointX(6);
        n_BaseLCY2 = GetPointY(6);
        
        p_Player = GetPlayer(2);
        p_Enemy = GetPlayer(3);
        
        p_Enemy.EnableStatistics(false);
        
        p_Player.SetMoney(10000);
        p_Enemy.SetMoney(20000);
        
        
        if(GetDifficultyLevel()==0)
            p_Enemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy.LoadScript("single\\singleHard");
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy.EnableAIFeatures(aiEnabled,false);
        
        p_Player.EnableResearch("RES_ED_UST2",true);
        
        // 1st tab
        p_Player.EnableBuilding("EDBPP",true);
        p_Player.EnableBuilding("EDBBA",false);
        p_Player.EnableBuilding("EDBFA",false);
        p_Player.EnableBuilding("EDBWB",false);
        p_Player.EnableBuilding("EDBAB",false);
        // 2nd tab
        p_Player.EnableBuilding("EDBRE",false);
        p_Player.EnableBuilding("EDBMI",true);
        p_Player.EnableBuilding("EDBTC",true);
        // 3rd tab
        p_Player.EnableBuilding("EDBST",false);
        // 4th tab
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBEN1",false);
        p_Player.EnableBuilding("EDBLZ",true);
        
        CreateArtefact("NEASPECIAL1",n_BaseLCX,n_BaseLCY,0,0,artefactSpecialAINewAreaLocation);
        
        bShowFailed=true;
        bCheckEndMission=false;
        bVictory=false;
        EnableNextMission(0,true);
        
        SetTimer(0,100);
        SetTimer(1,6000);
        
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing211a");
        Snow(n_ResourceX,n_ResourceY,45,400,5000,800,10); 
        return Mining,100;
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(GetGoalState(findResource)!= goalAchieved &&
            p_Player.IsPointLocated(n_ResourceX,n_ResourceY,0))
        {
            SetGoalState(findResource, goalAchieved);
            EnableGoal(sendToBase20000,true);
        }
        if(GetGoalState(sendToBase20000)!=goalAchieved 
            && p_Player.GetMoneySentToBase()>=20000)
        {
            SetGoalState(sendToBase20000, goalAchieved);
            if(!IsGoalEnabled(destroyEnemyUnits) &&
                !IsGoalEnabled(destroyEnemyBase))
            {
                AddBriefing("translateAccomplished211a");
                bVictory=true;
                EnableEndMissionButton(true);
            }
            //EnableSendingToBase(false);//XXXMD to wykorzystywac.
        }
        if(!IsGoalEnabled(destroyEnemyUnits) &&
            (p_Player.IsPointLocated(GetPointX(2),GetPointY(2),0) ||
            p_Player.IsPointLocated(GetPointX(3),GetPointY(3),0) ||
            p_Player.IsPointLocated(GetPointX(4),GetPointY(4),0) ||
            p_Player.IsPointLocated(GetPointX(5),GetPointY(5),0)))
        {
            p_Enemy.EnableStatistics(true);
            EnableGoal(destroyEnemyUnits,true);
            AddBriefing("translateBriefing211b");
            p_Enemy.EnableAIFeatures(aiEnabled,true);
            p_Enemy.EnableAIFeatures(aiControlOffense,false);
            p_Enemy.EnableAIFeatures(aiBuildMiningBuildings,false);
            bVictory=false;
            EnableEndMissionButton(false);
            // 1st tab
            p_Player.EnableBuilding("EDBBA",true);
            p_Player.EnableBuilding("EDBFA",true);
            p_Player.EnableBuilding("EDBAB",true);
            // 2nd tab
            p_Player.EnableBuilding("EDBRE",true);
        }
        if(!IsGoalEnabled(destroyEnemyBase) &&
            (p_Player.IsPointLocated(n_BaseLCX,n_BaseLCY,0)||
            p_Player.IsPointLocated(n_BaseLCX2,n_BaseLCY2,0))) //baza wroga
        {
            EnableGoal(destroyEnemyBase,true);
            Snow(n_BaseLCX,n_BaseLCY,30,400,5000,800,10); 
            p_Enemy.EnableAIFeatures(aiControlOffense,true);
            AddBriefing("translateBriefing211c");
        }
        
        if(GetGoalState(destroyEnemyUnits)!=goalAchieved && p_Enemy.GetNumberOfUnits()<7)
        {
            SetGoalState(destroyEnemyUnits, goalAchieved);
        }
        
        if(GetGoalState(destroyEnemyBase)!=goalAchieved && !p_Enemy.GetNumberOfBuildings())
        {
            p_Enemy.EnableAIFeatures(aiControlOffense,false);
            p_Enemy.EnableAIFeatures(aiControlDefense,false);
            p_Enemy.RussianAttack(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),0);
            SetGoalState(destroyEnemyBase, goalAchieved);
        }
        
        if(GetGoalState(destroyEnemyUnits)==goalAchieved && 
            GetGoalState(destroyEnemyBase)==goalAchieved && 
            GetGoalState(sendToBase20000)==goalAchieved)
        {
            AddBriefing("translateAccomplished211b");
            bVictory=true;
            EnableEndMissionButton(true);
            return Nothing;
        }
        
        return Mining,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        RegisterGoal(sendToBase20000,"translateGoalSend20000",p_Player.GetMoneySentToBase());
        
        if(GetGoalState(buildLandingZone)!=goalAchieved && p_Player.GetNumberOfBuildings(buildingTransportCenter))
        {
            SetGoalState(buildLandingZone,goalAchieved);
        }
        if(GetGoalState(callContTran)!=goalAchieved && p_Player.GetNumberOfUnits(chassisTank|unitCarrier)>=2)
        {
            SetGoalState(callContTran,goalAchieved);
        }
        if(bShowFailed)
        {
            if((ResourcesLeftInMoney()+p_Player.GetMoney()+p_Player.GetMoneySentToBase())<20000)
            {
                bShowFailed=false;
                SetGoalState(sendToBase20000, goalFailed);
                AddBriefing("translateFailed211a");
                EnableEndMissionButton(true,false);
                bVictory=false;
                return Nothing;
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                if(bVictory)
                    EndMission(true);
                else
                {
                    AddBriefing("translateFailed211b");
                    EndMission(false);
                }
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli 5min
    {
        Snow(n_ResourceX,n_ResourceY,45,400,2500,800,5); 
        Snow(n_BaseLCX,n_BaseLCY,20,400,2500,800,5); 
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
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        EnableNextMission(1,true);
        return true; //usuwa sie 
    }
}

