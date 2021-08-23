mission "translateTutorialED1"
{
    consts
    {
        buildBridge = 0;
        buildTunnelEntrance1 = 1;
        buildTunnel = 2;
        buildTunnelEntrance2 = 3;
        useUnitTransporter = 4;
    }
    player p_Player;
    unitex u_Builder;
    //***********************************************************  
    state Initialize;
    state Start;
    state BuildBridge;
    state BuildTunnelEntrance1;
    state BuildTunnel;
    state BuildTunnelEntrance2;
    state useUnitTransporter;
    state EndState;
    
    state Initialize
    {
        RegisterGoal(buildBridge,"translateGoalTutorialED1_1");
        RegisterGoal(buildTunnelEntrance1,"translateGoalTutorialED1_2");
        RegisterGoal(buildTunnel,"translateGoalTutorialED1_3");
        RegisterGoal(buildTunnelEntrance2,"translateGoalTutorialED1_4");
        RegisterGoal(useUnitTransporter,"translateGoalTutorialED1_5");
        
        p_Player=GetPlayer(1);
        if(p_Player!=null)p_Player.EnableStatistics(false);
        p_Player=GetPlayer(3);
        if(p_Player!=null)p_Player.EnableStatistics(false);
        p_Player=GetPlayer(2);
        if(p_Player!=null)p_Player.EnableStatistics(false);
        
        p_Player.SetMoney(20000);
        
        p_Player.EnableAI(false);           
        
        EnableGameFeature(lockResearchDialog,true);
        EnableGameFeature(lockConstructionDialog,true);
        EnableGameFeature(lockUpgradeWeaponDialog,true);
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
        // 4th tab
        p_Player.EnableBuilding("EDBUC",false);
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBEN1",false);
        p_Player.EnableBuilding("EDBLZ",false);

        p_Player.EnableCommand(commandBuildTrench,false);
        p_Player.EnableCommand(commandBuildFlatTerrain,false);
        p_Player.EnableCommand(commandBuildWall,false);
        p_Player.EnableCommand(commandBuildRoad,false);
        p_Player.EnableCommand(commandBuildWideTunnel,false);
        p_Player.EnableCommand(commandBuildNarrowTunnel,false);
        p_Player.EnableCommand(commandBuildWideBridge,false);
        p_Player.EnableCommand(commandBuildNarrowBridge,true);
        
    
        u_Builder=GetUnit(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),0);
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,128,20,0);
        Rain(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),40,400,5000,800,8); 
        return Start,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Start
    {
        EnableGoal(buildBridge,true);
        AddBriefing("translateTutorialED1_1");
        CreateArtefact("NEABANNERED", GetPointX(0), GetPointY(0),0,0,artefactSpecialAIOther);
        return BuildBridge;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildBridge
    {
        if(u_Builder.GetLocationY()>GetPointY(1))
        {
            SelectUnit(null,false);                         
            p_Player.EnableCommand(commandBuildNarrowTunnel,true);
            p_Player.EnableBuilding("EDBEN1",true);
            SelectUnit(u_Builder,false);                            

            EnableGoal(buildTunnelEntrance1,true);
            SetGoalState(buildBridge,goalAchieved);
            
            AddBriefing("translateTutorialED1_2");
            CreateArtefact("NEABANNERED", GetPointX(2), GetPointY(2),0,0,artefactSpecialAIOther);
            return BuildTunnelEntrance1,20;
        }
        return BuildBridge;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildTunnelEntrance1
    {
        if(u_Builder.GetLocationZ()!=0)
        {
            EnableGoal(buildTunnel,true);
            SetGoalState(buildTunnelEntrance1,goalAchieved);
            AddBriefing("translateTutorialED1_3");
            return BuildTunnel;
        }
        return BuildTunnelEntrance1;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildTunnel
    {
        if(u_Builder.DistanceTo(GetPointX(3),GetPointY(3))<5)
        {
            EnableGoal(buildTunnelEntrance2,true);
            SetGoalState(buildTunnel,goalAchieved);
            AddBriefing("translateTutorialED1_4");
            return BuildTunnelEntrance2;
        }
        return BuildTunnel;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildTunnelEntrance2
    {
        if(u_Builder.GetLocationZ()==0 &&u_Builder.DistanceTo(GetPointX(3),GetPointY(3))<7)
        {
            EnableGoal(useUnitTransporter,true);
            SetGoalState(buildTunnelEntrance2,goalAchieved);
            AddBriefing("translateTutorialED1_5");
            p_Player.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "EDUUT", "EDSUT", null, null, null); 
            CreateArtefact("NEABANNERED", GetPointX(4), GetPointY(4),0,0,artefactSpecialAIOther);
            return useUnitTransporter;
        }
        return BuildTunnelEntrance2;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state useUnitTransporter
    {
        if(u_Builder.GetLocationZ()==0 && 
            !u_Builder.IsTransported() &&
            u_Builder.DistanceTo(GetPointX(4),GetPointY(4))<3)
        {
            SetGoalState(useUnitTransporter,goalAchieved);
            AddBriefing("translateTutorialED1_6");
            return EndState;
        }
        return useUnitTransporter;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state EndState
    {
        return EndState,500;
    }
    //-------------------------------------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        return false;
    }
}