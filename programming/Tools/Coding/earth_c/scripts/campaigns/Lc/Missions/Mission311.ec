mission "translateMission311"
{
    consts
    {
        findResource = 0;
        sendToBase20000 = 1;
        backToBase = 2;
    }
    
    player pEnemy;
    player pPlayer;
    
    int n_ResourceX;
    int n_ResourceY;
    int bShowFailed;  
    int b_AIActivated;
    int bCheckEndMission;
    int bVictory;
    
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
        RegisterGoal(backToBase,"translateGoalHeroBackToBase");
        EnableGoal(findResource,true);
        
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy = GetPlayer(2);
        
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
            pEnemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            pEnemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            pEnemy.LoadScript("single\\singleHard");
        
        pEnemy.EnableAIFeatures(aiControlOffense,false);
        pEnemy.EnableAIFeatures(aiControlDefense,false);
        pPlayer.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        pEnemy.SetMoney(20000);
        
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_MCH2",true);
        //----------- Buildings --------------
        
        pPlayer.EnableBuilding("LCBBF",false); 
        pPlayer.EnableBuilding("LCBPP",false); 
        pPlayer.EnableBuilding("LCBBA",false); 
        pPlayer.EnableBuilding("LCBMR",false); 
        pPlayer.EnableBuilding("LCBSR",false);
        pPlayer.EnableBuilding("LCBRC",false);
        pPlayer.EnableBuilding("LCBAB",false);
        pPlayer.EnableBuilding("LCBGA",false);
        pPlayer.EnableBuilding("LCBDE",false);
        pPlayer.EnableBuilding("LCBHQ",false);
        pPlayer.EnableBuilding("LCBSD",false);
        pPlayer.EnableBuilding("LCBWC",false);
        pPlayer.EnableBuilding("LCBSS",false);
        pPlayer.EnableBuilding("LCBLZ",false);
        
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,10000);
        
        //----------- Variables --------------
        n_ResourceX = GetPointX(1);
        n_ResourceY = GetPointY(1);
        b_AIActivated=false;
        bCheckEndMission=false;
        bShowFailed=true;
        bVictory=false;
        
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,200;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        EnableNextMission(1,true);
        EnableNextMission(2,true);
        Snow(n_ResourceX,n_ResourceY,310,500,5000,500,10);
        AddBriefing("translateBriefing311a",pPlayer.GetName());
        return Searching,100;
    }
    //-----------------------------------------------------------------------------------------
    state Searching
    {
        if(pPlayer.IsPointLocated(n_ResourceX,n_ResourceY,0))
        {
            SetGoalState(findResource, goalAchieved);
            EnableGoal(sendToBase20000,true);
            pPlayer.EnableBuilding("LCBPP",true);
            pPlayer.EnableBuilding("LCBBA",true);
            pPlayer.EnableBuilding("LCBSR",true);
            pPlayer.EnableBuilding("LCBLZ",true);
            AddBriefing("translateBriefing311b",pPlayer.GetName());
            return Mining,200; 
        }
        return Searching,100; 
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        
        if(pPlayer.GetMoneySentToBase()>=20000)
        {
            SetGoalState(sendToBase20000, goalAchieved);
            AddBriefing("translateAccomplished311",pPlayer.GetName());
            EnableEndMissionButton(true);
            bVictory=true;
            return Nothing,500;
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
        RegisterGoal(sendToBase20000,"translateGoalSend20000",pPlayer.GetMoneySentToBase());
        if(!b_AIActivated &&
            (pPlayer.IsPointLocated(GetPointX(2),GetPointY(2),0)||
            pPlayer.IsPointLocated(GetPointX(3),GetPointY(3),0)||
            pPlayer.IsPointLocated(GetPointX(4),GetPointY(4),0)||
            pPlayer.IsPointLocated(GetPointX(5),GetPointY(5),0)||
            (pPlayer.GetMoneySentToBase()>=15000-(GetDifficultyLevel()*2500))))
        {
            b_AIActivated=true;
            AddBriefing("translateBriefing311c",pPlayer.GetName());
            pEnemy.EnableAIFeatures(aiControlOffense,true);
            
            pPlayer.EnableBuilding("LCBPP",true);
            pPlayer.EnableBuilding("LCBBA",true);
            pPlayer.EnableBuilding("LCBBF",true); 
            pPlayer.EnableBuilding("LCBMR",true); 
            pPlayer.EnableBuilding("LCBAB",true);
            pPlayer.EnableBuilding("LCBHQ",true);
            pPlayer.EnableBuilding("LCBLZ",true);
        }
        if(bShowFailed)
        {
            if(IsGoalEnabled(sendToBase20000))
            {
                if((ResourcesLeftInMoney()+pPlayer.GetMoney()+pPlayer.GetMoneySentToBase())<20000)
                {
                    bShowFailed=false;
                    SetGoalState(sendToBase20000, goalFailed);
                    AddBriefing("translateFailed311",pPlayer.GetName());
                    EnableEndMissionButton(true);
                    bVictory=false;
                    return Nothing;
                }
            }
        }
        
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                if(bVictory)
                    EndMission(true);
                else
                {
                    AddBriefing("translateFailedNoUnits",pPlayer.GetName());
                    EndMission(false);
                }
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli
    {
        Snow(n_ResourceX,n_ResourceY,10,400,2500,800,10); 
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

