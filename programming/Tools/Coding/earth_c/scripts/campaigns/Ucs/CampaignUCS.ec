campaign "translateCampaignUCS"
{
    consts
    {
        raceUCS=1;
        raceED=2;
        raceLC=3;
        
        
        mis111 = 0;
        mis112 = 1;
        mis113 = 2;
        mis114 = 3;
        mis121 = 4;
        mis122 = 5;
        mis123 = 6;
        mis124 = 7;
        mis131 = 8;
        mis132 = 9;
        mis133 = 10;
        mis134 = 11;
        mis141 = 12;
        mis142 = 13;
        mis143 = 14;
        mis144 = 15;
        mis151 = 16;
        mis152 = 17;
        mis153 = 18;
        mis165 = 19;
        mis171 = 20;
        mis172 = 21;
        
        baseUCS = 22;
        baseED = 23;
        baseLC = 24;
        
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
        
        RegisterMission(baseUCS,"!baseUCS","UCS\\Missions\\UCSbaseUCSscript","", baseFlag,                  -84, 41,0,0,0);
        RegisterMission(baseED,"!baseED","UCS\\Missions\\UCSbaseEDscript","",        baseFlag,                   50, 60,0,0,0);
        RegisterMission(baseLC,"!baseLC","UCS\\Missions\\UCSbaseLCscript","",        baseFlag,                  120,  8,0,0,0);
        
        //                   nr       lnd        script                    preBriefing                 timeFlags          x  y   d1  d2  d3  next1 next2 next3 next4              
        RegisterMission(mis111, "!111", "UCS\\Missions\\Mission111", "translateBriefingShort111", timeFlagWinter,        60, 60, 60, 60, 60, mis112,mis113);
        RegisterMission(mis112, "!112", "UCS\\Missions\\Mission112", "translateBriefingShort112", timeFlagWinter,        60, 78, 90, 90, 90, mis114,mis121);
        RegisterMission(mis113, "!113", "UCS\\Missions\\Mission113", "translateBriefingShort113", timeFlagWinter,    -100, 40, 90, 90, 90, mis122);
        RegisterMission(mis114, "!114", "UCS\\Missions\\Mission114", "translateBriefingShort114", timeFlagWinter,       120, 85,120,120,120);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------      
        RegisterMission(mis121, "!121", "UCS\\Missions\\Mission121", "translateBriefingShort121", timeFlagEarlySpring, 105, 52,0,0,0, mis131);
        RegisterMission(mis122, "!122", "UCS\\Missions\\Mission122", "translateBriefingShort122", timeFlagEarlySpring,-100, 40,0,0,0, mis134,mis123);
        RegisterMission(mis123, "!123", "UCS\\Missions\\Mission123", "translateBriefingShort123", timeFlagEarlySpring,-150, 65,0,0,0, mis124);
        RegisterMission(mis124, "!124", "UCS\\Missions\\Mission124", "translateBriefingShort124", timeFlagEarlySpring, 140, 40,0,0,0, mis132,mis133);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis131, "!131", "UCS\\Missions\\Mission131", "translateBriefingShort131", timeFlagSpring,       -90, 42,0,0,0, mis142);
        RegisterMission(mis132, "!132", "UCS\\Missions\\Mission132", "translateBriefingShort132", timeFlagSpring,        90, 35,0,0,0);
        RegisterMission(mis133, "!133", "UCS\\Missions\\Mission133", "translateBriefingShort133", timeFlagSpring,       -74, 41,0,0,0);
        RegisterMission(mis134, "!134", "UCS\\Missions\\Mission134", "translateBriefingShort134", timeFlagSpring,    -100, 40,0,0,0);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis141, "!141", "UCS\\Missions\\Mission141", "translateBriefingShort141", timeFlagSummer,        47,-18,0,0,0, mis152);
        RegisterMission(mis142, "!142", "UCS\\Missions\\Mission142", "translateBriefingShort142", timeFlagSummer,        77, 15,0,0,0, mis141,mis143,mis144);
        RegisterMission(mis143, "!143", "UCS\\Missions\\Mission143", "translateBriefingShort143", timeFlagSummer,        47,-18,0,0,0, mis153);
        RegisterMission(mis144, "!144", "UCS\\Missions\\Mission144", "translateBriefingShort144", timeFlagSummer,       133,-13,0,0,0, mis153);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis151, "!151", "UCS\\Missions\\Mission151", "translateBriefingShort151", timeFlagDesert,        35,-15,0,0,0, mis165);
        RegisterMission(mis152, "!152", "UCS\\Missions\\Mission152", "translateBriefingShort152", timeFlagDesert,       135,-25,0,0,0, mis151);
        RegisterMission(mis153, "!153", "UCS\\Missions\\Mission153", "translateBriefingShort153", timeFlagDesert,        31, 30,0,0,0, mis151);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------      
        RegisterMission(mis165, "!165", "UCS\\Missions\\Mission165", "translateBriefingShort165", timeFlagVolcano,      -75, -5,0,0,0, mis171,mis172);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis171, "!171", "UCS\\Missions\\Mission171", "translateBriefingShort171", timeFlagHeavyVolcano,-72,  3,0,0,0);
        RegisterMission(mis172, "!172", "UCS\\Missions\\Mission172", "translateBriefingShort172", timeFlagHeavyVolcano,-70,-30,0,0,0);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------      
        
        n_CashCounter = timeFlagEarlySpring;
        n_TimeFlag = timeFlagWinter;
        b_showVideo = true;
        b_showVideo2 = false;
        
        CreateGamePlayer(1,raceUCS,playerLocal,null);
        CreateGamePlayer(2,raceED,playerAI,null);
        CreateGamePlayer(3,raceLC,playerAI,null);
        
        LoadBase(1,baseUCS,1);
        LoadBase(2,baseED,2);
        LoadBase(3,baseLC,3);
        
        SetActivePlayerAndWorld(1,1);//player, world
        SetAvailableWorlds(1|2);//misja i baza UCS(swiat nr 1)
        
        EnableMission(mis111,true);
        ActivateMissions(timeFlagWinter,true);
        SetSeason(1);
        
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
                ShowVideo("CS114");
            
            if(n_TimeFlag == timeFlagSpring)
                ShowVideo("CS115");
            
            if(n_TimeFlag == timeFlagDesert)
                ShowVideo("CS116");
            
            if(n_TimeFlag == timeFlagVolcano)
                ShowVideo("CS117");
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
        if(bEnable==3)//enable LC base
            SetAvailableWorlds(GetAvailableWorlds()|8);
        if(bEnable==4)//you have win the game
        {
            EndGame("Video\\OutroUCS.wd1");
        }
        if(bEnable==5)//you loose the game
        {
            EndGame("Video\\OutroLost.wd1");
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


