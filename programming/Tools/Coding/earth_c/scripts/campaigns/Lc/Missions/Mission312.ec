mission "translateMission312"
{
    consts
    {
        makeTests = 0;
        backToBase = 1;
        
    }
    
    
    player pPlayer;
    player pNeutral;
    player pTowers;
    player pEnemy;
    
    unitex uHero;
    unitex uTester;
    
    int bTestPhase;
    
    state Initialize;
    state ShowBriefing;
    state Testing;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(makeTests,"translateGoal312");
        RegisterGoal(backToBase,"translateGoalHeroBackToBase",0);
        EnableGoal(makeTests,true);
        //----------- Temporary players ------
        
        tmpPlayer = GetPlayer(2); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pNeutral = GetPlayer(5);
        pTowers = GetPlayer(10);
        pEnemy = GetPlayer(1); 
        
        //----------- AI ---------------------
        pPlayer.EnableStatistics(false);
        pNeutral.EnableStatistics(false);
        pTowers.EnableStatistics(false);
        pEnemy.EnableStatistics(false);
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        pNeutral.EnableAIFeatures(aiEnabled,false);
        pTowers.EnableAIFeatures(aiEnabled,false);
        
        pNeutral.EnableAIFeatures(aiRejectAlliance,false);
        pTowers.EnableAIFeatures(aiRejectAlliance,false);
        
        pPlayer.SetAlly(pNeutral);
        pPlayer.SetAlly(pTowers);
        
        pTowers.SetEnemy(pNeutral);
        pNeutral.SetNeutral(pTowers);
        
        pNeutral.SetEnemy(pEnemy);
        pEnemy.SetNeutral(pNeutral);
        //----------- Money ------------------
        pPlayer.SetMoney(0);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_MCH2",true);
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
        uTester=GetUnit(GetPointX(0),GetPointY(0),GetPointZ(0));
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bTestPhase=0;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;//5 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        AddBriefing("translateBriefing312a",pPlayer.GetName());
        return Testing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Testing
    {
        if(bTestPhase==0 && 
            uHero.IsInWorld(GetWorldNum()) &&
            uHero.DistanceTo(GetPointX(1),GetPointY(1))<8)
        {
            uHero.ChangePlayer(pNeutral);
            uHero.CommandMove(GetPointX(1),GetPointY(1),0);
            bTestPhase=1;
            return Testing,100; 
        }
        
        if(bTestPhase==1 && 
            uHero.DistanceTo(GetPointX(1),GetPointY(1))==0)
        {
            AddBriefing("translateBriefing312b",pPlayer.GetName());//start speed test
            uHero.CommandMove(GetPointX(2),GetPointY(2),0);
            uTester.CommandMove(GetPointX(3),GetPointY(3),0);
            bTestPhase=2;
            return Testing,100; 
        }
        
        if(bTestPhase==2 && 
            uHero.DistanceTo(GetPointX(2),GetPointY(2))==0)
        {
            AddBriefing("translateBriefing312c",pPlayer.GetName());//end speed test start hp test
            uHero.CommandMove(GetPointX(6),GetPointY(6),0);
            bTestPhase=3;
            return Testing,100; 
        }
        
        if(bTestPhase==3 && 
            uHero.DistanceTo(GetPointX(6),GetPointY(6))==0)
        {
            bTestPhase=4;
            return Testing,200; 
        }
        
        if(bTestPhase==4)
        {
            uHero.CommandMove(GetPointX(4),GetPointY(4),0);
            bTestPhase=5;
            return Testing,100; 
        }
        if(bTestPhase==5 && 
            uHero.DistanceTo(GetPointX(4),GetPointY(4))==0)
        {
            AddBriefing("translateBriefing312d",pPlayer.GetName());//end hp test start fire test
            uHero.CommandMove(GetPointX(5),GetPointY(5),0);
            bTestPhase=6;
            return Testing,100; 
        }
        
        if(bTestPhase==6 && 
            !pEnemy.GetNumberOfUnits())
        {
            uHero.ChangePlayer(pPlayer);
            SetGoalState(makeTests, goalAchieved);
            EnableGoal(backToBase,true);
            AddBriefing("translateAccomplished312",pPlayer.GetName());//end tests
            
            bTestPhase=7;
            return Nothing,100; 
        }
        return Testing,100; 
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
        pNeutral.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pNeutral);
        
        pTowers.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pTowers);
    }
}

