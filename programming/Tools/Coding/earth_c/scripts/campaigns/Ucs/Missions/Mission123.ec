mission "translateMission123"
{//Alasca track ed tanks
    consts
    {
        destroyEDForces = 0;
    }
    
    player pEnemy;
    player pPlayer;
    
    int nWayPoint;
    
    state Initialize;
    state ShowBriefing;
    state OnTheWay;
    state Final;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //---------goals--------------------
        RegisterGoal(destroyEDForces,"translateGoal123");
        EnableGoal(destroyEDForces,true);               
        
        //-----------temporary players-----------------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        //-----------players-----------------
        pPlayer = GetPlayer(1);
        pEnemy = GetPlayer(2);
        //-----------AI-----------------
        pPlayer.EnableAIFeatures(aiEnabled,false);
        pEnemy.EnableAIFeatures(aiEnabled,false);
        pPlayer.SetMilitaryUnitsLimit(15000);
        //-----------money-----------------
        pPlayer.SetMoney(10000);
        pEnemy.SetMoney(0);
        //-----------researches-----------------
        pEnemy.EnableResearch("RES_ED_RepHand2",true);
        
        pPlayer.EnableResearch("RES_MSR2",true);
        pPlayer.EnableResearch("RES_UCS_UML1",true);
        pPlayer.EnableResearch("RES_UCS_BMD",true);
        //-----------buildings----------------
        pPlayer.EnableBuilding("UCSBEN1",false);
        //-----------Timers-----------------
        SetTimer(0,200);
        //-----------variables--------------
        nWayPoint=0;
        
        //-----------camera-----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,120;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        AddBriefing("translateBriefing123");
        return OnTheWay,600;
    }
    //-----------------------------------------------------------------------------------------  
    state OnTheWay
    {
        if(pPlayer.IsPointLocated(GetPointX(nWayPoint),GetPointY(nWayPoint),0))
        {
            if(nWayPoint==0)
                ShowVideo("CS112");
            nWayPoint=nWayPoint+1;
            if(nWayPoint>12) 
            {
                nWayPoint=12;
            }
        }
        if(nWayPoint)
            pEnemy.RussianAttack(GetPointX(nWayPoint),GetPointY(nWayPoint),0);
        
        
        if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed123");
            EndMission(false);
        }
        if(!pEnemy.GetNumberOfUnits())
        {
            SetGoalState(destroyEDForces, goalAchieved);
            AddBriefing("translateAccomplished123");
            EnableEndMissionButton(true);
            return Final,500;
        }
        return OnTheWay,200;
    }
    //-----------------------------------------------------------------------------------------
    state Final
    {
        return Final,500;
    }
    
    //-----------------------------------------------------------------------------------------
    event EndMission() 
    {
    }
}
