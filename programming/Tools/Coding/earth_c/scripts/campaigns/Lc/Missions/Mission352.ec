mission "translateMission352"
{//Rio de Janeiro
    consts
    {
        killNeo = 0;
        backToBase = 1;
    }
    
    player pPlayer;
    player pAlly;
    player pEnemy;
    
    unitex uNeo;
    unitex uHero;
    
    int nReflex;
    int nWayPoint;
    
    state Initialize;
    state ShowBriefing;
    state Preparing;
    state Runaway;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(killNeo,"translateGoal352");//kill Neo
        RegisterGoal(backToBase,"translateGoalHeroBackToBase",0);
        EnableGoal(killNeo,true);
        //----------- Temporary players ------
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pAlly = GetPlayer(1);
        pEnemy = GetPlayer(2); 
        
        //----------- AI ---------------------
        pPlayer.EnableAIFeatures(aiEnabled,false);
        pAlly.EnableAIFeatures(aiEnabled,false);
        pEnemy.EnableAIFeatures(aiEnabled,false);
        
        pAlly.EnableAIFeatures(aiRejectAlliance,false);
        pAlly.SetEnemy(pEnemy);
        pAlly.ChooseEnemy(pEnemy);
        pEnemy.SetEnemy(pAlly);
        pPlayer.SetAlly(pAlly);
        //----------- Money ------------------
        pPlayer.SetMoney(0);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_UCU1",true);
        
        pEnemy.EnableResearch("RES_ED_WHL1",true);
        pEnemy.EnableResearch("RES_ED_UMI1",true);
        pEnemy.EnableResearch("RES_ED_UA31",true);
        pEnemy.EnableResearch("RES_ED_SCR",true);
        
        pAlly.EnableResearch("RES_UCS_WHP1",true);
        pAlly.EnableResearch("RES_UCS_UBL1",true);
        pAlly.EnableResearch("RES_UCS_UMI1",true);
        pAlly.EnableResearch("RES_UCS_BOMBER31",true);
        pAlly.EnableResearch("RES_UCS_SHD",true);
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
        pPlayer.EnableBuilding("LCBLZ",false);
        pPlayer.EnableBuilding("LCLASERWALL",false);
        //----------- Units ------------------
        uNeo = GetUnit(GetPointX(0),GetPointY(0),GetPointZ(0));
        uHero = pPlayer.GetScriptUnit(0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        nWayPoint=1;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;//5 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        AddBriefing("translateBriefing352",pPlayer.GetName());//zabij go neo on rzejal mechy i rozwala baze naszych przyjaciol
        return Preparing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Preparing
    {
        if(pPlayer.GetNumberOfUnits()>0)
        {
            return Runaway,100;
        }
        return Preparing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Runaway
    {
        if(pPlayer. IsPointLocated(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint)))
        {
            nWayPoint=nWayPoint+1;
            if(nWayPoint>5) nWayPoint=5;
        }
        if(!uNeo.IsLive())
        {
            SetGoalState(killNeo, goalAchieved);
            if(uHero.IsInWorld(GetWorldNum()))
            {
                EnableGoal(backToBase,true);
            }
            AddBriefing("translateAccomplished352",pPlayer.GetName());//Neo is killed
            return Nothing,100; 
        }
        uNeo.CommandMove(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint));
        
        if(GetDifficultyLevel()==0)
            return Runaway,300;//EASY
        if(GetDifficultyLevel()==1)
            return Runaway,200;//MEDIUM
        
        return Runaway,100; //HARD
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
    }
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit u_Unit)
    {
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit u_Unit)
    { 
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        pEnemy.SetEnemy(pAlly);
        pAlly.SetEnemy(pEnemy);
    }
}

