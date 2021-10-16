player "translateAIPlayerMedium"
{
    state Initialize;
        state SetLimitState;
    state Nothing;
    
    state Initialize
    {
        if(GetRace()==1)//ucs
        {
            SetName("translateAIPlayerNameUCSMedium");
            if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetName("translateAINameMediumUCS1");
            if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetName("translateAINameMediumUCS2");
            if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetName("translateAINameMediumUCS3");
            if(GetIFFNumber()==4 ||GetIFFNumber()==9)SetName("translateAINameMediumUCS4");
        }
        if(GetRace()==2)//ed
        {
            SetName("translateAIPlayerNameEDMedium");
            if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetName("translateAINameMediumED1");
            if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetName("translateAINameMediumED2");
            if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetName("translateAINameMediumED3");
            if(GetIFFNumber()==4 ||GetIFFNumber()==9)SetName("translateAINameMediumED4");
        }
        if(GetRace()==3)//lc
        {
            SetName("translateAIPlayerNameLCMedium");
            if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetName("translateAINameMediumLC1");
            if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetName("translateAINameMediumLC2");
            if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetName("translateAINameMediumLC3");
            if(GetIFFNumber()==4 ||GetIFFNumber()==9)SetName("translateAINameMediumLC4");
        }
        SetMaxTankPlatoonSize(4);
        SetMaxHelicopterPlatoonSize(4);
        SetMaxShipPlatoonSize(4);
        
        SetNumberOfOffensiveTankPlatoons(5);
        SetNumberOfOffensiveShipPlatoons(2);
        SetNumberOfOffensiveHelicopterPlatoons(2);
        
        SetNumberOfDefensiveTankPlatoons(2);
        SetNumberOfDefensiveShipPlatoons(0);
        SetNumberOfDefensiveHelicopterPlatoons(1);
        
        EnableAIFeatures(aiRush,false);
                EnableAIFeatures(aiBuildSuperAttack,false);
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
        return Nothing,100000;
    }
}