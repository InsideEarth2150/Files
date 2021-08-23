mission "translateMission272"
{
    consts
    {
        sendToBase = 0;
        
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Player;
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
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(3);
        
        fleetCost = p_Player.GetScriptData(0);
        nNeedeResources = fleetCost - p_Player.GetMoneySentToOrbit();
        
        if(nNeedeResources > 100000)
            nNeedeResources=100000;
        RegisterGoal(sendToBase,"translateGoal272",nNeedeResources,0);
        EnableGoal(sendToBase,true);
        
        p_Player.SetMoney(10000);
        p_Enemy1.SetMoney(50000);
        p_Enemy2.SetMoney(50000);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
        }
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiEnabled,true);
        p_Enemy2.EnableAIFeatures(aiEnabled,true);
        
        //weapons
        p_Enemy2.EnableResearch("RES_LC_WCH2",true);
        p_Enemy2.EnableResearch("RES_LC_WSR2",true);
        p_Enemy2.EnableResearch("RES_LC_WMR1",true);
        p_Enemy2.EnableResearch("RES_LC_WSL1",true);
        p_Enemy2.EnableResearch("RES_LC_WHL1",true);
        p_Enemy2.EnableResearch("RES_LC_WSS1",true);
        p_Enemy2.EnableResearch("RES_LC_WHS1",true);
        p_Enemy2.EnableResearch("RES_LC_WARTILLERY",true);
        //CHASSIS
        p_Enemy2.EnableResearch("RES_LC_UMO2",true);
        p_Enemy2.EnableResearch("RES_LC_UCR1",true);
        p_Enemy2.EnableResearch("RES_LC_UCU1",true);
        p_Enemy2.EnableResearch("RES_LC_UME1",true);
        p_Enemy2.EnableResearch("RES_LC_UBO1",true);
        //SPECIAL
        p_Enemy2.EnableResearch("RES_LC_BWC",true);
        p_Enemy2.EnableResearch("RES_LC_SGen",true);
        p_Enemy2.EnableResearch("RES_LC_SHR1",true);
        p_Enemy2.EnableResearch("RES_LC_REG1",true);
        p_Enemy2.EnableResearch("RES_LC_SOB1",true);
        //AMMO
        p_Enemy2.EnableResearch("RES_MCH2",true);
        p_Enemy2.EnableResearch("RES_MSR2",true);
        p_Enemy2.EnableResearch("RES_MMR2",true);
        
        SetTimer(0,100);
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        bShowFailed=true;
        bCheckEndMission=false;
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing272",nNeedeResources);
        return Mining,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(GetGoalState(sendToBase)!=goalAchieved && p_Player.GetMoneySentToBase()>=nNeedeResources)
        {
            SetGoalState(sendToBase, goalAchieved);
            AddBriefing("translateAccomplished272");
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
        RegisterGoal(sendToBase,"translateGoal272",nNeedeResources,p_Player.GetMoneySentToBase());
        
        if(bShowFailed)
        {
            if((ResourcesLeftInMoney()+p_Player.GetMoney()+p_Player.GetMoneySentToBase())<20000)
            {
                bShowFailed=false;
                SetGoalState(sendToBase, goalFailed);
                AddBriefing("translateFailed272a");
                EnableEndMissionButton(true);
                return Nothing;
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed272b");
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

