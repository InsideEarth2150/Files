mission "translateMissionEDBaseED"
{
    consts
    {
        oneSeasonMoney =  50000;//CR
        oneSeasonTime =  150000;//clk =2h05min 
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
        nReport = 0;
        RegisterGoal(0,"translateGoalSendMoneyToSpace",fleetCost,0);
        RegisterGoal(1,"translateGoalEDCampaignPhase1");
        RegisterGoal(2,"translateGoalEDCampaignPhase2");
        RegisterGoal(3,"translateGoalEDCampaignPhase3");
        RegisterGoal(4,"translateGoalEDCampaignPhase4");
        RegisterGoal(5,"translateGoalEDCampaignPhase5");
        EnableGoal(0,true);
        EnableGoal(1,true);
        EnableGoal(2,true);
        EnableGoal(3,true);
        EnableGoal(4,true);
        EnableGoal(5,true);
        
        p_Player = GetPlayer(2);
        p_Player.SetMoney(5000);
        p_Player.SetMilitaryUnitsLimit(10000);
        
        SetTimer(0,oneSeasonTime);
        
        p_Player.SetScriptData(0,fleetCost);
        
        //weapons
        p_Player.EnableResearch("RES_ED_WCH2",false);
        p_Player.EnableResearch("RES_ED_WCA2",false);
        p_Player.EnableResearch("RES_ED_WHC1",false);
        p_Player.EnableResearch("RES_ED_WHC2",false);
        p_Player.EnableResearch("RES_ED_WSR1",false);
        p_Player.EnableResearch("RES_ED_WSR2",false);
        p_Player.EnableResearch("RES_ED_WMR1",false);
        p_Player.EnableResearch("RES_ED_AMR1",false);
        p_Player.EnableResearch("RES_ED_WHR1",false);
        p_Player.EnableResearch("RES_ED_WSL1",false);
        p_Player.EnableResearch("RES_ED_WHL1",false);
        p_Player.EnableResearch("RES_ED_WSI1",false);
        p_Player.EnableResearch("RES_ED_AB1",false);
        
        //ammo
        p_Player.EnableResearch("RES_MCH2",false);
        p_Player.EnableResearch("RES_ED_MSC2",false);
        p_Player.EnableResearch("RES_ED_MHC2",false);
        p_Player.EnableResearch("RES_MSR2",false);
        p_Player.EnableResearch("RES_MMR2",false);
        p_Player.EnableResearch("RES_ED_MHR2",false);
        p_Player.EnableResearch("RES_ED_MB2",false);
        //chassis
        p_Player.EnableResearch("RES_ED_UHT1",false);
        p_Player.EnableResearch("RES_ED_UBT1",false);
        
        
        p_Player.EnableResearch("RES_ED_UST2",false);
        p_Player.EnableResearch("RES_ED_UST3",false);
        p_Player.EnableResearch("RES_ED_UMT1",false);
        p_Player.EnableResearch("RES_ED_UMI1",false);
        p_Player.EnableResearch("RES_ED_UMW1",false);
        p_Player.EnableResearch("RES_ED_UHW1",false);
        
        p_Player.EnableResearch("RES_ED_USS2",false);
        p_Player.EnableResearch("RES_ED_UHS1",false);
        
        p_Player.EnableResearch("RES_ED_UA11",false);
        p_Player.EnableResearch("RES_ED_UA12",false);
        p_Player.EnableResearch("RES_ED_UA21",false);
        p_Player.EnableResearch("RES_ED_UA22",false);
        p_Player.EnableResearch("RES_ED_UA31",false);
        p_Player.EnableResearch("RES_ED_UA41",false);
        
        //special
        p_Player.EnableResearch("RES_ED_BMD",false);
        p_Player.EnableResearch("RES_ED_BHD",false);
        p_Player.EnableResearch("RES_ED_RepHand",false);
        p_Player.EnableResearch("RES_ED_RepHand2",false);
        p_Player.EnableResearch("RES_ED_SCR",false);
        p_Player.EnableResearch("RES_ED_SGen",false);
        
        bMissionsFinished=false;
        //BUILDINGS
        p_Player.EnableBuilding("EDBTC",false);
        
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),4,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        nReport = 0;
        AddBriefing("translateStartCampaign",fleetCost);
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),30,400,8000,800,5); 
        return ShowStartFirstMissionBriefing,140;
    }
    //-----------------------------------------------------------------------------------------
    state ShowStartFirstMissionBriefing
    {
        AddBriefing("translateStartFirstMission");
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        int nSendedMoney;
        int nRemTime;
        int i;
        int k;
        nSendedMoney = p_Player.GetMoneySentToOrbit();
        RegisterGoal(0,"translateGoalSendMoneyToSpace",fleetCost,(nSendedMoney*100)/fleetCost);
        for(i=1;i<6;i=i+1)
        {
            k=firstPhaseCost+(phaseCost*(i-1));
            if(nSendedMoney>=k)
            {
                SetGoalState(i,goalAchieved);
            }
        }
        if(nSendedMoney>=fleetCost)
        {
            SetGoalState(0,goalAchieved);
            AddBriefing("translateCampaignAccomplished");
            EndGameResult=4;
            return EndGameState,3;
        }
        if(!p_Player.GetNumberOfBuildings(buildingSpaceStation))
        {
            AddBriefing("translateCampaignEDSpacePortDestroyed",p_Player.GetName());
            EndGameResult=5;
            return EndGameState,3;
        }
        
        if(bMissionsFinished && (nSendedMoney+p_Player.GetMoney()+p_Player.GetMoneyFromFinishedMissions())<fleetCost)
        {
            AddBriefing("translateCampaignFailed");
            EndGameResult=5;
            return EndGameState,3;
        }
        
        SetConsoleText("translateCampaignEDRemainingTime",((oneSeasonTime*noOfSeasons) - GetMissionTime())/clicksPerDay);//XXXMD
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
            AddBriefing("translateCampaignFailed");
            EnableNextMission(0,5);
            return;
        }
        
        nSendedMoney = p_Player.GetMoneySentToOrbit();// to ma tu byc
        nProjectStatus = (nSendedMoney*100)/fleetCost;
        nMoneyForNextSeason = ((nReport+1)*oneSeasonMoney) - nSendedMoney;
        if(nMoneyForNextSeason<10000) nMoneyForNextSeason=10000;
        
        if(nSendedMoney < oneSeasonMoney*nReport)
            AddBriefing("translateDelayReport",nReport,nProjectStatus,oneSeasonMoney*nReport,nSendedMoney,nMoneyForNextSeason);
        else
            AddBriefing("translateReport",nReport,nProjectStatus,oneSeasonMoney*nReport,nSendedMoney,nMoneyForNextSeason);
    }
    
    event CustomEvent0(int k1,int k2,int k3,int k4) //XXXMD
    {
        bMissionsFinished=true;
    }
}