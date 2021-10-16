mission "translateTutorialUCS"
{
    consts
    {
        buildPowerPlant = 0;
        buildVechProdCent = 1;
        buildRefinery = 3;
        buildTransporters = 4;
        harvestResources = 5;
        buildWeapProdCent = 6;
        buildArmy = 7;
        findEnemy = 8;  
        destroyEnemy = 9;
    }
    
    player p_Player;
    player p_Enemy;
    
    int nDelayCount;
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
    state BuildRefinery;
    state BuildHarvesters;
    state HarvestResources;
    state BuildWeapProdCent;
    state BuildArmy;
    state More;
    state EndState;
    
    state Initialize
    {
        RegisterGoal(buildPowerPlant,"translateGoalTutorialUCS_PP");
        RegisterGoal(buildVechProdCent,"translateGoalTutorialUCS_BA");
        RegisterGoal(buildRefinery,"translateGoalTutorialUCS_RF");
        RegisterGoal(buildTransporters,"translateGoalTutorialUCS_OH");
        RegisterGoal(harvestResources,"translateGoalTutorialUCS_Mining");
        RegisterGoal(buildWeapProdCent,"translateGoalTutorialUCS_FA");
        RegisterGoal(buildArmy,"translateGoalTutorialUCS_tanks");
        RegisterGoal(findEnemy,"translateGoalTutorialUCS_findEnemy");
        RegisterGoal(destroyEnemy,"translateGoalTutorialUCS_destroyEnemy");
        
        p_Player=GetPlayer(1);
        p_Enemy=GetPlayer(2);
        
        p_Player.SetMoney(20000);
        p_Enemy.SetMoney(20000);
        
        p_Player.EnableAIFeatures(aiEnabled,false);     
        
        p_Enemy.EnableAIFeatures(aiEnabled,true);       
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        
        //weapons
        p_Player.EnableResearch("RES_UCS_WACH2",false);
        p_Player.EnableResearch("RES_UCS_WSR2",false);
                p_Player.EnableResearch("RES_UCS_WASR1",false);
        p_Player.EnableResearch("RES_UCS_WSP2",false);
        p_Player.EnableResearch("RES_UCS_WHG1",false);
        p_Player.EnableResearch("RES_UCS_WSD",false);
        //ammo
        p_Player.EnableResearch("RES_UCS_WAPB1",false);
                p_Player.EnableResearch("RES_MMR2",false);
        p_Player.EnableResearch("RES_UCS_MB2",false);
        p_Player.EnableResearch("RES_UCS_MG2",false);
        //chassis
        p_Player.EnableResearch("RES_UCS_GARG1",false);
        p_Player.EnableResearch("RES_UCS_USL3",false);
                p_Player.EnableResearch("RES_UCS_USS2",false);
        p_Player.EnableResearch("RES_UCS_UML3",false);
        p_Player.EnableResearch("RES_UCS_UHL1",false);
        p_Player.EnableResearch("RES_UCS_UMI1",false);
        p_Player.EnableResearch("RES_UCS_USS1",false);
        p_Player.EnableResearch("RES_UCS_UBS1",false);
        p_Player.EnableResearch("RES_UCS_USM1",false);
        p_Player.EnableResearch("RES_UCS_UAH1",false);
        p_Player.EnableResearch("RES_UCS_BOMBER21",false);
        //sopecial
        p_Player.EnableResearch("RES_UCS_BMD",false);
        p_Player.EnableResearch("RES_UCS_BHD",false);
        
        p_Player.EnableResearch("RES_UCS_RepHand2",false);
        p_Player.EnableResearch("RES_UCS_SGen",false);
        p_Player.EnableResearch("RES_UCS_SHD",false);
        
        p_Player.EnableResearch("RES_UCS_WSD",false);
        p_Player.EnableResearch("RES_UCS_PC",false);
        
        // 1st tab
        p_Player.EnableBuilding("UCSBPP",false);
        p_Player.EnableBuilding("UCSBET",false);
        p_Player.EnableBuilding("UCSBBA",false);
        p_Player.EnableBuilding("UCSBFA",false);
        p_Player.EnableBuilding("UCSBWB",false);
        p_Player.EnableBuilding("UCSBAB",false);
        // 2nd tab
        p_Player.EnableBuilding("UCSBRF",false);
        p_Player.EnableBuilding("UCSBTB",false);
        // 3rd tab
        p_Player.EnableBuilding("UCSBST",false);
        // 4th tab
        p_Player.EnableBuilding("UCSBRC",false);
        p_Player.EnableBuilding("UCSBTE",false);
        p_Player.EnableBuilding("UCSBHQ",false);
        p_Player.EnableBuilding("UCSBEN1",false);
        p_Player.EnableBuilding("UCSBLZ",false);
        
        
        nStartX = p_Player.GetStartingPointX();
                nStartY = p_Player.GetStartingPointY();
    
        LookAt(nStartX,nStartY,6,0,20,0,0);
        
        SetTimer(0,6000);//5min
        SetTimer(1,100);//5sec
        nBuildingCount=0;
        
        return Start;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state Start
    {
        Rain(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),30,400,2500,800,10); 
        AddBriefing("translateTutorialUCS_moveCamera");
        return MoveCamera,600;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state MoveCamera
    {
        EnableGoal(buildPowerPlant,true);
        p_Player.EnableBuilding("UCSBPP",true);
        AddBriefing("translateTutorialUCS_PP");
        return BuildPowerPlant,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildPowerPlant
    {
        if(p_Player.GetNumberOfBuildings(buildingPowerPlant))
        {
            p_Player.EnableBuilding("UCSBBA",true);
            p_Player.EnableBuilding("UCSBET",true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildPowerPlant,goalAchieved);
            EnableGoal(buildVechProdCent,true);
            if(!p_Player.GetNumberOfBuildings(buildingBase))
                AddBriefing("translateTutorialUCS_BA");
            return BuildVechProdCent,100;
        }
                if(!p_Player.GetNumberOfUnits(chassisTank|unitBuilder))
                {
                    p_Player.CreateUnitEx(nStartX,nStartY,  0,null,"UCSUBU1",null,null,null,null);                  
                }
                if(p_Player.GetMoney()<2000)    p_Player.AddMoney(2000);
        return BuildPowerPlant,50;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildVechProdCent
    {
        if(p_Player.GetNumberOfBuildings(buildingBase))
        {
            p_Player.EnableBuilding("UCSBRF",true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            SetGoalState(buildVechProdCent,goalAchieved);
            EnableGoal(buildRefinery,true);
            if(!p_Player.GetNumberOfBuildings(buildingRefinery))
                AddBriefing("translateTutorialUCS_RF");
            return BuildRefinery,100;
        }
        if(p_Player.GetNumberOfBuildings()>nBuildingCount)
        {
            nBuildingCount=nBuildingCount+1;
            AddBriefing("translateTutorialUCS_BA_Fool");
        }
                if(!p_Player.GetNumberOfUnits(chassisTank|unitBuilder))
                {
                    p_Player.CreateUnitEx(nStartX,nStartY,  0,null,"UCSUBU1",null,null,null,null);                  
                }
                if(p_Player.GetMoney()<2000)    p_Player.AddMoney(2000);
        
        return BuildVechProdCent,50;
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
                AddBriefing("translateTutorialUCS_OH");
            return BuildHarvesters,100;
        }
        if(p_Player.GetNumberOfBuildings()>nBuildingCount)
        {
            nBuildingCount=nBuildingCount+1;
            AddBriefing("translateTutorialUCS_RF_Fool");
        }
                if(p_Player.GetMoney()<2000)    p_Player.AddMoney(2000);
        return BuildRefinery,50;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildHarvesters
    {
        if(p_Player.GetNumberOfUnits(unitHarvester|chassisAny)>=2) 
        {
            SetGoalState(buildTransporters,goalAchieved);
            EnableGoal(harvestResources,true);
            AddBriefing("translateTutorialUCS_Mining");
            nMoney=p_Player.GetMoney();
            return HarvestResources,100;
        }
                if(p_Player.GetMoney()<2000)    p_Player.AddMoney(2000);
        return BuildHarvesters,100;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state HarvestResources
    {
        if(nMoney < p_Player.GetMoney())
        {
            p_Player.EnableBuilding("UCSBFA",true);
            SetGoalState(harvestResources,goalAchieved);
            EnableGoal(buildWeapProdCent,true);
            if(!p_Player.GetNumberOfBuildings(buildingFactory))
                AddBriefing("translateTutorialUCS_FA");
            return BuildWeapProdCent,100;
        }
        return HarvestResources,50;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state BuildWeapProdCent
    {
        if(p_Player.GetNumberOfBuildings(buildingFactory))
        {
            SetGoalState(buildWeapProdCent,goalAchieved);
            EnableGoal(buildArmy,true);
            nBuildingCount=p_Player.GetNumberOfBuildings();
            AddBriefing("translateTutorialUCS_tanks");
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
            if(GetGoalState(findEnemy)!=goalAchieved)
                AddBriefing("translateTutorialUCS_findEnemy");
            return More,600;
        }
        return BuildArmy,200;
    }
    //-------------------------------------------------------------------------------------------------------------------
    state More
    {
        p_Player.EnableBuilding("UCSBET",true);
        p_Player.EnableBuilding("UCSBAB",true);
        p_Player.EnableBuilding("UCSBST",true);
        p_Player.EnableBuilding("UCSBRC",true);
        p_Player.EnableBuilding("UCSBEN1",true);
        AddBriefing("translateTutorialUCS_more");
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
        Rain(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),30,400,2500,800,10); 
    }
    //-------------------------------------------------------------------------------------------------------------------
    event Timer1()
    {
        if(GetGoalState(findEnemy)!=goalAchieved && p_Player.IsPointLocated(p_Enemy.GetStartingPointX(),p_Enemy.GetStartingPointY(),0))
        {
            //LookAt(p_Enemy.GetStartingPointX(),p_Enemy.GetStartingPointY(),6,0,20,0,0);
            SetGoalState(findEnemy,goalAchieved);
            EnableGoal(destroyEnemy,true);
            AddBriefing("translateTutorialUCS_destroyEnemy");
        }
        if(GetGoalState(destroyEnemy)!=goalAchieved && !p_Enemy.GetNumberOfUnits())
        {
            SetGoalState(destroyEnemy,goalAchieved);
            AddBriefing("translateTutorialUCS_Victory");
        }
        
    }
}