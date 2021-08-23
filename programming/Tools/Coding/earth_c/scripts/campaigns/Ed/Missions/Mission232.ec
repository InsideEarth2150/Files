mission "translateMission232"
{//Malou island
    consts
    {
        sendToBase = 0;
        nNeededResources=100000;    
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Enemy4;
    player p_Player;
    
    
    
    int bShowFailed;  
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Mining;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        int enemyStartingMoney;
        int playerStartingMoney;
        
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(3);
        p_Enemy3 = GetPlayer(4);
        p_Enemy4 = GetPlayer(5);
        
        RegisterGoal(sendToBase,"translateGoalSend100000",0);
        EnableGoal(sendToBase,true);
        
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy3.LoadScript("single\\singleEasy");
            p_Enemy4.LoadScript("single\\singleEasy");
            p_Enemy3.EnableAIFeatures(aiControlOffense,false);
            p_Enemy4.EnableAIFeatures(aiControlOffense,false);
            playerStartingMoney=30000;
            enemyStartingMoney=20000;
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Enemy3.LoadScript("single\\singleMedium");
            p_Enemy4.LoadScript("single\\singleMedium");
            playerStartingMoney=20000;
            enemyStartingMoney=30000;
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Enemy3.LoadScript("single\\singleHard");
            p_Enemy4.LoadScript("single\\singleHard");
            playerStartingMoney=10000;
            enemyStartingMoney=50000;
        }
        
        p_Player.SetMoney(playerStartingMoney);
        p_Enemy1.SetMoney(enemyStartingMoney);
        p_Enemy2.SetMoney(enemyStartingMoney);
        p_Enemy3.SetMoney(enemyStartingMoney);
        p_Enemy4.SetMoney(enemyStartingMoney);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiRush,false);
        p_Enemy2.EnableAIFeatures(aiRush,false);
        p_Enemy3.EnableAIFeatures(aiRush,false);
        p_Enemy4.EnableAIFeatures(aiRush,false);
        
        p_Enemy1.EnableResearch("RES_UCS_WASR1",true);
        p_Enemy1.EnableResearch("RES_UCS_WCH2",true);
        p_Enemy1.EnableResearch("RES_UCS_WSP1",true);
        p_Enemy1.EnableResearch("RES_UCS_WSG1",true);
        p_Enemy1.EnableResearch("RES_MCH2",true);
        p_Enemy1.EnableResearch("RES_MSR2",true);
        p_Enemy1.EnableResearch("RES_UCS_MG2",true);
        p_Enemy1.EnableResearch("RES_UCS_UML1",true);
        p_Enemy1.EnableResearch("RES_UCS_UHL1",true);
        p_Enemy1.EnableResearch("RES_UCS_BMD",true);
        p_Enemy1.EnableResearch("RES_UCS_BHD",true);
        
        p_Enemy3.CopyResearches(p_Enemy1);
        
        p_Enemy2.EnableResearch("RES_LC_WSR2",true);
        p_Enemy2.EnableResearch("RES_LC_WSS1",true);
        p_Enemy2.EnableResearch("RES_LC_WMR1",true);
        p_Enemy2.EnableResearch("RES_MSR2",true);
        p_Enemy2.EnableResearch("RES_LC_UCR1",true);
        p_Enemy2.EnableResearch("RES_LC_UBO1",true);
        p_Enemy2.EnableResearch("RES_LC_REG1",true);
        p_Enemy2.EnableResearch("RES_LC_SGEN",true);
        p_Enemy2.EnableResearch("RES_LC_SHR1",true);
        p_Enemy2.EnableResearch("RES_LC_BWC",true);
        
        p_Enemy4.CopyResearches(p_Enemy2);
        
        p_Player.EnableResearch("RES_ED_WMR1",true);
        p_Player.EnableResearch("RES_MSR2",true);
        p_Player.EnableResearch("RES_ED_UHW1",true);
        p_Player.EnableResearch("RES_ED_BHD",true);
        
        SetTimer(0,100);
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        bShowFailed=true;
        bCheckEndMission=false;
        p_Player.SetMilitaryUnitsLimit(20000);  
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing232",nNeededResources);
        EnableNextMission(0,true);
        EnableNextMission(1,true);
        EnableNextMission(2,true);
        return Mining,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(GetGoalState(sendToBase)!=goalAchieved && p_Player.GetMoneySentToBase()>=nNeededResources)
        {
            SetGoalState(sendToBase, goalAchieved);
            AddBriefing("translateAccomplished232");
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
        RegisterGoal(sendToBase,"translateGoalSend100000",p_Player.GetMoneySentToBase());
        
        if(bShowFailed)
        {
            if((ResourcesLeftInMoney()+p_Player.GetMoney()+p_Player.GetMoneySentToBase())<nNeededResources)
            {
                bShowFailed=false;
                SetGoalState(sendToBase, goalFailed);
                AddBriefing("translateFailed232a");
                EnableEndMissionButton(true);
                return Nothing;
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed232b");
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

