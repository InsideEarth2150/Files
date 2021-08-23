mission "translateMission244"
{//Evacuate Ion cannon prototype
    consts
    {
        evacuatePrototype = 0;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Neutral;
    player p_Player;
    unitex p_Prototype;
    
    int n_EvacuatePointX;
    int n_EvacuatePointY;
    
    state Initialize;
    state ShowVideoState;
    state ShowBriefing;
    state EvacuatePrototype;
    state Final;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        tmpPlayer.EnableAIFeatures(aiEnabled,false);
        
        tmpPlayer = GetPlayer(4); 
        tmpPlayer.EnableStatistics(false);
        tmpPlayer.EnableAIFeatures(aiEnabled,false);
        
        RegisterGoal(evacuatePrototype,"translateGoal244");
        EnableGoal(evacuatePrototype,true);               
        
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(3);
        p_Neutral = GetPlayer(8);
        
        p_Prototype = GetUnit(GetPointX(0),GetPointY(0),1);
        
        p_Neutral.EnableStatistics(false);
        
        p_Player.SetMoney(0);
        p_Enemy1.SetMoney(30000);
        p_Enemy2.SetMoney(0);
        
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        
        
        if(GetDifficultyLevel()==0)
            p_Enemy1.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy1.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy1.LoadScript("single\\singleHard");
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy1.EnableAIFeatures(aiControlDefense,false);
        p_Enemy2.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        
        p_Player.EnableResearch("RES_ED_WHC1",true);
        p_Player.EnableResearch("RES_ED_WHL1",true);
        p_Player.EnableResearch("RES_MMR2",true);
        p_Player.EnableResearch("RES_MSR2",true);
        p_Player.EnableResearch("RES_ED_UHT1",true);
        p_Player.EnableResearch("RES_ED_UHS1",true);
        p_Player.EnableResearch("RES_ED_UMI1",true);
        p_Player.EnableResearch("RES_ED_UMW1",true);
        p_Player.EnableResearch("RES_ED_RepHand2",true);
        
        p_Enemy1.EnableResearch("RES_UCS_WHP1",true);
        p_Enemy1.EnableResearch("RES_UCS_WMR1",true);
        p_Enemy1.EnableResearch("RES_UCS_WHG1",true);
        p_Enemy1.EnableResearch("RES_UCS_SGEN",true);
        p_Enemy1.EnableResearch("RES_UCS_UBS1",true);
        p_Enemy1.EnableResearch("RES_UCS_USM1",true);
        p_Enemy1.EnableResearch("RES_UCS_UAH1",true);
        
        
        n_EvacuatePointX = p_Neutral.GetStartingPointX();
        n_EvacuatePointY = p_Neutral.GetStartingPointY();
        
        SetTimer(0,100);
        
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,1);
        return ShowVideoState,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowVideoState
    {
        ShowVideo("CS212");
        return ShowBriefing,20;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        EnableNextMission(1,true);
        AddBriefing("translateBriefing244");
        return EvacuatePrototype,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state EvacuatePrototype
    {
        if(Distance(p_Prototype.GetLocationX(),p_Prototype.GetLocationY(),n_EvacuatePointX,n_EvacuatePointY) < 5)
        {
            SetGoalState(evacuatePrototype, goalAchieved);
            p_Enemy1.EnableAIFeatures(aiControlOffense,true);
            p_Enemy1.EnableAIFeatures(aiControlDefense,true);
            
            p_Neutral.GiveAllUnitsTo(p_Player);
            p_Neutral.GiveAllBuildingsTo(p_Player);
            p_Player.EnableResearch("RES_ED_WSI1",true);
            AddBriefing("translateAccomplished244");
            p_Neutral.SetEnemy(p_Player);
            p_Player.SetEnemy(p_Neutral);
            EnableEndMissionButton(true);
            return Final,100;
        }
        return EvacuatePrototype,50;
    }
    //-----------------------------------------------------------------------------------------
    state Final
    {
        return Final,500;
    }
    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(!p_Prototype.IsLive())
        {
            AddBriefing("translateFailed244");
            p_Neutral.SetEnemy(p_Player);
            p_Player.SetEnemy(p_Neutral);
            EndMission(false);
        }
    }
}
