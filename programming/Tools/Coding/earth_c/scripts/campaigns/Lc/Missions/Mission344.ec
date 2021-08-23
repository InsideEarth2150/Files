mission "translateMission344"
{//Australia
    consts
    {
        destroyEnemyForces=0;
    }
    
    player pEnemy;
    player pAlly;
    player pPlayer;
    
    int bCheckEndMission;
    int nNeoAttack;
    
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(destroyEnemyForces,"translateGoal344");
        EnableGoal(destroyEnemyForces,true);           
        //----------- Temporary players ------
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy = GetPlayer(2);
        pAlly = GetPlayer(1);
        //----------- AI ---------------------
        pPlayer.SetMilitaryUnitsLimit(30000);
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
        {
            pEnemy.LoadScript("single\\singleEasy");
            pAlly.LoadScript("single\\singleHard");
        }
        if(GetDifficultyLevel()==1)
        {
            pEnemy.LoadScript("single\\singleMedium");
            pAlly.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            pEnemy.LoadScript("single\\singleHard");
            pAlly.LoadScript("single\\singleEasy");
        }
        
        pAlly.EnableAIFeatures(aiRejectAlliance,false);
        pPlayer.SetAlly(pAlly);
        pAlly.ChooseEnemy(pEnemy);
        pAlly.SetEnemy(pEnemy);
        pEnemy.ChooseEnemy(pPlayer);
        pEnemy.SetEnemy(pAlly);
        
        
        //----------- Money ------------------
        pPlayer.SetMoney(20000);
        pEnemy.SetMoney(120000);
        pAlly.SetMoney(120000);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WHL1",true);
        pPlayer.EnableResearch("RES_LC_UCR1",true);
        
        pEnemy.EnableResearch("RES_ED_UHT1",true);
        pEnemy.EnableResearch("RES_ED_UHW1",true);
        pEnemy.EnableResearch("RES_ED_UA41",true);
        pEnemy.EnableResearch("RES_ED_SGEN",true);
        
        pAlly.EnableResearch("RES_UCS_WMR1",true);
        pAlly.EnableResearch("RES_UCS_WHG1",true);
        pAlly.EnableResearch("RES_UCS_UHL1",true);
        pAlly.EnableResearch("RES_UCS_BOMBER21",true);
        pAlly.EnableResearch("RES_UCS_SGEN",true);
        pAlly.EnableResearch("RES_UCS_BHD",true);
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
        nNeoAttack=0;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing344a",pPlayer.GetName());
        return Fighting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!pEnemy.GetNumberOfBuildings())
            {
                SetGoalState(destroyEnemyForces,goalAchieved);           
                AddBriefing("translateAccomplished344",pPlayer.GetName());
                EnableEndMissionButton(true);
                return Evacuate,500;
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
        nNeoAttack=nNeoAttack+1;
        if(nNeoAttack==1)
        {
            AddBriefing("translateBriefing344b",pPlayer.GetName());
            pAlly.GiveAllUnitsTo(pEnemy);
        }
        if(nNeoAttack==3)
        {
            AddBriefing("translateBriefing344c",pPlayer.GetName());
            pAlly.GiveAllUnitsTo(pEnemy);
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
