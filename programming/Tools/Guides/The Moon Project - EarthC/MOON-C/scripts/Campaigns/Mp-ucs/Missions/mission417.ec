mission "translateMission417"
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

        DestroyGAMMA = 0;
        CopyData = 1;

        FirstOffenseAfter = 3; // minuty
        OffenseFrequency = 10; // minuty
        OffenseTime = 30; // sekundy
        FirstOffensePlayer = 3;
        LastOffensePlayer = 6;
    }

    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Enemy4;
    player p_Neutral;
    player p_Player;

    int nTimer0Counter;
    int nTimer1Counter;
    int nOffensePlayerNumber;
    player p_OffensePlayer;


    int MinStateOfBuildings1;
    int MinStateOfBuildings2;
    int MinStateOfBuildings3;
    int MinStateOfBuildings4;

    int CurrentStateOfBuildings1;
    int CurrentStateOfBuildings2;
    int CurrentStateOfBuildings3;
    int CurrentStateOfBuildings4;


    int DestroyGAMMA1Achieved;
    int DestroyGAMMA2Achieved;
    int DestroyGAMMA3Achieved;
    int DestroyGAMMA4Achieved;
    int CopyDataAchieved;
    int Briefing2Showed;

    int xBaseLC1;
    int yBaseLC1;

    int xBaseLC2;
    int yBaseLC2;

    int xBaseLC3;
    int yBaseLC3;

    int xBaseLC4;
    int yBaseLC4;

    int i;

    state Initialize;
    state ShowBriefing;
    state Working;
    state EndMissionFailed;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        DestroyGAMMA1Achieved = false;
        DestroyGAMMA2Achieved = false;
        DestroyGAMMA3Achieved = false;
        DestroyGAMMA4Achieved = false;
        CopyDataAchieved = false;
        Briefing2Showed = false;

        //----------- Timers -----------------
        SetTimer(0, 1200);
        SetTimer(1, 20);
        SetTimer(2, 20);

        //----------- Variables --------------
        nTimer0Counter = FirstOffenseAfter;
        nTimer1Counter = 0;
        nOffensePlayerNumber = FirstOffensePlayer - 1;


        //----------- Goals ------------------
        RegisterGoal(DestroyGAMMA, "translateGoalDestroyBaseGAMMA");
        RegisterGoal(CopyData, "translateGoalCopyData");

                //---show goals on list---
        EnableGoal(DestroyGAMMA,true);
        EnableGoal(CopyData,true);
                

        //----------- Players ----------------
        p_Player = GetPlayer(1);    //ja czyli UCS
        p_Enemy1 = GetPlayer(3);    //LC
        p_Enemy2 = GetPlayer(4);    //LC
        p_Enemy3 = GetPlayer(5);    //LC
        p_Enemy4 = GetPlayer(6);    //LC

        p_Neutral = GetPlayer(7);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableStatistics(false);
        p_Player.SetNeutral(p_Neutral);
        p_Enemy1.SetNeutral(p_Neutral);
        p_Enemy2.SetNeutral(p_Neutral);
        p_Enemy3.SetNeutral(p_Neutral);
        p_Enemy4.SetNeutral(p_Neutral);
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

                //----AI off-------------
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy3.EnableAIFeatures(aiControlOffense,false);
        p_Enemy4.EnableAIFeatures(aiControlOffense,false);

        p_Enemy1.EnableAIFeatures(aiControlDefense,false);
        p_Enemy2.EnableAIFeatures(aiControlDefense,false);
        p_Enemy3.EnableAIFeatures(aiControlDefense,false);
        p_Enemy4.EnableAIFeatures(aiControlDefense,false);

        p_Enemy1.EnableAIFeatures(aiRush,false);
        p_Enemy2.EnableAIFeatures(aiRush,false);
        p_Enemy3.EnableAIFeatures(aiRush,false);
        
        //----------- Money ------------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        p_Player.SetMoney(15000);
        p_Enemy1.SetMoney(10000);
        p_Enemy2.SetMoney(10000);
        p_Enemy3.SetMoney(10000);
        p_Enemy4.SetMoney(10000);

        p_Player.SetMilitaryUnitsLimit(50000);



        //---Variables----
        xBaseLC1 = p_Enemy1.GetStartingPointX();
        yBaseLC1 = p_Enemy1.GetStartingPointY();

        xBaseLC2 = p_Enemy2.GetStartingPointX();
        yBaseLC2 = p_Enemy2.GetStartingPointY();

        xBaseLC3 = p_Enemy3.GetStartingPointX();
        yBaseLC3 = p_Enemy3.GetStartingPointY();

        xBaseLC4 = p_Enemy4.GetStartingPointX();
        yBaseLC4 = p_Enemy4.GetStartingPointY();

        //---Artefacts : computers to capture ----
        CreateArtefact("NEACOMPUTER", GetPointX(0), GetPointY(0),GetPointZ(0),0,artefactSpecialAIOther);
        
        p_Enemy2.SetAlly(p_Enemy1);
        p_Enemy3.SetAlly(p_Enemy1);
        p_Enemy4.SetAlly(p_Enemy1);

        p_Enemy2.CopyResearches(p_Enemy1);
        p_Enemy3.CopyResearches(p_Enemy1);
        p_Enemy4.CopyResearches(p_Enemy1);

        p_Enemy1.EnableBuilding("LCCSD", false);    //Laser antyrakietowy
        p_Enemy2.EnableBuilding("LCCSD", false);    //Laser antyrakietowy
        p_Enemy3.EnableBuilding("LCCSD", false);    //Laser antyrakietowy
        p_Enemy4.EnableBuilding("LCCSD", false);    //Laser antyrakietowy

        p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
        p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
        p_Player.EnableBuilding("UCSCSD", false);   //Laser antyrakietowy

        p_Player.EnableResearch("RES_UCS_BHD", true);
        p_Player.EnableResearch("RES_UCS_BOMBER22", true);
        p_Player.EnableResearch("RES_UCS_SHD2", true);

        MinStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings()/5;
        MinStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings()/5;
        MinStateOfBuildings3 = p_Enemy3.GetNumberOfBuildings()/5;
        MinStateOfBuildings4 = p_Enemy4.GetNumberOfBuildings()/5;

        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(), 6, 0, 20, 0);
        return ShowBriefing;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
            //show campaign goal 2
            p_Player.SetScriptData(scriptFieldGoal5, 1);

            //show mission briefing
            AddBriefing("translateBriefing417a", p_Player.GetName());

            return Working;
    }

        //-----------------------------------------------------------------------------------------
        state Working
        {
            if(!p_Player.GetNumberOfUnits())
            {
                AddBriefing("translateFailed417", p_Player.GetName());
                return EndMissionFailed;
            }

            //--------- check goals --------------------------------

            //----capture LC base---

            if(!DestroyGAMMA1Achieved)
            {
                CurrentStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings();
                if(CurrentStateOfBuildings1 < 3)
                {
                    p_Enemy1.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy1.SetMoney(0);
                    DestroyGAMMA1Achieved = true;
                }
            }

            if(!DestroyGAMMA2Achieved)
            {
                CurrentStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings();
                if(CurrentStateOfBuildings2 < 3)
                {
                    p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy2.SetMoney(0);
                    DestroyGAMMA2Achieved = true;
                }
            }

            if(!DestroyGAMMA3Achieved)
            {
                CurrentStateOfBuildings3 = p_Enemy3.GetNumberOfBuildings();
                if(CurrentStateOfBuildings3 < 3)
                {
                    p_Enemy3.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy3.SetMoney(0);
                    DestroyGAMMA3Achieved = true;
                }
            }

            if(!DestroyGAMMA4Achieved)
            {
                CurrentStateOfBuildings4 = p_Enemy4.GetNumberOfBuildings();
                if(CurrentStateOfBuildings4 < 3)
                {
                    p_Enemy4.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy4.SetMoney(0);
                    DestroyGAMMA4Achieved = true;
                }
            }



            if(!Briefing2Showed)
            {
                if(p_Player.IsPointLocated(xBaseLC1, yBaseLC1) || p_Player.IsPointLocated(xBaseLC2, yBaseLC2) || 
                   p_Player.IsPointLocated(xBaseLC3, yBaseLC3) || p_Player.IsPointLocated(xBaseLC4, yBaseLC4) ||
                   p_Player.IsPointLocated(GetPointX(0), GetPointY(0),GetPointZ(0)))
                {
                    Briefing2Showed = true;
                    AddBriefing("translateBriefing417b", p_Player.GetName());
                }
            }

            if(DestroyGAMMA1Achieved && DestroyGAMMA2Achieved && DestroyGAMMA3Achieved && DestroyGAMMA4Achieved &&
                GetGoalState(DestroyGAMMA)!=goalAchieved)
            {
                //check mission goal
                SetGoalState(DestroyGAMMA, goalAchieved);

            }

            //mission achieved
            if(DestroyGAMMA1Achieved && DestroyGAMMA2Achieved && DestroyGAMMA3Achieved && DestroyGAMMA4Achieved && CopyDataAchieved)
            {
                //check campaign goal 4
                p_Player.SetScriptData(scriptFieldGoal5, 2);
                EnableNextMission(0,true);
                AddBriefing("translateAccomplished417", p_Player.GetName());
                EnableEndMissionButton(true);
                return Nothing;
            }

            return Working;
        }


        state EndMissionFailed
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

        //---capture CPU---
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        CopyDataAchieved = true;
        SetGoalState(CopyData, goalAchieved);
        return true;
    }

        //-----------------------------------------------------------------------------------------
        event Timer0() //wolany co minute
        {
            nTimer0Counter = nTimer0Counter - 1;

            if(nTimer0Counter == 0) // start ofensywy
            {
                nOffensePlayerNumber = nOffensePlayerNumber + 1;

                if(nOffensePlayerNumber == LastOffensePlayer + 1)
                    nOffensePlayerNumber = FirstOffensePlayer;
                
                p_OffensePlayer = GetPlayer(nOffensePlayerNumber);
                
                if(p_OffensePlayer.GetNumberOfUnits())
                {
                    p_OffensePlayer.EnableAIFeatures(aiControlOffense, true);
                    p_OffensePlayer.EnableAIFeatures(aiControlDefense, true);
                
                    nTimer0Counter = OffenseFrequency;
                    nTimer1Counter = OffenseTime;
                        }
                if(!p_OffensePlayer.GetNumberOfUnits())
                {
                    nTimer0Counter = 1;
                }
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
                    p_OffensePlayer.EnableAIFeatures(aiControlOffense,false);
                    p_OffensePlayer.EnableAIFeatures(aiControlOffense,false);
                }
            }
        }
  //-----------------------------------------------------------------------------------------
    event Timer2() 
    {
        DamageArea(p_Player.GetIFF(),GetPointX(4),GetPointY(4),0,7,5);
        DamageArea(p_Player.GetIFF(),GetPointX(5),GetPointY(5),0,8,5);
        DamageArea(p_Player.GetIFF(),GetPointX(6),GetPointY(6),0,7,5);
        DamageArea(p_Player.GetIFF(),GetPointX(7),GetPointY(7),0,6,5);
    }
//-----------------------------------------------------------------------------------------
    event EndMission() 
    {
            if(DestroyGAMMA1Achieved && DestroyGAMMA2Achieved && DestroyGAMMA3Achieved && DestroyGAMMA4Achieved && CopyDataAchieved)
            {
                p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
                p_Player.SetMoney(0);
            }
        }

}
