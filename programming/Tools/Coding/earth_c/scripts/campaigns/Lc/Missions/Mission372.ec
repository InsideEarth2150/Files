mission "translateMission372"
{
    consts
    {
        sendToBase = 0;
        
    }
    
    player pEnemy1;
    player pEnemy2;
    player pPlayer;
    int bShitchOnAI;
    int nNeedeResources;
    int fleetCost;
    int bShowFailed;  
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Mining;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        pPlayer = GetPlayer(3);
        fleetCost = pPlayer.GetScriptData(0);
        nNeedeResources = fleetCost - pPlayer.GetMoneySentToOrbit();
        if(nNeedeResources > 100000)
            nNeedeResources=100000;
        
        RegisterGoal(sendToBase,"translateGoal372",nNeedeResources,0);
        EnableGoal(sendToBase,true);
        //----------- Temporary players ------
        //----------- Players ----------------
        
        pEnemy1 = GetPlayer(1);
        pEnemy2 = GetPlayer(2);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            pEnemy1.LoadScript("single\\singleEasy");
            pEnemy2.LoadScript("single\\singleEasy");
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
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        pEnemy1.EnableAIFeatures(aiEnabled,true);
        pEnemy2.EnableAIFeatures(aiEnabled,true);
        //----------- Money ------------------
        pPlayer.SetMoney(20000);
        pEnemy1.SetMoney(150000);
        pEnemy2.SetMoney(150000);
        //----------- Researches -------------
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bShowFailed=true;
        bCheckEndMission=false;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing372",pPlayer.GetName(),nNeedeResources);
        return Mining,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(GetGoalState(sendToBase)!=goalAchieved && pPlayer.GetMoneySentToBase()>=nNeedeResources)
        {
            SetGoalState(sendToBase, goalAchieved);
            AddBriefing("translateAccomplished372",pPlayer.GetName());
            EnableEndMissionButton(true);
            return Nothing, 500;
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
        RegisterGoal(sendToBase,"translateGoal372",nNeedeResources,pPlayer.GetMoneySentToBase());
        
        if(bShowFailed)
        {
            if((ResourcesLeftInMoney()+pPlayer.GetMoneySentToBase()+pPlayer.GetMoney())<nNeedeResources)
            {
                bShowFailed=false;
                SetGoalState(sendToBase, goalFailed);
                AddBriefing("translateFailed372a",pPlayer.GetName());
                EnableEndMissionButton(true);
                return Nothing;
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed372b",pPlayer.GetName());
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
}

