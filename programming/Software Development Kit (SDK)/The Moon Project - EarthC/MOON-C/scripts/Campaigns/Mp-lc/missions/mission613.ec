mission "translateMission613"
{
    consts
    {
        scriptFieldMoney=9;

        goalDestroyUCSNorth = 0;
        goalDestroyUCSSouth = 1;
        goalBuildNorth = 2;
        goalBuildSouth = 3;

        FirstOffenseAfter = 15; // minuty
        OffenseFrequency = 3; // minuty
        OffenseTime = 30; // sekundy
        FirstOffensePlayer = 1;
        LastOffensePlayer = 5;
    }

    player p_Enemy1;
    player p_Enemy2;
    player p_Player;
    player p_Neutral;


    int nTimer0Counter;
    int nTimer1Counter;
    int nOffensePlayerNumber;
    player p_OffensePlayer;


    int DestroyUCS1Achieved;
    int DestroyUCS2Achieved;
    int BuildRafineryAndPPlantsAchieved;

    int BriefingBShowed;
    int CheckBase;

    int BuildRP1;
    int BuildRP2;

    int MinX1;
    int MinY1;
    int MaxX1;
    int MaxY1;

    int MinX2;
    int MinY2;
    int MaxX2;
    int MaxY2;

    int BuildingType;
    int lPP1;
    int lPP2;
    int lR1;
    int lR2;
    unitex CurrUnit;
    unitex FirstUnit;
    unitex FirstUnitUCS2;

    int i;
    int x;
    int y;
    int UCS1IsMining;
    int UCS2IsMining;

    int bMiningChecked;

    int MinStateOfBuildings1;
    int MinStateOfBuildings2;

    int CurrentStateOfBuildings1;
    int CurrentStateOfBuildings2;

    state Initialize;
    state ShowBriefing;
    state Working;
    state EndMissionFailed;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Timers -----------------
        SetTimer(0, 1200);
        SetTimer(1, 20);
        SetTimer(2, 151);
        //----------- Variables --------------
        nTimer0Counter = FirstOffenseAfter;
        nTimer1Counter = 0;
        nOffensePlayerNumber = FirstOffensePlayer - 1;

        BriefingBShowed = true;
        DestroyUCS1Achieved = false;
        DestroyUCS2Achieved = false;
        BuildRafineryAndPPlantsAchieved = false;
        BuildRP1 = false;
        BuildRP2 = false;
        CheckBase = 0;
        UCS1IsMining = true;
        UCS2IsMining = true;
        lPP1 = 0;
        lPP2 = 0;
        lR1 = 0;
        lR2 = 0;

        MinX1 = GetPointX(0);
        MinY1 = GetPointY(0);
        MaxX1 = GetPointX(1);
        MaxY1 = GetPointY(1);

        MinX2 = GetPointX(5);
        MinY2 = GetPointY(5);
        MaxX2 = GetPointX(6);
        MaxY2 = GetPointY(6);

        //----------- Goals ------------------
        RegisterGoal(goalDestroyUCSNorth,"translateGoal613A");
        RegisterGoal(goalDestroyUCSSouth,"translateGoal613B");
        
        RegisterGoal(goalBuildNorth,"translateGoal613C");
        RegisterGoal(goalBuildSouth,"translateGoal613D");

         
        EnableGoal(goalDestroyUCSNorth,true);
        EnableGoal(goalDestroyUCSSouth,true);
            

        //----------- Players ----------------
        p_Player = GetPlayer(3);        
        p_Enemy1 = GetPlayer(1);
        p_Enemy2  = GetPlayer(5);
        
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

        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy1.EnableAIFeatures(aiControlDefense,false);

        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlDefense,false);


        //----------- Money ------------------
        p_Player.EnableCommand(commandSoldBuilding,true);                  // 1st tab
        p_Player.SetMoney(10000);
        p_Player.AddResearch("RES_MISSION_PACK1_ONLY");




        p_Enemy1.AddResearch("RES_MISSION_PACK1_ONLY");
        p_Enemy2.AddResearch("RES_MISSION_PACK1_ONLY");

        p_Enemy1.SetMoney(10000);
        p_Enemy2.SetMoney(10000);

        //------easy------
        if(GetDifficultyLevel()==0)
        {
            //Enemy1
            KillArea(p_Enemy1.GetIFF(), GetPointX(2), GetPointY(2), 0, 1);
            KillArea(p_Enemy1.GetIFF(), GetPointX(10), GetPointY(10), 0, 1);

                //Enemy2
            KillArea(p_Enemy2.GetIFF(), GetPointX(7), GetPointY(7), 0, 1);
        }


        //-----Normal----------
        if(GetDifficultyLevel()==1)
        {
            //Enemy1
            KillArea(p_Enemy1.GetIFF(), GetPointX(10), GetPointY(10), 0, 1);

            //-----add to p_Enemy------
            //Spider+R : UCSUML1 # UCSWSSR1
            p_Enemy1.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "UCSUML1", "UCSWSSR1", null, null, null);
            p_Enemy1.CreateUnitEx(GetPointX(4), GetPointY(4), 0, null, "UCSUML1", "UCSWSSR1", null, null, null);


            //Enemy2
            //-----add to p_Enemy--------
            //Spider+R : UCSUML1 # UCSWSSR1
            p_Enemy2.CreateUnitEx(GetPointX(8), GetPointY(8), 0, null, "UCSUML1", "UCSWSSR1", null, null, null);
            p_Enemy2.CreateUnitEx(GetPointX(9), GetPointY(9), 0, null, "UCSUML1", "UCSWSSR1", null, null, null);

        }

        //-----Hard----------
        if(GetDifficultyLevel()==2)
        {
            //-----add to p_Enemy--------
            //Enemy1
            //Panther + R: UCSUHL1 # UCSWBSR1                   
            p_Enemy1.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "UCSUHL1", "UCSWBSR1", null, null, null);
            p_Enemy1.CreateUnitEx(GetPointX(4), GetPointY(4), 0, null, "UCSUHL1", "UCSWBSR1", null, null, null);

            //Enemy2
            //Panther + R: UCSUHL1 # UCSWBSR1                   
            p_Enemy2.CreateUnitEx(GetPointX(8), GetPointY(8), 0, null, "UCSUHL1", "UCSWBSR1", null, null, null);
            p_Enemy2.CreateUnitEx(GetPointX(9), GetPointY(9), 0, null, "UCSUHL1", "UCSWBSR1", null, null, null);
        }


        //----------- Buildings --------------
        p_Player.EnableBuilding("LCBSR",false); //Centrum wydobywczo-transportowe
        p_Player.EnableBuilding("LCBRC",false); 

        p_Enemy2.SetAlly(p_Enemy1);
        p_Enemy2.CopyResearches(p_Enemy1);          

        
        p_Player.EnableResearch("RES_LCBNE",true);//613
        p_Player.EnableResearch("RES_LC_BMD",true);//613
        p_Player.EnableResearch("RES_LC_MGen",true);//613
        p_Player.EnableResearch("RES_LC_SOB1",true);//613
        p_Player.EnableResearch("RES_LC_REG1",true);//613
        p_Player.EnableResearch("RES_LC_UME1",true);//613


        MinStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings()/5;
        MinStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings()/5;

        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        return ShowBriefing,60;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
            AddBriefing("translateBriefing613a", p_Player.GetName());
            BriefingBShowed = false;
            return Working, 20;
    }
    //-----------------------------------------------------------------------------------------

    state EndMissionFailed
    {
        EnableNextMission(0,2);
        return Nothing;
    }
    //-----------------------------------------------------------------------------------------

    state Working
    {
        //-----------mission failed-----------------
        if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings() )
        {
            AddBriefing("translateFailed613", p_Player.GetName());
            return EndMissionFailed;
        }

        //---- check 1 goal - destroy UCS ----
        if(!DestroyUCS1Achieved)
        {
            CurrentStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings();
            if(CurrentStateOfBuildings1 < MinStateOfBuildings1)
            {
                p_Enemy1.EnableAIFeatures(aiBuildBuildings,false);
                p_Enemy1.SetMoney(0);

                if(!CurrentStateOfBuildings1)
                {
                    SetGoalState(goalDestroyUCSNorth, goalAchieved);
                    DestroyUCS1Achieved = true;
                    p_Player.EnableResearch("RES_LCBPP2",true);
                    p_Player.AddResearch("RES_LCBPP2");//613 add w drugiej po³owie misji
                }
            }
        }

        if(!DestroyUCS2Achieved)
        {
            CurrentStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings();

            if(CurrentStateOfBuildings2 < MinStateOfBuildings2)
            {
                p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
                p_Enemy2.SetMoney(0);

                if(!CurrentStateOfBuildings2)
                {
                    SetGoalState(goalDestroyUCSSouth, goalAchieved);
                    DestroyUCS2Achieved = true;
                    p_Player.EnableResearch("RES_LCBPP2",true);
                    p_Player.AddResearch("RES_LCBPP2");//613 add w drugiej po³owie misji
                }
            }
        }

        //--- all goals achiewed ---
        if(BuildRP1 && BuildRP2 && DestroyUCS1Achieved && DestroyUCS2Achieved)
        {               
            p_Player.SetScriptData(0,2);

            EnableNextMission(0,true);              
            AddBriefing("translateAccomplished613", p_Player.GetName());
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

    event BuildingDestroyed(unit u_Unit)
    { 
            //czy zniszczono budynek wroga??
            if(!BriefingBShowed)
            {
                if(u_Unit.IsBuilding())
                {
                    if(u_Unit.GetIFFNumber() == p_Enemy1.GetIFFNumber() || u_Unit.GetIFFNumber() == p_Enemy2.GetIFFNumber())
                    {
                        EnableGoal(goalBuildNorth,true);
                        EnableGoal(goalBuildSouth,true);
                        AddBriefing("translateBriefing613b", p_Player.GetName());
                        BriefingBShowed = true;
                    }
                }
            }
    }

    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co minute
    {
        nTimer0Counter = nTimer0Counter - 1;

        if(nTimer0Counter == 0) // start ofensywy
        {
            nOffensePlayerNumber = nOffensePlayerNumber + 1;

            if(nOffensePlayerNumber >= LastOffensePlayer + 1)
                nOffensePlayerNumber = FirstOffensePlayer;

            if(nOffensePlayerNumber == 2)
                nOffensePlayerNumber = 5;
            
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
                p_OffensePlayer.EnableAIFeatures(aiControlDefense,false);
            }
        }
    }


    //-------check UCS bases--------
    event Timer2()
    {
        //sprawdzanie "na zmiane"
        if(CheckBase == 0)
        {
            CheckBase = 1;
            bMiningChecked = false;

            //czy wybudowano w bazie 1
            if(!BuildRP1)
            {
                //TraceD("1:(");TraceD(MinX1);TraceD(",");TraceD(MinY1);TraceD(")-(");
                //TraceD(MaxX1);TraceD(",");TraceD(MaxY1);TraceD(") ");

                bMiningChecked = true;

                for(y=MinY1; y<MaxY1+1; y=y+1)
                    for(x=MinX1; x<MaxX1+1; x=x+1)
                    {
                        CurrUnit = GetUnit(x, y, 0);
                        if(CurrUnit != null)
                        {                                   
                            if(CurrUnit.GetIFFNumber() == p_Player.GetIFFNumber() && CurrUnit.IsBuilding()) //czy nasz budynek                          
                            {
                                //TraceD("o");
                                BuildingType = CurrUnit.GetBuildingType();
                                //TraceD(BuildingType);

                                if(lPP1 < 2)    //jeszcze nie wykryl elektrowni
                                {
                                    //TraceD("<2");
                                    if(BuildingType == buildingPowerPlant)  //OK - wykryl elektrownie
                                    {
                                        //TraceD("!");
                                        if(lPP1 == 0)   //to pierwsza kostka z elektrownia
                                        {
                                            lPP1 = 1;
                                            FirstUnit = CurrUnit;
                                            //TraceD(" Wybudowano elektr.1 w UCS1 ");
                                        }
                                        else    //nie pierwsza kostka ale czy inna elektrownia
                                        {
                                            if(FirstUnit != CurrUnit)   //inna
                                            {
                                                lPP1 = 2;
                                                //TraceD(" Wybudowano elektr.2 w UCS1 ");
                                            }
                                        }
                                    }
                                }

                                if(!lR1 && BuildingType == buildingMinningRefinery)
                                {
                                    lR1 = 1;    //wybudowano kopalnie
                                    //TraceD(" Wybudowano kopalnie w UCS1 ");
                                }

                                if(lR1 && lPP1==2)
                                {
                                    BuildRP1 = true;
                                    SetGoalState(goalBuildNorth, goalAchieved);
                                    //TraceD(" Wybudowano to co trzeba w UCS1 ");
                                }
                            }
                            else
                            {
                                //TraceD(".");
                            }
                        }
                    }
                    //TraceD("        \n");
            }

        }
        else    //check UCS base 2
        {
            CheckBase = 0;
            
            //czy wybudowano w bazie 2
            if(!BuildRP2)
            {
                //TraceD("2:(");TraceD(MinX2);TraceD(",");TraceD(MinY2);TraceD(")-(");
                //TraceD(MaxX2);TraceD(",");TraceD(MaxY2);TraceD(") ");
                for(y=MinY2; y<MaxY2+1; y=y+1)
                    for(x=MinX2; x<MaxX2+1; x=x+1)
                    {
                        CurrUnit = GetUnit(x, y, 0);
                        if(CurrUnit != null)
                        {
                
                            if(CurrUnit.GetIFFNumber() == p_Player.GetIFFNumber() && CurrUnit.IsBuilding()) //czy nasz budynek
                            {
                                BuildingType = CurrUnit.GetBuildingType();
                                //TraceD("o");TraceD(BuildingType);
                                if(lPP2 < 2)    //jeszcze nie wykryl elektrowni
                                {
                                    //TraceD("<2");
                                    if(BuildingType == buildingPowerPlant)  //OK - wykryl elektrownie
                                    {
                                        if(lPP2 == 0)   //to pierwsza kostka z elektrownia
                                        {
                                            lPP2 = 1;
                                            FirstUnitUCS2 = CurrUnit;
                                            //TraceD(" Wybudowano elektr.1 w UCS2 ");
                                        }
                                        else    //nie pierwsza kostka ale czy inna elektrownia
                                        {
                                            if(FirstUnitUCS2 != CurrUnit)   //inna
                                            {
                                                lPP2 = 2;
                                                //TraceD(" Wybudowano elektr.2 w UCS2 ");
                                            }
                                        }
                                    }
                                }

                                if(!lR2 && BuildingType == buildingMinningRefinery)
                                {
                                    lR2 = 1;    //wybudowano kopalnie
                                    //TraceD(" Wybudowano kopalnie w UCS2 ");
                                }

                                if(lR2 && lPP2==2 && !BuildRP2)
                                {
                                    BuildRP2 = true;
                                    SetGoalState(goalBuildSouth, goalAchieved);
                                    //TraceD(" Wybudowano to co trzeba w UCS2 ");
                                }
                            }
                            else
                            {
                                //TraceD(".");
                            }
                        }
                }
            //TraceD("        \n");
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission() 
    {
        if(BuildRP1 && BuildRP2 && DestroyUCS1Achieved && DestroyUCS2Achieved)
        {
            p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
            p_Player.SetMoney(0);
        }
    }

}
