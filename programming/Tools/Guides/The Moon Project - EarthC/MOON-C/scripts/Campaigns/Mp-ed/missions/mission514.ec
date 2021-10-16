//  
//1 doprowadzic ciezarowke do startingpointa gracza 4 i przejêcie jego unitu

//Artefakty na markerach 1-30 to miny
//Hard 1-30
//Medium 11-30
//Easy 11-20

//AI dostaje dzia³ka przeciwlotnicze i plazme oraz rakiety naprowadzane
//Wy³aczone ma budowanie budynków.

//Budowanie budynków zostaje w³aczone po przejêciu pojazdu.

//Na Easy Gracz4 jest Ally i show area elektrowni.
//Na medium jest show area gracza 4
//NA hardzie AI ma w³aczone offense (na medium i easy wy³aczone)
    
mission "translateMission514"
{

    consts
    {
        deliverPilot = 0;
        evacuateCargoSalamander = 1;
        destroyAllPowerPlants = 2;
        destroyAllBuildings = 3;
        destroyAllUnits = 4;

        primaryGoal = 0;
        secondaryGoal = 1;
        hiddenGoal = 2;
        endMission = 3;

        accountMainBase = 1;
        accountResearchBase = 2;
        accountCareerPoints = 3;
    }
    
    player p_Enemy;
    player p_Neutral;//CargoSalamander
    player p_Player;
    
    unitex u_Truck;
    unitex u_CargoSalamander;
    
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
            Transfer(accountMainBase,0);
            Transfer(accountResearchBase,15000);
            Transfer(accountCareerPoints,2);
        }
        if(reason==secondaryGoal)
        {
            Transfer(accountMainBase,3000);
            Transfer(accountCareerPoints,10);
        }
        if(reason==hiddenGoal)
        {
            Transfer(accountMainBase,5000);
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
    state Delivering;
    state ShowVideo;
    state Escaping;
    state Nothing;
    state EndMissionFailed;     
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        int i;
        int start;
        int end;
                
        m_bSuccess = true;
        //----------- Goals ------------------
        RegisterGoal(deliverPilot,"translateGoal514a");
        RegisterGoal(evacuateCargoSalamander,"translateGoal514b");
        RegisterGoal(destroyAllPowerPlants,"translateGoal514c");
        RegisterGoal(destroyAllBuildings,"translateGoal514d");
        RegisterGoal(destroyAllUnits,"translateGoal514e");
        
        EnableGoal(deliverPilot,true);               
        EnableGoal(destroyAllPowerPlants,true);               
                
                
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

        p_Enemy.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Enemy);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
//          Na Easy Gracz4 jest Ally i show area elektrowni.
//          Na medium jest show area gracza 4
//          NA hardzie AI ma w³aczone offense (na medium i easy wy³aczone)


        if(GetDifficultyLevel()==0)
        {
            p_Neutral.EnableAIFeatures(aiRejectAlliance,false);
            p_Player.SetAlly(p_Neutral);
            p_Enemy.LoadScript("single\\singleEasy");
            p_Enemy.EnableAIFeatures(aiControlOffense,false);
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.LoadScript("single\\singleMedium");
            ShowArea(4,p_Neutral.GetStartingPointX(),p_Neutral.GetStartingPointY(),0,3);
            p_Enemy.EnableAIFeatures(aiControlOffense,false);
        }
        if(GetDifficultyLevel()==2)
            p_Enemy.LoadScript("single\\singleHard");

        p_Enemy.EnableAIFeatures(aiBuildBuildings,false);
        
                //----------- Money ------------------
        p_Player.SetMoney(0);
        if(GetDifficultyLevel()==1)
        {
            p_Enemy.SetMoney(20000);
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.SetMoney(100000);
        }
        p_Neutral.SetMoney(0);
        //----------- Researches -------------
        p_Enemy.AddResearch("RES_UCS_WSP1");
        p_Enemy.AddResearch("RES_UCS_WSP2");
        p_Enemy.AddResearch("RES_UCS_WSR1");
        p_Enemy.AddResearch("RES_UCS_WSR2");
        p_Enemy.AddResearch("RES_UCS_WSR3");
        p_Enemy.AddResearch("RES_UCSCAA1");
        p_Enemy.AddResearch("RES_UCSCAA2");
        p_Enemy.AddResearch("RES_UCS_SGen");
        p_Enemy.AddResearch("RES_UCS_MGen");
        p_Enemy.AddResearch("RES_UCS_HGen");

        p_Player.EnableResearch("RES_ED_ASR2",true);//helicopter rocket launcher
        p_Player.EnableResearch("RES_ED_AMR1",true);//helicopter rocket launcher
        p_Player.EnableResearch("RES_ED_SCR3",true);
        p_Player.EnableResearch("RES_ED_UA41",true);
        p_Player.EnableResearch("RES_EDUSTEALTH",true);

        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,true);
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
        p_Player.EnableBuilding("EDBBT",false);
        p_Player.EnableBuilding("EDBHT",false);
        p_Player.EnableBuilding("EDBART",false);
        // 4th tab
        p_Player.EnableBuilding("EDBUC",false);
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBEN1",false);
        p_Player.EnableBuilding("EDBLZ",true);
                    
        
        //----------- Artefacts --------------
//Artefakty na markerach 1-30 to miny
//Easy 11-20
//Medium 11-30
//Hard 1-30

        if(GetDifficultyLevel()==0)
        {
            start=11;
            end=20;
        }
        if(GetDifficultyLevel()==1)
        {
            start=11;
            end=30;
        }
        if(GetDifficultyLevel()==2)
        {
            start=1;
            end=30;
        }
        for(i=start;i<=end;i=i+1)
        {
            CreateArtefact("NEAMINE",GetPointX(i),GetPointY(i),GetPointZ(i),i,artefactSpecialAIOther);
        }
                
        //----------- Units ------------------
        u_Truck = GetUnit(GetPointX(0),GetPointY(0),0);
        u_CargoSalamander = GetUnit(p_Neutral.GetStartingPointX(),p_Neutral.GetStartingPointY(),0);
        u_CargoSalamander.LoadScript("Scripts\\Units\\Tank.ecomp");
        p_Player.SetScriptUnit(0,u_CargoSalamander);
        
        if(GetDifficultyLevel()==0)
        {
            KillArea(p_Enemy.GetIFF(), GetPointX(31), GetPointY(31), 0, 0);
            KillArea(p_Enemy.GetIFF(), GetPointX(32), GetPointY(32), 0, 0);
            KillArea(p_Enemy.GetIFF(), GetPointX(33), GetPointY(33), 0, 0);
            KillArea(p_Enemy.GetIFF(), GetPointX(34), GetPointY(34), 0, 0);
            KillArea(p_Enemy.GetIFF(), GetPointX(35), GetPointY(35), 0, 0);
            KillArea(p_Enemy.GetIFF(), GetPointX(36), GetPointY(36), 0, 0);
            KillArea(p_Enemy.GetIFF(), GetPointX(37), GetPointY(37), 0, 0);
            KillArea(p_Enemy.GetIFF(), GetPointX(38), GetPointY(38), 0, 0);
        }
        if(GetDifficultyLevel()==1)
        {
            KillArea(p_Enemy.GetIFF(), GetPointX(33), GetPointY(33), 0, 0);
            KillArea(p_Enemy.GetIFF(), GetPointX(35), GetPointY(35), 0, 0);
            KillArea(p_Enemy.GetIFF(), GetPointX(37), GetPointY(37), 0, 0);
        }
                
                //set campaign unit     
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
        EnableNextMission(0,true);//516
        AddBriefing("translateBriefing514a");
        Rain(GetPointX(0),GetPointY(0),45,400,5000,800,5); 
        return Delivering,1;
    }
    //-----------------------------------------------------------------------------------------  
    state Delivering
    {
        if(u_Truck.DistanceTo(p_Neutral.GetStartingPointX(),p_Neutral.GetStartingPointY())<2)
        {
            SetGoalState(deliverPilot,goalAchieved);
            EnableGoal(evacuateCargoSalamander,true);               
            AddBriefing("translateBriefing514b");
            u_CargoSalamander.ChangePlayer(p_Player);
            if(GetDifficultyLevel()==2)
                Storm(GetPointX(20),GetPointY(20),20,300,5000,1000,5,3,3);
            if(GetDifficultyLevel()==1)
                Storm(GetPointX(20),GetPointY(20),20,300,5000,1000,5,1,1);


            p_Player.EnableBuilding("EDBPP",true);
            p_Player.EnableBuilding("EDBAB",true);
        
            return ShowVideo;
        }
        return Delivering,20;
    }
    //-----------------------------------------------------------------------------------------  
    state ShowVideo
    {
        ShowVideo("Cutscene18");
        return Escaping;
    }   

    //-----------------------------------------------------------------------------------------  
    state Escaping
    {
        if(u_CargoSalamander.IsLive() && !u_CargoSalamander.IsInWorld(GetWorldNum()))
        {
            SetPrize(primaryGoal);
            EnableNextMission(1,true);//515
            SetGoalState(evacuateCargoSalamander,goalAchieved);
            AddBriefing("translateAccomplished514");
            m_bSuccess = true;
            EnableEndMissionButton(true);
            return Nothing;
        }
        return Escaping;
    }
    //-----------------------------------------------------------------------------------------  
    state Nothing
    {
        return Nothing;
    }
    //-----------------------------------------------------------------------------------------
        state EndMissionFailed
        {
            EnableNextMission(0,2);
            return Nothing;
        }
    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(!bCheckEndMission)return;

        bCheckEndMission=false;
            
        if(GetGoalState(destroyAllUnits)!=goalAchieved && !p_Enemy.GetNumberOfUnits())
        {
            EnableGoal(destroyAllUnits,true);               
            SetGoalState(destroyAllUnits, goalAchieved);
            SetPrize(hiddenGoal);
        }

        if(!p_Enemy.GetNumberOfBuildings(buildingPowerPlant) && GetGoalState(destroyAllPowerPlants)!=goalAchieved)
        {
            SetPrize(secondaryGoal);
            SetGoalState(destroyAllPowerPlants,goalAchieved);
        }

        if(!p_Enemy.GetNumberOfBuildings() && GetGoalState(destroyAllBuildings)!=goalAchieved)
        {
            EnableGoal(destroyAllBuildings,true);               
            SetPrize(hiddenGoal);
            SetGoalState(destroyAllBuildings,goalAchieved);
        }

        if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
        {
            if(GetGoalState(evacuateCargoSalamander)!=goalAchieved)
            {
                AddBriefing("translateFailed514a");
                m_bSuccess = false;
                state EndMissionFailed;
            }
            else
            {
                m_bSuccess = true;
                EndMission(true);
            }
        }
        if(!u_CargoSalamander.IsLive())
        {
            SetGoalState(evacuateCargoSalamander,goalFailed);
            AddBriefing("translateFailed514b");
            EnableNextMission(1,false);//515
            m_bSuccess = false;
            state EndMissionFailed;
        }
        if(!u_Truck.IsLive() && GetGoalState(deliverPilot)!=goalAchieved)
        {
            SetGoalState(deliverPilot,goalFailed);
            SetGoalState(evacuateCargoSalamander,goalFailed);
            AddBriefing("translateFailed514c");
            m_bSuccess = false;
            state EndMissionFailed;
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
        if(aID>0)//mines
        {
            KillArea(15, GetPointX(aID),GetPointY(aID),GetPointZ(aID),0);
            return true; //usuwa sie 
        }
        return true; //usuwa sie 
    }

}
   