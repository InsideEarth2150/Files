campaign "translateCampaignLCMP01"
{
    consts
    {
        raceUCS=1;
        raceLC=3;        

        mis611 = 0;
        mis612 = 1;
        mis613 = 2;
        mis614 = 3;
        mis615 = 4;
        mis616 = 5;
        mis617 = 6;
        mis618 = 7;
        mis619 = 8;
        mis620 = 9;
        mis621 = 10;
        mis622 = 11;
        
        base1 = 20;
        base2 = 21;
        base3 = 22;
        
        timeFlagWinter = 1;
        baseFlag = 255 ;
    }

   
    state Initialize;
    state Start;
    state Nothing;
    
    state Initialize
    {
        int i;

        RegisterMission(base1,"!LCbase1","LC\\Missions\\LCbase1Script","", baseFlag, 0,-90,0,0,0);
        RegisterMission(base2,"!LCbase2","LC\\Missions\\LCbase2Script","", baseFlag, 0, 90,0,0,0);
        RegisterMission(base3,"!LCbase3","LC\\Missions\\LCbase3Script","", baseFlag, 0, 90,0,0,0);

        //                nr       lnd        script                    preBriefing              timeFlags  x  y   d1  d2  d3  next1 next2 next3 next4
        RegisterMission(mis611, "!611", "LC\\Missions\\Mission611", "translateBriefingShort611", timeFlagWinter, -170,  80, 60, 60, 60, mis621,mis622);
        RegisterMission(mis612, "!612", "LC\\Missions\\Mission612", "translateBriefingShort612", timeFlagWinter,   20,  40, 60, 60, 60, mis614);
        RegisterMission(mis613, "!613", "LC\\Missions\\Mission613", "translateBriefingShort613", timeFlagWinter,   44,   0, 20, 20, 20, mis615);
        RegisterMission(mis614, "!614", "LC\\Missions\\Mission614", "translateBriefingShort614", timeFlagWinter,  160,  20, 20, 20, 20, mis616);
        RegisterMission(mis615, "!615", "LC\\Missions\\Mission615", "translateBriefingShort615", timeFlagWinter,  136,   0, 20, 20, 20, mis617);
        RegisterMission(mis616, "!616", "LC\\Missions\\Mission616", "translateBriefingShort616", timeFlagWinter, -125, -10, 20, 20, 20, mis618);
        RegisterMission(mis617, "!617", "LC\\Missions\\Mission617", "translateBriefingShort617", timeFlagWinter,  224,   0, 20, 20, 20, mis619);
        RegisterMission(mis618, "!618", "LC\\Missions\\Mission618", "translateBriefingShort618", timeFlagWinter,  -50,  10, 20, 20, 20, mis620);
        RegisterMission(mis619, "!619", "LC\\Missions\\Mission619", "translateBriefingShort619", timeFlagWinter,  316,   0, 20, 20, 20, mis620);
        RegisterMission(mis620, "!620", "LC\\Missions\\Mission620", "translateBriefingShort620", timeFlagWinter,    0,  90, 20, 20, 20);
        RegisterMission(mis621, "!621", "LC\\Missions\\Mission621", "translateBriefingShort621", timeFlagWinter,    0,  70, 20, 20, 20, mis612);
        RegisterMission(mis622, "!622", "LC\\Missions\\Mission622", "translateBriefingShort622", timeFlagWinter,  130,  50, 20, 20, 20, mis613);

        CreateGamePlayer(1, raceUCS, playerAI, null);
        CreateGamePlayer(3, raceLC, playerLocal, null);

        
        LoadBase(1,base3,3);
        LoadBase(2,base2,1);
        LoadBase(3,base1,1);
        
        
        SetActivePlayerAndWorld(3,1);//player, world
        SetAvailableWorlds(2);//baza LC(swiat nr 1)

        EnableMission(mis611,true);
                
        SetSeason(8);

        ActivateMissions(timeFlagWinter,true);
        
        return Start,10;
    }
    //-----------------------------------------------------------------------------------------
    state Start
    {
        SetAvailableWorlds(1|2|4|8);//misja i baza LC(swiat nr 3)
        EnableChooseMissionButton(true);
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
            
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
            //if(iMission==mis613)return;//XXX DEMO
        if(bEnable<2)
            EnableMission(GetNextMission(iMission,iNextNr),bEnable);

        //---gra przegarana - jakis odpowiedni filmik---
        if(bEnable==2)
            EndGame("Video\\Cutscene5.wd1");

                //---gra wygrana - jakis odpowiedni filmik----
        if(bEnable==3)
            EndGame("Video\\Cutscene6.wd1");
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

        EnableChooseMissionButton(true);
    }
}

//************************************
