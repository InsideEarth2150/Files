mission "translateMission144"
{//Australia
    consts
    {
        destroyEDBase = 0;
    }
    
    player p_Enemy;
    player p_Ally;
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
        //----------- Goals ------------------
        RegisterGoal(destroyEDBase,"translateGoal144");
        EnableGoal(destroyEDBase,true);           
        //----------- Temporary players ------
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        p_Enemy = GetPlayer(2);
        p_Ally = GetPlayer(3);
        //----------- AI ---------------------
        
        p_Player.SetMilitaryUnitsLimit(30000);
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy.LoadScript("single\\singleEasy");
            p_Ally.LoadScript("single\\singleHard");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.LoadScript("single\\singleMedium");
            p_Ally.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
            p_Ally.LoadScript("single\\singleEasy");
        }
        
        p_Ally.EnableAIFeatures(aiRejectAlliance,false);
        p_Player.SetAlly(p_Ally);
        p_Ally.ChooseEnemy(p_Enemy);
        p_Ally.SetEnemy(p_Enemy);
        p_Enemy.SetEnemy(p_Ally);
        
        
        //----------- Money ------------------
        p_Player.SetMoney(20000);
        p_Enemy.SetMoney(30000);
        p_Ally.SetMoney(30000);
        //----------- Researches -------------
        p_Enemy.EnableResearch("RES_ED_WSI1",true);
        p_Enemy.EnableResearch("RES_MMR2",true);
        p_Enemy.EnableResearch("RES_ED_UHT1",true);
        p_Enemy.EnableResearch("RES_ED_UHS1",true);
        
        p_Player.EnableResearch("RES_UCS_WAMR1",true);
        p_Player.EnableResearch("RES_UCS_BOMBER21",true);
        
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
        AddBriefing("translateBriefing144a");
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
            
            p_Player.SetAlly(p_Ally);
            p_Ally.EnableAIFeatures(aiControlOffense,false);
            
            SetGoalState(destroyEDBase,goalAchieved);
            AddBriefing("translateAccomplished144");
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
            AddBriefing("translateFailed144");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1()
    {
        if(bNeoSecondAttack)
        {
            bNeoSecondAttack=false;
            //      AddBriefing("translateBriefing144c");
            //      p_Player.GiveAllUnitsTo(p_Enemy);
        }
        if(bNeoFirstAttack)
        {
            bNeoFirstAttack=false;
            bNeoSecondAttack=true;
            AddBriefing("translateBriefing144b");
            p_Player.GiveAllUnitsTo(p_Enemy);
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_Ally.EnableAIFeatures(aiRejectAlliance,true);
        p_Player.SetEnemy(p_Ally);
        p_Ally.SetEnemy(p_Player);
    }
}
