mission "translateMission414"
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

        DestroyEnemy = 0;
    }

    player p_TmpPlayer;
    player p_Player;
    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;

    int nMoney;
    int bCheckEndMission;

    state Initialize;
    state ShowBriefing;
    state Working;
    state MissionFailed;
    state Nothing;

    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(DestroyEnemy, "translateGoal414DestroyEnemy");
        
                //---Show goals on list---
        EnableGoal(DestroyEnemy, true);
        
        //----------- Players ----------------
        p_Player = GetPlayer(1);    //UCS
        p_Enemy1 = GetPlayer(3);    //LC
        p_Enemy2 = GetPlayer(4);    //LC
        p_Enemy3 = GetPlayer(5);    //LC

        p_TmpPlayer = GetPlayer(2);
        p_TmpPlayer.EnableStatistics(false);
        
        //----------- AI ---------------------
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy3.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Enemy3.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Enemy3.LoadScript("single\\singleHard");

            p_Enemy1.AddResearch("RES_LCUME1");
            p_Enemy1.AddResearch("RES_LCUME2");
            p_Enemy1.AddResearch("RES_LCUME3");
            p_Enemy1.AddResearch("RES_LCUSF1");
            p_Enemy1.AddResearch("RES_LCUSF2");
            p_Enemy1.AddResearch("RES_LC_ASR1");
            p_Enemy1.AddResearch("RES_LC_ASR2");

            p_Enemy1.SetNumberOfOffensiveTankPlatoons(1);
            p_Enemy1.SetNumberOfOffensiveShipPlatoons(0);
            p_Enemy1.SetNumberOfOffensiveHelicopterPlatoons(3);
            p_Enemy1.SetNumberOfDefensiveTankPlatoons(1);
            p_Enemy1.SetNumberOfDefensiveShipPlatoons(0);
            p_Enemy1.SetNumberOfDefensiveHelicopterPlatoons(3);
            
            p_Enemy2.SetNumberOfOffensiveTankPlatoons(1);
            p_Enemy2.SetNumberOfOffensiveShipPlatoons(0);
            p_Enemy2.SetNumberOfOffensiveHelicopterPlatoons(3);
            p_Enemy2.SetNumberOfDefensiveTankPlatoons(1);
            p_Enemy2.SetNumberOfDefensiveShipPlatoons(0);
            p_Enemy2.SetNumberOfDefensiveHelicopterPlatoons(3);

            p_Enemy3.SetNumberOfOffensiveTankPlatoons(1);
            p_Enemy3.SetNumberOfOffensiveShipPlatoons(0);
            p_Enemy3.SetNumberOfOffensiveHelicopterPlatoons(3);
            p_Enemy3.SetNumberOfDefensiveTankPlatoons(1);
            p_Enemy3.SetNumberOfDefensiveShipPlatoons(0);
            p_Enemy3.SetNumberOfDefensiveHelicopterPlatoons(3);
        }
        p_Enemy1.EnableAIFeatures(aiUpgradeCannons,true);
        p_Enemy2.EnableAIFeatures(aiUpgradeCannons,true);
        p_Enemy3.EnableAIFeatures(aiUpgradeCannons,true);
        //wylacz inteligencje graczy
        p_Enemy1.EnableAIFeatures(aiBuildBuildings,false);
        p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
        p_Enemy3.EnableAIFeatures(aiBuildBuildings,false);

        p_Enemy1.EnableAIFeatures(aiRush,false);
        p_Enemy2.EnableAIFeatures(aiRush,false);
        p_Enemy3.EnableAIFeatures(aiRush,false);
        
        
        p_Enemy1.SetAlly(p_Enemy2);
        p_Enemy1.SetAlly(p_Enemy3);
        p_Enemy2.SetAlly(p_Enemy3);


        p_Player.AddResearch("RES_UCS_ART");
        p_Player.EnableResearch("RES_UCS_UML1", true);
        p_Player.EnableResearch("RES_MCH3", true);
        p_Player.EnableResearch("RES_MSR3", true);
        p_Player.EnableResearch("RES_UCS_MG3", true);
        p_Player.EnableResearch("RES_UCS_MGen", true);

        p_Enemy1.EnableResearch("RES_LC_WSL1",true);
        p_Enemy1.EnableResearch("RES_LC_WSR3",true);
        p_Enemy1.EnableResearch("RES_LC_MGen",true);

        p_Enemy2.CopyResearches(p_Enemy1);
        p_Enemy3.CopyResearches(p_Enemy1);
//----------- Money ------------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        if(GetDifficultyLevel()==0)
            p_Player.SetMoney(50000);
        if(GetDifficultyLevel()==1)
            p_Player.SetMoney(30000);
        if(GetDifficultyLevel()==2)
            p_Player.SetMoney(20000);

        p_Enemy1.SetMoney(3000);
        p_Enemy2.SetMoney(5000);
        p_Enemy3.SetMoney(10000);
        
        //----------- Timers -----------------
        //----------- Variables --------------
        bCheckEndMission=false;
        
        //---- Creating additional units -----
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.CreateUnitEx(GetPointX(0), GetPointY(0), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR

            p_Enemy2.CreateUnitEx(GetPointX(2), GetPointY(2), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR
            p_Enemy2.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR

            p_Enemy3.CreateUnitEx(GetPointX(6), GetPointY(6), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR
            p_Enemy3.CreateUnitEx(GetPointX(7), GetPointY(7), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.CreateUnitEx(GetPointX(0), GetPointY(0), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR
            p_Enemy1.CreateUnitEx(GetPointX(1), GetPointY(1), 0, null, "LCUCR3", "LCWMR3", null, null, null); // Crater m3 + R

            p_Enemy2.CreateUnitEx(GetPointX(2), GetPointY(2), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR
            p_Enemy2.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR
            p_Enemy2.CreateUnitEx(GetPointX(4), GetPointY(4), 0, null, "LCUCR3", "LCWMR3", null, null, null); // Crater m3 + R
            p_Enemy2.CreateUnitEx(GetPointX(5), GetPointY(5), 0, null, "LCUCR3", "LCWMR3", null, null, null); // Crater m3 + R

            p_Enemy3.CreateUnitEx(GetPointX(6), GetPointY(6), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR
            p_Enemy3.CreateUnitEx(GetPointX(7), GetPointY(7), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null); // Crusher m3 + hR
            p_Enemy3.CreateUnitEx(GetPointX(9), GetPointY(9), 0, null, "LCUCR3", "LCWMR3", null, null, null); // Crater m3 + R
            p_Enemy3.CreateUnitEx(GetPointX(10), GetPointY(10), 0, null, "LCUCR3", "LCWMR3", null, null, null); // Crater m3 + R
        }
        
        p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
        p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
        p_Player.EnableBuilding("UCSBSD", false);   //Laser antyrakietowy
        p_Player.EnableBuilding("UCSBLZ", false);   //Landing Zone

        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing, 100;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing414", p_Player.GetName());
        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {
    if(bCheckEndMission)
    {
            bCheckEndMission=false;
                        if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
                        {
                            SetGoalState(DestroyEnemy, goalFailed);
                            AddBriefing("translateFailed414", p_Player.GetName());
                            return MissionFailed, 20;
                        }

                        if(!p_Enemy1.GetNumberOfBuildings() && !p_Enemy2.GetNumberOfBuildings() && !p_Enemy3.GetNumberOfBuildings())
                        {
                            SetGoalState(DestroyEnemy, goalAchieved);
                        }
        }


        if(GetGoalState(DestroyEnemy) == goalAchieved)
        {
                AddBriefing("translateAccomplished414", p_Player.GetName());
                p_Player.EnableBuilding("UCSBLZ", true);    //Landing Zone
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
    event EndMission() 
    {
            if(GetGoalState(DestroyEnemy) == goalAchieved)
            {
                p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
                p_Player.SetMoney(0);
            }
        }
}
