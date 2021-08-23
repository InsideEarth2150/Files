player "translateAIPlayerEasy"
{
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        if(GetRace()==1)//ucs
        {
            SetName("translateAIPlayerNameUCSEasy");
            if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetName("translateAINameEasyUCS1");
            if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetName("translateAINameEasyUCS2");
            if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetName("translateAINameEasyUCS3");
            if(GetIFFNumber()==4 ||GetIFFNumber()==9)SetName("translateAINameEasyUCS4");
        }
        if(GetRace()==2)//ed
        {
            SetName("translateAIPlayerNameEDEasy");
            if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetName("translateAINameEasyED1");
            if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetName("translateAINameEasyED2");
            if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetName("translateAINameEasyED3");
            if(GetIFFNumber()==4 ||GetIFFNumber()==9)SetName("translateAINameEasyED4");
        }
        if(GetRace()==3)//lc
        {
            SetName("translateAIPlayerNameLCEasy");
            if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetName("translateAINameEasyLC1");
            if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetName("translateAINameEasyLC2");
            if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetName("translateAINameEasyLC3");
            if(GetIFFNumber()==4 ||GetIFFNumber()==9)SetName("translateAINameEasyLC4");
        }
        EnableAIFeatures(aiUpgradeCannons,false);
        EnableAIFeatures(aiRush,false);
        
        SetMaxTankPlatoonSize(3);
        SetMaxHelicopterPlatoonSize(3);
        SetMaxShipPlatoonSize(3);
        
        SetNumberOfOffensiveTankPlatoons(1);
        SetNumberOfOffensiveShipPlatoons(1);
        SetNumberOfOffensiveHelicopterPlatoons(1);
        
        SetNumberOfDefensiveTankPlatoons(3);
        SetNumberOfDefensiveShipPlatoons(0);
        SetNumberOfDefensiveHelicopterPlatoons(1);
        SetMaxAttackFrequency(800);
        return Nothing;
    }
    state Nothing
    {
        return Nothing,100000;
    }
}