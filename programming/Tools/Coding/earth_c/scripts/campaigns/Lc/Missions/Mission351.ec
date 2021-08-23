mission "translateMission351"
{//Mozambik kill Neo - tylko LC poniewaz UCS sie boi
    consts
    {
        destroyEDBase = 0;
        destroyNeoHome = 1;
    }
    
    player pEnemy;
    player pPlayer;
    
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
        RegisterGoal(destroyEDBase,"translateGoal351a");
        RegisterGoal(destroyNeoHome,"translateGoal351b");
        EnableGoal(destroyEDBase,true);           
        EnableGoal(destroyNeoHome,true);
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy = GetPlayer(2);
        //----------- AI ---------------------
        pPlayer.SetMilitaryUnitsLimit(40000);
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
        {
            pEnemy.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            pEnemy.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            pEnemy.LoadScript("single\\singleHard");
        }
        
        //----------- Money ------------------
        pPlayer.SetMoney(20000);
        pEnemy.SetMoney(170000);
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WHL1",true);
        pPlayer.EnableResearch("RES_MMR3",true);
        pPlayer.EnableResearch("RES_LC_REG2",true);
        
        
        pEnemy.EnableResearch("RES_ED_WHC1",true);
        pEnemy.EnableResearch("RES_ED_UA31",true);
        pEnemy.EnableResearch("RES_ED_UMI1",true);
        pEnemy.EnableResearch("RES_ED_SCR",true);
        
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
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing351",pPlayer.GetName());
        EnableNextMission(0,true);
        return Fighting,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(GetGoalState(destroyEDBase)==goalAchieved &&
            GetGoalState(destroyNeoHome)==goalAchieved)
        {
            AddBriefing("translateAccomplished351a",pPlayer.GetName());
            EnableEndMissionButton(true);
            return Evacuate,500;
        }
        
        if(GetGoalState(destroyNeoHome)!=goalAchieved && !uNeoHome.IsLive())
        {
            SetGoalState(destroyNeoHome,goalAchieved);
            AddBriefing("translateAccomplished351b",pPlayer.GetName());
        }
        
        if(GetGoalState(destroyEDBase)!=goalAchieved &&
            !pEnemy.GetNumberOfBuildings())
        {
            SetGoalState(destroyEDBase,goalAchieved);
        }
        return Fighting,200;
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        return Evacuate,500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0()
    {
        if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
        {
            AddBriefing("translateFailedNoUnits",pPlayer.GetName());
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
}
