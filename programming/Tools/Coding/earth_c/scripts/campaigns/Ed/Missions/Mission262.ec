mission "translateMission262"
{//Lesotho - Africa recover siloses.
    consts
    {
        destroySiloses = 0;
        launchTime = 48000;//40 min
        clicksPerDay = 16383;
    }
    player p_EnemyUCS;
    player p_EnemyMM;
    player p_Player;
    
    int bCheckEndMission;
    int bShowBriefing;
    
    state Initialize;
    state ShowBriefing;
    state Fight;
    state ShowVideoState;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(destroySiloses,"translateGoal262");
        EnableGoal(destroySiloses,true);           
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_EnemyUCS = GetPlayer(1);
        p_EnemyMM = GetPlayer(4);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            p_EnemyUCS.LoadScript("single\\singleEasy");
            p_EnemyUCS.EnableAIFeatures(aiUpgradeCannons,false);
            p_EnemyMM.LoadScript("single\\singleEasy");
            p_EnemyMM.EnableAIFeatures(aiUpgradeCannons,false);
            p_Player.SetMoney(30000);
            p_EnemyUCS.SetMoney(20000);
            p_EnemyMM.SetMoney(20000);
        }
        if(GetDifficultyLevel()==1)
        {
            p_EnemyUCS.LoadScript("single\\singleMedium");
            p_EnemyMM.LoadScript("single\\singleMedium");
            p_Player.SetMoney(20000);
            p_EnemyUCS.SetMoney(30000);
            p_EnemyMM.SetMoney(30000);
        }
        
        if(GetDifficultyLevel()==2)
        {
            p_EnemyUCS.LoadScript("single\\singleHard");
            p_EnemyMM.LoadScript("single\\singleHard");
            p_Player.SetMoney(15000);
            p_EnemyUCS.SetMoney(50000);
            p_EnemyMM.SetMoney(50000);
        }
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_EnemyMM.EnableAIFeatures(aiEnabled,false);
        p_EnemyUCS.EnableAIFeatures(aiControlOffense,false);
        
        
        p_EnemyMM.SetNeutral(p_EnemyUCS);
        p_EnemyUCS.SetNeutral(p_EnemyMM);
        //----------- Money ------------------
        //----------- Researches -------------
        p_Player.EnableResearch("RES_ED_AB1",true);
        p_Player.EnableResearch("RES_ED_UA31",true);
        
        p_EnemyUCS.EnableResearch("RES_UCS_WAPB1",true);
        p_EnemyUCS.EnableResearch("RES_UCS_MB2",true);
        p_EnemyUCS.EnableResearch("RES_UCS_BOMBER31",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,launchTime);
        //----------- Variables --------------
        bShowBriefing=true;
        bCheckEndMission=false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing262a");
        return Fight,100;
    }
    //-----------------------------------------------------------------------------------------
    state Fight
    {
        if(!p_EnemyMM.GetNumberOfBuildings())
        {
            SetGoalState(destroySiloses,goalAchieved);
            SetConsoleText("");
            AddBriefing("translateAccomplished262");
            p_EnemyMM.SetEnemy(p_EnemyUCS);
            p_EnemyUCS.SetEnemy(p_EnemyMM);
            return ShowVideoState,20;
        }  
        return Fight,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowVideoState
    { 
        ShowVideo("CS211");
        EnableEndMissionButton(true);
        return Nothing,512;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    { 
        return Nothing,512;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        int nTime;
        int nDays;
        int nHours;
        nTime = launchTime-GetMissionTime();
        if(nTime<0 || GetGoalState(destroySiloses)==goalAchieved) return;
        nDays=nTime/clicksPerDay;
        nHours = ((nTime-nDays*clicksPerDay)*24)/clicksPerDay;
        SetConsoleText("translateMissionMessage262",nDays,nHours);
        
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed262");
                p_EnemyMM.SetEnemy(p_EnemyUCS);
                p_EnemyUCS.SetEnemy(p_EnemyMM);
                EndMission(false);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 10min=600sec=12000 
    {
        if(bShowBriefing)
        {
            bShowBriefing=false;
            AddBriefing("translateBriefing262b");
            SetConsoleText("");
            p_EnemyMM.EnableAIFeatures(aiEnabled,true);
        }
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
    
}
