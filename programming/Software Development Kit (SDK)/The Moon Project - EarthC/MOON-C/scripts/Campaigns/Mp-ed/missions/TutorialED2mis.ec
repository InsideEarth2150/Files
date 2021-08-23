mission "translateTutorialED2"
{
    consts
    {
        sellUnits = 0;
        sellBuildings = 1;
        captureUnits = 2;
        captureBuilding1 = 3;
        captureBuilding2 = 4;
    }
    player p_Player;
    player p_Dummy1;
    player p_Dummy2;
    player p_Enemy;
    
    //***********************************************************  
    state Initialize;
    state Start;
    state SellUnits;
    state SellBuilding;
    state Wait1;
    state CaptureUnits;
    state Wait2;
    state CaptureBuilding;
    state EndState;
    
    state Initialize
    {
        RegisterGoal(sellUnits,"translateGoalTutorialED2_1");
        RegisterGoal(sellBuildings,"translateGoalTutorialED2_2");
        RegisterGoal(captureUnits,"translateGoalTutorialED2_3");
        RegisterGoal(captureBuilding1,"translateGoalTutorialED2_4");
        RegisterGoal(captureBuilding2,"translateGoalTutorialED2_5");
        
        p_Player = GetPlayer(2);
        p_Dummy1 = GetPlayer(3);
        p_Dummy2 = GetPlayer(4);
        p_Enemy = GetPlayer(1);

        p_Player.EnableStatistics(false);
        p_Dummy1.EnableStatistics(false);
        p_Dummy2.EnableStatistics(false);
        p_Enemy.EnableStatistics(false);

        p_Dummy1.SetNeutral(p_Enemy);
        p_Dummy2.SetNeutral(p_Enemy);

        p_Player.SetMoney(0);
        
        p_Player.EnableAI(false);           
        p_Dummy1.EnableAI(false);           
        p_Dummy2.EnableAI(false);           
        p_Enemy.EnableAI(false);           
        
        EnableGameFeature(lockResearchDialog,true);
        EnableGameFeature(lockConstructionDialog,true);
        EnableGameFeature(lockUpgradeWeaponDialog,true);
        p_Player.EnableCommand(commandAutodestruction,false);

        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return Start,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Start
    {
        EnableGoal(sellUnits,true);
        AddBriefing("translateTutorialED2_1");
        return SellUnits;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state SellUnits
    {
        if(!p_Player.GetNumberOfUnits())
        {
            EnableGoal(sellBuildings,true);
            SetGoalState(sellUnits,goalAchieved);
            p_Player.EnableCommand(commandSoldBuilding,true);
            AddBriefing("translateTutorialED2_2");
            return SellBuilding;
        }
        return SellUnits;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state SellBuilding
    {
        unitex u_Tmp;
        if(!p_Player.GetNumberOfBuildings())
        {
            SetGoalState(sellBuildings,goalAchieved);
            return Wait1,40;
        }
        return SellBuilding;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Wait1
    {
        unitex u_Tmp;
        EnableGoal(captureUnits,true);
        EnableGoal(captureBuilding1,true);
        AddBriefing("translateTutorialED2_3");
        p_Player.EnableCommand(commandSoldBuilding,false);
        p_Dummy1.GiveAllUnitsTo(p_Player);
        u_Tmp=GetUnit(GetPointX(0),GetPointY(0),0);
        u_Tmp.LoadScript("Scripts\\Units\\Tank.ecomp");
        u_Tmp=GetUnit(GetPointX(0)-1,GetPointY(0),0);
        u_Tmp.LoadScript("Scripts\\Units\\Repairer.ecomp");
        LookAt(GetPointX(0),GetPointY(0),6,0,20,0,0);
        return CaptureUnits;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state CaptureUnits
    {

        if(p_Player.GetNumberOfUnits()==5)
        {
            SetGoalState(captureUnits,goalAchieved);
        }
        if(p_Player.GetNumberOfBuildings()>1)
        {
            SetGoalState(captureBuilding1,goalAchieved);
        }
        if(GetGoalState(captureUnits)==goalAchieved &&
           GetGoalState(captureBuilding1)==goalAchieved)
        {
            return Wait2,40;
        }
        return CaptureUnits;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Wait2
    {
        unitex u_Tmp;
        p_Player.GiveAllUnitsTo(p_Dummy1);
        p_Player.GiveAllBuildingsTo(p_Dummy1);
        p_Dummy2.GiveAllUnitsTo(p_Player);
        
        u_Tmp=GetUnit(GetPointX(1),GetPointY(1),0);
        u_Tmp.LoadScript("Scripts\\Units\\Repairer.ecomp");
        
        LookAt(GetPointX(1),GetPointY(1),6,0,20,0,0);

        EnableGoal(captureBuilding2,true);
        AddBriefing("translateTutorialED2_4");
        return CaptureBuilding;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state CaptureBuilding
    {
        if(p_Player.GetNumberOfBuildings()>1)
        {
            SetGoalState(captureBuilding2,goalAchieved);
            AddBriefing("translateTutorialED2_5");
            return EndState,500;
        }
        return CaptureBuilding;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state EndState
    {
        return EndState,500;
    }
    //-------------------------------------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        return false;
    }
}