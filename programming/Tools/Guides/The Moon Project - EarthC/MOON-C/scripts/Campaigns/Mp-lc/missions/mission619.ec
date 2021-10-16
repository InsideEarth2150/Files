mission "translateMission619"
{
    consts
    {
        scriptFieldMoney=9;
        goalDestroyUCSNorthWest = 0;
        goalDestroyUCSNorthEast = 1;
        goalDestroyUCSSouthEast = 2;
        goalDestroyUCSSouthWest = 3;
        goalBuildNorthWest = 4;
        goalBuildNorthEast = 5;
        goalBuildSouthEast = 6;
        goalBuildSouthWest = 7;
        
        goalCollectMoney = 8;

        NeededMoney = 60000;

        FirstOffenseAfter = 17; // minuty
        OffenseFrequency = 3; // minuty
        OffenseTime = 30; // sekundy
        FirstOffensePlayer = 1;
        LastOffensePlayer = 9;

        fieldsCoveredByPP2 = 3;
    }

    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Enemy4;

    player p_Player;
    player p_Neutral;

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

    int DestroyUCS1Achieved;
    int DestroyUCS2Achieved;
    int DestroyUCS3Achieved;
    int DestroyUCS4Achieved;

    int DestroyAllUCSAchieved;
    int CollectMoneyAchieved;
    int BuildAllRP;

    int CheckBase;      

    int BuildRP1;
    int BuildRP2;
    int BuildRP3;
    int BuildRP4;

    int MinX1;
    int MinY1;
    int MaxX1;
    int MaxY1;

    int MinX2;
    int MinY2;
    int MaxX2;
    int MaxY2;

    int MinX3;
    int MinY3;
    int MaxX3;
    int MaxY3;

    int MinX4;
    int MinY4;
    int MaxX4;
    int MaxY4;

    int BuildingType;
    int lPP1;
    int lPP2;
    int lPP3;
    int lPP4;
    int lR1;
    int lR2;
    int lR3;
    int lR4;

    int nMoney;

    unitex CurrUnit;

    int i;
    int x;
    int y1;
    int y2;
    int y3;
    int y4;

    int UCS1IsMining;
    int UCS2IsMining;
    int UCS3IsMining;
    int UCS4IsMining;


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

        //----------- Variables --------------
        nTimer0Counter = FirstOffenseAfter;
        nTimer1Counter = 0;
        nOffensePlayerNumber = FirstOffensePlayer - 1;

        DestroyUCS1Achieved = false;
        DestroyUCS2Achieved = false;
        DestroyUCS3Achieved = false;
        DestroyUCS4Achieved = false;

        DestroyAllUCSAchieved = false;
        BuildAllRP = false;


        CollectMoneyAchieved = false;

        BuildRP1 = false;
        BuildRP2 = false;
        BuildRP3 = false;
        BuildRP4 = false;

        CheckBase = 0;
        UCS1IsMining = true;
        UCS2IsMining = true;
        UCS3IsMining = true;
        UCS4IsMining = true;

        lPP1 = 0;
        lPP2 = 0;
        lPP3 = 0;
        lPP4 = 0;
        lR1 = 0;
        lR2 = 0;
        lR3 = 0;
        lR4 = 0;


        MinX1 = GetPointX(0);
        MinY1 = GetPointY(0);
        MaxX1 = GetPointX(1);
        MaxY1 = GetPointY(1);

        if(MinX1>MaxX1){i=MinX1;MinX1=MaxX1;MaxX1=i;}
        if(MinY1>MaxY1){i=MinY1;MinY1=MaxY1;MaxY1=i;}
        
        MinX2 = GetPointX(10);
        MinY2 = GetPointY(10);
        MaxX2 = GetPointX(11);
        MaxY2 = GetPointY(11);

        if(MinX2>MaxX2){i=MinX2;MinX2=MaxX2;MaxX2=i;}
        if(MinY2>MaxY2){i=MinY2;MinY2=MaxY2;MaxY2=i;}
        
        MinX3 = GetPointX(20);
        MinY3 = GetPointY(20);
        MaxX3 = GetPointX(21);
        MaxY3 = GetPointY(21);

        if(MinX3>MaxX3){i=MinX3;MinX3=MaxX3;MaxX3=i;}
        if(MinY3>MaxY3){i=MinY3;MinY3=MaxY3;MaxY3=i;}

        MinX4 = GetPointX(30);
        MinY4 = GetPointY(30);
        MaxX4 = GetPointX(31);
        MaxY4 = GetPointY(31);

        if(MinX4>MaxX4){i=MinX4;MinX4=MaxX4;MaxX4=i;}
        if(MinY4>MaxY4){i=MinY4;MinY4=MaxY4;MaxY4=i;}


        y1 = MinY1 + 1;
        y2 = MinY2 + 1;
        y3 = MinY3 + 1;
        y4 = MinY4 + 1;


        //----------- Goals ------------------
        RegisterGoal(goalDestroyUCSNorthWest,"translateGoal619A");
        RegisterGoal(goalDestroyUCSNorthEast,"translateGoal619B");
        RegisterGoal(goalDestroyUCSSouthEast,"translateGoal619C");
        RegisterGoal(goalDestroyUCSSouthWest,"translateGoal619D");
        RegisterGoal(goalBuildNorthWest,"translateGoal619E");
        RegisterGoal(goalBuildNorthEast,"translateGoal619F");
        RegisterGoal(goalBuildSouthEast,"translateGoal619G");
        RegisterGoal(goalBuildSouthWest,"translateGoal619H");
        RegisterGoal(goalCollectMoney,"translateGoal619I");

        EnableGoal(goalDestroyUCSNorthWest,true);
        EnableGoal(goalDestroyUCSNorthEast,true);
        EnableGoal(goalDestroyUCSSouthEast,true);
        EnableGoal(goalDestroyUCSSouthWest,true);
        EnableGoal(goalBuildNorthWest,true);
        EnableGoal(goalBuildNorthEast,true);
        EnableGoal(goalBuildSouthEast,true);
        EnableGoal(goalBuildSouthWest,true);
        EnableGoal(goalCollectMoney,true);

        //----------- Players ----------------
        p_Player = GetPlayer(3);

        p_Enemy1  = GetPlayer(1);
        
        p_Enemy2  = GetPlayer(5);
        
        p_Enemy3  = GetPlayer(7);
        
        p_Enemy4  = GetPlayer(9);
        

        p_Neutral = GetPlayer(11);  //UCS
        p_Neutral.EnableStatistics(false);
        p_Neutral.SetAlly(p_Enemy1);
        p_Neutral.SetAlly(p_Enemy2);
        p_Neutral.SetAlly(p_Enemy3);
        p_Neutral.SetAlly(p_Enemy4);
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);

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

        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy1.EnableAIFeatures(aiControlDefense,false);

        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlDefense,false);

        p_Enemy3.EnableAIFeatures(aiControlOffense,false);
        p_Enemy3.EnableAIFeatures(aiControlDefense,false);

        p_Enemy4.EnableAIFeatures(aiControlOffense,false);
        p_Enemy4.EnableAIFeatures(aiControlDefense,false);

        //----------- Money ------------------
        p_Player.SetMoney(10000);

        p_Enemy1.SetMoney(10000);
        p_Enemy2.SetMoney(10000);
        p_Enemy3.SetMoney(10000);
        p_Enemy4.SetMoney(10000);

        p_Player.EnableCommand(commandSoldBuilding,true);                  // 1st tab
        
        //----------- Buildings --------------
        p_Player.EnableBuilding("LCBSR",false); //Centrum wydobywczo-transportowe

        p_Player.SetMilitaryUnitsLimit(100000);

        SetTimer(2, 1);

        p_Enemy2.SetAlly(p_Enemy1);
        p_Enemy3.SetAlly(p_Enemy1);
        p_Enemy4.SetAlly(p_Enemy1);

        p_Enemy3.SetAlly(p_Enemy2);
        p_Enemy4.SetAlly(p_Enemy2);

        p_Enemy4.SetAlly(p_Enemy3);


        p_Enemy1.EnableResearch("RES_UCS_MB2",true);
        p_Enemy1.EnableResearch("RES_UCS_WAPB1", true);

        p_Enemy2.CopyResearches(p_Enemy1);
        p_Enemy3.CopyResearches(p_Enemy1);
        p_Enemy4.CopyResearches(p_Enemy1);


        MinStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings()/5;
        MinStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings()/5;
        MinStateOfBuildings3 = p_Enemy3.GetNumberOfBuildings()/5;
        MinStateOfBuildings4 = p_Enemy4.GetNumberOfBuildings()/5;

        p_Player.EnableResearch("RES_LC_WARTILLERY",true);  //Artyleria plazmowa
        p_Player.EnableResearch("RES_LC_UCU1",true);//619
        p_Player.EnableBuilding("LCBRC",false); 

        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(), 12, 0, 45, 0);
        return ShowBriefing, 60;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
            AddBriefing("translateBriefing619", p_Player.GetName());
            return Working, 20;
    }
    //-----------------------------------------------------------------------------------------

        state EndMissionFailed
        {
            EnableNextMission(0,2);
            return Nothing;
        }

        state Working
        {
            //-----------mission failed-----------------
            if(!p_Player.GetNumberOfUnits())
            {
                AddBriefing("translateFailed619", p_Player.GetName());
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
                        SetGoalState(goalDestroyUCSNorthWest, goalAchieved);
                        DestroyUCS1Achieved = true;
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
                        SetGoalState(goalDestroyUCSNorthEast, goalAchieved);
                        DestroyUCS2Achieved = true;
                    }
                }
            }

            if(!DestroyUCS3Achieved)
            {
                CurrentStateOfBuildings3 = p_Enemy3.GetNumberOfBuildings();
                if(CurrentStateOfBuildings3 < MinStateOfBuildings3)
                {
                    p_Enemy3.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy3.SetMoney(0);

                    if(!CurrentStateOfBuildings3)
                    {
                        SetGoalState(goalDestroyUCSSouthEast, goalAchieved);
                        DestroyUCS3Achieved = true;
                    }
                }
            }

            if(!DestroyUCS4Achieved)
            {
                CurrentStateOfBuildings4 = p_Enemy4.GetNumberOfBuildings();
                if(CurrentStateOfBuildings4 < MinStateOfBuildings4)
                {
                    p_Enemy4.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy4.SetMoney(0);

                    if(!CurrentStateOfBuildings4)
                    {
                        SetGoalState(goalDestroyUCSSouthWest, goalAchieved);
                        DestroyUCS4Achieved = true;
                    }
                }
            }



            if(!DestroyAllUCSAchieved)
            {
                if(DestroyUCS1Achieved && DestroyUCS2Achieved && DestroyUCS3Achieved && DestroyUCS4Achieved)
                {
                    DestroyAllUCSAchieved = true;
                }
            }

            //--- Buildings ready ---
            if(!BuildAllRP)
            {
                if(BuildRP1 && BuildRP2 && BuildRP3 && BuildRP4)
                {
                    BuildAllRP = true;
                }
            }


            //is enough money
            if(!CollectMoneyAchieved)
            {
                nMoney = p_Player.GetMoney();

                if(nMoney >= NeededMoney)
                {
                    nMoney = nMoney - NeededMoney;
                    p_Player.SetMoney(nMoney);
                    SetGoalState(goalCollectMoney, goalAchieved);
                    CollectMoneyAchieved = true;
                }
            }


            //-----  All goals achieved  -----
            if(DestroyAllUCSAchieved && BuildAllRP && CollectMoneyAchieved)
            {
                p_Player.SetScriptData(3,2);

                if(p_Player.GetScriptData(11)!=11)//bo musi sie zakonczyc misja 618 i 619
                    p_Player.SetScriptData(11,11);
                else
                    EnableNextMission(0, true);
                
                AddBriefing("translateAccomplished619");
                EnableEndMissionButton(true);
                return Nothing;
            }
        }

        state Nothing
        {
            return Nothing, 500;
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
                
                if(nOffensePlayerNumber == 6 || nOffensePlayerNumber == 8)
                    nOffensePlayerNumber = nOffensePlayerNumber + 1;

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
            //------------------------- Base UCS1 -----------------------------------
            if(CheckBase == 0)
            {               
                //petla y1

                for(x=MinX1+1; x<MaxX1; x=x+1)
                {
                    CurrUnit = GetUnit(x, y1, 0);

                    //sprawdzenie jest to konieczne czy UCS nie wydobywa na tym terenie - jesli tak to niech nie wydobywa
                    if(UCS1IsMining || UCS2IsMining || UCS3IsMining || UCS4IsMining)
                    {
                        if(CurrUnit.IsHarvester())
                        {
                            CurrUnit.CommandMove(MinX1, MinY1, 0);

                            if(UCS1IsMining && CurrUnit.GetIFFNumber() == p_Enemy1.GetIFFNumber())
                            {
                                UCS1IsMining = false;
                                p_Enemy1.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);                                        
                                TraceD(" UCS1 nie wydobywa ");
                            }

                            if(UCS2IsMining && CurrUnit.GetIFFNumber() == p_Enemy2.GetIFFNumber())
                            {
                                UCS2IsMining = false;
                                p_Enemy2.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS2 nie wydobywa ");
                            }

                            if(UCS3IsMining && CurrUnit.GetIFFNumber() == p_Enemy3.GetIFFNumber())
                            {
                                UCS3IsMining = false;
                                p_Enemy3.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS3 nie wydobywa ");
                            }

                            if(UCS4IsMining && CurrUnit.GetIFFNumber() == p_Enemy4.GetIFFNumber())
                            {
                                UCS4IsMining = false;
                                p_Enemy4.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS4 nie wydobywa ");
                            }
                        }
                    }

                    //czy wybudowano w bazie 1
                    if(!BuildRP1)
                    {
                        //sprawdzenie czy odpowiednie budynki na tym terenie
                        if(CurrUnit.GetIFFNumber() == p_Player.GetIFFNumber() && CurrUnit.IsBuilding()) //czy nasz budynek                          
                        {
                            BuildingType = CurrUnit.GetBuildingType();

                            if(BuildingType == buildingPowerPlant)  //wykryl elektrownie
                            {
                                lPP1 = lPP1 + 1;
                                //TraceD(" El. w UCS1 ");
                                //TraceD(lPP1);
                                //TraceD(" ");
                            }

                            if(!lR1 && BuildingType == buildingMinningRefinery) //wykryl rafinerie
                            {
                                lR1 = 1;    //wybudowano kopalnie
                                //TraceD(" Wybudowano kopalnie w UCS1 ");
                            }

                            //jest juz rafineria i co najmniej 3 elektrownie
                            if(lR1 && lPP1>fieldsCoveredByPP2 && !BuildRP1)
                            {
                                SetGoalState(goalBuildNorthWest, goalAchieved);
                                BuildRP1 = true;
                                TraceD(" Wybudowano to co trzeba w UCS1 ");
                            }
                        }
                    }
                }

                y1 = y1 + 1;
                if(y1 >= MaxY1) //koniec sprawdzania obszaru
                {
                    y1 = MinY1+1;
                    lPP1 = 0;

                    //next time check next base
                    CheckBase = 1;
                }               
            }


            //------------------------- Base UCS2 -----------------------------------
            if(CheckBase == 1)
            {               
                //petla y2

                for(x=MinX2+1; x<MaxX2; x=x+1)
                {
                    CurrUnit = GetUnit(x, y2, 0);

                    //sprawdzenie jest to konieczne czy UCS nie wydobywa na tym terenie - jesli tak to niech nie wydobywa
                    if(UCS1IsMining || UCS2IsMining || UCS3IsMining || UCS4IsMining)
                    {
                        if(CurrUnit.IsHarvester())
                        {
                            CurrUnit.CommandMove(MinX2, MinY2, 0);

                            if(UCS1IsMining && CurrUnit.GetIFFNumber() == p_Enemy1.GetIFFNumber())
                            {
                                UCS1IsMining = false;
                                p_Enemy1.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);                                        
                                TraceD(" UCS1 nie wydobywa ");
                            }

                            if(UCS2IsMining && CurrUnit.GetIFFNumber() == p_Enemy2.GetIFFNumber())
                            {
                                UCS2IsMining = false;
                                p_Enemy2.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS2 nie wydobywa ");
                            }

                            if(UCS3IsMining && CurrUnit.GetIFFNumber() == p_Enemy3.GetIFFNumber())
                            {
                                UCS3IsMining = false;
                                p_Enemy3.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS3 nie wydobywa ");
                            }

                            if(UCS4IsMining && CurrUnit.GetIFFNumber() == p_Enemy4.GetIFFNumber())
                            {
                                UCS4IsMining = false;
                                p_Enemy4.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS4 nie wydobywa ");
                            }
                        }
                    }

                    //czy wybudowano w bazie 2
                    if(!BuildRP2)
                    {
                        //sprawdzenie czy odpowiednie budynki na tym terenie
                        if(CurrUnit.GetIFFNumber() == p_Player.GetIFFNumber() && CurrUnit.IsBuilding()) //czy nasz budynek                          
                        {
                            BuildingType = CurrUnit.GetBuildingType();

                            if(BuildingType == buildingPowerPlant)  //wykryl elektrownie
                            {
                                lPP2 = lPP2 + 1;
                                //TraceD(" El. w UCS2 ");
                                //TraceD(lPP2);
                                //TraceD(" ");
                            }

                            if(!lR2 && BuildingType == buildingMinningRefinery) //wykryl rafinerie
                            {
                                lR2 = 1;    //wybudowano kopalnie
                                //TraceD(" Wybudowano kopalnie w UCS2 ");
                            }

                            //jest juz rafineria i co najmniej 3 elektrownie
                            if(lR2 && lPP2>fieldsCoveredByPP2 && !BuildRP2)
                            {
                                BuildRP2 = true;
                                SetGoalState(goalBuildNorthEast, goalAchieved);
                                TraceD(" Wybudowano to co trzeba w UCS2 ");
                            }
                        }
                    }
                }

                y2 = y2 + 1;
                if(y2 >= MaxY2) //koniec sprawdzania obszaru
                {
                    y2 = MinY2+1;
                    lPP2 = 0;

                    //next time check next base
                    CheckBase = 2;
                }               
            }



            //------------------------- Base UCS3 -----------------------------------
            if(CheckBase == 2)
            {               
                //petla y3

                for(x=MinX3+1; x<MaxX3; x=x+1)
                {
                    CurrUnit = GetUnit(x, y3, 0);

                    //sprawdzenie jest to konieczne czy UCS nie wydobywa na tym terenie - jesli tak to niech nie wydobywa
                    if(UCS1IsMining || UCS2IsMining || UCS3IsMining || UCS4IsMining)
                    {
                        if(CurrUnit.IsHarvester())
                        {
                            CurrUnit.CommandMove(MinX3, MinY3, 0);

                            if(UCS1IsMining && CurrUnit.GetIFFNumber() == p_Enemy1.GetIFFNumber())
                            {
                                UCS1IsMining = false;
                                p_Enemy1.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);                                        
                                TraceD(" UCS1 nie wydobywa ");
                            }

                            if(UCS2IsMining && CurrUnit.GetIFFNumber() == p_Enemy2.GetIFFNumber())
                            {
                                UCS2IsMining = false;
                                p_Enemy2.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS2 nie wydobywa ");
                            }

                            if(UCS3IsMining && CurrUnit.GetIFFNumber() == p_Enemy3.GetIFFNumber())
                            {
                                UCS3IsMining = false;
                                p_Enemy3.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS3 nie wydobywa ");
                            }

                            if(UCS4IsMining && CurrUnit.GetIFFNumber() == p_Enemy4.GetIFFNumber())
                            {
                                UCS4IsMining = false;
                                p_Enemy4.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS4 nie wydobywa ");
                            }
                        }
                    }

                    //czy wybudowano w bazie 3
                    if(!BuildRP3)
                    {
                        //sprawdzenie czy odpowiednie budynki na tym terenie
                        if(CurrUnit.GetIFFNumber() == p_Player.GetIFFNumber() && CurrUnit.IsBuilding()) //czy nasz budynek                          
                        {
                            BuildingType = CurrUnit.GetBuildingType();

                            if(BuildingType == buildingPowerPlant)  //wykryl elektrownie
                            {
                                lPP3 = lPP3 + 1;
                                //TraceD(" El. w UCS3 ");
                                //TraceD(lPP3);
                                //TraceD(" ");
                            }

                            if(!lR3 && BuildingType == buildingMinningRefinery) //wykryl rafinerie
                            {
                                lR3 = 1;    //wybudowano kopalnie
                                //TraceD(" Wybudowano kopalnie w UCS3 ");
                            }

                            //jest juz rafineria i co najmniej 3 elektrownie
                            if(lR3 && lPP3>fieldsCoveredByPP2 && !BuildRP3)
                            {
                                BuildRP3 = true;
                                SetGoalState(goalBuildSouthEast, goalAchieved);
                                TraceD(" Wybudowano to co trzeba w UCS3 ");
                            }
                        }
                    }
                }

                y3 = y3 + 1;
                if(y3 >= MaxY3) //koniec sprawdzania obszaru
                {
                    y3 = MinY3+1;
                    lPP3 = 0;

                    //next time check next base
                    CheckBase = 3;
                }
            }


            //------------------------- Base UCS4 -----------------------------------
            if(CheckBase == 3)
            {
                //petla y4

                for(x=MinX4+1; x<MaxX4; x=x+1)
                {
                    CurrUnit = GetUnit(x, y4, 0);

                    //sprawdzenie jest to konieczne czy UCS nie wydobywa na tym terenie - jesli tak to niech nie wydobywa
                    if(UCS1IsMining || UCS2IsMining || UCS3IsMining || UCS4IsMining)
                    {
                        if(CurrUnit.IsHarvester())
                        {
                            CurrUnit.CommandMove(MinX4, MinY4, 0);

                            if(UCS1IsMining && CurrUnit.GetIFFNumber() == p_Enemy1.GetIFFNumber())
                            {
                                UCS1IsMining = false;
                                p_Enemy1.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);                                        
                                TraceD(" UCS1 nie wydobywa ");
                            }

                            if(UCS2IsMining && CurrUnit.GetIFFNumber() == p_Enemy2.GetIFFNumber())
                            {
                                UCS2IsMining = false;
                                p_Enemy2.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS2 nie wydobywa ");
                            }

                            if(UCS3IsMining && CurrUnit.GetIFFNumber() == p_Enemy3.GetIFFNumber())
                            {
                                UCS3IsMining = false;
                                p_Enemy3.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS3 nie wydobywa ");
                            }

                            if(UCS4IsMining && CurrUnit.GetIFFNumber() == p_Enemy4.GetIFFNumber())
                            {
                                UCS4IsMining = false;
                                p_Enemy4.EnableAIFeatures(aiBuildMiningBuildings | aiBuildMiningUnits | aiControlMiningUnits,false);
                                TraceD(" UCS4 nie wydobywa ");
                            }
                        }
                    }

                    //czy wybudowano w bazie 4
                    if(!BuildRP4)
                    {
                        //sprawdzenie czy odpowiednie budynki na tym terenie
                        if(CurrUnit.GetIFFNumber() == p_Player.GetIFFNumber() && CurrUnit.IsBuilding()) //czy nasz budynek                          
                        {
                            BuildingType = CurrUnit.GetBuildingType();

                            if(BuildingType == buildingPowerPlant)  //wykryl elektrownie
                            {
                                lPP4 = lPP4 + 1;
                                //TraceD(" El. w UCS4 ");
                                //TraceD(lPP4);
                                //TraceD(" ");
                            }

                            if(!lR4 && BuildingType == buildingMinningRefinery) //wykryl rafinerie
                            {
                                lR4 = 1;    //wybudowano kopalnie
                                //TraceD(" Wybudowano kopalnie w UCS4 ");
                            }

                            //jest juz rafineria i co najmniej 3 elektrownie
                            if(lR4 && lPP4>fieldsCoveredByPP2 && !BuildRP4)
                            {
                                BuildRP4 = true;
                                SetGoalState(goalBuildSouthWest, goalAchieved);
                                TraceD(" Wybudowano to co trzeba w UCS4 ");
                            }
                        }
                    }
                }

                y4 = y4 + 1;
                if(y4 >= MaxY4) //koniec sprawdzania obszaru
                {
                    y4 = MinY4+1;
                    lPP4 = 0;

                    //next time check next base
                    CheckBase = 0;
                }
            }


            //------------------------- End checking bases -----------------------------------
        }
    //-----------------------------------------------------------------------------------------
    event EndMission() 
    {
        if(DestroyAllUCSAchieved && BuildAllRP && CollectMoneyAchieved)
        {
            p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
            p_Player.SetMoney(0);
        }
    }
}
