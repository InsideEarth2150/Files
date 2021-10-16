mission "translateMission412"
{

    consts
    {
        EscortVehicle = 0;
    }

    player p_TmpPlayer;
    player p_Enemy;
    player p_Neutral;
    player p_Player;


    unitex u_EscortedVehicle;

    int bCheckEndMission;
    int DestinationX;
    int DestinationY;
    int bStartRain1;
    int bStartRain2;
    int bStartRain3;
    int bStartRain4;
    
    unitex u_Grizzli1;
    unitex u_Grizzli2;

    state Initialize;
    state ShowBriefing;
    state ShowVideo;
    state Working;
    state MissionFailed;
    state MissionAccomplished;
    state Nothing;

    //----------------------------------------------------------------------------------------- 
    state Initialize
    {

        //----------- Goals ------------------
        RegisterGoal(EscortVehicle, "translateGoal412EscortVehicle");
        //---Show goals on list---
        EnableGoal(EscortVehicle, true);
        
        //----------- Players ----------------
        p_Player = GetPlayer(1);    //UCS
        p_Enemy = GetPlayer(3);     //LC

        p_TmpPlayer = GetPlayer(2);
        p_TmpPlayer.EnableStatistics(false);
        
        p_Neutral = GetPlayer(4);
        p_Neutral.EnableStatistics(false);
        
        
        //----------- AI ---------------------
        
        p_Enemy.LoadScript("single\\singleMedium");
        
        //wylacz inteligencje graczy
        p_Enemy.EnableAIFeatures(aiControlOffense,false);
        p_Enemy.EnableAIFeatures(aiControlDefense,false);
       
        p_Enemy.SetNeutral(p_Neutral);
        p_Player.SetNeutral(p_Neutral);
        
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_Neutral.SetMoney(0);
        p_Enemy.SetMoney(5000);

        p_Enemy.EnableResearch("RES_LC_WCH2",true);
        p_Enemy.EnableResearch("RES_LC_WSR2",true);
        p_Enemy.EnableResearch("RES_MSR2",true);
        p_Enemy.EnableResearch("RES_MCH3",true);      
        //----------- Variables --------------
        
        
        DestinationX=GetPointX(10);
        DestinationY=GetPointY(10);
        
        bCheckEndMission=false;

        //----units-------------------------------
        u_EscortedVehicle = GetUnit(GetPointX(0),GetPointY(0),0);
        p_Player.AddUnitToSpecialTab(u_EscortedVehicle,true, -1);
        u_Grizzli1 = GetUnit(GetPointX(1),GetPointY(1),GetPointZ(1));
        u_Grizzli2 = GetUnit(GetPointX(2),GetPointY(2),GetPointZ(2));
        u_Grizzli1.SetUnitName("translateGrizzli1");
        u_Grizzli2.SetUnitName("translateGrizzli2");
        p_Player.AddUnitToSpecialTab(u_Grizzli1,true, -1);
        p_Player.AddUnitToSpecialTab(u_Grizzli2,true, -1);

        p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
        p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
        p_Player.EnableBuilding("UCSCSD", false);   //Laser antyrakietowy

        bStartRain1=false;
        bStartRain2=false;
        bStartRain3=false;
        bStartRain4=false;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);
        return ShowVideo;
    }

    //-----------------------------------------------------------------------------------------
    state ShowVideo
    {
        ShowVideo("Cutscene19");
        return ShowBriefing,100;
    }   
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing412", p_Player.GetName());
        MeteorRain(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),20,100,30000,100,2,1);
        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {

        if(!bStartRain1 && p_Player.IsPointLocated(GetPointX(3),GetPointY(3),0))
        {
            bStartRain1=true;
            MeteorRain(GetPointX(3),GetPointY(3),10,400,10000,100,3,1);
        }
        if(!bStartRain2 && p_Player.IsPointLocated(GetPointX(4),GetPointY(4),0))
        {
            bStartRain2=true;
            MeteorRain(GetPointX(4),GetPointY(4),10,400,10000,100,3,1);
        }
        if(!bStartRain3 && p_Player.IsPointLocated(GetPointX(5),GetPointY(5),0))
        {
            bStartRain3=true;
            MeteorRain(GetPointX(5),GetPointY(5),10,400,10000,100,3,1);
        }
        if(!bStartRain4 && p_Player.IsPointLocated(GetPointX(6),GetPointY(6),0))
        {
            bStartRain4=true;
            MeteorRain(GetPointX(6),GetPointY(6),10,400,10000,100,3,1);
        }
        if(bCheckEndMission)
        {
            bCheckEndMission=false;

            if(!u_EscortedVehicle.IsLive())
            {
                SetGoalState(EscortVehicle, goalFailed);
                AddBriefing("translateFailed412", p_Player.GetName());
                return MissionFailed, 20;
            }
            if(!u_Grizzli1.IsLive())
            {
                    AddBriefing("translateGrizzli1Killed",p_Player.GetName());
                    return MissionFailed;
            }
            if(!u_Grizzli2.IsLive())
            {
                    AddBriefing("translateGrizzli2Killed",p_Player.GetName());
                    return MissionFailed;
            }

        }
        
        if(u_EscortedVehicle.DistanceTo(DestinationX, DestinationY) < 5)
        {
            SetGoalState(EscortVehicle, goalAchieved);
            AddBriefing("translateAccomplished412", p_Player.GetName());
            return MissionAccomplished, 20;
        }

        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state MissionFailed
    {
            EnableNextMission(0,2);
            return Nothing;
    }

    //-----------------------------------------------------------------------------------------
    state MissionAccomplished
    {
        EnableNextMission(0, true);
        EndMission(true);
        return Nothing;
    }

    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }

    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit u_Unit)
    {
        bCheckEndMission=true;
    }

}
