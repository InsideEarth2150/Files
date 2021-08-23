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
    
    state Initialize;
    state ShowBriefing;
    state ShowStartFirstMissionBriefing;
    state Nothing;
    state EndDemo;
    
    state Initialize
    {
        nReport = 0;
        RegisterGoal(0,"translateGoalSendMoneyToSpace",fleetCost,0);
        EnableGoal(0,true);
        p_Player = GetPlayer(2);
        p_Player.SetMoney(2500);
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY()+9,6,0,20,0);
        p_Player.DelayedLookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY()-4,6,0,20,0,60,1);
        
        SetTimer(0,oneSeasonTime);
        
        p_Player.SetScriptData(0,fleetCost);
        p_Player.SetScriptData(1,0);
        
        //weapons
        //p_Player.EnableResearch("RES_ED_WCH2",false);
        //p_Player.EnableResearch("RES_ED_WCA2",false);
        p_Player.EnableResearch("RES_ED_WSL1",false);
        //p_Player.EnableResearch("RES_ED_WSR1",false);
        p_Player.EnableResearch("RES_ED_WSI1",false);
        p_Player.EnableResearch("RES_ED_WMR1",false);
        p_Player.EnableResearch("RES_ED_WHC1",false);
        p_Player.EnableResearch("RES_ED_WHI1",false);
        p_Player.EnableResearch("RES_ED_WHL1",false);
        p_Player.EnableResearch("RES_ED_WHR1",false);
        p_Player.EnableResearch("RES_ED_UHT1",false);
        //ammo
        p_Player.EnableResearch("RES_MCH2",false);
        p_Player.EnableResearch("RES_ED_MSC2",false);
        p_Player.EnableResearch("RES_ED_MHC2",false);
        p_Player.EnableResearch("RES_MSR2",false);
        p_Player.EnableResearch("RES_MMR2",false);
        p_Player.EnableResearch("RES_ED_MHR2",false);
        p_Player.EnableResearch("RES_ED_MHR4",false);
        
        //chassis
        //p_Player.EnableResearch("RES_ED_UMT1",false);
        p_Player.EnableResearch("RES_ED_UMW1",false);
        //p_Player.EnableResearch("RES_ED_UMI1",false);
        p_Player.EnableResearch("RES_ED_UHT1",false);
        p_Player.EnableResearch("RES_ED_UHW1",false);
        p_Player.EnableResearch("RES_ED_UBT1",false);
        p_Player.EnableResearch("RES_ED_UA11",false);
        p_Player.EnableResearch("RES_ED_UA12",false);
        p_Player.EnableResearch("RES_ED_UA21",false);
        p_Player.EnableResearch("RES_ED_UA31",false);
        p_Player.EnableResearch("RES_ED_UA41",false);
        p_Player.EnableResearch("RES_ED_USS2",false);
        p_Player.EnableResearch("RES_ED_UHS1",false);
        //special
        //p_Player.EnableResearch("RES_ED_RepHand",false);
        p_Player.EnableResearch("RES_ED_RepHand2",false);
        p_Player.EnableResearch("RES_ED_SCR",false);
        p_Player.EnableResearch("RES_ED_SGen",false);
        p_Player.EnableResearch("RES_ED_BMD",false);
        p_Player.EnableResearch("RES_ED_BHD",false);
        
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBTC",false);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        nReport = 0;
        AddBriefing("translateStartCampaign",fleetCost);
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),30,400,2500,800,8); 
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
        nSendedMoney = p_Player.GetMoneySentToOrbit();
        RegisterGoal(0,"translateGoalSendMoneyToSpace",fleetCost,(nSendedMoney*100)/fleetCost);
        
        if(!p_Player.GetNumberOfBuildings(buildingSpaceStation))
        {
            AddBriefing("translateCampaignEDSpacePortDestroyed",p_Player.GetName());
            return EndDemo,100;
        }
        
        if(p_Player.GetScriptData(1)==1)
        {
            AddBriefing("translateCampaignAccomplishedDemo");
            return EndDemo,100;
        }
        return Nothing,100;
    }
    //-----------------------------------------------------------------------------------------  
    state EndDemo
    {
        EndGame(null);
        //EndMission(true);
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
        if(nMoneyForNextSeason<0) nMoneyForNextSeason=0;
        
        if(nSendedMoney < oneSeasonMoney*nReport)
            AddBriefing("translateDelayReport",nReport,nProjectStatus,oneSeasonMoney*nReport,nSendedMoney,nMoneyForNextSeason);
        else
            AddBriefing("translateReport",nReport,nProjectStatus,oneSeasonMoney*nReport,nSendedMoney,nMoneyForNextSeason);
    }
    event Timer1() //wolany co 5000 cykli
    {
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),30,400,2500,800,10); 
    }
}