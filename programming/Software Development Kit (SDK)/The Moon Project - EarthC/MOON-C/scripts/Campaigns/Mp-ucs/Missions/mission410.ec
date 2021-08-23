mission "translateMission410"
{
    consts
    {
        bringGrizzli1 = 0;
        bringGrizzli2 = 1;
        harvest50000 = 2;
        DestroyLC = 3;
        DestroyED = 4;
    }

    player p_Enemy1;//ED
    player p_Enemy2;//LC
    player p_Player;
    player p_Ally1;//4
    player p_Ally2;//6
    
    unitex u_Grizzli1;
    unitex u_Grizzli2;
    unitex u_SpacePort;

    int bCheckEndMission;
    
    int i;
    
    state Initialize;
    state PlayTrackState;
    state ShowBriefing;
    state EnemyLocated;
    state Working;
    state Harvest;
    state EndMissionTrue;
    state EndMissionFailed;
    state Nothing;
        
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        
        //----------- Goals ------------------
        RegisterGoal(bringGrizzli1,"translateGoal410a");
        RegisterGoal(bringGrizzli2,"translateGoal410b");
        RegisterGoal(harvest50000, "translateGoal410c");                
        RegisterGoal(DestroyLC,    "translateGoal410d");//reward 25000
        RegisterGoal(DestroyED,    "translateGoal410e");//reward 25000

                //---show goals on list---
        EnableGoal(bringGrizzli1,true);
        EnableGoal(bringGrizzli2,true);
        EnableGoal(harvest50000,true);
        EnableGoal(DestroyLC,false);
        EnableGoal(DestroyED,false);

        
        //----------- Players ----------------
        p_Player = GetPlayer(1);    //ja czyli UCS
        p_Enemy1 = GetPlayer(2);    //ED
        p_Enemy2 = GetPlayer(3);    //LC
        p_Ally1 = GetPlayer(4); //gracz do przejecia
        p_Ally2 = GetPlayer(6); //gracz do przejecia
                
        //----------- AI ---------------------
        p_Enemy1.LoadScript("single\\singleMedium");
        p_Enemy2.LoadScript("single\\singleMedium");
        p_Ally1.LoadScript("single\\singleMedium");
        p_Ally2.LoadScript("single\\singleMedium");

        p_Ally1.EnableAIFeatures(aiRejectAlliance, false);
        p_Ally2.EnableAIFeatures(aiRejectAlliance, false);
        p_Player.SetAlly(p_Ally1);
        p_Player.SetAlly(p_Ally2);
        p_Ally1.SetAlly(p_Ally2);
        p_Ally1.SetEnemy(p_Enemy1);
        p_Ally2.SetEnemy(p_Enemy2);
        p_Ally1.EnableAIFeatures(aiControlOffense, false);
        p_Ally2.EnableAIFeatures(aiControlOffense, false);
        //--- Grizzlis ----------------
        u_Grizzli1 = GetUnit(GetPointX(1),GetPointY(1),GetPointZ(1));
        u_Grizzli2 = GetUnit(GetPointX(2),GetPointY(2),GetPointZ(2));

        u_Grizzli1.SetUnitName("translateGrizzli1");
        u_Grizzli2.SetUnitName("translateGrizzli2");

        p_Player.AddUnitToSpecialTab(u_Grizzli1,true, -1);
        p_Player.AddUnitToSpecialTab(u_Grizzli2,true, -1);

        u_SpacePort = GetUnit(GetPointX(0),GetPointY(0),0);


        /*CreateArtefact("NEACOMPUTER", GetPointX(1)+1, GetPointY(1), 1,0,artefactSpecialAIOther);
        CreateArtefact("NEASWITCH1",  GetPointX(1)+2, GetPointY(1), 1,0,artefactSpecialAIOther);
        CreateArtefact("NEASWITCH2",  GetPointX(1)+3, GetPointY(1), 1,0,artefactSpecialAIOther);
        CreateArtefact("NEAPLATE1",   GetPointX(2)+1, GetPointY(2), 1,0,artefactSpecialAIOther);
        CreateArtefact("NEAPLATE2",   GetPointX(2)+2, GetPointY(2), 1,0,artefactSpecialAIOther);
*/
        //----------- Variables --------------
        p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
        p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
        p_Player.EnableBuilding("UCSCSD", false);   //Laser antyrakietowy
        
        //----------- Money ------------------
        p_Enemy1.SetMoney(25000);
        p_Enemy2.SetMoney(25000);
        p_Ally1.SetMoney(25000);
        p_Ally2.SetMoney(25000);
        p_Player.SetMoney(20000);
    
        SetTimer(0, 100);

        //----------- Camera -----------------
        CallCamera();
        ShowArea(2,GetPointX(0),GetPointY(0)+10,0,10);
        ShowArea(2,GetPointX(0),GetPointY(0)+20,0,10);
        ShowArea(2,GetPointX(0),GetPointY(0)+30,0,10);
        ShowArea(2,GetPointX(0),GetPointY(0)+40,0,10);

        p_Player.LookAt(GetPointX(1), GetPointY(1), 6, 0, 20, 1);
        p_Player.DelayedLookAt(GetPointX(1),GetPointY(1),6,1,20,1,100,0);
        //p_Player.LookAt(GetPointX(0), GetPointY(0)+40, 6, 0, 20, 0);
        //p_Player.DelayedLookAt(GetPointX(0),GetPointY(0),6,0,20,0,90,1);
        return PlayTrackState,3;                
    }

    //-----------------------------------------------------------------------------------------
    state PlayTrackState
    {
        PlayTrack("music\\ucsday_3.mp2");
        return ShowBriefing,100;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateBriefing410a", p_Player.GetName());   //D:+name
        //p_Player.LookAt(GetPointX(1), GetPointY(1), 6, 0, 20, 1);
        //EnableEndMissionButton(true);//xxmd usunac
        return EnemyLocated,1200;//15s
    }

    //-----------------------------------------------------------------------------------------
    state EnemyLocated
    {
        ShowArea(2,GetPointX(3),GetPointY(3),0,6,showAreaBuildings);//centrum sterowania SunLight
        ShowArea(2,GetPointX(4),GetPointY(4),0,6,showAreaBuildings);//centrum sterowania SunLight
        //p_Player.LookAt(GetPointX(3), GetPointY(3), 6, 0, 20, 0);
        EnableGoal(DestroyLC,true);
        EnableGoal(DestroyED,true);
        AddBriefing("translateBriefing410b", p_Player.GetName());   //D:+name
        return Working;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {
        if(u_Grizzli1.DistanceTo(GetPointX(0),GetPointY(0))<3 &&
            u_Grizzli1.GetLocationZ()==1)
        {
            SetGoalState(bringGrizzli1,goalAchieved);
            u_Grizzli1.ChangePlayer(p_Ally1);
        }

        if(u_Grizzli2.DistanceTo(GetPointX(0),GetPointY(0))<3 &&
            u_Grizzli2.GetLocationZ()==1)
        {
            SetGoalState(bringGrizzli2,goalAchieved);
            u_Grizzli2.ChangePlayer(p_Ally1);
        }


        if(p_Player.GetMoney()>=50000)
            SetGoalState(harvest50000,goalAchieved);
        else
            SetGoalState(harvest50000,goalNotAchieved);

        if(GetGoalState(bringGrizzli1)==goalAchieved &&
            GetGoalState(bringGrizzli2)==goalAchieved)
        {
            if(p_Player.GetMoney()>=50000)
            {
                SetGoalState(harvest50000,goalAchieved);
                AddBriefing("translateAccomplished410",p_Player.GetName());//doprowadziles grizzlich i uzbiera³es forse
                p_Player.SetMoney(p_Player.GetMoney()-50000);
                return EndMissionTrue;
            }
            else
            {
                AddBriefing("translateBriefing410c",p_Player.GetName());    //uznieraj forse
                return Harvest;
            }
        }
        
        return Working;
    }
    //-----------------------------------------------------------------------------------------
    state Harvest
    {
        if(p_Player.GetMoney()>=50000)
        {
            SetGoalState(harvest50000,goalAchieved);
            AddBriefing("translateAccomplished410",p_Player.GetName());//uzbiera³eœ forse.
            p_Player.SetMoney(p_Player.GetMoney()-50000);
            return EndMissionTrue;
        }
    return Harvest;
    }

        //-----------------------------------------------------------------------------------------
        state EndMissionFailed
        {
            EnableNextMission(0,2);
            return Nothing;
        }
        //-----------------------------------------------------------------------------------------
        state EndMissionTrue
        {
            EndMission(true);
            return Nothing;
        }


    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------

    event Timer0()
    {
        if(!bCheckEndMission)return;
        bCheckEndMission=false;

        if(p_Enemy2.GetNumberOfBuildings()<4)
        {
            p_Enemy2.EnableAIFeatures(aiEnabled, false);
        }
        if(!u_Grizzli1.IsLive())
        {
          AddBriefing("translateGrizzli1Killed",p_Player.GetName());
          state EndMissionFailed;
        }
            if(!u_Grizzli2.IsLive())
        {
          AddBriefing("translateGrizzli2Killed",p_Player.GetName());
          state EndMissionFailed;
        }
        if(!u_SpacePort.IsLive())
        {
            AddBriefing("translateFailed410", p_Player.GetName());
            state EndMissionFailed;
        }
        
        if(GetGoalState(DestroyLC)!=goalAchieved && !p_Enemy2.GetNumberOfBuildings())
        {
            SetGoalState(DestroyLC, goalAchieved);
            p_Enemy2.EnableAIFeatures(aiEnabled, false);
            AddBriefing("translateBriefing410d", p_Player.GetName());
            p_Player.AddMoney(25000);
        }
        if(GetGoalState(DestroyED)!=goalAchieved && !p_Enemy1.GetNumberOfBuildings())
        {
            SetGoalState(DestroyED, goalAchieved);
            AddBriefing("translateBriefing410e", p_Player.GetName());
            p_Player.AddMoney(25000);
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
}
