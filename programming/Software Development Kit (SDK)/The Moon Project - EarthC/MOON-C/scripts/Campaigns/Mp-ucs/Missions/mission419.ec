mission "translateMission419"
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

            DestroyDELTA = 0;

        FirstOffenseAfter = 15; // minuty
        OffenseFrequency = 3; // minuty
        OffenseTime = 30; // sekundy
        FirstOffensePlayer = 3;
        LastOffensePlayer = 5;
    }

    int nTimer0Counter;
    int nTimer1Counter;
    int nOffensePlayerNumber;
    player p_OffensePlayer;

    player p_Enemy1;
        player p_Enemy2;
        player p_Enemy3;
    player p_Player;
        player p_PlayerLC;
        player p_Neutral;

        int DestroyDELTA1Achieved;
        int DestroyDELTA2Achieved;
        int DestroyDELTA3Achieved;


        int MinStateOfBuildings1;
        int MinStateOfBuildings2;
        int MinStateOfBuildings3;

        int CurrentStateOfBuildings1;
        int CurrentStateOfBuildings2;
        int CurrentStateOfBuildings3;

        
        int i;

    state Initialize;
    state ShowBriefing;
        state Working;
        state EndMissionFailed;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
                DestroyDELTA1Achieved = false;
                DestroyDELTA2Achieved = false;
                DestroyDELTA3Achieved = false;

        //----------- Timers -----------------
                SetTimer(0, 1200);
                SetTimer(1, 20);
                SetTimer(2, 20);
        //----------- Variables --------------
                nTimer0Counter = FirstOffenseAfter;
                nTimer1Counter = 0;
                nOffensePlayerNumber = FirstOffensePlayer - 1;

        //----------- Goals ------------------
        RegisterGoal(DestroyDELTA, "translateGoalDestroyBaseDELTA");

                //---show goals on list---
        EnableGoal(DestroyDELTA,true);
                

        //----------- Players ----------------
        p_Player = GetPlayer(1);    //ja czyli UCS
        p_Enemy1 = GetPlayer(3);    //LC
                p_Enemy2 = GetPlayer(4);    //LC
                p_Enemy3 = GetPlayer(5);    //LC

                p_Neutral = GetPlayer(6);
                p_Neutral.EnableAIFeatures(aiEnabled,false);
                p_Neutral.EnableStatistics(false);
                p_Player.SetNeutral(p_Neutral);
                p_Enemy1.SetNeutral(p_Neutral);
                p_Enemy2.SetNeutral(p_Neutral);
                p_Enemy3.SetNeutral(p_Neutral);
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
                }


        //----AI off-------------
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy3.EnableAIFeatures(aiControlOffense,false);

        p_Enemy1.EnableAIFeatures(aiControlDefense,false);
        p_Enemy2.EnableAIFeatures(aiControlDefense,false);
        p_Enemy3.EnableAIFeatures(aiControlDefense,false);

        p_Enemy1.EnableAIFeatures(aiRush,false);
        p_Enemy2.EnableAIFeatures(aiRush,false);
        p_Enemy3.EnableAIFeatures(aiRush,false);
        
        //----------- Money ------------------
                p_Player.EnableCommand(commandSoldBuilding,true);
                p_Player.SetMoney(20000);
                p_Enemy1.SetMoney(10000);
                p_Enemy2.SetMoney(10000);
                p_Enemy3.SetMoney(10000);

                p_Player.SetMilitaryUnitsLimit(60000);



                p_Enemy2.SetAlly(p_Enemy1);
                p_Enemy3.SetAlly(p_Enemy1);


                p_Enemy1.EnableBuilding("LCCSD", false);    //Laser antyrakietowy
                p_Enemy2.EnableBuilding("LCCSD", false);    //Laser antyrakietowy
                p_Enemy3.EnableBuilding("LCCSD", false);    //Laser antyrakietowy


                p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
                p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
                p_Player.EnableBuilding("UCSCSD", false);   //Laser antyrakietowy

                MinStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings()/5;
                MinStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings()/5;
                MinStateOfBuildings3 = p_Enemy3.GetNumberOfBuildings()/5;

                //----------- Researches -------------
                

                p_Player.EnableResearch("RES_UCS_WAPB2", true);
                p_Player.EnableResearch("RES_UCS_MB2", true);
                p_Player.EnableResearch("RES_UCS_SHD4", true);
                
                p_Enemy2.CopyResearches(p_Enemy1);
                p_Enemy3.CopyResearches(p_Enemy1);

        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(), 6, 0, 20, 0);
        return ShowBriefing;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
            //show campaign goal 2
            p_Player.SetScriptData(scriptFieldGoal6, 1);

            //show mission briefing
            AddBriefing("translateBriefing419", p_Player.GetName());

            return Working;
    }

        //-----------------------------------------------------------------------------------------
        state Working
        {
            if(!p_Player.GetNumberOfUnits())
            {
                AddBriefing("translateFailed419", p_Player.GetName());
                return EndMissionFailed;
            }

            //--------- check goals --------------------------------

            //----capture LC base---

            if(!DestroyDELTA1Achieved)
            {
                CurrentStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings();

                if(CurrentStateOfBuildings1 < MinStateOfBuildings1)
                {
                    p_Enemy1.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy1.SetMoney(0);

                    if(!CurrentStateOfBuildings1)
                        DestroyDELTA1Achieved = true;
                }
            }

            if(!DestroyDELTA2Achieved)
            {
                CurrentStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings();

                if(CurrentStateOfBuildings2 < MinStateOfBuildings2)
                {
                    p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy2.SetMoney(0);

                    if(!CurrentStateOfBuildings2)
                        DestroyDELTA2Achieved = true;
                }
            }

            if(!DestroyDELTA3Achieved)
            {
                CurrentStateOfBuildings3 = p_Enemy3.GetNumberOfBuildings();

                if(CurrentStateOfBuildings3 < MinStateOfBuildings3)
                {
                    p_Enemy3.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy3.SetMoney(0);

                    if(!CurrentStateOfBuildings3)
                        DestroyDELTA3Achieved = true;
                }
            }


            //mission achieved
            if(DestroyDELTA1Achieved && DestroyDELTA2Achieved && DestroyDELTA3Achieved)
            {
                //check campaign goal 4
                p_Player.SetScriptData(scriptFieldGoal6, 2);
                //check mission goal
                SetGoalState(DestroyDELTA, goalAchieved);

                EnableNextMission(0,true);
                AddBriefing("translateAccomplished419", p_Player.GetName());
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
        DamageArea(p_Player.GetIFF(),GetPointX(0),GetPointY(0),0,4,5);
        DamageArea(p_Player.GetIFF(),GetPointX(1),GetPointY(1),0,4,5);
        DamageArea(p_Player.GetIFF(),GetPointX(2),GetPointY(2),0,6,5);
    }
//-----------------------------------------------------------------------------------------
    event EndMission() 
    {
        if(DestroyDELTA1Achieved && DestroyDELTA2Achieved && DestroyDELTA3Achieved)
        {
            p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
            p_Player.SetMoney(0);
        }
    }

}
