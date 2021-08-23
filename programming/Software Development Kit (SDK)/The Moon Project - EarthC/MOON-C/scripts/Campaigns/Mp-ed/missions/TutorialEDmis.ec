mission "translateTutorialED"
{
    consts
    {
        buildPowerPlant = 0;
        buildVechProdCent = 1;
        buildMine = 2;
        buildRefinery = 3;
        buildTransporters = 4;
        harvestResources = 5;
        buildWeapProdCent = 6;
        buildArmy = 7;
        findEnemy = 8;  
        destroyEnemy = 9;
    }
    player p_EnemyUCS;
    player p_Player;
    
    int nUCSUnitsCount;
    int nBuildingCount;
    int nMoney;
        int nStartX;
        int nStartY;
    
    //***********************************************************  
    state Initialize;
    state Start;
    state MoveCamera;
    state BuildPowerPlant;
    state BuildVechProdCent;
    state BuildMine;
    state BuildRefinery;
    state BuildTransporters;
    state HarvestResources;
    state BuildWeapProdCent;
    state BuildArmy;
    state More;
    state EndState;
    
    state Initialize
    {
        RegisterGoal(buildPowerPlant,"translateGoalTutorialED_PP");
        RegisterGoal(buildVechProdCent,"translateGoalTutorialED_BA");
        RegisterGoal(buildMine,"translateGoalTutorialED_MI");
        RegisterGoal(buildRefinery,"translateGoalTutorialED_RE");
        RegisterGoal(buildTransporters,"translateGoalTutorialED_OH");
        RegisterGoal(harvestResources,"translateGoalTutorialED_Mining");
        RegisterGoal(buildWeapProdCent,"translateGoalTutorialED_FA");
        RegisterGoal(buildArmy,"translateGoalTutorialED_tanks");
        RegisterGoal(findEnemy,"translateGoalTutorialED_findEnemy");
        RegisterGoal(destroyEnemy,"translateGoalTutorialED_destroyEnemy");
        
        
        p_EnemyUCS=GetPlayer(1);
        p_Player=GetPlayer(2);
        
        p_EnemyUCS.SetMoney(0);
        p_Player.SetMoney(20000);
        
        p_EnemyUCS.EnableAI(false);             
        p_Player.EnableAI(false);           
        
        //weapons
        p_Player.EnableResearch("RES_ED_ACH2",false);
        p_Player.EnableResearch("RES_ED_WSL1",false);
        p_Player.EnableResearch("RES_ED_WSI1",false);
        p_Player.EnableResearch("RES_ED_WSR2",false);
        p_Player.EnableResearch("RES_ED_WMR1",false);
        p_Player.EnableResearch("RES_ED_WHC1",false);
        p_Player.EnableResearch("RES_ED_WHI1",false);
        p_Player.EnableResearch("RES_ED_WHL1",false);
        p_Player.EnableResearch("RES_ED_WHR1",false);
        p_Player.EnableResearch("RES_ED_AB1",false);
        //ammo
        p_Player.EnableResearch("RES_ED_MHC2",false);
        p_Player.EnableResearch("RES_ED_MB2",false);
        p_Player.EnableResearch("RES_ED_MSC3",false);
        p_Player.EnableResearch("RES_MMR2",false);
        p_Player.EnableResearch("RES_MSR3",false);
        p_Player.EnableResearch("RES_ED_MHR2",false);
        p_Player.EnableResearch("RES_ED_MHR4",false);
        //chassis
        p_Player.EnableResearch("RES_ED_UST3",false);
        p_Player.EnableResearch("RES_ED_UMT2",false);
        p_Player.EnableResearch("RES_ED_UMW1",false);
        p_Player.EnableResearch("RES_ED_UMI1",false);
        p_Player.EnableResearch("RES_ED_UHT1",false);
        p_Player.EnableResearch("RES_ED_UHW1",false);
        p_Player.EnableResearch("RES_ED_UBT1",false);
        p_Player.EnableResearch("RES_ED_UA11",false);
        p_Player.EnableResearch("RES_ED_UA21",false);
        p_Player.EnableResearch("RES_ED_UA31",false);
        p_Player.EnableResearch("RES_ED_UA41",false);
        p_Player.EnableResearch("RES_ED_USS2",false);
        p_Player.EnableResearch("RES_ED_UHS1",false);
        //special
        p_Player.EnableResearch("RES_ED_SCR",false);
        p_Player.EnableResearch("RES_ED_SGen",false);
        p_Player.EnableResearch("RES_ED_BMD",false);
        p_Player.EnableResearch("RES_ED_BHD",false);
        p_Player.EnableResearch("RES_ED_RepHand2",false);
        
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
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBEN1",false);
        p_Player.EnableBuilding("EDBLZ",false);
    
                
                nStartX = p_Player.GetStartingPointX();
                nStartY = p_Player.GetStartingPointY();
    
        LookAt(nStartX,nStartY,6,0,20,0,0);
        SetTimer(0,6000);
        SetTimer(1,100);
        nBuildingCount=0;
        return Start,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Start
    {
        AddBriefing("translateTutorialED_moveCamera");
        nUCSUnitsCount=p_EnemyUCS.GetNumberOfUnits()/2;
        return MoveCamera,600;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state MoveCamera
    {
        p_Player.EnableBuilding("EDBPP",true);
        EnableGoal(buildPowerPlant,true);
        AddBriefing("translateTutorialED_PP");
        return BuildPowerPlant,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildPowerPlant
    {
        if(p_Player.GetNumberOfBuildings(buildingPowerPlant))
        {
            p_Player.EnableBuilding("EDBBA",true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildPowerPlant,goalAchieved);
            EnableGoal(buildVechProdCent,true);
            if(!p_Player.GetNumberOfBuildings(buildingBase))
                AddBriefing("translateTutorialED_BA");
            return BuildVechProdCent,100;
        }
                if(!p_Player.GetNumberOfUnits(chassisTank|unitBuilder))
                {
                    p_Player.CreateUnitEx(nStartX,nStartY,  0,null,"EDUBU1",null,null,null,null);                  
                }
                if(p_Player.GetMoney()<2000)    p_Player.AddMoney(2000);
                
                return BuildPowerPlant,60;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildVechProdCent
    {
        if(p_Player.GetNumberOfBuildings(buildingBase))
        {
            p_Player.EnableBuilding("EDBMI",true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildVechProdCent,goalAchieved);
            EnableGoal(buildMine,true);
            if(!p_Player.GetNumberOfBuildings(buildingMine))
                AddBriefing("translateTutorialED_MI");
            return BuildMine,100;
        }
                if(!p_Player.GetNumberOfUnits(chassisTank|unitBuilder))
                {
                    p_Player.CreateUnitEx(nStartX,nStartY,  0,null,"EDUBU1",null,null,null,null);                  
                }
                if(p_Player.GetMoney()<2000)    p_Player.AddMoney(2000);
                
        if(p_Player.GetNumberOfBuildings()>nBuildingCount)
        {
            nBuildingCount=nBuildingCount+1;
            AddBriefing("translateTutorialED_BA_Fool");
        }
        return BuildVechProdCent,60;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildMine
    {
        if(p_Player.GetNumberOfBuildings(buildingMine))
        {
            p_Player.EnableBuilding("EDBRE",true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildMine,goalAchieved);
            EnableGoal(buildRefinery,true);
            if(!p_Player.GetNumberOfBuildings(buildingRefinery))
                AddBriefing("translateTutorialED_RE");
            return BuildRefinery,100;
        }
        if(p_Player.GetNumberOfBuildings()>nBuildingCount)
        {
            nBuildingCount=nBuildingCount+1;
            AddBriefing("translateTutorialED_MI_Fool");
        }
                if(p_Player.GetMoney()<2000)    p_Player.AddMoney(2000);
        return BuildMine,100;
    }
    
    //-------------------------------------------------------------------------------------------------------------------
    state BuildRefinery
    {
        if(p_Player.GetNumberOfBuildings(buildingRefinery))
        {
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildRefinery,goalAchieved);
            EnableGoal(buildTransporters,true);
            if(p_Player.GetNumberOfUnits(chassisTank|unitCarrier)<2)
                AddBriefing("translateTutorialED_OH");
            return BuildTransporters,100;
        }
        if(p_Player.GetNumberOfBuildings()>nBuildingCount)
        {
            nBuildingCount=nBuildingCount+1;
            AddBriefing("translateTutorialED_RE_Fool");
        }
                if(p_Player.GetMoney()<2000)    p_Player.AddMoney(2000);
        return BuildRefinery,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildTransporters
    {
        if(p_Player.GetNumberOfUnits(chassisTank|unitCarrier)>=2)
        {
            SetGoalState(buildTransporters,goalAchieved);
            EnableGoal(harvestResources,true);
            AddBriefing("translateTutorialED_Mining");
            nMoney=p_Player.GetMoney();
            return HarvestResources,100;
        }
                if(p_Player.GetMoney()<2000)    p_Player.AddMoney(2000);
        return BuildTransporters,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state HarvestResources
    {
        if(nMoney < p_Player.GetMoney())
        {
            p_Player.EnableBuilding("EDBFA",true);
            SetGoalState(harvestResources,goalAchieved);
            EnableGoal(buildWeapProdCent,true);
            if(!p_Player.GetNumberOfBuildings(buildingFactory))
                AddBriefing("translateTutorialED_FA");
            return BuildWeapProdCent,100;
        }
        return HarvestResources,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildWeapProdCent
    {
        if(p_Player.GetNumberOfBuildings(buildingFactory))
        {
            SetGoalState(buildWeapProdCent,goalAchieved);
            EnableGoal(buildArmy,true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            AddBriefing("translateTutorialED_tanks");
            return BuildArmy;
        }
        if(p_Player.GetNumberOfBuildings()>nBuildingCount)
        {
            nBuildingCount=nBuildingCount+1;
        }
        return BuildWeapProdCent,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildArmy
    {
        if(p_Player.GetNumberOfUnits(chassisTank|unitArmed)>=5)
        {
            SetGoalState(buildArmy,goalAchieved);
            EnableGoal(findEnemy,true);
            AddBriefing("translateTutorialED_findEnemy");
            return More,600;
        }
        return BuildArmy,200;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state More
    {
        p_Player.EnableBuilding("EDBAB",true);
        p_Player.EnableBuilding("EDBST",true);
        p_Player.EnableBuilding("EDBRC",true);
        p_Player.EnableBuilding("EDBEN1",true);
        AddBriefing("translateTutorialED_more");
        return EndState,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    //-------------------------------------------------------------------------------------------------------------------
    state EndState
    {
        return EndState,500;
    }
    //-------------------------------------------------------------------------------------------------------------------
    event Timer0()
    {
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),40,400,5000,800,8); 
    }
    //-------------------------------------------------------------------------------------------------------------------
    event Timer1()
    {
        if(GetGoalState(findEnemy)!=goalAchieved && p_Player.IsPointLocated(p_EnemyUCS.GetStartingPointX(),p_EnemyUCS.GetStartingPointY(),0))
        {
            //LookAt(p_EnemyUCS.GetStartingPointX(),p_EnemyUCS.GetStartingPointY(),6,0,20,0,0);
            SetGoalState(findEnemy,goalAchieved);
            EnableGoal(destroyEnemy,true);
            AddBriefing("translateTutorialED_destroyEnemy");
        }
        if(GetGoalState(destroyEnemy)!=goalAchieved && !p_EnemyUCS.GetNumberOfUnits())
        {
            SetGoalState(destroyEnemy,goalAchieved);
            AddBriefing("translateTutorialED_Victory");
        }
    }
}