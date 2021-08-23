mission "translateMission142"
{
    consts
    {
        protectMeeting = 0;
        ecsortLC = 1;
        attackTime = 1200;
        briefingTime = 3400;
        endMeetingTime = 6000; 
        
    }
    
    player pEnemy;
    player pLC;
    player pLCunits;
    player pPlayer;
    player pUCSunits;
    
    unitex uLC;
    unitex uUCS;
    
    
    int bCheckEndMission;
    int nMissionStep;
    
    
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(protectMeeting,"translateGoal142a");
        RegisterGoal(ecsortLC,"translateGoal142b");
        EnableGoal(protectMeeting,true);
        
        //----------- Temporary players ------
        //----------- Players ----------------
        pPlayer = GetPlayer(1);
        pEnemy =  GetPlayer(2);
        pLC =     GetPlayer(3);
        pLCunits =GetPlayer(4);
        pUCSunits=GetPlayer(6);
        //----------- AI ---------------------
        pLCunits.EnableStatistics(false);
        pUCSunits.EnableStatistics(false);
        
        if(GetDifficultyLevel()==0)
        {
            pEnemy.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            pEnemy.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            pEnemy.LoadScript("single\\singleHard");
        }
        pLC.LoadScript("single\\singleHard");
        pLCunits.LoadScript("single\\singleHard");
        pUCSunits.LoadScript("single\\singleHard");
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        pEnemy.EnableAIFeatures(aiControlOffense,false);
        //pEnemy.EnableAIFeatures(aiControlDefense,false);
        pLC.EnableAIFeatures(aiControlOffense,false);
        
        pLCunits.EnableAIFeatures(aiEnabled,false);
        pUCSunits.EnableAIFeatures(aiEnabled,false);
        
        pLC.EnableAIFeatures(aiRejectAlliance,false);
        pLCunits.EnableAIFeatures(aiRejectAlliance,false);
        pUCSunits.EnableAIFeatures(aiRejectAlliance,false);
        
        pLC.SetEnemy(pEnemy);
        pLCunits.SetEnemy(pEnemy);
        pUCSunits.SetEnemy(pEnemy);
        
        pPlayer.SetAlly(pLCunits);
        pPlayer.SetAlly(pUCSunits);
        
        pUCSunits.SetAlly(pLC);
        pUCSunits.SetAlly(pLCunits);
        
        pLCunits.ChooseEnemy(pEnemy);
        pUCSunits.ChooseEnemy(pEnemy);
        pLC.ChooseEnemy(pEnemy);
        
        pLCunits.SetNeutral(pEnemy);
        
        pEnemy.SetEnemy(pLCunits);
        pEnemy.SetEnemy(pLCunits);
        pEnemy.SetEnemy(pLC);
        
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        pEnemy.SetMoney(30000);
        pLC.SetMoney(30000);
        //----------- Researches -------------
        pEnemy.EnableResearch("RES_ED_UMI1",true);
        
        pLC.EnableResearch("RES_LC_REG1",true); 
        pLC.EnableResearch("RES_LC_SHR1",true); 
        
        pPlayer.EnableResearch("RES_UCS_WMR1",true);
        pPlayer.EnableResearch("RES_MMR2",true);
        pPlayer.EnableResearch("RES_UCS_UAH1",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        uLC = GetUnit(GetPointX(0),GetPointY(0),0);
        uUCS = GetUnit(GetPointX(1),GetPointY(1),0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        if(GetDifficultyLevel()==0)
            SetTimer(0,12000);
        if(GetDifficultyLevel()==1)
            SetTimer(0,9000);
        if(GetDifficultyLevel()==2)
            SetTimer(0,6000);
        
        //----------- Variables --------------
        bCheckEndMission=false;
        nMissionStep=0;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        return ShowBriefing,100;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing142a");
        uLC.CommandMove(GetPointX(2),GetPointY(2),0);
        uUCS.CommandMove(GetPointX(2),GetPointY(2),0);
        EnableNextMission(0,true);
        return Fighting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        if(GetMissionTime()>=attackTime && !nMissionStep)
        {
            nMissionStep=1;
            pEnemy.Attack(GetPointX(2),GetPointY(2),0);  
        }
        
        if(GetMissionTime()>=briefingTime && nMissionStep==1)
        {
            nMissionStep=2;
            AddBriefing("translateBriefing142b");//neo here -> protekt meeting
        }
        if(GetMissionTime()>=endMeetingTime && nMissionStep==2)
        {
            nMissionStep=3;
            SetGoalState(protectMeeting,goalAchieved);
            pPlayer.SetAlly(pLC);
            EnableGoal(ecsortLC,true);
            uLC.ChangePlayer(pPlayer);
            uUCS.ChangePlayer(pPlayer);
            AddBriefing("translateBriefing142c");//meeting is over -> escort LC to the base
        }
        
        if(uLC.DistanceTo(GetPointX(5),GetPointY(5))<14)
        {
            uLC.ChangePlayer(pLC);
            SetGoalState(ecsortLC,goalAchieved);
            AddBriefing("translateAccomplished142");
            EnableNextMission(0,false);
            EnableNextMission(1,true);
            EnableNextMission(2,true);
            EnableEndMissionButton(true);
            return Nothing;
        }
        
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!uLC.IsLive())
            {
                SetGoalState(ecsortLC,goalFailed);
                pLC.SetEnemy(pPlayer);
                pPlayer.SetEnemy(pLC);
                AddBriefing("translateFailed142a",pPlayer.GetName());
                EnableEndMissionButton(true,false);
                return Nothing;
            }
            
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailed142b");
                EndMission(false);
            }
        }
        return Fighting,200; 
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0()
    {
        if(nMissionStep>2)
        {
            pEnemy.Attack(uLC.GetLocationX(),uLC.GetLocationY(),uLC.GetLocationZ());
        }
    }
    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit uUnit)
    {
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event BuildingDestroyed(unit uUnit)
    { 
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        pLC.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pLC);
        
        pLCunits.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pLCunits);
        
        pLC.SetEnemy(pUCSunits);
        pUCSunits.SetEnemy(pLC);
        
        pLCunits.SetEnemy(pUCSunits);
        pUCSunits.SetEnemy(pLCunits);
        
        pUCSunits.SetEnemy(pPlayer);
        pPlayer.SetEnemy(pUCSunits);
    }
}

