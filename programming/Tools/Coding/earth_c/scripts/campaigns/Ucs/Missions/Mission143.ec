mission "translateMission143"
{//Madagaskar
    consts
    {
        defendLCBase=0;
        destroyEnemyForces=1;
        recoverArtefact = 2;
    }
    
    player p_Enemy;
    player p_Ally;
    player p_Player;
    
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state ShowVideoState;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(defendLCBase,"translateGoal143a");
        RegisterGoal(destroyEnemyForces,"translateGoal143b");
        RegisterGoal(recoverArtefact,"translateGoal143c");
        
        EnableGoal(defendLCBase,true);           
        EnableGoal(destroyEnemyForces,true);           
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
        
        p_Enemy.SetPointToAssemble(0,GetPointX(1),GetPointY(1),0);
        p_Enemy.SetPointToAssemble(1,GetPointX(2),GetPointY(2),0);
        
        p_Ally.EnableAIFeatures(aiRejectAlliance,false);
        p_Ally.ChooseEnemy(p_Enemy);
        p_Ally.SetEnemy(p_Enemy);
        
        p_Enemy.ChooseEnemy(p_Ally);
        p_Enemy.SetEnemy(p_Ally);
        
        p_Player.SetAlly(p_Ally);
        //----------- Money ------------------
        p_Player.SetMoney(20000);
        p_Enemy.SetMoney(30000);
        p_Ally.SetMoney(30000);
        //----------- Researches -------------
        p_Enemy.EnableResearch("RES_ED_WHC1",true);
        p_Enemy.EnableResearch("RES_ED_UHT1",true);
        
        p_Player.EnableResearch("RES_UCS_WHP1",true);
        p_Player.EnableResearch("RES_UCS_UAH2",true);
        
        
        p_Ally.EnableResearch("RES_LC_WHS1",true);
        p_Ally.EnableResearch("RES_LC_WHL1",true);
        p_Ally.EnableResearch("RES_LC_WMR1",true);
        p_Ally.EnableResearch("RES_MMR2",true);
        p_Ally.EnableResearch("RES_LC_UCR1",true);
        p_Ally.EnableResearch("RES_LC_UBO1",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,200);
        //----------- Variables --------------
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing143a");
        EnableNextMission(0,true);
        return Fighting,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed143b");
            EndMission(false);
        }
        if(!p_Ally.GetNumberOfBuildings())
        {
            SetGoalState(defendLCBase,goalFailed);           
            AddBriefing("translateFailed143a");
            EnableEndMissionButton(true,false);
            return Evacuate,500;
        }
        if(!p_Enemy.GetNumberOfUnits() && !p_Enemy.GetNumberOfBuildings())
        {
            SetGoalState(defendLCBase,goalAchieved);           
            SetGoalState(destroyEnemyForces,goalAchieved);           
            EnableGoal(recoverArtefact,true);
            AddBriefing("translateBriefing143b");
            CreateArtefact("NEASPECIAL2",GetPointX(0),GetPointY(0),1,0,artefactSpecialAIOther);
            return ShowVideoState,20;
        }
        return Fighting,200;
    }
    //-----------------------------------------------------------------------------------------
    state ShowVideoState
    {
        ShowVideo("CS110");
        return Evacuate,500;
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
            AddBriefing("translateFailed143b");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_Ally.EnableAIFeatures(aiRejectAlliance,true);
        p_Player.SetEnemy(p_Ally);
        p_Ally.SetEnemy(p_Player);
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        SetGoalState(recoverArtefact, goalAchieved);
        p_Player.EnableResearch("RES_UCS_SGen",true);
        AddBriefing("translateAccomplished143");
        EnableEndMissionButton(true);
        return true; //usuwa sie 
    }
}
