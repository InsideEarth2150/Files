mission "translateMission354"
{
    consts
    {
        destroyEnemyBase = 0;
        backToBase = 1;
    }
    
    player pEnemy;
    player pPlayer;
    player pCannon;
    
    unitex uHero;
    unitex uCannon;
    unitex uPP;
    
    int bCanCaptureCannon;    
    int bCannonFireCounter;
    int bCheckEndMission;
    
    state Initialize;
    state ShowBriefing;
    state Fighting;
    state ShowVideoState;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        player tmpPlayer;
        //----------- Goals ------------------
        RegisterGoal(destroyEnemyBase,"translateGoal354");
        RegisterGoal(backToBase,"translateGoalHeroBackToBase");
        EnableGoal(destroyEnemyBase,true);
        
        //----------- Temporary players ------
        tmpPlayer = GetPlayer(2); 
        tmpPlayer.EnableStatistics(false);
        
        //----------- Players ----------------
        pPlayer = GetPlayer(3);
        pEnemy = GetPlayer(1);
        pCannon = GetPlayer(6);
        //----------- AI ---------------------
        pPlayer.SetMilitaryUnitsLimit(30000);
        pCannon.EnableStatistics(false);
        pCannon.EnableAIFeatures(aiEnabled,false);
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        
        if(GetDifficultyLevel()==0)
            pEnemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            pEnemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            pEnemy.LoadScript("single\\singleHard");
        
        pPlayer.EnableAIFeatures(aiEnabled,false);
        //pEnemy.AddToMainTargetList();
        //----------- Money ------------------
        pPlayer.SetMoney(10000);
        pEnemy.SetMoney(40000);
        
        //----------- Researches -------------
        pPlayer.EnableResearch("RES_LC_WHS1",true);
        pPlayer.EnableResearch("RES_LC_WAS1",true);
        pPlayer.EnableResearch("RES_MMR3",true);
        pPlayer.EnableResearch("RES_LC_UCU1",true);
        pPlayer.EnableResearch("RES_LC_AMR1",true);
        pPlayer.EnableResearch("RES_LC_UBO1",true);
        pPlayer.EnableResearch("RES_LC_REG2",true);
        
        tmpPlayer.EnableResearch("RES_UCS_WHP1",true);
        tmpPlayer.EnableResearch("RES_UCS_WAPB1",true);
        tmpPlayer.EnableResearch("RES_UCS_UBL1",true);
        tmpPlayer.EnableResearch("RES_UCS_UMI1",true);
        tmpPlayer.EnableResearch("RES_UCS_BOMBER31",true);
        tmpPlayer.EnableResearch("RES_UCS_SHD",true);
        //----------- Buildings --------------
        //----------- Units ------------------
        uHero=pPlayer.GetScriptUnit(0);
        uCannon = GetUnit(GetPointX(0),GetPointY(0),0);
        uPP = GetUnit(GetPointX(1),GetPointY(1),0);
        //----------- Artefacts --------------
        //----------- Timers -----------------
        SetTimer(0,100);
        SetTimer(1,10000);
        //----------- Variables --------------
        bCheckEndMission=false;
        bCanCaptureCannon=true;
        bCannonFireCounter=0;
        //----------- Camera -----------------
        CallCamera();
        pPlayer.LookAt(pPlayer.GetStartingPointX(),pPlayer.GetStartingPointY(),6,0,20,0);
        ShowArea(8,GetPointX(0),GetPointY(0),0,3);
        return ShowBriefing,200;//15 sec
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableNextMission(0,true);
        AddBriefing("translateBriefing354a",pPlayer.GetName());//zniszcz baze ED mamy kody do ich dziala plazmowego mozesz je przejac musisz tylko tam sie dostac
        return Fighting,100;
    }
    //-----------------------------------------------------------------------------------------
    state Fighting
    {
        int timeToExplode;
        if(bCanCaptureCannon &&
            uHero.IsInWorld(GetWorldNum()) &&
            uHero.DistanceTo(GetPointX(0),GetPointY(0))<10 && 
            !uHero.GetLocationZ())
        {
            bCanCaptureCannon=false;
            bCannonFireCounter=5;
            AddBriefing("translateBriefing354b",pPlayer.GetName());
            pCannon.GiveAllBuildingsTo(pPlayer);
            return Fighting,20; 
        }
        
        if(bCannonFireCounter)
        {
            bCannonFireCounter=bCannonFireCounter-1;
            
            if(bCannonFireCounter==2)
            {
                uCannon.ChangePlayer(pEnemy);
                uPP.ChangePlayer(pEnemy);
                KillArea(2,GetPointX(0),GetPointY(0),0,10); 
            }
            
            if(!bCannonFireCounter)
            {
                AddBriefing("translateBriefing354c",pPlayer.GetName());
                SetConsoleText("");
            }
            else
                SetConsoleText("translateMessage354",bCannonFireCounter+50);//tik tik time remaining
            return Fighting,20; 
        }
        
        return Fighting,200; 
    }
    //-----------------------------------------------------------------------------------------
    state ShowVideoState
    {
        ShowVideo("CS310");
        EnableEndMissionButton(true);
        return Nothing,100;
    }
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(GetGoalState(backToBase)!=goalAchieved && !uHero.IsInWorld(GetWorldNum()))
        {
            SetGoalState(backToBase,goalAchieved);
            EnableEndMissionButton(true);
        }
        return Nothing, 100;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(bCheckEndMission)
        {
            bCheckEndMission=false;
            if(!pPlayer.GetNumberOfUnits() && !pPlayer.GetNumberOfBuildings())
            {
                AddBriefing("translateFailedNoUnits",pPlayer.GetName());
                EndMission(false);
            }
            
            if(GetGoalState(destroyEnemyBase)!=goalAchieved && pEnemy.GetNumberOfBuildings()<3)
            {
                SetGoalState(destroyEnemyBase, goalAchieved);
                EnableGoal(backToBase,true);
                AddBriefing("translateAccomplished354",pPlayer.GetName());
                state ShowVideoState;
            }
        }
    }
    //-----------------------------------------------------------------------------------------
    event Timer1() //wolany co 6000 cykli
    {
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
}

