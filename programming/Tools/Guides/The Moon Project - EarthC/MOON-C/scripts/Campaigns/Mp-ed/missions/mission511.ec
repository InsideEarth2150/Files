mission "translateMission511"
{//Escort convoy
    consts
    {
        escortConvoy = 0;
        destroyLCBase = 1;
                destroyAllLCUnits = 2;
                allConvoySurvived = 3;

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
    unitex p_ConvoyCraft1;
    unitex p_ConvoyCraft2;
    unitex p_ConvoyCraft3;
    unitex p_ConvoyCraft4;
        unitex p_ConvoyCraft5;
    unitex p_ConvoyCraft6;
    
    int nWayPoint;
    int bCheckEndMission;
    int m_bSuccess;
        int bAIActivated;
        int bShowBriefingB;
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
                Transfer(accountMainBase,3000);
                Transfer(accountResearchBase,15000);
                Transfer(accountCareerPoints,2);
            }
            if(reason==secondaryGoal)
            {
                //Transfer(accountMainBase,3000);
                Transfer(accountCareerPoints,5);
            }
            if(reason==hiddenGoal)//2x
            {
                Transfer(accountMainBase,3000);
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
    state OnTheWay;
    state Fight;
    state Final;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;

        m_bSuccess = true;
        //----------- Goals ------------------
                if(GetDifficultyLevel()==0)
                    RegisterGoal(escortConvoy,"translateGoal511a",2);
                if(GetDifficultyLevel()==1)
                    RegisterGoal(escortConvoy,"translateGoal511a",4);
                if(GetDifficultyLevel()==2)
                    RegisterGoal(escortConvoy,"translateGoal511a",6);

        RegisterGoal(destroyLCBase,"translateGoal511b");
                RegisterGoal(destroyAllLCUnits,"translateGoal511c");
                RegisterGoal(allConvoySurvived,"translateGoal511d");
            
                EnableGoal(escortConvoy,true);               
                
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
        p_Enemy2.EnableStatistics(false);
        
        p_Enemy1.LoadScript("single\\singleDefault");

                if(GetDifficultyLevel()==2)
                    p_Enemy1.LoadScript("single\\singleHard");
        
                p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        
                p_Neutral.EnableAIFeatures(aiRejectAlliance,false);
                
                if(GetDifficultyLevel()==0)
                    p_Player.SetAlly(p_Neutral);

        p_Neutral.ChooseEnemy(p_Enemy1);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiEnabled,false);
        p_Enemy2.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_Enemy1.SetMoney(20000);
        p_Enemy2.SetMoney(0);
                p_Neutral.SetMoney(0);
        //----------- Researches -------------
        p_Enemy1.AddResearch("RES_LC_SGen");
        p_Enemy1.AddResearch("RES_LC_MGen");
        p_Enemy1.AddResearch("RES_LC_HGen");
                
        p_Player.EnableResearch("RES_ED_UML3",true);
        p_Player.EnableResearch("RES_ED_UA22",true);
        p_Player.EnableResearch("RES_ED_MGen",true);//shield gen 2
        p_Player.EnableResearch("RES_ED_WSR2",true);
        p_Player.EnableResearch("RES_EDWAN1",true);
        p_Player.EnableResearch("RES_ED_WSL2",true);
        p_Player.EnableResearch("RES_ED_WSI2",true);
        p_Player.EnableResearch("RES_ED_MSC2",true);
        p_Player.EnableResearch("RES_MCH2",true);

        
        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        //----------- Units ------------------
        p_ConvoyCraft1 = GetUnit(GetPointX(0),GetPointY(0),0);
        p_ConvoyCraft2 = GetUnit(GetPointX(1),GetPointY(1),0);
        p_ConvoyCraft3 = GetUnit(GetPointX(2),GetPointY(2),0);
        p_ConvoyCraft4 = GetUnit(GetPointX(3),GetPointY(3),0);
        p_ConvoyCraft5 = GetUnit(GetPointX(4),GetPointY(4),0);
        p_ConvoyCraft6 = GetUnit(GetPointX(5),GetPointY(5),0);
        //----------- Artefacts --------------
                if(GetDifficultyLevel()==0)
                {
                    KillArea(p_Enemy2.GetIFF(), GetPointX(15), GetPointY(15), 0, 1);
                    KillArea(p_Enemy2.GetIFF(), GetPointX(16), GetPointY(16), 0, 1);
                    KillArea(p_Enemy2.GetIFF(), GetPointX(17), GetPointY(17), 0, 1);
                    KillArea(p_Enemy2.GetIFF(), GetPointX(18), GetPointY(18), 0, 1);
                    KillArea(p_Enemy2.GetIFF(), GetPointX(19), GetPointY(19), 0, 1);
                    KillArea(p_Enemy2.GetIFF(), GetPointX(20), GetPointY(20), 0, 1);
                    KillArea(p_Enemy2.GetIFF(), GetPointX(21), GetPointY(21), 0, 1);
                }
                if(GetDifficultyLevel()==1)
                {
                    KillArea(p_Enemy2.GetIFF(), GetPointX(15), GetPointY(15), 0, 1);
                    KillArea(p_Enemy2.GetIFF(), GetPointX(19), GetPointY(19), 0, 1);
                    KillArea(p_Enemy2.GetIFF(), GetPointX(20), GetPointY(20), 0, 1);
                }
                
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        nWayPoint=1;
                bCheckEndMission=false;
                bAIActivated=false;
                bShowBriefingB=true;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        if(GetDifficultyLevel()==0)
                    AddBriefing("translateBriefing511a",2);
                    
                if(GetDifficultyLevel()==1)
                    AddBriefing("translateBriefing511a",4);
                    
                if(GetDifficultyLevel()==2)
                    AddBriefing("translateBriefing511a",6);
                    
                Snow(GetPointX(6),GetPointY(6),45,400,5000,800,10); 
                Snow(GetPointX(7),GetPointY(7),45,400,5000,800,10); 
        return OnTheWay,300;
    }
    //-----------------------------------------------------------------------------------------  
    state OnTheWay
    {
                int nGoToPoint;
                int bMakeStep;
                int nTrucksFinished;
                int nTrucksAlive;
                int j;

                bMakeStep=false;
                
                if(bShowBriefingB)
                {
                    for(j=24;j<34 && bShowBriefingB==true;j=j+1)
                    {
                        if(p_Player.IsPointLocated(GetPointX(j),GetPointY(j),0))
                        {
                            bShowBriefingB=false;
                            EnableGoal(destroyLCBase,true);               
                            AddBriefing("translateBriefing511b");
                        }
                    }
                }

                if(nWayPoint==1)
                {
                    if(p_Player.IsPointLocated(GetPointX(6),GetPointY(6),0))
                    {
                        nGoToPoint=6;
                        bMakeStep=true;
                    }
                    if(p_Player.IsPointLocated(GetPointX(7),GetPointY(7),0))
                    {
                        nGoToPoint=7;
                        bMakeStep=true;
                    }
                }
                if(nWayPoint==2)
                {
                    if(p_Player.IsPointLocated(GetPointX(8),GetPointY(8),0))
                    {
                        nGoToPoint=8;
                        bMakeStep=true;
                        Snow(GetPointX(10),GetPointY(10),45,400,5000,800,10); 
                        Snow(GetPointX(13),GetPointY(13),45,400,5000,800,10); 
                    }
                    if(p_Player.IsPointLocated(GetPointX(9),GetPointY(9),0))
                    {
                        nGoToPoint=9;
                        bMakeStep=true;
                        Snow(GetPointX(10),GetPointY(10),45,400,5000,800,10); 
                        Snow(GetPointX(13),GetPointY(13),45,400,5000,800,10); 
                    }
                }
        if(GetDifficultyLevel()==2 && nWayPoint==3 &&!bAIActivated)
                {
                    bAIActivated=true;
                    p_Enemy1.EnableAIFeatures(aiEnabled,true);
                }
                if(nWayPoint>2) 
        {
                    nGoToPoint=nWayPoint+7;
                    if(p_Player.IsPointLocated(GetPointX(nGoToPoint),GetPointY(nGoToPoint),0))
                        bMakeStep=true;
                }
                
                if(bMakeStep || nWayPoint>5)
                {
                    if(nWayPoint<6)nWayPoint=nWayPoint+1;
                    p_ConvoyCraft1.CommandMove(GetPointX(nGoToPoint),GetPointY(nGoToPoint),0);
                    p_ConvoyCraft2.CommandMove(GetPointX(nGoToPoint),GetPointY(nGoToPoint),0);
                    p_ConvoyCraft3.CommandMove(GetPointX(nGoToPoint),GetPointY(nGoToPoint),0);
                    p_ConvoyCraft4.CommandMove(GetPointX(nGoToPoint),GetPointY(nGoToPoint),0);
                    p_ConvoyCraft5.CommandMove(GetPointX(nGoToPoint),GetPointY(nGoToPoint),0);
                    p_ConvoyCraft6.CommandMove(GetPointX(nGoToPoint),GetPointY(nGoToPoint),0);
                }
        if(nWayPoint>5) 
                {
                    nTrucksAlive=0;
                        if(p_ConvoyCraft1.IsLive())nTrucksAlive=nTrucksAlive+1;
            if(p_ConvoyCraft2.IsLive())nTrucksAlive=nTrucksAlive+1;
                        if(p_ConvoyCraft3.IsLive())nTrucksAlive=nTrucksAlive+1;
                        if(p_ConvoyCraft4.IsLive())nTrucksAlive=nTrucksAlive+1;
                        if(p_ConvoyCraft5.IsLive())nTrucksAlive=nTrucksAlive+1;
                        if(p_ConvoyCraft6.IsLive())nTrucksAlive=nTrucksAlive+1;

                    nTrucksFinished=0;
                        if(p_ConvoyCraft1.IsLive() && p_ConvoyCraft1.DistanceTo(GetPointX(13),GetPointY(13)) < 7)nTrucksFinished=nTrucksFinished+1;
            if(p_ConvoyCraft2.IsLive() && p_ConvoyCraft2.DistanceTo(GetPointX(13),GetPointY(13)) < 7)nTrucksFinished=nTrucksFinished+1;
                        if(p_ConvoyCraft3.IsLive() && p_ConvoyCraft3.DistanceTo(GetPointX(13),GetPointY(13)) < 7)nTrucksFinished=nTrucksFinished+1;
                        if(p_ConvoyCraft4.IsLive() && p_ConvoyCraft4.DistanceTo(GetPointX(13),GetPointY(13)) < 7)nTrucksFinished=nTrucksFinished+1;
                        if(p_ConvoyCraft5.IsLive() && p_ConvoyCraft5.DistanceTo(GetPointX(13),GetPointY(13)) < 7)nTrucksFinished=nTrucksFinished+1;
                        if(p_ConvoyCraft6.IsLive() && p_ConvoyCraft6.DistanceTo(GetPointX(13),GetPointY(13)) < 7)nTrucksFinished=nTrucksFinished+1;

                        if(
                             nTrucksAlive==nTrucksFinished &&(
                             ((GetDifficultyLevel()==0 && nTrucksFinished>1)||
                             ((GetDifficultyLevel()==1)&& nTrucksFinished>3)||
                             ((GetDifficultyLevel()==2)&& nTrucksFinished>5))))
                        {
                            SetGoalState(escortConvoy, goalAchieved);
                            
                            if(nTrucksFinished==6)
                            {
                                EnableGoal(allConvoySurvived,true);               
                                SetGoalState(allConvoySurvived, goalAchieved);
                                SetPrize(hiddenGoal);
                                AddBriefing("translateAccomplished511b");
                            }
                            else
                                AddBriefing("translateAccomplished511a");
                            p_Player.CreateUnitEx(GetPointX(22),GetPointY(22),  0,null,"EDUSPECIAL","EDWSPECIAL",null,null,null,0);                  
                            p_Player.CreateUnitEx(GetPointX(23),GetPointY(23),  0,null,"EDUSPECIAL","EDWSPECIAL",null,null,null,0);                  
                            SetPrize(primaryGoal);
              m_bSuccess = true;
                            EnableEndMissionButton(true);
                            return Fight,100;
                        }
            
        }
        return OnTheWay,300;
    }
    //-----------------------------------------------------------------------------------------
    state Fight
    {
        if(!p_Enemy1.GetNumberOfBuildings())
        {
            SetGoalState(destroyLCBase, goalAchieved);
            AddBriefing("translateAccomplished511c");
                        SetPrize(secondaryGoal);
            return Final,500;
        }
        return Fight,200;
    }
    //-----------------------------------------------------------------------------------------
    state Final
    {
        return Final,500;
    }
    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
            int nLostConvoyCrafts;
            
            if(!bCheckEndMission)return;

            bCheckEndMission=false;
                
            if(GetGoalState(escortConvoy)!=goalFailed && GetGoalState(escortConvoy)!=goalAchieved )
            {
                    if(!p_ConvoyCraft1.IsLive())nLostConvoyCrafts=1;
                    if(!p_ConvoyCraft2.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;
                    if(!p_ConvoyCraft3.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;
                    if(!p_ConvoyCraft4.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;
                    if(!p_ConvoyCraft5.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;
                    if(!p_ConvoyCraft6.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;
       
                    if(
                         ((GetDifficultyLevel()==0 && nLostConvoyCrafts>4)||
                         ((GetDifficultyLevel()==1)&& nLostConvoyCrafts>2)||
                         ((GetDifficultyLevel()==2)&& nLostConvoyCrafts>0)))
                    {
                        SetGoalState(escortConvoy, goalFailed);
                        AddBriefing("translateFailed511a");
                        m_bSuccess = false;
                        EnableEndMissionButton(true,false);
                        state Final;
                    }
            }
            
            if(GetGoalState(destroyAllLCUnits)!=goalAchieved && 
                !p_Enemy2.GetNumberOfUnits()&& !p_Enemy1.GetNumberOfUnits())
      {
                    EnableGoal(destroyAllLCUnits,true);               
          SetGoalState(destroyAllLCUnits, goalAchieved);
          SetPrize(hiddenGoal);
      }
      if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
      {
                  if(GetGoalState(escortConvoy)!=goalAchieved)
                    {
                        AddBriefing("translateFailed511b");
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
        p_Neutral.SetEnemy(p_Player);
        p_Player.SetEnemy(p_Neutral);
        p_Neutral.EnableAIFeatures(aiRejectAlliance,true);
    }
}
