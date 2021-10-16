mission "translateEDBase1"
{
    consts
    {
        accountMainBase = 1;
        accountResearchBase = 2;
        accountCareerPoints = 3;

        careerStep1 = 20;
        careerStep2 = 40;
        careerStep3 = 60;
        careerStep4 = 80;
        careerStep5 = 100;
        careerStep6 = 120;

        goalCareerStep1=0;
        goalCareerStep2=1;
        goalCareerStep3=2;
        goalCareerStep4=3;
        goalCareerStep5=4;
        goalCareerStep6=5;
    }

    player p_Player;
    player p_EnemyUCS;
    player p_EnemyLC;

    int i;
    int n_CareerPoints;
    int n_CareerStep;

    state Initialize;
    state PlayTrackState;
    state CameraMove;
    state Nothing;
    state ShowBriefing;

    state Initialize
    {
        unitex uHero;
        //----------- Goals ------------------
        RegisterGoal(goalCareerStep1,"translateGoalCareerStep1");
        RegisterGoal(goalCareerStep2,"translateGoalCareerStep2");
        RegisterGoal(goalCareerStep3,"translateGoalCareerStep3");
        RegisterGoal(goalCareerStep4,"translateGoalCareerStep4");
        RegisterGoal(goalCareerStep5,"translateGoalCareerStep5");
        RegisterGoal(goalCareerStep6,"translateGoalCareerStep6");
        EnableGoal(goalCareerStep1,true);               
        EnableGoal(goalCareerStep2,true);               
        EnableGoal(goalCareerStep3,true);               
        EnableGoal(goalCareerStep4,true);               
        EnableGoal(goalCareerStep5,true);               
        EnableGoal(goalCareerStep6,true);               
                
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_EnemyUCS = GetPlayer(1);
        p_EnemyLC = GetPlayer(3);
        //----------- AI ---------------------
        p_EnemyUCS.EnableAIFeatures(aiEnabled,false);
        p_EnemyLC.EnableAIFeatures(aiEnabled,false);
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_EnemyUCS.SetMoney(0);
        p_EnemyLC.SetMoney(0);
        
        //----------- Buildings --------------
        p_Player.EnableBuilding("EDBPP",true);
        p_Player.EnableBuilding("EDBBA",true);
        p_Player.EnableBuilding("EDBFA",true);
        p_Player.EnableBuilding("EDBWB",false);
        p_Player.EnableBuilding("EDBAB",true);
        // 2nd tab
        p_Player.EnableBuilding("EDBRE",false);
        p_Player.EnableBuilding("EDBMI",false);
        p_Player.EnableBuilding("EDBTC",false);
        // 3rd tab
        p_Player.EnableBuilding("EDBST",true);
        p_Player.EnableBuilding("EDBBT",true);
        p_Player.EnableBuilding("EDBHT",true);
        // 4th tab
        p_Player.EnableBuilding("EDBUC",false);
        p_Player.EnableBuilding("EDBRC",false);
        p_Player.EnableBuilding("EDBHQ",false);
        p_Player.EnableBuilding("EDBRA",true);
        p_Player.EnableBuilding("EDBEN1",true);
        p_Player.EnableBuilding("EDBLZ",true);
        p_Player.EnableBuilding("EDBART",false);

        p_Player.EnableCommand(commandSoldBuilding,true);
        //----------- Research ---------------
        p_Player.AddResearch("RES_MISSION_PACK1_ONLY");
        p_Player.AddResearch("RES_MSR2");
        p_Player.AddResearch("RES_MSR3");
        p_Player.AddResearch("RES_MSR4");

        p_EnemyUCS.AddResearch("RES_MISSION_PACK1_ONLY");
        p_EnemyUCS.AddResearch("RES_MSR2");
        p_EnemyUCS.AddResearch("RES_MSR3");
        p_EnemyUCS.AddResearch("RES_MSR4");

        p_EnemyLC.AddResearch("RES_MISSION_PACK1_ONLY");
        p_EnemyLC.AddResearch("RES_MSR2");
        p_EnemyLC.AddResearch("RES_MSR3");
        p_EnemyLC.AddResearch("RES_MSR4");



        //511
        p_Player.EnableResearch("RES_ED_UML3",false);
        p_Player.EnableResearch("RES_ED_UA22",false);
        p_Player.EnableResearch("RES_ED_MGen",false);//shield gen 2
        p_Player.EnableResearch("RES_ED_WSR2",false);
        p_Player.EnableResearch("RES_EDWAN1",false);
        p_Player.EnableResearch("RES_ED_WSL2",false);
        p_Player.EnableResearch("RES_ED_WSI2",false);
        p_Player.EnableResearch("RES_ED_MSC2",false);
        p_Player.EnableResearch("RES_MCH2",false);

        
        //512
        p_Player.EnableResearch("RES_ED_UMW2",false);
        p_Player.EnableResearch("RES_EDUUT",false);
        p_Player.EnableResearch("RES_ED_ACH2",false);
        p_Player.EnableResearch("RES_ED_WSL3",false);
        p_Player.EnableResearch("RES_ED_MSC3",false);
        p_Player.EnableResearch("RES_MCH3",false);
        p_Player.EnableResearch("RES_ED_SCR",false);

        //513
        p_Player.EnableResearch("RES_ED_HGen",false);//shield gen 3
        p_Player.EnableResearch("RES_ED_UMI1",false);
        p_Player.EnableResearch("RES_ED_UMW3",false);
        p_Player.EnableResearch("RES_ED_WSR3",false);//SR3
        p_Player.EnableResearch("RES_ED_ASR1",false);//helicopter rocket launcher
        p_Player.EnableResearch("RES_ED_BMD",false);//medium defense building
        p_Player.EnableResearch("RES_ED_SCR2",false);
        p_Player.EnableResearch("RES_ED_ART", false);//zeby nie mozna go bylo wynalezc bo dostajemy go w misji 513

        //514
        p_Player.EnableResearch("RES_ED_ASR2",false);//helicopter rocket launcher
        p_Player.EnableResearch("RES_ED_AMR1",false);//helicopter rocket launcher
        p_Player.EnableResearch("RES_ED_SCR3",false);
        p_Player.EnableResearch("RES_ED_UA41",false);
        p_Player.EnableResearch("RES_EDUSTEALTH",false);
        

        //515
        p_Player.EnableResearch("RES_ED_BC1",false);
        p_Player.EnableResearch("RES_ED_UA31",false);
        p_Player.EnableResearch("RES_ED_AMR2",false);//helicopter rocket launcher
        p_Player.EnableResearch("RES_ED_UHW1",false);
        p_Player.EnableResearch("RES_ED_WHC1",false);
        p_Player.EnableResearch("RES_ED_WHL1",false);
        p_Player.EnableResearch("RES_ED_WMR1",false);
        p_Player.EnableResearch("RES_ED_WHI1",false);
        p_Player.EnableResearch("RES_MMR2",false);

        //516
        p_Player.EnableResearch("RES_ED_UHT1",false);
        p_Player.EnableResearch("RES_ED_MHC2",false);
        p_Player.EnableResearch("RES_ED_WHC2",false);
        p_Player.EnableResearch("RES_ED_WHL2",false);
        p_Player.EnableResearch("RES_ED_WMR2",false);
        p_Player.EnableResearch("RES_ED_WHI2",false);
        p_Player.EnableResearch("RES_EDWEQ1",false);
        p_Player.EnableResearch("RES_EDBHT",false);

        //517
        p_Player.EnableResearch("RES_ED_UHT2",false);
        p_Player.EnableResearch("RES_ED_MHC3",false);
        p_Player.EnableResearch("RES_ED_BHD",false);//medium defense building

        //519
        p_Player.EnableResearch("RES_ED_WBT1",false);

        //521
        p_Player.EnableResearch("RES_ED_WBT2",false);
        

        //never used
        p_Player.EnableResearch("RES_ED_AB1",false);
        p_Player.EnableResearch("RES_ED_WHR1",false);

        p_Player.EnableResearch("RES_ED_USS1",false);
        p_Player.EnableResearch("RES_ED_USS2",false);
        p_Player.EnableResearch("RES_ED_USM1",false);
        p_Player.EnableResearch("RES_ED_USM2",false);
        p_Player.EnableResearch("RES_ED_WHI1",false);

        p_Player.EnableResearch("RES_ED_WHC1",false);
        p_Player.EnableResearch("RES_ED_WMR1",false);
        p_Player.EnableResearch("RES_ED_WHL1",false);

        //--- Timers -------------------------
        SetTimer(0,10);
        //----------- Camera -----------------
        CallCamera();
        EnableInterface(false);
        EnableCameraMovement(false);
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY()-25,20,128,30,0);
        p_Player.DelayedLookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),10,128,40,0,80,1);
        return PlayTrackState,3;                
    }

    state PlayTrackState
    {
        TraceD("!!!!!!!!!PlayTrack: music\\edday_3.mp2\n");
        PlayTrack("music\\edday_3.mp2");
        return CameraMove,77;
    }
    //-----------------------------------------------------------------------------------------
    state CameraMove
    {
        p_Player.DelayedLookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),5,0,60,0,80,1);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        EnableInterface(true);
        EnableCameraMovement(true);
        AddBriefing("translateStartCampaignEDMP01",p_Player.GetName());
        Snow(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),45,400,5000,800,10); 
        return Nothing,50;
    }

    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(p_Player.GetScriptData(7))//Attack
        {
            CallCamera();
            AddBriefing("translateBriefingBase1a");
            p_Player.SetScriptData(7,0);
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX(),  p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA11","UCSWAP1",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+1,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA11","UCSWAP1",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+2,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA11","UCSWAP1",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+3,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA11","UCSWAP1",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+4,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA11","UCSWAP1",null,null,null,0);                  
        }
        if(p_Player.GetScriptData(8))//Attack
        {
            CallCamera();
            AddBriefing("translateBriefingBase1b");
            p_Player.SetScriptData(8,0);
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX(),  p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA13","UCSWAP2",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+1,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA13","UCSWAP2",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+2,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA13","UCSWAP2",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+3,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA13","UCSWAP2",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+4,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA13","UCSWAP2",null,null,null,0);                  
        }
        if(p_Player.GetScriptData(9))//Attack
        {
            CallCamera();
            AddBriefing("translateBriefingBase1c");
            p_Player.SetScriptData(9,0);
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX(),  p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA22","UCSWAMR2",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+1,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA22","UCSWAMR2",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+2,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA22","UCSWAMR2",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+3,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA22","UCSWAPB2",null,null,null,0);                  
            p_EnemyUCS.CreateUnitEx(p_EnemyUCS.GetStartingPointX()+4,p_EnemyUCS.GetStartingPointY()+5,  0,null,"UCSUA22","UCSWAPB2",null,null,null,0);                  
        }
        if(p_Player.GetScriptData(accountMainBase))//Chash for accomplished mission
        {
            p_Player.AddMoney(p_Player.GetScriptData(accountMainBase));
            p_Player.SetScriptData(accountMainBase,0);
        }
        if(p_Player.GetScriptData(accountCareerPoints))
        {
            n_CareerPoints = n_CareerPoints+p_Player.GetScriptData(accountCareerPoints);
            p_Player.SetScriptData(accountCareerPoints,0);
        }


        if(n_CareerStep==0 && 
            n_CareerPoints >= careerStep1)
        {
            SetGoalState(goalCareerStep1, goalAchieved);
            ShowVideo("Cutscene10.wd1");
            n_CareerStep=1;
        }
        if(n_CareerStep==1 && n_CareerPoints >= careerStep2)
        {
            SetGoalState(goalCareerStep2, goalAchieved);
            ShowVideo("Cutscene11.wd1");
            n_CareerStep=2;
        }
        if(n_CareerStep==2 && n_CareerPoints >= careerStep3)
        {
            SetGoalState(goalCareerStep3, goalAchieved);
            ShowVideo("Cutscene12.wd1");
            n_CareerStep=3;
        }
        if(n_CareerStep==3 && n_CareerPoints >= careerStep4)
        {
            SetGoalState(goalCareerStep4, goalAchieved);
            ShowVideo("Cutscene13.wd1");
            n_CareerStep=4;
        }
        if(n_CareerStep==4 && n_CareerPoints >= careerStep5)
        {
            SetGoalState(goalCareerStep5, goalAchieved);
            ShowVideo("Cutscene14.wd1");
            n_CareerStep=5;
        }
        if(n_CareerStep==5 && n_CareerPoints >= careerStep6)
        {
            SetGoalState(goalCareerStep6, goalAchieved);
            ShowVideo("Cutscene15.wd1");
            n_CareerStep=6;
        }
        if(n_CareerStep==0)SetConsoleText("translateMessageCareer",careerStep1 - n_CareerPoints); 
        if(n_CareerStep==1)SetConsoleText("translateMessageCareer",careerStep2 - n_CareerPoints); 
        if(n_CareerStep==2)SetConsoleText("translateMessageCareer",careerStep3 - n_CareerPoints); 
        if(n_CareerStep==3)SetConsoleText("translateMessageCareer",careerStep4 - n_CareerPoints); 
        if(n_CareerStep==4)SetConsoleText("translateMessageCareer",careerStep5 - n_CareerPoints); 
        if(n_CareerStep==5)SetConsoleText("translateMessageCareer",careerStep6 - n_CareerPoints); 
        if(n_CareerStep==6)SetConsoleText(" ");
        return Nothing,50;
    }
    //-----------------------------------------------------------------------------------------  
    event Timer0()
    {
    }

    //-----------------------------------------------------------------------------------------
    event CustomEvent0(int k1,int k2,int k3,int k4) 
    {
        if(k4==128)
        {
            EnableUnitSounds(false);
            EnableBuildingSounds(false);
        }
    }
}
