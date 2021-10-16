mission "translateGameTypeHarvestAndKill"
{
    
    int nTimeLimit;
    int bCheckBuilding;
    int nMeteor;
    
    enum comboMoney
    {
              "translateScript20000CR",
        "translateScript30000CR",
        "translateScript40000CR",
                "translateScript50000CR",
multi:
        "translateGameMenuStartingMoney"
    }
    
    enum comboTime
    {
        "translateGameMenuTimeLimitNoLimit",
        "translateGameMenuTimeLimit15min",
        "translateGameMenuTimeLimit30min",
        "translateGameMenuTimeLimit45min",
        "translateGameMenuTimeLimit1h",
        "translateGameMenuTimeLimit15h",
multi:
        "translateGameMenuTimeLimit"
    }
        /*enum comboTime
    {
        "translateGameMenuTimeLimit15min",
        "translateGameMenuTimeLimit30min",
        "translateGameMenuTimeLimit45min",
multi:
        "translateGameMenuTimeLimit"
    }*/
    enum comboResources
    {
        "translateGameMenuResourcesLow",
        "translateGameMenuResourcesNormal",
        "translateGameMenuResourcesHigh",
        "translateGameMenuResourcesVeryHigh",
multi:
        "translateGameMenuResources"
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
        "translateGameMenuUnitsLimit10000CR",
        "translateGameMenuUnitsLimit20000CR",
        "translateGameMenuUnitsLimit30000CR",
        "translateGameMenuUnitsLimit50000CR",
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
        
        
        
        
        if(comboMoney==0)nStartingMoney = 20000;
        if(comboMoney==1)nStartingMoney = 30000;
        if(comboMoney==2)nStartingMoney = 40000;
        if(comboMoney==3)nStartingMoney = 50000;
        
        
        if(comboTime==0)nTimeLimit=0;
        if(comboTime==1)nTimeLimit=15*60*20;
        if(comboTime==2)nTimeLimit=30*60*20;
        if(comboTime==3)nTimeLimit=45*60*20;
        if(comboTime==4)nTimeLimit=60*60*20;
        if(comboTime==5)nTimeLimit=90*60*20;

        /*nTimeLimit=15*60*20;
        if(comboTime==1)nTimeLimit=30*60*20;
        if(comboTime==2)nTimeLimit=45*60*20;*/
        
        if(comboResources==0) ResourcesPerContainer(16);
        if(comboResources==1) ResourcesPerContainer(8);
        if(comboResources==2) ResourcesPerContainer(4);
        if(comboResources==3) ResourcesPerContainer(2);
        
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

        bCheckBuilding=false;
        for(i=0;i<15;i=i+1)
        {
            rPlayer=GetPlayer(i);
            
                              
            if(rPlayer!=null) 
            {
                                if(comboAlliedVictory)
                                    rPlayer.EnableAIFeatures2(ai2BNSendResult,false);//nie wysylac rezultatow do EARTH NETu       
            
                if(comboUnitsLimit==0) rPlayer.EnableMilitaryUnitsLimit(false);
                if(comboUnitsLimit==1) rPlayer.SetMilitaryUnitsLimit(10000);
                if(comboUnitsLimit==2) rPlayer.SetMilitaryUnitsLimit(20000);
                if(comboUnitsLimit==3) rPlayer.SetMilitaryUnitsLimit(30000);
                if(comboUnitsLimit==4) rPlayer.SetMilitaryUnitsLimit(50000);
                
                rPlayer.EnableAIFeatures2(ai2BNSendResult,false);//nie wysylac rezultatow do EARTH NETu
                
                rPlayer.SetMoney(nStartingMoney);
                rPlayer.LookAt(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),6,0,20,0);
                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    rPlayer.CreateDefaultUnit(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),0);
                rPlayer.EnableResearch("RES_ED_ACH2",false);
                rPlayer.EnableResearch("RES_ED_WSL1",false);
                rPlayer.EnableResearch("RES_ED_WSI1",false);
                rPlayer.EnableResearch("RES_ED_WSR2",false);
                                rPlayer.EnableResearch("RES_ED_ASR1",false);
                rPlayer.EnableResearch("RES_ED_WMR1",false);
                rPlayer.EnableResearch("RES_ED_WHC1",false);
                rPlayer.EnableResearch("RES_ED_WHI1",false);
                rPlayer.EnableResearch("RES_ED_WHL1",false);
                rPlayer.EnableResearch("RES_ED_WHR1",false);
                rPlayer.EnableResearch("RES_ED_AB1",false);
                //ammo
                rPlayer.EnableResearch("RES_ED_MHC2",false);
                rPlayer.EnableResearch("RES_ED_MB2",false);
                rPlayer.EnableResearch("RES_ED_MSC3",false);
                rPlayer.EnableResearch("RES_MMR2",false);
                rPlayer.EnableResearch("RES_MSR3",false);
                rPlayer.EnableResearch("RES_ED_MHR2",false);
                rPlayer.EnableResearch("RES_ED_MHR4",false);
                //chassis
                rPlayer.EnableResearch("RES_ED_UST3",false);
                rPlayer.EnableResearch("RES_ED_UMT2",false);
                rPlayer.EnableResearch("RES_ED_UMW1",false);
                rPlayer.EnableResearch("RES_ED_UMI1",false);
                rPlayer.EnableResearch("RES_ED_UHT1",false);
                rPlayer.EnableResearch("RES_ED_UHW1",false);
                rPlayer.EnableResearch("RES_ED_UBT1",false);
                rPlayer.EnableResearch("RES_ED_UA11",false);
                rPlayer.EnableResearch("RES_ED_UA21",false);
                rPlayer.EnableResearch("RES_ED_UA31",false);
                rPlayer.EnableResearch("RES_ED_UA41",false);
                rPlayer.EnableResearch("RES_ED_USS2",false);
                rPlayer.EnableResearch("RES_ED_UHS1",false);
                //special
                rPlayer.EnableResearch("RES_ED_SCR",false);
                rPlayer.EnableResearch("RES_ED_SGen",false);
                rPlayer.EnableResearch("RES_ED_BMD",false);
                rPlayer.EnableResearch("RES_ED_BHD",false);
                rPlayer.EnableResearch("RES_ED_RepHand2",false);
                
                rPlayer.EnableBuilding("EDBHQ",false);
                rPlayer.EnableBuilding("EDBRA",false);
                rPlayer.EnableBuilding("EDBTC",false);
                
                
                //rPlayer.EnableResearch("RES_LC_WCH2",false);
                rPlayer.EnableResearch("RES_LC_ACH2",false);
                rPlayer.EnableResearch("RES_LC_ASR1",false);
                rPlayer.EnableResearch("RES_LC_WSR2",false);
                //rPlayer.EnableResearch("RES_LC_WSL1",false);
                rPlayer.EnableResearch("RES_LC_WSL2",false);
                rPlayer.EnableResearch("RES_LC_WSS1",false);
                rPlayer.EnableResearch("RES_LC_WMR1",false);
                rPlayer.EnableResearch("RES_LC_WHL1",false);
                rPlayer.EnableResearch("RES_LC_WHS1",false);
                
                rPlayer.EnableResearch("RES_LC_WAS1",false);
                //rPlayer.EnableResearch("RES_LC_UMO2",false);
                rPlayer.EnableResearch("RES_LC_UCR1",false);
                rPlayer.EnableResearch("RES_LC_UCU1",false);
                
                rPlayer.EnableResearch("RES_LC_ULU3",false);
                rPlayer.EnableResearch("RES_LC_UMO3",false);
                rPlayer.EnableResearch("RES_LC_UME1",false);
                rPlayer.EnableResearch("RES_LC_UBO1",false);
                
                rPlayer.EnableResearch("RES_LC_BMD",false);
                rPlayer.EnableResearch("RES_LC_BHD",false);
                rPlayer.EnableResearch("RES_LC_SDIDEF",false);
                //rPlayer.EnableResearch("RES_LC_SGen",false);
                rPlayer.EnableResearch("RES_LC_MGen",false);
                rPlayer.EnableResearch("RES_LC_MGen",false);
                rPlayer.EnableResearch("RES_LC_SHR1",false);
                rPlayer.EnableResearch("RES_LC_REG1",false);
                rPlayer.EnableResearch("RES_LC_SOB1",false);
                rPlayer.EnableResearch("RES_LC_SDIDEF",false);
                rPlayer.EnableResearch("RES_LC_BWC",false);
                //weapons
                rPlayer.EnableResearch("RES_UCS_WACH2",false);
                rPlayer.EnableResearch("RES_UCS_WHG1",false);
                rPlayer.EnableResearch("RES_UCS_WSR2",false);
                rPlayer.EnableResearch("RES_UCS_WSP2",false);
                rPlayer.EnableResearch("RES_UCS_WSD",false);
                //ammo
                rPlayer.EnableResearch("RES_UCS_WAPB1",false);
                rPlayer.EnableResearch("RES_UCS_MB2",false);
                //chassis
                rPlayer.EnableResearch("RES_UCS_GARG1",false);
                rPlayer.EnableResearch("RES_UCS_USL3",false);
                rPlayer.EnableResearch("RES_UCS_UML3",false);
                rPlayer.EnableResearch("RES_UCS_UHL1",false);
                rPlayer.EnableResearch("RES_UCS_UMI1",false);
                rPlayer.EnableResearch("RES_UCS_USS2",false);
                rPlayer.EnableResearch("RES_UCS_UBS1",false);
                rPlayer.EnableResearch("RES_UCS_USM1",false);
                rPlayer.EnableResearch("RES_UCS_UAH1",false);
                rPlayer.EnableResearch("RES_UCS_BOMBER21",false);
                //sopecial
                rPlayer.EnableResearch("RES_UCS_BMD",false);
                rPlayer.EnableResearch("RES_UCS_BHD",false);
                
                rPlayer.EnableResearch("RES_UCS_RepHand2",false);
                rPlayer.EnableResearch("RES_UCS_SGen",false);
                rPlayer.EnableResearch("RES_UCS_SHD",false);
                
                rPlayer.EnableResearch("RES_UCS_WSD",false);
                rPlayer.EnableResearch("RES_UCS_PC",false);
                
            }
        }
        SetTimer(0,100);
        SetTimer(1,1200);
        
        nMeteor=1;
        return Nothing;
    }
    
    state Nothing
    {
        return Nothing;
    }
    
    event RemoveResources()
    {
        false;
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
        //----meteors
        //rPlayer = GetPlayer(1);
        //Meteor(rPlayer.GetStartingPointX()-nMeteor*2,rPlayer.GetStartingPointY(),nMeteor);
        //nMeteor=(nMeteor%10)+1;
        //end of meteors
        
        if (bCheckBuilding==false)
            return 0;
        rLastPlayer=null;
        iAlivePlayers=0;
        if(comboAlliedVictory)//--------------------------------------------------------------
        {
            bOneHasBeenDestroyed=false;
            for(i=0;i<15;i=i+1)
            {
                rPlayer = GetPlayer(i);
                if(rPlayer!=null && rPlayer.IsAlive()) 
                {
                    iCountBuilding =    rPlayer.GetNumberOfBuildings() + rPlayer.GetNumberOfUnits();
                    if (iCountBuilding==0)rPlayer.Defeat();
                }
                if(rPlayer!=null && !rPlayer.IsAlive()) 
                    bOneHasBeenDestroyed=true;
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
                        if(rPlayer2!=null && rPlayer2.IsAlive() && !rPlayer.IsAlly(rPlayer2)) 
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
        else//---------------------------------------------------------------------------------
        {
            for(i=0;i<15;i=i+1)
            {
                rPlayer = GetPlayer(i);
                if(rPlayer!=null && rPlayer.IsAlive()) 
                {
                    iCountBuilding =    rPlayer.GetNumberOfBuildings() + rPlayer.GetNumberOfUnits();
                    if (iCountBuilding>0)
                    {
                        iAlivePlayers=iAlivePlayers+1;
                        rLastPlayer=rPlayer;
                    }
                    else
                    {
                        rPlayer.Defeat();
                    }
                }
            }
            if (iAlivePlayers==1 && rLastPlayer!=null)
            {
                rLastPlayer.Victory();
            }
        }
    }
    event Timer1()
    {
        int i;
                int minLeft;
        player rPlayer;
        
        bCheckBuilding=true;
        if(nTimeLimit)
        {
                        minLeft=(nTimeLimit - GetMissionTime())/1200;

                        if(minLeft<0)minLeft=0;
                        SetConsoleText("translateScriptTimeLeft",minLeft);
            if(minLeft<1)
            {
                for(i=0;i<15;i=i+1)
                {
                    rPlayer=GetPlayer(i);
                    if(rPlayer!=null && rPlayer.IsAlive()) 
                    {
                        rPlayer.Defeat();
                                                KillArea(rPlayer.GetIFF(),GetRight()/2,GetBottom()/2,0,128);
                    }
                }
                                AddBriefing("translateCampaignAccomplishedDemo");
                                nTimeLimit=0;
            }
        }
    }
    
    
    command Initialize()
    {
        comboMoney=0;
        comboResources=1;
        comboStartingUnits=1;
        comboAlliedVictory=1;
        comboUnitsLimit=2;
    }
    
    command Uninitialize()
    {
        ResourcesPerContainer(8);
    }
    
    command Combo1(int nMode) button comboMoney
    {
        comboMoney = nMode;
    }
    
    command Combo2(int nMode) button comboTime 
    {
        comboTime = nMode;
    }
    
    command Combo3(int nMode) button comboResources 
    {
        comboResources = nMode;
    }
    
    command Combo4(int nMode) button comboStartingUnits 
    {
        comboStartingUnits = nMode;
    }
    
    command Combo5(int nMode) button comboUnitsLimit
    {
        comboUnitsLimit = nMode;
    }
    command Combo6(int nMode) button comboAlliedVictory
    {
        comboAlliedVictory = nMode;
    }
    
}

