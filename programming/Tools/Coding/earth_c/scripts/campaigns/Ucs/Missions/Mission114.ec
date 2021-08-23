mission "translateMission114"
{
    consts
    {
        findResource = 0;
        sendToBase30000 = 1;
    }
    
    player pEnemy;
    player pPlayer;
    
    int bShowFailed;    
    int bCheckEndMission;
    int bSwitchAI;
    state Initialize;
    state ShowBriefing;
    state Mining;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        int nStartAttack;
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(findResource,"translateGoalFindResources");
        RegisterGoal(sendToBase30000,"translateGoalSend30000",0);
        EnableGoal(findResource,true);
        EnableGoal(sendToBase30000,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(1);
        pEnemy = GetPlayer(2);
        //----------- AI ---------------------
        pPlayer.SetMilitaryUnitsLimit(15000);
        if(GetDifficultyLevel()==0)
        {
            pEnemy.LoadScript("single\\singleEasy");
            nStartAttack = 15; 
        }
        if(GetDifficultyLevel()==1)
        {
            pEnemy.LoadScript("single\\singleMedium");
            pEnemy.SetNumberOfOffensiveTankPlatoons(2);
            nStartAttack = 15; 
        }
        if(GetDifficultyLevel()==2)
        {
            pEnemy.LoadScript("single\\singleHard");
            nStartAttack = 15; 
        }
        
        //pEnemy.SetNumberOfOffensiveHelicopterPlatoons(0);
        //pEnemy.SetNumberOfDefensiveHelicopterPlatoons(0);
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        pEnemy.EnableAIFeatures(aiEnabled,true);
        pEnemy.EnableAIFeatures(aiControlOffense,false);
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        pEnemy.SetMoney(10000);
        //----------- Researches -------------
        pEnemy.EnableResearch("RES_ED_WCA2",true);  
        pEnemy.EnableResearch("RES_ED_MSC2",true);
        pEnemy.EnableResearch("RES_ED_UMT1",true);
        pEnemy.EnableResearch("RES_ED_UA12",true);
        pEnemy.EnableResearch("RES_ED_RepHand",true);
        
        pPlayer.EnableResearch("RES_UCS_WACH2",true);
        pPlayer.EnableResearch("RES_UCS_WSR1",true);
        pPlayer.EnableResearch("RES_MCH2",true);
        pPlayer.EnableResearch("RES_UCS_MG2",true);
        pPlayer.EnableResearch("RES_UCS_GARG1",true);
        //----------- Buildings --------------
        pPlayer.EnableBuilding("UCSBTE",false);
        pPlayer.EnableBuilding("UCSBEN1",false);
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,6000);
        SetTimer(2,nStartAttack*20*60);
        //----------- Variables --------------
        bShowFailed=true;
        bSwitchAI= true;
        bCheckEndMission=false;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing114");
        Snow(pPlayer.GetStartingPointX()-10,pPlayer.GetStartingPointY()+10,30,400,5000,800,10); 
        return Mining,100;
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(GetGoalState(findResource)!=goalAchieved && pPlayer.IsPointLocated(GetPointX(0),GetPointY(0),0))
        {
            SetGoalState(findResource, goalAchieved);
        }
        if(GetGoalState(sendToBase30000)!=goalAchieved && pPlayer.GetMoneySentToBase()>=30000)
        {
            SetGoalState(sendToBase30000, goalAchieved);
            AddBriefing("translateAccomplished114");
            EnableEndMissionButton(true);
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
        RegisterGoal(sendToBase30000,"translateGoalSend30000",pPlayer.GetMoneySentToBase());
        
        if(bSwitchAI && pPlayer.GetMoneySentToBase()>15000)
        {
            pEnemy.EnableAIFeatures(aiControlOffense,true);
            bSwitchAI=false;
        }
        if(bShowFailed)
        {
            if((ResourcesLeftInMoney()+pPlayer.GetMoneySentToBase()+pPlayer.GetMoney())<30000)
            {
                bShowFailed=false;
                SetGoalState(sendToBase30000, goalFailed);
                AddBriefing("translateFailed114a");
                EnableEndMissionButton(true);
                return Nothing;
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed114b");
                EndMission(false);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli 5min
    {
        Snow(pPlayer.GetStartingPointX()-10,pPlayer.GetStartingPointY()+10,30,400,5000,800,10); 
    }
    
    //-----------------------------------------------------------------------------------------
    event Timer2() //wolany co 6000 cykli 5min
    {
        pEnemy.EnableAIFeatures(aiControlOffense,true);    
    }
    
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit u_Unit)
    {
        if(bSwitchAI)
        {
            if(GetDifficultyLevel()!=0)
                pEnemy.EnableAIFeatures(aiControlOffense,true);
            bSwitchAI=false;
        }
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit u_Unit)
    { 
        if(bSwitchAI)
        {
            if(GetDifficultyLevel()!=0)
                pEnemy.EnableAIFeatures(aiControlOffense,true);
            bSwitchAI=false;
        }
        bCheckEndMission=true;
    }
}

