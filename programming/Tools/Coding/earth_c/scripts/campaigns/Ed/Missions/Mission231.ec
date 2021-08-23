mission "translateMission231"
{//Destroy second UCS research facility
    consts
    {
        destroyResearchFacility = 0;
        searchOutAlienBase = 1;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_GoalEnemy;
    player p_Player;
    
    state Initialize;
    state ShowBriefing;
    state DestroyResearchFacility;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Goals ------------------
        RegisterGoal(destroyResearchFacility,"translateGoal231a");
        RegisterGoal(searchOutAlienBase,"translateGoal231b");
        EnableGoal(destroyResearchFacility,true);           
        
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(5);
        p_GoalEnemy = GetPlayer(4);
        //----------- AI ---------------------
        p_Player.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        p_Player.SetMoney(20000);
        p_Enemy1.SetMoney(20000);
        p_Enemy2.SetMoney(50000);
        p_GoalEnemy.SetMoney(20000);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_GoalEnemy.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_GoalEnemy.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_GoalEnemy.LoadScript("single\\singleHard");
        }
        
        p_Enemy2.LoadScript("single\\singleHard");
        
        p_GoalEnemy.SetNumberOfOffensiveTankPlatoons(0);
        p_GoalEnemy.SetNumberOfOffensiveShipPlatoons(0);
        p_GoalEnemy.SetNumberOfOffensiveHelicopterPlatoons(0);
        
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy1.SetPointToAssemble(0,GetPointX(2),GetPointY(2),0);
        p_Enemy1.SetPointToAssemble(1,GetPointX(3),GetPointY(3),0);
        
        p_GoalEnemy.EnableAIFeatures(aiControlOffense,false);
        
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
        
        p_Enemy2.SetMaxTankPlatoonSize(5);
        
        p_Enemy2.SetNumberOfOffensiveTankPlatoons(0);
        p_Enemy2.SetNumberOfOffensiveShipPlatoons(0);
        p_Enemy2.SetNumberOfOffensiveHelicopterPlatoons(0);
        
        p_Enemy2.SetNumberOfDefensiveTankPlatoons(4);
        p_Enemy2.SetNumberOfDefensiveShipPlatoons(0);
        p_Enemy2.SetNumberOfDefensiveHelicopterPlatoons(0);
        
        //----------- Researches -------------
        p_Enemy1.EnableResearch("RES_UCS_WSP1",true);
        p_Enemy1.EnableResearch("RES_UCS_UMI1",true);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        p_GoalEnemy.CopyResearches(p_Enemy1);
        
        p_Player.EnableResearch("RES_ED_WSR1",true);
        p_Player.EnableResearch("RES_ED_UA22",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //                name          x,y,z, nr,typ
        CreateArtefact("NEASPECIAL2",GetPointX(0),GetPointY(0),1,0,artefactSpecialAINewAreaLocation);
        //----------- Timers -----------------
        SetTimer(0,200);
        //----------- Variables --------------
        //----------- Camera -----------------
        ShowArea(4,p_GoalEnemy.GetStartingPointX(),p_GoalEnemy.GetStartingPointY(),0,2);
        ShowArea(4,GetPointX(1),GetPointY(1),0,2);
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing231a");
        EnableNextMission(0,true);
        return DestroyResearchFacility,200; 
    }
    
    //-----------------------------------------------------------------------------------------
    state DestroyResearchFacility
    {
        
        if(GetGoalState(searchOutAlienBase)==goalAchieved &&
            GetGoalState(destroyResearchFacility)==goalAchieved)
        {
            AddBriefing("translateAccomplished231b");
            EnableEndMissionButton(true);
            return Evacuate,500;
        }
        
        if(GetGoalState(destroyResearchFacility)!=goalAchieved &&
            !p_GoalEnemy.GetNumberOfBuildings(buildingResearchCenter))
        {
            SetGoalState(destroyResearchFacility, goalAchieved);
            EnableGoal(searchOutAlienBase,true);
            AddBriefing("translateBriefing231b");
            p_Enemy1.EnableAIFeatures(aiControlOffense,true);
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
            AddBriefing("translateFailed231");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        SetGoalState(searchOutAlienBase, goalAchieved);
        EnableNextMission(1,true);
        return true; //usuwa sie 
    }
}
