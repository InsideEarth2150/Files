campaign "translateCampaignED"
{
    consts
    {
        raceUCS=1;
        raceED=2;
        raceLC=3;
        
        mis211 = 0;
        mis212 = 1;
        mis213 = 2;
        mis214 = 3;
        mis215 = 4;
        mis221 = 5;
        mis222 = 6;
        mis223 = 7;
        mis224 = 8;
        mis231 = 9;
        mis232 = 10;
        mis233 = 11;
        mis234 = 12;
        mis235 = 13;
        mis241 = 14;
        mis242 = 15;
        mis243 = 16;
        mis244 = 17;
        mis251 = 18;
        mis252 = 19;
        mis253 = 20;
        mis254 = 21;
        mis261 = 22;
        mis262 = 23;
        mis263 = 24;
        mis264 = 25;
        mis265 = 26;
        mis271 = 27;
        mis272 = 28;
        mis273 = 29;
        
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
        
        // pieniadze przewidywane do budowy statku na poczatku okresu
        /*cashEarlySpring = 50000; 
        cashSpring = 100000;
        cashSummer = 150000;
        cashDesert = 200000;
        cashVolcano = 250000;
        spaceShipPrice = 300000;
        */
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
        RegisterMission(baseED,"!baseED","ED\\Missions\\baseEDscript","",        baseFlag,                      50, 60,0,0,0);
        RegisterMission(baseLC,"!baseLC","ED\\Missions\\baseLCscript","",        baseFlag,                   120,  8,0,0,0);
        //                   nr       lnd        script                    preBriefing                 timeFlags          x  y   d1  d2  d3  next1 next2 next3 next4              
        RegisterMission(mis211, "!211", "ED\\Missions\\Mission211", "translateBriefingShort211", timeFlagWinter,           60, 60, 60, 60, 60, mis212,mis213);
        RegisterMission(mis212, "!212", "ED\\Missions\\Mission212", "translateBriefingShort212", timeFlagWinter,           60, 78, 90, 90, 90, mis215,mis214);
        RegisterMission(mis213, "!213", "ED\\Missions\\Mission213", "translateBriefingShort213", timeFlagWinter,           90, 35, 90, 90, 90);
        RegisterMission(mis214, "!214", "ED\\Missions\\Mission214", "translateBriefingShort214", timeFlagWinter,          120, 85,120,120,120);
        RegisterMission(mis215, "!215", "ED\\Missions\\Mission215", "translateBriefingShort215", timeFlagWinter,          161, 60, 90, 90, 90, mis221,mis223,mis224);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis221, "!221", "ED\\Missions\\Mission221", "translateBriefingShort221", timeFlagEarlySpring, 105, 52, 90, 90, 90, mis223,mis224);
        RegisterMission(mis222, "!222", "ED\\Missions\\Mission222", "translateBriefingShort222", timeFlagEarlySpring,-115, 65,300,300,300, mis231,mis233);
        RegisterMission(mis223, "!223", "ED\\Missions\\Mission223", "translateBriefingShort223", timeFlagEarlySpring,-150, 65,250,250,250, mis222);
        RegisterMission(mis224, "!224", "ED\\Missions\\Mission224", "translateBriefingShort224", timeFlagEarlySpring,   140, 40,150,150,150, mis232,mis234);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------    
        RegisterMission(mis231, "!231", "ED\\Missions\\Mission231", "translateBriefingShort231", timeFlagSpring,          -90, 42,300,300,300, mis232,mis235);
        RegisterMission(mis232, "!232", "ED\\Missions\\Mission232", "translateBriefingShort232", timeFlagSpring,          122, 11,150,150,150, mis241,mis242,mis243);
        RegisterMission(mis233, "!233", "ED\\Missions\\Mission233", "translateBriefingShort233", timeFlagSpring,          -74, 41,300,300,300, baseUCS);
        RegisterMission(mis234, "!234", "ED\\Missions\\Mission234", "translateBriefingShort234", timeFlagSpring,          -52, -2,360,360,360, mis241,mis242,mis243);
        RegisterMission(mis235, "!235", "ED\\Missions\\Mission235", "translateBriefingShort235", timeFlagSpring,         -110, 40,360,360,360);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis241, "!241", "ED\\Missions\\Mission241", "translateBriefingShort241", timeFlagSummer,          -80,  9,330,330,330);
        RegisterMission(mis242, "!242", "ED\\Missions\\Mission242", "translateBriefingShort242", timeFlagSummer,           77, 15, 90, 90, 90);
        RegisterMission(mis243, "!243", "ED\\Missions\\Mission243", "translateBriefingShort243", timeFlagSummer,           47,-18,250,250,250, mis244);
        RegisterMission(mis244, "!244", "ED\\Missions\\Mission244", "translateBriefingShort244", timeFlagSummer,          133,-13,300,300,300, mis251,mis252);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis251, "!251", "ED\\Missions\\Mission251", "translateBriefingShort251", timeFlagDesert,           35,-15,250,250,250, mis253);
        RegisterMission(mis252, "!252", "ED\\Missions\\Mission252", "translateBriefingShort252", timeFlagDesert,          135,-25,300,300,300, mis254);
        RegisterMission(mis253, "!253", "ED\\Missions\\Mission253", "translateBriefingShort253", timeFlagDesert,           31, 27,100,100,100, mis261,mis262,mis263);
        RegisterMission(mis254, "!254", "ED\\Missions\\Mission254", "translateBriefingShort254", timeFlagDesert,          166,-45,300,300,300, mis264,mis265);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis261, "!261", "ED\\Missions\\Mission261", "translateBriefingShort261", timeFlagVolcano,            13, -3,250,250,250);
        RegisterMission(mis262, "!262", "ED\\Missions\\Mission262", "translateBriefingShort262", timeFlagVolcano,            26,-27,260,260,260);
        RegisterMission(mis263, "!263", "ED\\Missions\\Mission263", "translateBriefingShort263", timeFlagVolcano,           -15, 20,250,250,250, mis271,mis272,mis273);
        RegisterMission(mis264, "!264", "ED\\Missions\\Mission264", "translateBriefingShort264", timeFlagVolcano,           -72,  3,150,150,150);
        RegisterMission(mis265, "!265", "ED\\Missions\\Mission265", "translateBriefingShort265", timeFlagVolcano,           -75, -5,150,150,150, mis271,mis272,mis273);
        //----------------------------------------------------------------------------------------------------------------------------------------------------------------
        RegisterMission(mis271, "!271", "ED\\Missions\\Mission271", "translateBriefingShort271", timeFlagHeavyVolcano,-70, -5,360,360,360);
        RegisterMission(mis272, "!272", "ED\\Missions\\Mission272", "translateBriefingShort272", timeFlagHeavyVolcano,-70,-30,360,360,360);
        RegisterMission(mis273, "!273", "ED\\Missions\\Mission273", "translateBriefingShort273", timeFlagHeavyVolcano,-77, -8,360,360,360);
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
            
            if(n_TimeFlag == timeFlagSpring)
                ShowVideo("CS215");
            
            if(n_TimeFlag == timeFlagDesert)
                ShowVideo("CS216");
            
            if(n_TimeFlag == timeFlagVolcano)
                ShowVideo("CS217");
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
        {
            EnableMission(GetNextMission(iMission,iNextNr),bEnable);
            //      SetMissionState(iMission,stateSkiped);
        }
        if(bEnable==2)//enable UCS base
            SetAvailableWorlds(GetAvailableWorlds()|2);
        if(bEnable==3)//enable LC base
            SetAvailableWorlds(GetAvailableWorlds()|8);
        if(bEnable==4)//you have win the game
        {
            EndGame("Video\\OutroED.wd1");
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
    
    /*event EndMission(int iMission, int nResult) // old campaign structure
    {
    int nTime;
    int nNewTimeFlag;
    nTime = GetCampaignTime();
    //SetMissionState(nr,stan); stateAccomplished, stateFailed, stateSkiped
    if(nResult==true)
    SetMissionState(iMission,stateAccomplished);
    else
    SetMissionState(iMission,stateFailed);
    
      nNewTimeFlag = timeFlagWinter;
      if(nTime > timeEarlySpring)  
      nNewTimeFlag = timeFlagEarlySpring;
      if(nTime > timeSpring) 
      nNewTimeFlag = timeFlagSpring;
      if(nTime > timeSummer) 
      nNewTimeFlag = timeFlagSummer;
      if(nTime>timeDesert) 
      nNewTimeFlag = timeFlagDesert;
      if(nTime>timeVolcano) 
      nNewTimeFlag = timeFlagVolcano;
      if(nTime>timeHeavyVolcano) 
      nNewTimeFlag = timeFlagHeavyVolcano;
      
        
          if(nNewTimeFlag != n_TimeFlag) //zmiana czasu
          {
          nNewTimeFlag = n_TimeFlag*2;
          if(AreMissionsEnabledEq(nNewTimeFlag,nNewTimeFlag))
          {
          EnableMissionsEq(n_TimeFlag,n_TimeFlag,false);
          n_TimeFlag = nNewTimeFlag;  //
          b_showVideo = true;
          }
          }
          else
          {
          if(!AreMissionsEnabledEq(n_TimeFlag,n_TimeFlag))
          {
          n_TimeFlag = n_TimeFlag*2;
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
    }*/
}

//************************************


