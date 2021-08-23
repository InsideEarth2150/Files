mission "translateMission124"
{//neo home
    consts
    {
        findStolenPlans = 0;
        destroyNeoHome = 1;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Player;
    
    unitex u_NeoHome;
    unitex u_Mech1;
    unitex u_Mech2;
    
    int bShowFailed;    
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state NeoMessage;
    state ShowBriefing2;
    state Fighting;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        int nEnemyMoney;
        player tmpPlayer;
        
        //-----------goals-----------------
        RegisterGoal(findStolenPlans,"translateGoal124a");
        RegisterGoal(destroyNeoHome,"translateGoal124b",0);
        EnableGoal(findStolenPlans,true);
        //-----------temporary players-----------------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //-----------players-----------------
        p_Player = GetPlayer(1);
        p_Enemy1 = GetPlayer(2);
        p_Enemy2 = GetPlayer(4);
        p_Enemy3 = GetPlayer(5);
        //-----------AI-----------------
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy3.LoadScript("single\\singleEasy");
            p_Enemy1.EnableAIFeatures(aiControlOffense,false);
            p_Enemy2.EnableAIFeatures(aiControlOffense,false);
            p_Enemy3.EnableAIFeatures(aiControlOffense,false);
            p_Enemy2.EnableAIFeatures(aiDefenseTowers,false);
            p_Enemy2.EnableAIFeatures2(ai2BuildingTowers,false);
            nEnemyMoney=10000;
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Enemy3.LoadScript("single\\singleMedium");
            p_Enemy1.EnableAIFeatures(aiControlOffense,false);
            p_Enemy2.EnableAIFeatures(aiControlOffense,false);
            p_Enemy2.EnableAIFeatures(aiDefenseTowers,false);
            nEnemyMoney=20000;
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Enemy3.LoadScript("single\\singleHard");
            p_Enemy1.EnableAIFeatures(aiControlOffense,false);
            nEnemyMoney=30000;
        }
        
        p_Enemy1.SetNeutral(p_Enemy2);
        p_Enemy1.SetNeutral(p_Enemy3);
        
        p_Enemy2.SetNeutral(p_Enemy1);
        p_Enemy2.SetNeutral(p_Enemy3);
        
        p_Enemy3.SetNeutral(p_Enemy1);
        p_Enemy3.SetNeutral(p_Enemy2);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        //-----------money-----------------
        p_Player.SetMoney(30000-nEnemyMoney/2);
        p_Enemy1.SetMoney(nEnemyMoney);
        p_Enemy2.SetMoney(nEnemyMoney);
        p_Enemy3.SetMoney(nEnemyMoney);
        
        //-----------researches-----------------
        p_Enemy1.EnableResearch("RES_ED_WSR1",true);
        p_Enemy1.EnableResearch("RES_ED_BMD",true);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        p_Enemy3.CopyResearches(p_Enemy1);
        
        
        p_Player.EnableResearch("RES_UCS_UMI1",true);
        p_Player.EnableResearch("RES_UCS_USS2",true);
        p_Player.EnableResearch("RES_UCS_UBS1",true);
        p_Player.EnableResearch("RES_UCS_RepHand2",true);
        //-----------buildings----------------
        p_Player.EnableBuilding("UCSBTE",false);
        //-----------units-----------------
        u_NeoHome = GetUnit(GetPointX(1),GetPointY(1),0);
        u_Mech1 = GetUnit(GetPointX(2),GetPointY(2),0);
        u_Mech2 = GetUnit(GetPointX(3),GetPointY(3),0);
        //-----------Artefacts----------------
        CreateArtefact("NEASPECIAL1",GetPointX(0),GetPointY(0),0,0,artefactSpecialAIOther);
        //-----------Timers----------------
        SetTimer(0,100);
        //-----------variables------------
        bShowFailed=true;
        bCheckEndMission=false;
        //-----------camera----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing124a");
        Rain(p_Player.GetStartingPointX(),p_Player.GetStartingPointY()+10,30,400,5000,800,10); 
        return NeoMessage,600;
    }
    //-----------------------------------------------------------------------------------------
    state NeoMessage
    {
        AddBriefing("translateBriefing124b");
        u_Mech1.ChangePlayer(p_Enemy1);
        u_Mech2.ChangePlayer(p_Enemy2);
        return ShowBriefing2,200;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing2
    {
        EnableGoal(destroyNeoHome,true);
        AddBriefing("translateBriefing124c");
        ShowArea(2,GetPointX(1),GetPointY(1),0,4);
        return Fighting,200;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        
        if(GetGoalState(destroyNeoHome)!=goalAchieved && !u_NeoHome.IsLive())
        {
            SetGoalState(destroyNeoHome, goalAchieved);
            AddBriefing("translateBriefing124d");
            p_Player.GiveAllUnitsTo(p_Enemy1);
        }
        if(GetGoalState(destroyNeoHome)==goalAchieved &&
            GetGoalState(findStolenPlans)!=goalNotAchieved)
        {
            AddBriefing("translateAccomplished124");
            EnableEndMissionButton(true);
            EnableNextMission(0,true);
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
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            
            if(GetGoalState(destroyNeoHome)==goalAchieved &&
                GetGoalState(findStolenPlans)!=goalNotAchieved)
                return;
            
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed124");
                EnableNextMission(1,true);
                EndMission(false);
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
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        if(GetMissionTime()<1200*(60-(GetDifficultyLevel()*15))) //60,45,30 minut
        {
            SetGoalState(findStolenPlans,goalAchieved);
            AddBriefing("translateBriefing124e");
        }
        else
        {
            SetGoalState(findStolenPlans,goalFailed);
            AddBriefing("translateBriefing124f");
        }
        return true; //usuwa sie 
    }
    
}

