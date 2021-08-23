mission "translateMission331"
{
    consts
    {
        meetConvoy = 0;
        escortConvoy = 1;
        backToBase = 2;
    }
    
    player pPlayer;
    player pConvoy;
    player pEnemy;
    
    unitex uHero;
    
    unitex uConvoyCraft1;
    unitex uConvoyCraft2;
    unitex uConvoyCraft3;
    unitex uConvoyCraft4;
    
    int bEDAsk;
    int b1Ready;  
    int b2Ready;  
    int b3Ready;  
    int b4Ready;  
    
    state Initialize;
    state ShowBriefing;
    state ReachBase1;
    state ReachBase2;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(meetConvoy,"translateGoal331a");
        RegisterGoal(escortConvoy,"translateGoal331b",100);
        RegisterGoal(backToBase,"translateGoalHeroBackToBase");
        EnableGoal(meetConvoy,true);
        //----------- Temporary players ------
        //    tmpPlayer = GetPlayer(2); 
        //    tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pConvoy = GetPlayer(1);
        pEnemy = GetPlayer(2);
        
        //----------- AI ---------------------
        pPlayer.SetMilitaryUnitsLimit(20000);    
        pPlayer.EnableAIFeatures(aiEnabled,false);
        pEnemy.EnableAIFeatures(aiEnabled,false);
        pConvoy.EnableAIFeatures(aiEnabled,false);
        
        pConvoy.EnableAIFeatures(aiRejectAlliance,false);
        
        pPlayer.SetAlly(pConvoy);
        //----------- Money ------------------
        pPlayer.SetMoney(0);
        pConvoy.SetMoney(20000);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_REG1",true);
        pConvoy.EnableResearch("RES_UCS_UAH1",true);
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
        
        uConvoyCraft1=GetUnit(GetPointX(0),GetPointY(0),GetPointZ(0));
        uConvoyCraft2=GetUnit(GetPointX(1),GetPointY(1),GetPointZ(1));
        uConvoyCraft3=GetUnit(GetPointX(2),GetPointY(2),GetPointZ(2));
        uConvoyCraft4=GetUnit(GetPointX(3),GetPointY(3),GetPointZ(3));
        //----------- Artefacts --------------
        //----------- Timers -----------------
        //----------- Variables --------------
        bEDAsk=true;
        b1Ready = false;  
        b2Ready = false;  
        b3Ready = false;  
        b4Ready = false;  
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;//5 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing331a",pPlayer.GetName());//dojedz do bazy 1 tam czeka konwoj
        return ReachBase1,100;
    }
    //-----------------------------------------------------------------------------------------
    state ReachBase1
    {
        if(uHero.IsInWorld(GetWorldNum()) &&
            uHero.DistanceTo(GetPointX(0),GetPointY(0))<5)
        {
            SetGoalState(meetConvoy,goalAchieved);
            EnableGoal(escortConvoy,true);
            if(GetDifficultyLevel()==0)
                AddBriefing("translateBriefing331b",pPlayer.GetName());//oto twoj konwoj zaprowadz go do bazy 2 100% musi przezyc
            return ReachBase2,100; 
        }
        return ReachBase1,100;
    }
    //-----------------------------------------------------------------------------------------
    state ReachBase2
    {
        if(bEDAsk && GetMissionTime()>6000)//5 min
        {
            bEDAsk=false;
            AddBriefing("translateBriefing331c",pPlayer.GetName());//ED here destroy this convoy and join us.
        }
        
        if(!uConvoyCraft1.IsLive() && !uConvoyCraft2.IsLive() && !uConvoyCraft3.IsLive() && !uConvoyCraft4.IsLive())
        {
            SetGoalState(escortConvoy,goalFailed);
            EnableGoal(backToBase,true);
            pEnemy.EnableAIFeatures(aiRejectAlliance,false);
            pPlayer.SetAlly(pEnemy);
            pConvoy.SetEnemy(pPlayer);
            pPlayer.SetEnemy(pConvoy);
            AddBriefing("translateAccomplished331b",pPlayer.GetName());//UCS convoy destroyed
            EnableNextMission(0,true);
            EnableNextMission(1,true);
            return Nothing,100; 
        }
        
        if(uHero.IsInWorld(GetWorldNum()))
        {
            if(uConvoyCraft1.IsLive())
                uConvoyCraft1.CommandMove(uHero.GetLocationX()-1,uHero.GetLocationY(),uHero.GetLocationZ());
            if(uConvoyCraft2.IsLive())
                uConvoyCraft2.CommandMove(uHero.GetLocationX()-2,uHero.GetLocationY(),uHero.GetLocationZ());
            if(uConvoyCraft3.IsLive())
                uConvoyCraft3.CommandMove(uHero.GetLocationX(),uHero.GetLocationY()-1,uHero.GetLocationZ());
            if(uConvoyCraft4.IsLive())
                uConvoyCraft4.CommandMove(uHero.GetLocationX(),uHero.GetLocationY()-2,uHero.GetLocationZ());
        }
        
        if(!b1Ready && uConvoyCraft1.IsLive() && 
            uConvoyCraft1.DistanceTo(GetPointX(4),GetPointY(4))<15)
        {
            b1Ready = true;
        }
        if(!b2Ready && uConvoyCraft2.IsLive() && 
            uConvoyCraft2.DistanceTo(GetPointX(4),GetPointY(4))<15)
        {
            b2Ready = true;
        }
        if(!b3Ready && uConvoyCraft3.IsLive() && 
            uConvoyCraft3.DistanceTo(GetPointX(4),GetPointY(4))<15)
        {
            b3Ready = true;
        }
        if(!b4Ready && uConvoyCraft4.IsLive() && 
            uConvoyCraft4.DistanceTo(GetPointX(4),GetPointY(4))<15)
        {
            b4Ready = true;
        }
        
        if(b1Ready && b2Ready && b3Ready && b4Ready)
        {
            SetGoalState(escortConvoy,goalAchieved);
            pConvoy.EnableAIFeatures(aiEnabled,true);
            pConvoy.EnableAIFeatures(aiControlOffense,false);
            EnableGoal(backToBase,true);
            AddBriefing("translateAccomplished331a",pPlayer.GetName());//convoy on place UCS alliance still keeped
            EnableNextMission(2,true);
            EnableNextMission(3,true);
            return Nothing,100; 
        }
        return ReachBase2,100;
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
        pEnemy.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pEnemy);
        
        pConvoy.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pConvoy);
    }
}

