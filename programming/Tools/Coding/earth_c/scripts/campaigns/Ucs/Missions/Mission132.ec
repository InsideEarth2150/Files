mission "translateMission132"
{//uwolnic Grizzlich
    consts
    {
        enablePrototypes = 0;
        destroyEnemyBase = 1;
    }
    
    player p_Enemy;
    player p_Neutral1; // landing zone
    player p_Neutral2; // grizzli
    player p_Player;
    
    int bCheckEndMission;
    int bEnableLZ;
    
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        int nEnemyMoney;
        player tmpPlayer;
        
        //-----------goals-----------------
        RegisterGoal(enablePrototypes,"translateGoal132a");
        RegisterGoal(destroyEnemyBase,"translateGoal132b");
        EnableGoal(enablePrototypes,true);
        //-----------temporary players-----------------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        //-----------players-----------------
        p_Player = GetPlayer(1);
        p_Enemy = GetPlayer(2);
        p_Neutral1 = GetPlayer(6);
        p_Neutral2 = GetPlayer(8);
        //-----------AI-----------------
        p_Neutral1.EnableStatistics(false);
        p_Neutral2.EnableStatistics(false);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy.LoadScript("single\\singleEasy");
            p_Enemy.EnableAIFeatures(aiControlOffense,false);
            nEnemyMoney=10000;
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.LoadScript("single\\singleMedium");
            p_Enemy.EnableAIFeatures(aiControlOffense,false);
            nEnemyMoney=20000;
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
            nEnemyMoney=30000;
        }
        
        
        p_Neutral1.EnableAIFeatures(aiEnabled,false);
        p_Neutral2.EnableAIFeatures(aiEnabled,false);
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        p_Neutral1.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral1);
        p_Neutral2.SetNeutral(p_Enemy);
        p_Neutral2.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral2);
        p_Enemy.SetNeutral(p_Neutral2);
        //-----------money-----------------
        p_Player.SetMoney(0);
        p_Enemy.SetMoney(nEnemyMoney);
        //-----------researches-----------------
        p_Enemy.EnableResearch("RES_ED_WMR1",true);
        p_Enemy.EnableResearch("RES_MSR2",true);    
        p_Enemy.EnableResearch("RES_ED_UHW1",true);
        p_Enemy.EnableResearch("RES_ED_BHD",true);
        
        p_Player.EnableResearch("RES_UCS_WHG1",true);
        p_Player.EnableResearch("RES_UCS_UHL1",true);
        p_Player.EnableResearch("RES_UCS_BHD",true);
        //-----------buildings----------------
        if(p_Player.GetScriptData(5)!=12)
            p_Player.EnableBuilding("UCSBTE",false);
        //-----------units-----------------
        //-----------Artefacts----------------
        CreateArtefact("NEASPECIAL1",GetPointX(0),GetPointY(0),1,0,artefactSpecialAIOther);
        //-----------Timers----------------
        SetTimer(0,100);
        //-----------variables------------
        bCheckEndMission=false;
        bEnableLZ=true;
        //-----------camera----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,150;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing132a");
        Rain(p_Player.GetStartingPointX(),p_Player.GetStartingPointY()-20,30,400,5000,800,5); 
        return Fighting,600;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(IsGoalEnabled(destroyEnemyBase) &&
            !p_Enemy.GetNumberOfBuildings())
        {
            SetGoalState(destroyEnemyBase,goalAchieved);
            AddBriefing("translateAccomplished123");
            EnableEndMissionButton(true);
            p_Neutral1.GiveAllBuildingsTo(p_Player);
            return Nothing,100;
        }
        return Fighting,200;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
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
                AddBriefing("translateFailed132");
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
        if(bEnableLZ)
        {
            bEnableLZ=false;
            p_Neutral1.GiveAllBuildingsTo(p_Player);//uwaga destroyed przychodzi tez gdy budynek jest konwertowany.
        }
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_Neutral1.SetEnemy(p_Player);
        p_Player.SetEnemy(p_Neutral1);
        p_Neutral2.SetEnemy(p_Enemy);
        p_Enemy.SetEnemy(p_Neutral2);
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        SetGoalState(enablePrototypes,goalAchieved);
        p_Neutral2.GiveAllUnitsTo(p_Player);
        EnableGoal(destroyEnemyBase,true);
        AddBriefing("translateBriefing132b");
        return true; //usuwa sie 
    }
    
}

