mission "translateMission353"
{
    consts
    {
        
        escortNeo = 0;
        destroyEnemyBase = 1;
        backToBase = 2;
    }
    
    player pPlayer;
    player pNeo;
    player pEnemy;
    player pDummy;
    
    unitex uHero;
    unitex uNeo;
    
    int bCaptureMechs;
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state ReachEnemyBase;
    state DestroyEnemyBase;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(escortNeo,"translateGoal353a");
        RegisterGoal(destroyEnemyBase,"translateGoal353b");
        RegisterGoal(backToBase,"translateGoalHeroBackToBase",0);
        EnableGoal(escortNeo,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(2); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pNeo = GetPlayer(8);
        pEnemy = GetPlayer(1);
        pDummy = GetPlayer(4);
        //----------- AI ---------------------
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        pPlayer.SetMoney(20000);
        pEnemy.SetMoney(20000);
        
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
        
        pDummy.EnableAIFeatures(aiEnabled,false);
        pDummy.EnableStatistics(false);
        
        pNeo.EnableStatistics(false);
        pNeo.EnableAIFeatures(aiEnabled,false);
        pNeo.EnableAIFeatures(aiRejectAlliance,false);
        
        pPlayer.SetAlly(pNeo);
        //----------- Money ------------------
        pPlayer.SetMoney(0);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_UCU1",true);
        
        tmpPlayer.EnableResearch("RES_ED_WHC1",true);
        tmpPlayer.EnableResearch("RES_ED_WHL1",true);
        tmpPlayer.EnableResearch("RES_ED_UMI1",true);
        tmpPlayer.EnableResearch("RES_ED_UA31",true);
        tmpPlayer.EnableResearch("RES_ED_SCR",true);
        
        pEnemy.EnableResearch("RES_UCS_WHP1",true);
        pEnemy.EnableResearch("RES_UCS_UBL1",true);
        pEnemy.EnableResearch("RES_UCS_UMI1",true);
        pEnemy.EnableResearch("RES_UCS_BOMBER31",true);
        pEnemy.EnableResearch("RES_UCS_SHD",true);
        //----------- Buildings --------------
        
        pPlayer.EnableBuilding("LCBBF",false); 
        pPlayer.EnableBuilding("LCBPP",false); 
        pPlayer.EnableBuilding("LCBBA",false); 
        pPlayer.EnableBuilding("LCBMR",false); 
        pPlayer.EnableBuilding("LCBSR",false);
        pPlayer.EnableBuilding("LCBRC",false);
        pPlayer.EnableBuilding("LCBAB",false);
        pPlayer.EnableBuilding("LCBGA",false);
        pPlayer.EnableBuilding("LCBDE",false);
        pPlayer.EnableBuilding("LCBHQ",false);
        pPlayer.EnableBuilding("LCBSD",false);
        pPlayer.EnableBuilding("LCBWC",false);
        pPlayer.EnableBuilding("LCBSS",false);
        pPlayer.EnableBuilding("LCBLZ",true);
        pPlayer.EnableBuilding("LCLASERWALL",false);
        //----------- Units ------------------
        uHero=pPlayer.GetScriptUnit(0);
        uNeo=GetUnit(GetPointX(0),GetPointY(0),GetPointZ(0));
        
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bCaptureMechs = true;       
        bCheckEndMission = false;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;//5 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing353",pPlayer.GetName());//zaprowadz Neo w poblize Headquarter w bazie UCS
        return ReachEnemyBase,100;
    }
    //-----------------------------------------------------------------------------------------
    state ReachEnemyBase
    {
        if(uNeo.IsLive() && uNeo.DistanceTo(GetPointX(1),GetPointY(1))<10)
        {
            pEnemy.GiveAllUnitsTo(pDummy);
            KillArea(2,GetPointX(1),GetPointY(1),0,20);
            pDummy.GiveAllUnitsTo(pEnemy);
            SetGoalState(escortNeo,goalAchieved);
            EnableGoal(destroyEnemyBase,true);
            uNeo.CommandMove(pNeo.GetStartingPointX(),pNeo.GetStartingPointY(),0);
            return DestroyEnemyBase,100; 
        }
        
        if(uHero.IsInWorld(GetWorldNum()))
        {
            if(uNeo.IsLive())
                uNeo.CommandMove(uHero.GetLocationX(),uHero.GetLocationY()+2,uHero.GetLocationZ());
        }
        return ReachEnemyBase,300;
    }
    //-----------------------------------------------------------------------------------------
    state DestroyEnemyBase
    {
        return DestroyEnemyBase,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(GetGoalState(backToBase)!=goalAchieved && !uHero.IsInWorld(GetWorldNum()))
        {
            SetGoalState(backToBase,goalAchieved);
            EnableEndMissionButton(true);
        }
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailedNoUnits",pPlayer.GetName());
                EndMission(false);
            }
            
            if(GetGoalState(destroyEnemyBase)!=goalAchieved && !pEnemy.GetNumberOfBuildings())
            {
                SetGoalState(destroyEnemyBase,goalAchieved);
                EnableGoal(backToBase,true);
                AddBriefing("translateAccomplished353",pPlayer.GetName());//enemy base destroyed
                state Nothing; 
            }
            
            if(GetGoalState(escortNeo)!=goalFailed && !uNeo.IsLive())
            {
                SetGoalState(escortNeo,goalFailed);
                AddBriefing("translateFailed353",pPlayer.GetName());//Neo Killed
            }
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
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        pNeo.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pNeo);
    }
}

