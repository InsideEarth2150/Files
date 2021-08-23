//Zdobyæ srodki na zdobycie kosmoportu UCS - harvesting ect
mission "translateMission519"
{

    consts
    {
        destroyEnemyBase1 = 0;
        destroyEnemyBase2 = 1;
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
    player p_Neutral;
    player p_Player;
    
    int bCheckEndMission;
    int m_bSuccess;
    int bStartWind;
    //----------------------------------------------------------------------------------------- 
    function int Transfer(int account, int value)
    {
        p_Player.SetScriptData(account,p_Player.GetScriptData(account)+value);
    }
    //----------------------------------------------------------------------------------------- 
    function int SetPrize(int reason)
    {
        if(reason==primaryGoal)//2x
        {
            Transfer(accountMainBase,5000);
            Transfer(accountResearchBase,15000);
            Transfer(accountCareerPoints,2);
        }
        if(reason==secondaryGoal)
        {
            Transfer(accountMainBase,5000);
            Transfer(accountCareerPoints,8);
        }
        if(reason==hiddenGoal)
        {
            Transfer(accountResearchBase,10000);
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
    state AttackOnBase;
    state Nothing;
        
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        m_bSuccess = true;
        //----------- Goals ------------------
        RegisterGoal(destroyEnemyBase1,"translateGoal519a");
        RegisterGoal(destroyEnemyBase2,"translateGoal519b");
        RegisterGoal(destroyAllUnits,"translateGoal519c");
        
        EnableGoal(destroyEnemyBase1,true);               
        EnableGoal(destroyEnemyBase2,true);               
                
        //----------- Temporary players ------
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(3);
        p_Neutral = GetPlayer(6);
        //----------- AI ---------------------
        p_Neutral.EnableStatistics(false);  
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
                
        p_Neutral.SetNeutral(p_Enemy1);
        p_Enemy1.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Enemy2);
        p_Enemy2.SetNeutral(p_Neutral);
        p_Neutral.EnableAIFeatures(aiEnabled,false);

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
        //----------- Researches -------------
        p_Player.EnableResearch("RES_ED_WBT1",true);
        
        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        // 1st tab
        p_Player.EnableBuilding("EDBWB",false);
        // 2nd tab
        p_Player.EnableBuilding("EDBTC",false);
        // 3rd tab
        // 4th tab
        p_Player.EnableBuilding("EDBUC",false);
        p_Player.EnableBuilding("EDBRC",false);
                    
        //----------- Artefacts --------------
        //----------- Units ------------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,1200*10);//10 min
        //----------- Variables --------------
        bCheckEndMission = false;
        bStartWind = true;
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
        EnableNextMission(0,true);//521
        EnableInterface(true);
        EnableCameraMovement(true);
        AddBriefing("translateBriefing519a");
        return AttackOnBase,200;
    }
    //-----------------------------------------------------------------------------------------     
    state AttackOnBase
    {
        p_Player.SetScriptData(9,1);
        return Nothing;
    }
        
    //-----------------------------------------------------------------------------------------  
    state Nothing
    {
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

        if(!p_Enemy1.GetNumberOfBuildings() && GetGoalState(destroyEnemyBase1)!=goalAchieved)
        {
            SetPrize(primaryGoal);
            SetGoalState(destroyEnemyBase1,goalAchieved);
            AddBriefing("translateAccomplished519");
            m_bSuccess = true;
            EnableEndMissionButton(true);
        }

        if(!p_Enemy2.GetNumberOfBuildings() && GetGoalState(destroyEnemyBase2)!=goalAchieved)
        {
            SetPrize(secondaryGoal);
            SetGoalState(destroyEnemyBase2,goalAchieved);
        }


        if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
        {
            if(GetGoalState(destroyEnemyBase1)!=goalAchieved)
            {
                AddBriefing("translateFailed519");
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
    event Timer1() //wolany co 10 min
    {
        if(!bStartWind)return;
        bStartWind=false;
        AddBriefing("translateBriefing519b");
        Wind(500,15000,500,10,128);
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
}
   