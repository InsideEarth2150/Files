campaign "translateCampaignED"
{
    consts
    {
        raceUCS=1;
        raceED=2;
        raceLC=3;
        
        mis211 = 0;
        
        baseUCS = 30;
        baseED = 31;
        baseLC = 32;
        
        timeFlagWinter = 1;
        timeFlagEarlySpring = 2;
        timeFlagSpring = 4;
        timeFlagSummer = 8;
        timeFlagDesert = 16;
        timeFlagVolcano = 32;
        timeFlagHeavyVolcano = 64;
        baseFlag = 255 ;
        
        // czas zmiany por roku
        
        timeEarlySpring = 400000; //= 20000 sec = 333 min = 5h 33 min
        timeSpring = 800000;
        timeSummer = 1200000;
        timeDesert = 1600000;
        timeVolcano = 2000000;
        timeHeavyVolcano = 2400000;
        timeEarthDestroyed=2800000;  // = 38h 30min
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
        
        RegisterMission(baseUCS,"!baseUCS","ED\\Missions\\baseUCSscript","",  baseFlag,                  -84, 41,0,0,0);
        RegisterMission(baseED,"!baseED","ED\\Missions\\baseEDscriptDemo","",        baseFlag,                      50, 60,0,0,0);
        RegisterMission(baseLC,"!baseLC","ED\\Missions\\baseLCscript","",        baseFlag,                   120,  8,0,0,0);
        //                   nr       lnd        script                    preBriefing                 timeFlags          x  y   d1  d2  d3  next1 next2 next3 next4              
        RegisterMission(mis211, "!211", "ED\\Missions\\Mission211Demo", "translateBriefingShort211", timeFlagWinter,           60, 60, 60, 60, 60);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------      
        n_CashCounter = timeFlagEarlySpring;
        n_TimeFlag = timeFlagWinter;
        b_showVideo = true;
        b_showVideo2 = false;
        
        
        CreateGamePlayer(1,raceUCS,playerAI,null);
        CreateGamePlayer(2,raceED,playerLocal,null);
        CreateGamePlayer(3,raceLC,playerAI,null);
        
        LoadBase(1,baseUCS,1);
        LoadBase(2,baseED,2);
        LoadBase(3,baseLC,3);
        SetTime(100);
        SetActivePlayerAndWorld(2,2);//player, world
        SetAvailableWorlds(1|4);//misja i baza ed(swiat nr 2)
        
        SetSeason(1);
        EnableMission(mis211,true);
        ActivateMissions(timeFlagWinter,true);
        
        return Start,240;
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
                ShowVideo("CS214");
        }
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------
    event StartMission(int iMission)
    {
        EnableChooseMissionButton(false);
        TraceD(iMission);
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
        //SetMissionState(nr,stan); stateAccomplished, stateFailed, stateSkiped
        if(nResult==true)
            SetMissionState(iMission,stateAccomplished);
        else
            SetMissionState(iMission,stateFailed);
    }
}

//************************************


