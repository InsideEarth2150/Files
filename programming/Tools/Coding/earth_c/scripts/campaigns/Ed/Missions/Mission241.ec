mission "translateMission241"
{//Panama
    consts
    {
        sendToBase = 0;
        nNeededResources=50000;    
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Player;
    
    int bShowFailed;  
    int bCheckEndMission;
    int bStartOffense;
    int bBlowUpTheBridge;
    state Initialize;
    state ShowBriefing;
    state Mining;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        int enemyStartingMoney;
        int playerStartingMoney;
        player tmpPlayer;
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(4);
        p_Enemy3 = GetPlayer(5);
        
        
        RegisterGoal(sendToBase,"translateGoalSend50000",0);
        EnableGoal(sendToBase,true);
        
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy3.LoadScript("single\\singleEasy");
            playerStartingMoney=30000;
            enemyStartingMoney=20000;
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Enemy3.LoadScript("single\\singleEasy");
            playerStartingMoney=20000;
            enemyStartingMoney=30000;
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Enemy3.LoadScript("single\\singleMedium");
            playerStartingMoney=10000;
            enemyStartingMoney=50000;
        }
        
        p_Player.SetMoney(playerStartingMoney);
        p_Enemy1.SetMoney(enemyStartingMoney);
        p_Enemy2.SetMoney(enemyStartingMoney);
        p_Enemy3.SetMoney(enemyStartingMoney);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiRush,false);
        p_Enemy2.EnableAIFeatures(aiRush,false);
        p_Enemy3.EnableAIFeatures(aiRush,false);
        
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy3.EnableAIFeatures(aiControlOffense,false);
        
        p_Enemy1.EnableResearch("RES_UCS_WHP1",true);
        p_Enemy1.EnableResearch("RES_UCS_UBS1",true);
        p_Enemy1.EnableResearch("RES_UCS_USM1",true);
        p_Enemy1.EnableResearch("RES_UCS_UMI1",true);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        p_Enemy3.CopyResearches(p_Enemy1);
        
        p_Player.EnableResearch("RES_ED_WHL1",true);
        p_Player.EnableResearch("RES_MMR2",true);
        p_Player.EnableResearch("RES_ED_UHT1",true);
        p_Player.EnableResearch("RES_ED_UHS1",true);
        
        bStartOffense=true;
        bBlowUpTheBridge=true;
        
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
        ShowArea(4,p_Enemy2.GetStartingPointX(),p_Enemy2.GetStartingPointY(),0,2);
        AddBriefing("translateBriefing241",nNeededResources);
        return Mining,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(bBlowUpTheBridge && p_Player.IsPointLocated(GetPointX(1),GetPointY(1),0))
        {
            bBlowUpTheBridge=false;
            //        IFFmask,x,y,z,range
            KillArea(65535,GetPointX(0),GetPointY(0),0,4);
        } 
        
        if(bStartOffense && p_Player.GetMoneySentToBase()>=10000)
        {
            p_Enemy1.EnableAIFeatures(aiControlOffense,true);
            p_Enemy2.EnableAIFeatures(aiControlOffense,true);
            bStartOffense=false;
        }
        if(GetGoalState(sendToBase)!=goalAchieved && p_Player.GetMoneySentToBase()>=nNeededResources)
        {
            SetGoalState(sendToBase, goalAchieved);
            AddBriefing("translateAccomplished241");
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
        RegisterGoal(sendToBase,"translateGoalSend50000",p_Player.GetMoneySentToBase());
        
        if(bShowFailed)
        {
            if((ResourcesLeftInMoney()+p_Player.GetMoney()+p_Player.GetMoneySentToBase())<nNeededResources)
            {
                bShowFailed=false;
                SetGoalState(sendToBase, goalFailed);
                AddBriefing("translateFailed241a");
                EnableEndMissionButton(true);
                return Nothing;
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed241b");
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

