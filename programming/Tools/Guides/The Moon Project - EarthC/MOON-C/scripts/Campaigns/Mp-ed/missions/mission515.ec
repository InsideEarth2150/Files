mission "translateMission515"
{

    consts
    {
        pickUpPilots = 0;
        recoverTanks = 1;
        destroyAllBuildings = 2;
        destroyAllUnits = 3;

        primaryGoal = 0;
        secondaryGoal = 1;
        hiddenGoal = 2;
        endMission = 3;

        accountMainBase = 1;
        accountResearchBase = 2;
        accountCareerPoints = 3;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Neutral1;//Tanks
    player p_Neutral2;//Teleports
    player p_Player;
        
    unitex u_CargoSalamander;
    
    int bCheckEndMission;
    int bEnemyActivated;
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
            Transfer(accountResearchBase,15000);
            Transfer(accountCareerPoints,2);
        }
        if(reason==secondaryGoal)
        {
            Transfer(accountMainBase,5000);
            Transfer(accountCareerPoints,10);
        }
        if(reason==hiddenGoal)
        {
            Transfer(accountMainBase,5000);
            Transfer(accountCareerPoints,2);
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
    state PickUpPilots;
    state RecoverTanks;
    state Nothing;
        
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        unitex u_TmpUnit;
        int i;
        int j;
        int start;
        int end;
                
        m_bSuccess = true;
        //----------- Goals ------------------
        RegisterGoal(pickUpPilots,"translateGoal515a");
        RegisterGoal(recoverTanks,"translateGoal515b");
        RegisterGoal(destroyAllBuildings,"translateGoal515c");
        RegisterGoal(destroyAllUnits,"translateGoal515d");
        
        EnableGoal(pickUpPilots,true);               
        EnableGoal(destroyAllBuildings,true);               
        
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3);
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(6);
        p_Neutral1 = GetPlayer(4);
        p_Neutral2 = GetPlayer(7);
        //----------- AI ---------------------
        p_Neutral1.EnableStatistics(false);  
        p_Neutral1.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral1);
        p_Neutral1.EnableAIFeatures(aiEnabled,false);
        p_Neutral2.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral2);
        p_Neutral2.EnableAIFeatures(aiEnabled,false);
        p_Neutral2.EnableStatistics(false);  
        p_Neutral1.SetNeutral(p_Neutral2);
        p_Neutral2.SetNeutral(p_Neutral1);

        if(GetDifficultyLevel()==0)
        {
            p_Neutral1.EnableAIFeatures(aiRejectAlliance,false);
            p_Player.SetAlly(p_Neutral1);
            ShowArea(4,GetPointX(0),GetPointY(0),0,3);
            p_Enemy2.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy2.LoadScript("single\\singleMedium");
            ShowArea(4,GetPointX(0),GetPointY(0),0,3);
            ShowArea(4,GetPointX(1),GetPointY(1),0,3);
        }
        if(GetDifficultyLevel()==2)
            p_Enemy2.LoadScript("single\\singleHard");
        
        p_Enemy1.LoadScript("single\\singleDefault");
        p_Enemy2.LoadScript("single\\singleMedium");

        p_Enemy1.SetNeutral(p_Neutral1);
        p_Neutral1.SetNeutral(p_Enemy1);
        p_Enemy1.SetNeutral(p_Neutral2);
        p_Neutral2.SetNeutral(p_Enemy1);
        p_Enemy2.SetNeutral(p_Neutral1);
        p_Neutral1.SetNeutral(p_Enemy2);
        p_Enemy2.SetNeutral(p_Neutral2);
        p_Neutral2.SetNeutral(p_Enemy2);

        p_Enemy1.SetNeutral(p_Enemy2);
        p_Enemy2.SetNeutral(p_Enemy1);

        p_Enemy1.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiRejectAlliance,false);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiDefenseTowers,false);
        p_Enemy2.EnableAIFeatures(aiBuildTanks | aiBuildShips | aiBuildHelicopters, false);
        
                
        p_Neutral2.EnableAIFeatures(aiRejectAlliance,false);
        p_Player.SetAlly(p_Enemy2);
        p_Player.SetAlly(p_Neutral2);

                //----------- Money ------------------
        p_Player.SetMoney(0);
        if(GetDifficultyLevel()==1)
        {
            p_Enemy2.SetMoney(20000);
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy2.SetMoney(100000);
        }
        p_Neutral1.SetMoney(0);
        p_Neutral2.SetMoney(0);

        //----------- Researches -------------
        p_Player.EnableResearch("RES_ED_BC1",true);
        p_Player.EnableResearch("RES_ED_UA31",true);
        p_Player.EnableResearch("RES_ED_AMR2",true);//helicopter rocket launcher
        p_Player.EnableResearch("RES_ED_UHW1",true);
        p_Player.EnableResearch("RES_ED_WHC1",true);
        p_Player.EnableResearch("RES_ED_WHL1",true);
        p_Player.EnableResearch("RES_ED_WMR1",true);
        p_Player.EnableResearch("RES_ED_WHI1",true);
        p_Player.EnableResearch("RES_MMR2",true);

        
        p_Enemy1.AddResearch("RES_UCS_USL1");
        p_Enemy1.AddResearch("RES_UCS_UML1");
        p_Enemy1.AddResearch("RES_UCS_UHL1");
        p_Enemy1.AddResearch("RES_UCS_WSP1");
        p_Enemy1.AddResearch("RES_UCS_WSP2");
        p_Enemy1.AddResearch("RES_UCS_WHP1");
        p_Enemy1.AddResearch("RES_UCS_WHP2");
        p_Enemy1.AddResearch("RES_UCS_WSR1");
        p_Enemy1.AddResearch("RES_UCS_WSR2");
        p_Enemy1.AddResearch("RES_UCS_WSR3");
        p_Enemy1.AddResearch("RES_UCS_WMR1");
        p_Enemy1.AddResearch("RES_UCS_WMR2");
        p_Enemy1.AddResearch("RES_UCS_WMR3");
        p_Enemy2.CopyResearches(p_Enemy1);
        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,true);
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
        p_Player.EnableBuilding("EDBBT",false);
        p_Player.EnableBuilding("EDBHT",false);
        p_Player.EnableBuilding("EDBART",false);
        // 4th tab
        p_Player.EnableBuilding("EDBUC",false);
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBEN1",false);
        p_Player.EnableBuilding("EDBLZ",true);
                    
        
        //----------- Artefacts --------------
        if(GetDifficultyLevel()==0)
        {
            start=0;
            end=0;
        }
        if(GetDifficultyLevel()==1)
        {
            start=30;
            end=40;
        }
        if(GetDifficultyLevel()==2)
        {
            start=30;
            end=50;
        }
        for(i=start;i<end;i=i+1)
        {
            CreateArtefact("NEAMINE",GetPointX(i),GetPointY(i),GetPointZ(i),i,artefactSpecialAIOther);
        }
                
        //----------- Units ------------------
        
        u_CargoSalamander = p_Player.GetScriptUnit(0);
        for(i=2;i<=26;i=i+2)
        {
            u_TmpUnit=GetUnit(GetPointX(i),GetPointY(i),GetPointZ(i));
            u_TmpUnit.BeginRecord();
            u_TmpUnit.CommandMove(GetPointX(i+1),GetPointY(i+1),0);
            u_TmpUnit.CommandMove(GetPointX(i),GetPointY(i),0);
            u_TmpUnit.RepeatRecordExecution();
            u_TmpUnit.EndRecord();
            u_TmpUnit.ExecuteRecord();
        }
        
        for(i=0;i<=3;i=i+1)
        for(j=-3;j<=3;j=j+1)
        {
            u_TmpUnit = GetUnit(p_Neutral1.GetStartingPointX()+i,p_Neutral1.GetStartingPointY()+j,0);
            if(u_TmpUnit!=null)
                u_TmpUnit.LoadScript("Scripts\\Units\\Tank.ecomp");
        }
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bCheckEndMission = false;
        bEnemyActivated = false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,50;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing515a");
        return PickUpPilots;
    }
    //-----------------------------------------------------------------------------------------  
    state PickUpPilots
    {
        if(u_CargoSalamander!=null && u_CargoSalamander.IsLive() && u_CargoSalamander.DistanceTo(GetPointX(0),GetPointY(0))<3)
        {
            p_Player.EnableBuilding("EDBPP",true);
            p_Player.EnableBuilding("EDBBA",true);
            p_Player.EnableBuilding("EDBFA",true);
            p_Player.EnableBuilding("EDBWB",true);
            p_Player.EnableBuilding("EDBAB",true);
            // 2nd tab
            if(GetDifficultyLevel()==2)
            {
                p_Player.EnableBuilding("EDBRE",true);
                p_Player.EnableBuilding("EDBMI",true);
            }
            // 3rd tab
            p_Player.EnableBuilding("EDBST",true);
            p_Player.EnableBuilding("EDBBT",true);
            p_Player.EnableBuilding("EDBHT",true);
            p_Player.EnableBuilding("EDBART",true);
            // 4th tab
            p_Player.EnableBuilding("EDBUC",true);
            p_Player.EnableBuilding("EDBRC",true);
            p_Player.EnableBuilding("EDBHQ",true);
            p_Player.EnableBuilding("EDBRA",true);
            p_Player.EnableBuilding("EDBEN1",true);
            p_Player.EnableBuilding("EDBLZ",true);
        
            SetGoalState(pickUpPilots,goalAchieved);
            if (GetDifficultyLevel()==2)
            {
                p_Enemy2.EnableAIFeatures(aiBuildTanks | aiBuildShips | aiBuildHelicopters, true);
            }
            EnableGoal(recoverTanks,true);               
            AddBriefing("translateBriefing515b");
            return RecoverTanks;
        }
        return PickUpPilots;
    }
    //-----------------------------------------------------------------------------------------  
    state RecoverTanks
    {
        if(u_CargoSalamander.DistanceTo(GetPointX(1),GetPointY(1))<4)
        {
            SetGoalState(recoverTanks,goalAchieved);
            AddBriefing("translateAccomplished515");
            SetPrize(primaryGoal);
            p_Neutral1.GiveAllUnitsTo(p_Player);
            m_bSuccess = true;
            EnableEndMissionButton(true);

        return Nothing; 
        }
        return RecoverTanks;
        
    }
    //-----------------------------------------------------------------------------------------  
    state Nothing
    {
        return Nothing;
    }

    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(!bEnemyActivated && (p_Player.GetNumberOfUnits()>1 || bCheckEndMission||
            (p_Player.GetNumberOfUnits()>0 && !u_CargoSalamander.IsInWorld(GetWorldNum()))))
        {
            bEnemyActivated=true;
            p_Player.SetEnemy(p_Enemy2);
            p_Enemy2.SetEnemy(p_Player);
            if(GetGoalState(pickUpPilots)==goalNotAchieved)
            {
                SetGoalState(pickUpPilots,goalFailed);
                SetGoalState(recoverTanks,goalFailed);
                AddBriefing("translateFailed515c");//you has been discovered all pilots has been killed
                m_bSuccess = false;
                EnableEndMissionButton(true,false);
                state Nothing;
            }
        }

        if(GetGoalState(recoverTanks)==goalNotAchieved && !u_CargoSalamander.IsLive())
        {
            if(GetGoalState(pickUpPilots)!=goalAchieved)
            SetGoalState(pickUpPilots,goalFailed);
            SetGoalState(recoverTanks,goalFailed);
            AddBriefing("translateFailed515b");
            m_bSuccess = false;
            EnableEndMissionButton(true,false);
            state Nothing;
        }

        if(!bCheckEndMission)return;
        bCheckEndMission=false;
              
                
        if(GetGoalState(destroyAllUnits)!=goalAchieved && !p_Enemy2.GetNumberOfUnits())
        {
            EnableGoal(destroyAllUnits,true);               
            SetGoalState(destroyAllUnits, goalAchieved);
            SetPrize(hiddenGoal);
        }

        if((p_Enemy2.GetNumberOfBuildings()==p_Enemy2.GetNumberOfBuildings(buildingEnergyTransmitter)) 
            && GetGoalState(destroyAllBuildings)!=goalAchieved)
        {
            EnableGoal(destroyAllBuildings,true);               
            SetPrize(secondaryGoal);
            SetGoalState(destroyAllBuildings,goalAchieved);
        }

        if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
        {
            if(GetGoalState(recoverTanks)!=goalAchieved)
            {
                AddBriefing("translateFailed515a");
                m_bSuccess = false;
                EndMission(false);
            }
            else
            {
                m_bSuccess = true;
                EndMission(true);
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
    event EndMission() 
    {
        SetPrize(endMission);
        p_Neutral1.SetEnemy(p_Player);
        p_Player.SetEnemy(p_Neutral1);
        p_Neutral1.EnableAIFeatures(aiRejectAlliance,true);
    }
   //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        if(aID>29 && aID<50)//mines
        {
            KillArea(15, GetPointX(aID),GetPointY(aID),GetPointZ(aID),0);
            return true; //usuwa sie 
        }
        return true; //usuwa sie 
    }
}
   