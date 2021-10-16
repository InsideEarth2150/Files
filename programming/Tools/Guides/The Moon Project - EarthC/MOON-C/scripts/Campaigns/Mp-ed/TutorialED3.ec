campaign "translateCampaignTutorialED3"
{
    consts
    {
        raceUCS=1;
        raceED=2;        
        raceLC=3;

        mis1 = 0;
        
        base1 = 1;
        base2 = 2;
        base3 = 3;
        
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
    
    state Initialize
    {
        int i;

        RegisterMission(base1,"!TutorialEDBase1","ED\\Missions\\TutorialED3base1","", baseFlag, 0, 90,10,10,10);
        RegisterMission(base2,"!TutorialEDBase2","ED\\Missions\\TutorialED3base2","", baseFlag,   0,-90,10,10,10);
        RegisterMission(base3,"!TutorialEDBase2","ED\\Missions\\TutorialED3base2","", baseFlag,   0,-90,10,10,10);

        //                nr       lnd        script                    preBriefing              timeFlags  x  y   d1  d2  d3  next1 next2 next3 next4
        RegisterMission(mis1, "!TutorialED3", "ED\\Missions\\TutorialED3mis", "translateBriefingShortTutorialED3", timeFlagWinter,      90,  65, 1, 1, 1);
            
        CreateGamePlayer(1, raceUCS, playerAI, null);
        CreateGamePlayer(2, raceED,  playerLocal, null);
        CreateGamePlayer(3, raceLC,  playerAI, null);
        
        LoadBase(1,base1,2);
        LoadBase(2,base2,1);
        LoadBase(3,base3,3);
        
        SetActivePlayerAndWorld(2,1);//player, world
        SetAvailableWorlds(1|2);//misja i baza ED

        EnableMission(mis1,true);
                
        SetSeason(3);
        n_TimeFlag = timeFlagWinter;
        ActivateMissions(timeFlagWinter,true);
        EnableChooseMissionButton(false);
        return Start,100;//10sek
    }
    //-----------------------------------------------------------------------------------------
    state Start
    {
        
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
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
        EnableChooseMissionButton(true);
    }
    //-----------------------------------------------------------------------------------------
    event EndMission(int iMission, int nResult) // 
    {
    }
}

//************************************
