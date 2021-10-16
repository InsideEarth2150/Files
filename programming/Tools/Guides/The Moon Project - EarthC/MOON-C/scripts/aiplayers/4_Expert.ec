player "translateAIPlayerExpert"
{
        int nAttackMode;
    state Initialize;
        state SetLimitState;
    state Nothing;
    
    state Initialize
    {
                SetName("translateAIPlayerExpert");
        
        SetMaxTankPlatoonSize(6);
        SetMaxHelicopterPlatoonSize(6);
        SetMaxShipPlatoonSize(6);
        
        SetNumberOfOffensiveTankPlatoons(4);
        SetNumberOfOffensiveShipPlatoons(1);
        SetNumberOfOffensiveHelicopterPlatoons(4);
        
        SetNumberOfDefensiveTankPlatoons(1);
        SetNumberOfDefensiveShipPlatoons(0);
        SetNumberOfDefensiveHelicopterPlatoons(1);
 
                if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetNumberOfOffensiveTankPlatoons(2);
        if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetNumberOfDefensiveTankPlatoons(0);
        if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetNumberOfDefensiveTankPlatoons(5);
        if(GetIFFNumber()==4 ||GetIFFNumber()==9){SetMaxTankPlatoonSize(3);SetMaxHelicopterPlatoonSize(8);}
        

                AddResearch("RES_MCH2");
                AddResearch("RES_MCH3");
                AddResearch("RES_MCH4");
                AddResearch("RES_MSR2");
                AddResearch("RES_MSR3");
                AddResearch("RES_MSR4");
                AddResearch("RES_MMR2");
                AddResearch("RES_MMR3");
                AddResearch("RES_MMR4");

                if(GetRace()==1)//UCS
                {
                    AddResearch("RES_UCS_UOH2");
                    AddResearch("RES_UCS_UOH3");
                    AddResearch("RES_UCS_UAH1");
                    AddResearch("RES_UCS_UAH2");
                    AddResearch("RES_UCS_UAH3");
                    AddResearch("RES_UCS_GARG1");
                    AddResearch("RES_UCS_MB2");
                    AddResearch("RES_UCS_MB3");
                    AddResearch("RES_UCS_MB4");
                    AddResearch("RES_UCS_MG2");
                    AddResearch("RES_UCS_MG3");
                    AddResearch("RES_UCS_MG4");
                }

        if(GetRace()==2)//ed
        {
                    AddResearch("RES_ED_MSC2");
                    AddResearch("RES_ED_MSC3");
                    AddResearch("RES_ED_MSC4");
                    AddResearch("RES_ED_MHC2");
                    AddResearch("RES_ED_MHC3");
                    AddResearch("RES_ED_MHC4");
                    AddResearch("RES_ED_MB2");
                    AddResearch("RES_ED_MB3");
                    AddResearch("RES_ED_MB4");
                    AddResearch("RES_ED_UST2");
                    AddResearch("RES_ED_UST3");
                    AddResearch("RES_ED_UMT1");
                    AddResearch("RES_ED_UMT2");
                    AddResearch("RES_ED_UMT3");
                    AddResearch("RES_ED_UMI1");
                    AddResearch("RES_ED_UMI2");
                    AddResearch("RES_ED_UA11");
                }
        if(GetRace()==3)//lc
        {
                    AddResearch("RES_LC_ULU2");
                    AddResearch("RES_LC_ULU3");
                    AddResearch("RES_LC_UMO2");
                    AddResearch("RES_LC_UMO3");
                    AddResearch("RES_LC_UME1");
                }

                nAttackMode=0;
        SetMaxAttackFrequency(400);

        return SetLimitState,10;
    }

        state SetLimitState
    {
            if(GetMoney()<20000) AddMoney(20000-GetMoney());
            EnableMilitaryUnitsLimit(false);
            return Nothing,6000;
        }

    state Nothing
    {
                //if(GetMoney()<20000)AddMoney(20000);

                if(!nAttackMode)
                {
                    nAttackMode=1;
                    SetMaxAttackFrequency(20);
                    return Nothing,200;//1min=60*20=1200
                }
                nAttackMode=0;
                SetMaxAttackFrequency(800);
        return Nothing,5000;//1min=60*20=1200
    }
}