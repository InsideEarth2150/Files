mission "translateGameTypeDieHard4"
{
    
    int bGameEnded;
    

    enum comboResearchLimit
    {
        "translateScriptAllResearches",
        "translateScriptNoBombs",
        "translateScriptNoMassDestructionWeapons",
        "translateScriptNoBombsAndMDW",
            multi:
        "translateScriptAvailableResearches"
    }

    enum comboWinCondition
    {
        "translateScriptDestroyEverything",
        "translateScriptDestroyAllStructures",
        "translateScriptDestroyMainStructures",
        "translateScriptDestroyPowerPlants",
        "translateScriptDestroyFactories",
            multi:
        "translateScriptVictoryCondition"
    }

    enum comboStartingUnits
    {
        "translateGameMenuStartingUnitsDefault",
        "translateGameMenuStartingUnitsBuilderOnly",
multi:
        "translateGameMenuStartingUnits"
    }
    
    enum comboUnitsLimit
    {
        "translateGameMenuUnitsLimitNoLimit",
        "translateGameMenuUnitsLimit20000CR",
        "translateGameMenuUnitsLimit50000CR",
        "100000 CR",
multi:
        "translateGameMenuUnitsLimit"
    }

    enum comboAlliedVictory
    {
        "translateGameMenuAlliedVictoryNo",
        "translateGameMenuAlliedVictoryYes",
multi:
        "translateGameMenuAlliedVictory"
    }
    
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        player rPlayer;
        int i;
        int nStartingMoney;
        
        
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

        bGameEnded=false;
        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);

            if(rPlayer!=null) 
            {
                rPlayer.SetMaxDistance(30);
                if(comboAlliedVictory)
                    rPlayer.EnableAIFeatures2(ai2BNSendResult,false);//nie wysylac rezultatow do EARTH NETu       
            
                rPlayer.SetMoney(100000);
                rPlayer.EnableAIFeatures(aiBuildMiningBuildings|aiBuildMiningUnits|aiControlMiningUnits,false);
                rPlayer.LookAt(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),6,0,20,0);
                
                if(comboUnitsLimit==0) rPlayer.EnableMilitaryUnitsLimit(false);
                if(comboUnitsLimit==1) rPlayer.SetMilitaryUnitsLimit(20000);
                if(comboUnitsLimit==2) rPlayer.SetMilitaryUnitsLimit(50000);
                if(comboUnitsLimit==3) rPlayer.SetMilitaryUnitsLimit(100000);
                
                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    rPlayer.CreateDefaultUnit(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),0);        
                
                rPlayer.EnableBuilding("EDBMI",false);
                rPlayer.EnableBuilding("EDBRE",false);
                rPlayer.EnableBuilding("UCSBRF",false);
                rPlayer.EnableBuilding("LCBMR",false);
                                    
                rPlayer.EnableResearch("RES_UCS_UOH2",false);
                rPlayer.EnableResearch("RES_UCS_UOH3",false);
                rPlayer.EnableResearch("RES_UCS_UAH1",false);
                rPlayer.EnableResearch("RES_UCS_UAH2",false);
                rPlayer.EnableResearch("RES_UCS_UAH3",false);

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

                //neutral stuff
                rPlayer.AddResearch("RES_MCH2");
                rPlayer.AddResearch("RES_MCH3");
                rPlayer.AddResearch("RES_MCH4");
                rPlayer.AddResearch("RES_MSR2");
                rPlayer.AddResearch("RES_MSR3");
                rPlayer.AddResearch("RES_MSR4");
                rPlayer.AddResearch("RES_MMR2");
                rPlayer.AddResearch("RES_MMR3");
                rPlayer.AddResearch("RES_MMR4");


                if(rPlayer.GetRace()==1)//UCS
                {
                    rPlayer.AddResearch("RES_UCS_USL2");
                    rPlayer.AddResearch("RES_UCS_USL3");
                    rPlayer.AddResearch("RES_UCS_UML1");
                    rPlayer.AddResearch("RES_UCS_UML2");
                    rPlayer.AddResearch("RES_UCS_UML3");
                    rPlayer.AddResearch("RES_UCS_UHL1");
                    rPlayer.AddResearch("RES_UCS_UHL2");
                    rPlayer.AddResearch("RES_UCS_UHL3");
                    rPlayer.AddResearch("RES_UCS_U4L1");
                    rPlayer.AddResearch("RES_UCS_U4L2");
                    rPlayer.AddResearch("RES_UCS_U4L3");
                    rPlayer.AddResearch("RES_UCS_UBL1");
                    rPlayer.AddResearch("RES_UCS_UBL2");
                    rPlayer.AddResearch("RES_UCS_UMI1");
                    rPlayer.AddResearch("RES_UCS_UMI2");
                    rPlayer.AddResearch("RES_UCS_USS1");
                    rPlayer.AddResearch("RES_UCS_USS2");
                    rPlayer.AddResearch("RES_UCS_UBS1");
                    rPlayer.AddResearch("RES_UCS_UBS2");
                    rPlayer.AddResearch("RES_UCS_UBS3");
                    rPlayer.AddResearch("RES_UCS_GARG1");
                    rPlayer.AddResearch("RES_UCS_GARG2");
                    rPlayer.AddResearch("RES_UCS_GARG3");
                    rPlayer.AddResearch("RES_UCS_BOMBER21");
                    rPlayer.AddResearch("RES_UCS_BOMBER22");
                    rPlayer.AddResearch("RES_UCS_BOMBER31");
                    rPlayer.AddResearch("RES_UCS_BOMBER32");
                    rPlayer.AddResearch("RES_UCS_BMD");
                    rPlayer.AddResearch("RES_UCS_BHD");
                    rPlayer.AddResearch("RES_UCS_WCH2");
                    rPlayer.AddResearch("RES_UCS_WACH2");
                    rPlayer.AddResearch("RES_UCS_WSR1");
                    rPlayer.AddResearch("RES_UCS_WSR2");
                    rPlayer.AddResearch("RES_UCS_WSR3");
                    rPlayer.AddResearch("RES_UCS_WASR1");
                    rPlayer.AddResearch("RES_UCS_WASR2");
                    rPlayer.AddResearch("RES_UCS_WSG1");
                    rPlayer.AddResearch("RES_UCS_WSG2");
                    rPlayer.AddResearch("RES_UCS_WHG1");
                    rPlayer.AddResearch("RES_UCS_WHG2");
                    rPlayer.AddResearch("RES_UCS_WMR1");
                    rPlayer.AddResearch("RES_UCS_WMR2");
                    rPlayer.AddResearch("RES_UCS_WMR3");
                    rPlayer.AddResearch("RES_UCS_WAMR1");
                    rPlayer.AddResearch("RES_UCS_WAMR2");
                    rPlayer.AddResearch("RES_UCS_WSP1");
                    rPlayer.AddResearch("RES_UCS_WSP2");
                    rPlayer.AddResearch("RES_UCS_WHP1");
                    rPlayer.AddResearch("RES_UCS_WHP2");
                    rPlayer.AddResearch("RES_UCS_WHP3");
                                        
                    if (comboResearchLimit!=2&&comboResearchLimit!=3)
                        rPlayer.AddResearch("RES_UCS_PC");
                    if (comboResearchLimit!=1&&comboResearchLimit!=3)
                    {
                        rPlayer.AddResearch("RES_UCS_WAPB1");
                        rPlayer.AddResearch("RES_UCS_WAPB2");
                    }
                    if (comboResearchLimit!=2&&comboResearchLimit!=3)
                        rPlayer.AddResearch("RES_UCS_WSD");
                    rPlayer.AddResearch("RES_UCS_RepHand");
                    rPlayer.AddResearch("RES_UCS_RepHand2");
                    rPlayer.AddResearch("RES_UCS_SGen");
                    rPlayer.AddResearch("RES_UCS_MGen");
                    rPlayer.AddResearch("RES_UCS_HGen");
                    rPlayer.AddResearch("RES_UCS_SHD");
                    rPlayer.AddResearch("RES_UCS_SHD2");
                    rPlayer.AddResearch("RES_UCS_SHD3");
                    rPlayer.AddResearch("RES_UCS_SHD4");
                    if (comboResearchLimit!=1&&comboResearchLimit!=3)
                    {
                        rPlayer.AddResearch("RES_UCS_MB2");
                        rPlayer.AddResearch("RES_UCS_MB3");
                        rPlayer.AddResearch("RES_UCS_MB4");
                    }
                    rPlayer.AddResearch("RES_UCS_MG2");
                    rPlayer.AddResearch("RES_UCS_MG3");
                    rPlayer.AddResearch("RES_UCS_MG4");
                }

                if(rPlayer.GetRace()==2)//ed
                {
                    rPlayer.AddResearch("RES_ED_UST2");
                    rPlayer.AddResearch("RES_ED_UST3");
                    rPlayer.AddResearch("RES_ED_UHT1");
                    rPlayer.AddResearch("RES_ED_UHT2");
                    rPlayer.AddResearch("RES_ED_UHT3");
                    rPlayer.AddResearch("RES_ED_UBT1");
                    rPlayer.AddResearch("RES_ED_UBT2");
                    rPlayer.AddResearch("RES_ED_UOH2");
                    rPlayer.AddResearch("RES_ED_UMT1");
                    rPlayer.AddResearch("RES_ED_UMT2");
                    rPlayer.AddResearch("RES_ED_UMT3");
                    rPlayer.AddResearch("RES_ED_UMI1");
                    rPlayer.AddResearch("RES_ED_UMI2");
                    rPlayer.AddResearch("RES_ED_UMW1");
                    rPlayer.AddResearch("RES_ED_UMW2");
                    rPlayer.AddResearch("RES_ED_UMW3");
                    rPlayer.AddResearch("RES_ED_UHW1");
                    rPlayer.AddResearch("RES_ED_UHW2");
                    rPlayer.AddResearch("RES_ED_USS2");
                    rPlayer.AddResearch("RES_ED_USS3");
                    rPlayer.AddResearch("RES_ED_UHS1");
                    rPlayer.AddResearch("RES_ED_UHS2");
                    rPlayer.AddResearch("RES_ED_UA11");
                    rPlayer.AddResearch("RES_ED_UA12");
                    rPlayer.AddResearch("RES_ED_UA21");
                    rPlayer.AddResearch("RES_ED_UA22");
                    rPlayer.AddResearch("RES_ED_UA41");
                    rPlayer.AddResearch("RES_ED_UA42");
                    rPlayer.AddResearch("RES_ED_UA31");
                    rPlayer.AddResearch("RES_ED_UA32");
                                        rPlayer.AddResearch("RES_ED_BMD");
                    rPlayer.AddResearch("RES_ED_BHD");
                    rPlayer.AddResearch("RES_ED_WCH2");
                    rPlayer.AddResearch("RES_ED_ACH2");
                    rPlayer.AddResearch("RES_ED_WCA2");
                    rPlayer.AddResearch("RES_ED_WHC1");
                    rPlayer.AddResearch("RES_ED_WHC2");
                    rPlayer.AddResearch("RES_ED_WSR1");
                    rPlayer.AddResearch("RES_ED_WSR2");
                    rPlayer.AddResearch("RES_ED_WSR3");
                    rPlayer.AddResearch("RES_ED_ASR1");
                    rPlayer.AddResearch("RES_ED_ASR2");
                    rPlayer.AddResearch("RES_ED_WNR");
                    rPlayer.AddResearch("RES_ED_WMR1");
                    rPlayer.AddResearch("RES_ED_WMR2");
                    rPlayer.AddResearch("RES_ED_WMR3");
                    rPlayer.AddResearch("RES_ED_AMR1");
                    rPlayer.AddResearch("RES_ED_AMR2");
                    if (comboResearchLimit!=2&&comboResearchLimit!=3)
                        rPlayer.AddResearch("RES_ED_WHR1");
                    rPlayer.AddResearch("RES_ED_WSL1");
                    rPlayer.AddResearch("RES_ED_WSL2");
                    rPlayer.AddResearch("RES_ED_WSL3");
                    rPlayer.AddResearch("RES_ED_WHL1");
                    rPlayer.AddResearch("RES_ED_WHL2");
                    rPlayer.AddResearch("RES_ED_WHL3");
                    rPlayer.AddResearch("RES_ED_WSI1");
                    rPlayer.AddResearch("RES_ED_WSI2");
                    rPlayer.AddResearch("RES_ED_WHI1");
                    rPlayer.AddResearch("RES_ED_WHI2");
                    if (comboResearchLimit!=1&&comboResearchLimit!=3)
                    {
                        rPlayer.AddResearch("RES_ED_AB1");
                        rPlayer.AddResearch("RES_ED_AB2");
                    }
                    rPlayer.AddResearch("RES_ED_RepHand");
                    rPlayer.AddResearch("RES_ED_RepHand2");
                    rPlayer.AddResearch("RES_ED_SGen");
                    rPlayer.AddResearch("RES_ED_MGen");
                    rPlayer.AddResearch("RES_ED_HGen");
                    rPlayer.AddResearch("RES_ED_SCR");
                    rPlayer.AddResearch("RES_ED_SCR2");
                    rPlayer.AddResearch("RES_ED_SCR3");
                    rPlayer.AddResearch("RES_ED_MHR2");
                    rPlayer.AddResearch("RES_ED_MHR3");
                    rPlayer.AddResearch("RES_ED_MHR4");
                                        
                    if (comboResearchLimit!=1&&comboResearchLimit!=3)
                    {
                        rPlayer.AddResearch("RES_ED_MB2");
                        rPlayer.AddResearch("RES_ED_MB3");
                        rPlayer.AddResearch("RES_ED_MB4");
                    }
                    rPlayer.AddResearch("RES_ED_MSC2");
                    rPlayer.AddResearch("RES_ED_MSC3");
                    rPlayer.AddResearch("RES_ED_MSC4");
                    rPlayer.AddResearch("RES_ED_MHC2");
                    rPlayer.AddResearch("RES_ED_MHC3");
                    rPlayer.AddResearch("RES_ED_MHC4");
                }
                if(rPlayer.GetRace()==3)//lc
                {
                    rPlayer.AddResearch("RES_LC_ULU2");
                    rPlayer.AddResearch("RES_LC_ULU3");
                    rPlayer.AddResearch("RES_LC_UMO2");
                    rPlayer.AddResearch("RES_LC_UMO3");
                    rPlayer.AddResearch("RES_LC_UCR1");
                    rPlayer.AddResearch("RES_LC_UCR2");
                    rPlayer.AddResearch("RES_LC_UCR3");
                    rPlayer.AddResearch("RES_LC_UCU1");
                    rPlayer.AddResearch("RES_LC_UCU2");
                    rPlayer.AddResearch("RES_LC_UCU3");
                                        rPlayer.AddResearch("RES_LC_UME1");
                    rPlayer.AddResearch("RES_LC_UME2");
                    rPlayer.AddResearch("RES_LC_UME3");
                    rPlayer.AddResearch("RES_LC_UBO1");
                    rPlayer.AddResearch("RES_LC_UBO2");
                    rPlayer.AddResearch("RES_LC_BMD");
                    rPlayer.AddResearch("RES_LC_BHD");
                    if (comboResearchLimit!=2&&comboResearchLimit!=3)
                        rPlayer.AddResearch("RES_LC_BWC");
                    if (comboResearchLimit!=2&&comboResearchLimit!=3)
                        rPlayer.AddResearch("RES_LC_SDIDEF");
                    rPlayer.AddResearch("RES_LC_WCH2");
                    rPlayer.AddResearch("RES_LC_ACH2");
                    rPlayer.AddResearch("RES_LC_WSR2");
                    rPlayer.AddResearch("RES_LC_WSR3");
                    rPlayer.AddResearch("RES_LC_ASR1");
                    rPlayer.AddResearch("RES_LC_ASR2");
                    rPlayer.AddResearch("RES_LC_WMR1");
                    rPlayer.AddResearch("RES_LC_WMR2");
                    rPlayer.AddResearch("RES_LC_WMR3");
                    rPlayer.AddResearch("RES_LC_AMR1");
                    rPlayer.AddResearch("RES_LC_AMR2");
                    rPlayer.AddResearch("RES_LC_WSL1");
                    rPlayer.AddResearch("RES_LC_WSL2");
                    rPlayer.AddResearch("RES_LC_WHL1");
                    rPlayer.AddResearch("RES_LC_WHL2");
                    rPlayer.AddResearch("RES_LC_WSS1");
                    rPlayer.AddResearch("RES_LC_WSS2");
                    rPlayer.AddResearch("RES_LC_WHS1");
                    rPlayer.AddResearch("RES_LC_WHS2");
                    rPlayer.AddResearch("RES_LC_WAS1");
                    rPlayer.AddResearch("RES_LC_WAS2");
                    rPlayer.AddResearch("RES_LC_WARTILLERY");
                    rPlayer.AddResearch("RES_LC_SGen");
                    rPlayer.AddResearch("RES_LC_MGen");
                    rPlayer.AddResearch("RES_LC_HGen");
                    rPlayer.AddResearch("RES_LC_SHR1");
                    rPlayer.AddResearch("RES_LC_SHR2");
                    rPlayer.AddResearch("RES_LC_SHR3");
                    rPlayer.AddResearch("RES_LC_REG1");
                    rPlayer.AddResearch("RES_LC_REG2");
                    rPlayer.AddResearch("RES_LC_REG3");
                    rPlayer.AddResearch("RES_LC_SOB1");
                    rPlayer.AddResearch("RES_LC_SOB2");
                }
                //MOON Project
                rPlayer.EnableCommand(commandSoldBuilding,true);
                rPlayer.AddResearch("RES_MISSION_PACK1_ONLY");

                if(comboResearchLimit==1||comboResearchLimit==3)
                {
                    //no bombs
                    rPlayer.EnableResearch("RES_UCS_ART",false);
                    rPlayer.EnableResearch("RES_ED_ART",false);
                    rPlayer.EnableResearch("RES_LC_ART",false);
                }
                if(comboResearchLimit==2||comboResearchLimit==3)
                {
                    //no MDW
                    rPlayer.EnableResearch("RES_UCS_USM1",false);
                    rPlayer.EnableResearch("RES_UCS_USM2",false);
                    rPlayer.EnableResearch("RES_ED_USM1",false);
                    rPlayer.EnableResearch("RES_ED_USM2",false);
                }

                if (rPlayer.GetRace() == raceUCS)
                {
                    rPlayer.AddResearch("RES_UCSUCS");
                                        rPlayer.AddResearch("RES_UCSUUT");
                    rPlayer.AddResearch("RES_UCSBHT");
                    rPlayer.AddResearch("RES_UCSWTSC1");
                    rPlayer.AddResearch("RES_UCSWTSC2");
                    rPlayer.AddResearch("RES_UCSWBHC1");
                    rPlayer.AddResearch("RES_UCSWBHC2");
                    rPlayer.AddResearch("RES_UCS_MSC2");
                    rPlayer.AddResearch("RES_UCS_MSC3");
                    rPlayer.AddResearch("RES_UCS_MSC4");
                    rPlayer.AddResearch("RES_UCS_MHC2");
                    rPlayer.AddResearch("RES_UCS_MHC3");
                    rPlayer.AddResearch("RES_UCS_MHC4");
                    if (comboResearchLimit!=1&&comboResearchLimit!=3)
                        rPlayer.AddResearch("RES_UCS_ART");
                    rPlayer.AddResearch("RES_UCSCAA1");
                    rPlayer.AddResearch("RES_UCSCAA2");
                    rPlayer.AddResearch("RES_UCSWAP1");
                    rPlayer.AddResearch("RES_UCSWAP2");
                    rPlayer.AddResearch("RES_UCSWAN1");
                    rPlayer.AddResearch("RES_UCSWEQ1");
                    rPlayer.AddResearch("RES_UCSWEQ2");
                    rPlayer.AddResearch("RES_UCS_BC1");
                    if (comboResearchLimit!=2&&comboResearchLimit!=3)
                    {
                        rPlayer.AddResearch("RES_UCS_USM1");
                        rPlayer.AddResearch("RES_UCS_USM2");
                    }
                }
                if (rPlayer.GetRace() == raceED)
                {
                                        if (comboResearchLimit!=1&&comboResearchLimit!=3)
                                            rPlayer.AddResearch("RES_ED_ART");
                    rPlayer.AddResearch("RES_EDBHT");
                    rPlayer.AddResearch("RES_EDWAA1");
                    rPlayer.AddResearch("RES_EDWAN1");
                    rPlayer.AddResearch("RES_EDWEQ1");
                    rPlayer.AddResearch("RES_EDWEQ2");
                    rPlayer.AddResearch("RES_ED_BC1");
                                        rPlayer.AddResearch("RES_EDUSTEALTH");
                                        rPlayer.AddResearch("RES_EDUUT");
                    if (comboResearchLimit!=2&&comboResearchLimit!=3)
                    {
                        rPlayer.AddResearch("RES_ED_USM1");
                        rPlayer.AddResearch("RES_ED_USM2");
                    }
                }
                if (rPlayer.GetRace() == raceLC)
                {
                    rPlayer.AddResearch("RES_LCBPP2");
                    rPlayer.AddResearch("RES_LCUFG1");
                    rPlayer.AddResearch("RES_LCUFG2");
                    rPlayer.AddResearch("RES_LCUFG3");
                    rPlayer.AddResearch("RES_LCBNE");
                    rPlayer.AddResearch("RES_LCUNH");
                                        rPlayer.AddResearch("RES_LCUUT");
                    if (comboResearchLimit!=1&&comboResearchLimit!=3)
                        rPlayer.AddResearch("RES_LC_ART");
                    rPlayer.AddResearch("RES_LCWAN1");
                    rPlayer.AddResearch("RES_LCWEQ1");
                    rPlayer.AddResearch("RES_LCWEQ2");
                    rPlayer.AddResearch("RES_LCUSF1");
                    rPlayer.AddResearch("RES_LCUSF2");
                    rPlayer.AddResearch("RES_LCCAA1");
                    rPlayer.AddResearch("RES_LC_BC1");
                }





            }
        }
        SetTimer(0,100);
        SetTimer(1, 20);
        SetTimer(2,1200);
        SetTimer(3,200);
        SetTimer(5,200);
        return Nothing;
    }
    
    state Nothing
    {
        return Nothing;
    }
    
    event RemoveResources()
    {
        true;
    }
    
    event RemoveUnits()
    {
        if(comboStartingUnits)
            true;
        else
            false;
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
                                    iCountBuilding = rPlayer.GetNumberOfBuildings() + rPlayer.GetNumberOfUnits();
                                if(comboWinCondition==1)
                                    iCountBuilding = rPlayer.GetNumberOfBuildings();
                    
                                if(comboWinCondition==2)//main structures
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
                                if(comboWinCondition==3)//power plants
                                    iCountBuilding = rPlayer.GetNumberOfBuildings(buildingPowerPlant)+
                                            rPlayer.GetNumberOfBuildings(buildingSolarPower)+
                                            rPlayer.GetNumberOfBuildings(buildingEnergyBattery);

                                if(comboWinCondition==4)//factorys
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
        int i;
        player rPlayer;
        
        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null) 
            {
                if(rPlayer.GetMoney()<100000)
                    rPlayer.AddMoney(100000 - rPlayer.GetMoney());
            }
        }
    }
    
    event Timer2()
    {
        if(comboWinCondition==0)
            SetConsoleText("translateScriptDestroyEverything");
        if(comboWinCondition==1)
            SetConsoleText("translateScriptDestroyAllStructures");
        if(comboWinCondition==2)
            SetConsoleText("translateScriptDestroyMainStructures");
        if(comboWinCondition==3)
            SetConsoleText("translateScriptDestroyPowerPlants");
        if(comboWinCondition==4)
            SetConsoleText("translateScriptDestroyFactories");
                
    }
    event Timer3()
    {
        int i;
        player rPlayer;
        
        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null) 
            {
                if(rPlayer.GetMaxDistance()<255)
                    rPlayer.SetMaxDistance(rPlayer.GetMaxDistance()+1);
            }
        }
    }

    event Timer5()
    {
        int i;
        int j;
        player rPlayer;
        player rPlayer2;
        //sprawdzanie zenablowania szpiegowania 
        //(po 10 minutach - warunek player ma 2 lub mniej budynki inne niz wiezyczki
        //i 4 lub mniej wiezyczki i 6 lub mniej unitow)
        //jesli warunek nie jest spelniony to z powrotem disablujemy szpiegowanie
        if (GetMissionTime() > 10*60*20)
        {
            for (i = 0; i < 15; i = i + 1)
            {
                rPlayer = GetPlayer(i);
                if ((rPlayer != null) && rPlayer.IsAlive())
                {
                    if ((rPlayer.GetNumberOfBuildings(buildingNormal) <= 4) &&
                        ((rPlayer.GetNumberOfBuildings() - rPlayer.GetNumberOfBuildings(buildingNormal)) <= 2) &&
                        (rPlayer.GetNumberOfUnits() <= 6))
                    {
                        for (j = 0; j < 15; j = j + 1)
                        {
                            rPlayer2 = GetPlayer(j);
                            if ((j != i) && (rPlayer2 != null) && rPlayer2.IsAlive() && !rPlayer2.IsAlly(rPlayer))
                            {
                                if (rPlayer2.IsCommandDisabled(commandBuildingSpyPlayer0 + i))
                                    rPlayer2.EnableCommand(commandBuildingSpyPlayer0 + i, true);
                            }
                        }
                    }
                    else
                    {
                        for (j = 0; j < 15; j = j + 1)
                        {
                            rPlayer2 = GetPlayer(j);
                            if ((j != i) && (rPlayer2 != null) && rPlayer2.IsAlive())
                            {
                                if (rPlayer2.IsCommandEnabled(commandBuildingSpyPlayer0 + i))
                                    rPlayer2.EnableCommand(commandBuildingSpyPlayer0 + i, false);
                            }
                        }
                    }
                }
            }
        }
    }
    
    command Initialize()
    {
        comboResearchLimit=0;
        comboWinCondition=0;
        comboStartingUnits=1;
        comboAlliedVictory=1;
        comboUnitsLimit=2;
    }
    
    command Combo1(int nMode) button comboResearchLimit
    {
        comboResearchLimit = nMode;
    }
    command Combo2(int nMode) button comboWinCondition
    {
        comboWinCondition = nMode;
    }
    command Combo3(int nMode) button comboStartingUnits 
    {
        comboStartingUnits = nMode;
    }
    command Combo4(int nMode) button comboUnitsLimit
    {
        comboUnitsLimit = nMode;
    }
    command Combo5(int nMode) button comboAlliedVictory
    {
        comboAlliedVictory = nMode;
    }
    
}

