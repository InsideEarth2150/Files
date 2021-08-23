mission "translateMission333"
{
    consts
    {
        destroyPrototype = 0;
        backToBase = 1;
    }
    
    player pPlayer;
    player pTraitor;
    player pEnemy;
    
    unitex uPrototype;
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
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(destroyPrototype,"translateGoal333");//destroy prototype
        RegisterGoal(backToBase,"translateGoalHeroBackToBase",0);
        EnableGoal(destroyPrototype,true);
        //----------- Temporary players ------
        
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pTraitor = GetPlayer(5);
        pEnemy = GetPlayer(2); 
        
        //----------- AI ---------------------
        pPlayer.EnableStatistics(false);
        pTraitor.EnableStatistics(false);
        pEnemy.EnableStatistics(false);
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        pTraitor.EnableAIFeatures(aiEnabled,false);
        
        
        pEnemy.SetNeutral(pTraitor);
        pTraitor.SetNeutral(pEnemy);
        
        
        pEnemy.EnableAIFeatures(aiControlOffense,false);
        pEnemy.SetMaxTankPlatoonSize(6);
        pEnemy.SetMaxHelicopterPlatoonSize(0);
        pEnemy.SetMaxShipPlatoonSize(0);
        
        pEnemy.SetNumberOfOffensiveTankPlatoons(10);
        pEnemy.SetNumberOfOffensiveShipPlatoons(0);
        pEnemy.SetNumberOfOffensiveHelicopterPlatoons(0);
        
        pEnemy.SetNumberOfDefensiveTankPlatoons(0);
        pEnemy.SetNumberOfDefensiveShipPlatoons(0);
        pEnemy.SetNumberOfDefensiveHelicopterPlatoons(0);
        pEnemy.SetMaxAttackFrequency(200);
        
        //----------- Money ------------------
        pPlayer.SetMoney(0);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WSS1",true);
        pPlayer.EnableResearch("RES_LC_WSL1",true);
        pPlayer.EnableResearch("RES_LC_BWC",true);
        pPlayer.EnableResearch("RES_LC_MGEN",true);
        pPlayer.EnableResearch("RES_LC_BHD",true);
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
        uPrototype = GetUnit(GetPointX(0),GetPointY(0),GetPointZ(0));
        uHero = pPlayer.GetScriptUnit(0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        nWayPoint=1;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(GetPointX(0),GetPointY(0),6,0,20,0);
        return ShowBriefing,100;//5 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        AddBriefing("translateBriefing333",pPlayer.GetName());//zdrada!!!! zabij go tylko hero moze to uczynic
        return Preparing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Preparing
    {
        if(pPlayer.GetNumberOfUnits()>0)
        {
            KillArea(8,uPrototype.GetLocationX(),uPrototype.GetLocationY(),0,15);
            CallCamera();
            pPlayer.LookAt(GetPointX(0)+3,GetPointY(0)-5,8,0,20,0);
            return Runaway,100;
        }
        return Preparing,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Runaway
    {
        if(uHero.DistanceTo(GetPointX(nWayPoint),GetPointY(nWayPoint))<15
            || pPlayer.IsPointLocated(GetPointX(nWayPoint),GetPointY(nWayPoint),0))
        {
            nWayPoint=nWayPoint+1;
            if(nWayPoint>5) nWayPoint=5;
        }
        if(uPrototype.DistanceTo(GetPointX(5),GetPointY(5))==0 && uPrototype.GetLocationZ()==1)
        {
            pEnemy.EnableAIFeatures(aiControlOffense,true);
            KillArea(4,GetPointX(6),GetPointY(6),0,1);
            SetGoalState(destroyPrototype, goalFailed);
            EnableGoal(backToBase,true);
            AddBriefing("translateFailed333",pPlayer.GetName());//prototype escaped
            return Nothing,100; 
        }
        if(!uPrototype.IsLive())
        {
            pEnemy.EnableAIFeatures(aiControlOffense,true);
            SetGoalState(destroyPrototype, goalAchieved);
            EnableGoal(backToBase,true);
            AddBriefing("translateAccomplished333",pPlayer.GetName());//prototype destroyed
            return Nothing,100; 
        }
        uPrototype.CommandMove(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint));
        
        if(GetDifficultyLevel()==0)
            return Runaway,400;//EASY
        if(GetDifficultyLevel()==1)
            return Runaway,200;//MEDIUM
        
        return Runaway,100; //HARD
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(GetGoalState(backToBase)!=goalAchieved && !uHero.IsInWorld(GetWorldNum()))
        {
            ShowVideo("CS312");
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
        pEnemy.SetEnemy(pTraitor);
        pTraitor.SetEnemy(pEnemy);
    }
}

