mission "translateMission618"
{

    consts
    {
        scriptFieldMoney=9;
        goalDestroyNorthCannon = 0;
        goalDestroyWestCannon = 1;
        goalDestroySouthCannon = 2;
        goalFangHaveToSurvive = 3;
    }

    player p_Player;
    player p_Enemy;
    player p_TmpPlayer;
    
    int bCheckEndMission;
    
    unitex Cannon1;
    unitex Cannon2;
    unitex Cannon3;
    unitex Cannon4;
    unitex Cannon5;
    unitex Cannon6;
    unitex CannonHQ1;
    unitex CannonHQ2;
    unitex CannonHQ3;
    unitex uFang;

    state Initialize;
    state ShowBriefing;
    state Working;
    state MissionFailed;
    state Nothing;

    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(goalDestroyNorthCannon, "translateGoal618a");
        RegisterGoal(goalDestroyWestCannon, "translateGoal618b");
        RegisterGoal(goalDestroySouthCannon, "translateGoal618c");
        RegisterGoal(goalFangHaveToSurvive, "translateGoal618d");
        //---Show goals on list---
        EnableGoal(goalDestroyNorthCannon, true);
        EnableGoal(goalDestroyWestCannon, true);
        EnableGoal(goalDestroySouthCannon, true);
        EnableGoal(goalFangHaveToSurvive, true);
        
        //----------- Players ----------------
        p_Player = GetPlayer(3);    //LC
        p_Enemy = GetPlayer(1);     //UCS

        p_TmpPlayer = GetPlayer(2);
        p_TmpPlayer.EnableStatistics(false);
        
        //----------- AI ---------------------
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
        }
        
        //wylacz inteligencje graczy
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        p_Enemy.EnableAIFeatures(aiControlDefense,false);
        p_Enemy.EnableAIFeatures(aiBuildBuildings,false);
        
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_Enemy.SetMoney(0);
        
        //----------- Timers -----------------
        //----------- Variables --------------
        bCheckEndMission = false;
        
        Cannon1 = GetUnit(GetPointX(8), GetPointY(8), 0);
        Cannon2 = GetUnit(GetPointX(9), GetPointY(9), 0);
        Cannon3 = GetUnit(GetPointX(10), GetPointY(10), 0);
        Cannon4 = GetUnit(GetPointX(11), GetPointY(11), 0);
        Cannon5 = GetUnit(GetPointX(12), GetPointY(12), 0);
        Cannon6 = GetUnit(GetPointX(13), GetPointY(13), 0);

        CannonHQ1 = GetUnit(GetPointX(14), GetPointY(14), 0);
        CannonHQ2 = GetUnit(GetPointX(15), GetPointY(15), 0);
        CannonHQ3 = GetUnit(GetPointX(16), GetPointY(16), 0);
        
        uFang = GetUnit(GetPointX(31), GetPointY(31), 0);
        p_Player.AddUnitToSpecialTab(uFang,true, -1);

        //---- Creating & destroying additional units -----
        if(GetDifficultyLevel()==0)
        {
            p_Player.CreateUnitEx(GetPointX(0), GetPointY(0), 0, null, "LCUCR3", "LCWHL2", null,"LCWSL2", null, 1); // Crater m3 + E + E
            p_Player.CreateUnitEx(GetPointX(1), GetPointY(1), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null,1); // Crusher m3 + R + R
            p_Player.CreateUnitEx(GetPointX(2), GetPointY(2), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Player.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Meteor m3 + 20mm

            p_Player.CreateUnitEx(GetPointX(4), GetPointY(4), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null, 1); // Crater m3 + E + E
            p_Player.CreateUnitEx(GetPointX(5), GetPointY(5), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null, 1); // Crusher m3 + R + R
            p_Player.CreateUnitEx(GetPointX(6), GetPointY(6), 0, null, "LCUBO2", "LCWAMR2", null, null, null, 1); // Thunder m2 + hR
            p_Player.CreateUnitEx(GetPointX(7), GetPointY(7), 0, null, "LCUBO2", "LCWAMR2", null, null, null, 1); // Meteor m3 + 20mm
            
            KillArea(p_Enemy.GetIFF(), GetPointX(17), GetPointY(17), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(18), GetPointY(18), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(19), GetPointY(19), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(20), GetPointY(20), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(21), GetPointY(21), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(22), GetPointY(22), 0, 1);
        }
        if(GetDifficultyLevel()==1)
        {
            p_Player.CreateUnitEx(GetPointX(0), GetPointY(0), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null, 1); // Crater m3 + E + E
            p_Player.CreateUnitEx(GetPointX(1), GetPointY(1), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null, 1); // Crusher m3 + R + R
            p_Player.CreateUnitEx(GetPointX(2), GetPointY(2), 0, null, "LCUBO2", "LCWAMR2", null, null, null, 1); // Thunder m2 + hR
            p_Player.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "LCUBO2", "LCWAMR2", null, null, null, 1); // Meteor m3 + 20mm

            KillArea(p_Enemy.GetIFF(), GetPointX(17), GetPointY(17), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(19), GetPointY(19), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(21), GetPointY(21), 0, 1);

            p_Enemy.CreateUnitEx(GetPointX(23), GetPointY(23), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(24), GetPointY(24), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(25), GetPointY(25), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(26), GetPointY(26), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(27), GetPointY(27), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(28), GetPointY(28), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(29), GetPointY(29), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(30), GetPointY(30), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.CreateUnitEx(GetPointX(23), GetPointY(23), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(24), GetPointY(24), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(25), GetPointY(25), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(26), GetPointY(26), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(27), GetPointY(27), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(28), GetPointY(28), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(29), GetPointY(29), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(30), GetPointY(30), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR

            p_Enemy.CreateUnitEx(GetPointX(23), GetPointY(23) + 1, 0, null, "UCSUBL1", "UCSWBMR3", "UCSWSSR3", null, null); // Jaguar + hR + R
            p_Enemy.CreateUnitEx(GetPointX(24), GetPointY(24) + 1, 0, null, "UCSUBL1", "UCSWBMR3", "UCSWSSR3", null, null); // Jaguar + hR + R
            p_Enemy.CreateUnitEx(GetPointX(25), GetPointY(25) + 1, 0, null, "UCSUBL1", "UCSWBMR3", "UCSWSSR3", null, null); // Jaguar + hR + R
            p_Enemy.CreateUnitEx(GetPointX(26), GetPointY(26) + 1, 0, null, "UCSUBL1", "UCSWBMR3", "UCSWSSR3", null, null); // Jaguar + hR + R
            p_Enemy.CreateUnitEx(GetPointX(27), GetPointY(27) + 1, 0, null, "UCSUBL1", "UCSWBMR3", "UCSWSSR3", null, null); // Jaguar + hR + R
            p_Enemy.CreateUnitEx(GetPointX(28), GetPointY(28) + 1, 0, null, "UCSUBL1", "UCSWBMR3", "UCSWSSR3", null, null); // Jaguar + hR + R
            p_Enemy.CreateUnitEx(GetPointX(29), GetPointY(29) + 1, 0, null, "UCSUBL1", "UCSWBMR3", "UCSWSSR3", null, null); // Jaguar + hR + R
            p_Enemy.CreateUnitEx(GetPointX(30), GetPointY(30) + 1, 0, null, "UCSUBL1", "UCSWBMR3", "UCSWSSR3", null, null); // Jaguar + hR + R
        }
        
        //----------- Buildings -----------------
        p_Player.EnableBuilding("LCBBF",false);
        p_Player.EnableBuilding("LCBPP",false);
        p_Player.EnableBuilding("LCBPP2",false);
        p_Player.EnableBuilding("LCBNE",false);
        p_Player.EnableBuilding("LCBSB",false);
        p_Player.EnableBuilding("LCBBA",false);
        p_Player.EnableBuilding("LCBMR",false);
        p_Player.EnableBuilding("LCBSR",false);
        p_Player.EnableBuilding("LCBRC",false);
        p_Player.EnableBuilding("LCBAB",false);
        p_Player.EnableBuilding("LCBGA",false);
        p_Player.EnableBuilding("LCBDE",false);
        p_Player.EnableBuilding("LCBHQ",false);
        p_Player.EnableBuilding("LCBSD",false);
        p_Player.EnableBuilding("LCBWC",false);
        p_Player.EnableBuilding("LCBSS",false);
        p_Player.EnableBuilding("LCBLZ",true);

        p_Player.EnableBuilding("LCBUC",false);
        p_Player.EnableBuilding("LCBEN1",false);
        p_Player.EnableBuilding("LCLASERWALL",false);
        
        p_Enemy.EnableResearch("RES_UCS_WAPB1", true);
        p_Enemy.EnableResearch("RES_UCS_MB2", true);
        
        p_Player.EnableResearch("RES_LC_ART",true);//618
        p_Player.EnableResearch("RES_LC_BWC",true);//618
        p_Player.EnableCommand(commandSoldBuilding,true);                          
        p_Player.EnableBuilding("LCBRC",false); 
        
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        return ShowBriefing, 100;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing618", p_Player.GetName());
        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(uFang!=null && !uFang.IsLive())
            {
                if(GetGoalState(goalDestroyNorthCannon) != goalAchieved)
                    SetGoalState(goalDestroyNorthCannon, goalFailed);
                if(GetGoalState(goalDestroyWestCannon) != goalAchieved)
                    SetGoalState(goalDestroyWestCannon, goalFailed);
                if(GetGoalState(goalDestroySouthCannon) != goalAchieved)
                    SetGoalState(goalDestroySouthCannon, goalFailed);

                SetGoalState(goalFangHaveToSurvive, goalFailed);
                AddBriefing("translateFailed618a", p_Player.GetName());
                return MissionFailed, 20;
            }
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings() &&
                GetGoalState(goalDestroyNorthCannon) != goalAchieved&&
                GetGoalState(goalDestroyWestCannon) != goalAchieved&&
                GetGoalState(goalDestroySouthCannon) != goalAchieved)

            {
                if(GetGoalState(goalDestroyNorthCannon) != goalAchieved)
                    SetGoalState(goalDestroyNorthCannon, goalFailed);
                if(GetGoalState(goalDestroyWestCannon) != goalAchieved)
                    SetGoalState(goalDestroyWestCannon, goalFailed);
                if(GetGoalState(goalDestroySouthCannon) != goalAchieved)
                    SetGoalState(goalDestroySouthCannon, goalFailed);
                    
                AddBriefing("translateFailed618b", p_Player.GetName());
                return MissionFailed, 20;
            }

            if(!Cannon1.IsLive() && !Cannon2.IsLive() && !CannonHQ1.IsLive())
                SetGoalState(goalDestroyNorthCannon, goalAchieved);

            if(!Cannon3.IsLive() && !Cannon4.IsLive() && !CannonHQ2.IsLive())
                SetGoalState(goalDestroyWestCannon, goalAchieved);

            if(!Cannon5.IsLive() && !Cannon6.IsLive() && !CannonHQ3.IsLive())
                SetGoalState(goalDestroySouthCannon, goalAchieved);

        }

        if(GetGoalState(goalDestroyNorthCannon) == goalAchieved && 
            GetGoalState(goalDestroyWestCannon) == goalAchieved && 
            GetGoalState(goalDestroySouthCannon) == goalAchieved)
        {
            SetGoalState(goalFangHaveToSurvive, goalAchieved);
            AddBriefing("translateAccomplished618", p_Player.GetName());
            
            if(p_Player.GetScriptData(11)!=11)//bo musi sie zakonczyc misja 618 i 619
                p_Player.SetScriptData(11,11);
            else
                EnableNextMission(0, true);

            EnableEndMissionButton(true);
            return Nothing;
        }

        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state MissionFailed
    {
        EnableNextMission(0,2);
        return Nothing;
    }

    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(uFang!=null && !uFang.IsLive())
        {
    
            SetGoalState(goalFangHaveToSurvive, goalFailed);
            AddBriefing("translateFailed618a", p_Player.GetName());
            return MissionFailed, 20;
        }
        return Nothing, 100;
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
        if(GetGoalState(goalDestroyNorthCannon) == goalAchieved && 
            GetGoalState(goalDestroyWestCannon) == goalAchieved && 
            GetGoalState(goalDestroySouthCannon) == goalAchieved)
        {
            p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
            p_Player.SetMoney(0);
        }
    }
    
}
