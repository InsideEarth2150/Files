mission "translateMission614"
{

    consts
    {
        scriptFieldMoney=9;
        goalDestroyEnemy1 = 0;
        goalDestroyEnemy2 = 1;
        goalDestroyEnemy3 = 2;
        goalActivateUnitTransporters = 3;
        goalFangHaveToSurvive = 4;
    }

    player p_Player;
    player p_Enemy0;
    player p_Enemy1;
    player p_Enemy2;
    player p_Neutral;
    player p_TmpPlayer;

    unitex uFang;
 
    int bCheckEndMission;
    int bUnitTransportersActivated;
 


    state Initialize;
    state ShowBriefing;
    state Working;
    state MissionFailed;
    state Nothing;

    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------

        RegisterGoal(goalDestroyEnemy1, "translateGoal614a");
        RegisterGoal(goalDestroyEnemy2, "translateGoal614b");
        RegisterGoal(goalDestroyEnemy3, "translateGoal614c");
        RegisterGoal(goalActivateUnitTransporters, "translateGoal614d");
        RegisterGoal(goalFangHaveToSurvive, "translateGoal614e");

        EnableGoal(goalDestroyEnemy1, true);
        EnableGoal(goalDestroyEnemy2, true);
        EnableGoal(goalDestroyEnemy3, true);
        EnableGoal(goalActivateUnitTransporters, true);
        EnableGoal(goalFangHaveToSurvive, true);

        
        //----------- Players ----------------
        p_Player = GetPlayer(3);    //LC

        p_Enemy0 = GetPlayer(0);    //UCS
        p_Enemy1 = GetPlayer(1);    //UCS
        p_Enemy2 = GetPlayer(5);    //UCS

        
        p_TmpPlayer = GetPlayer(2);
        p_TmpPlayer.EnableStatistics(false);
        
        p_Neutral = GetPlayer(6);   //UCS
        p_Neutral.EnableStatistics(false);
        p_Neutral.SetAlly(p_Enemy1);
        p_Neutral.SetAlly(p_Enemy2);
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);

        //----------- AI ---------------------
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy0.LoadScript("single\\singleEasy");
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy0.SetName("translateAINameEasyUCS1");
            p_Enemy1.SetName("translateAINameEasyUCS2");
            p_Enemy2.SetName("translateAINameEasyUCS3");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy0.LoadScript("single\\singleMedium");
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Enemy0.SetName("translateAINameMediumUCS1");
            p_Enemy1.SetName("translateAINameMediumUCS2");
            p_Enemy2.SetName("translateAINameMediumUCS3");

        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy0.LoadScript("single\\singleHard");
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Enemy0.SetName("translateAINameHardUCS1");
            p_Enemy1.SetName("translateAINameHardUCS2");
            p_Enemy2.SetName("translateAINameHardUCS3");
        }
        
        //wylacz inteligencje graczy
        p_Enemy0.EnableAIFeatures(aiEnabled,false);
        
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
        
        p_Enemy1.SetAlly(p_Enemy2);
        p_Enemy1.SetAlly(p_Enemy0);
        
        p_Player.SetNeutral(p_Neutral);
        p_Enemy0.SetNeutral(p_Neutral);
        p_Enemy1.SetNeutral(p_Neutral);
        p_Enemy2.SetNeutral(p_Neutral);
        
        //----------- Money ------------------
        p_Player.SetMoney(10000);
        p_Enemy0.SetMoney(0);
        p_Enemy1.SetMoney(10000);
        p_Enemy2.SetMoney(30000);
        p_Neutral.SetMoney(0);
        
        //----------- Timers -----------------
        SetTimer(0, 40);
        //----------- Variables --------------
        bCheckEndMission = false;
        bUnitTransportersActivated = false;

        uFang = GetUnit(GetPointX(13),GetPointY(13),0);
        p_Player.AddUnitToSpecialTab(uFang,true, -1);

        p_Player.EnableBuilding("LCBLZ",false);
        p_Player.EnableBuilding("LCBRC",false); 
        p_Player.EnableBuilding("LCBSR",false); //Centrum wydobywczo-transportowe
        p_Player.EnableCommand(commandSoldBuilding,true);                  
        p_Player.SetMaxDistance(20);
        //---- Creating & destroying additional units -----
        if(GetDifficultyLevel()==0)
        {
            KillArea(p_Enemy1.GetIFF(), GetPointX(2), GetPointY(2), 0, 1);
            KillArea(p_Enemy1.GetIFF(), GetPointX(6), GetPointY(6), 0, 1);
            p_Player.CreateUnitEx(GetPointX(10), GetPointY(10), 0, null, "LCUCR3", "LCWHL2", null, null, null); 
            p_Player.CreateUnitEx(GetPointX(11), GetPointY(11), 0, null, "LCUCR3", "LCWHL2", null, null, null); 
            p_Player.CreateUnitEx(GetPointX(12), GetPointY(12), 0, null, "LCUCR3", "LCWHL2", null, null, null); 
        }
        if(GetDifficultyLevel()==1)
        {
            p_Player.CreateUnitEx(GetPointX(10), GetPointY(10), 0, null, "LCUCR3", "LCWHL2", null, null, null); 

            KillArea(p_Enemy1.GetIFF(), GetPointX(6), GetPointY(6), 0, 1);
        
            p_Enemy1.CreateUnitEx(GetPointX(3) - 1, GetPointY(3), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy1.CreateUnitEx(GetPointX(3) + 1, GetPointY(3), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy1.CreateUnitEx(GetPointX(4) - 1, GetPointY(4), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy1.CreateUnitEx(GetPointX(4) + 1, GetPointY(4), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR

            p_Enemy2.CreateUnitEx(GetPointX(8) - 1, GetPointY(8), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy2.CreateUnitEx(GetPointX(8) + 1, GetPointY(8), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.CreateUnitEx(GetPointX(3) - 1, GetPointY(3), 0, null, "UCSUML1", "UCSWSMR1", null, null, null,2); // Spider + hR
            p_Enemy1.CreateUnitEx(GetPointX(3) + 1, GetPointY(3), 0, null, "UCSUML1", "UCSWSMR1", null, null, null,2); // Spider + hR
            p_Enemy1.CreateUnitEx(GetPointX(4) - 1, GetPointY(4), 0, null, "UCSUML1", "UCSWSMR1", null, null, null,2); // Spider + hR
            p_Enemy1.CreateUnitEx(GetPointX(4) + 1, GetPointY(4), 0, null, "UCSUML1", "UCSWSMR1", null, null, null,2); // Spider + hR

            p_Enemy1.CreateUnitEx(GetPointX(5) - 1, GetPointY(5), 0, null, "UCSUHL1", "UCSWBSR1", null, null, null,2); // Panther + R
            p_Enemy1.CreateUnitEx(GetPointX(5) + 1, GetPointY(5), 0, null, "UCSUHL1", "UCSWBSR1", null, null, null,2); // Panther + R
            p_Enemy1.CreateUnitEx(GetPointX(7) - 1, GetPointY(7), 0, null, "UCSUHL1", "UCSWBSR1", null, null, null,2); // Panther + R
            p_Enemy1.CreateUnitEx(GetPointX(7) + 1, GetPointY(7), 0, null, "UCSUHL1", "UCSWBSR1", null, null, null,2); // Panther + R

            p_Enemy2.CreateUnitEx(GetPointX(8) - 1, GetPointY(8), 0, null, "UCSUML1", "UCSWSMR1", null, null, null,2); // Spider + hR
            p_Enemy2.CreateUnitEx(GetPointX(8) + 1, GetPointY(8), 0, null, "UCSUML1", "UCSWSMR1", null, null, null,2); // Spider + hR

            p_Enemy2.CreateUnitEx(GetPointX(8), GetPointY(8) - 1, 0, null, "UCSUHL1", "UCSWBHP1", null, null, null,1); // Panther + hP
            p_Enemy2.CreateUnitEx(GetPointX(8), GetPointY(8) + 1, 0, null, "UCSUHL1", "UCSWBHP1", null, null, null,1); // Panther + hP
        }
        
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        return ShowBriefing, 100;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing614a", p_Player.GetName());
        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {
        unitex uTransporter;
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(uFang!=null && !uFang.IsLive())
            {
                SetGoalState(goalFangHaveToSurvive, goalFailed);
                AddBriefing("translateFailed614", p_Player.GetName());
                return MissionFailed, 20;
            }

            if(GetGoalState(goalDestroyEnemy1)!= goalAchieved && !p_Enemy0.GetNumberOfUnits())
                SetGoalState(goalDestroyEnemy1, goalAchieved);

            if(GetGoalState(goalDestroyEnemy2)!= goalAchieved && !p_Enemy1.GetNumberOfBuildings())
                SetGoalState(goalDestroyEnemy2, goalAchieved);

            if(GetGoalState(goalDestroyEnemy3)!= goalAchieved && !p_Enemy2.GetNumberOfBuildings())
            {
                SetGoalState(goalDestroyEnemy3, goalAchieved);
            }
        }

        if(!bUnitTransportersActivated &&
            uFang!=null && uFang.IsLive() && uFang.GetLocationZ()==0 &&
            uFang.DistanceTo(GetPointX(14),GetPointY(14))<5)
        {
            bUnitTransportersActivated=true;
            p_Neutral.GiveAllUnitsTo(p_Player);

            uTransporter = GetUnit(GetPointX(14)-1,GetPointY(14),0);
            uTransporter.LoadScript("Scripts\\Units\\Transporter.ecomp");
            uTransporter = GetUnit(GetPointX(14)+1,GetPointY(14),0);
            uTransporter.LoadScript("Scripts\\Units\\Transporter.ecomp");
            uTransporter = GetUnit(GetPointX(14),GetPointY(14)+1,0);
            uTransporter.LoadScript("Scripts\\Units\\Transporter.ecomp");

            SetGoalState(goalActivateUnitTransporters,goalAchieved);
            AddBriefing("translateBriefing614b", p_Player.GetName());
        }
        if(GetGoalState(goalDestroyEnemy1)== goalAchieved && 
            GetGoalState(goalDestroyEnemy2)== goalAchieved && 
            GetGoalState(goalDestroyEnemy3)== goalAchieved && 
            GetGoalState(goalActivateUnitTransporters)== goalAchieved) 
        {
            SetGoalState(goalFangHaveToSurvive, goalAchieved);
            AddBriefing("translateAccomplished614", p_Player.GetName());
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
            AddBriefing("translateFailed614", p_Player.GetName());
            return MissionFailed, 20;
        }
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
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co minute
    {
    }
    
    //-----------------------------------------------------------------------------------------
    event EndMission() 
    {
        if(GetGoalState(goalDestroyEnemy1)== goalAchieved && 
            GetGoalState(goalDestroyEnemy2)== goalAchieved && 
            GetGoalState(goalDestroyEnemy3)== goalAchieved && 
            GetGoalState(goalActivateUnitTransporters)== goalAchieved) 
        {
            p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
            p_Player.SetMoney(0);
        }
    }
}
