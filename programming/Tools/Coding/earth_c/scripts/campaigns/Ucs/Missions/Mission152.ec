mission "translateMission152"
{//Australia
    consts
    {
        destroyEDForces = 0;
    }
    
    player p_Enemy;
    player p_Player;
    
    int bNeoFirstAttack;
    int bNeoSecondAttack;
    
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(destroyEDForces,"translateGoal152");
        EnableGoal(destroyEDForces,true);           
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        p_Enemy = GetPlayer(2);
        //----------- AI ---------------------
        p_Player.SetMilitaryUnitsLimit(30000);
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
        }
        
        //----------- Money ------------------
        p_Player.SetMoney(20000);
        p_Enemy.SetMoney(40000);
        //----------- Researches -------------
        p_Player.EnableResearch("RES_UCS_WAMR1",true);
        p_Player.EnableResearch("RES_UCS_BOMBER21",true);
        
        p_Enemy.EnableResearch("RES_ED_AMR1",true);
        p_Enemy.EnableResearch("RES_ED_MHC2",true);
        p_Enemy.EnableResearch("RES_ED_UA41",true);
        
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,200);
        SetTimer(1,18000);//7 min
        //----------- Variables --------------
        bNeoFirstAttack=true;
        bNeoSecondAttack=false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing152a");
        EnableNextMission(0,true);
        return Fighting,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(!p_Enemy.GetNumberOfUnits() && !p_Enemy.GetNumberOfBuildings())
        {
            bNeoSecondAttack=false;
            bNeoFirstAttack=false;
            SetGoalState(destroyEDForces,goalAchieved);
            AddBriefing("translateAccomplished152");
            EnableEndMissionButton(true);
            return Evacuate,500;
        }
        return Fighting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        return Evacuate,500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0()
    {
        if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed152");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1()
    {
        if(bNeoSecondAttack)
        {
            bNeoSecondAttack=false;
            AddBriefing("translateBriefing152c");
            p_Player.GiveAllUnitsTo(p_Enemy);
        }
        if(bNeoFirstAttack)
        {
            bNeoFirstAttack=false;
            bNeoSecondAttack=true;
            AddBriefing("translateBriefing152b");
            p_Player.GiveAllUnitsTo(p_Enemy);
        }
    }
}
