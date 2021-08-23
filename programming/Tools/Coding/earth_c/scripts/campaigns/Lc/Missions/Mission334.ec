mission "translateMission334"
{
    consts
    {
        sendToBase50000 = 0;
        backToBase = 1;
    }
    
    player pEnemy;
    player pEDStrikeForces;
    player pPlayer;
    
    unitex uHero;
    
    int bShowFailed;    
    int bCheckEndMission;
    int nAttackCounter;
    
    state Initialize;
    state ShowBriefing;
    state Mining;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(sendToBase50000,"translateGoalSend50000",0);
        RegisterGoal(backToBase,"translateGoalHeroBackToBase");
        EnableGoal(sendToBase50000,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy = GetPlayer(2);
        pEDStrikeForces = GetPlayer(4);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
            pEnemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            pEnemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            pEnemy.LoadScript("single\\singleHard");
        
        
        pEDStrikeForces.LoadScript("single\\singleHard");
        pEDStrikeForces.SetMaxTankPlatoonSize(6);
        pEDStrikeForces.SetNumberOfOffensiveTankPlatoons(10);
        pEDStrikeForces.SetNumberOfDefensiveTankPlatoons(0);
        pEDStrikeForces.EnableAIFeatures(aiControlOffense,false);
        pEDStrikeForces.EnableAIFeatures(aiControlDefense,false);
        pEDStrikeForces.SetNeutral(pEnemy);
        pEnemy.SetNeutral(pEDStrikeForces);
        
        
        pEnemy.EnableAIFeatures(aiControlOffense,false);
        
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        pEnemy.SetMoney(20000);
        
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WSL2",true);
        pPlayer.EnableResearch("RES_MSR4",true);
        pPlayer.EnableResearch("RES_LC_SHR1",true);
        
        pEnemy.EnableResearch("RES_ED_WSL1",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        uHero=pPlayer.GetScriptUnit(0);
        //----------- Artefacts --------------
        //----------- Variables --------------
        bCheckEndMission=false;
        bShowFailed=true;
        if(GetDifficultyLevel()==0)
            nAttackCounter=48;//hours
        if(GetDifficultyLevel()==1)
            nAttackCounter=36;
        if(GetDifficultyLevel()==2)
            nAttackCounter=24;
        
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,16383/24);
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,200;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        Rain(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),10,400,5000,800,5); 
        AddBriefing("translateBriefing334a",pPlayer.GetName(),nAttackCounter);//masz tylko <%0> hours for destroing the bridges
        return Mining,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(pPlayer.GetMoneySentToBase()>=50000)
        {
            SetGoalState(sendToBase50000, goalAchieved);
            EnableGoal(backToBase,true);
            AddBriefing("translateAccomplished334",pPlayer.GetName());
            return Nothing,500;
        }
        return Mining,200; 
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
        RegisterGoal(sendToBase50000,"translateGoalSend50000",pPlayer.GetMoneySentToBase());
        if(bShowFailed)
        {
            if(GetGoalState(sendToBase50000)!=goalAchieved)
            {
                if(ResourcesLeftInMoney()+pPlayer.GetMoneySentToBase()+pPlayer.GetMoney()<40000)
                {
                    bShowFailed=false;
                    SetGoalState(sendToBase50000, goalFailed);
                    EnableGoal(backToBase,true);
                    AddBriefing("translateFailed334",pPlayer.GetName());
                    state Nothing;
                }
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailedNoUnits",pPlayer.GetName());
                EndMission(false);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 1h
    {
        if(nAttackCounter>0)
        {
            nAttackCounter=nAttackCounter-1;
            SetConsoleText("translateMessage334",nAttackCounter/24,nAttackCounter%24);
            if(!nAttackCounter)
            {
                pEDStrikeForces.RussianAttack(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),0);
                AddBriefing("translateBriefing334b",pPlayer.GetName());
                pEnemy.EnableAIFeatures(aiControlOffense,true);
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
}

