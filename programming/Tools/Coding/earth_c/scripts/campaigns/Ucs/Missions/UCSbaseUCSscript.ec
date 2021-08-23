mission "translateMissionUCSBaseUCS"
{
    consts
    {
        oneSeasonMoney =  50000;//CR
        oneSeasonTime =  150000;//clk = 2h 5min tak naprawde to odpowiada to polowce sezonu
        noOfSeasons = 20;    
        fleetCost =      1000000;
        firstPhaseCost = 100000;
        phaseCost = 200000;
        clicksPerDay = 16383;
    }
    player p_Player;
    int nReport;
    int bMissionsFinished;
    int EndGameResult;
    
    state Initialize;
    state ShowBriefing;
    state ShowStartFirstMissionBriefing;
    state Nothing;
    state EndGameState;
    
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(0,"translateGoalUCSSendMoneyToSpace",fleetCost,0);
        RegisterGoal(1,"translateGoalUCSCampaignPhase1");
        RegisterGoal(2,"translateGoalUCSCampaignPhase2");
        RegisterGoal(3,"translateGoalUCSCampaignPhase3");
        RegisterGoal(4,"translateGoalUCSCampaignPhase4");
        RegisterGoal(5,"translateGoalUCSCampaignPhase5");
        EnableGoal(0,true);
        EnableGoal(1,true);
        EnableGoal(2,true);
        EnableGoal(3,true);
        EnableGoal(4,true);
        EnableGoal(5,true);
        //----------- Temporary players ------
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        //----------- AI ---------------------
        p_Player.SetScriptData(0,fleetCost);
        p_Player.SetMilitaryUnitsLimit(10000);
        //----------- Money ------------------
        p_Player.SetMoney(5000);
        //----------- Researches -------------
        p_Player.EnableResearch("RES_UCS_WCH2",false);
        p_Player.EnableResearch("RES_UCS_WACH2",false);
        p_Player.EnableResearch("RES_UCS_WSG2",false);
        p_Player.EnableResearch("RES_UCS_WHG1",false);
        p_Player.EnableResearch("RES_UCS_WSR1",false);
        p_Player.EnableResearch("RES_UCS_WASR1",false);
        p_Player.EnableResearch("RES_UCS_WSP1",false);
        p_Player.EnableResearch("RES_UCS_WMR1",false);
        p_Player.EnableResearch("RES_UCS_WAMR1",false);
        p_Player.EnableResearch("RES_UCS_WHP1",false);
        p_Player.EnableResearch("RES_UCS_WAPB1",false);
        p_Player.EnableResearch("RES_UCS_WSD",false);
        p_Player.EnableResearch("RES_UCS_PC",false);
        
        p_Player.EnableResearch("RES_MCH2",false);
        p_Player.EnableResearch("RES_MSR2",false);
        p_Player.EnableResearch("RES_MMR2",false);
        p_Player.EnableResearch("RES_UCS_MB2",false);
        p_Player.EnableResearch("RES_UCS_MG2",false);
        
        p_Player.EnableResearch("RES_UCS_USL2",false);
        p_Player.EnableResearch("RES_UCS_USL3",false);
        p_Player.EnableResearch("RES_UCS_UML1",false);
        p_Player.EnableResearch("RES_UCS_UHL1",false);
        p_Player.EnableResearch("RES_UCS_UBL1",false);
        p_Player.EnableResearch("RES_UCS_UMI1",false);
        p_Player.EnableResearch("RES_UCS_UOH2",false);
        p_Player.EnableResearch("RES_UCS_UOH3",false);
        p_Player.EnableResearch("RES_UCS_USS2",false);
        p_Player.EnableResearch("RES_UCS_UBS1",false);
        p_Player.EnableResearch("RES_UCS_UAH1",false);
        p_Player.EnableResearch("RES_UCS_UAH2",false);
        p_Player.EnableResearch("RES_UCS_UAH3",false);
        p_Player.EnableResearch("RES_UCS_GARG1",false);
        p_Player.EnableResearch("RES_UCS_BOMBER21",false);
        p_Player.EnableResearch("RES_UCS_BOMBER31",false);
        
        p_Player.EnableResearch("RES_UCS_BMD",false);
        p_Player.EnableResearch("RES_UCS_BHD",false);
        p_Player.EnableResearch("RES_UCS_RepHand",false);
        p_Player.EnableResearch("RES_UCS_RepHand2",false);
        p_Player.EnableResearch("RES_UCS_SGen",false);
        p_Player.EnableResearch("RES_UCS_SHD",false);
        
        //----------- Buildings --------------
        p_Player.EnableBuilding("UCSBEN1",false);
        p_Player.EnableBuilding("UCSBTE",false);
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,oneSeasonTime);
        //----------- Variables --------------
        nReport = 0;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        nReport = 0;
        AddBriefing("translateStartCampaignUCS",fleetCost,p_Player.GetName());
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),30,400,8000,800,5); 
        return ShowStartFirstMissionBriefing,140;
    }
    //-----------------------------------------------------------------------------------------
    state ShowStartFirstMissionBriefing
    {
        AddBriefing("translateStartFirstMission");
        return Nothing,500;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        int nSendedMoney;
        int nRemTime;
        int i;
        nSendedMoney = p_Player.GetMoneySentToOrbit();
        
        RegisterGoal(0,"translateGoalSendMoneyToSpace",fleetCost,(nSendedMoney*100)/fleetCost);
        RegisterGoal(1,"translateGoalUCSCampaignPhase1");
        RegisterGoal(2,"translateGoalUCSCampaignPhase2");
        RegisterGoal(3,"translateGoalUCSCampaignPhase3");
        RegisterGoal(4,"translateGoalUCSCampaignPhase4");
        RegisterGoal(5,"translateGoalUCSCampaignPhase5");
        
        for(i=1;i<6;i=i+1)
        {
            if(GetGoalState(i)!=goalAchieved && (nSendedMoney>=((phaseCost*(i-1))+firstPhaseCost)))
            {
                SetGoalState(i,goalAchieved);
            }
        }
        
        if(bMissionsFinished && (nSendedMoney+p_Player.GetMoney()+p_Player.GetMoneyFromFinishedMissions())<fleetCost)
        {
            AddBriefing("translateCampaignUCSFailed");
            EndGameResult=5;
            return EndGameState,3;
        }
        
        if(!p_Player.GetNumberOfBuildings(buildingSpaceStation))
        {
            AddBriefing("translateCampaignUCSSpacePortDestroyed",p_Player.GetName());
            EndGameResult=5;
            return EndGameState,3;
        }
        
        if(nSendedMoney>=fleetCost)
        {
            SetGoalState(0,goalAchieved);
            AddBriefing("translateCampaignUCSAccomplished",p_Player.GetName());
            EndGameResult=4;
            return EndGameState,3;
        }
        SetConsoleText("translateCampaignUCSRemainingTime",((oneSeasonTime*noOfSeasons) - GetMissionTime())/clicksPerDay);//XXXMD
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
        
        nReport = nReport+1;
        
        if(nReport>noOfSeasons)
        {
            AddBriefing("translateCampaignUCSFailed",p_Player.GetName());
            EnableNextMission(0,5);
            return;
        }
        
        nSendedMoney = p_Player.GetMoneySentToOrbit();// to ma tu byc
        nProjectStatus = (nSendedMoney*100)/fleetCost;
        nMoneyForNextSeason = ((nReport+1)*oneSeasonMoney) - nSendedMoney;
        if(nMoneyForNextSeason<10000) nMoneyForNextSeason=10000;
        
        if(nSendedMoney < oneSeasonMoney*nReport)
            AddBriefing("translateUCSDelayReport",p_Player.GetName(),nReport,nProjectStatus,nMoneyForNextSeason,((nSendedMoney*100)/(oneSeasonMoney*nReport)));
        else
            AddBriefing("translateUCSReport",p_Player.GetName(),nReport,nProjectStatus,nMoneyForNextSeason);
    }
    
    event CustomEvent0(int k1,int k2,int k3,int k4) //XXXMD
    {
        bMissionsFinished=true;
    }
}