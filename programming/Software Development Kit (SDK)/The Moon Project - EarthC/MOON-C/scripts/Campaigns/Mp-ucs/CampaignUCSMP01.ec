campaign "translateCampaignUCSMP01"
{
    consts
    {
        raceUCS=1;
        raceLC=3;   
                
        mis410 = 30;
        mis411 = 31;
        mis412 = 32;
        mis413 = 33;
        mis414 = 34;
        mis415 = 35;
        mis416 = 36;
        mis417 = 37;
        mis418 = 38;
        mis419 = 39;
        mis420 = 40;

        base1 = 45;
        base2 = 46;
                base3 = 47;

        timeFlagWinter = 1;
        baseFlag = 255;
        
    }

    int n_TimeFlag;
    int n_MissionToLoad;


    state Initialize;
    state Start;
    state Nothing;
    state LoadNextMission;
    
    state Initialize
    {
        int i;
        
        RegisterMission(base1,"!UCSbaseUCSMP01","UCS\\Missions\\UCSbase1script","", baseFlag,  0,-90,0,0,0);
        RegisterMission(base2, "!UCSbaseLCMP01","UCS\\Missions\\UCSbase2script","", baseFlag,  0, 90,0,0,0);
                RegisterMission(base3, "!UCSbaseLCMP01","UCS\\Missions\\UCSbase3script","", baseFlag,  0, 90,0,0,0);
        //              nr       lnd        script                    preBriefing                 timeFlags          x  y   d1  d2  d3  next1 next2 next3 next4
                RegisterMission(mis410, "!410", "UCS\\Missions\\Mission410", "translateBriefingShort410", timeFlagWinter,    10,-80,  60, 60, 60, mis412);          
                RegisterMission(mis411, "!411", "UCS\\Missions\\Mission411", "translateBriefingShort411", timeFlagWinter,    10,-80,  60, 60, 60, mis412);
                RegisterMission(mis412, "!412", "UCS\\Missions\\Mission412", "translateBriefingShort412", timeFlagWinter,    30,-70,  60, 60, 60, mis413);
                RegisterMission(mis413, "!413", "UCS\\Missions\\Mission413", "translateBriefingShort413", timeFlagWinter,    44, 0,   60, 60, 60, mis414,mis415);

                RegisterMission(mis414, "!414", "UCS\\Missions\\Mission414", "translateBriefingShort414", timeFlagWinter,   113,-45,  90, 90, 90);
                RegisterMission(mis415, "!415", "UCS\\Missions\\Mission415", "translateBriefingShort415", timeFlagWinter,   136,  0, 120,120,120, mis416);

                RegisterMission(mis416, "!416", "UCS\\Missions\\Mission416", "translateBriefingShort416", timeFlagWinter,   203,-45,  90, 90, 90, mis417);
                RegisterMission(mis417, "!417", "UCS\\Missions\\Mission417", "translateBriefingShort417", timeFlagWinter,   224,  0, 120,120,120, mis418);

                RegisterMission(mis418, "!418", "UCS\\Missions\\Mission418", "translateBriefingShort418", timeFlagWinter,   316,-15,  90, 90, 90, mis419);
                RegisterMission(mis419, "!419", "UCS\\Missions\\Mission419", "translateBriefingShort419", timeFlagWinter,   316,  0, 120,120,120, mis420);
                RegisterMission(mis420, "!420", "UCS\\Missions\\Mission420", "translateBriefingShort420", timeFlagWinter,     0, 90, 240,240,240);

        n_TimeFlag = timeFlagWinter;

        CreateGamePlayer(1,raceUCS,playerLocal,null);
        CreateGamePlayer(3,raceLC,playerAI,null);

        ForceKeepLoadProgress(4);
        LoadBase(1,base1,1);
        LoadBase(2,base2,3);//// ????? dwa razy 3
        LoadBase(3,base3,3);//// ????? dwa razy 3
        ForceCloseLoadProgress();
        LoadMission(0,mis410);

        SetActivePlayerAndWorld(1,0);//player, world
        SetAvailableWorlds(1);//misja i baza UCS(swiat nr 1)
                EnableMission(mis413,true);
        ActivateMissions(timeFlagWinter,true);
        SetSeason(8);
                return Start,10;
    }
    //-----------------------------------------------------------------------------------------
    state Start
    {
        //EnableChooseMissionButton(true);
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
            return Nothing, 0;      
    }
    //-----------------------------------------------------------------------------------------
    state LoadNextMission
    {
        LoadMission(0, n_MissionToLoad);
        SetAvailableWorlds(1);
        return Nothing;
    }
    //-----------------------------------------------------------------------------------------
    event StartMission(int iMission)
    {
            EnableChooseMissionButton(false);
            TraceD(iMission);
            LoadMission(0,iMission);
            EnableMission(iMission,false);
    }

    //-----------------------------------------------------------------------------------------
    event EnableNextMission(int iMission,int iNextNr,int bEnable)
    {
            //if(iMission==mis413)return;//XXX DEMO
        if(bEnable<2)
                    EnableMission(GetNextMission(iMission,iNextNr),bEnable);

        if(bEnable==2)//failed
            EndGame("Video\\Cutscene6.wd1");//video failed
        if(bEnable==3)//victory
            EndGame("Video\\Cutscene5.wd1");//video victory

    }

    //-----------------------------------------------------------------------------------------
    event EndingMission(int iMission, int nResult)
    {
            if(iMission==mis410||iMission==mis411||iMission==mis412)
        {
            SetAvailableWorlds(1|2);
        }
                if(iMission==mis412)
                {
                    SendCustomEvent(0,1,0,0,0);//enable show briefing in Moon Base
                }
        }
    //-----------------------------------------------------------------------------------------
    event EndMission(int iMission, int nResult) // 
    {
        if(nResult==true)
                {
            SetMissionState(iMission,stateAccomplished);
                }
        else
                {
                        SetMissionState(iMission,stateFailed);
                }               

                if(iMission==mis410)
        {
            n_MissionToLoad = mis411;
            ForceKeepBitmapAfterStatistic();//musi byc tutaj a nie przed LoadMission
            state LoadNextMission;
        }
                else if(iMission==mis411)
        {
            n_MissionToLoad = mis412;
            ForceKeepBitmapAfterStatistic();//musi byc tutaj a nie przed LoadMission
            state LoadNextMission;
        }
                else
                    EnableChooseMissionButton(true);
    }
}

//************************************
