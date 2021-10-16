mission "translateMissionUCSBaseUCSMP01"
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
    }
    player p_Player;

    int i;

    state Initialize;
    state Waiting;
    state PrepareShowBriefing;
    state ShowBriefing;
    state Nothing;
    state EndGameState;

    
    state Initialize
    { 
        unitex u_Grizzli1;
        unitex u_Grizzli2;

        //----------- Goals ------------------
        RegisterGoal(0, "translateGoalCaptureInfo");
        RegisterGoal(1, "translateGoalSunLightFail");
        RegisterGoal(2, "translateGoalDestroyALPHA");
        RegisterGoal(3, "translateGoalDestroyBETA");
        RegisterGoal(4, "translateGoalDestroyGAMMA");
        RegisterGoal(5, "translateGoalDestroyDELTA");
        RegisterGoal(6, "translateGrizzli1HaveToSurvive");
        RegisterGoal(7, "translateGrizzli2HaveToSurvive");

        EnableGoal(0,true);
        EnableGoal(6,true);
        EnableGoal(7,true);

        //----------- Players ----------------
        p_Player = GetPlayer(1);


        p_Player.EnableBuilding("UCSBWB", false);   //Stocznia
        p_Player.EnableBuilding("UCSBTB", false);   //Centrum transportu rudy
        p_Player.EnableBuilding("UCSCSD", false);   //Laser antyrakietowy


        
        //p_Player.AddResearch("RES_UCS_WSR1"); //Wyrzutnia rakiet
        //p_Player.AddResearch("RES_UCS_UML1"); //Spider
        //p_Player.AddResearch("RES_UCS_UHL1"); //Panther

        p_Player.AddResearch("RES_MISSION_PACK1_ONLY");
        p_Player.EnableResearch("RES_UCS_USS1",false);  //Shark - ≥Ûdü
        p_Player.EnableResearch("RES_UCS_USS2",false);  //Shark - ≥Ûdü
        p_Player.EnableResearch("RES_UCS_USM1",false);  //Orca - ≥Ûdü podwodna
        p_Player.EnableResearch("RES_UCS_USM2",false);  //Orca - ≥Ûdü podwodna
        p_Player.EnableResearch("RES_UCS_UBS1",false);  //Hydra - ≥Ûdü
        p_Player.EnableResearch("RES_UCS_WSD",false);   //laser antyrakietowy
        p_Player.EnableResearch("RES_UCS_PC",false);    //Stacjonarne dzia≥o plazmowe


        p_Player.EnableResearch("RES_UCS_ART",false);
        //----------------------------------413
        p_Player.EnableResearch("RES_UCS_USL2",false);
        p_Player.EnableResearch("RES_UCS_GARG1",false);
        p_Player.EnableResearch("RES_UCS_WCH2",false);
        p_Player.EnableResearch("RES_UCS_WSP1",false);
        p_Player.EnableResearch("RES_UCS_WSR1",false);
        p_Player.EnableResearch("RES_UCS_WSG2",false);
        p_Player.EnableResearch("RES_MCH2",false);
        p_Player.EnableResearch("RES_MSR2",false);
        p_Player.EnableResearch("RES_UCS_MG2",false);
        p_Player.EnableResearch("RES_UCS_RepHand",false);
        p_Player.EnableResearch("RES_UCS_SGen",false);
        //----------------------------------414
        p_Player.EnableResearch("RES_UCS_UML1",false);
        p_Player.EnableResearch("RES_MCH3",false);
        p_Player.EnableResearch("RES_MSR3",false);
        p_Player.EnableResearch("RES_UCS_MG3",false);
        p_Player.EnableResearch("RES_UCS_MGen",false);
        //----------------------------------415
        p_Player.EnableResearch("RES_UCS_GARG1",false);
        p_Player.EnableResearch("RES_UCS_UHL1",false);
        p_Player.EnableResearch("RES_UCS_WHG1",false);
        p_Player.EnableResearch("RES_UCS_WHP1",false);
        p_Player.EnableResearch("RES_UCS_WHP2",false);
        p_Player.EnableResearch("RES_UCS_WSR3",false);
        p_Player.EnableResearch("RES_UCS_WASR1",false);
        p_Player.EnableResearch("RES_UCS_WMR1",false);
        p_Player.EnableResearch("RES_MMR2",false);
        p_Player.EnableResearch("RES_UCS_RepHand2",false);
        p_Player.EnableResearch("RES_UCS_HGen",false);
        p_Player.EnableResearch("RES_UCS_BMD",false);
        p_Player.EnableResearch("RES_UCS_SHD",false);
        //----------------------------------416
        p_Player.EnableResearch("RES_UCS_UBL1",false);
        p_Player.EnableResearch("RES_UCS_UMI1",false);
        p_Player.EnableResearch("RES_UCS_BOMBER21",false);
        p_Player.EnableResearch("RES_UCS_WHP3",false);
        p_Player.EnableResearch("RES_UCS_WMR2",false);
        p_Player.EnableResearch("RES_UCS_WAMR1",false);
        p_Player.EnableResearch("RES_MMR3",false);
        //----------------------------------417
        p_Player.EnableResearch("RES_UCS_BHD",false);
        p_Player.EnableResearch("RES_UCS_BOMBER22",false);
        p_Player.EnableResearch("RES_UCS_SHD2",false);
        //----------------------------------418
        p_Player.EnableResearch("RES_UCS_BOMBER31",false);
        p_Player.EnableResearch("RES_UCS_WAPB1",false);
        p_Player.EnableResearch("RES_UCS_SHD3",false);
        //----------------------------------419
        p_Player.EnableResearch("RES_UCS_WAPB2",false);
        p_Player.EnableResearch("RES_UCS_MB2",false);
        p_Player.EnableResearch("RES_UCS_SHD4",false);


        p_Player.EnableResearch("RES_UCSUCS",false);
        p_Player.EnableResearch("RES_UCSWEQ1",false);
        p_Player.EnableResearch("RES_UCSWBHC1",false);
        //--- Variables for campaign goals ---
        p_Player.SetScriptData(0,0);
        p_Player.SetScriptData(1,0);
        p_Player.SetScriptData(2,0);
        p_Player.SetScriptData(3,0);
        p_Player.SetScriptData(4,0);
        p_Player.SetScriptData(5,0);

        p_Player.EnableCommand(commandSoldBuilding,true);
//----------- Units ------------------
        u_Grizzli1 = GetUnit(GetPointX(1),GetPointY(1),GetPointZ(1));
        u_Grizzli2 = GetUnit(GetPointX(2),GetPointY(2),GetPointZ(2));
        u_Grizzli1.SetUnitName("translateGrizzli1");
        u_Grizzli2.SetUnitName("translateGrizzli2");

        p_Player.SetScriptUnit(1,u_Grizzli1);
        p_Player.SetScriptUnit(2,u_Grizzli2);
        //----------- Money ------------------
        p_Player.SetMoney(0);
        p_Player.SetMilitaryUnitsLimit(15000);
        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),6,0,20,0);

        EnableUnitSounds(false);
        EnableBuildingSounds(false);

        return Waiting;
    }

    //-----------------------------------------------------------------------------------------
    state Waiting
    {
    
    }
    state PrepareShowBriefing
    {
        return ShowBriefing,100;
    }
    state ShowBriefing
    {
        unitex u_Grizzli1;
        unitex u_Grizzli2;
        AddBriefing("translateStartCampaignUCSMP01",p_Player.GetName());
        u_Grizzli1 = p_Player.GetScriptUnit(1);
        p_Player.AddUnitToSpecialTab(u_Grizzli1,true, -1);
        u_Grizzli2 = p_Player.GetScriptUnit(2);
        p_Player.AddUnitToSpecialTab(u_Grizzli2,true, -1);
        
        EnableUnitSounds(true);
        EnableBuildingSounds(true);

        TraceD("EnableGameFeature(lockResearchDialog,false);           \n");
        EnableGameFeature(lockResearchDialog,false);
        EnableGameFeature(lockConstructionDialog,false);
        EnableGameFeature(lockUpgradeWeaponDialog,false);

        
        return Nothing,50;
    }    

    //-----------------------------------------------------------------------------------------

    state Nothing
    {
        unitex u_Grizzli1;
        unitex u_Grizzli2;
        
        if(p_Player.GetScriptData(scriptFieldMeteors)==10)
        {
            p_Player.SetScriptData(scriptFieldMeteors,0);
            MeteorRain(p_Player.GetStartingPointX(), p_Player.GetStartingPointY(),20,500,1200,500,10,10);
        }
        if(p_Player.GetScriptData(scriptFieldMoney))//Chash from missions after the end. 
        {
            p_Player.AddMoney(p_Player.GetScriptData(scriptFieldMoney));
            p_Player.SetScriptData(scriptFieldMoney,0);
        }
        //---checking campaign goals---
        for(i=0; i<6; i=i+1)
        {
            if(p_Player.GetScriptData(i)==1)
            {
                EnableGoal(i,true);
            }

            if(p_Player.GetScriptData(i)==2)
            {
                SetGoalState(i, goalAchieved);
            }
        }
        u_Grizzli1 = p_Player.GetScriptUnit(1);
        u_Grizzli2 = p_Player.GetScriptUnit(2);

        if(!p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateCampaignUCSBaseDestroyed",p_Player.GetName());
            return EndGameState,5;
        }
        if((u_Grizzli1==null || !u_Grizzli1.IsLive())&&
            (u_Grizzli2==null || !u_Grizzli2.IsLive()))
        {
            SetGoalState(6,goalFailed);
            SetGoalState(7,goalFailed);
            AddBriefing("translateBothGrizzlisKilled",p_Player.GetName());
            return EndGameState,5;
        }
            
        if(u_Grizzli1==null || !u_Grizzli1.IsLive())
        {
            SetGoalState(6,goalFailed);
            AddBriefing("translateGrizzli1Killed",p_Player.GetName());
            return EndGameState,5;
        }

        if(u_Grizzli2==null || !u_Grizzli2.IsLive())
        {
            SetGoalState(7,goalFailed);
            AddBriefing("translateGrizzli2Killed",p_Player.GetName());
            return EndGameState,5;
        }
            return Nothing,50;
    }
    
    //-----------------------------------------------------------------------------------------
    state EndGameState
    {
        EnableNextMission(0,2);//end campaign
        return EndGameState,600;
    }
    
    //-----------------------------------------------------------------------------------------
    event CustomEvent0(int k1,int k2,int k3,int k4) //XXXMD
    {
            if(k1==1)
            {
                state ShowBriefing;
            }
    }
}
