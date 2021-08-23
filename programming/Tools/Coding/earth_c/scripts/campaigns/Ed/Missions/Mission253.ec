mission "translateMission253"
{//Egipt -  destroy UCS base (and LC)
    consts
    {
        destroyUCSBase = 0;
        destroyLCBase = 1;
    }
    player p_EnemyUCS;
    player p_EnemyLC;
    player p_Player;
    
    int bCheckEndMission;
    int bLCunitDestroyed;
    int bUCSunitDestroyed;
    
    state Initialize;
    state ShowBriefing;
    state Searching;
    state LCAllied;
    state UCSFight;
    state FinalFight;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        RegisterGoal(destroyUCSBase,"translateGoal253a");
        RegisterGoal(destroyLCBase,"translateGoal253b");
        EnableGoal(destroyUCSBase,true);           
        
        
        p_Player = GetPlayer(2);
        p_EnemyUCS = GetPlayer(1);
        p_EnemyLC = GetPlayer(3);
        
        
        if(GetDifficultyLevel()==0)
        {
            p_EnemyUCS.LoadScript("single\\singleEasy");
            p_EnemyUCS.EnableAIFeatures(aiUpgradeCannons,false);
            p_EnemyLC.LoadScript("single\\singleEasy");
            p_EnemyLC.EnableAIFeatures(aiUpgradeCannons,false);
            p_Player.SetMoney(30000);
            p_EnemyUCS.SetMoney(20000);
            p_EnemyLC.SetMoney(20000);
        }
        if(GetDifficultyLevel()==1)
        {
            p_EnemyUCS.LoadScript("single\\singleMedium");
            p_EnemyLC.LoadScript("single\\singleMedium");
            p_Player.SetMoney(20000);
            p_EnemyUCS.SetMoney(40000);
            p_EnemyLC.SetMoney(40000);
        }
        
        if(GetDifficultyLevel()==2)
        {
            p_EnemyUCS.LoadScript("single\\singleHard");
            p_EnemyLC.LoadScript("single\\singleHard");
            p_Player.SetMoney(15000);
            p_EnemyUCS.SetMoney(50000);
            p_EnemyLC.SetMoney(50000);
        }
        
        p_EnemyLC.SetName("Alia Tiosh");
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_EnemyLC.EnableAIFeatures(aiControlOffense,false);
        p_EnemyUCS.EnableAIFeatures(aiControlOffense,false);
        
        p_Player.EnableResearch("RES_ED_WHC2",true);
        
        p_EnemyUCS.EnableResearch("RES_UCS_UBL1",true);
        p_EnemyUCS.EnableResearch("RES_UCS_BOMBER21",true);
        
        p_EnemyLC.EnableResearch("RES_LC_WHL1",true);
        p_EnemyLC.EnableResearch("RES_LC_WHS1",true);
        p_EnemyLC.EnableResearch("RES_LC_WARTILLERY",true);
        p_EnemyLC.EnableResearch("RES_MMR2",true);
        
        
        bLCunitDestroyed = false;
        bUCSunitDestroyed = false;
        
        SetTimer(0,100);
        
        bCheckEndMission=false;
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        ShowArea(4,GetPointX(0),GetPointY(0),0,4);
        p_Player.SetMilitaryUnitsLimit(30000);  
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(2,true);
        AddBriefing("translateBriefing253a");
        return Searching,100;
    }
    //-----------------------------------------------------------------------------------------
    state Searching
    {
        if(bLCunitDestroyed)
        {
            bLCunitDestroyed=false;
            AddBriefing("translateBriefing253e");
            EnableGoal(destroyLCBase,true);           
            p_EnemyLC.EnableAIFeatures(aiControlOffense,true);
            p_EnemyUCS.EnableAIFeatures(aiControlOffense,true);
            return FinalFight,500;
        }
        
        if(bUCSunitDestroyed)
        {
            bUCSunitDestroyed=false;
            p_EnemyLC.EnableAIFeatures(aiRejectAlliance,false);
            p_Player.SetAlly(p_EnemyLC);
            p_EnemyLC.ChooseEnemy(p_EnemyUCS);
            p_EnemyLC.SetEnemy(p_EnemyUCS);
            p_EnemyUCS.SetEnemy(p_EnemyLC);
            p_EnemyLC.EnableAIFeatures(aiControlOffense,true);
            p_EnemyUCS.EnableAIFeatures(aiControlOffense,true);
            AddBriefing("translateBriefing253b");
            return LCAllied,200;
        }
        return Searching,100;
    }
    //-----------------------------------------------------------------------------------------
    state LCAllied
    {
        if(bLCunitDestroyed)
        {
            bLCunitDestroyed=false;
            AddBriefing("translateBriefing253c");
            EnableGoal(destroyLCBase,true);  
            p_EnemyLC.SetEnemy(p_Player);
            p_Player.SetEnemy(p_EnemyLC);
            p_EnemyLC.ChooseEnemy(p_Player);
            return FinalFight,500;
        }
        
        if(GetGoalState(destroyUCSBase)==goalAchieved)
        {
            AddBriefing("translateBriefing253d");
            bLCunitDestroyed = true;
            return LCAllied,400;
        }
        
        if(GetGoalState(destroyLCBase)==goalAchieved)
        {
            return UCSFight,200;
        }
        return LCAllied,200;
    }
    //-----------------------------------------------------------------------------------------
    state UCSFight
    {
        if(GetGoalState(destroyUCSBase)==goalAchieved)
        {
            EnableNextMission(0,true);
            EnableNextMission(1,true);
            AddBriefing("translateAccomplished253b");
            EnableEndMissionButton(true);
            return Nothing,500;
        }
        return UCSFight,200;
    }
    //-----------------------------------------------------------------------------------------
    state FinalFight
    {
        if(GetGoalState(destroyUCSBase)==goalAchieved &&
            GetGoalState(destroyLCBase)==goalAchieved)
        {
            EnableNextMission(0,true);
            EnableNextMission(1,true);
            AddBriefing("translateAccomplished253a");
            EnableEndMissionButton(true);
            return Nothing,500;
        }
        return FinalFight,100;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    { 
        return Nothing,512;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed254");
                EndMission(false);
            }
            if(GetGoalState(destroyUCSBase)!=goalAchieved &&
                !p_EnemyUCS.GetNumberOfBuildings() && 
                p_EnemyUCS.GetNumberOfUnits()<6)
            {
                SetGoalState(destroyUCSBase,goalAchieved);
            }
            
            if(GetGoalState(destroyLCBase)!=goalAchieved &&
                !p_EnemyLC.GetNumberOfBuildings() && 
                p_EnemyLC.GetNumberOfUnits()<6)
            {
                SetGoalState(destroyLCBase,goalAchieved);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit u_Unit)
    {
        unit pAttacker;
        bCheckEndMission=true;
        pAttacker = u_Unit.GetAttacker();
        if(pAttacker==null) return;
        if(pAttacker.GetIFFNumber()!=p_Player.GetIFFNumber()) return;
        if(u_Unit.GetIFFNumber()==p_EnemyLC.GetIFFNumber())
        {
            bLCunitDestroyed=true;  
            return;
        }
        if(u_Unit.GetIFFNumber()==p_EnemyUCS.GetIFFNumber())
            bUCSunitDestroyed=true;
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit u_Unit)
    { 
        unit uAttacker;
        bCheckEndMission=true;
        uAttacker = u_Unit.GetAttacker();
        if(uAttacker==null) return;
        if(uAttacker.GetIFFNumber()!=p_Player.GetIFFNumber()) 
        {
            return;
        }
        if(u_Unit.GetIFFNumber()==p_EnemyLC.GetIFFNumber())
        {
            bLCunitDestroyed=true;  
            return;
        }
        if(u_Unit.GetIFFNumber()==p_EnemyUCS.GetIFFNumber())
            bUCSunitDestroyed=true;
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_EnemyLC.SetEnemy(p_Player);
        p_Player.SetEnemy(p_EnemyLC);
        p_EnemyLC.EnableAIFeatures(aiRejectAlliance,true);
    }
}
