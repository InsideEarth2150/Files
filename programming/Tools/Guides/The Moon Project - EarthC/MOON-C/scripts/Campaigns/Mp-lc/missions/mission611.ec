// ucs wyladowa³ na ksiezycu. Uzywa specjalistycznych pojazdów obardzo duzej sile razenia.
//zaatakowali nasze centrum badania nowych technologii.

// fat girl jest dopiero prototypem ale musisz go uzyc aby zniszczyc wroga.

//Pojazdy wroga zosta³y rozdzielone wiec spróbuj je zniszczyc pojedynczo.



mission "translateMission611"
{
    consts
    {
        scriptFieldMoney=9;
        goalDestroyUCSUnits = 0;
        goalDestroyUCSBuildings = 1;
    }

    int bCheckEndMission;
    player p_Enemy;
    player p_Player;
        
    state Initialize;
    state ShowBriefing;
    state EndMissionFailed;
    state Working;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(goalDestroyUCSUnits,"translateGoal611a");
        RegisterGoal(goalDestroyUCSBuildings,"translateGoal611b");
                

        EnableGoal(goalDestroyUCSUnits,true);
        EnableGoal(goalDestroyUCSBuildings,true);

        //----------- Players ----------------
        p_Player = GetPlayer(3);
        p_Enemy  = GetPlayer(1);
                
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
            p_Enemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.LoadScript("single\\singleHard");
            p_Enemy.SetNumberOfOffensiveTankPlatoons(2);
            p_Enemy.SetNumberOfOffensiveShipPlatoons(0);
            p_Enemy.SetNumberOfOffensiveHelicopterPlatoons(2);
        }
        //----------- Money ------------------
        if(GetDifficultyLevel()==0)
        {
            p_Player.SetMoney(30000);
            p_Enemy.SetMoney(10000);
        }
        if(GetDifficultyLevel()==1)
        {
            p_Player.SetMoney(20000);
            p_Enemy.SetMoney(20000);
        }
        if(GetDifficultyLevel()==2)
        {
            p_Player.SetMoney(10000);
            p_Enemy.SetMoney(30000);
        }
                
        
        if(GetDifficultyLevel()==0)
        {
            KillArea(2,GetPointX(0), GetPointY(0), 0,1);
            KillArea(2,GetPointX(1), GetPointY(1), 0,1);
        }
        if(GetDifficultyLevel()==1)
        {
            KillArea(2,GetPointX(1), GetPointY(1), 0,1);
        }

        bCheckEndMission=false;                 

        p_Player.EnableResearch("RES_LC_SGen",true);//611
        p_Player.EnableResearch("RES_LC_UMO2",true);//611
        p_Player.EnableResearch("RES_LC_WSL1",true);//611

        //----------- Buildings --------------
        p_Player.EnableBuilding("LCBPP2",false);
        p_Player.EnableBuilding("LCBHQ",false);
        p_Player.EnableBuilding("LCBRC",false);
        p_Player.EnableBuilding("LCBEN1",false);
        p_Player.EnableBuilding("LCBSR",false);
        p_Player.EnableBuilding("LCBSD",false);
        p_Player.EnableBuilding("LCBSS",false);
        p_Player.EnableBuilding("LCBART",false);

        p_Player.AddResearch("RES_LCUFG1");
        p_Player.AddResearch("RES_LC_WSL1");

        p_Enemy.AddResearch("RES_MISSION_PACK1_ONLY");
        p_Enemy.AddResearch("RES_MSR2");
        p_Enemy.AddResearch("RES_MSR3");
        p_Enemy.AddResearch("RES_MSR4");

        p_Player.EnableResearch("RES_LCUFG1",true);
        p_Player.EnableResearch("RES_LC_WSL1",true);

        p_Enemy.EnableResearch("RES_MSR2",true);
        p_Enemy.EnableResearch("RES_MSR3",true);
        p_Enemy.EnableResearch("RES_MSR4",true);

        SetTimer(0,100);
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        return ShowBriefing,1;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing611a", p_Player.GetName());
        if(GetDifficultyLevel()==0)
            MeteorRain(GetPointX(2), GetPointY(2),40,100,30000,100,1,1);
        if(GetDifficultyLevel()==1)
            MeteorRain(GetPointX(2), GetPointY(2),40,100,30000,100,3,2);
        if(GetDifficultyLevel()==2)
            MeteorRain(GetPointX(2), GetPointY(2),40,100,30000,100,6,3);
        return Working, 20;
    }
    //-----------------------------------------------------------------------------------------
    state EndMissionFailed
    {
        EnableNextMission(0,2);
        return Nothing;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {

        //--- all goals achievwd ---
        if(GetGoalState(goalDestroyUCSUnits)==goalAchieved && 
            GetGoalState(goalDestroyUCSBuildings)==goalAchieved)
        {
            EnableNextMission(0,true);
            EnableNextMission(1,true);
            p_Player.AddResearch("RES_LCUFG1");//611 add
            p_Player.EnableResearch("RES_LCUFG2",true);//611
            AddBriefing("translateAccomplished611", p_Player.GetName());
            EnableEndMissionButton(true);
            return Nothing;
        }
    }
   //-----------------------------------------------------------------------------------------
 
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
        if(!bCheckEndMission)return;

        bCheckEndMission=false;
            
        if(!p_Player.GetNumberOfUnits() && !p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed611", p_Player.GetName());
            state EndMissionFailed;
        }
        
        if(GetGoalState(goalDestroyUCSUnits)!=goalAchieved && 
            !p_Enemy.GetNumberOfUnits())
        {
            SetGoalState(goalDestroyUCSUnits, goalAchieved);
            AddBriefing("translateBriefing611b", p_Player.GetName());
        }

        if(GetGoalState(goalDestroyUCSBuildings)!=goalAchieved && 
            !p_Enemy.GetNumberOfBuildings())
        {
            SetGoalState(goalDestroyUCSBuildings, goalAchieved);
            AddBriefing("translateBriefing611c", p_Player.GetName());
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
        if(GetGoalState(goalDestroyUCSUnits)==goalAchieved && 
            GetGoalState(goalDestroyUCSBuildings)==goalAchieved)
        {
            p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
            p_Player.SetMoney(0);
        }
    }

}
