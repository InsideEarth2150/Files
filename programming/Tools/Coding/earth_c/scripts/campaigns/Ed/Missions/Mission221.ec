mission "translateMission221"
{//Laser weapon tests
    consts
    {
        destroyDummies = 0;
        destroyEnemy = 1;
    }
    
    player p_Enemy;
    player p_Player;
    player p_Dummy;
    player p_Neutral;
    
    state Initialize;
    state ShowBriefing;
    state DestroyDummies;
    state DestroyEnemy;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        
        
        RegisterGoal(destroyDummies,"translateGoal221a");
        RegisterGoal(destroyEnemy,"translateGoal221b");
        EnableGoal(destroyDummies,true);           
        
        p_Player = GetPlayer(2);
        p_Enemy = GetPlayer(3);
        p_Dummy = GetPlayer(4);
        p_Neutral = GetPlayer(8);
        p_Player.SetMoney(0);
        p_Enemy.SetMoney(0);
        p_Dummy.SetMoney(0);
        p_Neutral.SetMoney(0);
        
        p_Neutral.EnableStatistics(false);
        p_Dummy.EnableStatistics(false);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy.LoadScript("single\\singleEasy");
            p_Enemy.SetMoney(15000);
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.LoadScript("single\\singleMedium");
            p_Enemy.SetMoney(30000);
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
            p_Enemy.SetMoney(50000);
        }
        
        p_Enemy.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Dummy.EnableAIFeatures(aiEnabled,false);
        
        p_Dummy.SetNeutral(p_Player);
        p_Dummy.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Player);
        p_Neutral.SetNeutral(p_Dummy);
        p_Player.SetNeutral(p_Neutral);
        
        p_Enemy.SetPointToAssemble(0,GetPointX(0),GetPointY(0),0);
        p_Enemy.SetPointToAssemble(1,GetPointX(1),GetPointY(1),0);
        p_Enemy.SetPointToAssemble(2,GetPointX(2),GetPointY(2),0);
        
        p_Enemy.EnableResearch("RES_LC_WSR2",true);
        p_Enemy.EnableResearch("RES_LC_REG1",true);
        
        
        p_Player.EnableBuilding("EDBRA",false);
        
        SetTimer(0,100);
        ShowArea(4,GetPointX(5),GetPointY(5),0,1);
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    state ShowBriefing
    {
        AddBriefing("translateBriefing221a");
        EnableNextMission(0,true);
        EnableNextMission(1,true);
        return DestroyDummies,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state DestroyDummies
    {
        if(!p_Dummy.GetNumberOfUnits())
        {
            
            p_Neutral.GiveAllUnitsTo(p_Player);
            p_Neutral.GiveAllBuildingsTo(p_Player);
            p_Player.EnableResearch("RES_ED_WSL1",true);
            SetGoalState(destroyDummies, goalAchieved);
            EnableGoal(destroyEnemy,true);
            AddBriefing("translateBriefing221b");
            p_Player.SetMoney(20000);
            p_Enemy.EnableAIFeatures(aiEnabled,true);
            return DestroyEnemy,200; 
        }
        return DestroyDummies,100;
    }
    //-----------------------------------------------------------------------------------------
    state DestroyEnemy
    {
        
        if(p_Enemy.GetNumberOfUnits()<10 && !p_Enemy.GetNumberOfBuildings())
        {
            SetGoalState(destroyEnemy, goalAchieved);
            AddBriefing("translateAccomplished221");
            EnableEndMissionButton(true);
            return Evacuate;
        }
        return DestroyEnemy,100;
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        return Evacuate,500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed221");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_Dummy.SetEnemy(p_Player);
        p_Dummy.SetEnemy(p_Neutral);
        p_Neutral.SetEnemy(p_Player);
        p_Neutral.SetEnemy(p_Dummy);
        p_Player.SetEnemy(p_Neutral);
    }
}
