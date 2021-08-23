mission "translateMissionBaseLC"
{
    consts
    {
        oneSeasonMoney =  25000;//CR
        oneSeasonTime =  150000;//clk = 1h 20min tak naprawde to odpowiada to polowce sezonu
        noOfSeasons = 20;    
        fleetCost =      500000;
        firstPhaseCost = 50000;
        phaseCost = 100000;
        clicksPerDay = 16383;
    }
    
    player pPlayer;
    
    int nReport;
    int EndGameResult;
    int bMissionsFinished;
    
    state Initialize;
    state ShowBriefing1;
    state ShowBriefing2;
    state ShowStartFirstMissionBriefing;
    state Nothing;
    state EndGameState;
    
    state Initialize
    {
        unitex uHero;
        //----------- Goals ------------------
        RegisterGoal(0,"translateGoalLCSendMoneyToSpace",fleetCost,0);
        RegisterGoal(1,"translateGoalLCCampaignPhase1");
        RegisterGoal(2,"translateGoalLCCampaignPhase2");
        RegisterGoal(3,"translateGoalLCCampaignPhase3");
        RegisterGoal(4,"translateGoalLCCampaignPhase4");
        RegisterGoal(5,"translateGoalLCCampaignPhase5");
        EnableGoal(0,true);
        EnableGoal(1,true);
        EnableGoal(2,true);
        EnableGoal(3,true);
        EnableGoal(4,true);
        EnableGoal(5,true);
        //----------- Temporary players ------
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        //----------- AI ---------------------
        pPlayer.SetScriptData(0,fleetCost);
        pPlayer.SetMilitaryUnitsLimit(10000);
        //----------- Money ------------------
        pPlayer.SetMoney(5000);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WCH2",false);
        pPlayer.EnableResearch("RES_LC_ACH2",false);
        pPlayer.EnableResearch("RES_LC_WSR2",false);
        pPlayer.EnableResearch("RES_LC_ASR1",false);
        pPlayer.EnableResearch("RES_LC_WMR1",false);
        pPlayer.EnableResearch("RES_LC_AMR1",false);
        pPlayer.EnableResearch("RES_LC_WSL1",false);
        pPlayer.EnableResearch("RES_LC_WHL1",false);
        pPlayer.EnableResearch("RES_LC_WSS1",false);
        pPlayer.EnableResearch("RES_LC_WHS1",false);
        pPlayer.EnableResearch("RES_LC_WAS1",false);
        pPlayer.EnableResearch("RES_LC_WARTILLERY",false);
        //CHASS
        pPlayer.EnableResearch("RES_LC_UMO2",false);
        pPlayer.EnableResearch("RES_LC_UCR1",false);
        pPlayer.EnableResearch("RES_LC_UCU1",false);
        pPlayer.EnableResearch("RES_LC_UME1",false);
        pPlayer.EnableResearch("RES_LC_UBO1",false);
        //SPECIAL
        pPlayer.EnableResearch("RES_LC_BMD",false);
        pPlayer.EnableResearch("RES_LC_BHD",false);
        pPlayer.EnableResearch("RES_LC_BWC",false);
        pPlayer.EnableResearch("RES_LC_SDIDEF",false);
        pPlayer.EnableResearch("RES_LC_SGen",false);
        pPlayer.EnableResearch("RES_LC_MGen",false);
        pPlayer.EnableResearch("RES_LC_HGen",false);
        pPlayer.EnableResearch("RES_LC_SHR1",false);
        pPlayer.EnableResearch("RES_LC_REG1",false);
        pPlayer.EnableResearch("RES_LC_SOB1",false);
        //AMMO
        pPlayer.EnableResearch("RES_MCH2",false);
        pPlayer.EnableResearch("RES_MSR2",false);
        pPlayer.EnableResearch("RES_MSR3",false);
        pPlayer.EnableResearch("RES_MSR4",false);
        pPlayer.EnableResearch("RES_MMR2",false);
        pPlayer.EnableResearch("RES_MMR3",false);
        pPlayer.EnableResearch("RES_MMR4",false);
        //----------- Buildings --------------
        pPlayer.EnableBuilding("LCBSR",false);
        pPlayer.EnableBuilding("LCLASERWALL",false);
        //----------- Units ------------------
        uHero = GetUnit(GetPointX(0),GetPointY(0),0);
        pPlayer.SetScriptUnit(0,uHero);
        uHero.CommandMove(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),0);
        CallCamera();
        SelectUnit(uHero,false);                            
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,oneSeasonTime);
        //----------- Variables --------------
        nReport = 0;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing1,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing1
    {
        nReport = 0;
        AddBriefing("translateStartCampaignLC1",pPlayer.GetName());
        Snow(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),30,400,8000,800,5); 
        return ShowBriefing2,500;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing2
    {
        AddBriefing("translateStartCampaignLC2",pPlayer.GetName(),fleetCost);
        return ShowStartFirstMissionBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowStartFirstMissionBriefing
    {
        AddBriefing("translateStartFirstMission");
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------
    state HeroKilled
    {
        ShowVideo("CSKilled");
        return EndGameState,3;
    }
    //-----------------------------------------------------------------------------------------     
    state Nothing
    {
        unitex uHero;
        int nSendedMoney;
        int nRemTime;
        int i;
        nSendedMoney = pPlayer.GetMoneySentToOrbit();
        
        RegisterGoal(0,"translateGoalLCSendMoneyToSpace",fleetCost,(nSendedMoney*100)/fleetCost);
        RegisterGoal(1,"translateGoalLCCampaignPhase1");
        RegisterGoal(2,"translateGoalLCCampaignPhase2");
        RegisterGoal(3,"translateGoalLCCampaignPhase3");
        RegisterGoal(4,"translateGoalLCCampaignPhase4");
        RegisterGoal(5,"translateGoalLCCampaignPhase5");
        
        for(i=1;i<6;i=i+1)
        {
            if(GetGoalState(i)!=goalAchieved && (nSendedMoney>=((phaseCost*(i-1))+firstPhaseCost)))
            {
                SetGoalState(i,goalAchieved);
            }
        }
        
        if(bMissionsFinished && (nSendedMoney+pPlayer.GetMoney()+pPlayer.GetMoneyFromFinishedMissions())<fleetCost)
        {
            AddBriefing("translateCampaignLCFailed");
            EndGameResult=5;
            return EndGameState,3;
        }
        
        if(nSendedMoney>=fleetCost)
        {
            SetGoalState(0,goalAchieved);
            AddBriefing("translateCampaignLCAccomplished",pPlayer.GetName());
            EndGameResult=4;
            return EndGameState,3;
        }
        SetConsoleText("translateCampaignLCRemainingTime",((oneSeasonTime*noOfSeasons) - GetMissionTime())/clicksPerDay);//XXXMD
        uHero = pPlayer.GetScriptUnit(0);
        if(uHero==null || !uHero.IsLive())
        {
            AddBriefing("translateCampaignLCHeroKilled",pPlayer.GetName());
            EndGameResult=6;
            return HeroKilled,2;
        }
        if(!pPlayer.GetNumberOfBuildings(buildingSpaceStation))
        {
            AddBriefing("translateCampaignLCSpacePortDestroyed",pPlayer.GetName());
            EndGameResult=5;
            return EndGameState,3;
        }
        return Nothing,600;
    }
    //-----------------------------------------------------------------------------------------  
    state EndGameState
    {
        EnableNextMission(0,EndGameResult);
        return EndGameState,600;
    }
    //-----------------------------------------------------------------------------------------  
    event Timer0() //wolany co 200 000 cykli< ustawione funkcja SetTimer w state Initialize
    {
        int nSendedMoney;
        int nProjectStatus;
        int nMoneyForNextSeason;
        int nPrecentDelivered;
        
        nReport = nReport+1;
        
        if(nReport>noOfSeasons)
        {
            AddBriefing("translateCampaignLCFailed",pPlayer.GetName());
            EndGameResult=5;
            return EndGameState;
        }
        
        nSendedMoney = pPlayer.GetMoneySentToOrbit();// to ma tu byc
        nProjectStatus = (nSendedMoney*100)/fleetCost;
        nMoneyForNextSeason = ((nReport+1)*oneSeasonMoney) - nSendedMoney;
        if(nMoneyForNextSeason<10000) nMoneyForNextSeason=10000;
        
        nPrecentDelivered = (nSendedMoney*100)/(oneSeasonMoney*nReport);
        if(nSendedMoney < oneSeasonMoney*nReport)
            AddBriefing("translateLCDelayReport",pPlayer.GetName(),nReport,nProjectStatus,nMoneyForNextSeason,nPrecentDelivered);
        else
            AddBriefing("translateLCReport",pPlayer.GetName(),nReport,nProjectStatus,nMoneyForNextSeason);
    }
    event CustomEvent0(int k1,int k2,int k3,int k4) //XXXMD
    {
        bMissionsFinished=true;
    }
}