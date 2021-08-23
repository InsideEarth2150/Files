campaign "translateCampaignEDMP01"
{
    consts
    {
        raceUCS=1;
        raceED=2;        
        raceLC=3;

        mis511 = 50;
        mis512 = 51;
        mis513 = 52;
        mis514 = 53;
        mis515 = 54;
        mis516 = 55;
        mis517 = 56;
        mis518 = 57;
        mis519 = 58;
        mis520 = 59;
        mis521 = 60;//add by JS to compile
        mis522 = 61;//add by JS to compile
        
        base1 = 65;
        base2 = 66;
        base3 = 67;
        
        timeFlagWinter = 1;
        timeFlagEarlySpring = 2;
        timeFlagSpring = 4;
        timeFlagSummer = 8;
        timeFlagDesert = 16;
        timeFlagVolcano = 32;
        timeFlagHeavyVolcano = 64;
        timeFlagMoon =128;
        baseFlag = 255 ;
    }

    int n_TimeFlag;
   
    state Initialize;
    state Start;
    state Nothing;
    state LoadMission522;
    
    state Initialize
    {
        int i;

        RegisterMission(base1,"!MPEDBase1","ED\\Missions\\EDbase1script","", baseFlag, 0, 90,10,10,10);
        RegisterMission(base2,"!MPEDbase2","ED\\Missions\\EDbase2script","", baseFlag,   0,-90,10,10,10);
        RegisterMission(base3,"!MPEDbase3","ED\\Missions\\EDbase3script","", baseFlag,   0,-90,10,10,10);

        //                nr       lnd        script                    preBriefing              timeFlags  x  y   d1  d2  d3  next1 next2 next3 next4
        RegisterMission(mis511, "!511", "ED\\Missions\\Mission511", "translateBriefingShort511", timeFlagWinter,      90,  65, 10, 10, 10);
        RegisterMission(mis512, "!512", "ED\\Missions\\Mission512", "translateBriefingShort512", timeFlagWinter,      60,  75, 10, 10, 10, mis514,mis513);
        RegisterMission(mis513, "!513", "ED\\Missions\\Mission513", "translateBriefingShort513", timeFlagEarlySpring,105, 45, 10, 10, 10);
        RegisterMission(mis514, "!514", "ED\\Missions\\Mission514", "translateBriefingShort514", timeFlagEarlySpring, 65, 40, 10, 10, 10, mis516,mis515);
        RegisterMission(mis515, "!515", "ED\\Missions\\Mission515", "translateBriefingShort515", timeFlagSpring,      70, 30, 10, 10, 10);
        RegisterMission(mis516, "!516", "ED\\Missions\\Mission516", "translateBriefingShort516", timeFlagSpring,      30, 50, 10, 10, 10, mis517);
        RegisterMission(mis517, "!517", "ED\\Missions\\Mission517", "translateBriefingShort517", timeFlagSummer,      -3, 40, 10, 10, 10, mis519);
        //RegisterMission(mis518, "!518", "ED\\Missions\\Mission518", "translateBriefingShort518", timeFlagSummer,  -50,  10, 10, 10, 10);
        RegisterMission(mis519, "!519", "ED\\Missions\\Mission519", "translateBriefingShort519", timeFlagDesert,      30,   0, 10, 10, 10, mis521);
        //RegisterMission(mis520, "!520", "ED\\Missions\\Mission520", "translateBriefingShort520", timeFlagDesert,    0,  90, 10, 10, 10);
        RegisterMission(mis521, "!521", "ED\\Missions\\Mission521", "translateBriefingShort521", timeFlagVolcano,    -82,  28, 10, 10, 10,mis522);
        RegisterMission(mis522, "!522", "ED\\Missions\\Mission522", "translateBriefingShort522", timeFlagMoon,         0,  90, 10, 10, 10);
            
        CreateGamePlayer(1, raceUCS, playerAI, null);
        CreateGamePlayer(2, raceED,  playerLocal, null);
        CreateGamePlayer(3, raceLC,  playerAI, null);
        
        LoadBase(1,base1,2);
        LoadBase(2,base2,1);
        LoadBase(3,base3,3);
        
        SetActivePlayerAndWorld(2,1);//player, world
        SetAvailableWorlds(1|2|4|8);//misja i 2 bazy ED

        EnableMission(mis511,true);
        EnableMission(mis512,true);
                
        SetSeason(1);
        n_TimeFlag = timeFlagWinter;
        ActivateMissions(timeFlagWinter,true);
        
        return Start,221;//10sek
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
        return Nothing,0;//ma byc 0 zeby szybko wskoczylo do LoadMission522
    }
    //-----------------------------------------------------------------------------------------
    state LoadMission522
    {
        TraceD("Load 522       \n");
        SetSeason(8);
        LoadMission(0,mis522);
        SetAvailableWorlds(1);//only mission
        SendCustomEvent(0,0,0,0,128);
        return Nothing;
    }
    //-----------------------------------------------------------------------------------------
    event StartMission(int iMission)
    {
        EnableChooseMissionButton(false);
        LoadMission(0,iMission);
        EnableMission(iMission,false);
    }

    //-----------------------------------------------------------------------------------------
    event EnableNextMission(int iMission,int iNextNr,int bEnable)
    {
        if(bEnable==2)//game loose -show video SUICIDE
        {
                SetAvailableWorlds(1|2|4|8);
                EndGame("Video\\Cutscene16.wd1");
                return;
        }
        if(bEnable==3)//game win -show video
        {
                SetAvailableWorlds(1|2|4|8);
                EndGame("Video\\Cutscene17.wd1");
                return;
        }
        EnableMission(GetNextMission(iMission,iNextNr),bEnable);
        }

    //-----------------------------------------------------------------------------------------
    event EndingMission(int iMission, int nResult)
    {
        if(iMission==mis521)
        {
            //tak dla pewnosci
            SetAvailableWorlds(1|2|4|8);
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission(int iMission, int nResult) // 
    {
                TraceD("End Mission: ");TraceD(iMission);TraceD("   \n");
                if(iMission==mis521)
                {
                    TraceD("Ready to load 522   \n");
                    ForceKeepBitmapAfterStatistic();//musi byc tutaj a nie przed LoadMission
                    state LoadMission522;
                    return;
                }
                
                if(nResult==true)
                {
            SetMissionState(iMission,stateAccomplished);
                }
        else
                {
                        SetMissionState(iMission,stateFailed);
                }               
            
                if(!AreMissionsEnabledEq(n_TimeFlag,n_TimeFlag))
                {
                    if(n_TimeFlag != timeFlagVolcano)
                    {
                        n_TimeFlag = n_TimeFlag*2;
                    }
                    else
                        n_TimeFlag = timeFlagMoon;
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
                if(n_TimeFlag==timeFlagMoon) SetSeason(8);

                EnableChooseMissionButton(true);
    }
}

//************************************
