mission "translateMission261"
{//Kongo - destroy UCS base
    consts
    {
        destroyUCSBase = 0;
        destroyMMBase = 1;
    }
    player p_EnemyUCS;
    player p_EnemyMM;
    player p_Player;
    
    int bCheckEndMission;
    int bUCSunitDestroyed;
    
    
    state Initialize;
    state ShowBriefing;
    state Starting;
    state Fight;
    state Nothing;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(destroyUCSBase,"translateGoal261a");
        RegisterGoal(destroyMMBase,"translateGoal261b");
        EnableGoal(destroyUCSBase,true);           
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_EnemyUCS = GetPlayer(1);
        p_EnemyMM = GetPlayer(8);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            p_EnemyUCS.LoadScript("single\\singleEasy");
            p_EnemyUCS.EnableAIFeatures(aiUpgradeCannons,false);
            p_EnemyMM.LoadScript("single\\singleEasy");
            p_EnemyMM.EnableAIFeatures(aiUpgradeCannons,false);
            p_Player.SetMoney(30000);
            p_EnemyUCS.SetMoney(20000);
            p_EnemyMM.SetMoney(20000);
        }
        if(GetDifficultyLevel()==1)
        {
            p_EnemyUCS.LoadScript("single\\singleMedium");
            p_EnemyMM.LoadScript("single\\singleMedium");
            p_Player.SetMoney(20000);
            p_EnemyUCS.SetMoney(30000);
            p_EnemyMM.SetMoney(30000);
        }
        
        if(GetDifficultyLevel()==2)
        {
            p_EnemyUCS.LoadScript("single\\singleHard");
            p_EnemyMM.LoadScript("single\\singleHard");
            p_Player.SetMoney(15000);
            p_EnemyUCS.SetMoney(50000);
            p_EnemyMM.SetMoney(50000);
        }
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_EnemyMM.EnableAIFeatures(aiControlOffense,false);
        p_EnemyUCS.EnableAIFeatures(aiControlOffense,false);
        
        p_EnemyMM.EnableAIFeatures(aiRejectAlliance,false);
        p_Player.SetAlly(p_EnemyMM);
        p_EnemyMM.ChooseEnemy(p_EnemyUCS);
        //----------- Money ------------------
        //----------- Researches -------------
        p_Player.EnableResearch("RES_ED_UBT1",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,1200);
        //----------- Variables --------------
        bUCSunitDestroyed = false;
        bCheckEndMission=false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing261a");
        return Starting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Starting
    {
        if(bUCSunitDestroyed)
        {
            bUCSunitDestroyed=false;
            EnableGoal(destroyMMBase,true);           
            p_EnemyMM.SetEnemy(p_Player);
            p_Player.SetEnemy(p_EnemyMM);
            
            p_EnemyMM.SetNeutral(p_EnemyUCS);
            p_EnemyUCS.SetNeutral(p_EnemyMM);
            
            p_EnemyMM.EnableAIFeatures(aiControlOffense,true);
            p_EnemyUCS.EnableAIFeatures(aiControlOffense,true);
            AddBriefing("translateBriefing261b");
            return Fight,500;
        }
        return Starting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Fight
    {
        if(bCheckEndMission)
        {
            if(GetGoalState(destroyUCSBase)==goalAchieved &&
                GetGoalState(destroyMMBase)==goalAchieved)
            {
                AddBriefing("translateAccomplished261");
                p_EnemyMM.SetEnemy(p_EnemyUCS);
                p_EnemyUCS.SetEnemy(p_EnemyMM);
                p_EnemyMM.SetEnemy(p_Player);
                p_Player.SetEnemy(p_EnemyMM);
                EnableEndMissionButton(true);
                return Nothing,500;
            }
        }
        return Fight,100;
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
                AddBriefing("translateFailed261");
                p_EnemyMM.SetEnemy(p_EnemyUCS);
                p_EnemyUCS.SetEnemy(p_EnemyMM);
                p_EnemyMM.SetEnemy(p_Player);
                p_Player.SetEnemy(p_EnemyMM);
                EndMission(false);
            }
            if(GetGoalState(destroyUCSBase)!=goalAchieved &&
                !p_EnemyUCS.GetNumberOfBuildings() && 
                p_EnemyUCS.GetNumberOfUnits()<6)
            {
                SetGoalState(destroyUCSBase,goalAchieved);
            }
            
            if(GetGoalState(destroyMMBase)!=goalAchieved &&
                !p_EnemyMM.GetNumberOfBuildings() && 
                p_EnemyMM.GetNumberOfUnits()<6)
            {
                SetGoalState(destroyMMBase,goalAchieved);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 10min=600sec=12000 
    {
        bUCSunitDestroyed=true;
    }
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit u_Unit)
    {
        unit uAttacker;
        bCheckEndMission=true;
        uAttacker = u_Unit.GetAttacker();
        if(uAttacker==null) return;
        if(uAttacker.GetIFFNumber()!=p_Player.GetIFFNumber()) return;
        if(u_Unit.GetIFFNumber()==p_EnemyUCS.GetIFFNumber())
        {
            bUCSunitDestroyed=true;  
            return;
        }
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit u_Unit)
    { 
        unit uAttacker;
        bCheckEndMission=true;
        uAttacker = u_Unit.GetAttacker();
        if(uAttacker == null) return;
        if(uAttacker.GetIFFNumber()!=p_Player.GetIFFNumber()) return;
        if(u_Unit.GetIFFNumber()==p_EnemyUCS.GetIFFNumber())
        {
            bUCSunitDestroyed=true;  
            return;
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_EnemyMM.SetEnemy(p_Player);
        p_Player.SetEnemy(p_EnemyMM);
        
        p_EnemyMM.SetEnemy(p_EnemyUCS);
        p_EnemyUCS.SetEnemy(p_EnemyMM);
        p_EnemyMM.EnableAIFeatures(aiRejectAlliance,true);
    }
}
