mission "translateMission416"
{

    consts
    {
            scriptFieldGoal1=0;
            scriptFieldGoal2=1;
            scriptFieldGoal3=2;
            scriptFieldGoal4=3;
            scriptFieldGoal5=4;
            scriptFieldGoal6=5;
            scriptFieldMoney=9;
            scriptFieldMeteors=10;

      goalTakeOverEnemyPos = 0;
        goalDestroyEnemy = 1;

        FirstOffenseAfter = 25; // minuty
        OffenseFrequency = 10; // minuty
        OffenseTime = 30; // sekundy
    }

    player p_TmpPlayer;
    player p_Player;
    player p_Enemy;
    
    int bCheckEndMission;
    
    int nTimer0Counter;
    int nTimer1Counter;
    
    int nMinNoOfBuildings;
    int nCurrNoOfBuildings;
    
    unitex Most1Wieza1;
    unitex Most1Wieza2;
    unitex Most1Wieza3;
    unitex Most2Wieza1;
    unitex Most2Wieza2;
    unitex Most2Wieza3;
    unitex Most3Wieza1;
    unitex Most3Wieza2;
    unitex Most3Wieza3;
    
    state Initialize;
    state ShowBriefing;
    state Working;
    state MissionFailed;
    state Nothing;

    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(goalTakeOverEnemyPos, "translateGoal416TakeOverEnemyPos");
        RegisterGoal(goalDestroyEnemy, "translateGoal416DestroyEnemy");

        //---Show goals on list---
        EnableGoal(goalTakeOverEnemyPos, true);
        EnableGoal(goalDestroyEnemy, true);
        
        //----------- Players ----------------
        p_Player = GetPlayer(1);    //UCS
        p_Enemy = GetPlayer(3);     //LC

        p_TmpPlayer = GetPlayer(2);
        p_TmpPlayer.EnableStatistics(false);
        
        //----------- AI ---------------------
        
        if(GetDifficultyLevel()==0)
            p_Enemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy.LoadScript("single\\singleHard");

        p_Player.SetMilitaryUnitsLimit(45000);

        //wylacz inteligencje graczy
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        p_Enemy.EnableAIFeatures(aiControlDefense,false);
        
        p_Enemy.EnableResearch("RES_LC_UCU1",true);
        p_Enemy.EnableResearch("RES_LC_UBO1",true);
        p_Enemy.EnableResearch("RES_LC_AMR1",true);
        p_Enemy.EnableResearch("RES_LC_HGen",true);
        p_Enemy.AddResearch("RES_LC_WARTILLERY");

        //----------- Money ------------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        p_Player.SetMoney(10000);
        p_Enemy.SetMoney(10000);
        
        //----------- Timers -----------------
        SetTimer(0, 1200);
        SetTimer(1, 20);

        //----------- Variables --------------
        bCheckEndMission=false;

        nTimer0Counter = FirstOffenseAfter;
        nTimer1Counter = 0;
        
        Most1Wieza1 = GetUnit(GetPointX(25),GetPointY(25),0);
        Most1Wieza2 = GetUnit(GetPointX(26),GetPointY(26),0);
        Most1Wieza3 = GetUnit(GetPointX(27),GetPointY(27),0);
        Most2Wieza1 = GetUnit(GetPointX(28),GetPointY(28),0);
        Most2Wieza2 = GetUnit(GetPointX(29),GetPointY(29),0);
        Most2Wieza3 = GetUnit(GetPointX(30),GetPointY(30),0);
        Most3Wieza1 = GetUnit(GetPointX(31),GetPointY(31),0);
        Most3Wieza2 = GetUnit(GetPointX(32),GetPointY(32),0);
        Most3Wieza3 = GetUnit(GetPointX(33),GetPointY(33),0);

        //---- Creating & destroying additional units -----
        if(GetDifficultyLevel()==0)
        {
            KillArea(p_Enemy.GetIFF(), GetPointX(0), GetPointY(0), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(3), GetPointY(3), 0, 1);
        }

        if(GetDifficultyLevel()==1)
        {
            KillArea(p_Enemy.GetIFF(), GetPointX(3), GetPointY(3), 0, 1);

            p_Enemy.CreateUnitEx(GetPointX(1), GetPointY(1), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null,1); // Crusher m3 + hR
            p_Enemy.CreateUnitEx(GetPointX(2), GetPointY(2), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null,1); // Crusher m3 + hR

            p_Enemy.CreateUnitEx(GetPointX(10), GetPointY(10), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(11), GetPointY(11), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(12), GetPointY(12), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR

            p_Enemy.CreateUnitEx(GetPointX(6), GetPointY(6), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(8), GetPointY(8), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(14), GetPointY(14), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR

            p_Enemy.CreateUnitEx(GetPointX(7), GetPointY(7), 0, null, "LCUCR3", "LCWHL2", null, null, null,2); // Lunar m3 + 20mm
            p_Enemy.CreateUnitEx(GetPointX(9), GetPointY(9), 0, null, "LCUCR3", "LCWHL2", null, null, null,2); // Lunar m3 + 20mm
            p_Enemy.CreateUnitEx(GetPointX(15), GetPointY(15), 0, null, "LCUCR3", "LCWHL2", null, null, null,2); // Lunar m3 + 20mm
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.CreateUnitEx(GetPointX(1), GetPointY(1), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null,1); // Crusher m3 + hR
            p_Enemy.CreateUnitEx(GetPointX(2), GetPointY(2), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null,1); // Crusher m3 + hR
            p_Enemy.CreateUnitEx(GetPointX(4), GetPointY(4), 0, null, "LCUCR3", "LCWMR3", null, null, null,2); // Crater m3 + R
            p_Enemy.CreateUnitEx(GetPointX(5), GetPointY(5), 0, null, "LCUCR3", "LCWMR3", null, null, null,2); // Crater m3 + R

            p_Enemy.CreateUnitEx(GetPointX(10), GetPointY(10), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(11), GetPointY(11), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(12), GetPointY(12), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(22), GetPointY(22), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null,2);
            p_Enemy.CreateUnitEx(GetPointX(23), GetPointY(23), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null,2);
            p_Enemy.CreateUnitEx(GetPointX(24), GetPointY(24), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null,2);

            p_Enemy.CreateUnitEx(GetPointX(6), GetPointY(6), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(8), GetPointY(8), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(14), GetPointY(14), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(16), GetPointY(16), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(17), GetPointY(17), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR
            p_Enemy.CreateUnitEx(GetPointX(18), GetPointY(18), 0, null, "LCUBO2", "LCWAMR2", null, null, null,1); // Thunder m2 + hR

            p_Enemy.CreateUnitEx(GetPointX(7), GetPointY(7), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null,2); 
            p_Enemy.CreateUnitEx(GetPointX(9), GetPointY(9), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null,2); 
            p_Enemy.CreateUnitEx(GetPointX(15), GetPointY(15), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null,2); 
            p_Enemy.CreateUnitEx(GetPointX(19), GetPointY(19), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null,2); 
            p_Enemy.CreateUnitEx(GetPointX(20), GetPointY(20), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null,2); 
            p_Enemy.CreateUnitEx(GetPointX(21), GetPointY(21), 0, null, "LCUCR3", "LCWHL2", null, "LCWSL2", null,2); 
        }
        

        nMinNoOfBuildings = p_Enemy.GetNumberOfBuildings() / 5;
        
        p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
        p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
        p_Player.EnableBuilding("UCSCSD", false);   //Laser antyrakietowy

        p_Player.EnableResearch("RES_UCS_UBL1", true);
        p_Player.EnableResearch("RES_UCS_UMI1", true);
        p_Player.EnableResearch("RES_UCS_BOMBER21", true);
        p_Player.EnableResearch("RES_UCS_WHP3", true);
        p_Player.EnableResearch("RES_UCS_WMR2", true);
        p_Player.EnableResearch("RES_UCS_WAMR1", true);
        p_Player.EnableResearch("RES_MMR3", true);
                
        
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing, 100;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing416", p_Player.GetName());
        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {
        if(GetGoalState(goalTakeOverEnemyPos) == goalAchieved && GetGoalState(goalDestroyEnemy) == goalAchieved)
        {
            AddBriefing("translateAccomplished416", p_Player.GetName());
            EnableNextMission(0, true);
            EnableEndMissionButton(true);
            return Nothing;
        }

        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                if(GetGoalState(goalTakeOverEnemyPos) != goalAchieved)
                    SetGoalState(goalTakeOverEnemyPos, goalFailed);
                if(GetGoalState(goalDestroyEnemy) != goalAchieved)
                    SetGoalState(goalDestroyEnemy, goalFailed);
            
                AddBriefing("translateFailed416", p_Player.GetName());
                return MissionFailed, 20;
            }
            
            nCurrNoOfBuildings = p_Enemy.GetNumberOfBuildings();
            
            if(nCurrNoOfBuildings < nMinNoOfBuildings)
            {
                p_Enemy.EnableAIFeatures(aiBuildBuildings, false);
                p_Enemy.SetMoney(0);
                
                if(!nCurrNoOfBuildings)
                    SetGoalState(goalTakeOverEnemyPos, goalAchieved);
            }
            
            if(!p_Enemy.GetNumberOfUnits())
                SetGoalState(goalDestroyEnemy, goalAchieved);
            
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
        nTimer0Counter = nTimer0Counter - 1;

        if(nTimer0Counter == 0) // start ofensywy
        {
            p_Enemy.EnableAIFeatures(aiControlOffense, true);
            p_Enemy.EnableAIFeatures(aiControlDefense, true);
            
            nTimer0Counter = OffenseFrequency;
            nTimer1Counter = OffenseTime;
        }
    }
    
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co sekunde
    {
        if(nTimer1Counter > 0)
        {
            nTimer1Counter = nTimer1Counter - 1;
            
            if(nTimer1Counter == 0) // stop ofensywy
            {
                p_Enemy.EnableAIFeatures(aiControlOffense, false);
                p_Enemy.EnableAIFeatures(aiControlDefense, false);
            }
        }
    }
//-----------------------------------------------------------------------------------------
    event EndMission() 
    {
            if(GetGoalState(goalTakeOverEnemyPos) == goalAchieved && GetGoalState(goalDestroyEnemy) == goalAchieved)
            {
                p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
                p_Player.SetMoney(0);
            }
        }
    
}
