mission "translateMission131"
{
    consts
    {
        destroyEnemy = 0;
    }
    
    player pEnemy;
    player pPlayer;
    
    unitex uMainBaseLC;
    
    int bCheckEndMission;
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(destroyEnemy,"translateGoal131");
        EnableGoal(destroyEnemy,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(2); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(1);
        pEnemy = GetPlayer(3);
        //----------- AI ---------------------
        pPlayer.SetMilitaryUnitsLimit(20000);
        if(GetDifficultyLevel()==0)
        {
            pEnemy.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            pEnemy.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            pEnemy.LoadScript("single\\singleHard");
        }
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        pPlayer.SetMilitaryUnitsLimit(20000);
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        pEnemy.SetMoney(20000);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_UCS_WSP1",true);
        pPlayer.EnableResearch("RES_UCS_UOH3",true);
        //----------- Buildings --------------
        if(pPlayer.GetScriptData(5)!=12)
            pPlayer.EnableBuilding("UCSBTE",false);
        //----------- Units ------------------
        uMainBaseLC = GetUnit(GetPointX(0),GetPointY(0),0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,200);
        //----------- Variables --------------
        bCheckEndMission=false;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        AddBriefing("translateBriefing131");
        return Fighting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            
            if(!uMainBaseLC.IsLive())
            {
                EnableGoal(destroyEnemy,false);
                pEnemy.EnableAIFeatures(aiRejectAlliance,false);
                pEnemy.EnableAIFeatures(aiEnabled,false);
                pPlayer.SetAlly(pEnemy);
                AddBriefing("translateAccomplished131",pEnemy.GetName());
                EnableEndMissionButton(true);
                return Nothing,500;
            }
            
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed131");
                EndMission(false);
            }
        }
        return Fighting,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit uUnit)
    {
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit uUnit)
    { 
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    { 
        pPlayer.SetEnemy(pEnemy);
        pEnemy.SetEnemy(pPlayer);
    }
}

