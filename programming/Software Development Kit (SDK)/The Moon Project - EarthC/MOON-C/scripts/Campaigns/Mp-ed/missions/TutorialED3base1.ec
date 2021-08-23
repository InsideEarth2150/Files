mission "translateTutorialED31"
{
    consts
    {
        goalBuildLandingZone = 0;
        goalStartMission = 1;
        goalFinishMission = 2;
    }

    player p_Player;
    
    
    state Initialize;
    state PlayTrackState;
    state ShowBriefing;
    state BuildLandingZone;
    state FinishMission;
    state Nothing;
    

    state Initialize
    {

        //----------- Goals ------------------
        RegisterGoal(goalBuildLandingZone,"translateGoalTutorialED3_1");
        RegisterGoal(goalStartMission,"translateGoalTutorialED3_2");
        RegisterGoal(goalFinishMission,"translateGoalTutorialED3_3");
        
        EnableGoal(goalBuildLandingZone,true);               
                
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        //----------- AI ---------------------
        p_Player.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        p_Player.SetMoney(10000);
        
        //----------- Buildings --------------
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
        // 4th tab
        p_Player.EnableBuilding("EDBUC",false);
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBEN1",false);
        p_Player.EnableBuilding("EDBLZ",true);
        p_Player.EnableBuilding("EDBART",false);

        EnableGameFeature(lockResearchDialog,true);
        EnableGameFeature(lockConstructionDialog,true);
        EnableGameFeature(lockUpgradeWeaponDialog,true);

        p_Player.EnableCommand(commandAutodestruction,false);
        p_Player.EnableCommand(commandSoldBuilding,false);
        p_Player.EnableCommand(commandBuildTrench,false);
        p_Player.EnableCommand(commandBuildFlatTerrain,false);
        p_Player.EnableCommand(commandBuildWall,false);
        p_Player.EnableCommand(commandBuildRoad,false);
        p_Player.EnableCommand(commandBuildWideBridge,false);
        p_Player.EnableCommand(commandBuildNarrowBridge,false);
        p_Player.EnableCommand(commandBuildWideTunnel,false);
        p_Player.EnableCommand(commandBuildNarrowTunnel,false);

        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return PlayTrackState,3;                
    }

    state PlayTrackState
    {
        PlayTrack("music\\edday_3.mp2");
        return ShowBriefing,50;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateTutorialED3_1",p_Player.GetName());
        return BuildLandingZone;
    }
    //-----------------------------------------------------------------------------------------
    state BuildLandingZone
    {
        if(p_Player.GetNumberOfBuildings()>0)
        {
            EnableNextMission(0,1);
            SetGoalState(goalBuildLandingZone,goalAchieved);
            EnableGoal(goalStartMission,true);               
            AddBriefing("translateTutorialED3_2",p_Player.GetName());
            return FinishMission;
        }
        return BuildLandingZone;
    }
//-----------------------------------------------------------------------------------------
    state FinishMission
    {
        if(p_Player.GetScriptData(1))
        {
            p_Player.SetScriptData(1,0);
            EnableGoal(goalFinishMission,true);               
            SetGoalState(goalStartMission,goalAchieved);
        }
        if(p_Player.GetScriptData(2))
        {
            p_Player.SetScriptData(2,0);
            SetGoalState(goalFinishMission,goalAchieved);
            AddBriefing("translateTutorialED3_3",p_Player.GetName());
            return Nothing,50;
        }
        return FinishMission;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing,50;
    }
}
