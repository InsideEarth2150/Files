


mission "translateMission621"
{
    consts
    {
        scriptFieldMoney=9;
        goalDestroyUCSHarvesters = 0;
        goalDestroyUCSBase = 1;
    }

    player p_Enemy;
    player p_Player;
        
    int bCheckEndMission;

    state Initialize;
    state ShowBriefing;
    state Working;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(goalDestroyUCSHarvesters,"translateGoal621a");
        RegisterGoal(goalDestroyUCSBase,"translateGoal621b");


        EnableGoal(goalDestroyUCSHarvesters,true);
        EnableGoal(goalDestroyUCSBase,true);

        //----------- Players ----------------
        p_Player = GetPlayer(3);
        p_Enemy  = GetPlayer(1);

        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
            p_Enemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy.LoadScript("single\\singleHard");

        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        p_Enemy.EnableAIFeatures(aiBuildMiningUnits,false);
        //----------- Money ------------------
        p_Player.SetMoney(10000);
        p_Enemy.SetMoney(0);

        if(GetDifficultyLevel()==0)
        {
            KillArea(2,GetPointX(0), GetPointY(0), 0,1);
            KillArea(2,GetPointX(1), GetPointY(1), 0,1);
            KillArea(2,GetPointX(2), GetPointY(2), 0,1);
            KillArea(2,GetPointX(3), GetPointY(3), 0,1);
        }
        if(GetDifficultyLevel()==1)
        {
            KillArea(2,GetPointX(1), GetPointY(1), 0,1);
            KillArea(2,GetPointX(2), GetPointY(2), 0,1);
        }

        //----------- Buildings --------------
        p_Player.EnableBuilding("LCBBF",false);
        p_Player.EnableBuilding("LCBPP",false);
        p_Player.EnableBuilding("LCBPP2",false);
        p_Player.EnableBuilding("LCBSB",false);
        p_Player.EnableBuilding("LCBBA",false);
        p_Player.EnableBuilding("LCBMR",false);
        p_Player.EnableBuilding("LCBSR",false);
        p_Player.EnableBuilding("LCBRC",false);
        p_Player.EnableBuilding("LCBAB",false);
        p_Player.EnableBuilding("LCBGA",false);
        p_Player.EnableBuilding("LCBDE",false);
        p_Player.EnableBuilding("LCBHQ",false);
        p_Player.EnableBuilding("LCBNE",false);
        p_Player.EnableBuilding("LCBSD",false);
        p_Player.EnableBuilding("LCBWC",false);
        p_Player.EnableBuilding("LCBSS",false);
        p_Player.EnableBuilding("LCBLZ",false);

        p_Player.EnableBuilding("LCBUC",false);
        p_Player.EnableBuilding("LCBEN1",false);
        p_Player.EnableBuilding("LCLASERWALL",false);
        p_Player.EnableCommand(commandSoldBuilding,true);                  

        p_Player.EnableResearch("RES_LCUUT",true);//621 add
        p_Player.AddResearch("RES_LCUUT");//621 add

        bCheckEndMission=false;

        SetTimer(0,100);
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        return ShowBriefing,1;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing621a", p_Player.GetName());
        EnableNextMission(0,true);
        return Working, 20;
    }
    //-----------------------------------------------------------------------------------------
    state Working
    {
        if(GetGoalState(goalDestroyUCSHarvesters)==goalNotAchieved)
            SetConsoleText("translateMessage621",p_Enemy.GetNumberOfUnits(unitHarvester|chassisAny));

        if(GetGoalState(goalDestroyUCSHarvesters)==goalAchieved && 
            GetGoalState(goalDestroyUCSBase)==goalAchieved)
        {
            AddBriefing("translateAccomplished621", p_Player.GetName());
            EnableEndMissionButton(true);
            return Nothing;
        }
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
            return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0()
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;

            if(GetGoalState(goalDestroyUCSHarvesters)==goalNotAchieved && !p_Enemy.GetNumberOfUnits(unitHarvester|chassisAny))
            {
                SetConsoleText("");
                SetGoalState(goalDestroyUCSHarvesters,goalAchieved);
                AddBriefing("translateBriefing621b", p_Player.GetName());
                p_Player.EnableBuilding("LCBLZ",true);
                p_Player.SetMoney(10000);
                p_Enemy.SetMoney(20000);
            }

            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            { 
                AddBriefing("translateFailed621", p_Player.GetName());
                EndMission(false);
            }

            if(GetGoalState(goalDestroyUCSBase)==goalNotAchieved && !p_Enemy.GetNumberOfBuildings())
            {
                SetGoalState(goalDestroyUCSBase,goalAchieved);
                AddBriefing("translateBriefing621c", p_Player.GetName());
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
    event EndMission() 
    {
        if(GetGoalState(goalDestroyUCSHarvesters)==goalAchieved && 
        GetGoalState(goalDestroyUCSBase)==goalAchieved)
        {
            p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
            p_Player.SetMoney(0);
        }
    }
}
