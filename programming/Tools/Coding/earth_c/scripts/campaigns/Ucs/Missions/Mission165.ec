mission "translateMission165"
{
    consts
    {
        sendToBase = 0;
        
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Player;
    int bShitchOnAI;
    int nNeedeResources;
    int fleetCost;
    int bShowFailed;  
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Mining;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        p_Player = GetPlayer(1);
        fleetCost = p_Player.GetScriptData(0);
        nNeedeResources = fleetCost - p_Player.GetMoneySentToOrbit();
        if(nNeedeResources > 100000)
            nNeedeResources=100000;
        
        RegisterGoal(sendToBase,"translateGoal165",nNeedeResources,0);
        EnableGoal(sendToBase,true);
        //----------- Temporary players ------
        //----------- Players ----------------
        
        p_Enemy1 = GetPlayer(2);
        p_Enemy2 = GetPlayer(3);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
        }
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiEnabled,true);
        p_Enemy2.EnableAIFeatures(aiEnabled,true);
        //----------- Money ------------------
        p_Player.SetMoney(10000);
        p_Enemy1.SetMoney(50000);
        p_Enemy2.SetMoney(50000);
        //----------- Researches -------------
        
        p_Enemy1.EnableResearch("RES_ED_WHR1",true);
        p_Enemy1.EnableResearch("RES_ED_AB1",true);
        p_Enemy1.EnableResearch("RES_ED_MB2",true);
        p_Enemy1.EnableResearch("RES_ED_MHR2",true);
        p_Enemy1.EnableResearch("RES_ED_UA31",true);
        
        p_Player.EnableResearch("RES_UCS_PC",true);
        p_Player.EnableResearch("RES_UCS_WSD",true);
        p_Player.EnableResearch("RES_UCS_WAPB1",true);
        p_Player.EnableResearch("RES_UCS_MB2",true);
        p_Player.EnableResearch("RES_UCS_BOMBER31",true);
        
        p_Enemy2.EnableResearch("RES_LC_WARTILLERY",true);
        p_Enemy2.EnableResearch("RES_LC_UCU1",true);
        
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bShowFailed=true;
        bCheckEndMission=false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        EnableNextMission(1,true);
        AddBriefing("translateBriefing165",nNeedeResources);
        return Mining,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(GetGoalState(sendToBase)!=goalAchieved && p_Player.GetMoneySentToBase()>=nNeedeResources)
        {
            SetGoalState(sendToBase, goalAchieved);
            AddBriefing("translateAccomplished165");
            EnableEndMissionButton(true);
            return Nothing, 500;
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
        RegisterGoal(sendToBase,"translateGoal165",nNeedeResources,p_Player.GetMoneySentToBase());
        
        if(bShowFailed)
        {
            if((ResourcesLeftInMoney()+p_Player.GetMoneySentToBase()+p_Player.GetMoney())<nNeedeResources)
            {
                bShowFailed=false;
                SetGoalState(sendToBase, goalFailed);
                AddBriefing("translateFailed165a");
                EnableEndMissionButton(true);
                return Nothing;
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed165b");
                EndMission(false);
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

