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
                
                rPlayer.SetMoney(nStartingMoney);
                rPlayer.LookAt(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),6,0,20,0);
                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    rPlayer.CreateDefaultUnit(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(),0);
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

