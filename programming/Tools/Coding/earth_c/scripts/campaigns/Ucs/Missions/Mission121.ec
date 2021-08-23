mission "translateMission121"
{//Baikal - zniszczyc centrum naukowe ED
    consts
    {
        establishCommunication = 0;
        destroyEDBase = 1;
    }
    
    player p_Enemy;
    player p_Player;
    player p_Mechs;
    player p_ED2;
    
    int bShowFailed;    
    int bCheckEndMission;
    int bShowVideo;
    
    state Initialize;
    state ShowBriefing;
    state StartLaser;
    state EnableMechs;
    state EnableAI;
    state Fighting;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(establishCommunication,"translateGoal121a");
        RegisterGoal(destroyEDBase,"translateGoal121b");
        EnableGoal(establishCommunication,true);
        EnableGoal(destroyEDBase,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        p_Enemy = GetPlayer(2);
        p_Mechs = GetPlayer(4);
        p_ED2 = GetPlayer(8);
        //----------- AI ---------------------
        p_Mechs.EnableStatistics(false);
        p_ED2.EnableStatistics(false);
        
        p_Mechs.SetNeutral(p_Enemy);
        p_Mechs.SetNeutral(p_ED2);
        p_Enemy.SetNeutral(p_Mechs);
        p_Enemy.SetNeutral(p_ED2);
        p_ED2.SetNeutral(p_Mechs);
        
        if(GetDifficultyLevel()==0)
            p_Enemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy.LoadScript("single\\singleHard");
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy.EnableAIFeatures(aiEnabled,true);
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        p_Mechs.EnableAIFeatures(aiEnabled,false);
        p_ED2.EnableAIFeatures(aiEnabled,false);
        
        p_Mechs.EnableAIFeatures(aiRejectAlliance,false);
        p_Player.SetAlly(p_Mechs);
        p_Player.SetMilitaryUnitsLimit(15000);
        //----------- Money ------------------
        p_Player.SetMoney(10000);
        p_Enemy.SetMoney(30000);
        //----------- Researches -------------
        p_Enemy.EnableResearch("RES_ED_WSL1",true);
        p_Enemy.EnableResearch("RES_ED_UA21",true);
        p_Enemy.EnableResearch("RES_ED_UMW1",true);
        
        p_Player.EnableResearch("RES_UCS_WASR1",true);
        p_Player.EnableResearch("RES_UCS_UOH2",true);
        p_Player.EnableResearch("RES_UCS_UML1",true);
        p_Player.EnableResearch("RES_UCS_RepHand",true);
        //----------- Buildings --------------
        p_Player.EnableBuilding("UCSBTE",false);
        p_Player.EnableBuilding("UCSBEN1",false);
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,6000);
        //----------- Variables --------------
        bShowFailed = true;
        bCheckEndMission = false;
        bShowVideo=true;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing121");
        EnableNextMission(0,true);
        return StartLaser,1200;
    }
    //-----------------------------------------------------------------------------------------
    state StartLaser
    {
        p_Enemy.SetEnemy(p_Mechs);
        return EnableMechs,400;
    }
    //-----------------------------------------------------------------------------------------
    state EnableMechs
    {
        SetGoalState(establishCommunication,goalAchieved);
        p_Player.DelayedLookAt(p_Mechs.GetStartingPointX(),p_Mechs.GetStartingPointY(),6,0,15,0,60,1);
        p_Mechs.GiveAllUnitsTo(p_Player);
        p_ED2.GiveAllUnitsTo(p_Enemy);
        p_ED2.GiveAllBuildingsTo(p_Enemy);
        p_Enemy.RussianAttack(p_Enemy.GetStartingPointX(),p_Enemy.GetStartingPointY(),0);
        return EnableAI,6000;
    }
    //-----------------------------------------------------------------------------------------
    state EnableAI
    {
        p_Enemy.EnableAIFeatures(aiControlOffense,true);   
        return Fighting,200;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        return Fighting,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        
        if(bShowVideo)
        {
            ShowVideo("CS111");
            bShowVideo=false;
        }
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed121");
                EndMission(false);
            }
            if(GetGoalState(destroyEDBase)!=goalAchieved &&
                !p_Enemy.GetNumberOfUnits() && !p_Enemy.GetNumberOfBuildings())
            {
                SetGoalState(destroyEDBase,goalAchieved);
                AddBriefing("translateAccomplished121");
                EnableEndMissionButton(true);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli 5min
    {
        Rain(p_Player.GetStartingPointX(),p_Player.GetStartingPointY()-10,30,400,5000,800,10); 
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
        p_Mechs.SetEnemy(p_Enemy);
        p_Mechs.SetEnemy(p_ED2);
        p_Enemy.SetEnemy(p_Mechs);
        p_ED2.SetEnemy(p_Mechs);
    }
}

