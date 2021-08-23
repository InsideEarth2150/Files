mission "translateMission314"
{
    consts
    {
        deliverDocuments = 0;
        backToBase = 1;
    }
    
    player pEnemy;
    player pPlayer;
    player pNeutral;
    
    unitex uHero;
    
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Searching;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(deliverDocuments,"translateGoal314");
        RegisterGoal(backToBase,"translateGoalHeroBackToBase");
        EnableGoal(deliverDocuments,true);
        //----------- Temporary players ------
        
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy = GetPlayer(2);
        pNeutral = GetPlayer(1);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            pEnemy.LoadScript("single\\singleEasy");
            pEnemy.EnableAIFeatures(aiControlDefense,false);
        }
        if(GetDifficultyLevel()==1)
            pEnemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            pEnemy.LoadScript("single\\singleHard");
        
        pNeutral.LoadScript("single\\singleHard");
        pEnemy.EnableAIFeatures(aiControlOffense,false);
        pNeutral.EnableAIFeatures(aiControlOffense,false);
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        pNeutral.SetNeutral(pPlayer);
        pPlayer.SetNeutral(pNeutral);
        pNeutral.ChooseEnemy(pEnemy);
        pNeutral.SetEnemy(pEnemy);
        //----------- Money ------------------
        pPlayer.SetMoney(0);
        pEnemy.SetMoney(20000);
        pNeutral.SetMoney(30000);
        //----------- Researches -------------
        pEnemy.EnableResearch("RES_ED_WCH2",true);
        pEnemy.EnableResearch("RES_ED_ACH2",true);
        pEnemy.EnableResearch("RES_MCH2",true);
        pEnemy.EnableResearch("RES_ED_UA11",true);
        //----------- Buildings --------------
        
        pPlayer.EnableBuilding("LCBBF",false); 
        pPlayer.EnableBuilding("LCBPP",false); 
        pPlayer.EnableBuilding("LCBBA",false); 
        pPlayer.EnableBuilding("LCBMR",false); 
        pPlayer.EnableBuilding("LCBSR",false);
        pPlayer.EnableBuilding("LCBRC",false);
        pPlayer.EnableBuilding("LCBAB",false);
        pPlayer.EnableBuilding("LCBGA",false);
        pPlayer.EnableBuilding("LCBDE",false);
        pPlayer.EnableBuilding("LCBHQ",false);
        pPlayer.EnableBuilding("LCBSD",false);
        pPlayer.EnableBuilding("LCBWC",false);
        pPlayer.EnableBuilding("LCBSS",false);
        pPlayer.EnableBuilding("LCBLZ",false);
        pPlayer.EnableBuilding("LCLASERWALL",false);
        //----------- Units ------------------
        uHero=pPlayer.GetScriptUnit(0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bCheckEndMission=false;
        
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;//5 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing314",pPlayer.GetName());
        return Searching,100;
    }
    //-----------------------------------------------------------------------------------------
    state Searching
    {
        if(uHero)
        {
            if(uHero.IsInWorld(GetWorldNum()) 
                && uHero.DistanceTo(GetPointX(0),GetPointY(0))<10
                && !uHero.GetLocationZ())
            {
                SetGoalState(deliverDocuments, goalAchieved);
                EnableGoal(backToBase,true);
                AddBriefing("translateAccomplished314",pPlayer.GetName());
                EnableNextMission(0,true);
                return Nothing,200; 
            }
        }
        return Searching,100; 
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(GetGoalState(backToBase)!=goalAchieved && !uHero.IsInWorld(GetWorldNum()))
        {
            SetGoalState(backToBase,goalAchieved);
            EnableEndMissionButton(true);
        }
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                if(GetGoalState(backToBase)!=goalAchieved) 
                {
                    AddBriefing("translateFailedNoUnits",pPlayer.GetName());
                    EndMission(false);
                }
                else
                    EndMission(true);
            }
            if(pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                pPlayer.EnableBuilding("LCBLZ",true);
                if(pPlayer.GetMoney()<500) pPlayer.AddMoney(500);
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
        pNeutral.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pNeutral);
    }
}

