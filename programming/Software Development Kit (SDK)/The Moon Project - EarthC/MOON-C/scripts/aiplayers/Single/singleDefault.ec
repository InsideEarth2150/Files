player "translateAIPlayerMedium"
{
    state Initialize;
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
        return Nothing;
    }
    state Nothing
    {
        return Nothing,100000;
    }
}