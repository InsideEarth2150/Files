mission "translateMission251"
{//Escort convoy
    consts
    {
        escortConvoy = 0;
        destroyUCSBase = 1;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Neutral;
    player p_Player;
    unitex p_ConvoyCraft1;
    unitex p_ConvoyCraft2;
    unitex p_ConvoyCraft3;
    unitex p_ConvoyCraft4;
    unitex p_ConvoyEscort1;
    unitex p_ConvoyEscort2;
    int nWayPoint;
    
    state Initialize;
    state ShowBriefing;
    state OnTheWay;
    state Fight;
    state Final;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(escortConvoy,"translateGoal251a");
        RegisterGoal(destroyUCSBase,"translateGoal251b");
        EnableGoal(escortConvoy,true);               
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(4);
        p_Neutral = GetPlayer(8);
        //----------- AI ---------------------
        p_Neutral.EnableStatistics(false);  
        p_Enemy2.EnableStatistics(false);
        
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        
        p_Neutral.EnableAIFeatures(aiRejectAlliance,false);
        p_Player.SetAlly(p_Neutral);
        p_Neutral.ChooseEnemy(p_Enemy1);
        
        if(GetDifficultyLevel()==0)
            p_Enemy1.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy1.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy1.LoadScript("single\\singleHard");
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy1.EnableAIFeatures(aiControlDefense,false);
        p_Enemy2.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        
        p_Neutral.SetName("translateAIName251");
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_Enemy1.SetMoney(30000);
        p_Enemy2.SetMoney(0);
        //----------- Researches -------------
        p_Player.EnableResearch("RES_ED_MHC2",true);
        p_Player.EnableResearch("RES_ED_SCR",true);
        
        p_Enemy1.EnableResearch("RES_UCS_SHD",true);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        //----------- Buildings --------------
        //----------- Units ------------------
        p_ConvoyCraft1 = GetUnit(GetPointX(0),GetPointY(0),0);
        p_ConvoyCraft2 = GetUnit(GetPointX(1),GetPointY(1),0);
        p_ConvoyCraft3 = GetUnit(GetPointX(2),GetPointY(2),0);
        p_ConvoyCraft4 = GetUnit(GetPointX(3),GetPointY(3),0);
        p_ConvoyEscort1 = GetUnit(GetPointX(4),GetPointY(4),0);
        p_ConvoyEscort2 = GetUnit(GetPointX(5),GetPointY(5),0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,200);
        //----------- Variables --------------
        nWayPoint=5;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        ShowArea(4,GetPointX(6),GetPointY(6),0,2);
        ShowArea(4,GetPointX(7),GetPointY(7),0,2);
        ShowArea(4,GetPointX(8),GetPointY(8),0,2);
        ShowArea(4,GetPointX(9),GetPointY(9),0,2);
        ShowArea(4,GetPointX(10),GetPointY(10),0,2);
        EnableNextMission(0,true);
        AddBriefing("translateBriefing251a");
        return OnTheWay,300;
    }
    //-----------------------------------------------------------------------------------------  
    state OnTheWay
    {
        if(nWayPoint>9) 
        {
            nWayPoint=10;
        }
        if(p_ConvoyCraft1.DistanceTo(GetPointX(10),GetPointY(10)) < 5 &&
            p_ConvoyCraft2.DistanceTo(GetPointX(10),GetPointY(10)) < 5 &&
            p_ConvoyCraft3.DistanceTo(GetPointX(10),GetPointY(10)) < 5 &&
            p_ConvoyCraft4.DistanceTo(GetPointX(10),GetPointY(10)) < 5 )
        {
            p_Neutral.GiveAllUnitsTo(p_Player);
            p_Neutral.GiveAllBuildingsTo(p_Player);
            SetGoalState(escortConvoy, goalAchieved);
            EnableGoal(destroyUCSBase,true);               
            p_Enemy1.EnableAIFeatures(aiControlOffense,true);
            p_Enemy1.EnableAIFeatures(aiControlDefense,true);
            p_Player.SetMoney(20000);
            AddBriefing("translateBriefing251b");
            return Fight,100;
        }
        
        if(p_ConvoyCraft1.DistanceTo(GetPointX(nWayPoint),GetPointY(nWayPoint)) < 5 &&
            p_ConvoyCraft2.DistanceTo(GetPointX(nWayPoint),GetPointY(nWayPoint)) < 5 &&
            p_ConvoyCraft3.DistanceTo(GetPointX(nWayPoint),GetPointY(nWayPoint)) < 5 &&
            p_ConvoyCraft4.DistanceTo(GetPointX(nWayPoint),GetPointY(nWayPoint)) < 5 )
        {
            nWayPoint=nWayPoint+1;
            if(nWayPoint==9)
            {
                p_Player.SetMoney(2000);
                AddBriefing("translateBriefing251c");
            }
        }
        
        p_ConvoyCraft1.CommandMove(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint));
        p_ConvoyCraft2.CommandMove(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint));
        p_ConvoyCraft3.CommandMove(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint));
        p_ConvoyCraft4.CommandMove(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint));
        p_ConvoyEscort1.CommandMove(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint));
        p_ConvoyEscort2.CommandMove(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint));
        
        return OnTheWay,300;
    }
    //-----------------------------------------------------------------------------------------
    state Fight
    {
        if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed251b");
            EndMission(false);
        }
        if(
            (p_Enemy1.GetNumberOfUnits()<6) && 
            !p_Enemy1.GetNumberOfBuildings())
        {
            SetGoalState(destroyUCSBase, goalAchieved);
            AddBriefing("translateAccomplished251");
            EnableEndMissionButton(true);
            return Final,500;
        }
        return Fight,200;
    }
    //-----------------------------------------------------------------------------------------
    state Final
    {
        return Final,500;
    }
    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 200 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(GetGoalState(escortConvoy)!=goalAchieved &&
            (!p_ConvoyCraft1.IsLive()||
            !p_ConvoyCraft2.IsLive()||
            !p_ConvoyCraft3.IsLive()||
            !p_ConvoyCraft4.IsLive()))
        {
            AddBriefing("translateFailed251a");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission() 
    {
        p_Neutral.SetEnemy(p_Player);
        p_Player.SetEnemy(p_Neutral);
        p_Neutral.EnableAIFeatures(aiRejectAlliance,true);
    }
}
