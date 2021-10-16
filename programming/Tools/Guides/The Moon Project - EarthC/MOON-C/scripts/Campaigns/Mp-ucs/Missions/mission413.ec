mission "translateMission413"
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
    
        DestroyALPHA = 0;
    }

    player p_Enemy1;
    player p_Enemy2;
    player p_Enemy3;
    player p_Player;
    player p_Neutral;

    int DestroyALPHA1Achieved;
    int DestroyALPHA2Achieved;

    int MinStateOfBuildings1;
    int CurrentStateOfBuildings1;

    int MinStateOfBuildings2;
    int CurrentStateOfBuildings2;
    int ShowBriefingB;
    int i;

    int bStartRain1;
    int bStartRain2;
    int bStartRain3;
    int bStartRain4;

    int nTimer0Counter;
    int nTimer1Counter;
    int nOffensePlayerNumber;
    player p_OffensePlayer;

    
    state Initialize;
    state ShowVideo;
    state ShowBriefing;
    state Working;
    state EndMissionFailed;
    state Nothing;
    //----------------------------------------------------------------------------------------- 
    state Initialize
    {
        DestroyALPHA1Achieved = false;
        DestroyALPHA2Achieved = false;

        //----------- Timers -----------------
        SetTimer(0, 1200);
        SetTimer(1, 20);
        SetTimer(2, 20);

        //----------- Variables --------------

        //----------- Goals ------------------
        RegisterGoal(DestroyALPHA, "translateGoalDestroyBaseALPHA");
        EnableGoal(DestroyALPHA,true);

        //----------- Players ----------------
        p_Player = GetPlayer(1);    //ja czyli UCS
        p_Enemy1 = GetPlayer(3);    //LC
        p_Enemy2 = GetPlayer(4);    //LC
        p_Enemy3 = GetPlayer(6);    //LC
        p_Neutral = GetPlayer(5);   //UCS

        p_Neutral.EnableStatistics(false);
        p_Enemy3.EnableStatistics(false);
        //----------- AI ---------------------
        if(GetDifficultyLevel()==0)
        {
            p_Enemy1.LoadScript("single\\singleEasy");
            p_Enemy2.LoadScript("single\\singleEasy");
        }

        if(GetDifficultyLevel()==1)
        {
            p_Enemy1.LoadScript("single\\singleMedium");
            p_Enemy2.LoadScript("single\\singleMedium");
        }

        if(GetDifficultyLevel()==2)
        {
            p_Enemy1.LoadScript("single\\singleHard");
            p_Enemy2.LoadScript("single\\singleHard");
        }

        p_Enemy1.EnableAIFeatures(aiRush,false);
        p_Enemy2.EnableAIFeatures(aiRush,false);

        //----AI off-------------
        
        p_Enemy3.EnableAIFeatures(aiEnabled,false);
        p_Enemy3.SetAlly(p_Enemy2);
        p_Enemy3.SetAlly(p_Enemy1);
        
        p_Neutral.EnableAIFeatures(aiEnabled,false);
        p_Neutral.SetAlly(p_Enemy2);
        p_Neutral.SetAlly(p_Enemy1);
        p_Neutral.SetNeutral(p_Player);
        p_Player.SetNeutral(p_Neutral);
        //----------- Money ------------------
        p_Player.EnableCommand(commandSoldBuilding,true);
        p_Player.SetMoney(10000);
        p_Enemy1.SetMoney(10000);
        p_Enemy2.SetMoney(10000);
        p_Player.SetMilitaryUnitsLimit(30000);

        p_Player.AddResearch("RES_MISSION_PACK1_ONLY");
        p_Player.EnableResearch("RES_UCS_USL2",true);
        p_Player.EnableResearch("RES_UCS_GARG1", true);
        p_Player.EnableResearch("RES_UCS_WCH2", true);
        p_Player.EnableResearch("RES_UCS_WSP1", true);
        p_Player.EnableResearch("RES_UCS_WSR1", true);
        p_Player.EnableResearch("RES_UCS_WSG2", true);
        p_Player.EnableResearch("RES_MCH2", true);
        p_Player.EnableResearch("RES_MSR2", true);
        p_Player.EnableResearch("RES_UCS_MG2", true);
        p_Player.EnableResearch("RES_UCS_RepHand", true);
        p_Player.EnableResearch("RES_UCS_SGen", true);
        p_Player.AddResearch("RES_UCSUCS"); //Cargo Salamander

        p_Enemy1.AddResearch("RES_MISSION_PACK1_ONLY");
        p_Enemy1.EnableResearch("RES_LC_UME1",true);
        p_Enemy1.EnableResearch("RES_LC_ULU2",true);
        p_Enemy1.EnableResearch("RES_LC_UMO2",true);
        p_Enemy1.EnableResearch("RES_LC_ACH2",true);
        p_Enemy1.EnableResearch("RES_LC_ASR1",true);
        p_Enemy1.EnableResearch("RES_LC_WSL1",true);
        p_Enemy1.EnableResearch("RES_MSR2",true);

        p_Enemy2.CopyResearches(p_Enemy1);
        //-----Easy------------
        if(GetDifficultyLevel()==0)
        {
            //kill needless buildings
            KillArea(p_Enemy1.GetIFF(), GetPointX(0), GetPointY(0), 0, 2);
            KillArea(p_Enemy1.GetIFF(), GetPointX(1), GetPointY(1), 0, 2);

            KillArea(p_Enemy2.GetIFF(), GetPointX(2), GetPointY(2), 0, 2);
            KillArea(p_Enemy2.GetIFF(), GetPointX(3), GetPointY(3), 0, 2);                  
        }

        //-----Normal----------
        if(GetDifficultyLevel()==1)
        {
            //kill needless buildings
            KillArea(p_Enemy1.GetIFF(), GetPointX(0), GetPointY(0), 0, 2);
            KillArea(p_Enemy2.GetIFF(), GetPointX(2), GetPointY(2), 0, 2);

            for(i=4; i<=8; i=i+1)
            {
                p_Enemy3.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCUMO3","LCWSL2",null,null,null);                 
                p_Enemy3.CreateUnitEx(GetPointX(i)+1, GetPointY(i), 0,null,"LCUMO3","LCWSR2",null,null,null);                   
            }
        }

        //-----Hard----------
        if(GetDifficultyLevel()==2)
        {
            for(i=4; i<=13; i=i+1)
            {
                p_Enemy3.CreateUnitEx(GetPointX(i), GetPointY(i), 0,null,"LCUCU3","LCWMR3","LCWHL2",null,null,1);
                p_Enemy3.CreateUnitEx(GetPointX(i)+1, GetPointY(i), 0,null,"LCUCU3","LCWMR3","LCWHL2",null,null,1);
            }
        }

        p_Enemy1.SetAlly(p_Enemy2);

        p_Enemy1.EnableBuilding("LCCSD", false);    //Laser antyrakietowy
        p_Enemy2.EnableBuilding("LCCSD", false);    //Laser antyrakietowy

        p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
        p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
        p_Player.EnableBuilding("UCSCSD", false);   //Laser antyrakietowy

        MinStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings()/5;
        MinStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings()/5;
        bStartRain1=false;
        bStartRain2=false;
        bStartRain3=false;
        bStartRain4=false;
        ShowBriefingB=true;
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(), 8, 0, 45, 0);
        return ShowVideo;
    }

    //-----------------------------------------------------------------------------------------
    state ShowVideo
    {
        ShowVideo("Cutscene4");
        return ShowBriefing,100;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
            //check campaign goal 0
            p_Player.SetScriptData(scriptFieldGoal1, 2);

            //show campaign goal 1
            p_Player.SetScriptData(scriptFieldGoal2, 1);
            p_Player.SetScriptData(scriptFieldGoal3, 1);

            //show mission briefing
            AddBriefing("translateBriefing413a", p_Player.GetName());   //D+
            ShowArea(2,GetPointX(36),GetPointY(36),0,4,showAreaBuildings);//
            return Working;
    }

        //-----------------------------------------------------------------------------------------
        state Working
        {
            if(!bStartRain1 && p_Player.IsPointLocated(GetPointX(4),GetPointY(4),0))
            {
                bStartRain1=true;
                MeteorRain(GetPointX(4),GetPointY(4),10,400,10000,100,3,1);
            }
            if(!bStartRain2 && p_Player.IsPointLocated(GetPointX(5),GetPointY(5),0))
            {
                bStartRain2=true;
                MeteorRain(GetPointX(5),GetPointY(5),10,400,10000,100,3,1);
            }
            if(!bStartRain3 && p_Player.IsPointLocated(GetPointX(8),GetPointY(8),0))
            {
                bStartRain3=true;
                MeteorRain(GetPointX(8),GetPointY(8),10,400,10000,100,3,1);
            }
            if(!bStartRain4 && p_Player.IsPointLocated(GetPointX(13),GetPointY(13),0))
            {
                bStartRain4=true;
                MeteorRain(GetPointX(13),GetPointY(13),10,400,10000,100,3,1);
            }
            if(!p_Player.GetNumberOfUnits())
            {
                AddBriefing("translateFailed413", p_Player.GetName());
                return EndMissionFailed;
            }

            //--------- check goals --------------------------------

            //----capture LC base---

            if(!DestroyALPHA1Achieved)
            {
                CurrentStateOfBuildings1 = p_Enemy1.GetNumberOfBuildings();
                if(CurrentStateOfBuildings1 <= MinStateOfBuildings1)
                {
                    p_Enemy1.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy1.SetMoney(0);

                    if(!CurrentStateOfBuildings1)
                    {
                        DestroyALPHA1Achieved = true;
                        MeteorRain(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),20,500,100,500,2,1);
                    }
                }
            }

            if(!DestroyALPHA2Achieved)
            {
                CurrentStateOfBuildings2 = p_Enemy2.GetNumberOfBuildings();
                if(CurrentStateOfBuildings2 <= MinStateOfBuildings2)
                {
                    p_Enemy2.EnableAIFeatures(aiBuildBuildings,false);
                    p_Enemy2.SetMoney(0);

                    if(!CurrentStateOfBuildings2)
                    {
                        DestroyALPHA2Achieved = true;
                        MeteorRain(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),20,500,100,500,2,1);
                    }
                }
            }

            //--- misja wykonana calkowicie ---
            if(DestroyALPHA1Achieved && DestroyALPHA2Achieved)
            {
                //check campaign goal 1
                p_Player.SetScriptData(scriptFieldGoal3,2);
                
                //check mission goal
                SetGoalState(DestroyALPHA,goalAchieved);

                EnableNextMission(0,true);
                EnableNextMission(1,true);
                AddBriefing("translateAccomplished413", p_Player.GetName());
                EnableEndMissionButton(true);
                return Nothing;
            }

            return Working;
        }


        state EndMissionFailed
        {
            EnableNextMission(0,2);
            return Nothing;
        }

    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        return Nothing, 500;
    }
    //-----------------------------------------------------------------------------------------


  //-----------------------------------------------------------------------------------------
    event Timer0() //wolany co minute
    {
    }
    
  //-----------------------------------------------------------------------------------------
    event Timer2() 
    {
        if(ShowBriefingB && p_Player.IsPointLocated(GetPointX(34),GetPointY(34),0))
        {
            ShowBriefingB=false;
            CallCamera();
            p_Player.LookAt(GetPointX(34),GetPointY(34), 15, 0, 20, 0);
            AddBriefing("translateBriefing413b", p_Player.GetName());
        }
        if(ShowBriefingB && p_Player.IsPointLocated(GetPointX(35),GetPointY(35),0))
        {
            ShowBriefingB=false;
            CallCamera();
            p_Player.LookAt(GetPointX(35),GetPointY(35), 15, 0, 20, 0);
            AddBriefing("translateBriefing413b", p_Player.GetName());
        }
        DamageArea(p_Player.GetIFF(),GetPointX(34),GetPointY(34),0,9,5);
        DamageArea(p_Player.GetIFF(),GetPointX(35),GetPointY(35),0,9,5);
    }
  //-----------------------------------------------------------------------------------------
    event EndMission() 
    {
            if(DestroyALPHA1Achieved && DestroyALPHA2Achieved)
            {
                p_Player.SetScriptData(scriptFieldMoney,p_Player.GetScriptData(scriptFieldMoney)+p_Player.GetMoney());
                p_Player.SetMoney(0);
            }
        }

}
