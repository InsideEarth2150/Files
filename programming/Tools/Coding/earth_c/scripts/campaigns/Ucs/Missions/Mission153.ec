mission "translateMission153"
{//Egipt
    consts
    {
        destroyEDBase = 0;
        destroyLCBase = 1;
    }
    
    player p_Enemy;
    player p_Ally;
    player p_Player;
    
    int bNeoAttack;
    int bLCBreakAlliance;
    int maxPlatoons;
    
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(destroyEDBase,"translateGoal153a");
        RegisterGoal(destroyLCBase,"translateGoal153b");
        EnableGoal(destroyEDBase,true);           
        //----------- Temporary players ------
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        p_Enemy = GetPlayer(2);
        p_Ally = GetPlayer(3);
        //----------- AI ---------------------
        p_Ally.EnableAIFeatures(aiRejectAlliance,false);
        p_Player.SetAlly(p_Ally);
        
        
        p_Ally.ChooseEnemy(p_Enemy);
        p_Enemy.ChooseEnemy(p_Ally);
        p_Ally.SetEnemy(p_Enemy);
        p_Enemy.SetEnemy(p_Ally);
        
        p_Player.SetMilitaryUnitsLimit(30000);
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy.LoadScript("single\\singleEasy");
            p_Ally.LoadScript("single\\singleHard");
            maxPlatoons=2;
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.LoadScript("single\\singleMedium");
            p_Ally.LoadScript("single\\singleMedium");
            maxPlatoons=4;
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
            p_Ally.LoadScript("single\\singleEasy");
            maxPlatoons=7;
        }
        
        //----------- Money ------------------
        p_Player.SetMoney(20000);
        p_Enemy.SetMoney(40000);
        p_Ally.SetMoney(40000);
        //----------- Researches -------------
        p_Enemy.EnableResearch("RES_ED_AMR1",true);
        p_Enemy.EnableResearch("RES_ED_MHC2",true);
        p_Enemy.EnableResearch("RES_ED_UA41",true);
        
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,200);
        SetTimer(1,18000);//7 min XXXMD to wlaczyc
        //SetTimer(1,1800);//0.7 min
        //----------- Variables --------------
        bNeoAttack=true;
        bLCBreakAlliance=false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing153a");
        EnableNextMission(0,true);
        return Fighting,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(GetGoalState(destroyLCBase)!=goalAchieved &&
            p_Ally.GetNumberOfBuildings()<5)
        {
            SetGoalState(destroyLCBase,goalAchieved);
        }
        if(GetGoalState(destroyEDBase)!=goalAchieved &&
            p_Enemy.GetNumberOfBuildings()<5)
        {
            SetGoalState(destroyEDBase,goalAchieved);
        }
        if(GetGoalState(destroyEDBase)==goalAchieved &&
            GetGoalState(destroyLCBase)==goalAchieved)
        {
            SetGoalState(destroyEDBase,goalAchieved);
            AddBriefing("translateAccomplished153");
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
            AddBriefing("translateFailed153");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1()
    {
        if(bLCBreakAlliance)
        {
            p_Enemy.EnableAIFeatures(aiControlOffense,true);
            bLCBreakAlliance=false;
            p_Ally.SetEnemy(p_Player);
            p_Ally.ChooseEnemy(p_Player);
            p_Enemy.ChooseEnemy(p_Player);
            
            p_Player.SetEnemy(p_Ally);
            EnableGoal(destroyLCBase,true);           
            AddBriefing("translateBriefing153c");
        }
        if(bNeoAttack)
        {
            bNeoAttack=false;
            bLCBreakAlliance=true;
            AddBriefing("translateBriefing153b");
            p_Enemy.SetNumberOfOffensiveTankPlatoons(maxPlatoons);
            p_Player.GiveAllUnitsTo(p_Enemy);
            p_Enemy.RussianAttack(p_Ally.GetStartingPointX(),p_Ally.GetStartingPointY(),0);
            p_Enemy.EnableAIFeatures(aiControlOffense,false);
            SetTimer(1,6000);
        }
    }
}
