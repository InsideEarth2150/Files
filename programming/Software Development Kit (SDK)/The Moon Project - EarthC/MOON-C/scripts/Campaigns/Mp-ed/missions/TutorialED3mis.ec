mission "translateLesson4"
{
    consts
    {
        goalBringGruz = 0;
        goalBringCash = 1;
        
    }
    player p_Player;
    
    //***********************************************************  
    state Initialize;
    state Start;
    state Start2;
    state Working;
    state EndState;
    
    state Initialize
    {
        RegisterGoal(goalBringGruz,"translateGoalTutorialED3_4");
        RegisterGoal(goalBringCash,"translateGoalTutorialED3_5");
        
        p_Player=GetPlayer(1);
            if(p_Player!=null)p_Player.EnableStatistics(false);
        p_Player=GetPlayer(3);
            if(p_Player!=null)p_Player.EnableStatistics(false);
    
        p_Player = GetPlayer(2);
        p_Player.SetMoney(0);
        p_Player.EnableAI(false);           
        
        EnableGameFeature(lockResearchDialog,true);
        EnableGameFeature(lockConstructionDialog,true);
        EnableGameFeature(lockUpgradeWeaponDialog,true);
        p_Player.EnableCommand(commandAutodestruction,false);
        p_Player.EnableCommand(commandSoldBuilding,false);

        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        p_Player.SetScriptData(1,1);
        return Start,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Start
    {
        AddBriefing("translateTutorialED3_4");
        return Start2,400;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Start2
    {
        EnableGoal(goalBringGruz,true);
        EnableGoal(goalBringCash,true);
        AddBriefing("translateTutorialED3_5");
        return Working;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Working
    {
        if(p_Player.GetNumberOfUnits()>0)
            SetGoalState(goalBringGruz,goalAchieved);
        if(p_Player.GetMoney()>=5000)
            SetGoalState(goalBringCash,goalAchieved);
        
        if(GetGoalState(goalBringGruz)==goalAchieved &&
           GetGoalState(goalBringCash)==goalAchieved)
        {
            EnableEndMissionButton(true);
            AddBriefing("translateTutorialED3_6");
            return EndState,500;
        }
        return Working;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state EndState
    {
        return EndState,500;
    }
     //-----------------------------------------------------------------------------------------
    event EndMission() 
    {
        p_Player.SetScriptData(2,1);
    }
}