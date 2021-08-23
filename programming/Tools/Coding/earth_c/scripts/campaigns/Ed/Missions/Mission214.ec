mission "translateMission214"
{//Antarktyka centrum - stara baza Rosyjska  
    consts
    {
        findBase = 0;
        findHangar = 1;
        findCommandCenter = 2;
        sendToBase50000 = 3;
    }
    
    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Neutral;
    player p_Player;
    
    int bShowFailed;
    int bSwitchOnAI;
    int bCheckEndMission;
    int n_HangarX;
    int n_HangarY;
    int n_CenterX;
    int n_CenterY;
    
    //----------------------------------------------------------------------------------------- 
    state Initialize;
    state ShowBriefing;
    state LocateUnits;
    state ExploringBase;
    state Mining;
    state Evacuate;
    
    state Initialize
    {
        player tmpPlayer;
        tmpPlayer = GetPlayer(3); 
        tmpPlayer.EnableStatistics(false);
        
        RegisterGoal(findBase,"translateGoal214a");
        RegisterGoal(findHangar,"translateGoal214b");
        RegisterGoal(findCommandCenter,"translateGoal214c");
        RegisterGoal(sendToBase50000,"translateGoalSend50000");
        
        EnableGoal(findBase,true);                  
        EnableGoal(findHangar,true);           
        
        
        n_HangarX=GetPointX(0);
        n_HangarY=GetPointY(0);
        n_CenterX=GetPointX(1);
        n_CenterY=GetPointY(1);
        
        p_Player = GetPlayer(2);
        p_Neutral= GetPlayer(4);
        p_Enemy1 = GetPlayer(1);
        p_Enemy2 = GetPlayer(5);
        p_Enemy3 = GetPlayer(6);
        
        p_Player.SetMoney(10000);
        p_Enemy1.SetMoney(25000);
        p_Enemy2.SetMoney(25000);
        p_Enemy3.SetMoney(25000);
        
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy3.LoadScript("single\\singleEasy");
        }
        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Enemy3.LoadScript("single\\singleMedium");
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Enemy3.LoadScript("single\\singleHard");
        }
        
        
        p_Enemy1.SetAlly(p_Enemy2);
        p_Enemy2.SetAlly(p_Enemy3);
        p_Enemy3.SetAlly(p_Enemy1);
        
        p_Player.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Player);
        
        p_Neutral.EnableStatistics(false);
        
        p_Enemy1.EnableAIFeatures(aiControlOffense,false);
        p_Enemy2.EnableAIFeatures(aiControlOffense,false);
        p_Enemy3.EnableAIFeatures(aiControlOffense,false);
        
        p_Player.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        
        bShowFailed=false;
        bSwitchOnAI=false;
        bCheckEndMission=false;
        
        SetTimer(0,100);
        SetTimer(1,6000);
        
        
        CreateArtefact("NEASPECIAL2",n_CenterX,n_CenterY,1,0,artefactSpecialAIOther);
        
        
        p_Enemy1.EnableResearch("RES_UCS_WCH2",true);
        p_Enemy1.EnableResearch("RES_MCH2",true);
        p_Enemy1.EnableResearch("RES_UCS_GARG1",true);
        
        p_Enemy2.EnableResearch("RES_UCS_WSP1",false);
        p_Enemy3.EnableResearch("RES_UCS_WSP1",false);
        
        p_Enemy2.CopyResearches(p_Enemy1);
        p_Enemy3.CopyResearches(p_Enemy1);
        
        p_Player.EnableResearch("RES_ED_WCA2",true);
        p_Player.EnableResearch("RES_ED_MSC2",true);
        p_Player.EnableResearch("RES_ED_UMT1",true);
        p_Player.EnableResearch("RES_ED_RepHand",true);
        
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
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",false);
        p_Player.EnableBuilding("EDBEN1",true);
        p_Player.EnableBuilding("EDBLZ",true);
        
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,128,20,0);
        p_Player.DelayedLookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0,60,0);
        return ShowBriefing,200;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing214a");
        return LocateUnits,100;
    }
    //-----------------------------------------------------------------------------------------
    
    state LocateUnits
    {
        if(GetGoalState(findBase)!=goalAchieved && p_Player.IsPointLocated(n_HangarX,n_HangarY,0))
        {
            SetGoalState(findBase, goalAchieved);
        }
        
        if(p_Player.IsPointLocated(n_HangarX,n_HangarY,1))
        {
            p_Player.LookAt(n_HangarX,n_HangarY,10,0,20,1);
            SetGoalState(findHangar, goalAchieved);
            EnableGoal(findCommandCenter,true);
            bSwitchOnAI=true;
            AddBriefing("translateBriefing214b");
            return ExploringBase,100;
        }
        return LocateUnits,100;
    }
    //-----------------------------------------------------------------------------------------
    state ExploringBase
    {
        return ExploringBase,100;
    }
    //-----------------------------------------------------------------------------------------
    state Mining
    {
        if(p_Player.GetMoneySentToBase()>=50000)
        {
            SetGoalState(sendToBase50000, goalAchieved);
            AddBriefing("translateAccomplished214");
            EnableEndMissionButton(true);
            
            return Evacuate,500;
        }
        return Mining,100;
    }
    //-----------------------------------------------------------------------------------------
    state Evacuate
    {
        return Evacuate,500;
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
        if(GetDifficultyLevel()!=0)
        {
            if(u_Unit.GetIFFNumber()==p_Enemy1.GetIFFNumber())
            {
                p_Enemy2.Attack(n_HangarX,n_HangarY,0);
                p_Enemy3.Attack(n_HangarX,n_HangarY,0);
                p_Enemy2.EnableAIFeatures(aiControlOffense,true);
                p_Enemy3.EnableAIFeatures(aiControlOffense,true);
            }
            if(u_Unit.GetIFFNumber()==p_Enemy2.GetIFFNumber())
            {
                p_Enemy1.Attack(n_HangarX,n_HangarY,0);
                p_Enemy3.Attack(n_HangarX,n_HangarY,0);
                p_Enemy1.EnableAIFeatures(aiControlOffense,true);
                p_Enemy3.EnableAIFeatures(aiControlOffense,true);
            }
            if(u_Unit.GetIFFNumber()==p_Enemy3.GetIFFNumber())
            {
                p_Enemy1.Attack(n_HangarX,n_HangarY,0);
                p_Enemy2.Attack(n_HangarX,n_HangarY,0);
                p_Enemy1.EnableAIFeatures(aiControlOffense,true);
                p_Enemy2.EnableAIFeatures(aiControlOffense,true);
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        RegisterGoal(sendToBase50000,"translateGoalSend50000",p_Player.GetMoneySentToBase());
        
        if(bShowFailed)
        {
            if((ResourcesLeftInMoney()+p_Player.GetMoney()+p_Player.GetMoneySentToBase())<50000)
            {
                bShowFailed=false;
                SetGoalState(sendToBase50000, goalFailed);
                AddBriefing("translateFailed214a");
                EnableEndMissionButton(true);
            }
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!p_Player.GetNumberOfBuildings() && !p_Player.GetNumberOfUnits())
            {
                AddBriefing("translateFailed214b");
                EndMission(false);
            }
        }
    }  
    //-----------------------------------------------------------------------------------------  
    event Timer1() 
    {
        Snow(p_Neutral.GetStartingPointX(),p_Neutral.GetStartingPointY(),30,400,2500,800,10); 
        Snow(p_Neutral.GetStartingPointX(),p_Neutral.GetStartingPointY(),30,400,2500,800,10); 
        Snow(p_Neutral.GetStartingPointX(),p_Neutral.GetStartingPointY(),30,400,2500,800,10); 
        Snow(p_Neutral.GetStartingPointX(),p_Neutral.GetStartingPointY(),30,400,2500,800,10); 
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(p_Player == piPlayer)
        {
            p_Player.EnableBuilding("EDBPP",true);
            p_Player.EnableBuilding("EDBBA",true);
            p_Player.EnableBuilding("EDBFA",true);
            p_Player.EnableBuilding("EDBWB",true);
            p_Player.EnableBuilding("EDBAB",true);
            // 2nd tab
            p_Player.EnableBuilding("EDBRE",true);
            p_Player.EnableBuilding("EDBMI",true);
            p_Player.EnableBuilding("EDBTC",true);
            // 3rd tab
            p_Player.EnableBuilding("EDBST",true);
            // 4th tab
            p_Player.EnableBuilding("EDBHQ",true);
            p_Player.EnableBuilding("EDBEN1",true);
            p_Player.EnableBuilding("EDBLZ",true);
            
            p_Player.LookAt(n_CenterX,n_CenterY,10,0,20,1);
            SetGoalState(findCommandCenter, goalAchieved);
            EnableGoal(sendToBase50000,true);
            AddBriefing("translateBriefing214c");
            p_Neutral.GiveAllUnitsTo(p_Player);
            p_Neutral.GiveAllBuildingsTo(p_Player);
            
            p_Enemy1.EnableAIFeatures(aiControlOffense,true);
            bShowFailed=true;
            state Mining;
            return true; //usuwa sie 
        }    
        return false;
    }
    //-----------------------------------------------------------------------------------------
    event EndMission()
    {
        p_Player.SetEnemy(p_Neutral);
        p_Neutral.SetEnemy(p_Player);
        p_Enemy2.EnableResearch("RES_UCS_WSP1",true);
        p_Enemy3.EnableResearch("RES_UCS_WSP1",true);
    }
    
}
