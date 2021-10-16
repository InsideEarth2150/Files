mission "translateMission616"
{

    consts
    {
        scriptFieldMoney=9;
        goalEscortConvoy = 0;
        goalFangHaveToSurvived = 1;
    }

    player p_Player;
    player p_Enemy;
    
    
    unitex uFang;
    unitex p_ConvoyCraft1;
    unitex p_ConvoyCraft2;
    unitex p_ConvoyCraft3;
    unitex p_ConvoyCraft4;
    unitex p_ConvoyCraft5;
    unitex p_ConvoyCraft6;
    

    int bCheckEndMission;
    int nDestX;
    int nDestY;
    

    state Initialize;
    state ShowBriefing;
    state Working;
    state MissionFailed;
    state MissionAccomplished;
    state Nothing;

    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        int i;
        //----------- Goals ------------------

        if(GetDifficultyLevel()==0)
            RegisterGoal(goalEscortConvoy,"translateGoal616a",2);
        if(GetDifficultyLevel()==1)
            RegisterGoal(goalEscortConvoy,"translateGoal616a",4);
        if(GetDifficultyLevel()==2)
            RegisterGoal(goalEscortConvoy,"translateGoal616a",6);

        RegisterGoal(goalFangHaveToSurvived,"translateGoal616b");

        //---Show goals on list---
        EnableGoal(goalEscortConvoy, true);
        EnableGoal(goalFangHaveToSurvived, true);
        
        //----------- Players ----------------
        p_Player = GetPlayer(3);    //LC
        p_Enemy = GetPlayer(1);     //UCS

        //----------- AI ---------------------
        //wylacz inteligencje graczy
        p_Enemy.EnableAIFeatures(aiEnabled, false);
        
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_Enemy.SetMoney(0);
        
        //----------- Variables --------------
        uFang = GetUnit(GetPointX(30), GetPointY(30), 0);
        p_ConvoyCraft1 = GetUnit(GetPointX(31),GetPointY(31),0);
        p_ConvoyCraft2 = GetUnit(GetPointX(32),GetPointY(32),0);
        p_ConvoyCraft3 = GetUnit(GetPointX(33),GetPointY(33),0);
        p_ConvoyCraft4 = GetUnit(GetPointX(34),GetPointY(34),0);
        p_ConvoyCraft5 = GetUnit(GetPointX(35),GetPointY(35),0);
        p_ConvoyCraft6 = GetUnit(GetPointX(36),GetPointY(36),0);
        p_Player.AddUnitToSpecialTab(uFang,true, -1);
        p_Player.AddUnitToSpecialTab(p_ConvoyCraft1,true, -1);
        p_Player.AddUnitToSpecialTab(p_ConvoyCraft2,true, -1);
        p_Player.AddUnitToSpecialTab(p_ConvoyCraft3,true, -1);
        p_Player.AddUnitToSpecialTab(p_ConvoyCraft4,true, -1);
        p_Player.AddUnitToSpecialTab(p_ConvoyCraft5,true, -1);
        p_Player.AddUnitToSpecialTab(p_ConvoyCraft6,true, -1);
        
        nDestX=GetPointX(13);
        nDestY=GetPointY(13);
        
        bCheckEndMission=false;

        //----------- Artefacts --------------
        for(i=20;i<=27;i=i+1)
        {
            CreateArtefact("NEAMINE",GetPointX(i),GetPointY(i),GetPointZ(i),i,artefactSpecialAIOther);
        }

        //---- Creating additional units -----
        if(GetDifficultyLevel()==0)
        {
            p_Player.CreateUnitEx(GetPointX(0), GetPointY(0), 0, null, "LCUCR3", "LCWHL2", "LCWSL2", null, null,1); // Crater m3 + E + E
            p_Player.CreateUnitEx(GetPointX(1), GetPointY(1), 0, null, "LCUCR3", "LCWHL2", "LCWSL2", null, null,1); // Crater m3 + E + E
            p_Player.CreateUnitEx(GetPointX(2), GetPointY(2), 0, null, "LCUCU3", "LCWMR3", "LCWMR3", null, null,1); // Crusher m3 + R + R
        }
        if(GetDifficultyLevel()==1)
        {
            p_Player.CreateUnitEx(GetPointX(0), GetPointY(0), 0, null, "LCUCR3", "LCWHL2", "LCWSL2", null, null); // Crater m3 + E + E

            p_Enemy.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(4), GetPointY(4), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(5), GetPointY(5), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(6), GetPointY(6), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(7), GetPointY(7), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(8), GetPointY(8), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(9), GetPointY(9), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(10), GetPointY(10), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(11), GetPointY(11), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(12), GetPointY(12), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
        }
        if(GetDifficultyLevel()==2)
        {
            p_Enemy.CreateUnitEx(GetPointX(3), GetPointY(3), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(4), GetPointY(4), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(5), GetPointY(5), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(6), GetPointY(6), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(7), GetPointY(7), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(8), GetPointY(8), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(9), GetPointY(9), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(10), GetPointY(10), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(11), GetPointY(11), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P
            p_Enemy.CreateUnitEx(GetPointX(12), GetPointY(12), 0, null, "UCSUML1", "UCSWSSP1", null, null, null); // Spider + P

            p_Enemy.CreateUnitEx(GetPointX(3) + 1, GetPointY(3), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(4) + 1, GetPointY(4), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(5) + 1, GetPointY(5), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(6) + 1, GetPointY(6), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(7) + 1, GetPointY(7), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(8) + 1, GetPointY(8), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(9) + 1, GetPointY(9), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(10) + 1, GetPointY(10), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(11) + 1, GetPointY(11), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
            p_Enemy.CreateUnitEx(GetPointX(12) + 1, GetPointY(12), 0, null, "UCSUML1", "UCSWSMR1", null, null, null); // Spider + hR
        }
        //----------- Buildings --------------
        p_Player.EnableCommand(commandSoldBuilding,false);
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
        p_Player.EnableBuilding("LCBNE",false);
        p_Player.EnableBuilding("LCBDE",false);
        p_Player.EnableBuilding("LCBHQ",false);
        p_Player.EnableBuilding("LCBART",false);
        p_Player.EnableBuilding("LCBUC",false);
        p_Player.EnableBuilding("LCBSD",false);
        p_Player.EnableBuilding("LCBWC",false);
        p_Player.EnableBuilding("LCBSS",false);
        p_Player.EnableBuilding("LCBLZ",false);
        p_Player.EnableBuilding("LCBEN1",false);
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        return ShowBriefing, 100;
    }

    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        if(GetDifficultyLevel()==0)
            AddBriefing("translateBriefing616", p_Player.GetName(),2);
        if(GetDifficultyLevel()==1)
            AddBriefing("translateBriefing616", p_Player.GetName(),4);
        if(GetDifficultyLevel()==2)
            AddBriefing("translateBriefing616", p_Player.GetName(),6);
        return Working, 100;
    }

    //-----------------------------------------------------------------------------------------
    state Working
    {
        int nTrucksAlive;
        int nTrucksFinished;

        nTrucksAlive=0;
    
        if(p_ConvoyCraft1.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft2.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft3.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft4.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft5.IsLive())nTrucksAlive=nTrucksAlive+1;
        if(p_ConvoyCraft6.IsLive())nTrucksAlive=nTrucksAlive+1;

        if(bCheckEndMission)
        {
            bCheckEndMission=false;

            if(!uFang.IsLive())
            {
                SetGoalState(goalFangHaveToSurvived, goalFailed);
                AddBriefing("translateFailed616a", p_Player.GetName());
                return MissionFailed, 20;
            }
            if((nTrucksAlive<6 && GetDifficultyLevel()==2)||
                (nTrucksAlive<4 && GetDifficultyLevel()==1)||
                (nTrucksAlive<2 && GetDifficultyLevel()==0))
            {
                SetGoalState(goalEscortConvoy,goalFailed);
                AddBriefing("translateFailed616b", p_Player.GetName());
                return MissionFailed, 20;
            }
        }
        
        

        nTrucksFinished=0;
        
        if(p_ConvoyCraft1.IsLive() 
            && p_ConvoyCraft1.DistanceTo(nDestX,nDestY) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft2.IsLive() && p_ConvoyCraft2.DistanceTo(nDestX,nDestY) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft3.IsLive() && p_ConvoyCraft3.DistanceTo(nDestX,nDestY) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft4.IsLive() && p_ConvoyCraft4.DistanceTo(nDestX,nDestY) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft5.IsLive() && p_ConvoyCraft5.DistanceTo(nDestX,nDestY) < 7)nTrucksFinished=nTrucksFinished+1;
        if(p_ConvoyCraft6.IsLive() && p_ConvoyCraft6.DistanceTo(nDestX,nDestY) < 7)nTrucksFinished=nTrucksFinished+1;

        if(
             nTrucksAlive==nTrucksFinished &&(
             ((GetDifficultyLevel()==0 && nTrucksFinished>1)||
             ((GetDifficultyLevel()==1)&& nTrucksFinished>3)||
             ((GetDifficultyLevel()==2)&& nTrucksFinished>5))))
        {
            SetGoalState(goalEscortConvoy, goalAchieved);
            p_Player.EnableResearch("RES_LCUNH",true);//616
            p_Player.AddResearch("RES_LCUNH");//616
            SetGoalState(goalFangHaveToSurvived, goalAchieved);
            AddBriefing("translateAccomplished616",p_Player.GetName());
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
        EnableEndMissionButton(true);
        return Nothing;
    }

    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        if(!uFang.IsLive())
        {
            SetGoalState(goalFangHaveToSurvived, goalFailed);
            AddBriefing("translateFailed616a", p_Player.GetName());
            return MissionFailed, 20;
        }
        return Nothing, 100;
    }

    //-----------------------------------------------------------------------------------------
    event UnitDestroyed(unit u_Unit)
    {
        bCheckEndMission=true;
    }
    //-----------------------------------------------------------------------------------------
    event Artefact(int aID,player piPlayer)
    {
        if(piPlayer!=p_Player) return false;

        KillArea(255, GetPointX(aID),GetPointY(aID),GetPointZ(aID),1);
        return true; //nie usuwa sie 
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

}
