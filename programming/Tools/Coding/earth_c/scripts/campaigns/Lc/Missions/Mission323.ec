mission "translateMission323"
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
    
    unitex uPrototype;
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
        RegisterGoal(makeTests,"translateGoal323");
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
        pEnemy.EnableAIFeatures(aiEnabled,false);
        
        pNeutral.EnableAIFeatures(aiRejectAlliance,false);
        pTowers.EnableAIFeatures(aiRejectAlliance,false);
        pEnemy.EnableAIFeatures(aiRejectAlliance,false);
        
        pPlayer.SetAlly(pNeutral);
        pPlayer.SetAlly(pTowers);
        
        pEnemy.SetNeutral(pPlayer);
        pEnemy.SetNeutral(pNeutral);
        
        pNeutral.SetNeutral(pTowers);
        //----------- Money ------------------
        pPlayer.SetMoney(0);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_SGEN",true);
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
        uPrototype=GetUnit(GetPointX(1),GetPointY(1),GetPointZ(0));
        uTester=GetUnit(GetPointX(0),GetPointY(0),GetPointZ(0));
        CallCamera();
        SelectUnit(uPrototype,false);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bTestPhase=0;
        
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(GetPointX(1),GetPointY(1),6,0,20,0);
        return ShowBriefing,100;//5 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        AddBriefing("translateBriefing323a",pPlayer.GetName());
        return Testing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Testing
    {
        if(bTestPhase==0)
        {
            bTestPhase=1;
        }
        
        if(bTestPhase==1)
        {
            AddBriefing("translateBriefing323b",pPlayer.GetName());//start speed test
            uPrototype.CommandMove(GetPointX(2),GetPointY(2),0);
            uTester.CommandMove(GetPointX(3),GetPointY(3),0);
            bTestPhase=2;
            return Testing,100; 
        }
        
        if(bTestPhase==2 && 
            uPrototype.DistanceTo(GetPointX(2),GetPointY(2))==0)
        {
            AddBriefing("translateBriefing323c",pPlayer.GetName());//end speed test start hp test
            uPrototype.CommandMove(GetPointX(6),GetPointY(6),0);
            bTestPhase=3;
            return Testing,100; 
        }
        
        if(bTestPhase==3 && 
            uPrototype.DistanceTo(GetPointX(6),GetPointY(6))==0)
        {
            bTestPhase=4;
            return Testing,100; 
        }
        
        if(bTestPhase==4)
        {
            uPrototype.CommandMove(GetPointX(4),GetPointY(4),0);
            bTestPhase=5;
            return Testing,100; 
        }
        
        if(bTestPhase==5 && 
            uPrototype.DistanceTo(GetPointX(4),GetPointY(4))==0)
        {
            AddBriefing("translateBriefing323d",pPlayer.GetName());//end hp test start fire test
            uPrototype.CommandMove(GetPointX(5),GetPointY(5),0);
            uPrototype.ChangePlayer(pPlayer);
            CallCamera();
            SelectUnit(uPrototype,false);                           
            bTestPhase=6;
            return Testing,100; 
        }
        
        if(bTestPhase==6 && pEnemy.GetNumberOfUnits()<3)
        {
            KillArea(8,uPrototype.GetLocationX(),uPrototype.GetLocationY(),0,1);
            bTestPhase=7;
            return Testing,100; 
        }
        
        if(bTestPhase==7)
        {
            SetGoalState(makeTests, goalFailed);
            AddBriefing("translateAccomplished323",pPlayer.GetName());//end tests
            EnableEndMissionButton(true,false);
            return Nothing,100; 
        }
        return Testing,100; 
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
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
        
        pEnemy.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pEnemy);
    }
}

