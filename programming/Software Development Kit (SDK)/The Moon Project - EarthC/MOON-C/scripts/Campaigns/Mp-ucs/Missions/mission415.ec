//mission starts from meteor rain in base(completly destroy)
//then first goal - destroy weather control buildings if not meteor rain in main base.


mission "translateMission415"
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

            DestroyBETA = 0;
            goalDestroyWC = 1;
            

        FirstOffenseAfter = 30; // minuty
        OffenseFrequency = 10; // minuty
        OffenseTime = 30; // sekundy
        FirstOffensePlayer = 3;
        LastOffensePlayer = 5;
    }

    int nTimer0Counter;
    int nTimer1Counter;
        int nMeteorShowerCounter;
    int nOffensePlayerNumber;
        int bFireMeteor;

    player p_OffensePlayer;


    player p_Enemy1;
        player p_Enemy2;
        player p_Enemy3;
    player p_Player;
    player p_Neutral;

        int DestroyBETA1Achieved;
        int DestroyBETA2Achieved;
        int DestroyBETA3Achieved;

        int MinStateOfBuildings1;
        int MinStateOfBuildings2;
        int MinStateOfBuildings3;

        int CurrentStateOfBuildings1;
        int CurrentStateOfBuildings2;
        int CurrentStateOfBuildings3;

        int i;

    state Initialize;
    state ShowBriefing;
        state ShowBriefing2;
        state Working;
        state EndMissionFailed;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
                DestroyBETA1Achieved = false;
                DestroyBETA2Achieved = false;
                DestroyBETA3Achieved = false;


        //----------- Timers -----------------
                SetTimer(0, 1200);
                SetTimer(1, 20);
                SetTimer(2, 20);
                
        //----------- Variables --------------
                nTimer0Counter = FirstOffenseAfter;
                nTimer1Counter = 0;
                nOffensePlayerNumber = FirstOffensePlayer - 1;
                bFireMeteor = false;
        //----------- Goals ------------------
        RegisterGoal(DestroyBETA, "translateGoalDestroyBaseBETA");
                RegisterGoal(goalDestroyWC, "translateGoalDestroyWeatherControls");
                //---show goals on list---
        EnableGoal(DestroyBETA,true);

        
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
                p_Player.SetMoney(10000);
        p_Enemy1.SetMoney(10000);
                p_Enemy2.SetMoney(10000);
                p_Enemy3.SetMoney(10000);

                p_Player.SetMilitaryUnitsLimit(40000);

                p_Player.EnableResearch("RES_UCS_GARG1", true);
                p_Player.EnableResearch("RES_UCS_UHL1", true);
                p_Player.EnableResearch("RES_UCS_WHG1", true);
                p_Player.EnableResearch("RES_UCS_WHP1", true);
                p_Player.EnableResearch("RES_UCS_WHP2", true);
                p_Player.EnableResearch("RES_UCS_WSR3", true);
                p_Player.EnableResearch("RES_UCS_WASR1", true);
                p_Player.EnableResearch("RES_UCS_WMR1", true);
                p_Player.EnableResearch("RES_MMR2", true);
                p_Player.EnableResearch("RES_UCS_RepHand2", true);
                p_Player.EnableResearch("RES_UCS_HGen", true);
                p_Player.EnableResearch("RES_UCS_BMD", true);
                p_Player.EnableResearch("RES_UCS_SHD", true);
                p_Player.EnableResearch("RES_UCSUCS",true);
                p_Player.EnableResearch("RES_UCSWEQ1",true);
                p_Player.EnableResearch("RES_UCSWBHC1",true);
                
                p_Player.AddResearch("RES_MISSION_PACK1_ONLY");

                p_Enemy1.EnableResearch("RES_LC_UCR1",true);
                p_Enemy1.EnableResearch("RES_LC_WHL1",true);
                p_Enemy1.EnableResearch("RES_LC_WMR1",true);
                p_Enemy1.EnableResearch("RES_MMR2",true);
                p_Enemy1.EnableResearch("RES_LC_BHD",true);

                p_Enemy2.CopyResearches(p_Enemy1);
                p_Enemy3.CopyResearches(p_Enemy1);
                //-----Easy------------
                if(GetDifficultyLevel()==0)
                {
                    //kill needless buildings
                    KillArea(p_Enemy1.GetIFF(), GetPointX(0), GetPointY(0), 0, 1);
                    KillArea(p_Enemy1.GetIFF(), GetPointX(7), GetPointY(7), 0, 1);                  

                    KillArea(p_Enemy2.GetIFF(), GetPointX(14), GetPointY(14), 0, 1);
                    KillArea(p_Enemy2.GetIFF(), GetPointX(22), GetPointY(22), 0, 1);

                    KillArea(p_Enemy3.GetIFF(), GetPointX(29), GetPointY(29), 0, 1);
                    KillArea(p_Enemy3.GetIFF(), GetPointX(36), GetPointY(36), 0, 1);
                }

                //-----Normal----------
                if(GetDifficultyLevel()==1)
                {
                    ////////////////LC1////////////////
                    //kill needless buildings
                    KillArea(p_Enemy1.GetIFF(), GetPointX(7), GetPointY(7), 0, 1);

                    //crusher : LCUCU1
                    p_Enemy1.CreateUnitEx(GetPointX(1), GetPointY(1),0,null,"LCUCU3","LCWMR3","LCWMR3",null,null);


                    //lunar: LCULU1 + LCWCH1
                    for(i=2; i<5; i=i+1)
                    {
                        p_Enemy1.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCULU1","LCWCH1",null,null,null);
                    }

                    //moon : LCUMO1 - under ground
                    p_Enemy1.CreateUnitEx(GetPointX(5), GetPointY(5), GetPointZ(5),null,"LCUMO1","LCWCH1",null,null,null);                  
                    p_Enemy1.CreateUnitEx(GetPointX(6), GetPointY(6), GetPointZ(6),null,"LCUMO1","LCWCH1",null,null,null);                  



                    /////////////////LC2///////////////
                    KillArea(p_Enemy2.GetIFF(), GetPointX(22), GetPointY(22), 0, 1);

                    //crusher : LCUCU1
                    p_Enemy2.CreateUnitEx(GetPointX(15), GetPointY(15),0,null,"LCUCU3","LCWMR3","LCWMR3",null,null);

                    //lunar: LCULU1 + LCWCH1
                    for(i=16; i<19; i=i+1)
                    {
                        p_Enemy2.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCULU1","LCWCH1",null,null,null);
                    }

                    //moon : LCUMO1 - under ground
                    p_Enemy2.CreateUnitEx(GetPointX(19), GetPointY(19), GetPointZ(19),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy2.CreateUnitEx(GetPointX(20), GetPointY(20), GetPointZ(20),null,"LCUMO1","LCWCH1",null,null,null);


                    /////////////////LC3///////////////
                    KillArea(p_Enemy3.GetIFF(), GetPointX(36), GetPointY(36), 0, 1);

                    //thunder: LCUBO2 + LCWAMR1
                    p_Enemy3.CreateUnitEx(GetPointX(30), GetPointY(30),0,null,"LCUBO2","LCWAMR1",null,null,null);

                    //lunar: LCULU1 + LCWCH1
                    for(i=31; i<34; i=i+1)
                    {
                        p_Enemy3.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCULU1","LCWCH1",null,null,null);
                    }

                    //moon : LCUMO1 - under ground
                    p_Enemy3.CreateUnitEx(GetPointX(34), GetPointY(34), GetPointZ(34),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy3.CreateUnitEx(GetPointX(35), GetPointY(35), GetPointZ(35),null,"LCUMO1","LCWCH1",null,null,null);


                }

                //-----Hard----------
                if(GetDifficultyLevel()==2)
                {
                    ////////////////LC1////////////////

                    //crusher : LCUCU1
                    p_Enemy1.CreateUnitEx(GetPointX(1), GetPointY(1),0,null,"LCUCU3","LCWMR3","LCWMR3",null,null);
                    p_Enemy1.CreateUnitEx(GetPointX(8), GetPointY(8),0,null,"LCUCU3","LCWMR3","LCWMR3",null,null);

                    //lunar: LCULU1 + LCWCH1
                    for(i=2; i<5; i=i+1)
                    {
                        p_Enemy1.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCULU1","LCWCH1",null,null,null);
                    }

                    //moon : LCUMO1
                    for(i=9; i<12; i=i+1)
                    {
                        p_Enemy1.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCUMO1","LCWCH1",null,null,null);
                    }

                    //moon : LCUMO1 - under ground
                    p_Enemy1.CreateUnitEx(GetPointX(5), GetPointY(5), GetPointZ(5),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy1.CreateUnitEx(GetPointX(6), GetPointY(6), GetPointZ(6),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy1.CreateUnitEx(GetPointX(12), GetPointY(12), GetPointZ(12),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy1.CreateUnitEx(GetPointX(13), GetPointY(13), GetPointZ(13),null,"LCUMO1","LCWCH1",null,null,null);



                    /////////////////LC2///////////////

                    //crusher : LCUCU1
                    p_Enemy2.CreateUnitEx(GetPointX(15), GetPointY(15),0,null,"LCUCU3","LCWMR3","LCWMR3",null,null);
                    p_Enemy2.CreateUnitEx(GetPointX(23), GetPointY(23),0,null,"LCUCU3","LCWMR3","LCWMR3",null,null);

                    //lunar: LCULU1 + LCWCH1
                    for(i=16; i<19; i=i+1)
                    {
                        p_Enemy2.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCULU1","LCWCH1",null,null,null);
                    }

                    //moon : LCUMO1
                    for(i=24; i<27; i=i+1)
                    {
                        p_Enemy1.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCUMO1","LCWCH1",null,null,null);
                    }

                    //moon : LCUMO1 - under ground
                    p_Enemy2.CreateUnitEx(GetPointX(19), GetPointY(19), GetPointZ(19),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy2.CreateUnitEx(GetPointX(20), GetPointY(20), GetPointZ(20),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy2.CreateUnitEx(GetPointX(27), GetPointY(27), GetPointZ(27),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy2.CreateUnitEx(GetPointX(28), GetPointY(28), GetPointZ(28),null,"LCUMO1","LCWCH1",null,null,null);



                    /////////////////LC3///////////////

                    //thunder: LCUBO2 + LCWAMR1
                    p_Enemy3.CreateUnitEx(GetPointX(30), GetPointY(30),0,null,"LCUBO2","LCWAMR1",null,null,null);
                    p_Enemy3.CreateUnitEx(GetPointX(37), GetPointY(37),0,null,"LCUBO2","LCWAMR1",null,null,null);

                    //lunar: LCULU1 + LCWCH1
                    for(i=31; i<34; i=i+1)
                    {
                        p_Enemy3.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCULU1","LCWCH1",null,null,null);
                    }

                    //moon : LCUMO1
                    for(i=38; i<41; i=i+1)
                    {
                        p_Enemy1.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCUMO1","LCWCH1",null,null,null);
                    }

                    //moon : LCUMO1 - under ground
                    p_Enemy3.CreateUnitEx(GetPointX(34), GetPointY(34), GetPointZ(34),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy3.CreateUnitEx(GetPointX(35), GetPointY(35), GetPointZ(35),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy3.CreateUnitEx(GetPointX(41), GetPointY(41), GetPointZ(41),null,"LCUMO1","LCWCH1",null,null,null);
                    p_Enemy3.CreateUnitEx(GetPointX(42), GetPointY(42), GetPointZ(42),null,"LCUMO1","LCWCH1",null,null,null);

                }

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

                //----------- Camera -----------------
        CallCamera();
                p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(), 15, 128, 20, 0);
                p_Player.DelayedLookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(), 6, 0, 20, 0,50,1);
        return ShowBriefing,55;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
            //show campaign goal 3
            p_Player.SetScriptData(scriptFieldGoal4, 1);
            //show mission briefing
            AddBriefing("translateBriefing415a", p_Player.GetName());
            MeteorRain(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),15,200,1200,200,10,10);
            return ShowBriefing2,1200;
    }
        //-----------------------------------------------------------------------------------------
        state ShowBriefing2
    {
            //show mission briefing2 
            EnableGoal(goalDestroyWC,true);
            AddBriefing("translateBriefing415b", p_Player.GetName());
            ShowArea(2,GetPointX(47),GetPointY(47),0,4,showAreaBuildings);
            ShowArea(2,GetPointX(48),GetPointY(48),0,4,showAreaBuildings);
            p_Player.LookAt(GetPointX(47),GetPointY(47), 15, 128, 20, 0);
            if(GetDifficultyLevel()==0) nMeteorShowerCounter=30*60;
            if(GetDifficultyLevel()==1) nMeteorShowerCounter=20*60;
            if(GetDifficultyLevel()==2) nMeteorShowerCounter=10*60;
      return Working;
    }
        //-----------------------------------------------------------------------------------------
        state Working
        {
            if(!p_Player.GetNumberOfUnits())
            {
                AddBriefing("translateFailed415", p_Player.GetName());
                return EndMissionFailed;
            }

            if(!p_Enemy1.GetNumberOfBuildings(buildingWeatherControl))
            {

                SetConsoleText("");
                if(nMeteorShowerCounter>0)
                {
                    SetGoalState(goalDestroyWC,goalAchieved);
                    AddBriefing("translateBriefing415c", p_Player.GetName());
                }
                nMeteorShowerCounter=0;
            }
            //--------- check goals --------------------------------

            //----capture LC base---

            if(!DestroyBETA1Achieved)
            {
                CurrentStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings();
                if(CurrentStateOfBuildings1 < MinStateOfBuildings1)
                {               
                    p_Enemy1.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy1.SetMoney(0);

                    if(!CurrentStateOfBuildings1)
                        DestroyBETA1Achieved = true;
                }
            }

            if(!DestroyBETA2Achieved)
            {
                CurrentStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings();
                if(CurrentStateOfBuildings2 < MinStateOfBuildings2)
                {
                    p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy2.SetMoney(0);

                    if(!CurrentStateOfBuildings2)
                        DestroyBETA2Achieved = true;
                }
            }

            if(!DestroyBETA3Achieved)
            {
                CurrentStateOfBuildings3 = p_Enemy3.GetNumberOfBuildings();
                if(CurrentStateOfBuildings3 < MinStateOfBuildings3)
                {
                    p_Enemy3.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy3.SetMoney(0);

                    if(!CurrentStateOfBuildings3)
                        DestroyBETA3Achieved = true;
                }
            }

            //mission achieved
            if(DestroyBETA1Achieved && DestroyBETA2Achieved && DestroyBETA3Achieved)
            {
                //check campaign goal 1
                p_Player.SetScriptData(scriptFieldGoal4, 2);
                //check mission goal
                SetGoalState(DestroyBETA, goalAchieved);
                EnableNextMission(0,true);
                AddBriefing("translateAccomplished415", p_Player.GetName());
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
        unitex u_Grizzli1;
        u_Grizzli1 = p_Player.GetScriptUnit(1);
    if(bFireMeteor && nMeteorShowerCounter>0 && u_Grizzli1!=null && u_Grizzli1.IsLive() && u_Grizzli1.IsInWorld(GetWorldNum()))
    {
            if(GetDifficultyLevel()==1) Meteor(u_Grizzli1.GetLocationX(),u_Grizzli1.GetLocationY(),1);
            if(GetDifficultyLevel()==2) Meteor(u_Grizzli1.GetLocationX(),u_Grizzli1.GetLocationY(),2);
        }

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
        if(nMeteorShowerCounter > 0)
        {
            nMeteorShowerCounter = nMeteorShowerCounter - 1;
            SetConsoleText("translateMessage415",nMeteorShowerCounter);
            if(nMeteorShowerCounter == 0) // Meteor rain.
            {
                SetGoalState(goalDestroyWC,goalFailed);
                SetConsoleText("");
                p_Player.SetScriptData(scriptFieldMeteors,10);
                MeteorRain(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),15,500,30000,100,10,10);
            }
        }

    }
  //-----------------------------------------------------------------------------------------
    event Timer2() 
    {
        DamageArea(p_Player.GetIFF(),GetPointX(43),GetPointY(43),0,6,5);
        DamageArea(p_Player.GetIFF(),GetPointX(44),GetPointY(44),0,10,5);
        DamageArea(p_Player.GetIFF(),GetPointX(45),GetPointY(45),0,5,5);
        DamageArea(p_Player.GetIFF(),GetPointX(46),GetPointY(46),0,7,5);
    }
    event BuildingDestroyed(unit uBuilding)
    {
        unitex u_Grizzli1;
        
        if(!bFireMeteor && nMeteorShowerCounter>0 )
        {
            u_Grizzli1 = p_Player.GetScriptUnit(1);
            if(uBuilding.GetAttacker()==u_Grizzli1)//gdy Grizzli1 rozwali pierwszy budynek na misji to zaczynamy w niego walic.
            {
                bFireMeteor=true;
            }
        }
    }
//-----------------------------------------------------------------------------------------
    event EndMission() 
    {
            if(DestroyBETA1Achieved && DestroyBETA2Achieved && DestroyBETA3Achieved)
            {
                p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
                p_Player.SetMoney(0);
            }
        }
}
