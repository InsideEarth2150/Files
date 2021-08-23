mission "translateMission322"
{
    consts
    {
        meetConvoy = 0;
        escortConvoy = 1;
        backToBase = 2;
    }
    
    player pPlayer;
    player pConvoy;
    player pUCS1;
    player pUCS2;
    player pEnemy1;
    player pEnemy2;
    player pEnemy3;
    
    unitex uHero;
    unitex uConvoyCraft1;
    unitex uConvoyCraft2;
    unitex uConvoyCraft3;
    
    int bTestPhase;
    int b1Ready;  
    int b2Ready;  
    int b3Ready;  
    
    state Initialize;
    state ShowBriefing;
    state ReachBase1;
    state ReachBase2;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(meetConvoy,"translateGoal322a");
        if(GetDifficultyLevel()==0)
            RegisterGoal(escortConvoy,"translateGoal322b",33);
        if(GetDifficultyLevel()==1)
            RegisterGoal(escortConvoy,"translateGoal322b",66);
        if(GetDifficultyLevel()==2)
            RegisterGoal(escortConvoy,"translateGoal322b",100);
        RegisterGoal(backToBase,"translateGoalHeroBackToBase",0);
        EnableGoal(meetConvoy,true);
        //----------- Temporary players ------
        //    tmpPlayer = GetPlayer(2); 
        //    tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pConvoy = GetPlayer(6);
        pUCS1 = GetPlayer(1); 
        pUCS2 = GetPlayer(4);
        pEnemy1 = GetPlayer(2);
        pEnemy2 = GetPlayer(7);
        pEnemy3 = GetPlayer(8);
        
        //----------- AI ---------------------
        pEnemy2.EnableStatistics(false);
        pEnemy3.EnableStatistics(false);
        
        pEnemy1.LoadScript("single\\singleEasy");
        pUCS1.LoadScript("single\\singleEasy");
        pUCS2.LoadScript("single\\singleMedium");
        pConvoy.LoadScript("single\\singleHard");
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        pEnemy1.EnableAIFeatures(aiControlOffense,false);
        pEnemy2.EnableAIFeatures(aiRush,false);
        pEnemy3.EnableAIFeatures(aiRush,false);
        
        pEnemy2.SetMaxTankPlatoonSize(4);
        pEnemy2.SetNumberOfOffensiveTankPlatoons(3);
        pEnemy2.SetNumberOfDefensiveTankPlatoons(0);
        
        pEnemy3.SetMaxTankPlatoonSize(4);
        pEnemy3.SetNumberOfOffensiveTankPlatoons(3);
        pEnemy3.SetNumberOfDefensiveTankPlatoons(0);
        
        pEnemy1.SetNeutral(pEnemy2);
        pEnemy1.SetNeutral(pEnemy3);
        
        pEnemy2.SetNeutral(pEnemy1);
        pEnemy2.SetNeutral(pEnemy3);
        
        pEnemy3.SetNeutral(pEnemy1);
        pEnemy3.SetNeutral(pEnemy2);
        
        pConvoy.EnableAIFeatures(aiEnabled,false);
        pUCS1.EnableAIFeatures(aiControlOffense,false);
        pUCS2.EnableAIFeatures(aiControlOffense,false);
        
        pUCS1.EnableAIFeatures(aiRejectAlliance,false);
        pUCS2.EnableAIFeatures(aiRejectAlliance,false);
        pConvoy.EnableAIFeatures(aiRejectAlliance,false);
        
        pPlayer.SetAlly(pUCS1);
        pPlayer.SetAlly(pUCS2);
        pPlayer.SetAlly(pConvoy);
        
        pUCS1.SetAlly(pUCS2);
        pUCS1.SetAlly(pConvoy);
        
        pUCS2.SetAlly(pConvoy);
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        pPlayer.SetMoney(0);
        pEnemy1.SetMoney(20000);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_MSR3",true);
        pPlayer.EnableResearch("RES_LC_ASR1",true);
        pPlayer.EnableResearch("RES_LC_SOB2",true);
        
        pUCS1.EnableResearch("RES_UCS_WSP1",true);
        pUCS1.EnableResearch("RES_MSR2",true);
        pUCS1.EnableResearch("RES_UCS_BMD",true);
        
        pEnemy1.EnableResearch("RES_ED_WSR1",true);
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
        
        //----------- Artefacts --------------
        //----------- Timers -----------------
        //----------- Variables --------------
        bTestPhase=0;
        b1Ready = false;  
        b2Ready = false;  
        b3Ready = false;  
        
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;//5 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing322a",pPlayer.GetName());//dojedz do bazy 1 tam czeka konwoj
        
        
        if(GetDifficultyLevel()==1)
        {
            pEnemy2.RussianAttack(GetPointX(4),GetPointY(4),0);
        }
        
        if(GetDifficultyLevel()==2)
        {
            pEnemy2.RussianAttack(GetPointX(4),GetPointY(4),0);
            pEnemy3.RussianAttack(GetPointX(5),GetPointY(5),0);
        }
        
        pEnemy2.EnableAIFeatures(aiEnabled,false);
        pEnemy3.EnableAIFeatures(aiEnabled,false);
        pConvoy.EnableAIFeatures(aiEnabled,false);    
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
                AddBriefing("translateBriefing322b",pPlayer.GetName(),33);//oto twoj konwoj zaprowadz go do bazy 2 33% musi przezyc
            if(GetDifficultyLevel()==1)
                AddBriefing("translateBriefing322b",pPlayer.GetName(),66);//oto twoj konwoj zaprowadz go do bazy 2 66% musi przezyc
            if(GetDifficultyLevel()==2)
                AddBriefing("translateBriefing322b",pPlayer.GetName(),100);//oto twoj konwoj zaprowadz go do bazy 2 100% musi przezyc
            return ReachBase2,100; 
        }
        return ReachBase1,100;
    }
    //-----------------------------------------------------------------------------------------
    state ReachBase2
    {
        
        if(uHero.IsInWorld(GetWorldNum()))
        {
            if(uConvoyCraft1.IsLive())
                uConvoyCraft1.CommandMove(uHero.GetLocationX()-1,uHero.GetLocationY(),uHero.GetLocationZ());
            if(uConvoyCraft2.IsLive())
                uConvoyCraft2.CommandMove(uHero.GetLocationX()-2,uHero.GetLocationY(),uHero.GetLocationZ());
            if(uConvoyCraft3.IsLive())
                uConvoyCraft3.CommandMove(uHero.GetLocationX()-3,uHero.GetLocationY(),uHero.GetLocationZ());
        }
        
        if(!b1Ready && uConvoyCraft1.IsLive() && 
            uConvoyCraft1.DistanceTo(GetPointX(3),GetPointY(3))<15)
        {
            b1Ready = true;
        }
        if(!b2Ready && uConvoyCraft2.IsLive() && 
            uConvoyCraft2.DistanceTo(GetPointX(3),GetPointY(3))<15)
        {
            b2Ready = true;
        }
        if(!b3Ready && uConvoyCraft3.IsLive() && 
            uConvoyCraft3.DistanceTo(GetPointX(3),GetPointY(3))<15)
        {
            b3Ready = true;
        }
        
        if((GetDifficultyLevel()==1 && pConvoy.GetNumberOfUnits()<2) ||
            (GetDifficultyLevel()==2 && pConvoy.GetNumberOfUnits()<3) ||
            pConvoy.GetNumberOfUnits()==0)
        {
            SetGoalState(escortConvoy,goalFailed);
            EnableGoal(backToBase,true);
            AddBriefing("translateFailed322",pPlayer.GetName());//convoy destroyed
            return Nothing,100; 
        }
        
        if((b1Ready || !uConvoyCraft1.IsLive()) &&
            (b2Ready || !uConvoyCraft2.IsLive()) &&
            (b3Ready || !uConvoyCraft3.IsLive()))
        {
            if(uConvoyCraft1.IsLive()) uConvoyCraft1.ChangePlayer(pUCS2);
            if(uConvoyCraft2.IsLive()) uConvoyCraft2.ChangePlayer(pUCS2);
            if(uConvoyCraft3.IsLive()) uConvoyCraft3.ChangePlayer(pUCS2);
            pUCS2.SetMoney(20000);
            SetGoalState(escortConvoy,goalAchieved);
            EnableGoal(backToBase,true);
            AddBriefing("translateAccomplished322",pPlayer.GetName());//convoy on place
            EnableNextMission(0,true);
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
        pUCS1.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pUCS1);
        
        pUCS2.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pUCS2);
        
        pConvoy.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pConvoy);
    }
}

