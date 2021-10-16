    //zniszczyæ bazê LC
    //baza znajduje sie w górach nie mozna do niej dotrzeæ
    //obrona przeciwlotnicza wyklucza atak z powietrza.
    //gracz otrzymuje 2 buildery które moga budowaæ artyleriê, elektrowniê i supply center.

    //1 zadanie zdobycie informacji o po³ozeniu bazy i uzyskanie danych dla lotnictwa
    // -pojawiaja sie bombowce i niszcz¹ bazê LC LC-5 Bombowce-4
    //2 zadanie dotarcie do builderów uwiêzionych w podziemiach i ich przejecie.(artefakt) 4
    //3 zadanie zniszczenie bazy LC broni¹cej przejœcia przez mosty 
    //(artefakt który ja niszczy jest w tunelach.Po jego zebraniu wylatuja w powiertze elektrownie i mozna dorznac resztê)
    //4 zadanie ustawienie stanowisk artylerii i wykoñczenie ostatniej bazy. AI3

mission "translateMission513"
{

    consts
    {
        findTargetForBombers = 0;
        destroyLCBase1 = 1;
        findBuilders = 2;
        destroyLCBase2 = 3;
        findPositionForArtillery = 4;
        destroyLCBase3 = 5;
        destroyAllLCUnits = 6;

        primaryGoal = 0;
        hiddenGoal = 2;
        endMission = 3;

        accountMainBase = 1;
        accountResearchBase = 2;
        accountCareerPoints = 3;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Enemy4;
    player p_Neutral;//builders and bombers
    player p_Ally;//bombers
    player p_Player;
    unitex u_Builder1;
    unitex u_Builder2;
    
    int bCheckEndMission;
    int bAccomplisedShowed;
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
            Transfer(accountMainBase,10000);
            Transfer(accountResearchBase,15000);
            Transfer(accountCareerPoints,8);
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
        
    state Initialize;
    state ShowBriefing;
    state Searching;
    state FindingGruzes;
    state FinalBattle;
    state AttackOnBase;
    state Nothing;
        
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
            
        m_bSuccess = true;
        //----------- Goals ------------------
        RegisterGoal(findTargetForBombers,"translateGoal513a");
        RegisterGoal(destroyLCBase1,"translateGoal513b");
        RegisterGoal(findBuilders,"translateGoal513c");
        RegisterGoal(destroyLCBase2,"translateGoal513d");
        RegisterGoal(findPositionForArtillery,"translateGoal513e");
        RegisterGoal(destroyLCBase3,"translateGoal513f");
        RegisterGoal(destroyAllLCUnits,"translateGoal513g");
        
        EnableGoal(findTargetForBombers,true);               
                
                
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(1);
        tmpPlayer.EnableStatistics(false);
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(3);
        p_Enemy2 = GetPlayer(5);
        p_Enemy3 = GetPlayer(8);
        p_Enemy4 = GetPlayer(9);
        p_Neutral = GetPlayer(4);
        p_Ally = GetPlayer(6);
        //----------- AI ---------------------
        p_Neutral.EnableStatistics(false);  
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        p_Enemy1.SetNeutral(p_Neutral);
        p_Enemy2.SetNeutral(p_Neutral);

        if(GetDifficultyLevel()==0)
            p_Enemy1.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy1.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy1.LoadScript("single\\singleHard");

        p_Ally.LoadScript("single\\singleDefault");
        p_Enemy1.LoadScript("single\\singleDefault");
        p_Enemy2.LoadScript("single\\singleDefault");
        p_Enemy3.LoadScript("single\\singleDefault");
        p_Enemy4.LoadScript("single\\singleDefault");

        p_Ally.EnableAIFeatures(aiEnabled,false);
        p_Ally.EnableAIFeatures(aiRejectAlliance,false);
        p_Player.SetAlly(p_Ally);
        
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        
        p_Enemy1.EnableAIFeatures(aiBuildBuildings,false);
        p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
                
        p_Enemy3.EnableAIFeatures(aiBuildBuildings,false);
        p_Enemy3.EnableAIFeatures(aiControlOffense,false);
        
        p_Enemy4.EnableAIFeatures(aiEnabled,false);
        
        p_Ally.SetAlly(p_Neutral);
        p_Enemy1.SetAlly(p_Neutral);
        p_Enemy2.SetAlly(p_Neutral);
        p_Enemy3.SetAlly(p_Neutral);
        p_Enemy4.SetAlly(p_Neutral);

        p_Enemy4.SetAlly(p_Enemy1);
        p_Enemy4.SetAlly(p_Enemy2);
        p_Enemy4.SetAlly(p_Enemy3);
        p_Enemy1.SetAlly(p_Enemy2);
        p_Enemy1.SetAlly(p_Enemy3);
        p_Enemy2.SetAlly(p_Enemy3);

        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);

                
        //----------- Money ------------------
        p_Player.SetMoney(0);
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.SetMoney(20000);
            p_Enemy2.SetMoney(20000);
            p_Enemy3.SetMoney(20000);
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.SetMoney(100000);
            p_Enemy2.SetMoney(120000);
            p_Enemy3.SetMoney(120000);
        }
        p_Neutral.SetMoney(0);
        p_Ally.SetMoney(100000);
        //----------- Researches -------------
        p_Player.EnableResearch("RES_ED_ART", true);//zeby nie bylo jakis researchow
        p_Player.AddResearch("RES_ED_ART");
        p_Player.EnableResearch("RES_ED_ART", false);//zeby nie bylo widac go wynalezionego w drzewie
        
        p_Player.EnableResearch("RES_ED_BC1",true);

        p_Player.EnableResearch("RES_ED_HGen",true);//shield gen 3
        p_Player.EnableResearch("RES_ED_UMI1",true);
        p_Player.EnableResearch("RES_ED_UMW3",true);
        p_Player.EnableResearch("RES_ED_WSR3",true);//SR3
        p_Player.EnableResearch("RES_ED_ASR1",true);//helicopter rocket launcher
        p_Player.EnableResearch("RES_ED_BMD",true);//medium defense building
        p_Player.EnableResearch("RES_ED_SCR2",true);
        


        p_Ally.AddResearch("RES_ED_AB1");
        p_Ally.AddResearch("RES_ED_AB2");
        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,true);                  // 1st tab
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
        p_Player.EnableBuilding("EDBEN1",true);
        p_Player.EnableBuilding("EDBLZ",true);
                    
        
        //----------- Artefacts --------------
        CreateArtefact("NEACOMPUTER",GetPointX(4),GetPointY(4),GetPointZ(4),0,artefactSpecialAIOther);
        CreateArtefact("NEASWITCH2",GetPointX(5),GetPointY(5),GetPointZ(5),1,artefactSpecialAIOther);
        //----------- Units ------------------
        u_Builder1=GetUnit(GetPointX(2),GetPointY(2),GetPointZ(2));
        u_Builder2=GetUnit(GetPointX(3),GetPointY(3),GetPointZ(3));
        //----------- Units ------------------
        if(GetDifficultyLevel()<2)//easy and medium
        {
            KillArea(p_Enemy4.GetIFF(), GetPointX(10), GetPointY(10), 0, 2);
            KillArea(p_Enemy4.GetIFF(), GetPointX(11), GetPointY(11), 0, 2);
            KillArea(p_Enemy4.GetIFF(), GetPointX(12), GetPointY(12), 0, 2);
            KillArea(p_Enemy4.GetIFF(), GetPointX(13), GetPointY(13), 0, 2);
            KillArea(p_Enemy4.GetIFF(), GetPointX(14), GetPointY(14), 0, 2);
            KillArea(p_Enemy4.GetIFF(), GetPointX(15), GetPointY(15), 0, 2);
        }
        if(GetDifficultyLevel()<1)//easy
        {
                KillArea(p_Enemy4.GetIFF(), GetPointX(16), GetPointY(16), 0, 2);
                KillArea(p_Enemy4.GetIFF(), GetPointX(17), GetPointY(17), 0, 2);
                KillArea(p_Enemy4.GetIFF(), GetPointX(18), GetPointY(18), 0, 2);
        }

        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
                bCheckEndMission = false;
                bAccomplisedShowed = false;
                //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing513a");
                Rain(GetPointX(0),GetPointY(0),45,400,5000,800,5); 
                return Searching,1;
    }
    //-----------------------------------------------------------------------------------------  
    state Searching
    {
            unitex u_Bomber;
            int x;
            int y;
            int n_X;
            int n_Y;
            if(p_Player.IsPointLocated(GetPointX(0),GetPointY(0),0))
            {
                if(GetDifficultyLevel()==2)
                    p_Enemy1.EnableAIFeatures(aiControlOffense,true);
                SetGoalState(findTargetForBombers,goalAchieved);
                EnableGoal(destroyLCBase1,true);
                EnableGoal(findBuilders,true);               
                SetConsoleText("translateMessage513");//Bomber attack launched
                AddBriefing("translateBriefing513b");
                for(x=-1;x<2;x=x+1)
                for(y=-1;y<2;y=y+1)
                {
                    n_X = GetPointX(1)+x;
                    n_Y = GetPointY(1)+y;
                    u_Bomber=p_Ally.CreateUnitEx(n_X,n_Y,   0,null,"EDUA32","EDWAB2",null,null,null,0);                  
                    u_Bomber.CommandMove(GetPointX(0),GetPointY(0),0);
                }
                return FindingGruzes,1000;
            }
            return Searching,20;
    }
        //-----------------------------------------------------------------------------------------  
        state FindingGruzes
        {
            SetConsoleText("");
            return FindingGruzes;
        }
        //-----------------------------------------------------------------------------------------  
        state FinalBattle
        {
            if(GetGoalState(destroyLCBase2)==goalAchieved &&
                p_Player.IsPointLocated(GetPointX(7),GetPointY(7),0))
            {
                p_Player.EnableBuilding("EDBART",true);
                p_Player.EnableBuilding("EDBPP",true);
                p_Player.EnableBuilding("EDBAB",true);
                p_Player.EnableBuilding("EDBBA",true);
                p_Player.AddMoney(25000);
                SetGoalState(findPositionForArtillery, goalAchieved);
                AddBriefing("translateBriefing513c");//build artillery
                p_Player.LookAt(GetPointX(7),GetPointY(7),10,128,20,0);
                p_Player.DelayedLookAt(GetPointX(7),GetPointY(7),10,0,20,0,100,1);
                
                if (GetDifficultyLevel()==1)
                    Storm(GetPointX(7),GetPointY(7),15,300,5000,1000,5,3,1);
                if (GetDifficultyLevel()==2)
                    Storm(GetPointX(7),GetPointY(7),15,300,5000,1000,5,3,3);

                return AttackOnBase,1200;
            }
            return FinalBattle;
        }
        //-----------------------------------------------------------------------------------------
        state AttackOnBase
        {
            p_Player.SetScriptData(7,1);
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
                
            if(GetGoalState(destroyAllLCUnits)!=goalAchieved && !p_Enemy1.GetNumberOfUnits())
      {
                    EnableGoal(destroyAllLCUnits,true);               
          SetGoalState(destroyAllLCUnits, goalAchieved);
          SetPrize(hiddenGoal);
      }
      //JS zmiana playerow bo byli nie tacy jak trzeba
            if(!p_Enemy2.GetNumberOfBuildings() && GetGoalState(destroyLCBase1)!=goalAchieved)
      {
                  SetGoalState(destroyLCBase1,goalAchieved);
                    p_Ally.GiveAllBuildingsTo(p_Player);//xxxmd
                    //JS wykomentowane bo LC od razu zabijali tunel u gory po prawej
          //p_Neutral.GiveAllBuildingsTo(p_Player);
          if (GetDifficultyLevel()==0)
          {
            p_Neutral.EnableAIFeatures(aiRejectAlliance,false);
            p_Player.SetAlly(p_Neutral);
          }
                    if (GetDifficultyLevel()==0)
                        Storm(GetPointX(1),GetPointY(1),15,300,5000,1000,5,5,1);
                    if (GetDifficultyLevel()==1)
                        Storm(GetPointX(1),GetPointY(1),15,300,5000,1000,5,5,5);
                    if (GetDifficultyLevel()==2)
                        Storm(GetPointX(1),GetPointY(1),15,300,5000,1000,5,5,10);
            }

            if(!p_Enemy3.GetNumberOfBuildings() && GetGoalState(destroyLCBase2)!=goalAchieved)
      {
                  SetGoalState(destroyLCBase2,goalAchieved);
                    EnableGoal(findPositionForArtillery,true);
                    EnableGoal(destroyLCBase3,true);
            }

            if(!p_Enemy1.GetNumberOfBuildings() && GetGoalState(destroyLCBase3)!=goalAchieved)
      {
                  SetGoalState(destroyLCBase3,goalAchieved);
            }

            if(!bAccomplisedShowed &&
                        GetGoalState(destroyLCBase1)==goalAchieved &&
                        GetGoalState(destroyLCBase2)==goalAchieved &&
                        GetGoalState(destroyLCBase3)==goalAchieved)
            {
                bAccomplisedShowed=true;
                SetPrize(primaryGoal);
                AddBriefing("translateAccomplished513");
                m_bSuccess = true;
                EnableEndMissionButton(true);
            }
                

      if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
      {
                  if(GetGoalState(destroyLCBase1)!=goalAchieved||
                        GetGoalState(destroyLCBase2)!=goalAchieved||
                        GetGoalState(destroyLCBase3)!=goalAchieved)
                    {
                        AddBriefing("translateFailed513");
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
        if(aID==0)//builders    
        {
            u_Builder1.ChangePlayer(p_Player);
            u_Builder2.ChangePlayer(p_Player);
            p_Player.AddMoney(5000);
            SetGoalState(findBuilders,goalAchieved);
            EnableGoal(destroyLCBase2,true);
            AddBriefing("translateBriefing513GoalGruz");
            state FinalBattle;
            return true; //usuwa sie 
        }

        if(aID==1)//detonator
        {
            KillArea(256,GetPointX(6),GetPointY(6),GetPointZ(6),4);
            CreateArtefact("NEASWITCH1",GetPointX(5),GetPointY(5),GetPointZ(5),4,artefactSpecialAIOther);
            AddBriefing("translateBriefing513GoalDetonator");
            return true; //usuwa sie 
        }
        return false; //usuwa sie 
    }

}
   