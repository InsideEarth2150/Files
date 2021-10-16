//markers 0-3 aktywacja silosow.
//4-silos 1
//wlaczyc rakiety atomowe neutralowi i wywolac restoreAmmo na wszystkich 8-miu silosach

mission "translateMission516"
{

    consts
    {
        recaptureBase = 0;
        cancelSelfDestruction = 1;
        destroyLCBase = 2;
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
    player p_Neutral;//silosy
    player p_Player;
    
    int bCheckEndMission;
    int n_SelfDestructionCounter;
    int n_CancelCounter;
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
            Transfer(accountMainBase,5000);
            Transfer(accountResearchBase,15000);
            Transfer(accountCareerPoints,10);
        }
        if(reason==secondaryGoal)
        {
            Transfer(accountCareerPoints,7);
        }
        if(reason==hiddenGoal)
        {
            Transfer(accountMainBase,3000);
            Transfer(accountCareerPoints,3);
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
    state RecaptureOurBase;
    state CancelSelfDestruction;
    state AttackOnBase;
    state Nothing;
    state EndMissionFailed;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        unitex u_Silo;
        int i;
                
        m_bSuccess = true;
        //----------- Goals ------------------
        RegisterGoal(recaptureBase,"translateGoal516a");
        RegisterGoal(cancelSelfDestruction,"translateGoal516b");
        RegisterGoal(destroyLCBase,"translateGoal516c");
        RegisterGoal(destroyAllUnits,"translateGoal516d");
        
        EnableGoal(recaptureBase,true);               
                
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(1);
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(3);
        p_Enemy2 = GetPlayer(5);
        p_Neutral = GetPlayer(4);
        //----------- AI ---------------------
        p_Neutral.EnableStatistics(false);  
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        p_Neutral.EnableAIFeatures(aiEnabled,false);

        if(GetDifficultyLevel()==0)
        {
            p_Neutral.EnableAIFeatures(aiRejectAlliance,false);
            p_Player.SetAlly(p_Neutral);
            ShowArea(4,GetPointX(4),GetPointY(4),0,3);
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            ShowArea(4,GetPointX(4),GetPointY(4),0,3);
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
        }

        p_Enemy1.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Enemy1);
        p_Enemy2.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Enemy2);

        p_Enemy2.SetAlly(p_Enemy1);

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
        p_Enemy2.CopyResearches(p_Enemy1);

        p_Neutral.AddResearch("RES_ED_WSR1");
        p_Neutral.AddResearch("RES_ED_WSR2");
        p_Neutral.AddResearch("RES_ED_WSR3");

        p_Neutral.AddResearch("RES_ED_WMR1");
        p_Neutral.AddResearch("RES_ED_WMR2");
        p_Neutral.AddResearch("RES_ED_WMR3");

        p_Neutral.AddResearch("RES_ED_WHR1");
        p_Neutral.AddResearch("RES_ED_MHR2");
        p_Neutral.AddResearch("RES_ED_MHR3");
        p_Neutral.AddResearch("RES_ED_MHR4");

        p_Player.EnableResearch("RES_ED_UHT1",true);
        p_Player.EnableResearch("RES_ED_MHC2",true);
        p_Player.EnableResearch("RES_ED_WHC2",true);
        p_Player.EnableResearch("RES_ED_WHL2",true);
        p_Player.EnableResearch("RES_ED_WMR2",true);
        p_Player.EnableResearch("RES_ED_WHI2",true);
        p_Player.EnableResearch("RES_EDWEQ1",true);
        p_Player.EnableResearch("RES_EDBHT",true);

        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,true);
                   // 1st tab
        p_Player.EnableBuilding("EDBWB",false);
        // 2nd tab
        p_Player.EnableBuilding("EDBTC",false);
        // 3rd tab
        p_Player.EnableBuilding("EDBBC",false);
        p_Player.EnableBuilding("EDBSI",false);
        // 4th tab
        p_Player.EnableBuilding("EDBUC",false);
        p_Player.EnableBuilding("EDBRC",false);
                    
        //----------- Artefacts --------------
                
                
        //----------- Units ------------------
        for(i=0;i<8;i=i+1)
        {
            u_Silo = GetUnit(GetPointX(4)+i,GetPointY(4),0);
            u_Silo.RegenerateAmmo();
        }
        //----------- Timers -----------------
        SetTimer(0,100);

        //----------- Variables --------------
        bCheckEndMission = false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
                EnableNextMission(0,true);//517
        AddBriefing("translateBriefing516a");
                p_Player.SetNeutral(p_Neutral);
                p_Neutral.SetNeutral(p_Player);
                if(GetDifficultyLevel()==0)
                {
                    Storm(GetPointX(5),GetPointY(5),15,300,5000,1000,5,3,1);
                    Rain(GetPointX(6),GetPointY(6),15,300,5000,1000,5);
                }
                if(GetDifficultyLevel()==1)
                {
                    Storm(GetPointX(5),GetPointY(5),15,300,7000,1000,5,5,3);
                    Storm(GetPointX(6),GetPointY(6),15,300,7000,1000,5,5,3);
                }
                if(GetDifficultyLevel()==2)
                {
                    Storm(GetPointX(5),GetPointY(5),15,300,15000,1000,5,5,10);
                    Storm(GetPointX(6),GetPointY(6),15,300,15000,1000,5,5,10);
                }
                return RecaptureOurBase;
    }
        //-----------------------------------------------------------------------------------------
        state RecaptureOurBase
        {
            int i;
            if(p_Player.GetNumberOfBuildings(buildingBBC)>0)
            {
                for(i=0;i<4;i=i+1)
                {
                    CreateArtefact("NEASWITCH2",GetPointX(i),GetPointY(i),GetPointZ(i),i,artefactSpecialAIOther);
                }
                SetGoalState(recaptureBase,goalAchieved);
                EnableGoal(cancelSelfDestruction,true);               
                AddBriefing("translateBriefing516b");
                if(GetDifficultyLevel()==0)
                    n_SelfDestructionCounter=1024;
                if(GetDifficultyLevel()==1)
                    n_SelfDestructionCounter=512;
                if(GetDifficultyLevel()==2)
                    n_SelfDestructionCounter=256;
                n_CancelCounter=0;
                return CancelSelfDestruction,1;
            }
            return RecaptureOurBase;
        }
        //-----------------------------------------------------------------------------------------  
        state CancelSelfDestruction
        {
            int d;
            int h;
            int m;

            if(n_CancelCounter>3)
            {
                EnableGoal(destroyLCBase,true);               
                SetGoalState(cancelSelfDestruction,goalAchieved);
                SetPrize(primaryGoal);
                AddBriefing("translateBriefing516c");
                SetConsoleText(" ");
        m_bSuccess = true;
                EnableEndMissionButton(true);
                return AttackOnBase,1200;
            }
            n_SelfDestructionCounter=n_SelfDestructionCounter-1;
            if (n_SelfDestructionCounter < 0)
            {
                d = 0;
                h = 0;
                m = 0;
            }
            else
            {
                //ticksPerDay = 16383;
                //tiicksPerHour = 683;
                m = 24*60*n_SelfDestructionCounter*20/16383;
                d = m/60/24;
                h = (m/60)%24;
                m = m%60;
                if ((m%5) > 0)
                {
                    m = (m/5)*5;
                }
            }
            if (d == 0)
            {
                SetConsoleText("translateMessage516c",h/10,h%10,m/10,m%10);
            }
            else if (d == 1)
            {
                SetConsoleText("translateMessage516b",d,h/10,h%10,m/10,m%10);
            }
            else
            {
                SetConsoleText("translateMessage516a",d,h/10,h%10,m/10,m%10);
            }

            if(n_SelfDestructionCounter<0)
            {
                KillArea(15,GetPointX(4)+5,GetPointY(4)-2,0,5);
                SetGoalState(cancelSelfDestruction,goalFailed);
                AddBriefing("translateFailed516b");
        SetConsoleText(" ");
        m_bSuccess = false;
                return EndMissionFailed;        
            }
            return CancelSelfDestruction,20;
        }
        //-----------------------------------------------------------------------------------------     
        state AttackOnBase
        {
            p_Player.SetScriptData(10,1);
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
            if(!bCheckEndMission)return;

            bCheckEndMission=false;
                
            if(GetGoalState(destroyAllUnits)!=goalAchieved && !p_Enemy1.GetNumberOfUnits())
      {
                    EnableGoal(destroyAllUnits,true);               
          SetGoalState(destroyAllUnits, goalAchieved);
          SetPrize(hiddenGoal);
      }

            if(!p_Enemy1.GetNumberOfBuildings() && GetGoalState(destroyLCBase)!=goalAchieved)
      {
                EnableGoal(destroyLCBase,true);               
                SetPrize(secondaryGoal);
                SetGoalState(destroyLCBase,goalAchieved);
            }

      if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
      {
                  if(GetGoalState(cancelSelfDestruction)!=goalAchieved)
                    {
                        AddBriefing("translateFailed516a");
            SetConsoleText(" ");
            m_bSuccess = false;
                        state EndMissionFailed;     
                        
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
        p_Neutral.SetEnemy(p_Player);
        p_Player.SetEnemy(p_Neutral);
        p_Neutral.EnableAIFeatures(aiRejectAlliance,true);
    }
   //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        if(aID<4)
        {
            n_CancelCounter=n_CancelCounter+1;
            CreateArtefact("NEASWITCH1",GetPointX(aID),GetPointY(aID),GetPointZ(aID),aID+10,artefactSpecialAIOther);
            return true; //usuwa sie 
        }
        return false; //usuwa sie 
    }

}
   