mission "translateMission265"
{//Andas - destroy ucs base
    consts
    {
        destroyEnemyBase = 0;
    }
    player p_Enemy;
    player p_Player;
    
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        RegisterGoal(destroyEnemyBase,"translateGoal265");
        EnableGoal(destroyEnemyBase,true);           
        
        
        p_Player = GetPlayer(2);
        p_Enemy = GetPlayer(1);
        
        
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy.LoadScript("single\\singleEasy");
            p_Enemy.EnableAIFeatures(aiUpgradeCannons,false);
            p_Player.SetMoney(30000);
            p_Enemy.SetMoney(20000);
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.LoadScript("single\\singleMedium");
            p_Player.SetMoney(20000);
            p_Enemy.SetMoney(30000);
        }
        
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
            p_Enemy.CreateDefaultUnit(p_Enemy.GetStartingPointX(),p_Enemy.GetStartingPointY(),0);
            p_Player.SetMoney(15000);
            p_Enemy.SetMoney(50000);
        }
        p_Player.EnableResearch("RES_ED_AB1",true);
        p_Player.EnableResearch("RES_ED_WHR1",true);
        p_Player.EnableResearch("RES_ED_MB2",true);
        p_Player.EnableResearch("RES_ED_MHR2",true);
        p_Player.EnableResearch("RES_ED_UA31",true);
        p_Player.EnableResearch("RES_ED_UBT1",true);
        
        p_Enemy.EnableResearch("RES_UCS_PC",true);
        p_Enemy.EnableResearch("RES_UCS_WSD",true);
        p_Enemy.EnableResearch("RES_UCS_MB2",true);
        p_Enemy.EnableResearch("RES_UCS_BOMBER31",true);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        SetTimer(0,100);
        bCheckEndMission=false;
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        p_Player.SetMilitaryUnitsLimit(40000);  
        return ShowBriefing,100;
    }
    state ShowBriefing
    {
        AddBriefing("translateBriefing265");
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
                AddBriefing("translateFailed265");
                EndMission(false);
            }
            if(GetGoalState(destroyEnemyBase)!=goalAchieved && 
                (p_Enemy.GetNumberOfUnits()<6) && 
                !p_Enemy.GetNumberOfBuildings())
            {
                SetGoalState(destroyEnemyBase, goalAchieved);
                EnableNextMission(0,true);
                EnableNextMission(1,true);
                EnableNextMission(2,true);
                AddBriefing("translateAccomplished265");
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
