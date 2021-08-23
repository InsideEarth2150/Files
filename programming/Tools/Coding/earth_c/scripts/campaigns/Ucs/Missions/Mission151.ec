mission "translateMission151"
{//Mozambik kill Neo
    consts
    {
        destroyEDBase = 0;
        destroyNeoHome = 1;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Player;
    
    unitex uNeoHome;
    
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
        RegisterGoal(destroyEDBase,"translateGoal151a");
        RegisterGoal(destroyNeoHome,"translateGoal151b");
        EnableGoal(destroyEDBase,true);           
        EnableGoal(destroyNeoHome,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(1);
        p_Enemy1 = GetPlayer(2);
        p_Enemy2 = GetPlayer(8);
        //----------- AI ---------------------
        p_Player.SetMilitaryUnitsLimit(40000);
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleHard");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleEasy");
        }
        
        //----------- Money ------------------
        p_Player.SetMoney(20000);
        p_Enemy1.SetMoney(30000);
        p_Enemy2.SetMoney(30000);
        //----------- Researches -------------
        p_Player.EnableResearch("RES_UCS_UBL1",true);
        p_Player.EnableResearch("RES_UCS_UAH3",true);
        p_Player.EnableResearch("RES_UCS_SHD",true);
        
        p_Enemy1.EnableResearch("RES_ED_WHC2",true);
        p_Enemy1.EnableResearch("RES_ED_UBT1",true);
        p_Enemy1.EnableResearch("RES_ED_SCR",true);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        //----------- Buildings --------------
        //----------- Units ------------------
        uNeoHome=GetUnit(GetPointX(0),GetPointY(0),0);
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
        AddBriefing("translateBriefing151a");
        EnableNextMission(0,true);
        return Fighting,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(GetGoalState(destroyEDBase)==goalAchieved &&
            GetGoalState(destroyNeoHome)== goalAchieved)
        {
            AddBriefing("translateAccomplished151c");
            EnableEndMissionButton(true);
            return Evacuate,500;
        }
        
        if(GetGoalState(destroyNeoHome)!=goalAchieved && !uNeoHome.IsLive())
        {
            bNeoSecondAttack=false;
            bNeoFirstAttack=false;
            SetGoalState(destroyNeoHome,goalAchieved);
            AddBriefing("translateAccomplished151b");
        }
        
        if(GetGoalState(destroyEDBase)!=goalAchieved &&
            !p_Enemy1.GetNumberOfUnits() && !p_Enemy1.GetNumberOfBuildings() &&
            !p_Enemy2.GetNumberOfUnits() && !p_Enemy2.GetNumberOfBuildings())
        {
            SetGoalState(destroyEDBase,goalAchieved);
            AddBriefing("translateAccomplished151a");
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
            AddBriefing("translateFailed151");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1()
    {
        if(uNeoHome.IsLive())
        {
            if(bNeoSecondAttack)
            {
                bNeoSecondAttack=false;
                AddBriefing("translateBriefing151c");
                p_Player.GiveAllUnitsTo(p_Enemy1);
            }
            if(bNeoFirstAttack)
            {
                bNeoFirstAttack=false;
                bNeoSecondAttack=true;
                AddBriefing("translateBriefing151b");
                p_Player.GiveAllUnitsTo(p_Enemy1);
            }
        }
    }
}
