mission "translateGameTypeEarnMoney"
{
    int nMoneyToEarn;
    int nTimeLimit;
    
    enum comboMoney
    {
        "translateScript20000CR",
        "translateScript30000CR",
        "translateScript40000CR",
multi:
        "translateGameMenuStartingMoney"
    }
    enum comboMoneyToEarn
    {
                "translateScript25000CR",
        "translateScript40000CR",
        "translateScript50000CR",
        "translateScript75000CR",
                "translateScript100000CR",
multi:
        "translateGameMenuMoneyToGain"
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
    
    
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        player rPlayer;
        int i;
        int nStartingMoney;
        
        if(comboMoney==0) nStartingMoney=20000;
        if(comboMoney==1) nStartingMoney=30000;
        if(comboMoney==2) nStartingMoney=40000;
                
        nMoneyToEarn=25000;
        if(comboMoneyToEarn==1) nMoneyToEarn=40000;
        if(comboMoneyToEarn==2) nMoneyToEarn=50000;
        if(comboMoneyToEarn==3) nMoneyToEarn=75000;
                if(comboMoneyToEarn==4) nMoneyToEarn=100000;
        
        if(comboTime==0)nTimeLimit=0;
        if(comboTime==1)nTimeLimit=15*60*20;
        if(comboTime==2)nTimeLimit=30*60*20;
        if(comboTime==3)nTimeLimit=45*60*20;
        if(comboTime==4)nTimeLimit=60*60*20;
        if(comboTime==5)nTimeLimit=90*60*20;
        
        if(comboResources==0)ResourcesPerContainer(16);
        if(comboResources==1)ResourcesPerContainer(8);
        if(comboResources==2)ResourcesPerContainer(4);
        if(comboResources==3)ResourcesPerContainer(2);
        
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
                                rPlayer.SetAllowGiveMoney(false);
                rPlayer.SetMoney(nStartingMoney);
                rPlayer.LookAt(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),6,0,20,0);
                
                if(comboUnitsLimit==0) rPlayer.EnableMilitaryUnitsLimit(false);
                if(comboUnitsLimit==1) rPlayer.SetMilitaryUnitsLimit(10000);
                if(comboUnitsLimit==2) rPlayer.SetMilitaryUnitsLimit(20000);
                if(comboUnitsLimit==3) rPlayer.SetMilitaryUnitsLimit(30000);
                if(comboUnitsLimit==4) rPlayer.SetMilitaryUnitsLimit(50000);
                
                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    rPlayer.CreateDefaultUnit(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),0);
            }
        }
        SetTimer(0,100);
        SetTimer(1,1200);
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
        int bOthersDefeat;
        int iCountBuilding;
        player rPlayer;
        player rLastPlayer;
        
        rLastPlayer=null;
        iAlivePlayers=0;
        bOthersDefeat=false;
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
                    if(rPlayer.GetMoney()>=nMoneyToEarn)
                    {
                        rPlayer.Victory();
                        bOthersDefeat=true;
                    }
                }
                else
                {
                                    rPlayer.Defeat();
                }
            }
        }
        if (iAlivePlayers==1 && rLastPlayer!=null && rPlayer.IsAlive())
        {
            rLastPlayer.Victory();
        }
        
        if(bOthersDefeat==true)
                {
                    for(i=0;i<15;i=i+1)
                    {
                            rPlayer = GetPlayer(i);
                            if(rPlayer!=null && rPlayer.IsAlive()) 
                            {
                                    if(rPlayer.GetMoney()<nMoneyToEarn)
                                    {
                                            rPlayer.Defeat();
                                            KillArea(rPlayer.GetIFF(),GetRight()/2,GetBottom()/2,0,128);
                                    }
                            }
                    }
                }
    }
    event Timer1()
    {
        int i;
                int minLeft;
        player rPlayer;
        
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
                                nTimeLimit=0;
            }
        }
    }
        
    command Initialize()
    {
        nTimeLimit=0;
        comboResources=1;
        comboStartingUnits=1;
        comboUnitsLimit=2;
    }
    
    command Uninitialize()
    {
        ResourcesPerContainer(8);
    }
    
    command Combo1(int nMode) button comboMoney
    {
        comboMoney=nMode;
        if(comboMoneyToEarn < comboMoney) comboMoneyToEarn = comboMoney;
    }
    
    command Combo2(int nMode) button comboMoneyToEarn
    {
        comboMoneyToEarn=nMode;
        if(comboMoneyToEarn < comboMoney) comboMoney = comboMoneyToEarn;
    }
    
    command Combo3(int nMode) button comboTime 
    {
        comboTime = nMode;
    }
    
    command Combo4(int nMode) button comboResources 
    {
        comboResources=nMode;
    }
    
    command Combo5(int nMode) button comboStartingUnits 
    {
        comboStartingUnits = nMode;
    }
    
    command Combo6(int nMode) button comboUnitsLimit
    {
        comboUnitsLimit = nMode;
    }
}

