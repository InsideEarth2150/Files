mission "translateLCBase3"
{
    player p_Player;

        int i;

    state Initialize;
    state Nothing;
    state ShowBriefing;
    state EndGameState;

    state Initialize
    {
        unitex uHero;
        //----------- Goals ------------------
        RegisterGoal(0,"translateGoalBuildALPHA");
        RegisterGoal(1,"translateGoalBuildBETA");
        RegisterGoal(2,"translateGoalBuildGAMMA");
        RegisterGoal(3,"translateGoalBuildDELTA");
        RegisterGoal(4,"translateGoalBuildControlStation");

        EnableGoal(0,true);
        EnableGoal(1,true);
        EnableGoal(2,true);
        EnableGoal(3,true);
        EnableGoal(4,true);

        //----------- Players ----------------
        p_Player = GetPlayer(3);
        //----------- AI ---------------------

        p_Player.SetMilitaryUnitsLimit(50000);

        //----------- Money ------------------
        p_Player.SetMoney(0);

        //----------- Buildings --------------
        p_Player.EnableBuilding("LCBSR",false); //Centrum wydobywczo-transportowe

        //----------- Research ---------------
        p_Player.AddResearch("RES_MISSION_PACK1_ONLY");
        
        //----------- Researches -------------
        p_Player.EnableResearch("RES_LC_SGen",false);//611
        p_Player.EnableResearch("RES_LC_UMO2",false);//611
        p_Player.EnableResearch("RES_LCUFG1",false);//611 add
        p_Player.EnableResearch("RES_LCUFG2",false);//611
        p_Player.EnableResearch("RES_LC_WSL1",false);//611

        p_Player.EnableResearch("RES_LCCAA1",false);//612 add
        p_Player.EnableResearch("RES_LCUSF1",false);//612 add

        p_Player.EnableResearch("RES_LCBPP2",false);//613 add w drugiej po³owie misji
        p_Player.EnableResearch("RES_LCBNE",false);//613
        p_Player.EnableResearch("RES_LC_BMD",false);//613
        p_Player.EnableResearch("RES_LC_MGen",false);//613
        p_Player.EnableResearch("RES_LC_SOB1",false);//613
        p_Player.EnableResearch("RES_LC_REG1",false);//613
        p_Player.EnableResearch("RES_LC_UME1",false);//613//612

        p_Player.EnableResearch("RES_LC_WMR1",false);//615
        p_Player.EnableResearch("RES_LC_UCR1",false);//615
        p_Player.EnableResearch("RES_LC_HGen",false);//615
        p_Player.EnableResearch("RES_LC_BHD",false);//615
        p_Player.EnableResearch("RES_MMR2",false);//615

        p_Player.EnableResearch("RES_LCUNH",false);//616 add

        p_Player.EnableResearch("RES_LC_UBO1",false);//617
        p_Player.EnableResearch("RES_LC_AMR1",false);//617
        p_Player.EnableResearch("RES_LC_WHL1",false);//617

        p_Player.EnableResearch("RES_LC_ART",false);//618
        p_Player.EnableResearch("RES_LC_BWC",false);//618
        
        p_Player.EnableResearch("RES_LC_WARTILLERY",false);//619
        p_Player.EnableResearch("RES_LC_UCU1",false);//619
        
        p_Player.EnableResearch("RES_LCUUT",false);//621 add
        
        p_Player.EnableResearch("RES_LC_SHR1",false);//622
        
        p_Player.EnableResearch("RES_LC_WSS1",false);
        p_Player.EnableResearch("RES_LC_WHS1",false);
        p_Player.EnableResearch("RES_LC_WAS1",false);
        p_Player.EnableResearch("RES_LC_SDIDEF",false); //Laser antyrakietowy
        p_Player.EnableBuilding("LCBSD",false); //Obrona antyrakietowa
        p_Player.EnableBuilding("LCBSR",false); 
        p_Player.EnableBuilding("LCBRC",false); 
        

        //--- Variables for campaign goals ---
        p_Player.SetScriptData(0,0);
        p_Player.SetScriptData(1,0);
        p_Player.SetScriptData(2,0);
        p_Player.SetScriptData(3,0);
        p_Player.SetScriptData(4,0);

        //----------- Camera -----------------
        CallCamera();
        p_Player.LookAt(p_Player.GetStartingPointX(),p_Player.GetStartingPointY(),12,0,45,0);
        return ShowBriefing,1;
    }
    //-----------------------------------------------------------------------------------------
    state ShowBriefing
    {
        AddBriefing("translateStartCampaignLC1MP01",p_Player.GetName());
        return Nothing,50;
    }

    //-----------------------------------------------------------------------------------------
    state Nothing
    {
        //---checking campaign goals---
        for(i=0; i<5; i=i+1)
        {
            if(p_Player.GetScriptData(i)==2)
            {
                SetGoalState(i, goalAchieved);
            }
        }
        if(!p_Player.GetNumberOfBuildings())
        {
            AddBriefing("translateCampaignLCBaseDestroyed",p_Player.GetName());
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
}
