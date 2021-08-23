mission "translateMission111"
{
    consts
    {
        findResource = 0;
        sendToBase20000 = 1;
    }
    
    player p_Enemy;
    player p_Player;
    
    int n_ResourceX;
    int n_ResourceY;
    int n_EnemyBaseX;
    int n_EnemyBaseY;
    int bShowFailed;  
    int b_AIActivated;
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Searching;
    state Mining;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(findResource,"translateGoalFindResources");
        RegisterGoal(sendToBase20000,"translateGoalSend20000",0);
        EnableGoal(findResource,true);
        
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        p_Enemy = GetPlayer(2);
        
        //----------- AI ---------------------
        p_Enemy.EnableStatistics(false);
        
        if(GetDifficultyLevel()==0)
            p_Enemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy.LoadScript("single\\singleHard");
        
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        p_Enemy.EnableAIFeatures(aiControlDefense,false);
        
        //----------- Money ------------------
        p_Player.SetMoney(10000);
        p_Enemy.SetMoney(30000);
        
        //----------- Researches -------------
        p_Player.EnableResearch("RES_UCS_USL2",true);
        //----------- Buildings --------------
        // 1st tab
        p_Player.EnableBuilding("UCSBPP",true);
        p_Player.EnableBuilding("UCSBBA",true);
        p_Player.EnableBuilding("UCSBFA",false);
        p_Player.EnableBuilding("UCSBWB",false);
        p_Player.EnableBuilding("UCSBAB",false);
        // 2nd tab
        p_Player.EnableBuilding("UCSBRF",false);
        p_Player.EnableBuilding("UCSBTB",true);
        // 3rd tab
        p_Player.EnableBuilding("UCSBST",false);
        // 4th tab
        p_Player.EnableBuilding("UCSBRC",false);
        p_Player.EnableBuilding("UCSBEN1",false);
        p_Player.EnableBuilding("UCSBTE",false);
        p_Player.EnableBuilding("UCSBHQ",false);
        p_Player.EnableBuilding("UCSBEN1",false);
        p_Player.EnableBuilding("UCSBLZ",true);
        
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,1000);
        
        //----------- Variables --------------
        n_ResourceX = GetPointX(1);
        n_ResourceY = GetPointY(1);
        n_EnemyBaseX = GetPointX(0);
        n_EnemyBaseY = GetPointY(0);
        b_AIActivated=false;
        bCheckEndMission=false;
        bShowFailed=true;
        
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,200;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        Snow(n_ResourceX,n_ResourceY,310,500,5000,500,10);
        AddBriefing("translateBriefing111a");
        return Searching,100;
    }
    //-----------------------------------------------------------------------------------------
    state Searching
    {
        if(p_Player.IsPointLocated(n_ResourceX,n_ResourceY,0))
        {
            SetGoalState(findResource, goalAchieved);
            EnableGoal(sendToBase20000,true);
            EnableNextMission(0,true);
            EnableNextMission(1,true);
            return Mining,200; 
        }
        return Searching,100; 
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        
        if(p_Player.GetMoneySentToBase()>=20000)
        {
            SetGoalState(sendToBase20000, goalAchieved);
            AddBriefing("translateAccomplished111");
            EnableEndMissionButton(true);
            return Nothing,500;
        }
        if(!b_AIActivated &&
            (p_Player.GetMoneySentToBase()>=15000 ||
            p_Player.IsPointLocated(GetPointX(2),GetPointY(2),GetPointZ(2)) ||
            p_Player.IsPointLocated(GetPointX(3),GetPointY(3),GetPointZ(3)) ||
            p_Player.IsPointLocated(GetPointX(4),GetPointY(4),GetPointZ(4)) ||
            p_Player.IsPointLocated(GetPointX(5),GetPointY(5),GetPointZ(5))))
        {
            b_AIActivated=true;
            AddBriefing("translateBriefing111b");
            p_Enemy.EnableAIFeatures(aiControlOffense,true);
            p_Enemy.EnableAIFeatures(aiControlDefense,true);
            // 1st tab
            p_Player.EnableBuilding("UCSBBA",true);
            p_Player.EnableBuilding("UCSBFA",true);
            p_Player.EnableBuilding("UCSBAB",true);
            // 2nd tab
            p_Player.EnableBuilding("UCSBRF",true);
            p_Enemy.EnableStatistics(true);
        }
        return Mining,200; 
    }
    
    //-----------------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        RegisterGoal(sendToBase20000,"translateGoalSend20000",p_Player.GetMoneySentToBase());
        if(bShowFailed)
        {
            if(IsGoalEnabled(sendToBase20000))
            {
                if((ResourcesLeftInMoney()+p_Player.GetMoney()+p_Player.GetMoneySentToBase())<20000)
                {
                    bShowFailed=false;
                    SetGoalState(sendToBase20000, goalFailed);
                    AddBriefing("translateFailed111a");
                    EnableEndMissionButton(true);
                    return Nothing;
                }
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed111b");
                EndMission(false);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 1000 cykli
    {
        if(GetMissionTime()==1000) Snow(n_ResourceX,n_ResourceY,10,400,5000,800,10); 
        if(GetMissionTime()==12000) Snow(n_EnemyBaseX,n_EnemyBaseY,10,400,5000,800,10); 
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

