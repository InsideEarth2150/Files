builder "translateScriptNameConstructionVechicle"
{
    consts
    {
        buildNone = 0;
        buildBuilding = 1;
        buildWall = 2;
        buildTrench = 3;
        buildFlatTerrain = 4;
        buildWideBridge = 5;
        buildNarrowBridge = 6;
        buildWideTunnel = 7;
        buildNarrowTunnel = 8;
    }
    
    int  m_nMoveToX;
    int  m_nMoveToY;
    int  m_nMoveToZ;
    
    enum lights
    {
        "translateCommandStateLightsAUTO",
        "translateCommandStateLightsON",
        "translateCommandStateLightsOFF",
multi:
        "translateCommandStateLightsMode"
    }
    
    enum traceMode
    {
        "translateCommandStateTraceOFF",
        "translateCommandStateTraceON",
multi:
        "translateCommandStateTraceMode"
    }
    
    
    state Initialize;
    state Nothing;
    state StartMoving;
    state Moving;
    state MovingToBuildBuilding;
    state MovingToBuildElement;
    state BuildBuilding;
    state BuildElement;
    
    
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
        return Moving, 40;
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
    
    state MovingToBuildBuilding
    {
        if (IsMoving())
        {
            if(traceMode) TraceD("BuildRobot->IsMoving\n");
            return MovingToBuildBuilding;
        }
        else
        {
            if (IsInGoodPointForCurrentBuild())
            {
                if(traceMode)     TraceD("BuildRobot->CallBuildBuilding\n");
                CallBuildBuilding();
                return BuildBuilding;
            }
            else
            {
                //!!jakis licznik?
                m_nMoveToX = GetCurrentBuildLocationX();
                m_nMoveToY = GetCurrentBuildLocationY();
                m_nMoveToZ = GetCurrentBuildLocationZ();
                CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                return MovingToBuildBuilding;
            }
        }
    }
    
    state MovingToBuildElement
    {
        if (IsMoving())
        {
            return MovingToBuildElement;
        }
        else
        {
            if (IsInGoodPointForCurrentBuild())
            {
                CallBuildCurrentElement();
                return BuildElement;
            }
            else
            {
                //!!jakis licznik?
                m_nMoveToX = GetCurrentBuildLocationX();
                m_nMoveToY = GetCurrentBuildLocationY();
                m_nMoveToZ = GetCurrentBuildLocationZ();
                CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                return MovingToBuildElement;
            }
        }
    }
    
    state BuildBuilding
    {
        if (IsBuildWorking())
        {
            return BuildBuilding;
        }
        else
        {
            NextCommand(1);//!!1 czy 0?
            return Nothing;
        }
    }
    
    state BuildElement
    {
        if (IsBuildWorking())
        {
            return BuildElement;
        }
        else
        {
            if (NextElementPoint())
            {
                m_nMoveToX = GetCurrentBuildLocationX();
                m_nMoveToY = GetCurrentBuildLocationY();
                m_nMoveToZ = GetCurrentBuildLocationZ();
                CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                return MovingToBuildElement;
            }
            else
            {
                NextCommand(1);//!!1 czy 0?
                return Nothing;
            }
        }
    }
    
    command Initialize()
    {
        false;
    }
    
    
    command Uninitialize()
    {
        //wykasowac referencje
        false;
    }
    
    //bez nazwy - wywolywane po wybraniu miejsca
    command BuildBuilding(int nX, int nY, int nZ, int nAlpha, int nID) hidden button "translateCommandBuilding"
    {
        SetBuildTypeBuildBuilding(nX, nY, nZ, nAlpha, nID);
        m_nMoveToX = GetCurrentBuildLocationX();
        m_nMoveToY = GetCurrentBuildLocationY();
        m_nMoveToZ = GetCurrentBuildLocationZ();
        CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
        state MovingToBuildBuilding;
        true;
    }
    
    command BuildTrench(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandTrench" hotkey
    {
        SetBuildTypeBuildElements(buildTrench);
        if (AddElementsLine(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMoveToX = GetCurrentBuildLocationX();
            m_nMoveToY = GetCurrentBuildLocationY();
            m_nMoveToZ = GetCurrentBuildLocationZ();
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToBuildElement;
        }
        true;
    }
    
    command BuildFlatTerrain(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandFlatten" hotkey
    {
        SetBuildTypeBuildElements(buildFlatTerrain);
        if (AddElementsLine(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMoveToX = GetCurrentBuildLocationX();
            m_nMoveToY = GetCurrentBuildLocationY();
            m_nMoveToZ = GetCurrentBuildLocationZ();
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToBuildElement;
        }
        true;
    }
    
    command BuildWall(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandWall" hotkey
    {
        SetBuildTypeBuildElements(buildWall);
        if (AddElementsLine(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMoveToX = GetCurrentBuildLocationX();
            m_nMoveToY = GetCurrentBuildLocationY();
            m_nMoveToZ = GetCurrentBuildLocationZ();
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToBuildElement;
        }
        true;
    }
    command BuildWideBridge(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandBridge2" hotkey
    {
        SetBuildTypeBuildElements(buildWideBridge);
        if (AddElementsLine(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMoveToX = GetCurrentBuildLocationX();
            m_nMoveToY = GetCurrentBuildLocationY();
            m_nMoveToZ = GetCurrentBuildLocationZ();
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToBuildElement;
        }
        true;
    }
    
    command BuildNarrowBridge(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandBridge1" hotkey
    {
        SetBuildTypeBuildElements(buildNarrowBridge);
        if (AddElementsLine(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMoveToX = GetCurrentBuildLocationX();
            m_nMoveToY = GetCurrentBuildLocationY();
            m_nMoveToZ = GetCurrentBuildLocationZ();
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToBuildElement;
        }
        true;
    }
    
    command BuildWideTunnel(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandTunnel2" hotkey
    {
        SetBuildTypeBuildElements(buildWideTunnel);
        if (AddElementsLine(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMoveToX = GetCurrentBuildLocationX();
            m_nMoveToY = GetCurrentBuildLocationY();
            m_nMoveToZ = GetCurrentBuildLocationZ();
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToBuildElement;
        }
        true;
    }
    
    command BuildNarrowTunnel(int nX1, int nY1, int nZ1, int nX2, int nY2, int nZ2) button "translateCommandTunnel1" hotkey
    {
        SetBuildTypeBuildElements(buildNarrowTunnel);
        if (AddElementsLine(nX1, nY1, nZ1, nX2, nY2, nZ2))
        {
            m_nMoveToX = GetCurrentBuildLocationX();
            m_nMoveToY = GetCurrentBuildLocationY();
            m_nMoveToZ = GetCurrentBuildLocationZ();
            CallMoveToPointForce(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            state MovingToBuildElement;
        }
        true;
    }
    
    command SpecialNextAngle() button "translateCommandTurn" description "translateCommandTurnDescription" hotkey priority 50
    {
        //implemented in code
    }
    
    command Move(int nGx, int nGy, int nLz) button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        m_nMoveToX = nGx;
        m_nMoveToY = nGy;
        m_nMoveToZ = nLz;
        CallMoveToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
        state StartMoving;
        true;
    }
    //-------------------------------------------------------
    command SetLights(int nMode) button lights hotkey priority 204
    {
        if (nMode == -1)
        {
            lights = (lights + 1) % 3;
        }
        else
        {
            assert(nMode == 0);
            lights = nMode;
        }
        SetLightsMode(lights);
    }
    //-------------------------------------------------------
    command Enter(unit uEntrance) hidden button "translateCommandEnter"
    {
        m_nMoveToX = GetEntranceX(uEntrance);
        m_nMoveToY = GetEntranceY(uEntrance);
        m_nMoveToZ = GetEntranceZ(uEntrance);
        CallMoveInsideObject(uEntrance);
        state StartMoving;
        true;
    }
    
    //-------------------------------------------------------
    command SpecialChangeUnitsScript() button "translateCommandChangeScript" description "translateCommandChangeScriptDescription" hotkey priority 254 
    {
        //special command - no implementation
    }
    
    /*    command UserOneParam9(int nMode) hidden button traceMode priority 255
    {
    if (nMode == -1)
    {
    traceMode = (traceMode + 1) % 2;
    }
    else
    {
    assert(nMode == 0);
    traceMode = nMode;
    }
    }*/
    
    
}