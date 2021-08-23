mission "translateMission243"
{//Madagaskar
    consts
    {
        recoverArtefact=0;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_GoalEnemy;
    player p_Player;
    
    state Initialize;
    state ShowBriefing;
    state RecoverArtefact;
    state Evacuate;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        RegisterGoal(recoverArtefact,"translateGoal243");
        EnableGoal(recoverArtefact,true);           
        
        //                   name          x,y,z, nr,typ
        CreateArtefact("NEASPECIAL2",GetPointX(0),GetPointY(0),1,0,artefactSpecialAIOther);
        
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(3);
        
        p_Player.SetMoney(20000);
        p_Enemy1.SetMoney(40000);
        p_Enemy2.SetMoney(40000);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        
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
        
        p_Enemy1.SetPointToAssemble(0,GetPointX(1),GetPointY(1),0);
        p_Enemy1.SetPointToAssemble(1,GetPointX(2),GetPointY(2),0);
        
        p_Player.EnableResearch("RES_ED_WHC1",true);
        p_Player.EnableResearch("RES_MSR2",true);
        p_Player.EnableResearch("RES_ED_UHT1",true);
        
        p_Enemy1.EnableResearch("RES_UCS_WHG1",true);
        p_Enemy1.EnableResearch("RES_UCS_SGEN",true);
        p_Enemy1.EnableResearch("RES_UCS_UMI1",true);
        
        p_Enemy2.EnableResearch("RES_LC_WHS1",true);
        p_Enemy2.EnableResearch("RES_MMR2",true);
        p_Enemy2.EnableResearch("RES_LC_UCU1",true);
        p_Enemy2.EnableResearch("RES_LC_SOB1",true);
        
        
        SetTimer(0,200);
        
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing243");
        EnableNextMission(0,true);
        return RecoverArtefact,100;
    }
    
    //-----------------------------------------------------------------------------------------
    state RecoverArtefact
    {
        if(GetGoalState(recoverArtefact)==goalAchieved)
        {
            EnableEndMissionButton(true);
            return Evacuate,500;
        }
        return RecoverArtefact,100;
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
            AddBriefing("translateFailed243");
            EndMission(false);
        }
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        SetGoalState(recoverArtefact, goalAchieved);
        p_Player.EnableResearch("RES_ED_SGen",true);
        AddBriefing("translateAccomplished243");
        return true; //usuwa sie 
    }
}
