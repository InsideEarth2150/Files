mission "translateMission222"
{//Destroy UCS research facility
    consts
    {
        recoverComputerData=0;
        destroyResearchFacility = 1;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_GoalEnemy;
    player p_Player;
    
    state Initialize;
    state ShowBriefing;
    state RecoverComputerData;
    state DestroyResearchFacility;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        RegisterGoal(recoverComputerData,"translateGoal222a");
        RegisterGoal(destroyResearchFacility,"translateGoal222b");
        EnableGoal(recoverComputerData,true);           
        
        //                   name          x,y,z, nr,typ
        CreateArtefact("NEASPECIAL2",GetPointX(0),GetPointY(0),1,0,artefactSpecialAIOther);
        
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(5);
        p_GoalEnemy = GetPlayer(4);
        
        p_Player.SetMoney(20000);
        p_Enemy1.SetMoney(20000);
        p_Enemy2.SetMoney(20000);
        p_GoalEnemy.SetMoney(20000);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        
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
        p_GoalEnemy.LoadScript("single\\singleEasy");
        
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_GoalEnemy.EnableAIFeatures(aiControlOffense,false);
        
        p_GoalEnemy.SetMaxTankPlatoonSize(3);
        p_GoalEnemy.SetMaxShipPlatoonSize(4);
        
        p_GoalEnemy.SetNumberOfOffensiveTankPlatoons(0);
        p_GoalEnemy.SetNumberOfOffensiveShipPlatoons(0);
        p_GoalEnemy.SetNumberOfOffensiveHelicopterPlatoons(0);
        
        p_GoalEnemy.SetNumberOfDefensiveTankPlatoons(3);
        p_GoalEnemy.SetNumberOfDefensiveShipPlatoons(0);
        p_GoalEnemy.SetNumberOfDefensiveHelicopterPlatoons(0);
        
        p_Enemy1.SetNeutral(p_Enemy2);
        p_Enemy2.SetNeutral(p_Enemy1);
        
        p_Enemy1.SetPointToAssemble(0,GetPointX(1),GetPointY(1),0);
        p_Enemy1.SetPointToAssemble(1,GetPointX(2),GetPointY(2),0);
        p_Enemy2.SetPointToAssemble(0,GetPointX(3),GetPointY(3),0);
        p_Enemy2.SetPointToAssemble(1,GetPointX(4),GetPointY(4),0);
        
        ShowArea(4,p_GoalEnemy.GetStartingPointX(),p_GoalEnemy.GetStartingPointY(),0,2);
        ShowArea(4,p_Enemy1.GetStartingPointX(),p_Enemy1.GetStartingPointY(),0,2);
        ShowArea(4,p_Enemy2.GetStartingPointX(),p_Enemy2.GetStartingPointY(),0,2);
        
        p_Enemy1.EnableResearch("RES_UCS_WASR1",true);
        p_Enemy1.EnableResearch("RES_UCS_WCH2",true);
        p_Enemy1.EnableResearch("RES_MCH2",true);
        p_Enemy1.EnableResearch("RES_UCS_UOH2",true);
        p_Enemy1.EnableResearch("RES_UCS_RepHand",true);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        p_GoalEnemy.CopyResearches(p_Enemy1);
        
        p_Player.EnableResearch("RES_ED_UMW1",true);
        p_Player.EnableResearch("RES_ED_USS2",true);
        p_Player.EnableResearch("RES_ED_UA21",true);
        
        p_Player.EnableBuilding("EDBRA",false);
        
        SetTimer(0,200);
        
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing222a");
        EnableNextMission(0,true);
        EnableNextMission(1,true);
        return RecoverComputerData,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state RecoverComputerData
    {
        if(GetGoalState(recoverComputerData)==goalAchieved)
        {
            return DestroyResearchFacility,200; 
        }
        return RecoverComputerData,100;
    }
    //-----------------------------------------------------------------------------------------
    state DestroyResearchFacility
    {
        if(!p_GoalEnemy.GetNumberOfBuildings(buildingResearchCenter))
        {
            p_Player.EnableBuilding("EDBTC",true);
            SetGoalState(destroyResearchFacility, goalAchieved);
            AddBriefing("translateAccomplished222");
            EnableEndMissionButton(true);
            return Evacuate,500;
        }
        return DestroyResearchFacility,100;
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        return Evacuate,500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0()
    {
        if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed222");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_Enemy1.SetEnemy(p_Enemy2);
        p_Enemy2.SetEnemy(p_Enemy1);
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        p_Enemy1.EnableAIFeatures(aiControlOffense,true);
        p_Enemy2.EnableAIFeatures(aiControlOffense,true);
        SetGoalState(recoverComputerData, goalAchieved);
        EnableGoal(destroyResearchFacility,true);
        
        if(!p_GoalEnemy.GetNumberOfBuildings(buildingResearchCenter))
        {
            SetGoalState(destroyResearchFacility, goalAchieved);
            AddBriefing("translateAccomplished222");
            EnableEndMissionButton(true);
            state Evacuate; 
        }
        else
        {
            AddBriefing("translateBriefing222b");
            state DestroyResearchFacility;
        }
        return true; //usuwa sie 
    }
}
