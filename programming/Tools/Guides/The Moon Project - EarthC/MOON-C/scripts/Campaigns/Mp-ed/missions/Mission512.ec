mission "translateMission512"
{//Rescue mission

// stoi artefakt kolo niego unit (amfibia)
// odnalezienie ich przed up³ywem 4 godzin (2 goale zaliczone)
// odnalezienie po tym terminie 1 goal zaliczony.
// strata bazy - przegrana
// odnalezienie i zniszczenie wszystkich UCSów - hidden goal.
// po2 dniach bombowce UCS przylatuj¹ i robi¹ nalot (startuje z markera 7)
// easy 1 med 2 hard 3.


    consts
    {
        findTransmiter = 0;
                rescueSpy = 1;
        destroyAllUCSUnits = 2;

                primaryGoal = 0;
                secondaryGoal = 1;
                hiddenGoal = 2;
                endMission = 3;

                accountMainBase = 1;
                accountResearchBase = 2;
                accountCareerPoints = 3;

    }
    
    player p_Enemy;
    player p_Neutral;
    player p_Player;
    unitex u_Radar1;
    unitex u_Radar2;
        unitex u_Rescuer;
    
    int nWayPoint;
    int bCheckEndMission;
        int nRescueTime;
        int nAttackTime;
        int n_Transmiter_X;
        int n_Transmiter_Y;
    int m_bSuccess;
        int nTimeLeft;

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
                Transfer(accountMainBase,3000);
                Transfer(accountCareerPoints,7);
            }
            if(reason==hiddenGoal)
            {
                Transfer(accountMainBase,3000);
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
    state PostInitialize;
    state ShowBriefing;
    state Searching;
        state Escapeing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;

        m_bSuccess = true;
                if(GetDifficultyLevel()==0)
                {
                    nRescueTime=12;//godzin
                    nAttackTime=18;//godzin gry
                }
                if(GetDifficultyLevel()==1)
                {
                    nRescueTime=6;//godzin
                    nAttackTime=12;//godzin gry
                }
                if(GetDifficultyLevel()==2)
                {
                    nRescueTime=3;//godzin
                    nAttackTime=9;//godzin gry
                }
                nTimeLeft=nRescueTime;
        //----------- Goals ------------------
                RegisterGoal(findTransmiter,"translateGoal512a");
                RegisterGoal(rescueSpy,"translateGoal512b",nRescueTime);
                RegisterGoal(destroyAllUCSUnits,"translateGoal512c");

                EnableGoal(findTransmiter,true);               
                EnableGoal(rescueSpy,true);               
        //----------- Temporary players ------
                tmpPlayer = GetPlayer(3);
                tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
                p_Enemy = GetPlayer(1);
        p_Neutral = GetPlayer(4);
        //----------- AI ---------------------
        p_Neutral.EnableStatistics(false);  
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);

        p_Enemy.LoadScript("single\\singleDefault");

        p_Enemy.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Enemy);

        p_Neutral.EnableAIFeatures(aiEnabled,false);
        p_Enemy.EnableAIFeatures(aiEnabled,false);
        
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_Enemy.SetMoney(0);
        p_Neutral.SetMoney(0);
        //----------- Researches -------------
        p_Player.EnableResearch("RES_ED_UMW2",true);
        p_Player.EnableResearch("RES_EDUUT",true);
        p_Player.EnableResearch("RES_ED_ACH2",true);
        p_Player.EnableResearch("RES_ED_WSL3",true);
        p_Player.EnableResearch("RES_ED_MSC3",true);
        p_Player.EnableResearch("RES_MCH3",true);
        p_Player.EnableResearch("RES_ED_SCR",true);

        //----------- Buildings --------------
        p_Player.EnableBuilding("EDBRC",false);
        //----------- Units ------------------
        u_Radar2 = GetUnit(GetPointX(0),GetPointY(0),0);
        u_Radar1 = GetUnit(GetPointX(1),GetPointY(1),0);
        u_Radar1.SetUnitName("translate512scaner1");
        u_Radar2.SetUnitName("translate512scaner2");
        p_Player.AddUnitToSpecialTab(u_Radar1,true, -1);
        p_Player.AddUnitToSpecialTab(u_Radar2,true, -1);
        //----------- Artefacts --------------
        //JS - przeniesienie tworzenia artefaktow do drugiego state'a po to
        //aby przy restart generowalo za kazdym razem inna pozycje
        //(bo save restart jest po pierwszym stepie AIWorld'a)

                if(GetDifficultyLevel()>0)//medium
                {//jednostki wroga
                        p_Enemy.CreateUnitEx(GetPointX(2)-1,GetPointY(2)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(3)-1,GetPointY(3)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(4)-1,GetPointY(4)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(5)-1,GetPointY(5)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(6)-1,GetPointY(6)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(7)-1,GetPointY(7)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                }
                if(GetDifficultyLevel()==2)//hard
                {
                        p_Enemy.CreateUnitEx(GetPointX(2),GetPointY(2)-1,  0,null,"UCSUSL3","UCSWTSR2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(3),GetPointY(3)-1,  0,null,"UCSUSL3","UCSWTSR2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(4),GetPointY(4)-1,  0,null,"UCSUSL3","UCSWTSR2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(5),GetPointY(5)-1,  0,null,"UCSUSL3","UCSWTSR2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(6),GetPointY(6)-1,  0,null,"UCSUSL3","UCSWTSR2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(7),GetPointY(7)-1,  0,null,"UCSUSL3","UCSWTSR2",null,null,null,0);                  
                        
                        p_Enemy.CreateUnitEx(GetPointX(2)+1,GetPointY(2)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(3)+1,GetPointY(3)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(4)+1,GetPointY(4)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(5)+1,GetPointY(5)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(6)+1,GetPointY(6)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                        p_Enemy.CreateUnitEx(GetPointX(7)+1,GetPointY(7)-1,  0,null,"UCSUSL3","UCSWTSP2",null,null,null,0);                  
                }
                
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        nWayPoint=1;
                bCheckEndMission=false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return PostInitialize,0;
    }
    //-----------------------------------------------------------------------------------------
    state PostInitialize
    {
        int n_Rnd;
        //----------- Artefacts --------------
        n_Rnd = Rand(6)+2;
        TraceD("Rnd= ");TraceD(n_Rnd);TraceD("        \n");
        n_Transmiter_X = GetPointX(n_Rnd);
        n_Transmiter_Y = GetPointY(n_Rnd);
        p_Neutral.CreateUnitEx(n_Transmiter_X+1,n_Transmiter_Y,  0,null,"EDUMW3","EDWCH1",null,null,null,0);                  
        CreateArtefact("NEASPECIAL1",n_Transmiter_X,n_Transmiter_Y,0,0,artefactSpecialAIOther);
        return ShowBriefing,99;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);//513
        AddBriefing("translateBriefing512",nRescueTime);
                Snow(GetPointX(0),GetPointY(0),45,400,5000,800,10); 
                return Searching,1;
    }
    //-----------------------------------------------------------------------------------------  
    state Searching
    {
            int n_Dist1;
            int n_Dist2;
            n_Dist1=u_Radar1.DistanceTo(n_Transmiter_X,n_Transmiter_Y);
            n_Dist2=u_Radar2.DistanceTo(n_Transmiter_X,n_Transmiter_Y);
            SetConsoleText("translateMessage512",n_Dist1*8,n_Dist2*8,nTimeLeft);
            if(GetGoalState(findTransmiter)==goalAchieved)
            {
                SetConsoleText("");
                return Escapeing,20;
            }
            return Searching,20;
    }
        //-----------------------------------------------------------------------------------------  
    state Escapeing
    {
            if(GetGoalState(rescueSpy)==goalNotAchieved && u_Rescuer!=null)
            {
                if(u_Rescuer.DistanceTo(GetPointX(0),GetPointY(0))<7)
                {
                    SetGoalState(rescueSpy,goalAchieved);
                    SetPrize(secondaryGoal);
                    AddBriefing("translateAccomplished512c");
                    u_Rescuer=null;
                }
            }
            return Escapeing,20;
    }

    //-----------------------------------------------------------------------------------------
    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
            
            //clicksPerDay = 16383;
            //clicksPerHour = 683;
            nTimeLeft = nRescueTime*683 - GetMissionTime();
            
            if(nTimeLeft<0)
            {
                nTimeLeft=0;
                if(GetGoalState(findTransmiter)==goalNotAchieved)
                    SetGoalState(rescueSpy,goalFailed);
            }
            else
                nTimeLeft=(nTimeLeft/683)+1;
            RegisterGoal(rescueSpy,"translateGoal512b",nTimeLeft);
            
            if(nAttackTime && (nAttackTime*683)<GetMissionTime())
            {//atak UCS
                nAttackTime=0;
                p_Enemy.CreateUnitEx(GetPointX(0),GetPointY(0)+8,  0,null,"UCSUA32","UCSWAPB2",null,null,null,0);                  
                if(GetDifficultyLevel()==1)
                    p_Enemy.CreateUnitEx(GetPointX(0)+1,GetPointY(0)+8,  0,null,"UCSUA32","UCSWAPB2",null,null,null,0);                  
                if(GetDifficultyLevel()==2)
                    p_Enemy.CreateUnitEx(GetPointX(0)-1,GetPointY(0)+8,  0,null,"UCSUA32","UCSWAPB2",null,null,null,0);                  

            }

            if(!bCheckEndMission)return;

            bCheckEndMission=false;
            
            if(GetGoalState(rescueSpy)==goalNotAchieved && u_Rescuer!=null)
            {
                if(!u_Rescuer.IsLive())
                {
                    SetGoalState(rescueSpy,goalFailed);
                    u_Rescuer=null;
                }
            }

            if(GetGoalState(destroyAllUCSUnits)!=goalAchieved && !p_Enemy.GetNumberOfUnits())
      {
                    EnableGoal(destroyAllUCSUnits,true);               
          SetGoalState(destroyAllUCSUnits, goalAchieved);
          SetPrize(hiddenGoal);
      }
      if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
      {
                  if(GetGoalState(findTransmiter)!=goalAchieved)
                    {
                        AddBriefing("translateFailed512");
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
   //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
              if(piPlayer!=p_Player) return false;
        EnableNextMission(1,true);//514
                SetGoalState(findTransmiter,goalAchieved);
                if(GetGoalState(rescueSpy)==goalNotAchieved)
                {
                    u_Rescuer = GetUnit(n_Transmiter_X,n_Transmiter_Y);
                    AddBriefing("translateAccomplished512a");
                }
                else
                {
                    AddBriefing("translateAccomplished512b");
                }
                SetPrize(primaryGoal);
        m_bSuccess = true;
                EnableEndMissionButton(true);
                return true; //usuwa sie 
    }

}
