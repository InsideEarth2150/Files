mission "translateMission215"
{//Projekt LASER - siberia
    consts
    {
        evacuateBase = 0;
        build3ResCent = 1;
        evacuatePrototype = 2;
    }
    
    player p_Enemy;
    player p_Player;
    player p_Neutral;
    player p_Neutral2;
    unitex p_Prototype;
    unitex p_Builder;
    
    int n_EvacuatePointX;
    int n_EvacuatePointY;
    int bCheckEndMission;
    int nAttackCounter;
    
    state Initialize;
    state ShowBriefing;
    state EvacuateBase;
    state BuildUpBase;
    state EvacuatePrototype;
    state Final;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(1); 
        tmpPlayer.EnableStatistics(false);
        
        RegisterGoal(evacuateBase,"translateGoal215a");
        RegisterGoal(build3ResCent,"translateGoal215b");
        RegisterGoal(evacuatePrototype,"translateGoal215c");
        EnableGoal(evacuateBase,true);               
        
        p_Player = GetPlayer(2);
        p_Enemy = GetPlayer(3);
        p_Neutral = GetPlayer(4);
        p_Neutral2 = GetPlayer(8);
        p_Neutral.EnableStatistics(false);
        p_Neutral2.EnableStatistics(false);
        
        p_Prototype = GetUnit(GetPointX(1),GetPointY(1),1);
        p_Builder = GetUnit(GetPointX(2),GetPointY(2),0);
        
        p_Player.SetMoney(0);
        p_Enemy.SetMoney(30000);
        
        p_Enemy.SetNeutral(p_Neutral);
        p_Player.SetNeutral(p_Neutral);
        p_Player.SetNeutral(p_Neutral2);
        p_Neutral.SetNeutral(p_Player);
        p_Neutral2.SetNeutral(p_Player);
        p_Enemy.SetEnemy(p_Neutral2);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        
        
        if(GetDifficultyLevel()==0)
            p_Enemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy.LoadScript("single\\singleHard");
        
        p_Enemy.EnableAIFeatures(aiControlDefense,false);
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        p_Enemy.RussianAttack(GetPointX(2),GetPointY(2),0);
        
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        p_Neutral2.EnableAIFeatures(aiEnabled,false);
        
        p_Enemy.SetPointToAssemble(0,GetPointX(3),GetPointY(3),0);
        p_Enemy.SetPointToAssemble(1,GetPointX(4),GetPointY(4),0);
        p_Enemy.SetPointToAssemble(2,GetPointX(5),GetPointY(5),0);
        
        n_EvacuatePointX = GetPointX(0);
        n_EvacuatePointY = GetPointY(0);
        
        p_Enemy.EnableResearch("RES_LC_BHD",false);
        p_Enemy.EnableResearch("RES_LC_BMD",false);
        
        p_Enemy.EnableResearch("RES_LC_WSL1",true);
        p_Enemy.EnableResearch("RES_LC_WCH2",true);
        p_Enemy.EnableResearch("RES_MCH2",true);
        p_Enemy.EnableResearch("RES_LC_UMO2",true);
        p_Enemy.EnableResearch("RES_LC_UME1",true);
        
        p_Player.EnableResearch("RES_ED_WSR1",true);
        p_Player.EnableResearch("RES_ED_MSC2",true);
        p_Player.EnableResearch("RES_ED_UMT1",true);
        p_Player.EnableResearch("RES_ED_UA11",true);
        p_Player.EnableResearch("RES_ED_UA12",true);
        p_Player.EnableResearch("RES_ED_RepHand",true);
        
        // 1st tab
        p_Player.EnableBuilding("EDBPP",false);
        p_Player.EnableBuilding("EDBBA",false);
        p_Player.EnableBuilding("EDBFA",false);
        p_Player.EnableBuilding("EDBWB",false);
        p_Player.EnableBuilding("EDBAB",false);
        // 2nd tab
        p_Player.EnableBuilding("EDBRE",false);
        p_Player.EnableBuilding("EDBMI",false);
        p_Player.EnableBuilding("EDBTC",false);
        // 3rd tab
        p_Player.EnableBuilding("EDBST",false);
        // 4th tab
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBEN1",true);
        p_Player.EnableBuilding("EDBLZ",true);
        
        SetTimer(0,100);
        SetTimer(1,6000);
        bCheckEndMission = false;
        
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),8,0,20,0);
        p_Player.SetMilitaryUnitsLimit(15000);  
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing215a");
        return EvacuateBase,100;
        p_Enemy.SetEnemy(p_Neutral2);
    }
    
    //-----------------------------------------------------------------------------------------
    state EvacuateBase
    {
        nAttackCounter=nAttackCounter+1;
        if(nAttackCounter>15)
        {
            nAttackCounter=0;
            p_Enemy.RussianAttack(GetPointX(2),GetPointY(2),0);
        }
        p_Enemy.SetEnemy(p_Neutral2);
        if(Distance(p_Builder.GetLocationX(),p_Builder.GetLocationY(),n_EvacuatePointX,n_EvacuatePointY) < 18)
        {
            SetGoalState(evacuateBase, goalAchieved);
            EnableGoal(build3ResCent,true);
            p_Player.SetMoney(15000);
            AddBriefing("translateBriefing215b");
            
            // 1st tab
            p_Player.EnableBuilding("EDBPP",true);
            p_Player.EnableBuilding("EDBBA",true);
            p_Player.EnableBuilding("EDBFA",true);
            p_Player.EnableBuilding("EDBWB",true);
            p_Player.EnableBuilding("EDBAB",true);
            // 2nd tab
            p_Player.EnableBuilding("EDBRE",true);
            p_Player.EnableBuilding("EDBMI",true);
            p_Player.EnableBuilding("EDBTC",true);
            // 3rd tab
            p_Player.EnableBuilding("EDBST",true);
            // 4th tab
            p_Player.EnableBuilding("EDBRC",true);
            p_Player.EnableBuilding("EDBHQ",true);
            p_Player.EnableBuilding("EDBRA",true);
            p_Player.EnableBuilding("EDBEN1",true);
            p_Player.EnableBuilding("EDBLZ",true);
            
            p_Enemy.EnableAIFeatures(aiControlDefense,true);      
            return BuildUpBase,200; 
        }
        return EvacuateBase,20;
    }
    //-----------------------------------------------------------------------------------------
    state BuildUpBase
    {
        if(p_Player.GetNumberOfBuildings(buildingResearchCenter)>2)
        {
            SetGoalState(build3ResCent, goalAchieved);
            p_Prototype.ChangePlayer(p_Player);
            EnableGoal(evacuatePrototype,true);
            AddBriefing("translateBriefing215c");
            p_Enemy.EnableAIFeatures(aiControlOffense,true);
            return EvacuatePrototype;
        }
        /*if(!p_Player.GetMoney())
        {
        EnableNextMission(1,true);
        EnableNextMission(2,true);
        AddBriefing("translateFailed215c");
        EndMission(false);
    }*/
        return BuildUpBase,200;
    }
    //-----------------------------------------------------------------------------------------
    state EvacuatePrototype
    {
        if(Distance(p_Prototype.GetLocationX(),p_Prototype.GetLocationY(),n_EvacuatePointX,n_EvacuatePointY) < 5)
        {
            SetGoalState(evacuatePrototype, goalAchieved);
            EnableNextMission(0,true);
            AddBriefing("translateAccomplished215");
            EnableEndMissionButton(true);
            return Final,100;
        }
        return EvacuatePrototype,100;
    }
    //-----------------------------------------------------------------------------------------
    state Final
    {
        return Final,500;
    }
    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(GetGoalState(evacuateBase)!=goalAchieved && !p_Builder.IsLive())
        {
            AddBriefing("translateFailed215a");
            EnableNextMission(1,true);
            EnableNextMission(2,true);
            EndMission(false);
        }
        if(!p_Prototype.IsLive())
        {
            AddBriefing("translateFailed215b");
            EnableNextMission(1,true);
            EnableNextMission(2,true);
            EndMission(false);
        }
        
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed215d");
                EnableNextMission(1,true);
                EnableNextMission(2,true);
                EndMission(false);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli 5min
    {
        Snow(n_EvacuatePointX,n_EvacuatePointY,40,400,2500,800,5); 
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
    event EndMission()
    {
        p_Enemy.SetEnemy(p_Neutral);
        p_Player.SetEnemy(p_Neutral);
        p_Player.SetEnemy(p_Neutral2);
        p_Neutral.SetEnemy(p_Player);
        p_Neutral2.SetEnemy(p_Player);
        
    }
}
