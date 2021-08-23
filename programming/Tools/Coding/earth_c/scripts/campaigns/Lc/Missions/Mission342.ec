mission "translateMission342"
{//India
    consts
    {
        sendToBase50000 = 0;
    }
    
    player pEnemy1;
    player pEnemy2;
    player pEnemy3;
    player pEnemy4;
    player pEnemy5;
    player pPlayer;
    
    int bShowFailed;  
    int bCheckEndMission;
    int nTimer;
    int nAttack;
    
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
        EnableGoal(sendToBase50000,true);
        
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        tmpPlayer = GetPlayer(2); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy1 = GetPlayer(4);
        pEnemy2 = GetPlayer(5);
        pEnemy3 = GetPlayer(6);
        pEnemy4 = GetPlayer(7);
        pEnemy5 = GetPlayer(8);
        
        //----------- AI ---------------------
        pEnemy1.EnableStatistics(false);
        pEnemy2.EnableStatistics(false);
        pEnemy3.EnableStatistics(false);
        pEnemy4.EnableStatistics(false);
        pEnemy5.EnableStatistics(false);
        
        pEnemy1.SetMaxTankPlatoonSize(4);
        pEnemy2.SetMaxTankPlatoonSize(4);
        pEnemy3.SetMaxTankPlatoonSize(4);
        pEnemy4.SetMaxTankPlatoonSize(4);
        pEnemy5.SetMaxTankPlatoonSize(4);
        
        pEnemy1.SetNumberOfDefensiveTankPlatoons(3-GetDifficultyLevel());
        pEnemy2.SetNumberOfDefensiveTankPlatoons(3-GetDifficultyLevel());
        pEnemy3.SetNumberOfDefensiveTankPlatoons(3-GetDifficultyLevel());
        pEnemy4.SetNumberOfDefensiveTankPlatoons(3-GetDifficultyLevel());
        pEnemy5.SetNumberOfDefensiveTankPlatoons(3-GetDifficultyLevel());
        
        pEnemy1.SetNumberOfOffensiveTankPlatoons(1+GetDifficultyLevel());
        pEnemy2.SetNumberOfOffensiveTankPlatoons(1+GetDifficultyLevel());
        pEnemy3.SetNumberOfOffensiveTankPlatoons(1+GetDifficultyLevel());
        pEnemy4.SetNumberOfOffensiveTankPlatoons(1+GetDifficultyLevel());
        pEnemy5.SetNumberOfOffensiveTankPlatoons(1+GetDifficultyLevel());
        
        pEnemy1.EnableAIFeatures(aiControlOffense,false);
        pEnemy2.EnableAIFeatures(aiControlOffense,false);
        pEnemy3.EnableAIFeatures(aiControlOffense,false);
        pEnemy4.EnableAIFeatures(aiControlOffense,false);
        pEnemy5.EnableAIFeatures(aiControlOffense,false);
        
        pEnemy1.SetNeutral(pEnemy5);
        pEnemy5.SetNeutral(pEnemy1);
        
        pEnemy2.SetNeutral(pEnemy3);
        pEnemy3.SetNeutral(pEnemy2);
        
        pEnemy2.SetNeutral(pEnemy4);
        pEnemy4.SetNeutral(pEnemy2);
        
        pEnemy1.SetName("Naroshi");
        pEnemy2.SetName("Taga Ri");
        pEnemy3.SetName("Kon Hi");
        pEnemy4.SetName("Wi Jan Ho");
        pEnemy5.SetName("Tar Gan");
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WMR1",true);
        pPlayer.EnableResearch("RES_MMR2",true);
        pPlayer.EnableResearch("RES_LC_UCR1",true);
        pPlayer.EnableResearch("RES_LC_HGEN",true);
        
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Variables --------------
        bCheckEndMission=false;
        bShowFailed=true;
        nAttack=0;
        if(GetDifficultyLevel()==0)
            nTimer=9000;
        if(GetDifficultyLevel()==1)
            nTimer=6000;
        if(GetDifficultyLevel()==2)
            nTimer=3600;
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,nTimer);
        
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,200;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing342",pPlayer.GetName());
        EnableNextMission(0,true);
        return Mining,100;
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(pPlayer.GetMoneySentToBase()>=50000)
        {
            SetGoalState(sendToBase50000, goalAchieved);
            AddBriefing("translateAccomplished342",pPlayer.GetName());
            EnableEndMissionButton(true);
            return Nothing,500;
        }
        return Mining,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        RegisterGoal(sendToBase50000,"translateGoalSend50000",pPlayer.GetMoneySentToBase());
        if(bShowFailed)
        {
            if(IsGoalEnabled(sendToBase50000))
            {
                if((ResourcesLeftInMoney()+pPlayer.GetMoneySentToBase()+pPlayer.GetMoney())<50000)
                {
                    bShowFailed=false;
                    SetGoalState(sendToBase50000, goalFailed);
                    AddBriefing("translateFailed342",pPlayer.GetName());
                    EnableEndMissionButton(true);
                    return Nothing;
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
    event Timer1() 
    {
        nAttack=nAttack+1;
        if(nAttack==1)
        {
            pEnemy1.EnableAIFeatures(aiControlOffense,true);
            pEnemy1.EnableStatistics(true);
        }
        if(nAttack==2)
        {
            pEnemy2.EnableAIFeatures(aiControlOffense,true);
            pEnemy2.EnableStatistics(true);
        }
        if(nAttack==3)
        {
            pEnemy3.EnableAIFeatures(aiControlOffense,true);
            pEnemy3.EnableStatistics(true);
        }
        if(nAttack==4)
        {
            pEnemy4.EnableAIFeatures(aiControlOffense,true);
            pEnemy4.EnableStatistics(true);
        }
        if(nAttack==5)
        {
            pEnemy5.EnableAIFeatures(aiControlOffense,true);
            pEnemy5.EnableStatistics(true);
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

