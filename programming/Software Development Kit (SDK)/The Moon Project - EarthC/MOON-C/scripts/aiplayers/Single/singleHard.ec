player "translateAIPlayerHard"
{
        int nAttackMode;
    state Initialize;
    state Nothing;
    
    state Initialize
    {
        if(GetRace()==1)//ucs
        {
            SetName("translateAIPlayerNameUCSHard");
            if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetName("translateAINameHardUCS1");
            if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetName("translateAINameHardUCS2");
            if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetName("translateAINameHardUCS3");
            if(GetIFFNumber()==4 ||GetIFFNumber()==9)SetName("translateAINameHardUCS4");
        }
        if(GetRace()==2)//ed
        {
            SetName("translateAIPlayerNameEDHard");
            if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetName("translateAINameHardED1");
            if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetName("translateAINameHardED2");
            if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetName("translateAINameHardED3");
            if(GetIFFNumber()==4 ||GetIFFNumber()==9)SetName("translateAINameHardED4");
        }
        if(GetRace()==3)//lc
        {
            SetName("translateAIPlayerNameLCHard");
            if(GetIFFNumber()==1 ||GetIFFNumber()==6)SetName("translateAINameHardLC1");
            if(GetIFFNumber()==2 ||GetIFFNumber()==7)SetName("translateAINameHardLC2");
            if(GetIFFNumber()==3 ||GetIFFNumber()==8)SetName("translateAINameHardLC3");
            if(GetIFFNumber()==4 ||GetIFFNumber()==9)SetName("translateAINameHardLC4");
        }
        SetMaxTankPlatoonSize(6);
        SetMaxHelicopterPlatoonSize(6);
        SetMaxShipPlatoonSize(6);
        
        SetNumberOfOffensiveTankPlatoons(4);
        SetNumberOfOffensiveShipPlatoons(4);
        SetNumberOfOffensiveHelicopterPlatoons(4);
        
        SetNumberOfDefensiveTankPlatoons(4);
        SetNumberOfDefensiveShipPlatoons(0);
        SetNumberOfDefensiveHelicopterPlatoons(3);
        SetMaxAttackFrequency(400);
        return Nothing,6000;
    }
    state Nothing
    {
        if(!nAttackMode)
        {
            nAttackMode=1;
            SetMaxAttackFrequency(10);
            return Nothing,200;
        }
        nAttackMode=0;
        SetMaxAttackFrequency(800);
        return Nothing,6000;//1min=60*20=1200
    }
}