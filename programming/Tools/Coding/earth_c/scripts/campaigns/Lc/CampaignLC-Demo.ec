
campaign "translateCampaignLC"
{
    consts
    {
        raceUCS=1;
        raceED=2;
        raceLC=3;
        
        
        mis314 = 0;
        
        baseUCS = 24;
        baseED = 25;
        baseLC = 26;
        
        timeFlagWinter = 1;
        timeFlagEarlySpring = 2;
        timeFlagSpring = 4;
        timeFlagSummer = 8;
        timeFlagDesert = 16;
        timeFlagVolcano = 32;
        timeFlagHeavyVolcano = 64;
        baseFlag = 255 ;
        
        // pieniadze przewidywane do budowy statku na poczatku okresu
        cashEarlySpring = 50000; 
        cashSpring = 100000;
        cashSummer = 150000;
        cashDesert = 200000;
        cashVolcano = 250000;
        spaceShipPrice = 300000;
        
        // czas zmiany por roku
        timeEarlySpring =     150000; //2h 5min
        timeSpring =          300000;
        timeSummer =          450000;
        timeDesert =          600000;
        timeVolcano =         750000;
        timeHeavyVolcano =    900000;
        timeEarthDestroyed= 1050000;  
    }
    
    int n_TimeFlag;
    int n_CashCounter;
    int b_showVideo;
    int b_showVideo2;
    
    state Initialize;
    state Start;
    state Nothing;
    
    state Initialize
    {
        int i;
        
        RegisterMission(baseUCS,"!baseUCS","LC\\Missions\\LCbaseUCSscript","", baseFlag,                    -84, 41,0,0,0);
        RegisterMission(baseED,"!baseED","LC\\Missions\\LCbaseEDscript","",      baseFlag,                   50, 60,0,0,0);
        RegisterMission(baseLC,"!baseLC","LC\\Missions\\LCbaseLCscriptDemo","",      baseFlag,                  120,  8,0,0,0);
        //                   nr       lnd        script                    preBriefing                 timeFlags          x  y   d1  d2  d3  next1 next2 next3 next4              
        RegisterMission(mis314, "!314", "LC\\Missions\\Mission314Demo", "translateBriefingShort314", timeFlagWinter,        120, 85,20,20,20);
        
        n_CashCounter = timeFlagEarlySpring;
        n_TimeFlag = timeFlagWinter;
        b_showVideo = true;
        b_showVideo2 = false;
        
        CreateGamePlayer(1,raceUCS,playerAI,null);
        CreateGamePlayer(2,raceED,playerAI,null);
        CreateGamePlayer(3,raceLC,playerLocal,null);
        
        LoadBase(1,baseUCS,1);
        LoadBase(2,baseED,2);
        LoadBase(3,baseLC,3);
        
        SetActivePlayerAndWorld(3,3);//player, world
        SetAvailableWorlds(1|8);//misja i baza LC(swiat nr 3)
        
        EnableMission(mis314,true);
        ActivateMissions(timeFlagWinter,true);
        SetSeason(1);
        
        return Start,700;
    }
    //-----------------------------------------------------------------------------------------
    state Start
    {
        EnableChooseMissionButton(true);
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(b_showVideo2)
        {
            b_showVideo2 = false;
            
            if(n_TimeFlag == timeFlagWinter)
                ShowVideo("CS314");
            
            if(n_TimeFlag == timeFlagSpring)
                ShowVideo("CS315");
            
            if(n_TimeFlag == timeFlagDesert)
                ShowVideo("CS316");
            
            if(n_TimeFlag == timeFlagVolcano)
                ShowVideo("CS317");
        }
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------
    event StartMission(int iMission)
    {
        EnableChooseMissionButton(false);
        LoadMission(0,iMission);
        
        EnableMission(iMission,false);
        
        if(b_showVideo)
        {
            b_showVideo = false;
            b_showVideo2 = true;
        }
    }
    //-----------------------------------------------------------------------------------------
    event EnableNextMission(int iMission,int iNextNr,int bEnable)
    {
    }
    //-----------------------------------------------------------------------------------------
    event EndMission(int iMission, int nResult) // 
    {
        int nTime;
        int nNewTimeFlag;
        nTime = GetCampaignTime();
        if(nResult==true)
            SetMissionState(iMission,stateAccomplished);
        else
            SetMissionState(iMission,stateFailed);
    }
}

//************************************


