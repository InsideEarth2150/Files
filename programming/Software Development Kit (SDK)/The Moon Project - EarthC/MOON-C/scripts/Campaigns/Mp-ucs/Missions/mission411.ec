mission "translateMission411"
{
    consts
    {
        RescueGrizzli1 = 0;
        RescueGrizzli2 = 1;
        LocateLCBase = 2;
        DestroyLC = 3;
        CaptureCPU = 4;
    }

    player p_Enemy;
    player p_Escort1;
    player p_Escort2;
    player p_Player;
    player p_Grizzli1;
    player p_Grizzli2;
    player p_Teleport;

    unitex u_Grizzli1;
    unitex u_Grizzli2;

    int DestroyLCAchieved;
    int RescueGrizzliAchieved1;
    int RescueGrizzliAchieved2;
    int CaptureCPUAchieved;
    int LCBaseLocated;

    int xLCBase;
    int yLCBase;

    int i;
    
    state Initialize;
    state ShowVideo;
    state ShowBriefing;
    state Working;
    state Nothing;
    state EndMissionFailed;
    state EndMissionState;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {

        //----------- Extra ------------------
        EnableGameFeature(lockResearchDialog,true);
        EnableGameFeature(lockConstructionDialog,true);
        EnableGameFeature(lockUpgradeWeaponDialog,true);

        DestroyLCAchieved = false;
        RescueGrizzliAchieved1 = false;
        RescueGrizzliAchieved2 = false;
        CaptureCPUAchieved = false;
        LCBaseLocated = false;


        //----------- Goals ------------------
        RegisterGoal(RescueGrizzli1, "translateGoalRescueGrizzli1");
        RegisterGoal(RescueGrizzli2, "translateGoalRescueGrizzli2");
        RegisterGoal(LocateLCBase, "translateGoalLocateLCBase");
        RegisterGoal(DestroyLC,     "translateGoalDestroyLC");              
        RegisterGoal(CaptureCPU,    "translateGoalCaptureCPU");

                //---show goals on list---
        EnableGoal(DestroyLC,false);
        EnableGoal(RescueGrizzli1,true);
        EnableGoal(RescueGrizzli2,true);
        EnableGoal(LocateLCBase,true);
        EnableGoal(CaptureCPU,false);
                

        
        //----------- Players ----------------
        p_Player = GetPlayer(1);    //ja czyli UCS
        p_Enemy = GetPlayer(3); //LC
        p_Grizzli1 = GetPlayer(5);  //gracz do przejecia
        p_Grizzli2 = GetPlayer(4);  //gracz do przejecia
        p_Teleport = GetPlayer(6);
        p_Escort1 = GetPlayer(8);
        p_Escort2 = GetPlayer(7);

        p_Grizzli1.EnableStatistics(false);
        p_Grizzli2.EnableStatistics(false);
        p_Escort1.EnableStatistics(false);
        p_Escort2.EnableStatistics(false);
        p_Teleport.EnableStatistics(false);


        //----------- AI ---------------------
        
        p_Enemy.LoadScript("single\\singleMedium");
        p_Escort1.LoadScript("single\\singleMedium");
        p_Escort2.LoadScript("single\\singleMedium");
    
        //---Grizzli as neutral----------------
        p_Grizzli1.EnableAIFeatures(aiControlOffense, false);

        p_Grizzli1.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Grizzli1);

        p_Grizzli1.SetNeutral(p_Escort1);
        p_Escort1.SetNeutral(p_Grizzli1);


        p_Grizzli2.EnableAIFeatures(aiControlOffense, false);
        p_Player.SetNeutral(p_Grizzli2);
        p_Grizzli2.SetNeutral(p_Player);

        p_Grizzli2.SetNeutral(p_Escort2);
        p_Escort2.SetNeutral(p_Grizzli2);


        //--- don't attack Teleport please ---
        p_Enemy.SetNeutral(p_Teleport);
        p_Player.SetNeutral(p_Teleport);


        //----------- Variables --------------
        xLCBase = GetPointX(0);
        yLCBase = GetPointY(0);


        //----AI off-------------
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        p_Enemy.EnableAIFeatures(aiControlDefense,false);
                p_Enemy.EnableAIFeatures(aiBuildBuildings,false);

        p_Escort1.EnableAIFeatures(aiControlOffense,false);
        p_Escort1.EnableAIFeatures(aiControlDefense,false);

        p_Escort2.EnableAIFeatures(aiControlOffense,false);
        p_Escort2.EnableAIFeatures(aiControlDefense,false);

        
        //----------- Money ------------------
        p_Enemy.SetMoney(5000);

        p_Enemy.EnableResearch("RES_LC_SGen",true);
        p_Enemy.EnableResearch("RES_LC_BMD",true);
        p_Enemy.EnableResearch("RES_MCH2",true);

    
        //---Artefacts : computers to capture ----
        CreateArtefact("NEACOMPUTER", GetPointX(3), GetPointY(3),  GetPointZ(3),0,artefactSpecialAIOther);
    
        p_Escort1.SetAlly(p_Enemy);
        p_Escort2.SetAlly(p_Enemy);

        //----units-------------------------------
        u_Grizzli1 = GetUnit(GetPointX(1),GetPointY(1),GetPointZ(1));
        u_Grizzli2 = GetUnit(GetPointX(2),GetPointY(2),GetPointZ(2));
        u_Grizzli1.SetUnitName("translateGrizzli1");
        u_Grizzli2.SetUnitName("translateGrizzli2");
        
        u_Grizzli1.LoadScript("Scripts\\Units\\Tank.ecomp");
        u_Grizzli2.LoadScript("Scripts\\Units\\Tank.ecomp");
        //------Timers------------------------  
        SetTimer(0, 100);

        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(), 6, 0, 20, 0);
        return ShowVideo;
    }

    //-----------------------------------------------------------------------------------------
    state ShowVideo
    {
        ShowVideo("Cutscene1");
        return ShowBriefing,100;
    }
    state ShowBriefing
    {
        ShowArea(p_Player.GetIFF(), GetPointX(1), GetPointY(1), 0, 2);
        ShowArea(p_Player.GetIFF(), GetPointX(2), GetPointY(2), 0, 2);
        AddBriefing("translateBriefing411a", p_Player.GetName());   //D:+name
        MeteorRain(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),20,500,30000,100,1,1);
        //EnableEndMissionButton(true);//XXXMD
        return Working;
    }


        //-----------------------------------------------------------------------------------------
        state Working
        {
            if(!p_Player.GetNumberOfUnits())
            {
                AddBriefing("translateFailed411", p_Player.GetName());
                return EndMissionFailed;
            }

            //--------- check goals --------------------------------

            //----capture LC base---

            if(GetGoalState(DestroyLC)!=goalAchieved && !p_Enemy.GetNumberOfBuildings())
            {
                SetGoalState(DestroyLC, goalAchieved);
                AddBriefing("translateBriefing411e", p_Player.GetName());//LC base has been destroyed
                DestroyLCAchieved = true;
            }

            //---free Grizzli1---
            if(GetGoalState(RescueGrizzli1)!= goalAchieved && !p_Escort1.GetNumberOfUnits())
            {
                MeteorRain(p_Grizzli1.GetStartingPointX(), p_Grizzli1.GetStartingPointY(),20,100,30000,100,1,1);
                p_Grizzli1.GiveAllUnitsTo(p_Player);
                SetGoalState(RescueGrizzli1, goalAchieved);
                AddBriefing("translateBriefing411c", p_Player.GetName());//grizzli 1 recovered
                p_Player.AddUnitToSpecialTab(u_Grizzli1,true, -1);
            }

            //---free Grizzli2---
            if(GetGoalState(RescueGrizzli2)!=goalAchieved && !p_Escort2.GetNumberOfUnits())
            {
                MeteorRain(p_Grizzli2.GetStartingPointX(), p_Grizzli2.GetStartingPointY(),20,100,30000,100,1,1);
                p_Grizzli2.GiveAllUnitsTo(p_Player);
                SetGoalState(RescueGrizzli2, goalAchieved);
                AddBriefing("translateBriefing411d", p_Player.GetName());   //grizzli 2 recovered
                p_Player.AddUnitToSpecialTab(u_Grizzli2,true, -1);
            }
        
            //---LC base located---
            if(!LCBaseLocated && p_Player.IsPointLocated(xLCBase, yLCBase))
            {           
                SetGoalState(LocateLCBase, goalAchieved);
                EnableGoal(CaptureCPU,true);
                EnableGoal(DestroyLC,true);
                AddBriefing("translateBriefing411b", p_Player.GetName());   //D+name
                LCBaseLocated=true;
            }
        

            //-----check the goal----------
            
            //--- misja wykonana calkowicie ---
            if(DestroyLCAchieved && CaptureCPUAchieved&&
                GetGoalState(RescueGrizzli1)==goalAchieved&&
                GetGoalState(RescueGrizzli2)==goalAchieved)
            {
                EnableNextMission(0,true);
                AddBriefing("translateAccomplished411", p_Player.GetName());//D+name
                
                return EndMissionState;
            }

            return Working;
        }
        //-----------------------------------------------------------------------------------------
        state EndMissionFailed
        {
            EnableNextMission(0,2);
            ShowVideo("");
            return Nothing;
        }
        //-----------------------------------------------------------------------------------------
        state EndMissionState
        {
            EndMission(true);
        }

    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------

        event Timer0()
        {
        //  TraceD(p_Enemy.GetMoney());
        //  TraceD("           \n");
            if(!u_Grizzli1.IsLive())
      {
          AddBriefing("translateGrizzli1Killed",p_Player.GetName());
          state EndMissionFailed;
      }
            if(!u_Grizzli2.IsLive())
      {
          AddBriefing("translateGrizzli2Killed",p_Player.GetName());
          state EndMissionFailed;
      }
        }

        //---capture CPU---------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
                CaptureCPUAchieved = true;
                SetGoalState(CaptureCPU, goalAchieved);
                ShowArea(p_Player.GetIFF(), GetPointX(3), GetPointY(3), 1, 200);
                AddBriefing("translateBriefing411f", p_Player.GetName());                   
        return true; //usuwa sie
    }
}
