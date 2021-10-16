//cel misji - zniszczyc 4 controll centery i 4 elektrownie
//kazdy cc jest niesmiertelny tal dlugo jak zasilajaca go elektrownia jest niesmiertelna.
//Elektrownie mozna zniszczyæ przez zebranie artefaktu self dest
// 

mission "translateMission420"
{
    consts
    {
        scriptFieldGoal1=0;
        scriptFieldGoal2=1;
        scriptFieldGoal3=2;
        scriptFieldGoal4=3;
        scriptFieldGoal5=4;
        scriptFieldGoal6=5;
        scriptFieldMoney=9;
        scriptFieldMeteors=10;

        goalDeactivePP1 = 0;
        goalDeactivePP2 = 1;
        goalDeactivePP3 = 2;
        goalDeactivePP4 = 3;
        goalDestroyControlCenter1 = 4;
        goalDestroyControlCenter2 = 5;
        goalDestroyControlCenter3 = 6;
        goalDestroyControlCenter4 = 7;

    }

    player p_Enemy1;//3
    player p_Enemy2;//4
    player p_Enemy3;//5
    player p_Enemy4;//6 -w tunelach
    player p_Neutral;//7
    player p_Player;

    int bCheckEndMission;

    unitex uCC1;
    unitex uCC2;
    unitex uCC3;
    unitex uCC4;
    unitex uPP1;
    unitex uPP2;
    unitex uPP3;
    unitex uPP4;

    int bPP1active;
    int bPP2active;
    int bPP3active;
    int bPP4active;


    state Initialize;
    state ShowBriefing;
    state Working;
    state EndMissionFailed;
    state Victory;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        //----------- Goals ------------------
        RegisterGoal(goalDestroyControlCenter1, "translateGoal420a");
        RegisterGoal(goalDestroyControlCenter2, "translateGoal420b");
        RegisterGoal(goalDestroyControlCenter3, "translateGoal420c");
        RegisterGoal(goalDestroyControlCenter4, "translateGoal420d");

        RegisterGoal(goalDeactivePP1, "translateGoal420e");
        RegisterGoal(goalDeactivePP2, "translateGoal420f");
        RegisterGoal(goalDeactivePP3, "translateGoal420g");
        RegisterGoal(goalDeactivePP4, "translateGoal420h");

        EnableGoal(goalDestroyControlCenter1,true);
        EnableGoal(goalDestroyControlCenter2,true);
        EnableGoal(goalDestroyControlCenter3,true);
        EnableGoal(goalDestroyControlCenter4,true);
        
        //----------- Players ----------------
        p_Player = GetPlayer(1);    //ja czyli UCS
        p_Enemy1 = GetPlayer(3);    //LC
        p_Enemy2 = GetPlayer(4);    //LC
        p_Enemy3 = GetPlayer(5);    //LC
        p_Enemy4 = GetPlayer(6);    //LC
        
        p_Neutral = GetPlayer(7);
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        p_Neutral.EnableStatistics(false);
        
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
            p_Enemy3.LoadScript("single\\singleEasy");
            p_Enemy4.LoadScript("single\\singleEasy");
        }

        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
            p_Enemy3.LoadScript("single\\singleMedium");
            p_Enemy4.LoadScript("single\\singleMedium");
        }

        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
            p_Enemy3.LoadScript("single\\singleHard");
            p_Enemy4.LoadScript("single\\singleHard");
        }
        
        //----------- Money ------------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        p_Player.SetMoney(30000);
        p_Player.SetMilitaryUnitsLimit(70000);

        p_Enemy1.SetMoney(10000);
        p_Enemy2.SetMoney(10000);
        p_Enemy3.SetMoney(10000);
        p_Enemy4.SetMoney(10000);

        p_Player.SetNeutral(p_Neutral);
        p_Enemy1.SetNeutral(p_Neutral);
        p_Enemy2.SetNeutral(p_Neutral);
        p_Enemy3.SetNeutral(p_Neutral);
        p_Enemy4.SetNeutral(p_Neutral);
        
        p_Enemy1.SetAlly(p_Enemy2);
        p_Enemy1.SetAlly(p_Enemy3);
        p_Enemy1.SetAlly(p_Enemy4);
        p_Enemy2.SetAlly(p_Enemy3);
        p_Enemy2.SetAlly(p_Enemy4);
        p_Enemy3.SetAlly(p_Enemy4);
        
        
        p_Enemy2.CopyResearches(p_Enemy1);
        p_Enemy3.CopyResearches(p_Enemy1);
        p_Enemy4.CopyResearches(p_Enemy1);
        p_Enemy1.EnableBuilding("LCCSD", false);    //Laser antyrakietowy
        p_Enemy2.EnableBuilding("LCCSD", false);    //Laser antyrakietowy
        p_Enemy3.EnableBuilding("LCCSD", false);    //Laser antyrakietowy
        p_Enemy4.EnableBuilding("LCCSD", false);    //Laser antyrakietowy


        p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
        p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
        p_Player.EnableBuilding("UCSCSD", false);   //Laser antyrakietowy

        //----------- Timers -----------------
        SetTimer(0, 1);
        //----------- Variables -----------------
        bPP1active=true;
        bPP2active=true;
        bPP3active=true;
        bPP4active=true;

        //----------- Units -----------------
        uCC1 = GetUnit(GetPointX(1), GetPointY(1),0);
        uCC2 = GetUnit(GetPointX(2), GetPointY(2),0);
        uCC3 = GetUnit(GetPointX(3), GetPointY(3),0);
        uCC4 = GetUnit(GetPointX(4), GetPointY(4),0);
        
        uPP1 = GetUnit(GetPointX(5), GetPointY(5),0);
        uPP2 = GetUnit(GetPointX(6), GetPointY(6),0);
        uPP3 = GetUnit(GetPointX(7), GetPointY(7),0);
        uPP4 = GetUnit(GetPointX(8), GetPointY(8),0);
        //----------- Artifacts --------------
        CreateArtefact("NEAPLATE1", GetPointX(9),  GetPointY(9),   GetPointZ(9),  9,artefactSpecialAIOther);
        CreateArtefact("NEAPLATE1", GetPointX(10), GetPointY(10),  GetPointZ(10),10,artefactSpecialAIOther);
        CreateArtefact("NEAPLATE1", GetPointX(11), GetPointY(11),  GetPointZ(11),11,artefactSpecialAIOther);
        CreateArtefact("NEAPLATE1", GetPointX(12), GetPointY(12),  GetPointZ(12),12,artefactSpecialAIOther);
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(), 6, 0, 20, 0);
        return ShowBriefing;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
            //show mission briefing
            AddBriefing("translateBriefing420a", p_Player.GetName());
            return Working;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {
        if(!bCheckEndMission) return Working;
        bCheckEndMission=false;

        if(!p_Player.GetNumberOfUnits()&&!p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateFailed420", p_Player.GetName());
            return EndMissionFailed;
        }
        
        if(GetGoalState(goalDestroyControlCenter1)!=goalAchieved && !uCC1.IsLive())
        {
            SetGoalState(goalDestroyControlCenter1,goalAchieved);
        }
        if(GetGoalState(goalDestroyControlCenter2)!=goalAchieved && !uCC2.IsLive())
        {
            SetGoalState(goalDestroyControlCenter2,goalAchieved);
        }
        if(GetGoalState(goalDestroyControlCenter3)!=goalAchieved && !uCC3.IsLive())
        {
            SetGoalState(goalDestroyControlCenter3,goalAchieved);
        }
        if(GetGoalState(goalDestroyControlCenter4)!=goalAchieved && !uCC4.IsLive())
        {
            SetGoalState(goalDestroyControlCenter4,goalAchieved);
        }
        
        if(GetGoalState(goalDestroyControlCenter1)==goalAchieved &&
            GetGoalState(goalDestroyControlCenter2)==goalAchieved &&
            GetGoalState(goalDestroyControlCenter3)==goalAchieved &&
            GetGoalState(goalDestroyControlCenter4)==goalAchieved)
        {
            p_Player.SetScriptData(scriptFieldGoal2, 2);
            AddBriefing("translateAccomplished420", p_Player.GetName());
            return Victory;
        }
        return Working;
    }

    //-----------------------------------------------------------------------------------------
    state EndMissionFailed
    {
        EnableNextMission(0,2);
        return Nothing;
    }

    //-----------------------------------------------------------------------------------------
    state Victory
    {
      EnableNextMission(0,3);
      return Victory, 500;
    }           
                    
    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------

    event Timer0() //wolany co minute
    {
        //regeneration of HPs
        if(uPP1.IsLive())
        {
            if(bPP1active) uPP1.RegenerateHP();
            uCC1.RegenerateHP();
        }
        if(uPP2.IsLive())
        {
            if(bPP2active) uPP2.RegenerateHP();
            uCC2.RegenerateHP();
        }
        if(uPP3.IsLive())
        {
            if(bPP3active) uPP3.RegenerateHP();
            uCC3.RegenerateHP();
        }
        if(uPP4.IsLive())
        {
            if(bPP4active) uPP4.RegenerateHP();
            uCC4.RegenerateHP();
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
    //---------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!= p_Player) return false;
        if(aID>12)return false;
        if(aID==9)
        {
            bPP1active=false; 
            CreateArtefact("NEAPLATE1", GetPointX(aID),  GetPointY(aID),   GetPointZ(aID), aID+10,artefactSpecialAIOther);
            SetGoalState(goalDeactivePP1,goalAchieved);
            AddBriefing("translateBriefing420b",p_Player.GetName());
        }
        if(aID==10)
        {
            bPP2active=false; 
            CreateArtefact("NEAPLATE1", GetPointX(aID),  GetPointY(aID),   GetPointZ(aID), aID+10,artefactSpecialAIOther);
            SetGoalState(goalDeactivePP2,goalAchieved);
            AddBriefing("translateBriefing420c",p_Player.GetName());
        }
        if(aID==11)
        {
            bPP3active=false; 
            CreateArtefact("NEAPLATE1", GetPointX(aID),  GetPointY(aID),   GetPointZ(aID), aID+10,artefactSpecialAIOther);
            SetGoalState(goalDeactivePP3,goalAchieved);
            AddBriefing("translateBriefing420d",p_Player.GetName());
        }
        if(aID==12)
        {
            bPP4active=false; 
            CreateArtefact("NEAPLATE1", GetPointX(aID),  GetPointY(aID),   GetPointZ(aID), aID+10,artefactSpecialAIOther);
            SetGoalState(goalDeactivePP4,goalAchieved);
            AddBriefing("translateBriefing420e",p_Player.GetName());
        }
        
        return true; //usuwa sie
    }

}
