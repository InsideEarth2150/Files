mission "translateMission233"
{//Spy Run
    consts
    {
        findData1 = 0;
        findData2 = 1;
        findData3 = 2;
        backToLandingZone=3;
    }
    
    player p_Enemy1;
    player p_Neutral;
    player p_Player;
    unitex p_Spy;
    
    state Initialize;
    state ShowBriefing;
    state Spy;
    state Evacuate;
    
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        tmpPlayer = GetPlayer(8); 
        tmpPlayer.EnableStatistics(false);
        
        RegisterGoal(findData1,"translateGoal233a");
        RegisterGoal(findData2,"translateGoal233b");
        RegisterGoal(findData3,"translateGoal233c");
        RegisterGoal(backToLandingZone,"translateGoal233d");
        
        EnableGoal(findData1,true);           
        EnableGoal(findData2,true);           
        EnableGoal(findData3,true);           
        
        //                   name          x,y,z, nr,typ
        CreateArtefact("NEASPECIAL2",GetPointX(1),GetPointY(1),1,0,artefactSpecialAIOther);
        CreateArtefact("NEASPECIAL2",GetPointX(2),GetPointY(2),1,1,artefactSpecialAIOther);
        CreateArtefact("NEASPECIAL2",GetPointX(3),GetPointY(3),1,2,artefactSpecialAIOther);
        
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Neutral = GetPlayer(8);
        
        p_Player.SetMoney(0);
        p_Enemy1.SetMoney(10000);
        p_Neutral.SetMoney(0);
        
        p_Spy = GetUnit(GetPointX(0),GetPointY(0),0);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
        }
        
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy1.EnableAIFeatures(aiControlDefense,false);
        
        
        
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        
        SetTimer(0,200);
        
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing233a");
        return Spy,200; 
    }
    
    //-----------------------------------------------------------------------------------------
    state Spy
    {
        
        if(GetGoalState(findData1)==goalAchieved &&
            GetGoalState(findData2)==goalAchieved &&
            GetGoalState(findData3)==goalAchieved)
        {
            p_Neutral.GiveAllBuildingsTo(p_Player);
            p_Enemy1.GiveAllUnitsTo(p_Player);
            EnableGoal(backToLandingZone,true);
            AddBriefing("translateBriefing233b"); //back to lz
            return Evacuate,50;
        }
        return Spy,100;
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        if(GetGoalState(backToLandingZone)!=goalAchieved &&
            Distance(p_Spy.GetLocationX(),p_Spy.GetLocationY(),p_Player.GetStartingPointX(),p_Player.GetStartingPointY()) < 5)
        {
            SetGoalState(backToLandingZone, goalAchieved);
            //EnableNextMission(0,2);//eneble UCS base
            AddBriefing("translateAccomplished233");
            EnableEndMissionButton(true);
        }
        return Evacuate,50;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0()
    {
        if(!p_Spy.IsLive())
        {
            AddBriefing("translateFailed233");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        if(aID==0)
            SetGoalState(findData1, goalAchieved);
        if(aID==1)
            SetGoalState(findData2, goalAchieved);
        if(aID==2)
            SetGoalState(findData3, goalAchieved);
        return true; //usuwa sie 
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_Neutral.SetEnemy(p_Player);
        p_Player.SetEnemy(p_Neutral);
    }
    
}
