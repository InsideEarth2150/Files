mission "translateMission612"
{//

    consts
    {
        scriptFieldMoney=9;
        goalDestroyEnemy1 = 0;
        goalDestroyEnemy2 = 1;
        goalFangHaveToSurvive = 2;
    }

    player p_TmpPlayer;
    player p_Player;
    player p_Enemy1;
    player p_Enemy2;
    player p_Neutral;

    int nMoney;
    int bCheckEndMission;
    int nMaxMeteorCounter;
    int nMeteorCounter;
    int nMeteorX;
    int nMeteorY;
    int b_FireMeteors;
    int nMeteorIntensity;
    int nMeteorPower;
    int nMeteorRange;

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
        RegisterGoal(goalDestroyEnemy1, "translateGoal612a");
        RegisterGoal(goalDestroyEnemy2, "translateGoal612b");
        RegisterGoal(goalFangHaveToSurvive, "translateGoal612c");

        //---Show goals on list---
        EnableGoal(goalDestroyEnemy1, true);
        EnableGoal(goalDestroyEnemy2, true);
        EnableGoal(goalFangHaveToSurvive, true);
        
        
        //----------- Players ----------------
        p_Player = GetPlayer(3);    //LC

        p_Enemy1 = GetPlayer(1);    //UCS
        p_Enemy2 = GetPlayer(5);    //UCS
    
        p_Neutral = GetPlayer(7);   //UCS
        p_Neutral.EnableStatistics(false);
        p_Neutral.SetAlly(p_Enemy1);
        p_Neutral.SetAlly(p_Enemy2);
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
    
        //----------- AI ---------------------
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");

        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");

        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
        }
        

        //wylacz inteligencje graczy
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy1.EnableAIFeatures(aiBuildBuildings,false);
        p_Enemy1.EnableAIFeatures(aiBuildBuilders,false);
        
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
        p_Enemy2.EnableAIFeatures(aiBuildBuilders,false);
        
        p_Enemy1.SetAlly(p_Enemy2);
        
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_Enemy1.SetMoney(20000);
        p_Enemy2.SetMoney(20000);
        
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
        p_Player.EnableBuilding("LCBLZ",false);

        p_Player.EnableBuilding("LCBUC",false);
        p_Player.EnableBuilding("LCBEN1",false);
        p_Player.EnableBuilding("LCLASERWALL",false);
        p_Player.EnableCommand(commandSoldBuilding,true);                  

        p_Player.EnableResearch("RES_LC_UME1",true);//613//612
        p_Player.EnableResearch("RES_LCCAA1",true);//612 
        p_Player.EnableResearch("RES_LCUSF1",true);//612 
        p_Player.AddResearch("RES_LCCAA1");//612 add
        p_Player.AddResearch("RES_LCUSF1");//612 add
        //----------- Timers -----------------
        SetTimer(0, 20);
        
        //----------- Variables --------------
        bCheckEndMission=false;
        if(GetDifficultyLevel()==0)
        {
            nMaxMeteorCounter=60*1;
            nMeteorIntensity = 3;
            nMeteorPower = 10;
            nMeteorRange = 12;
        }
        if(GetDifficultyLevel()==1)
        {
            nMaxMeteorCounter=60*2;
            nMeteorIntensity = 2;
            nMeteorPower = 7;
            nMeteorRange =10;
        }
        
        if(GetDifficultyLevel()==2)
        {
            nMaxMeteorCounter=60*3;
            nMeteorIntensity = 2;
            nMeteorPower = 6;
            nMeteorRange = 7;
        }
        
        nMeteorCounter = nMaxMeteorCounter;
        b_FireMeteors=true;
        uFang=GetUnit(GetPointX(12),GetPointY(12),0);
        p_Player.AddUnitToSpecialTab(uFang,true, -1);
        //---- Creating & destroying additional units -----
        if(GetDifficultyLevel()==0)
        {
            KillArea(p_Enemy1.GetIFF(), GetPointX(0), GetPointY(0), 0, 1);
            KillArea(p_Enemy1.GetIFF(), GetPointX(6), GetPointY(6), 0, 1);
            KillArea(p_Enemy2.GetIFF(), GetPointX(8), GetPointY(8), 0, 1);
            KillArea(p_Enemy2.GetIFF(), GetPointX(10),GetPointY(10), 0, 1);
        }
        if(GetDifficultyLevel()==1)
        {
            KillArea(p_Enemy1.GetIFF(), GetPointX(6), GetPointY(6), 0, 1);
            KillArea(p_Enemy2.GetIFF(), GetPointX(10), GetPointY(10), 0, 1);
        
            p_Enemy1.CreateUnitEx(GetPointX(1), GetPointY(1), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR

            p_Enemy1.CreateUnitEx(GetPointX(2), GetPointY(2), 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(4), GetPointY(4), 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(5), GetPointY(5), 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R

            p_Enemy2.CreateUnitEx(GetPointX(9), GetPointY(9), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.CreateUnitEx(GetPointX(1), GetPointY(1), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy1.CreateUnitEx(GetPointX(7), GetPointY(7), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR

            p_Enemy1.CreateUnitEx(GetPointX(2), GetPointY(2), 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(4), GetPointY(4), 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(5), GetPointY(5), 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(2), GetPointY(2) + 1, 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(3), GetPointY(3) + 1, 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(4), GetPointY(4) + 1, 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
            p_Enemy1.CreateUnitEx(GetPointX(5), GetPointY(5) + 1, 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R

            p_Enemy2.CreateUnitEx(GetPointX(9), GetPointY(9), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy2.CreateUnitEx(GetPointX(11), GetPointY(11), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
        }
        
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        return ShowBriefing, 100;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing612", p_Player.GetName());
        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!uFang.IsLive())
            {
                SetGoalState(goalFangHaveToSurvive,goalFailed);
                AddBriefing("translateFailed612", p_Player.GetName());
                return MissionFailed, 20;
            }
            
            if(!p_Enemy1.GetNumberOfBuildings())
            {
                SetGoalState(goalDestroyEnemy1, goalAchieved);
            }
            if(!p_Enemy2.GetNumberOfBuildings())
            {
                SetGoalState(goalDestroyEnemy2, goalAchieved);
            }
        }

        if(GetGoalState(goalDestroyEnemy1) == goalAchieved &&
            GetGoalState(goalDestroyEnemy2) == goalAchieved)
        {
            b_FireMeteors=false;
            SetGoalState(goalFangHaveToSurvive, goalAchieved);
            SetConsoleText("");
            AddBriefing("translateAccomplished612", p_Player.GetName());
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
        if(!uFang.IsLive())
        {
            SetGoalState(goalFangHaveToSurvive,goalFailed);
            AddBriefing("translateFailed612", p_Player.GetName());
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
    event Timer0() //wolany co sekunde
    {
        if(b_FireMeteors)
        {
            nMeteorCounter=nMeteorCounter-1;
            SetConsoleText("translateMessage612a",nMeteorCounter);
            if(!nMeteorCounter)
            {
                SetConsoleText("translateMessage612b");//FIRE!!!!!! blinking
                nMeteorCounter=nMaxMeteorCounter;
                if(uFang.IsLive() && uFang.IsInWorld(GetWorldNum()) && uFang.GetLocationZ()==0)
                {
                    nMeteorX = uFang.GetLocationX();
                    nMeteorY = uFang.GetLocationY();
                    MeteorRain(nMeteorX,nMeteorY,nMeteorRange,500,1000,500,nMeteorIntensity,nMeteorPower);
                }
            }
        }
    }
  //-----------------------------------------------------------------------------------------
    event EndMission() 
    {
        if(GetGoalState(goalDestroyEnemy1) == goalAchieved &&
            GetGoalState(goalDestroyEnemy2) == goalAchieved)
            {
                p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
                p_Player.SetMoney(0);
            }
        }

}
