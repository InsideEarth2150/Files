sapper "translateScriptNameMiner"
{
    int m_nMoveToX;
    int m_nMoveToY;
    int m_nMoveToZ;
    int m_nMinePointX;
    int m_nMinePointY;
    int m_nMinePointZ;
    int m_nState;//0-Nothing, 1-Moving, 2-MovingToMinePutPoint
    
    enum lights
    {
        "translateCommandStateLightsAUTO",
        "translateCommandStateLightsON",
        "translateCommandStateLightsOFF",
multi:
        "translateCommandStateLightsMode"
    }
    
    
    state Initialize;
    state Nothing;
    state StartMoving;
    state Moving;
    state MovingToMinePutPoint;
    state PuttingMine;
    state WaitForMines;
    
    state Initialize
    {
        return Nothing;
    }
    
    state Nothing
    {
        return Nothing;
    }
    
    state StartMoving
    {
        return Moving, 20;
    }
    //--------------------------------------------------------------------------
    state Moving
    {
        if (IsMoving())
        {
            return Moving;
        }
        else
        {
            NextCommand(1);
            return Nothing;
        }
    }
    
    state MovingToMinePutPoint
    {
        if (IsMoving())
        {
            return MovingToMinePutPoint;
        }
        else
        {
            if ((GetLocationX() == m_nMinePointX) && (GetLocationY() == m_nMinePointY) && (GetLocationZ() == m_nMinePointZ))
            {
                if (HaveMines())
                {
                    CallPutMine();
                    return PuttingMine;
                }
                else
                {
                    return WaitForMines;
                }
            }
            else
            {
                //moze zastosowac jakis licznik (po wyzerowaniu ktorego przechodzimy do nastepnego punktu) 
                //zeby w kolko nie wywolywac ponizszego
                CallMoveToPointForce(m_nMinePointX, m_nMinePointY, m_nMinePointZ);
                return MovingToMinePutPoint;
            }
        }
    }
    
    state PuttingMine
    {
        if (IsPuttingMine())
        {
            //jeszcze nie skonczyl
            state PuttingMine;
        }
        else
        {
            if (NextMinePoint())
            {
                m_nMinePointX = GetCurrMinePointX();
                m_nMinePointY = GetCurrMinePointY();
                m_nMinePointZ = GetCurrMinePointZ();
                CallMoveToPointForce(m_nMinePointX, m_nMinePointY, m_nMinePointZ);
                return MovingToMinePutPoint;
            }
            else
            {
                //nie ma juz wiecej punktow do zaminowania
                NextCommand(1);
                return Nothing;
            }
        }
    }
    
    state WaitForMines
    {
        if (HaveMines())
        {
            CallPutMine();
            return PuttingMine;
        }
        else
        {
            return WaitForMines;
        }
    }
    
    //------------------------------------------------------- 
    state Froozen
    {
        if (IsFroozen())
        {
            state Froozen;
        }
        else
        {
            if (m_nState == 2)
            {
                CallMoveToPoint(m_nMinePointX, m_nMinePointY, m_nMinePointZ);
                return MovingToMinePutPoint;
            }
            else if (m_nState == 1)
            {
                CallMoveToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                return Moving;
            }
            else
            {
                return Nothing;
            }
        }
    }
    
    event OnFreezeForSupplyOrRepair(int nFreezeTicks)
    {
        if (state == Froozen)
        {
            //zostaje poprzedni m_nState
        }
        else if ((state == StartMoving) || (state == Moving))
        {
            m_nState = 1;
        }
        else if ((state == MovingToMinePutPoint) || (state == PuttingMine) ||
            (state == WaitForMines))
        {
            m_nState = 2;
        }
        else
        {
            m_nState = 0;
        }
        CallFreeze(nFreezeTicks);
        state Froozen;
        true;
    }
    //------------------------------------------------------- 
    
    command Initialize()
    {
        //pozwolic dzialkom strzelac samym (o ile sa jakies)
        SetCannonFireMode(-1, 1);
        false;
    }
    
    command Uninitialize()
    {
        //wykasowac referencje
        false;
    }
    
    command MineTerrainClose(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandMineClose" description "translateCommandMineCloseDescription" hotkey priority 100
    {
        ResetMinePoints();
        if (AddMineAreaClose(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMinePointX = GetCurrMinePointX();
            m_nMinePointY = GetCurrMinePointY();
            m_nMinePointZ = GetCurrMinePointZ();
            CallMoveToPointForce(m_nMinePointX, m_nMinePointY, m_nMinePointZ);
            state MovingToMinePutPoint;
        }
        else
        {
            //nie mozna postawic miny na zadnym punkcie tego obszaru
        }
        true;
    }
    
    command MineTerrainMedium(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandMineMedium" description "translateCommandMineMediumDescription" hotkey priority 101
    {
        ResetMinePoints();
        if (AddMineAreaMedium(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMinePointX = GetCurrMinePointX();
            m_nMinePointY = GetCurrMinePointY();
            m_nMinePointZ = GetCurrMinePointZ();
            CallMoveToPointForce(m_nMinePointX, m_nMinePointY, m_nMinePointZ);
            state MovingToMinePutPoint;
        }
        else
        {
            //nie mozna postawic miny na zadnym punkcie tego obszaru
        }
        true;
    }
    
    command MineTerrainFar(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandMineFar" description "translateCommandMineFarDescription" hotkey priority 102
    {
        ResetMinePoints();
        if (AddMineAreaFar(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMinePointX = GetCurrMinePointX();
            m_nMinePointY = GetCurrMinePointY();
            m_nMinePointZ = GetCurrMinePointZ();
            CallMoveToPointForce(m_nMinePointX, m_nMinePointY, m_nMinePointZ);
            state MovingToMinePutPoint;
        }
        else
        {
            //nie mozna postawic miny na zadnym punkcie tego obszaru
        }
        true;
    }
    
    command MineTerrainLine(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandMineLine" description "translateCommandMineLineDescription" hotkey priority 103
    {
        ResetMinePoints();
        if (AddMineLine(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMinePointX = GetCurrMinePointX();
            m_nMinePointY = GetCurrMinePointY();
            m_nMinePointZ = GetCurrMinePointZ();
            CallMoveToPointForce(m_nMinePointX, m_nMinePointY, m_nMinePointZ);
            state MovingToMinePutPoint;
        }
        else
        {
            //nie mozna postawic miny na zadnym punkcie tego obszaru
        }
        true;
    }
    
    command UserPoint0(int nX, int nY, int nZ) button "translateCommandAddPoint" description "translateCommandAddPointDescription" hotkey priority 102
    {
        //for test
        if (IsCurrentMineArea())
        {
            ResetMinePoints();
        }
        if (AddMinePoint(nX, nY, nZ))
        {
            if ((state != MovingToMinePutPoint) && (state != WaitForMines) && (state != PuttingMine))
            {
                m_nMinePointX = GetCurrMinePointX();
                m_nMinePointY = GetCurrMinePointY();
                m_nMinePointZ = GetCurrMinePointZ();
                CallMoveToPointForce(m_nMinePointX, m_nMinePointY, m_nMinePointZ);
                state MovingToMinePutPoint;
            }
        }
                else
                    NextCommand(0);
        true;
    }
    
    command Move(int nGx, int nGy, int nLz) hidden button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        ResetMinePoints();
        m_nMoveToX = nGx;
        m_nMoveToY = nGy;
        m_nMoveToZ = nLz;
        CallMoveToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
        state StartMoving;
        true;
    }
    
    command Enter(unit uEntrance) hidden button "translateCommandEnter"
    {
        ResetMinePoints();
        m_nMoveToX = GetEntranceX(uEntrance);
        m_nMoveToY = GetEntranceY(uEntrance);
        m_nMoveToZ = GetEntranceZ(uEntrance);
        CallMoveInsideObject(uEntrance);
        state StartMoving;
        true;
    }
    
    command SendSupplyRequest() button "translateCommandSupply" description "translateCommandSupplyDescription" hotkey priority 27
    {
        SendSupplyRequest();
        NextCommand(1);
        true;
    }
    
    command Stop() button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        ResetMinePoints();
        CallStopMoving();
        state StartMoving;
        true;
    }
    //-------------------------------------------------------
    command SetLights(int nMode) button lights description "translateCommandStateLightsModeDescription" hotkey priority 204
    {
        if (nMode == -1)
            lights = (lights + 1) % 3;
        else
            lights = nMode;
        SetLightsMode(lights);
    }
    
    //-------------------------------------------------------
    command SpecialChangeUnitsScript() button "translateCommandChangeScript" description "translateCommandChangeScriptDescription" hotkey priority 254 
    {
        //special command - no implementation
    }
}