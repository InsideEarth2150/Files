//Zdobyæ kosmoport UCS
mission "translateMission521"
{

    consts
    {
        destroySpacePortDefenses = 0;
        captureSpacePort = 1;
        destroyEnemyBase = 2;
        destroyAllUnits = 3;

        primaryGoal = 0;
        secondaryGoal = 1;
        hiddenGoal = 2;
        endMission = 3;

        accountMainBase = 1;
        accountResearchBase = 2;
        accountCareerPoints = 3;

    }
    
    player p_Enemy1;// UCS Base
    player p_Enemy2;//Space port defences
    player p_Neutral;//Space Port
    player p_Player;
    unitex u_SpacePort;
    
    int bCheckEndMission;
    int n_Counter;
    int m_bSuccess;
    //----------------------------------------------------------------------------------------- 
    function int Transfer(int account, int value)
    {
        p_Player.SetScriptData(account,p_Player.GetScriptData(account)+value);
    }
    //----------------------------------------------------------------------------------------- 
    function int SetPrize(int reason)
    {
        if(reason==primaryGoal)
        {
            Transfer(accountMainBase,0);
            Transfer(accountResearchBase,0);
            Transfer(accountCareerPoints,0);
        }
        if(reason==secondaryGoal)
        {
            Transfer(accountResearchBase,20000);
            Transfer(accountCareerPoints,16);
        }
        if(reason==hiddenGoal)
        {
            Transfer(accountMainBase,3000);
            Transfer(accountCareerPoints,5);
        }
        if(reason==endMission)
        {
            if (m_bSuccess)
            {
                Transfer(accountMainBase,p_Player.GetMoney()/2);
                Transfer(accountResearchBase,p_Player.GetMoney()/2);
                p_Player.AddMoney(0 - p_Player.GetMoney());
            }
        }
    }
    //----------------------------------------------------------------------------------------- 
        
    state Initialize;
    state ShowBriefing;
    state CaptureSpacePort;
    state ShowingCapturedSpacePort;
    state EndMissionAfterVideo;
    state Nothing;
    state EndMissionFailed;     
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
                
        m_bSuccess = true;
        //----------- Goals ------------------
        RegisterGoal(destroySpacePortDefenses,"translateGoal521a");
        RegisterGoal(captureSpacePort,"translateGoal521b");
        RegisterGoal(destroyEnemyBase,"translateGoal521c");
        RegisterGoal(destroyAllUnits,"translateGoal521d");
        
        EnableGoal(destroySpacePortDefenses,true);               
        EnableGoal(captureSpacePort,true);               
        EnableGoal(destroyEnemyBase,true);               
                
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3);
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(6);
        p_Neutral = GetPlayer(4);
        //----------- AI ---------------------
        p_Neutral.EnableStatistics(false);  
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        p_Neutral.EnableAIFeatures(aiEnabled,false);

        ShowArea(4,p_Neutral.GetStartingPointX(),p_Neutral.GetStartingPointY(),0,3);

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
        if(GetDifficultyLevel()==0)
        {
            KillArea(p_Enemy2.GetIFF(), GetPointX(4), GetPointY(4), 0, 1);
            KillArea(p_Enemy2.GetIFF(), GetPointX(5), GetPointY(5), 0, 1);
        }
        if(GetDifficultyLevel()==1)
        {
            KillArea(p_Enemy2.GetIFF(), GetPointX(5), GetPointY(5), 0, 1);
        }        
        p_Enemy1.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Enemy1);
        p_Enemy2.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Enemy2);

        
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
        

        //----------- Money ------------------
        if(GetDifficultyLevel()==0)
        {
            p_Player.SetMoney(50000);
            p_Enemy1.SetMoney(20000);
            p_Enemy2.SetMoney(20000);
        }
        if(GetDifficultyLevel()==1)
        {
            p_Player.SetMoney(30000);
            p_Enemy1.SetMoney(30000);
            p_Enemy2.SetMoney(30000);
        }
        if(GetDifficultyLevel()==2)
        {
            p_Player.SetMoney(15000);
            p_Enemy1.SetMoney(100000);
            p_Enemy2.SetMoney(100000);
        }
        p_Neutral.SetMoney(0);
        //----------- Researches -------------
        p_Player.EnableResearch("RES_ED_WBT2",true);
        p_Enemy2.CopyResearches(p_Enemy1);
        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        p_Player.EnableBuilding("EDBWB",false);
        p_Player.EnableBuilding("EDBTC",false);
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBUC",false);
                    
        //----------- Artefacts --------------
                
        CreateArtefact("NEAPLATE1",GetPointX(1),GetPointY(1),GetPointZ(1),1,artefactSpecialAIOther);                
        CreateArtefact("NEAPLATE1",GetPointX(2),GetPointY(2),GetPointZ(2),2,artefactSpecialAIOther);                
        CreateArtefact("NEAPLATE1",GetPointX(3),GetPointY(3),GetPointZ(3),3,artefactSpecialAIOther);                
        CreateArtefact("NEAPLATE1",GetPointX(4),GetPointY(4),GetPointZ(4),4,artefactSpecialAIOther);                                
        //----------- Units ------------------
        u_SpacePort=GetUnit(GetPointX(0),GetPointY(0),0);
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bCheckEndMission = false;
        n_Counter=0;
        //----------- Camera -----------------
        CallCamera();
        EnableInterface(false);
        EnableCameraMovement(false);
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,128,20,0);
        p_Player.DelayedLookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0,100,1);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);//522
        EnableInterface(true);
        EnableCameraMovement(true);
        AddBriefing("translateBriefing521");
        return CaptureSpacePort;
    }
    //-----------------------------------------------------------------------------------------
    state CaptureSpacePort
    {
        if(GetGoalState(destroySpacePortDefenses)==goalAchieved &&
            GetGoalState(captureSpacePort)!=goalAchieved && n_Counter>3)
        {
            SetGoalState(captureSpacePort,goalAchieved);
            n_Counter=0;
            AddBriefing("translateAccomplished521");//XXXMD JS zmiana translateAccomplished521b -> translateAccomplished521
            CallCamera();
            p_Player.LookAt(GetPointX(0),GetPointY(0),6,128,20,0);
            p_Player.DelayedLookAt(GetPointX(0),GetPointY(0),6,0,20,0,100,1);
            SetPrize(primaryGoal);
            return ShowingCapturedSpacePort,100;
        }
        return CaptureSpacePort;
    }
    //-----------------------------------------------------------------------------------------     

    state ShowingCapturedSpacePort
    {
        ShowVideo("Cutscene2");
        return EndMissionAfterVideo,0;
    }
    //-----------------------------------------------------------------------------------------     
    state EndMissionAfterVideo
    {
        m_bSuccess = true;
        EndMission(true);
        return Nothing;
    }
    //-----------------------------------------------------------------------------------------     
    state Nothing
    {
        return Nothing;
    }
    //-----------------------------------------------------------------------------------------
    state EndMissionFailed
    {
        EnableNextMission(0,2);
        return Nothing;
    }
    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(!u_SpacePort.IsLive())
        {
            AddBriefing("translateFailed521b");
            state EndMissionFailed;
        }
        if(!bCheckEndMission)return;

        bCheckEndMission=false;
            
        if(GetGoalState(destroyAllUnits)!=goalAchieved && 
            !p_Enemy1.GetNumberOfUnits()&& 
            !p_Enemy2.GetNumberOfUnits())
        {
            EnableGoal(destroyAllUnits,true);               
            SetGoalState(destroyAllUnits, goalAchieved);
            SetPrize(hiddenGoal);
        }

        if(!p_Enemy1.GetNumberOfBuildings() && GetGoalState(destroyEnemyBase)!=goalAchieved)
        {
            SetPrize(secondaryGoal);
            SetGoalState(destroyEnemyBase,goalAchieved);
        }

        if(!p_Enemy2.GetNumberOfBuildings() && GetGoalState(destroySpacePortDefenses)!=goalAchieved)
        {
            SetGoalState(destroySpacePortDefenses,goalAchieved);
        }

        if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed521a");
            m_bSuccess = false;
            state EndMissionFailed;
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
    event EndMission() 
    {
        SetPrize(endMission);
        p_Neutral.SetEnemy(p_Player);
        p_Player.SetEnemy(p_Neutral);
        p_Neutral.EnableAIFeatures(aiRejectAlliance,true);
    }
   //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        if(aID>4) return false;
        CreateArtefact("NEAPLATE2",GetPointX(aID),GetPointY(aID),GetPointZ(aID),aID+10,artefactSpecialAIOther);             
        n_Counter=n_Counter+1;
        return true; //usuwa sie 
    }
}
   