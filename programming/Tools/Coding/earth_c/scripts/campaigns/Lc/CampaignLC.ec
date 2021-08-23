
campaign "translateCampaignLC"
{
    consts
    {
        raceUCS=1;
        raceED=2;
        raceLC=3;
        
        
        mis311 = 0;
        mis312 = 1;
        mis313 = 2;
        mis314 = 3;
        mis315 = 4;
        mis321 = 5;
        mis322 = 6;
        mis323 = 7;
        mis331 = 8;
        mis333 = 9;
        mis334 = 10;
        mis341 = 11;
        mis342 = 12;
        mis343 = 13;
        mis344 = 14;
        mis351 = 15;
        mis352 = 16;
        mis353 = 17;
        mis354 = 18;
        mis361 = 19;
        mis362 = 20;
        mis363 = 21;
        mis371 = 22;
        mis372 = 23;
        
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
        RegisterMission(baseLC,"!baseLC","LC\\Missions\\LCbaseLCscript","",      baseFlag,                  120,  8,0,0,0);
        //                   nr       lnd        script                    preBriefing                 timeFlags          x  y   d1  d2  d3  next1 next2 next3 next4              
        RegisterMission(mis311, "!311", "LC\\Missions\\Mission311", "translateBriefingShort311", timeFlagWinter,         60, 60, 60, 60, 60, mis313,mis314,mis315);
        RegisterMission(mis312, "!312", "LC\\Missions\\Mission312", "translateBriefingShort312", timeFlagWinter,      105, 25, 20, 20, 20, mis323);
        RegisterMission(mis313, "!313", "LC\\Missions\\Mission313", "translateBriefingShort313", timeFlagWinter,       90, 35, 90, 90, 90);
        RegisterMission(mis314, "!314", "LC\\Missions\\Mission314", "translateBriefingShort314", timeFlagWinter,        120, 85,20,20,20, mis322);
        RegisterMission(mis315, "!315", "LC\\Missions\\Mission315", "translateBriefingShort315", timeFlagWinter,        161, 60, 90, 90, 90);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------      
        RegisterMission(mis321, "!321", "LC\\Missions\\Mission321", "translateBriefingShort321", timeFlagEarlySpring, 105, 52,0,0,0);
        RegisterMission(mis322, "!322", "LC\\Missions\\Mission322", "translateBriefingShort322", timeFlagEarlySpring,-100, 40,0,0,0, mis321);
        RegisterMission(mis323, "!323", "LC\\Missions\\Mission323", "translateBriefingShort323", timeFlagEarlySpring, 105, 25,0,0,0, mis333);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis331, "!331", "LC\\Missions\\Mission331", "translateBriefingShort331", timeFlagSpring,        -90, 42,0,0,0, mis341,mis342,mis343,mis344);
        RegisterMission(mis333, "!333", "LC\\Missions\\Mission333", "translateBriefingShort333", timeFlagSpring,        105, 25,0,0,0, mis334);
        RegisterMission(mis334, "!334", "LC\\Missions\\Mission334", "translateBriefingShort334", timeFlagSpring,      -52, -2,0,0,0, mis331);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis341, "!341", "LC\\Missions\\Mission341", "translateBriefingShort341", timeFlagSummer,        -47,-18,0,0,0, mis353);
        RegisterMission(mis342, "!342", "LC\\Missions\\Mission342", "translateBriefingShort342", timeFlagSummer,         77, 15,0,0,0, mis354);
        RegisterMission(mis343, "!343", "LC\\Missions\\Mission343", "translateBriefingShort343", timeFlagSummer,         47,-18,0,0,0, mis351);
        RegisterMission(mis344, "!344", "LC\\Missions\\Mission344", "translateBriefingShort344", timeFlagSummer,        133,-13,0,0,0);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis351, "!351", "LC\\Missions\\Mission351", "translateBriefingShort351", timeFlagDesert,         35,-15,0,0,0, mis352);
        RegisterMission(mis352, "!352", "LC\\Missions\\Mission352", "translateBriefingShort352", timeFlagDesert,        -47,-18,0,0,0, mis361);
        RegisterMission(mis353, "!353", "LC\\Missions\\Mission353", "translateBriefingShort353", timeFlagDesert,         31, 30,0,0,0);
        RegisterMission(mis354, "!354", "LC\\Missions\\Mission354", "translateBriefingShort354", timeFlagDesert,         13, -3,0,0,0, mis362);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------      
        RegisterMission(mis361, "!361", "LC\\Missions\\Mission361", "translateBriefingShort361", timeFlagVolcano,        26,-27,0,0,0, mis363);
        RegisterMission(mis362, "!362", "LC\\Missions\\Mission362", "translateBriefingShort362", timeFlagVolcano,        26,-27,0,0,0, mis363);
        RegisterMission(mis363, "!363", "LC\\Missions\\Mission363", "translateBriefingShort363", timeFlagVolcano,       -75, -5,0,0,0, mis371,mis372);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis371, "!371", "LC\\Missions\\Mission371", "translateBriefingShort371", timeFlagHeavyVolcano,-55, -2,0,0,0);
        RegisterMission(mis372, "!372", "LC\\Missions\\Mission372", "translateBriefingShort372", timeFlagHeavyVolcano,-70,-30,0,0,0);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------      
        
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
        
        EnableMission(mis311,true);
        EnableMission(mis312,true);
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
        if(bEnable<2)
            EnableMission(GetNextMission(iMission,iNextNr),bEnable);
        if(bEnable==2)//enable ED base
            SetAvailableWorlds(GetAvailableWorlds()|4);
        if(bEnable==3)//enable UCS base
            SetAvailableWorlds(GetAvailableWorlds()|2);
        
        if(bEnable==4)//you have win the game
        {
            EndGame("Video\\OutroLC.wd1"); 
        }
        if(bEnable==5)//you loose the game
        {
            EndGame("Video\\OutroLost.wd1"); 
        }
        if(bEnable==6)//you loose the game hero is killed
        {
            EndGame(null); 
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission(int iMission, int nResult) // 
    {
        if(nResult==true)
            SetMissionState(iMission,stateAccomplished);
        else
            SetMissionState(iMission,stateFailed);
        
        
        if(!AreMissionsEnabledEq(n_TimeFlag,n_TimeFlag))
        {
            if(n_TimeFlag != timeFlagHeavyVolcano)
            {
                n_TimeFlag = n_TimeFlag*2;
                b_showVideo = true;
            }
        }
        
        if(AreMissionsEnabledEq(n_TimeFlag,n_TimeFlag))
        {
            ActivateMissionsEq(n_TimeFlag,n_TimeFlag,true);
        }
        else
        {
            SendCustomEvent(0,0,0,0,0);
            return;
        }
        SetSeason(1);
        if(n_TimeFlag==timeFlagEarlySpring)SetSeason(2);
        if(n_TimeFlag==timeFlagSpring) SetSeason(3);
        if(n_TimeFlag==timeFlagSummer) SetSeason(4);
        if(n_TimeFlag==timeFlagDesert) SetSeason(5);
        if(n_TimeFlag==timeFlagVolcano) SetSeason(6);
        if(n_TimeFlag==timeFlagHeavyVolcano) SetSeason(7);
        
        EnableChooseMissionButton(true);
    }
}

//************************************


