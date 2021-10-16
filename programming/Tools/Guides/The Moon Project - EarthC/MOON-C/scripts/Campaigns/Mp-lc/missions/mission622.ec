//XXX tens skrypt nie dzia³a
mission "translateMission622"
{//Prepare way for convoy
    consts
    {
        scriptFieldMoney=9;
        goalEscortConvoy = 0;
        goalAllConvoySurvived=1;
    }

    player p_Player;
    player p_Convoy;

    unitex p_ConvoyCraft1;
    unitex p_ConvoyCraft2;
    unitex p_ConvoyCraft3;
    unitex p_ConvoyCraft4;
    unitex p_ConvoyCraft5;
    unitex p_ConvoyCraft6;
    
    int bCheckEndMission;
    int nMaxTimer;
        
        
    //----------------------------------------------------------------------------------------- 
    state Initialize;
    state ShowBriefing;
    state BuildingWay;
    state OnTheWay;
    state Final1;//explanation
    state Final2;//video
    state Final3;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        int i;
        //----------- Goals ------------------
        if(GetDifficultyLevel()==0)
            RegisterGoal(goalEscortConvoy,"translateGoal622a",2);
        if(GetDifficultyLevel()==1)
            RegisterGoal(goalEscortConvoy,"translateGoal622a",4);
        if(GetDifficultyLevel()==2)
            RegisterGoal(goalEscortConvoy,"translateGoal622a",6);

        RegisterGoal(goalAllConvoySurvived,"translateGoal622b");
            
        EnableGoal(goalEscortConvoy,true);               
                
        //----------- Players ----------------
        p_Player = GetPlayer(3);

        p_Convoy = GetPlayer(1);
        p_Convoy.EnableStatistics(false);
        p_Convoy = GetPlayer(5);
        p_Convoy.LoadScript("single\\singleMedium");
        //----------- AI ---------------------
        p_Convoy.EnableAIFeatures(aiRejectAlliance,false);
        p_Player.SetAlly(p_Convoy);
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Convoy.EnableAIFeatures(aiEnabled,false);
        
        //----------- Money ------------------
        p_Player.SetMoney(20000);
        
        //----------- Researches -------------
        p_Player.EnableResearch("RES_LC_SHR1",true);//622

        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,false);
        p_Player.EnableCommand(commandAutodestruction,false);
        p_Player.EnableBuilding("LCBBF",false);
        p_Player.EnableBuilding("LCBPP",false);
        p_Player.EnableBuilding("LCBPP2",false);
        p_Player.EnableBuilding("LCBSB",false);
        p_Player.EnableBuilding("LCBBA",false);
        p_Player.EnableBuilding("LCBMR",false);
        p_Player.EnableBuilding("LCBSR",false);
        p_Player.EnableBuilding("LCBRC",false);
        p_Player.EnableBuilding("LCBAB",false);
        p_Player.EnableBuilding("LCBGA",false);
        p_Player.EnableBuilding("LCBDE",false);
        p_Player.EnableBuilding("LCBNE",false);
        p_Player.EnableBuilding("LCBHQ",false);
        p_Player.EnableBuilding("LCBART",false);
        p_Player.EnableBuilding("LCBUC",false);
        p_Player.EnableBuilding("LCBSD",false);
        p_Player.EnableBuilding("LCBWC",false);
        p_Player.EnableBuilding("LCBSS",false);
        p_Player.EnableBuilding("LCBLZ",false);
        p_Player.EnableBuilding("LCBEN1",false);

        //----------- Units ------------------
        p_ConvoyCraft1 = GetUnit(GetPointX(1),GetPointY(1),0);
        p_ConvoyCraft2 = GetUnit(GetPointX(2),GetPointY(2),0);
        p_ConvoyCraft3 = GetUnit(GetPointX(3),GetPointY(3),0);
        p_ConvoyCraft4 = GetUnit(GetPointX(4),GetPointY(4),0);
        p_ConvoyCraft5 = GetUnit(GetPointX(5),GetPointY(5),0);
        p_ConvoyCraft6 = GetUnit(GetPointX(6),GetPointY(6),0);
        //----------- Artefacts --------------
        for(i=10;i<=50;i=i+1)
        {
            CreateArtefact("NEAMINE",GetPointX(i),GetPointY(i),GetPointZ(i),i,artefactSpecialAIOther);
        }
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        if(GetDifficultyLevel()==0)
        {
            AddBriefing("translateBriefing622a",p_Player.GetName(),2);
            nMaxTimer=60*7;
        }
            
        if(GetDifficultyLevel()==1)
        {
            AddBriefing("translateBriefing622a",p_Player.GetName(),4);
            nMaxTimer=60*5;
        }
            
        if(GetDifficultyLevel()==2)
        {
            AddBriefing("translateBriefing622a",p_Player.GetName(),6);
            nMaxTimer=60*3;
        }
        if(GetDifficultyLevel()!=2) 
            ShowArea(8,GetPointX(0),GetPointY(0),0,128);
        return BuildingWay,20;
    }
    //-----------------------------------------------------------------------------------------  
    state BuildingWay
    {
        SetConsoleText("translateMessage622",nMaxTimer);
        nMaxTimer=nMaxTimer-1;
        if(!nMaxTimer)
        {
            SetConsoleText("");
            AddBriefing("translateBriefing622b",p_Player.GetName());
            return OnTheWay;
        }
        return BuildingWay,20;
    }
    //-----------------------------------------------------------------------------------------  
    state OnTheWay
    {
        int nGoToPoint;
        int bMakeStep;
        int nTrucksFinished;
        int nTrucksAlive;
        int j;
        
        bMakeStep=false;
        
        
        p_ConvoyCraft1.CommandMove(GetPointX(0),GetPointY(0),0);
        p_ConvoyCraft2.CommandMove(GetPointX(0),GetPointY(0),0);
        p_ConvoyCraft3.CommandMove(GetPointX(0),GetPointY(0),0);
        p_ConvoyCraft4.CommandMove(GetPointX(0),GetPointY(0),0);
        p_ConvoyCraft5.CommandMove(GetPointX(0),GetPointY(0),0);
        p_ConvoyCraft6.CommandMove(GetPointX(0),GetPointY(0),0);

        nTrucksAlive=0;

        if(p_ConvoyCraft1.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft2.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft3.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft4.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft5.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft6.IsLive())nTrucksAlive=nTrucksAlive+1;

        nTrucksFinished=0;
        
        if(p_ConvoyCraft1.IsLive() && p_ConvoyCraft1.DistanceTo(GetPointX(0),GetPointY(0)) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft2.IsLive() && p_ConvoyCraft2.DistanceTo(GetPointX(0),GetPointY(0)) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft3.IsLive() && p_ConvoyCraft3.DistanceTo(GetPointX(0),GetPointY(0)) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft4.IsLive() && p_ConvoyCraft4.DistanceTo(GetPointX(0),GetPointY(0)) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft5.IsLive() && p_ConvoyCraft5.DistanceTo(GetPointX(0),GetPointY(0)) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft6.IsLive() && p_ConvoyCraft6.DistanceTo(GetPointX(0),GetPointY(0)) < 7)nTrucksFinished=nTrucksFinished+1;

        if(
             nTrucksAlive==nTrucksFinished &&(
             ((GetDifficultyLevel()==0 && nTrucksFinished>1)||
             ((GetDifficultyLevel()==1)&& nTrucksFinished>3)||
             ((GetDifficultyLevel()==2)&& nTrucksFinished>5))))
        {
            SetGoalState(goalEscortConvoy, goalAchieved);
            
            if(nTrucksFinished==6)
            {
                p_Player.EnableBuilding("LCBLZ",true);
                p_Player.SetMoney(p_Player.GetMoney()+2000);
                p_Convoy.GiveAllUnitsTo(p_Player);
                EnableGoal(goalAllConvoySurvived,true);               
                SetGoalState(goalAllConvoySurvived, goalAchieved);
                AddBriefing("translateAccomplished622b",p_Player.GetName());

            }
            else
                AddBriefing("translateAccomplished622a",p_Player.GetName());
            
            return Final1,100;
        }
        return OnTheWay,200;
    }
    //-----------------------------------------------------------------------------------------
    state Final1
    {
        AddBriefing("translateExplanation622",p_Player.GetName());
        return Final2,1;
    }
    //-----------------------------------------------------------------------------------------
    state Final2
    {
        ShowVideo("cutscene3");
        return Final3,20;
    }
    //-----------------------------------------------------------------------------------------
    state Final3
    {
        EnableEndMissionButton(true);
       return Final3,10000;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        int nLostConvoyCrafts;

        if(!bCheckEndMission)return;

        bCheckEndMission=false;
            
        if(GetGoalState(goalEscortConvoy)==goalNotAchieved)
        {
            if(!p_ConvoyCraft1.IsLive())nLostConvoyCrafts=1;
            if(!p_ConvoyCraft2.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;
            if(!p_ConvoyCraft3.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;
            if(!p_ConvoyCraft4.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;
            if(!p_ConvoyCraft5.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;
            if(!p_ConvoyCraft6.IsLive())nLostConvoyCrafts=nLostConvoyCrafts+1;

            if(
                 ((GetDifficultyLevel()==0 && nLostConvoyCrafts>4)||
                 ((GetDifficultyLevel()==1)&& nLostConvoyCrafts>2)||
                 ((GetDifficultyLevel()==2)&& nLostConvoyCrafts>0)))
            {
                SetGoalState(goalEscortConvoy, goalFailed);
                AddBriefing("translateFailed622a",p_Player.GetName());
                EnableEndMissionButton(true,false);
                state Final1;
            }
        }
        
        if(!p_Player.GetNumberOfUnits() &&!p_Player.GetNumberOfBuildings())
        {
            if(GetGoalState(goalEscortConvoy)!=goalAchieved)
            {
                AddBriefing("translateFailed622b",p_Player.GetName());
                EndMission(false);
            }
            else
            {
                EndMission(true);
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
        if(GetGoalState(goalEscortConvoy)==goalAchieved)
        {
            p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
            p_Player.SetMoney(0);
        }
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        KillArea(255, GetPointX(aID),GetPointY(aID),GetPointZ(aID),1);
        return false; //nie usuwa sie 
    }
}
