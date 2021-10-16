mission "translateMissionUCSBaseLCMP01"
{
    player p_PlayerLC;
    
    state Initialize;
    state Nothing;

          state Initialize
    {
        p_PlayerLC=GetPlayer(3);
        p_PlayerLC.SetMoney(10000);

        p_PlayerLC.EnableAIFeatures(aiBuildTanks,false);    
        p_PlayerLC.EnableAIFeatures(aiBuildShips,false);
        p_PlayerLC.EnableAIFeatures(aiBuildHelicopters,false);
        
        p_PlayerLC.EnableAIFeatures(aiBuildSpecialUnits,false);


        //----------- Researches -------------
/*              //413
        p_PlayerLC.EnableResearch("RES_LC_WCH2",false); //Sprzê¿one dzia³ka 20 mm
        p_PlayerLC.EnableResearch("RES_LC_ACH2",false); //Lotnicze dzia³ka 20 mm
        p_PlayerLC.EnableResearch("RES_LC_WSR1",false); //Wyrzutnia rakiet R1 (bylo "RES_LC_WSR2")
        p_PlayerLC.EnableResearch("RES_LC_ASR1",false); //Wyrzutnia rakiet R1a
        p_PlayerLC.EnableResearch("RES_LC_WSL1",false); //Dzia³o elektryczne E1
        
                //414
                p_PlayerLC.EnableResearch("RES_LC_WMR1",false); //Wyrzutnia ciê¿kich rakiet R12
        p_PlayerLC.EnableResearch("RES_LC_AMR1",false); //Wyrzutnia ciê¿kich rakiet R1a
        p_PlayerLC.EnableResearch("RES_LC_WHL1",false); //Dzia³o elektryczne E3
                p_PlayerLC.EnableResearch("RES_LC_UCR1",false); //Crater m1

                //415
        p_PlayerLC.EnableResearch("RES_LC_WSS1",false); //miotacz dzwiekowy D1
        p_PlayerLC.EnableResearch("RES_LC_WHS1",false); // -"- D3
                p_PlayerLC.EnableResearch("RES_LC_UCU1",false); //Crusher m1
        
                //416
        p_PlayerLC.EnableResearch("RES_LC_WAS1",false); // -"- D5
                p_PlayerLC.EnableResearch("RES_LC_UBO1",false); //Thunder m1

                //417
                p_PlayerLC.EnableResearch("RES_LC_WARTILLERY",false);   //Artyleria plazmowa
*/

                p_PlayerLC.AddResearch("RES_MISSION_PACK1_ONLY");
                p_PlayerLC.EnableResearch("RES_LC_WSS1",false); //miotacz dzwiekowy D1
                p_PlayerLC.EnableResearch("RES_LC_WHS1",false); // -"- D3
    //----------411             
                p_PlayerLC.EnableResearch("RES_LC_SGen",false);
                p_PlayerLC.EnableResearch("RES_LC_BMD",false);
                p_PlayerLC.EnableResearch("RES_MCH2",false);
    //----------412
                p_PlayerLC.EnableResearch("RES_LC_WCH2",false);
                p_PlayerLC.EnableResearch("RES_LC_WSR2",false);
                p_PlayerLC.EnableResearch("RES_MSR2",false);
                p_PlayerLC.EnableResearch("RES_MCH3",false);
    //----------413
                p_PlayerLC.EnableResearch("RES_LC_UME1",false);
                p_PlayerLC.EnableResearch("RES_LC_ULU2",false);
                p_PlayerLC.EnableResearch("RES_LC_UMO2",false);
                p_PlayerLC.EnableResearch("RES_LC_ACH2",false);
                p_PlayerLC.EnableResearch("RES_LC_ASR1",false);
                p_PlayerLC.EnableResearch("RES_LC_WSL1",false);
                p_PlayerLC.EnableResearch("RES_MSR2",false);
    //----------414
                p_PlayerLC.EnableResearch("RES_LC_WSL1",false);
                p_PlayerLC.EnableResearch("RES_LC_WSR3",false);
                p_PlayerLC.EnableResearch("RES_LC_MGen",false);
    //----------415
                p_PlayerLC.EnableResearch("RES_LC_UCR1",false);
                p_PlayerLC.EnableResearch("RES_LC_WHL1",false);
                p_PlayerLC.EnableResearch("RES_LC_WMR1",false);
                p_PlayerLC.EnableResearch("RES_MMR2",false);
                p_PlayerLC.EnableResearch("RES_LC_BHD",false);
    //----------416
                p_PlayerLC.EnableResearch("RES_LC_UCU1",false);
                p_PlayerLC.EnableResearch("RES_LC_UBO1",false);
                p_PlayerLC.EnableResearch("RES_LC_AMR1",false);
                p_PlayerLC.EnableResearch("RES_LC_HGen",false);


        //SPECIAL
        p_PlayerLC.EnableResearch("RES_LC_BWC",false);  //Centrum kontroli pogody
        p_PlayerLC.EnableResearch("RES_LC_SDIDEF",false);   //Laser antyrakietowy
        p_PlayerLC.EnableBuilding("LCCSD", false);  //Laser antyrakietowy
        p_PlayerLC.EnableResearch("RES_LC_WSS1",false);

        EnableUnitSounds(false);
        EnableBuildingSounds(false);
        return Nothing;
    }
    state Nothing
    {
    }
    event CustomEvent0(int k1,int k2,int k3,int k4) //XXXMD
    {
            if(k1==1)
            {
                    EnableUnitSounds(true);
                    EnableBuildingSounds(true);

            }
    }
}






