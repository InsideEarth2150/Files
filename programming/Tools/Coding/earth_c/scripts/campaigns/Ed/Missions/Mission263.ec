mission "translateMission263"
{//Algier - destroy UCS water base
    consts
    {
        destroyEnemy1Base = 0;
        destroyEnemy2Base = 1;
    }
    player p_Enemy1;
    player p_Enemy2;
    player p_Player;
    
    int bCheckEndMission;
    int bShowEnd;
    
    state Initialize;
    state ShowBriefing;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        RegisterGoal(destroyEnemy1Base,"translateGoal263a");
        RegisterGoal(destroyEnemy2Base,"translateGoal263b");
        EnableGoal(destroyEnemy1Base,true);           
        EnableGoal(destroyEnemy2Base,true);           
        
        
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(4);
        
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy1.EnableAIFeatures(aiUpgradeCannons,false);
            p_Enemy2.EnableAIFeatures(aiUpgradeCannons,false);
            p_Player.SetMoney(30000);
            p_Enemy1.SetMoney(20000);
            p_Enemy2.SetMoney(20000);
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Player.SetMoney(20000);
            p_Enemy1.SetMoney(30000);
            p_Enemy2.SetMoney(30000);
        }
        
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Player.SetMoney(15000);
            p_Enemy1.SetMoney(50000);
            p_Enemy2.SetMoney(50000);
        }
        
        p_Player.EnableResearch("RES_ED_AB1",true);
        p_Player.EnableResearch("RES_ED_WHR1",true);
        p_Player.EnableResearch("RES_ED_MB2",true);
        p_Player.EnableResearch("RES_ED_MHR2",true);
        p_Player.EnableResearch("RES_ED_UA31",true);
        p_Player.EnableResearch("RES_ED_UBT1",true);
        
        p_Enemy1.EnableResearch("RES_UCS_PC",true);
        p_Enemy1.EnableResearch("RES_UCS_WSD",true);
        p_Enemy1.EnableResearch("RES_UCS_MB2",true);
        p_Enemy1.EnableResearch("RES_UCS_BOMBER31",true);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        SetTimer(0,100);
        bCheckEndMission=false;
        bShowEnd=true;
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        p_Player.SetMilitaryUnitsLimit(40000);  
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing263");
        return Nothing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    { 
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
                AddBriefing("translateFailed263");
                EndMission(false);
            }
            if(GetGoalState(destroyEnemy1Base)!=goalAchieved && 
                (p_Enemy1.GetNumberOfUnits()<6) && 
                !p_Enemy1.GetNumberOfBuildings())
            {
                SetGoalState(destroyEnemy1Base, goalAchieved);
            }
            if(GetGoalState(destroyEnemy2Base)!=goalAchieved && 
                (p_Enemy2.GetNumberOfUnits()<6) && 
                !p_Enemy2.GetNumberOfBuildings())
            {
                SetGoalState(destroyEnemy2Base, goalAchieved);
            }
            if(bShowEnd &&
                GetGoalState(destroyEnemy1Base)==goalAchieved && 
                GetGoalState(destroyEnemy2Base)==goalAchieved)
            {
                bShowEnd=false;
                EnableNextMission(0,true);
                EnableNextMission(1,true);
                EnableNextMission(2,true);
                AddBriefing("translateAccomplished263");
                EnableEndMissionButton(true);
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
}
