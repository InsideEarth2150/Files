mission "translateMission361"
{//Madagaskar
    consts
    {
        destroyEDForces=0;
        destroyUCSForces=1;
    }
    
    player pEnemy;
    player pAlly;
    player pPlayer;
    
    int bCheckEndMission;
    int bBetrayal;
    int makeBetrayal;
    
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state ShowVideoState;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(destroyEDForces,"translateGoal361a");
        RegisterGoal(destroyUCSForces,"translateGoal361b");
        EnableGoal(destroyEDForces,true);           
        //----------- Temporary players ------
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy = GetPlayer(2);
        pAlly = GetPlayer(1);
        //----------- AI ---------------------
        pPlayer.SetMilitaryUnitsLimit(40000);
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
        {
            pEnemy.LoadScript("single\\singleEasy");
            pAlly.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            pEnemy.LoadScript("single\\singleMedium");
            pAlly.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            pEnemy.LoadScript("single\\singleHard");
            pAlly.LoadScript("single\\singleHard");
        }
        
        pAlly.EnableAIFeatures(aiRejectAlliance,false);
        pAlly.SetEnemy(pEnemy);
        pAlly.ChooseEnemy(pEnemy);
        pEnemy.SetEnemy(pAlly);
        pPlayer.SetAlly(pAlly);
        
        pPlayer.SetMilitaryUnitsLimit(40000);
        //----------- Money ------------------
        pPlayer.SetMoney(20000);
        pEnemy.SetMoney(150000);
        pAlly.SetMoney(150000);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WHS1",true);
        pPlayer.EnableResearch("RES_LC_WAS1",true);
        pPlayer.EnableResearch("RES_LC_AMR1",true);
        pPlayer.EnableResearch("RES_LC_UBO1",true);
        pPlayer.EnableResearch("RES_LC_SDIDEF",true);
        pPlayer.EnableResearch("RES_LC_WARTILLERY",true);
        pPlayer.EnableResearch("RES_MMR4",true);
        
        pEnemy.EnableResearch("RES_ED_WHR1",true);
        pEnemy.EnableResearch("RES_ED_UBT1",true);
        
        pAlly.EnableResearch("RES_UCS_PC",true);
        pAlly.EnableResearch("RES_UCS_WSD",true);
        pAlly.EnableResearch("RES_UCS_WAPB1",true);
        pAlly.EnableResearch("RES_UCS_MB2",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        if(GetDifficultyLevel()==0)
            SetTimer(0,24000);//20min
        if(GetDifficultyLevel()==1)
            SetTimer(0,12000);//10min
        if(GetDifficultyLevel()==2)
            SetTimer(0,6000);//5 min
        //----------- Variables --------------
        bCheckEndMission=false;
        bBetrayal=true;
        makeBetrayal=false;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing361a",pPlayer.GetName());
        EnableNextMission(0,true);
        return Fighting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(makeBetrayal)
        {
            makeBetrayal=false;
            EnableGoal(destroyUCSForces,true);           
            pAlly.EnableAIFeatures(aiRejectAlliance,true);
            pAlly.SetEnemy(pPlayer);
            pEnemy.SetEnemy(pPlayer);
            pPlayer.SetEnemy(pAlly);
            pAlly.ChooseEnemy(pPlayer);
            pEnemy.ChooseEnemy(pPlayer);
            AddBriefing("translateBriefing361b",pPlayer.GetName());
        }
        
        if(GetGoalState(destroyEDForces)==goalAchieved &&
            GetGoalState(destroyUCSForces)==goalAchieved )
        {
            AddBriefing("translateAccomplished361c",pPlayer.GetName());
            return ShowVideoState,20;
        }
        
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(GetGoalState(destroyEDForces)!=goalAchieved &&
                !pEnemy.GetNumberOfUnits() && 
                !pEnemy.GetNumberOfBuildings())
            {
                SetGoalState(destroyEDForces,goalAchieved);           
                AddBriefing("translateAccomplished361a",pPlayer.GetName());//ED forces destroyed
            }
            if(GetGoalState(destroyUCSForces)!=goalAchieved &&
                !pAlly.GetNumberOfUnits() && 
                !pAlly.GetNumberOfBuildings())
            {
                SetGoalState(destroyUCSForces,goalAchieved);           
                AddBriefing("translateAccomplished361b",pPlayer.GetName());//UCS forces destroyed Traitors are dead now
            }
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailedNoUnits",pPlayer.GetName());
                EndMission(false);
            }
        }
        
        return Fighting,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowVideoState
    {
        ShowVideo("CS311");
        EnableEndMissionButton(true);
        return Evacuate,500;
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        return Evacuate,500;
    }
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit u_Unit)
    {
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit u_Unit)
    { 
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------//-----------------------------------------------------------------------------------------
    event Timer0()
    {
        if(bBetrayal)
        {
            bBetrayal=false;
            makeBetrayal=true;
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        pAlly.EnableAIFeatures(aiRejectAlliance,true);
        pPlayer.SetEnemy(pAlly);
        pAlly.SetEnemy(pPlayer);
    }
    //-----------------------------------------------------------------------------------------
}
