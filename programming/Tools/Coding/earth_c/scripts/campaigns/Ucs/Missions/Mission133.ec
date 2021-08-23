mission "translateMission133"
{
    consts
    {
        destroyEnemy = 0;
        defendMainBase1 = 1; 
        defendMainBase2 = 2; 
        defendMainBase3 = 3; 
    }
    
    player pEnemy1;
    player pEnemy2;
    player pEnemy3;
    player pPlayer;
    
    unitex uMainBase1;
    unitex uMainBase2;
    unitex uMainBase3;
    
    int bCheckEndMission;
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(destroyEnemy,"translateGoal133a");
        RegisterGoal(defendMainBase1,"translateGoal133b");
        RegisterGoal(defendMainBase2,"translateGoal133c");
        RegisterGoal(defendMainBase3,"translateGoal133d");
        EnableGoal(destroyEnemy,true);
        EnableGoal(defendMainBase1,true);
        EnableGoal(defendMainBase2,true);
        EnableGoal(defendMainBase3,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(1);
        pEnemy1 = GetPlayer(2);
        pEnemy2 = GetPlayer(4);
        pEnemy3 = GetPlayer(5);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            pEnemy1.LoadScript("single\\singleEasy");
            pEnemy2.LoadScript("single\\singleEasy");
            pEnemy3.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            pEnemy1.LoadScript("single\\singleMedium");
            pEnemy2.LoadScript("single\\singleMedium");
            pEnemy3.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            pEnemy1.LoadScript("single\\singleHard");
            pEnemy2.LoadScript("single\\singleHard");
            pEnemy3.LoadScript("single\\singleHard");
        }
        
        pEnemy1.EnableAIFeatures(aiControlOffense,false);
        pEnemy1.EnableAIFeatures(aiControlDefense,false);
        pEnemy2.EnableAIFeatures(aiControlOffense,false);
        pEnemy2.EnableAIFeatures(aiControlDefense,false);
        pEnemy3.EnableAIFeatures(aiControlOffense,false);
        pEnemy3.EnableAIFeatures(aiControlDefense,false);
        
        pEnemy1.SetNeutral(pEnemy2);
        pEnemy1.SetNeutral(pEnemy3);
        pEnemy2.SetNeutral(pEnemy1);
        pEnemy2.SetNeutral(pEnemy3);
        pEnemy3.SetNeutral(pEnemy1);
        pEnemy3.SetNeutral(pEnemy2);
        pPlayer.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        pEnemy1.SetMoney(20000);
        pEnemy2.SetMoney(20000);
        pEnemy3.SetMoney(20000);
        //----------- Researches -------------
        pEnemy1.EnableResearch("RES_ED_WMR1",true); 
        pEnemy1.EnableResearch("RES_MSR2",true);    
        pEnemy1.EnableResearch("RES_ED_UHW1",true);
        pEnemy1.EnableResearch("RES_ED_BHD",true);
        
        pEnemy2.CopyResearches(pEnemy1);
        pEnemy3.CopyResearches(pEnemy1);
        
        pPlayer.EnableResearch("RES_UCS_WHG1",true);
        pPlayer.EnableResearch("RES_UCS_UHL1",true);
        pPlayer.EnableResearch("RES_UCS_BHD",true);
        //----------- Buildings --------------
        pPlayer.EnableBuilding("UCSBTE",false);
        //----------- Units ------------------
        uMainBase1 = GetUnit(GetPointX(0),GetPointY(0),0);
        uMainBase2 = GetUnit(GetPointX(1),GetPointY(1),0);
        uMainBase3 = GetUnit(GetPointX(2),GetPointY(2),0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,1200);
        //----------- Variables --------------
        bCheckEndMission=false;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing133");
        return Fighting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            
            if(GetGoalState(defendMainBase1)!=goalFailed && !uMainBase1.IsLive())
                SetGoalState(defendMainBase1,goalFailed);
            
            if(GetGoalState(defendMainBase2)!=goalFailed && !uMainBase2.IsLive())
                SetGoalState(defendMainBase2,goalFailed);
            
            if(GetGoalState(defendMainBase3)!=goalFailed && !uMainBase3.IsLive())
                SetGoalState(defendMainBase3,goalFailed);
            
            if(!pEnemy1.GetNumberOfUnits() && !pEnemy1.GetNumberOfBuildings() &&
                !pEnemy2.GetNumberOfUnits() && !pEnemy2.GetNumberOfBuildings() &&
                !pEnemy3.GetNumberOfUnits() && !pEnemy3.GetNumberOfBuildings())
            {
                SetGoalState(destroyEnemy,goalAchieved);
            }
            
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed133");
                EndMission(false);
            }
            if(GetGoalState(defendMainBase1)==goalFailed &&
                GetGoalState(defendMainBase2)==goalFailed &&
                GetGoalState(defendMainBase2)==goalFailed 
                )
            {
                AddBriefing("translateFailed133");
                EnableEndMissionButton(true,false);
                return Nothing,500;
            }
        }
        if(GetGoalState(destroyEnemy)==goalAchieved)
        {
            if(GetGoalState(defendMainBase1)!=goalFailed)
                SetGoalState(defendMainBase1,goalAchieved);
            if(GetGoalState(defendMainBase2)!=goalFailed)
                SetGoalState(defendMainBase2,goalAchieved);
            if(GetGoalState(defendMainBase3)!=goalFailed)
                SetGoalState(defendMainBase3,goalAchieved);
            AddBriefing("translateAccomplished133");
            EnableEndMissionButton(true);
            return Nothing,500;
        }
        return Fighting,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0()
    {
        pEnemy1.RussianAttack(GetPointX(0),GetPointY(0),0);
        pEnemy2.RussianAttack(GetPointX(1),GetPointY(1),0);
        pEnemy3.RussianAttack(GetPointX(2),GetPointY(2),0);
    }
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit uUnit)
    {
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit uUnit)
    { 
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        pEnemy1.SetEnemy(pEnemy2);
        pEnemy1.SetEnemy(pEnemy3);
        pEnemy2.SetEnemy(pEnemy1);
        pEnemy2.SetEnemy(pEnemy3);
        pEnemy3.SetEnemy(pEnemy1);
        pEnemy3.SetEnemy(pEnemy2);
    }
}

