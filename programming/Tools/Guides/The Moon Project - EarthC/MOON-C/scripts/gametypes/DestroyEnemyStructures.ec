mission "translateGameTypeDestroyStructures"
{
    
    int nTimeLimit;
    int nCashRate;
        int nBuildingType;
    
        enum comboCashType
    {
        "translateScriptMineForMoney",
        "translateScript2500CRmin",
                "translateScript5000CRmin",
                "translateScript10000CRmin",
                "translateScript20000CRmin",
            multi:
        "translateScriptGainingMoney"
    }
    /*enum comboStartingUnits
    {
        "translateGameMenuStartingUnitsDefault",
        "translateGameMenuStartingUnitsBuilderOnly",
            multi:
        "translateGameMenuStartingUnits"
    }*/
        enum comboAlliedVictory
    {
        "translateGameMenuAlliedVictoryNo",
        "translateGameMenuAlliedVictoryYes",
            multi:
        "translateGameMenuAlliedVictory"
    }

    enum comboUnitsLimit
    {
        "translateGameMenuUnitsLimitNoLimit",
        "translateGameMenuUnitsLimit10000CR",
        "translateGameMenuUnitsLimit20000CR",
        "translateGameMenuUnitsLimit30000CR",
        "translateGameMenuUnitsLimit50000CR",
            multi:
        "translateGameMenuUnitsLimit"
    }
    enum comboWinCondition
    {
        "translateScriptDestroyAllStructures",
                "translateScriptDestroyMainStructures",
        "translateScriptDestroyPowerPlants",
                "translateScriptDestroyFactories",
            multi:
        "translateScriptVictoryCondition"
    }
        enum comboResearchTime
    {
        "translateScriptNormalTime",
                "translateScript2xfaster",
        "translateScript4xfaster",
                "translateScript8xfaster",
            multi:
        "translateScriptResearchTime"
    }
        enum comboResearchLimit
    {
        "translateScriptAllResearches",
                "translateScriptNoBombs",
        "translateScriptNoMassDestructionWeapons",
                "translateScriptNoBombsAndMDW",
            multi:
        "translateScriptAvailableResearches"
    }
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        player rPlayer;
        int i;
        int nStartingMoney;
        
        nStartingMoney = 25000;
                
                if(comboCashType==0) nCashRate = 0;
                if(comboCashType==1) nCashRate = 2500;
                if(comboCashType==2) nCashRate = 5000;
                if(comboCashType==3) nCashRate = 10000;
                if(comboCashType==4) nCashRate = 20000;

                if(comboResearchTime==1) SetTimeDivider(2);
                if(comboResearchTime==2) SetTimeDivider(4);
                if(comboResearchTime==3) SetTimeDivider(8);

        ResourcesPerContainer(2);
        
        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            if (rPlayer!=null)
            {
                if(rPlayer.GetRace()==raceUCS)
                {
                    rPlayer.EnableBuilding("UCSBLZ", false);
                    rPlayer.EnableBuilding("UCSBTB", false);
                }
                if(rPlayer.GetRace()==raceED)
                {
                    rPlayer.EnableBuilding("EDBLZ", false);
                    rPlayer.EnableBuilding("EDBTC", false);
                }
                if(rPlayer.GetRace()==raceLC)
                {
                    rPlayer.EnableBuilding("LCBLZ", false);
                    rPlayer.EnableBuilding("LCBSR", false);
                }
            }
        }

        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null) 
            {
                                if(comboAlliedVictory)
                                    rPlayer.EnableAIFeatures2(ai2BNSendResult,false);//nie wysylac rezultatow do EARTH NETu       

                                rPlayer.SetScriptData(0,0);
                if(comboUnitsLimit==0) rPlayer.EnableMilitaryUnitsLimit(false);
                if(comboUnitsLimit==1) rPlayer.SetMilitaryUnitsLimit(10000);
                if(comboUnitsLimit==2) rPlayer.SetMilitaryUnitsLimit(20000);
                if(comboUnitsLimit==3) rPlayer.SetMilitaryUnitsLimit(30000);
                if(comboUnitsLimit==4) rPlayer.SetMilitaryUnitsLimit(50000);
                
                rPlayer.SetMoney(nStartingMoney);
                rPlayer.LookAt(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),6,0,20,0);
                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    rPlayer.CreateDefaultUnit(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),0);

                                if(comboCashType>0)
                                {
                                    rPlayer.EnableAIFeatures(aiBuildMiningBuildings|aiBuildMiningUnits|aiControlMiningUnits,false);

                                    rPlayer.EnableBuilding("EDBMI",false);
                                    rPlayer.EnableBuilding("EDBRE",false);
                                    rPlayer.EnableBuilding("UCSBRF",false);
                                    rPlayer.EnableBuilding("LCBMR",false);
                                    
                                    rPlayer.EnableResearch("RES_UCS_UOH2",false);
                                    rPlayer.EnableResearch("RES_UCS_UOH3",false);
                                    rPlayer.EnableResearch("RES_UCS_UAH1",false);
                                    rPlayer.EnableResearch("RES_UCS_UAH2",false);
                                    rPlayer.EnableResearch("RES_UCS_UAH3",false);
                                }
                                if(comboResearchLimit==1||comboResearchLimit==3)
                                {
                                    //no bombs
                                    rPlayer.EnableResearch("RES_ED_AB1",false);
                                    rPlayer.EnableResearch("RES_ED_MB2",false);
                                    rPlayer.EnableResearch("RES_UCS_WAPB1",false);
                                    rPlayer.EnableResearch("RES_UCS_MB2",false);
                
                                }
                                if(comboResearchLimit==2||comboResearchLimit==3)
                                {
                                    //no UW
                                    rPlayer.EnableResearch("RES_ED_WHR1",false);
                                    rPlayer.EnableResearch("RES_LC_BWC",false);
                                    rPlayer.EnableResearch("RES_LC_SDIDEF",false);
                                    rPlayer.EnableResearch("RES_UCS_PC",false);
                                    rPlayer.EnableResearch("RES_UCS_WSD",false);
                                }
            }
        }
        
                SetTimer(0,100);
        SetTimer(2,1200);
                SetTimer(1,400);
        return Nothing;
    }
    
    state Nothing
    {
        return Nothing;
    }
    
    event RemoveResources()
    {
            if(comboCashType==0)
                false;
            else
                true;
    }
    
    event RemoveUnits()
    {
    /*    if(comboStartingUnits)
            true;
        else
            false;*/
            true;
    }
    
    event Timer0()
    {
        int iAlivePlayers;
        int i;
        int j;
        int iCountBuilding;
        int bActiveEnemies;
        int bOneHasBeenDestroyed;   
        player rPlayer;
        player rPlayer2;
        player rLastPlayer;
     
                

        rLastPlayer=null;
        iAlivePlayers=0;
        bOneHasBeenDestroyed=false;
        for(i=0;i<15;i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null)
                        {
                            if(rPlayer.IsAlive()) 
                            {
                                if(comboWinCondition==0)
                                    iCountBuilding = rPlayer.GetNumberOfBuildings();
                    
                                if(comboWinCondition==1)//main structures
                                {
                                    iCountBuilding = rPlayer.GetNumberOfBuildings(buildingPowerPlant)+
                                        rPlayer.GetNumberOfBuildings(buildingSolarPower)+
                                        rPlayer.GetNumberOfBuildings(buildingEnergyBattery)+
                                        rPlayer.GetNumberOfBuildings(buildingBase)+
                                        rPlayer.GetNumberOfBuildings(buildingFactory)+
                                        rPlayer.GetNumberOfBuildings(buildingWaterBase)+
                                        rPlayer.GetNumberOfBuildings(buildingSupplyCenter)+
                                        rPlayer.GetNumberOfBuildings(buildingMine)+
                                        rPlayer.GetNumberOfBuildings(buildingRefinery)+
                                        rPlayer.GetNumberOfBuildings(buildingResearchCenter)+
                                        rPlayer.GetNumberOfBuildings(buildingHeadquater)+
                                        rPlayer.GetNumberOfBuildings(buildingBBC)+
                                        rPlayer.GetNumberOfBuildings(buildingPlasmaControl)+
                                        rPlayer.GetNumberOfBuildings(buildingWeatherControl)+
                                        rPlayer.GetNumberOfBuildings(buildingMinningRefinery)+
                                        rPlayer.GetNumberOfBuildings(buildingBaseFactory);
                                }
                                if(comboWinCondition==2)//power plants
                                    iCountBuilding = rPlayer.GetNumberOfBuildings(buildingPowerPlant)+
                                            rPlayer.GetNumberOfBuildings(buildingSolarPower)+
                                            rPlayer.GetNumberOfBuildings(buildingEnergyBattery);

                                if(comboWinCondition==3)//factorys
                                {
                                    iCountBuilding = 
                                        rPlayer.GetNumberOfBuildings(buildingBase)+
                                        rPlayer.GetNumberOfBuildings(buildingFactory)+
                                        rPlayer.GetNumberOfBuildings(buildingWaterBase)+
                                        rPlayer.GetNumberOfBuildings(buildingBaseFactory);
                                }

                                if(iCountBuilding) rPlayer.SetScriptData(0,1);
                                    
                                if (iCountBuilding==0)
                                {
                                    if(rPlayer.GetScriptData(0)==1)
                                    {
                                        rPlayer.Defeat();
                                        KillArea(rPlayer.GetIFF(),GetRight()/2,GetBottom()/2,0,128);
                                    }
                                    else
                                    {
                                        if((rPlayer.GetNumberOfUnits()==0) && (rPlayer.GetNumberOfBuildings() == 0))
                                            rPlayer.Defeat();
                                    }
                                }
                            }
                            if(!rPlayer.IsAlive()) bOneHasBeenDestroyed=true;
                        }
        }
        
        bActiveEnemies=false;
        for(i=0;i<15;i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null && rPlayer.IsAlive()) 
            {
                for(j=i+1;j<15;j=j+1)
                {
                    rPlayer2 = GetPlayer(j);
                    if(rPlayer2!=null && rPlayer2.IsAlive() && (!(rPlayer.IsAlly(rPlayer2) && comboAlliedVictory))) 
                    {
                        bActiveEnemies=true;
                    }
                }
            }
        }
        if(bActiveEnemies) return;
        if(!bOneHasBeenDestroyed) return;
        

        for(i=0;i<15;i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null && rPlayer.IsAlive()) 
            {
                rPlayer.Victory();
            }
        }
    }
    
        event Timer1()
    {
            SetConsoleText("");
        }

        event Timer2()
    {
        int i;
        player rPlayer;
        
                if(comboWinCondition==0)
                    SetConsoleText("translateScriptDestroyAllStructures");
                if(comboWinCondition==1)
                    SetConsoleText("translateScriptDestroyMainStructures");
        if(comboWinCondition==2)
                    SetConsoleText("translateScriptDestroyPowerPlants");
                if(comboWinCondition==3)
                    SetConsoleText("translateScriptDestroyFactories");
                
        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null && rPlayer.IsAlive()) 
            {
                            if(rPlayer.GetMoney()<100000)
                rPlayer.AddMoney(nCashRate);
            }
        }
    }
        
    command Initialize()
    {
        comboCashType=0;//mine for money
        //comboStartingUnits=1;
                comboAlliedVictory=1;
        comboWinCondition=0;//destroy all structures
        comboUnitsLimit=2;
    }
    
    command Uninitialize()
    {
        ResourcesPerContainer(8);
    }
        
    command Combo1(int nMode) button comboCashType
    {
        comboCashType = nMode;
    }

    command Combo2(int nMode) button comboWinCondition
    {
        comboWinCondition = nMode;
    }

    command Combo3(int nMode) button comboResearchTime
        {
            comboResearchTime = nMode;
    }

        command Combo4(int nMode) button comboResearchLimit
    {
        comboResearchLimit = nMode;
    }
    
    command Combo5(int nMode) button comboUnitsLimit
    {
        comboUnitsLimit = nMode;
    }

    command Combo6(int nMode) button comboAlliedVictory
    {
        comboAlliedVictory = nMode;
    }

        /*
        command Combo6(int nMode) button comboStartingUnits 
    {
        comboStartingUnits = nMode;
    }*/
    

}

