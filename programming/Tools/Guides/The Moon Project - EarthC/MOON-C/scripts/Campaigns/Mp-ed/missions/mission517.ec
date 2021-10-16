//odzyskaæ 3 wo³gi z broni¹ atomow¹
mission "translateMission517"
{

    consts
    {
        recaptureUnits = 0;
        destroyEnemyBase = 1;
        destroyAllUnits = 2;

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
    player p_Neutral1;//Units with nuclear weapons
    player p_Neutral2;//Entrance
    player p_Player;
    
    
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
            Transfer(accountMainBase,2000);
            Transfer(accountResearchBase,20000);
            Transfer(accountCareerPoints,5);
        }
        if(reason==secondaryGoal)
        {
            Transfer(accountResearchBase,5000);
            Transfer(accountCareerPoints,8);
        }
        if(reason==hiddenGoal)
        {
            Transfer(accountResearchBase,5000);
            Transfer(accountCareerPoints,1);
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
    state RecaptureUnits;
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
        RegisterGoal(recaptureUnits,"translateGoal517a");
        RegisterGoal(destroyEnemyBase,"translateGoal517b");
        RegisterGoal(destroyAllUnits,"translateGoal517c");
        
        EnableGoal(recaptureUnits,true);               
                
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3);
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(6);
        p_Neutral1 = GetPlayer(4);
        p_Neutral2 = GetPlayer(5);
        //----------- AI ---------------------
        p_Neutral1.EnableStatistics(false);  
        p_Neutral1.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral1);
        p_Neutral1.EnableAIFeatures(aiEnabled,false);
        p_Neutral2.EnableStatistics(false);  
        p_Neutral2.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral2);
        p_Neutral2.EnableAIFeatures(aiEnabled,false);

        if(GetDifficultyLevel()==0)
        {
            p_Neutral1.EnableAIFeatures(aiRejectAlliance,false);
            p_Player.SetAlly(p_Neutral1);
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            ShowArea(4,p_Neutral1.GetStartingPointX(),p_Neutral1.GetStartingPointY(),0,3);
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
        }
        
        p_Enemy1.SetNeutral(p_Neutral1);
        p_Neutral1.SetNeutral(p_Enemy1);
        p_Enemy2.SetNeutral(p_Neutral1);
        p_Neutral1.SetNeutral(p_Enemy2);
        
        p_Enemy1.SetNeutral(p_Neutral2);
        p_Neutral2.SetNeutral(p_Enemy1);
        p_Enemy2.SetNeutral(p_Neutral2);
        p_Neutral2.SetNeutral(p_Enemy2);
        p_Neutral2.SetNeutral(p_Neutral1);
        p_Neutral1.SetNeutral(p_Neutral2);
        
        p_Enemy1.SetNeutral(p_Enemy2);
        p_Enemy2.SetNeutral(p_Enemy1);

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
        p_Neutral1.SetMoney(0);
        //----------- Researches -------------
        p_Enemy2.CopyResearches(p_Enemy1);

        p_Neutral1.AddResearch("RES_ED_WSR1");
        p_Neutral1.AddResearch("RES_ED_WSR2");
        p_Neutral1.AddResearch("RES_ED_WSR3");

        p_Neutral1.AddResearch("RES_ED_WMR1");
        p_Neutral1.AddResearch("RES_ED_WMR2");
        p_Neutral1.AddResearch("RES_ED_WMR3");

        p_Neutral1.AddResearch("RES_ED_WHR1");
        p_Neutral1.AddResearch("RES_ED_MHR2");
        p_Neutral1.AddResearch("RES_ED_MHR3");
        p_Neutral1.AddResearch("RES_ED_MHR4");

        p_Player.EnableResearch("RES_ED_UHT2",true);
        p_Player.EnableResearch("RES_ED_MHC3",true);
        p_Player.EnableResearch("RES_ED_BHD",true);//medium defense building

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
        CreateArtefact("NEACOMPUTER",GetPointX(0),GetPointY(0),GetPointZ(0),0,artefactSpecialAIOther);              
        
        //----------- Units ------------------
        for(i=0;i<3;i=i+1)
        {
            u_Silo = GetUnit(p_Neutral1.GetStartingPointX()+1,p_Neutral1.GetStartingPointY()-1+i,0);
            u_Silo.RegenerateAmmo();
            u_Silo.LoadScript("Scripts\\Units\\AdvancedTankHoldFire.ecomp");
        }
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bCheckEndMission = false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,128,20,0);
        p_Player.DelayedLookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0,100,1);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);//519
        AddBriefing("translateBriefing517");
        if(GetDifficultyLevel()==0)
            n_Counter=6144;
        if(GetDifficultyLevel()==1)
            n_Counter=2560;
        if(GetDifficultyLevel()==2)
            n_Counter=1536;
    
        return RecaptureUnits;
    }
    //-----------------------------------------------------------------------------------------
    state RecaptureUnits
    {
        int i;
        int d;
        int h;
        int m;

        if(GetGoalState(recaptureUnits)==goalAchieved)
        {
            SetConsoleText(" ");
            return AttackOnBase,1000;
        }
        n_Counter=n_Counter-1;
        if (n_Counter < 0)
        {
            d = 0;
            h = 0;
            m = 0;
        }
        else
        {
            //ticksPerDay = 16383;
            //tiicksPerHour = 683;
            m = 24*60*n_Counter*20/16383;
            d = m/60/24;
            h = m/60%24;
            m = m%60;
            if ((m%5) > 0)
            {
                m = (m/5)*5;
            }
        }
        if (d == 0)
        {
            SetConsoleText("translateMessage517c",h/10,h%10,m/10,m%10);
        }
        else if (d == 1)
        {
            SetConsoleText("translateMessage517b",d,h/10,h%10,m/10,m%10);
        }
        else
        {
            SetConsoleText("translateMessage517a",d,h/10,h%10,m/10,m%10);
        }

        if(n_Counter<=0)
        {
            p_Neutral1.SetEnemy(p_Player);
            p_Neutral1.EnableAIFeatures(aiEnabled,true);
            p_Neutral1.RussianAttack(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),0);
            SetGoalState(recaptureUnits,goalFailed);
            AddBriefing("translateFailed517b");
            SetConsoleText(" ");
    m_bSuccess = false;
            return EndMissionFailed;        
        }
        return RecaptureUnits,20;
    }
    //-----------------------------------------------------------------------------------------     
    state AttackOnBase
    {
        p_Player.SetScriptData(8,1);
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

            if(GetGoalState(recaptureUnits)==goalNotAchieved &&p_Neutral1.GetNumberOfUnits()==0)
            {
                SetGoalState(recaptureUnits,goalFailed);//? tak ma byc
                AddBriefing("translateAccomplished517b");
                SetConsoleText(" ");
        m_bSuccess = true;
                EnableEndMissionButton(true);
                return Nothing;     
            }

            if(GetGoalState(destroyAllUnits)!=goalAchieved && !p_Enemy1.GetNumberOfUnits())
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

      if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
      {
                  if(GetGoalState(recaptureUnits)!=goalAchieved)
                    {
                        AddBriefing("translateFailed517a");
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
    }
   //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        if(n_Counter<1)return true; 
        p_Neutral1.GiveAllUnitsTo(p_Player);
        SetGoalState(recaptureUnits,goalAchieved);
        EnableGoal(destroyEnemyBase,true);  
        AddBriefing("translateAccomplished517a");
        SetConsoleText(" ");
        SetPrize(primaryGoal);
        m_bSuccess = true;
        EnableEndMissionButton(true);
        return true; //usuwa sie 
    }

}
   