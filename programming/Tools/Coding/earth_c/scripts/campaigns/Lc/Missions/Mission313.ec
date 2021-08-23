mission "translateMission313"
{
    consts
    {
        sendToBase20000 = 0;
    }
    
    player pEnemy;
    player pPlayer;
    
    int bShowFailed;  
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Mining;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(sendToBase20000,"translateGoalSend20000",0);
        EnableGoal(sendToBase20000,true);
        
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy = GetPlayer(2);
        
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
            pEnemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            pEnemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            pEnemy.LoadScript("single\\singleHard");
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        //pEnemy.AddToMainTargetList();
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        pEnemy.SetMoney(20000);
        
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WCH2",true);
        pPlayer.EnableResearch("RES_LC_ACH2",true);
        pPlayer.EnableResearch("RES_LC_UME1",true);
        pPlayer.EnableResearch("RES_MSR2",true);
        pPlayer.EnableResearch("RES_LC_BMD",true);
        
        pEnemy.EnableResearch("RES_ED_WCH2",true);
        pEnemy.EnableResearch("RES_MCH2",true);
        pEnemy.EnableResearch("RES_ED_UA11",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,10000);
        
        //----------- Variables --------------
        bCheckEndMission=false;
        bShowFailed=true;
        
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,200;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing313",pPlayer.GetName());
        return Mining,100;
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(pPlayer.GetMoneySentToBase()>=20000)
        {
            SetGoalState(sendToBase20000, goalAchieved);
            AddBriefing("translateAccomplished313",pPlayer.GetName());
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
        RegisterGoal(sendToBase20000,"translateGoalSend20000",pPlayer.GetMoneySentToBase());
        if(bShowFailed)
        {
            if(IsGoalEnabled(sendToBase20000))
            {
                if((ResourcesLeftInMoney()+pPlayer.GetMoney()+pPlayer.GetMoneySentToBase())<20000)
                {
                    bShowFailed=false;
                    SetGoalState(sendToBase20000, goalFailed);
                    AddBriefing("translateFailed313",pPlayer.GetName());
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
    event Timer1() //wolany co 6000 cykli
    {
        Snow(GetPointX(0),GetPointY(0),30,400,2500,800,10); 
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

