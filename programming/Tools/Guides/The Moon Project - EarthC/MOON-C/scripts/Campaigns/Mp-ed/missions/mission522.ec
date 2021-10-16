//Ksiezyc. Po wyladowaniu nalezy opuœciæ teren l¹dowania i udaæ siê
//do centrum sterowania dzia³em SunLight
//Po dotarciu do podziemi centrum sterowania pojazdem Kom Fiodorowa 
//uruchomiona zostaje procedura autozniszczenia
mission "translateMission522"
{

    consts
    {
        destroySunLight = 0;
        fiodorowSurvived = 1;
    }

    player p_Enemy;
    player p_Ally;
    player p_Neutral;//TunellEntrance
    player p_Player;
    
    unitex u_Fiodorow;
    
    int bCheckEndMission;
    int n_AnimationStep;
    int b_Rain1;
    int b_Rain2;
    int b_Rain3;
        
    state Initialize;
    state ShowBriefing;
    state ShowBriefingAnimation;
    state DestroySunLights;
    state ShowDestroy;
    state Nothing;
        
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        int i;
        int start;
        int end;
        int nShield;

        //----------- Extra ------------------
        EnableGameFeature(lockResearchDialog,true);
        EnableGameFeature(lockConstructionDialog,true);
        EnableGameFeature(lockUpgradeWeaponDialog,true);

        //----------- Goals ------------------
        RegisterGoal(destroySunLight,"translateGoal522a");
        RegisterGoal(fiodorowSurvived,"translateGoal522b");
        
        EnableGoal(destroySunLight,true);               
        EnableGoal(fiodorowSurvived,true);               
                
                
        //----------- Players ----------------
        p_Player = GetPlayer(2);
        p_Enemy = GetPlayer(3);
        p_Neutral = GetPlayer(1);
        //----------- AI ---------------------
        p_Neutral.EnableStatistics(false);  
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        p_Neutral.EnableAIFeatures(aiEnabled,false);

        if(GetDifficultyLevel()==0)
            p_Enemy.LoadScript("single\\singleEasy");
        if(GetDifficultyLevel()==1)
            p_Enemy.LoadScript("single\\singleMedium");
        if(GetDifficultyLevel()==2)
            p_Enemy.LoadScript("single\\singleHard");
        
        p_Enemy.SetNeutral(p_Neutral);
        p_Neutral.SetNeutral(p_Enemy);
        
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        p_Enemy.EnableAIFeatures(aiControlDefense,false);
        p_Enemy.EnableAIFeatures(aiBuildBuildings,false);
        
        //----------- Money ------------------
        p_Player.SetMoney(0);
        if(GetDifficultyLevel()==0)
            p_Enemy.SetMoney(10000);
        if(GetDifficultyLevel()==1)
            p_Enemy.SetMoney(20000);
        if(GetDifficultyLevel()==2)
            p_Enemy.SetMoney(100000);
        p_Neutral.SetMoney(0);

        //----------- Researches -------------
        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        if(GetDifficultyLevel()==0)
        {
            KillArea(p_Enemy.GetIFF(), GetPointX(21), GetPointY(21), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(22), GetPointY(22), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(23), GetPointY(23), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(24), GetPointY(24), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(25), GetPointY(25), 0, 1);
        }
        if(GetDifficultyLevel()==1)
        {
            KillArea(p_Enemy.GetIFF(), GetPointX(22), GetPointY(22), 0, 1);
            KillArea(p_Enemy.GetIFF(), GetPointX(24), GetPointY(24), 0, 1);
        }
        //----------- Artefacts --------------
        start=0;
        end=0;
        if(GetDifficultyLevel()==1)
        {
            start=30;
            end=41;
        }
        if(GetDifficultyLevel()==2)
        {
            start=30;
            end=61;
        }
        for(i=start;i<end;i=i+1)
        {
            CreateArtefact("NEAMINE",GetPointX(i),GetPointY(i),GetPointZ(i),i,artefactSpecialAIOther);
        }
        
        //----------- Units ------------------
        p_Player.CreateUnitEx(GetPointX(0),GetPointY(0),  0,null,"EDUSPECIAL","EDWSPECIAL",null,null,null,0);                  
        u_Fiodorow = GetUnit(GetPointX(0),GetPointY(0),0);
        u_Fiodorow.SetUnitName("translate522Fiodorow");
        p_Player.AddUnitToSpecialTab(u_Fiodorow,true, -1);
        
        if(GetDifficultyLevel()==0)
        {
            end=9;
            nShield=0;
        }
        if(GetDifficultyLevel()==1)
        {
            end=6;
            nShield=-1;
        }
        if(GetDifficultyLevel()==2)
        {
            end=4;
            nShield=-1;
        }
        for (i=0;i<=end;i=i+1)
        {
            p_Player.CreateUnitEx(GetPointX(70+i),GetPointY(70+i), 0,null,"LCUUFO","LCWUFO",null,null,null,nShield);
            u_Fiodorow = GetUnit(GetPointX(70+i),GetPointY(70+i),0);
            if (i == 0) u_Fiodorow.SetUnitName("translate522Unit1");
            else if (i == 1) u_Fiodorow.SetUnitName("translate522Unit2");
            else if (i == 2) u_Fiodorow.SetUnitName("translate522Unit3");
            else if (i == 3) u_Fiodorow.SetUnitName("translate522Unit4");
            else if (i == 4) u_Fiodorow.SetUnitName("translate522Unit5");
            else if (i == 5) u_Fiodorow.SetUnitName("translate522Unit6");
            else if (i == 6) u_Fiodorow.SetUnitName("translate522Unit7");
            else if (i == 7) u_Fiodorow.SetUnitName("translate522Unit8");
            else if (i == 8) u_Fiodorow.SetUnitName("translate522Unit9");
            else if (i == 9) u_Fiodorow.SetUnitName("translate522Unit10");
            p_Player.AddUnitToSpecialTab(u_Fiodorow,true, -1);
        }
        u_Fiodorow = GetUnit(GetPointX(0),GetPointY(0),0);
                
        //----------- Timers -----------------
        SetTimer(0,100);
        //----------- Variables --------------
        bCheckEndMission = false;
        n_AnimationStep=0;
        //----------- Camera -----------------
        CallCamera();
        EnableInterface(false);
        EnableCameraMovement(false);
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,128,20,0);
        p_Player.DelayedLookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0,100,1);
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        int nIntensity;
        if(GetDifficultyLevel()==0)
            nIntensity = 1;
        else if(GetDifficultyLevel()==1)
            nIntensity = 2;
        else
            nIntensity = 3;
        MeteorRain(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),20,500,30000,100,nIntensity,1);
        EnableInterface(true);//zeby mozna bylo nacisnac OK w briefingu
        AddBriefing("translateBriefing522");
        n_AnimationStep=0;
        ShowArea(4,GetPointX(10),GetPointY(10),0,10,showAreaBuildings);//centrum sterowania SunLight
        return ShowBriefingAnimation,1;
    }
    //-----------------------------------------------------------------------------------------  
    state ShowBriefingAnimation
    {
        if(n_AnimationStep==0)
        {
            EnableInterface(false);
            p_Player.LookAt(GetPointX(10),GetPointY(10),10,128,20,0);
            p_Player.DelayedLookAt(GetPointX(10),GetPointY(10),10,0,20,0,100,1);
            n_AnimationStep=1;
            return ShowBriefingAnimation,101;
        }
        if(n_AnimationStep==1)
        {
            p_Player.DelayedLookAt(GetPointX(0),GetPointY(0),8,0,20,0,50,1);
            n_AnimationStep=2;
            return ShowBriefingAnimation,50;
        }
        if(n_AnimationStep==2)
        {
            n_AnimationStep=0;
            EnableInterface(true);
            EnableCameraMovement(true);
            return DestroySunLights;
        }
    }
        
    //-----------------------------------------------------------------------------------------  
    state DestroySunLights
    {
        if(u_Fiodorow.DistanceTo(GetPointX(1),GetPointY(1))<2 &&
            u_Fiodorow.GetLocationZ()==1)
        {
            SetGoalState(destroySunLight,goalAchieved);
            SetGoalState(fiodorowSurvived,goalAchieved);
            AddBriefing("translateAccomplished522");
            n_AnimationStep = 0;
            return ShowDestroy,1;
        }
        return DestroySunLights;
    }
    //-----------------------------------------------------------------------------------------  
    state ShowDestroy
    {
        int n_Time;
        n_Time=20;
        
        if(n_AnimationStep==0)//move to PP1
        { 
            TraceD("move to PP1\n");
            ShowArea(4,GetPointX(10),GetPointY(10),0,20,showAreaBuildings);//centrum sterowania SunLight
            EnableInterface(false);
            p_Player.LookAt(GetPointX(10),GetPointY(10),15,127,40,0);
            p_Player.DelayedLookAt(GetPointX(10),GetPointY(10),15,128,40,0,80,0);
            n_AnimationStep=2;
            return ShowDestroy,15;//n_Time
        }
        if(n_AnimationStep>1 && n_AnimationStep<6)//destroy PP1
        {
            TraceD("destroy PP1\n");
            KillArea(15,GetPointX(n_AnimationStep),GetPointY(n_AnimationStep),0,7);
            n_AnimationStep = n_AnimationStep+1;
            if(n_AnimationStep==6)
                return ShowDestroy,3;
            return ShowDestroy,20;
        }
        if(n_AnimationStep==6)//destroy everything
        {
            n_AnimationStep = 7;
            p_Player.DelayedLookAt(GetPointX(10),GetPointY(10),15,135,40,0,120,0);
            return ShowDestroy,15;
        }
        if(n_AnimationStep==7)//destroy everything
        { 
            TraceD("destroy everything\n");
            KillArea(15,GetPointX(10),GetPointY(10),0,15);
            n_AnimationStep = 8;
            return ShowDestroy,63;
        }
        if(n_AnimationStep==8)//destroy everything
        {
            n_AnimationStep = 9;
            p_Player.DelayedLookAt(GetPointX(10),GetPointY(10),15,140,40,0,120,0);
            return ShowDestroy,35;
        }
        if(n_AnimationStep==9)
        {
            EnableInterface(true);
            EnableNextMission(0,3);// Win
        }
        /*if(n_AnimationStep==0)//move to PP1
        { 
            TraceD("move to PP1\n");
            EnableInterface(false);
            p_Player.LookAt(GetPointX(10),GetPointY(10),10,0,20,0);
            p_Player.DelayedLookAt(GetPointX(2),GetPointY(2),10,0,20,0,n_Time,1);
            n_AnimationStep=2;
            return ShowDestroy,15;//n_Time
        }
        if(n_AnimationStep==2)//destroy PP1
        {
            EnableInterface(true);
            TraceD("destroy PP1\n");
            KillArea(15,GetPointX(2),GetPointY(2),0,7);
            n_AnimationStep = 3;
            EnableInterface(false);
            return ShowDestroy,20;
        }

        if(n_AnimationStep==3)//move to PP2
        {
            TraceD("move to PP2\n");
            n_AnimationStep = 4;
            p_Player.DelayedLookAt(GetPointX(3),GetPointY(3),10,0,20,0,n_Time,1);
            return ShowDestroy,15;
        }
        if(n_AnimationStep==4)//destroy PP2
        {
            TraceD("destroy PP2\n");
            KillArea(15,GetPointX(3),GetPointY(3),0,7);
            n_AnimationStep = 5;
            return ShowDestroy,20;
        }

        if(n_AnimationStep==5)//move to PP3
        {
            TraceD("move to PP3\n");
            n_AnimationStep = 6;
            p_Player.DelayedLookAt(GetPointX(4),GetPointY(4),10,0,20,0,n_Time,1);
            return ShowDestroy,15;
        }
        if(n_AnimationStep==6)//destroy PP3
        {
            TraceD("destroy PP3\n");
            KillArea(15,GetPointX(4),GetPointY(4),0,7);
            n_AnimationStep = 7;
            return ShowDestroy,20;
        }

        if(n_AnimationStep==7)//move to PP4
        {
            TraceD("move to PP4\n");
            n_AnimationStep = 8;
            p_Player.DelayedLookAt(GetPointX(5),GetPointY(5),10,0,20,0,n_Time,1);
            return ShowDestroy,15;
        }
        if(n_AnimationStep==8)//destroy PP4
        {
            TraceD("destroy PP4\n");
            KillArea(15,GetPointX(5),GetPointY(5),0,7);
            n_AnimationStep = 9;
            return ShowDestroy,15;
        }

        if(n_AnimationStep==9)//move to center
        {
            TraceD("move to center\n");
            p_Player.DelayedLookAt(GetPointX(10),GetPointY(10),30,0,20,0,n_Time,1);
            n_AnimationStep=10;
            return ShowDestroy,50;
        }
        if(n_AnimationStep==10)//destroy everything
        { TraceD("destroy everything\n");
            KillArea(15,GetPointX(10),GetPointY(10),0,15);
            n_AnimationStep = 11;
            return ShowDestroy,100;
        }

        if(n_AnimationStep==11)
        {
            EnableInterface(true);
            EnableNextMission(0,3);// Win
        }*/
        return Nothing;
        
    }
    //-----------------------------------------------------------------------------------------  
    state Nothing
    {
        return Nothing;
    }
    //-----------------------------------------------------------------------------------------  
    state EndGame
    {
        EnableNextMission(0,2);// loose
    }

    //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co 100 cykli< ustawione funkcja SetTimer w state Initialize
    {
      int nIntensity;
            ShowArea(4,GetPointX(10),GetPointY(10),0,8,showAreaBuildings);//centrum sterowania SunLight

            if(!b_Rain1 && p_Player.IsPointLocated(GetPointX(11),GetPointY(11),0))
            {
                b_Rain1=true;
                if(GetDifficultyLevel()==0)
                    nIntensity = 1;
                else if(GetDifficultyLevel()==1)
                    nIntensity = 2;
                else
                    nIntensity = 3;
                MeteorRain(GetPointX(11),GetPointY(11),20,500,30000,100,nIntensity,1);
            }
            if(!b_Rain2 &&p_Player.IsPointLocated(GetPointX(12),GetPointY(12),0))
            {
                b_Rain2=true;
                if(GetDifficultyLevel()==0)
                    nIntensity = 1;
                else if(GetDifficultyLevel()==1)
                    nIntensity = 2;
                else
                    nIntensity = 3;
                MeteorRain(GetPointX(12),GetPointY(12),20,500,30000,100,nIntensity,1);
            }
            if(!b_Rain3 &&p_Player.IsPointLocated(GetPointX(13),GetPointY(13),0))
            {
                b_Rain3=true;
                if(GetDifficultyLevel()==0)
                    nIntensity = 1;
                else if(GetDifficultyLevel()==1)
                    nIntensity = 2;
                else
                    nIntensity = 3;
                MeteorRain(GetPointX(13),GetPointY(13),20,500,30000,100,nIntensity,1);
            }

            if(!bCheckEndMission)return;

            bCheckEndMission=false;
                
            if(!u_Fiodorow.IsLive())
            {
                AddBriefing("translateFailed522");
                state EndGame;
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
    }
    //-----------------------------------------------------------------------------------------
    event EndMission() 
    {
    }
   //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;
        if(aID>29 && aID<=60)//mines
        {
            KillArea(15, GetPointX(aID),GetPointY(aID),GetPointZ(aID),0);
            return true; //usuwa sie 
        }
        return true; //usuwa sie 
    }
}
   