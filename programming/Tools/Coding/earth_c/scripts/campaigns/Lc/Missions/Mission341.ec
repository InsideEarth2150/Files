mission "translateMission341"
{//Rio
    consts
    {
        
        escortNeo = 0;
        destroyEnemyBase = 1;
        backToBase = 2;
    }
    
    player pPlayer;
    player pNeo;
    player pEnemy;
    
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
        RegisterGoal(escortNeo,"translateGoal341a");
        RegisterGoal(destroyEnemyBase,"translateGoal341b");
        RegisterGoal(backToBase,"translateGoalHeroBackToBase",0);
        EnableGoal(escortNeo,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(2); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pNeo = GetPlayer(8);
        pEnemy = GetPlayer(1);
        
        //----------- AI ---------------------
        pPlayer.SetMilitaryUnitsLimit(30000);
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        pNeo.EnableStatistics(false);
        pNeo.EnableAIFeatures(aiEnabled,false);
        pNeo.EnableAIFeatures(aiRejectAlliance,false);
        
        pEnemy.EnableAIFeatures(aiRush,false);
        pEnemy.EnableAIFeatures(aiControlOffense,false);
        
        pPlayer.SetAlly(pNeo);
        //----------- Money ------------------
        pPlayer.SetMoney(0);
        //----------- Researches -------------
        tmpPlayer.EnableResearch("RES_ED_WSI1",true);
        tmpPlayer.EnableResearch("RES_ED_WHC1",true);
        tmpPlayer.EnableResearch("RES_ED_UHT1",true);
        tmpPlayer.EnableResearch("RES_ED_UHW1",true);
        tmpPlayer.EnableResearch("RES_ED_UA41",true);
        tmpPlayer.EnableResearch("RES_ED_SGEN",true);
        
        pEnemy.EnableResearch("RES_UCS_WMR1",true);
        pEnemy.EnableResearch("RES_UCS_WHG1",true);
        pEnemy.EnableResearch("RES_MMR2",true);
        pEnemy.EnableResearch("RES_UCS_UHL1",true);
        pEnemy.EnableResearch("RES_UCS_BOMBER21",true);
        pEnemy.EnableResearch("RES_UCS_BHD",true);
        pEnemy.EnableResearch("RES_UCS_SGEN",true);
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
        AddBriefing("translateBriefing341a",pPlayer.GetName());//zaprowadz Neo w poblize Headquarter w bazie UCS
        return ReachEnemyBase,100;
    }
    //-----------------------------------------------------------------------------------------
    state ReachEnemyBase
    {
        if(uNeo.DistanceTo(GetPointX(1),GetPointY(1))<15)
        {
            pEnemy.GiveAllUnitsTo(pPlayer);
            //
            EnableGoal(destroyEnemyBase,true);
            AddBriefing("translateBriefing341b",pPlayer.GetName());//oto moj przyjaciemlu nasze nowe zabawki teraz mozemy zniszczyc ta baze i wykorzytac surowce.
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
        
        if(bCheckEndMission)
        {
            if(!pEnemy.GetNumberOfBuildings())
            {
                SetGoalState(escortNeo,goalAchieved);
                SetGoalState(destroyEnemyBase,goalAchieved);
                EnableGoal(backToBase,true);
                AddBriefing("translateAccomplished341",pPlayer.GetName());//enemy base destroyed
                EnableNextMission(0,true);
                return Nothing,100; 
            }
        }
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
        if(GetGoalState(escortNeo)!=goalFailed && !uNeo.IsLive())
        {
            SetGoalState(escortNeo,goalFailed);
            EnableGoal(backToBase,true);
            AddBriefing("translateFailed341",pPlayer.GetName());//Neo killed
            EnableNextMission(0,false);
            state Nothing; 
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

