mission "translateMission264"
{//Columbia
    consts
    {
        goToDestinationPoint = 0;
        sendToBase50000 = 1;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    
    player p_Neutral;
    player p_Player;
    
    unitex p_Guide;
    unitex p_Builder;
    
    int nWayPoint;
    int bShowFailed;
    
    state Initialize;
    state ShowBriefing;
    state OnTheWay;
    state Fight;
    state Final;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(goToDestinationPoint,"translateGoal264");
        RegisterGoal(sendToBase50000,"translateGoalSend50000");
        EnableGoal(goToDestinationPoint,true);               
        
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(4);
        p_Enemy3 = GetPlayer(5);
        p_Neutral = GetPlayer(8);
        
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
            p_Enemy1.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy1.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy1.LoadScript("single\\singleHard");
        
        p_Enemy2.EnableStatistics(false);
        p_Enemy3.EnableStatistics(false);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy1.EnableAIFeatures(aiControlDefense,false);
        p_Enemy2.EnableAIFeatures(aiEnabled,false);
        p_Enemy3.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        
        p_Neutral.EnableAIFeatures(aiRejectAlliance,false);
        p_Neutral.ChooseEnemy(p_Enemy1);
        p_Player.SetAlly(p_Neutral);
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_Enemy1.SetMoney(40000);
        p_Enemy2.SetMoney(0);
        
        //----------- Researches -------------
        //----------- Buildings --------------
        //----------- Units ------------------
        p_Guide = GetUnit(GetPointX(0),GetPointY(0),0);
        p_Builder = GetUnit(p_Player.GetStartingPointX()-1,p_Player.GetStartingPointY(),0);
        
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,200);
        
        //----------- Variables --------------
        nWayPoint=0;
        bShowFailed=true;
        
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing264a");
        return OnTheWay,200;
    }
    //-----------------------------------------------------------------------------------------  
    state OnTheWay
    {
        
        if(nWayPoint==1) p_Enemy3.RussianAttack(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),0);
        
        if(p_Player.IsPointLocated(p_Neutral.GetStartingPointX(),p_Neutral.GetStartingPointY(),0))
        {
            p_Neutral.GiveAllUnitsTo(p_Player);
            SetGoalState(goToDestinationPoint, goalAchieved);
            EnableGoal(sendToBase50000,true);               
            p_Enemy1.EnableAIFeatures(aiControlOffense,true);
            p_Player.SetMoney(20000);
            AddBriefing("translateBriefing264b");
            return Fight,100;
        }
        if(Distance(p_Guide.GetLocationX(),p_Guide.GetLocationY(),GetPointX(nWayPoint),GetPointY(nWayPoint))<2 &&
            Distance(p_Guide.GetLocationX(),p_Guide.GetLocationY(),p_Builder.GetLocationX(),p_Builder.GetLocationY())<3)
        {
            nWayPoint = nWayPoint+1;
            if(nWayPoint>9) 
            {
                nWayPoint=10;
            }
            
        }
        p_Guide.CommandMove(GetPointX(nWayPoint),GetPointY(nWayPoint),GetPointZ(nWayPoint));
        ShowArea(4,p_Guide.GetLocationX(),p_Guide.GetLocationY(),p_Guide.GetLocationZ(),1);
        return OnTheWay,100;
        
    }
    //-----------------------------------------------------------------------------------------
    state Fight
    {
        if(p_Player.GetNumberOfUnits()> 6) p_Enemy1.EnableAIFeatures(aiControlOffense,true);
        
        if(GetGoalState(sendToBase50000)!=goalAchieved && p_Player.GetMoneySentToBase()>=50000)
        {
            SetGoalState(sendToBase50000, goalAchieved);
            AddBriefing("translateAccomplished264");
            EnableEndMissionButton(true);
            return Final,500;
        }
        return Fight,200;
    }
    //-----------------------------------------------------------------------------------------
    state Final
    {
        return Final,500;
    }
    
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 200 cykli< ustawione funkcja SetTimer w state Initialize
    {
        RegisterGoal(sendToBase50000,"translateGoalSend50000",p_Player.GetMoneySentToBase());
        
        if(bShowFailed)
        {
            if((ResourcesLeftInMoney()+p_Player.GetMoney()+p_Player.GetMoneySentToBase())<50000)
            {
                bShowFailed=false;
                SetGoalState(sendToBase50000, goalFailed);
                AddBriefing("translateFailed264a");
                EnableEndMissionButton(true);
            }
        }
        
        if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed264b");
            EndMission(false);
        }
    }
    //-------------------------------------------------------------------------------------
    event EndMission()
    {
        p_Neutral.EnableAIFeatures(aiRejectAlliance,true);
        p_Neutral.SetEnemy(p_Player);
        p_Player.SetEnemy(p_Neutral);
        
    }
}
