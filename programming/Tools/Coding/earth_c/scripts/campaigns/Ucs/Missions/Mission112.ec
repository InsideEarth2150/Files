mission "translateMission112"
{//Antarktyka klif
    consts
    {
        defendFor20min = 0;
        clicksPerDay = 16383;
    }
    player p_Enemy;
    player p_Enemy2;
    player p_Player;
    int bCheckEndMission;
    int bShowAc;
    
    state Initialize;
    state ShowBriefing;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(defendFor20min,"translateGoal112",0,0);
        EnableGoal(defendFor20min,true);           
        
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        p_Enemy = GetPlayer(2);
        p_Enemy2 = GetPlayer(4);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            p_Enemy.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleHard");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleHard");
        }
        
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleMedium");
        }
        p_Enemy2.SetMaxTankPlatoonSize(6);
        p_Enemy2.SetNumberOfOffensiveTankPlatoons(10);
        p_Enemy2.SetNumberOfDefensiveTankPlatoons(0);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlDefense,false);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        p_Enemy2.SetNeutral(p_Enemy);
        p_Enemy.SetNeutral(p_Enemy2);
        p_Player.SetEnemy(p_Enemy);
        p_Enemy.SetEnemy(p_Player);
        //----------- Money ------------------
        p_Player.SetMoney(5000);
        p_Enemy.SetMoney(50000);
        //----------- Researches -------------
        p_Player.EnableResearch("RES_UCS_USL3",true);
        p_Player.EnableResearch("RES_UCS_WCH2",true);
        p_Player.EnableResearch("RES_UCS_WSG2",true);
        
        p_Enemy.EnableResearch("RES_ED_WCH2",true);
        p_Enemy.EnableResearch("RES_MCH2",true);
        p_Enemy.EnableResearch("RES_ED_UA11",true);
        //----------- Buildings --------------
        p_Player.EnableBuilding("UCSBBA",false);
        p_Player.EnableBuilding("UCSBFA",false);
        p_Player.EnableBuilding("UCSBPP",false);
        p_Player.EnableBuilding("UCSBPR",false);
        p_Player.EnableBuilding("UCSBTB",false);
        p_Player.EnableBuilding("UCSBET",false);
        p_Player.EnableBuilding("UCSBRF",false);
        p_Player.EnableBuilding("UCSBRC",false);
        p_Player.EnableBuilding("UCSBAB",false);
        p_Player.EnableBuilding("UCSBWB",false);
        p_Player.EnableBuilding("UCSBFO",false);
        p_Player.EnableBuilding("UCSBST",true);
        p_Player.EnableBuilding("UCSBBT",false);
        p_Player.EnableBuilding("UCSBPB",false);
        p_Player.EnableBuilding("UCSBPC",false);
        p_Player.EnableBuilding("UCSBHQ",false);
        p_Player.EnableBuilding("UCSBSD",false);
        p_Player.EnableBuilding("UCSBSH",false);
        p_Player.EnableBuilding("UCSBTE",false);
        p_Player.EnableBuilding("UCSBEN1",false);
        p_Player.EnableBuilding("UCSBSS",false);
        p_Player.EnableBuilding("UCSBLZ",false);
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,1000);
        SetTimer(2,clicksPerDay*2);
        //----------- Variables --------------
        bCheckEndMission=false;
        bShowAc=true;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        EnableNextMission(1,true);
        AddBriefing("translateBriefing112");
        return Nothing,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Nothing
    { 
        return Nothing,600;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        int nTime;
        int nTimeDays;
        int nTimeHours;
        
        nTime = ((clicksPerDay*2) - GetMissionTime());
        
        if(nTime>=0)
        {
            nTimeDays = nTime / clicksPerDay;
            nTimeHours = (nTime % clicksPerDay)*24/clicksPerDay;
            RegisterGoal(defendFor20min,"translateGoal112",nTimeDays,nTimeHours);
            SetConsoleText("translateMessage112",nTimeDays,nTimeHours);
            if(nTime==0)SetConsoleText(" ");
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed112");
                EndMission(false);
            }
            if(bShowAc && !p_Enemy.GetNumberOfUnits() && !p_Enemy.GetNumberOfBuildings())
            {
                bShowAc=false;
                AddBriefing("translateAccomplished112");
                p_Player.SetMoney(p_Player.GetMoney()+5000);
                p_Player.EnableBuilding("UCSBLZ",true);
                EnableEndMissionButton(true);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli
    {
        if(GetDifficultyLevel()!=0)
            p_Enemy.RussianAttack(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),0);
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),20,50,2500,30,7); 
    }
    //-----------------------------------------------------------------------------------------
    event Timer2() //wolany co 20min = 20*60*20 = 1200*20 = 24000
    {
        if(bShowAc)
        {
            bShowAc=false;
            if(GetDifficultyLevel()!=0)
            {
                p_Enemy2.EnableAIFeatures(aiRush,true);
                p_Enemy2.EnableAIFeatures(aiControlOffense,true);
            }
            SetGoalState(defendFor20min,goalAchieved);
            AddBriefing("translateAccomplished112");
            p_Player.SetMoney(p_Player.GetMoney()+5000);
            p_Player.EnableBuilding("UCSBLZ",true);
            EnableEndMissionButton(true);
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
        p_Enemy2.SetEnemy(p_Enemy);
        p_Enemy.SetEnemy(p_Enemy2);
    }
}
