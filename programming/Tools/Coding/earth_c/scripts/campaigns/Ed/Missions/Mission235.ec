mission "translateMission235"
{//Find UFO
    consts
    {
        findUFO = 0;
        findStartingArtfact1 = 1;
        findStartingArtfact2 = 2;
        findStartingArtfact3 = 3;
        findStartingArtfact4 = 4;
        backToLandingZone = 5;
    }
    
    player p_Enemy;
    player p_Player;
    player p_Neutral;
    unitex p_UFO;
    
    
    state Initialize;
    state ShowBriefing;
    state Searching;
    state SearchingArtefacts;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        RegisterGoal(findUFO,"translateGoal235a");
        RegisterGoal(findStartingArtfact1,"translateGoal235b");
        RegisterGoal(findStartingArtfact2,"translateGoal235c");
        RegisterGoal(findStartingArtfact3,"translateGoal235d");
        RegisterGoal(findStartingArtfact4,"translateGoal235e");
        RegisterGoal(backToLandingZone,"translateGoal235f");
        
        EnableGoal(findUFO,true);               
        
        p_Player = GetPlayer(2);
        p_Enemy = GetPlayer(1);
        p_Neutral = GetPlayer(6);
        
        p_Neutral.EnableStatistics(false);
        
        p_UFO = GetUnit(GetPointX(0),GetPointY(0),1);
        
        p_Player.SetMoney(0);
        p_Enemy.SetMoney(40000);
        
        p_Player.SetEnemy(p_Enemy);
        p_Enemy.SetEnemy(p_Player);
        
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        
        p_Neutral.SetNeutral(p_Enemy);
        p_Enemy.SetNeutral(p_Neutral);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
            p_Enemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy.LoadScript("single\\singleHard");
        
        SetTimer(0,100);
        
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing235a");
        return Searching,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Searching
    {
        if(p_Player.IsPointLocated(GetPointX(0),GetPointY(0),1))
        {
            SetGoalState(findUFO, goalAchieved);
            EnableGoal(findStartingArtfact1,true);
            EnableGoal(findStartingArtfact2,true);
            EnableGoal(findStartingArtfact3,true);
            EnableGoal(findStartingArtfact4,true);
            CreateArtefact("NEASPECIAL2",GetPointX(1),GetPointY(1),1,0,artefactSpecialAIOther);
            CreateArtefact("NEASPECIAL2",GetPointX(2),GetPointY(2),1,1,artefactSpecialAIOther);
            CreateArtefact("NEASPECIAL2",GetPointX(3),GetPointY(3),1,2,artefactSpecialAIOther);
            CreateArtefact("NEASPECIAL2",GetPointX(4),GetPointY(4),1,3,artefactSpecialAIOther);
            CallCamera();
            p_Player.LookAt(GetPointX(0),GetPointY(0),6,0,20,1);
            AddBriefing("translateBriefing235b");
            return SearchingArtefacts,200; 
        }
        return Searching,200;
    }
    //-----------------------------------------------------------------------------------------
    state SearchingArtefacts
    {
        if(GetGoalState(findStartingArtfact1)==goalAchieved &&
            GetGoalState(findStartingArtfact2)==goalAchieved &&
            GetGoalState(findStartingArtfact3)==goalAchieved &&
            GetGoalState(findStartingArtfact4)==goalAchieved)
        {
            p_Neutral.GiveAllUnitsTo(p_Player);
            EnableGoal(backToLandingZone,true);
            AddBriefing("translateBriefing235c"); //back to lz
            return Evacuate,50;
        }
        return SearchingArtefacts,200;
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        if(GetGoalState(backToLandingZone)!=goalAchieved &&
            Distance(p_UFO.GetLocationX(),p_UFO.GetLocationY(),p_Player.GetStartingPointX(),p_Player.GetStartingPointY()) < 5)
        {
            CallCamera();
            p_Player.LookAt(p_UFO.GetLocationX(),p_UFO.GetLocationY(),6,0,20,p_UFO.GetLocationZ());
            SetGoalState(backToLandingZone, goalAchieved);
            AddBriefing("translateAccomplished235");
            p_Neutral.SetEnemy(p_Player);
            p_Player.SetEnemy(p_Neutral);
            p_Neutral.SetEnemy(p_Enemy);
            p_Enemy.SetEnemy(p_Neutral);
            
            EnableEndMissionButton(true);
        }
        return Evacuate,50;
    }
    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(!p_UFO.IsLive() && GetGoalState(backToLandingZone)!= goalFailed)
        {
            SetGoalState(backToLandingZone, goalFailed);
            AddBriefing("translateFailed235a");
            p_Neutral.SetEnemy(p_Player);
            p_Player.SetEnemy(p_Neutral);
            p_Neutral.SetEnemy(p_Enemy);
            p_Enemy.SetEnemy(p_Neutral);
            EnableEndMissionButton(true);
        }
        if(!p_Player.GetNumberOfBuildings() && GetGoalState(backToLandingZone)!= goalFailed)
        {
            SetGoalState(backToLandingZone, goalFailed);
            AddBriefing("translateFailed235b");
            p_Neutral.SetEnemy(p_Player);
            p_Player.SetEnemy(p_Neutral);
            p_Neutral.SetEnemy(p_Enemy);
            p_Enemy.SetEnemy(p_Neutral);
            EndMission(false);
        }
        
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        if(aID==0)
            SetGoalState(findStartingArtfact1, goalAchieved);
        if(aID==1)
            SetGoalState(findStartingArtfact2, goalAchieved);
        if(aID==2)
            SetGoalState(findStartingArtfact3, goalAchieved);
        if(aID==3)
            SetGoalState(findStartingArtfact4, goalAchieved);
        return true; //usuwa sie 
    }
    
}
