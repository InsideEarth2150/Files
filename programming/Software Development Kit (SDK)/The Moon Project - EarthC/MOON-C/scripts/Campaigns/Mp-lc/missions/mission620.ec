mission "translateMission620"
{
    consts
    {
        goalDestroyUCS1 = 0;
        goalDestroyUCS2 = 1;
        goalDestroyUCS3 = 2;
        goalDestroyUCS4 = 3;
        goalDefendCC = 4;
    }

    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Enemy4;

    player p_Player;

    unitex uCC1;
    unitex uCC2;
    unitex uCC3;
    unitex uCC4;

    int bCheckEndMission;

    state Initialize;
    state ShowBriefing;
    state Working;
    state EndMissionFailed;
    state EndGameSuccess;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(goalDestroyUCS1,"translateGoal620a");
        RegisterGoal(goalDestroyUCS2,"translateGoal620b");
        RegisterGoal(goalDestroyUCS3,"translateGoal620c");;
        RegisterGoal(goalDestroyUCS4,"translateGoal620d");
        RegisterGoal(goalDefendCC,"translateGoal620e");

        EnableGoal(goalDestroyUCS1,true);
        EnableGoal(goalDestroyUCS2,true);
        EnableGoal(goalDestroyUCS3,true);
        EnableGoal(goalDestroyUCS4,true);
        EnableGoal(goalDefendCC,true);

        //----------- Players ----------------
        p_Player = GetPlayer(3);

        p_Enemy1  = GetPlayer(1);
        p_Enemy2  = GetPlayer(5);
        p_Enemy3  = GetPlayer(7);
        p_Enemy4  = GetPlayer(9);
        
        
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy3.LoadScript("single\\singleEasy");
            p_Enemy4.LoadScript("single\\singleEasy");
        }

        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Enemy3.LoadScript("single\\singleMedium");
            p_Enemy4.LoadScript("single\\singleMedium");
        }

        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Enemy3.LoadScript("single\\singleHard");
            p_Enemy4.LoadScript("single\\singleHard");
        }

        p_Enemy1.EnableAIFeatures(aiRush,false);
        p_Enemy2.EnableAIFeatures(aiRush,false);
        p_Enemy3.EnableAIFeatures(aiRush,false);
        p_Enemy4.EnableAIFeatures(aiRush,false);
        
        p_Enemy2.SetAlly(p_Enemy1);
        p_Enemy3.SetAlly(p_Enemy1);
        p_Enemy4.SetAlly(p_Enemy1);

        p_Enemy3.SetAlly(p_Enemy2);
        p_Enemy4.SetAlly(p_Enemy2);

        p_Enemy4.SetAlly(p_Enemy3);

        p_Enemy1.EnableAIFeatures(aiBuildSuperAttack, true);
        p_Enemy2.EnableAIFeatures(aiBuildSuperAttack, true);
        p_Enemy3.EnableAIFeatures(aiBuildSuperAttack, true);
        p_Enemy4.EnableAIFeatures(aiBuildSuperAttack, true);

        p_Enemy2.CopyResearches(p_Enemy1);
        p_Enemy3.CopyResearches(p_Enemy1);
        p_Enemy4.CopyResearches(p_Enemy1);

        //----------- Money ------------------
        p_Player.SetMoney(40000);

        p_Enemy1.SetMoney(10000);
        p_Enemy2.SetMoney(10000);
        p_Enemy3.SetMoney(10000);
        p_Enemy4.SetMoney(10000);

        p_Player.EnableCommand(commandSoldBuilding,true);                  // 1st tab
        //----------- Timers -----------------
        SetTimer(0, 20);
        SetTimer(1, 20);
        SetTimer(2, 1);//xxxmd
        //----------- Variables --------------
        uCC1 = GetUnit(GetPointX(0),GetPointY(0),0);
        uCC2 = GetUnit(GetPointX(1),GetPointY(1),0);
        uCC3 = GetUnit(GetPointX(2),GetPointY(2),0);
        uCC4 = GetUnit(GetPointX(3),GetPointY(3),0);
        //----------- Buildings --------------
        p_Player.EnableBuilding("LCBSR",false); //Centrum wydobywczo-transportowe
        p_Player.EnableBuilding("LCBRC",false); 
        p_Player.EnableResearch("RES_LC_WARTILLERY",true);  //Artyleria plazmowa

        p_Enemy1.EnableResearch("RES_UCS_MB2",true);             
        p_Enemy1.EnableResearch("RES_UCS_WAPB1", true);      

        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(), 12, 0, 45, 0);
        return ShowBriefing, 60;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
            AddBriefing("translateBriefing620", p_Player.GetName());
            return Working, 20;
    }


    //----------------------------------------------------------------------------------------- 
    state Working
    {
        if(!bCheckEndMission)
            return Working;

        bCheckEndMission=false;
        //-----------mission failed-----------------
        if(!uCC1.IsLive() ||!uCC2.IsLive() ||!uCC3.IsLive() ||!uCC4.IsLive())
        {
            SetGoalState(goalDefendCC,goalFailed);
            AddBriefing("translateFailed620", p_Player.GetName());
            return EndMissionFailed;
        }

        //---- check 1 goal - destroy UCS ----
        if(GetGoalState(goalDestroyUCS1)!=goalAchieved &&
            !p_Enemy1.GetNumberOfBuildings())
        {
            SetGoalState(goalDestroyUCS1,goalAchieved);
            p_Enemy1.EnableAIFeatures(aiEnabled,false);
        }
        if(GetGoalState(goalDestroyUCS2)!=goalAchieved &&
            !p_Enemy2.GetNumberOfBuildings())
        {
            SetGoalState(goalDestroyUCS2,goalAchieved);
            p_Enemy2.EnableAIFeatures(aiEnabled,false);
        }
        if(GetGoalState(goalDestroyUCS3)!=goalAchieved &&
            !p_Enemy3.GetNumberOfBuildings())
        {
            SetGoalState(goalDestroyUCS3,goalAchieved);
            p_Enemy3.EnableAIFeatures(aiEnabled,false);
        }
        if(GetGoalState(goalDestroyUCS4)!=goalAchieved &&
            !p_Enemy4.GetNumberOfBuildings())
        {
            SetGoalState(goalDestroyUCS4,goalAchieved);
            p_Enemy4.EnableAIFeatures(aiEnabled,false);
        }

        //-----  All goals achieved  -----
        if(GetGoalState(goalDestroyUCS1)==goalAchieved &&
            GetGoalState(goalDestroyUCS2)==goalAchieved &&
            GetGoalState(goalDestroyUCS3)==goalAchieved &&
            GetGoalState(goalDestroyUCS4)==goalAchieved)
        {
            SetGoalState(goalDefendCC,goalAchieved);
            p_Player.SetScriptData(4,2);
            AddBriefing("translateAccomplished620");
            return EndGameSuccess;
        }
        return Working;
    }

    //-----------------------------------------------------------------------------------------
    state EndMissionFailed
    {
        EnableNextMission(0,2);
        return Nothing;
    }

    //-----------------------------------------------------------------------------------------
    state EndGameSuccess
    {
        EnableNextMission(0,3);
        return Nothing;
    }

    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
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
}
