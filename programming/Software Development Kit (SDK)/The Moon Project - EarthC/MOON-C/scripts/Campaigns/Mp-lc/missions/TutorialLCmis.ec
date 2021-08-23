mission "translateTutorialLC"
{
    consts
    {
        buildPowerPlant = 0;
        upgradePowerPlant = 1;
        buildBattery = 2;
        buildMainBase = 3;
        buildMine = 4;
        buildArmy = 5;
        findEnemy = 6;  
        destroyEnemy = 7;
    }
    player p_EnemyUCS;
    player p_Player;
    
    int nUCSUnitsCount;
    int nBuildingCount;
    int tmpCounter;
    int nUnitCount;
    //***********************************************************  
    state Initialize;
    state Start;
    state MoveCamera;
    state BuildPowerPlant;
    state UpgradePowerPlant;
    state BuildBattery;
    state BuildMainBase;
    state BuildMine;
    state BuildArmy;
    state More;
    state EndState;
    
    state Initialize
    {
        
        RegisterGoal(buildPowerPlant,"translateGoalTutorialLC_PP");
        RegisterGoal(upgradePowerPlant,"translateGoalTutorialLC_PP_UPG");
        RegisterGoal(buildBattery,"translateGoalTutorialLC_BA");
        RegisterGoal(buildMainBase,"translateGoalTutorialLC_BF");
        RegisterGoal(buildMine,"translateGoalTutorialLC_MI");
        RegisterGoal(buildArmy,"translateGoalTutorialLC_tanks");
        RegisterGoal(findEnemy,"translateGoalTutorialLC_findEnemy");
        RegisterGoal(destroyEnemy,"translateGoalTutorialLC_destroyEnemy");
        nUnitCount=0;    
        p_EnemyUCS=GetPlayer(1);
        p_Player=GetPlayer(3);
        
        p_EnemyUCS.SetMoney(10000);
        p_Player.SetMoney(20000);
        
        
        p_EnemyUCS.EnableAIFeatures(aiEnabled,false);               
        p_Player.EnableAIFeatures(aiEnabled,false); 
        
                p_Player.EnableResearch("RES_MMR2",false);
        //p_Player.EnableResearch("RES_LC_WCH2",false);
        p_Player.EnableResearch("RES_LC_ACH2",false);
        //p_Player.EnableResearch("RES_LC_WSR1",false);
        p_Player.EnableResearch("RES_LC_WSR2",false);
        p_Player.EnableResearch("RES_LC_ASR1",false);
        //p_Player.EnableResearch("RES_LC_WSL1",false);
        p_Player.EnableResearch("RES_LC_WSL2",false);
        p_Player.EnableResearch("RES_LC_WSS1",false);
        p_Player.EnableResearch("RES_LC_WMR1",false);
        p_Player.EnableResearch("RES_LC_WHL1",false);
        p_Player.EnableResearch("RES_LC_WHS1",false);
        
        p_Player.EnableResearch("RES_LC_WAS1",false);
        //p_Player.EnableResearch("RES_LC_UMO2",false);
        p_Player.EnableResearch("RES_LC_UCR1",false);
        p_Player.EnableResearch("RES_LC_UCU1",false);
        
        p_Player.EnableResearch("RES_LC_ULU3",false);
        p_Player.EnableResearch("RES_LC_UMO3",false);
        p_Player.EnableResearch("RES_LC_UME1",false);
        p_Player.EnableResearch("RES_LC_UBO1",false);
        
        p_Player.EnableResearch("RES_LC_BMD",false);
        p_Player.EnableResearch("RES_LC_BHD",false);
        p_Player.EnableResearch("RES_LC_SDIDEF",false);
        //p_Player.EnableResearch("RES_LC_SGen",false);
        p_Player.EnableResearch("RES_LC_MGen",false);
        p_Player.EnableResearch("RES_LC_MGen",false);
        p_Player.EnableResearch("RES_LC_SHR1",false);
        p_Player.EnableResearch("RES_LC_REG1",false);
        p_Player.EnableResearch("RES_LC_SOB1",false);
        p_Player.EnableResearch("RES_LC_SDIDEF",false);
        p_Player.EnableResearch("RES_LC_BWC",false);
        
        p_Player.EnableBuilding("LCBPP",false);
        p_Player.EnableBuilding("LCBBF",false);
        p_Player.EnableBuilding("LCBBA",false);
        p_Player.EnableBuilding("LCBMR",false);
        p_Player.EnableBuilding("LCBSR",false);
        p_Player.EnableBuilding("LCBRC",false);
        p_Player.EnableBuilding("LCBAB",false);
        p_Player.EnableBuilding("LCBGA",false);
        p_Player.EnableBuilding("LCBDE",false);
        p_Player.EnableBuilding("LCBHQ",false);
        p_Player.EnableBuilding("LCBSD",false);
        p_Player.EnableBuilding("LCBWC",false);
        p_Player.EnableBuilding("LCBLZ",false);
        p_Player.EnableBuilding("LCLASERWALL",false);
        
        SetTimer(0,100);    
        LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0,0);
        nBuildingCount=0;
        tmpCounter=0;
        return Start,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Start
    {
        AddBriefing("translateTutorialLC_moveCamera");
        nUCSUnitsCount=p_EnemyUCS.GetNumberOfUnits()/2;
        return MoveCamera,500;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state MoveCamera
    {
        EnableGoal(buildPowerPlant,true);
                p_Player.EnableBuilding("LCBPP",true);
        AddBriefing("translateTutorialLC_PP");
        return BuildPowerPlant,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildPowerPlant
    {
        if(p_Player.GetNumberOfBuildings(buildingSolarPower))
        {
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildPowerPlant,goalAchieved);
            EnableGoal(upgradePowerPlant,true);
            AddBriefing("translateTutorialLC_PP_UPG");
            return UpgradePowerPlant,100;
        }
        return BuildPowerPlant,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state UpgradePowerPlant
    {
                if(p_Player.GetNumberOfBuildings(buildingSolarBattery)>3)
        {
            p_Player.EnableBuilding("LCBBA",true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(upgradePowerPlant,goalAchieved);
            EnableGoal(buildBattery,true);
            if(!p_Player.GetNumberOfBuildings(buildingEnergyBattery))
                AddBriefing("translateTutorialLC_BA");
                        if(!p_Player.GetNumberOfUnits())
                            p_Player.CreateUnitEx(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),  0,null,"LCULU1","LCWCH1",null,null,null,0);                    
            return BuildBattery,100;
        }
        return UpgradePowerPlant,20;//1 sec
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildBattery
    {
        if(p_Player.GetNumberOfBuildings(buildingEnergyBattery))
        {
            p_Player.EnableBuilding("LCBBF",true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildBattery,goalAchieved);
            EnableGoal(buildMainBase,true);
            if(!p_Player.GetNumberOfBuildings(buildingBaseFactory))
                AddBriefing("translateTutorialLC_BF");
            return BuildMainBase,100;
        }
                if(!p_Player.GetNumberOfUnits())
                            p_Player.CreateUnitEx(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),  0,null,"LCULU1","LCWCH1",null,null,null,0);                    
        if(p_Player.GetNumberOfBuildings()>nBuildingCount)
        {
            nBuildingCount=p_Player.GetNumberOfBuildings();
            AddBriefing("translateTutorialLC_BF_Fool");
        }

        return BuildBattery,50;
    }
    
    //-------------------------------------------------------------------------------------------------------------------
    state BuildMainBase
    {
        if(p_Player.GetNumberOfBuildings(buildingBaseFactory))
        {
            p_Player.EnableBuilding("LCBMR",true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildMainBase,goalAchieved);
            EnableGoal(buildMine,true);
            p_EnemyUCS.LoadScript("single\\singleEasy");
            p_EnemyUCS.EnableAIFeatures(aiEnabled,true);              
            p_EnemyUCS.EnableAIFeatures(aiBuildBuildings,false);
            p_EnemyUCS.EnableAIFeatures(aiControlOffense,false);
            p_EnemyUCS.EnableAIFeatures(aiBuildTanks|aiBuildShips|aiBuildHelicopters,false);  
            
            if(!p_Player.GetNumberOfBuildings(buildingMine))
                AddBriefing("translateTutorialLC_MI");
                        return BuildMine,100;
        }
                if(!p_Player.GetNumberOfUnits())
                            p_Player.CreateUnitEx(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),  0,null,"LCULU1","LCWCH1",null,null,null,0);                    
       /* if(p_Player.GetNumberOfBuildings()>nBuildingCount)
        {
            nBuildingCount=p_Player.GetNumberOfBuildings();
            AddBriefing("translateTutorialLC_BF_Fool");
        }*/
        return BuildMainBase,50;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildMine
    {
        if(p_Player.GetNumberOfBuildings(buildingMinningRefinery))
        {
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildMine,goalAchieved);
            EnableGoal(buildArmy,true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            AddBriefing("translateTutorialLC_tanks");
            nUnitCount=p_Player.GetNumberOfUnits(chassisAmphibianTank|unitArmed);
                        if(nUnitCount>3)nUnitCount=3;
            return BuildArmy,50;
        }
                if(!p_Player.GetNumberOfUnits())
                            p_Player.CreateUnitEx(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),  0,null,"LCULU1","LCWCH1",null,null,null,0);                    
        if(p_Player.GetNumberOfBuildings()>nBuildingCount)
        {
            nBuildingCount=nBuildingCount+1;
            AddBriefing("translateTutorialLC_MI_Fool");
        }
        return BuildMine,50;
    }
    
    //-------------------------------------------------------------------------------------------------------------------
    state BuildArmy
    {
        if(p_Player.GetNumberOfUnits(chassisAmphibianTank|unitArmed)>=nUnitCount+4)
        {
            SetGoalState(buildArmy,goalAchieved);
            EnableGoal(findEnemy,true);
            AddBriefing("translateTutorialLC_findEnemy");
            return More,600;
        }
        return BuildArmy,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state More
    {
        p_Player.EnableBuilding("LCBAB",true);
        p_Player.EnableBuilding("LCBGA",true);
        p_Player.EnableBuilding("LCBRC",true);
        p_Player.EnableBuilding("LCLASERWALL",true);
        AddBriefing("translateTutorialLC_more");
        return EndState,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state EndState
    {
        return EndState,500;
    }
    //-------------------------------------------------------------------------------------------------------------------
    event Timer0()
    {
        if(GetGoalState(findEnemy)!=goalAchieved && p_Player.IsPointLocated(p_EnemyUCS.GetStartingPointX(),p_EnemyUCS.GetStartingPointY(),0))
        {
            SetGoalState(findEnemy,goalAchieved);
            EnableGoal(destroyEnemy,true);
            AddBriefing("translateTutorialLC_destroyEnemy");
        }
        if(GetGoalState(destroyEnemy)!=goalAchieved && !p_EnemyUCS.GetNumberOfUnits())
        {
            SetGoalState(destroyEnemy,goalAchieved);
            AddBriefing("translateTutorialLC_Victory");
        }
    }
}