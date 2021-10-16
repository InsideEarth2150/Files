mission "translateMission418"
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

        DestroyPowerPlants = 0;
    }

    
    player p_Player;
    player p_Enemy1;
    player p_Enemy2;
    player p_Neutral;
    
    int bCheckEndMission;
    int bReinforcementsOnTheWay;
    int nCallReinforcements;
    
    unitex Elektr1;
    unitex Elektr2;
    unitex Elektr3;
    unitex Elektr4;
    unitex Elektr5;
    unitex Elektr6;

    
    state Initialize;
    state ShowBriefing;
    state Working;
    state MissionFailed;
    state Nothing;

    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(DestroyPowerPlants, "translateGoal418DestroyPowerPlants");

        //---Show goals on list---
        EnableGoal(DestroyPowerPlants, true);
        
        //----------- Players ----------------
        p_Player = GetPlayer(1);    //UCS
        p_Enemy1 = GetPlayer(3);    //LC
        p_Enemy2 = GetPlayer(5);    //LC
        p_Enemy2.EnableStatistics(false);

        p_Enemy1.SetAlly(p_Enemy2);
        p_Enemy2.SetAlly(p_Enemy1);

        p_Neutral = GetPlayer(4);
        p_Neutral.EnableStatistics(false);

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
        p_Enemy1.EnableAIFeatures(aiControlDefense,false);
        p_Enemy2.EnableAIFeatures(aiEnabled,false);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlDefense,false);
        
        p_Enemy1.SetNeutral(p_Neutral);
        p_Enemy2.SetNeutral(p_Neutral);
        p_Player.SetNeutral(p_Neutral);

        //----------- Money ------------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        p_Player.SetMoney(0);
        p_Neutral.SetMoney(0);
        p_Enemy1.SetMoney(0);
        p_Enemy2.SetMoney(0);
        
        //----------- Variables --------------
        bCheckEndMission = false;
        
        bReinforcementsOnTheWay = false;
        nCallReinforcements = 0;
        
        Elektr1 = GetUnit(GetPointX(1), GetPointY(1), 0);
        Elektr2 = GetUnit(GetPointX(2), GetPointY(2), 0);
        Elektr3 = GetUnit(GetPointX(3), GetPointY(3), 0);
        Elektr4 = GetUnit(GetPointX(4), GetPointY(4), 0);
        Elektr5 = GetUnit(GetPointX(5), GetPointY(5), 0);
        Elektr6 = GetUnit(GetPointX(6), GetPointY(6), 0);
        
        
        //---- Creating & destroying additional units -----
        if(GetDifficultyLevel()==0)
        {
                    p_Player.CreateUnitEx(GetPointX(0) + 1, GetPointY(0) - 2, 0, null, "UCSUHL1", "UCSWBMR1", null, null, null); // Panther + hR
                    p_Player.CreateUnitEx(GetPointX(0) - 2, GetPointY(0) - 1, 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
                    p_Player.CreateUnitEx(GetPointX(0) + 2, GetPointY(0) - 1, 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
                    p_Player.CreateUnitEx(GetPointX(0) - 2, GetPointY(0), 0, null, "UCSUSL1", "UCSWTSP1", null, null, null); // Tiger + P
                    p_Player.CreateUnitEx(GetPointX(0) + 2, GetPointY(0), 0, null, "UCSUSL1", "UCSWTSP1", null, null, null); // Tiger + P
        }

        if(GetDifficultyLevel()==1)
        {
                    p_Player.CreateUnitEx(GetPointX(0), GetPointY(0) - 2, 0, null, "UCSUHL1", "UCSWBMR1", null, null, null); // Panther + hR
                    p_Player.CreateUnitEx(GetPointX(0), GetPointY(0) - 1, 0, null, "UCSUSL1", "UCSWTSR1", null, null, null); // Tiger + R
                    p_Player.CreateUnitEx(GetPointX(0), GetPointY(0), 0, null, "UCSUSL1", "UCSWTSP1", null, null, null); // Tiger + P
        }
        
                p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
                p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
                p_Player.EnableBuilding("UCSCSD", false);   //Laser antyrakietowy

                p_Player.EnableResearch("RES_UCS_BOMBER31", true);
                p_Player.EnableResearch("RES_UCS_WAPB1", true);
                p_Player.EnableResearch("RES_UCS_SHD3", true);

                
                p_Enemy2.CopyResearches(p_Enemy1);
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing, 100;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing418", p_Player.GetName());
        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {

        if(!bReinforcementsOnTheWay)
        {
            if(!Elektr1.IsLive() || !Elektr2.IsLive() || !Elektr3.IsLive() || !Elektr4.IsLive()
               || !Elektr5.IsLive() || !Elektr6.IsLive())
            {
                nCallReinforcements = nCallReinforcements + 1;
                
                if(nCallReinforcements > 60) // po 5 minutach
                {
                    p_Enemy2.EnableAIFeatures(aiEnabled,true);
                    p_Enemy2.EnableAIFeatures(aiControlOffense, true);
                    p_Enemy2.EnableAIFeatures(aiControlDefense, true);
                    p_Enemy2.RussianAttack(p_Enemy1.GetStartingPointX(), p_Enemy1.GetStartingPointY(), 0);
                            bReinforcementsOnTheWay = true;
                }
            }
        }
    
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits())
            {
                SetGoalState(DestroyPowerPlants, goalFailed);
                AddBriefing("translateFailed418", p_Player.GetName());
                return MissionFailed, 20;
            }
            
            if(!Elektr1.IsLive() && !Elektr2.IsLive() && !Elektr3.IsLive() && !Elektr4.IsLive()
               && !Elektr5.IsLive() && !Elektr6.IsLive())
            {
                SetGoalState(DestroyPowerPlants, goalAchieved);
                AddBriefing("translateAccomplished418", p_Player.GetName());
                EnableNextMission(0, true);
                EnableEndMissionButton(true);
                return Nothing;
            }
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
            if(!Elektr1.IsLive() && !Elektr2.IsLive() && !Elektr3.IsLive() && !Elektr4.IsLive()
               && !Elektr5.IsLive() && !Elektr6.IsLive())
            {
                p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
                p_Player.SetMoney(0);
            }
        }

}
