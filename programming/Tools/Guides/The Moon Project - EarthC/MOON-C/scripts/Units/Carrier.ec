carrier "translateScriptNameContainerTransporter"
{
    int  m_nMoveToX;
    int  m_nMoveToY;
    int  m_nMoveToZ;
    int  m_nCurrPutGetX;
    int  m_nCurrPutGetY;
    int  m_nCurrPutGetZ;
    int  m_nContainerX;
    int  m_nContainerY;
    int  m_nContainerZ;
    int  m_nGetContainerFrom;//0 - mine, 1 - single container
    int  m_nState;

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
    state MovingToContainerSource;
    state MovingToContainerDestination;
    state GettingContainer;
    state PuttingContainer;
    //-------------------------------------------------------
    state Initialize
    {
        return Nothing;
    }
    //-------------------------------------------------------
    state Nothing
    {
        return Nothing;
    }
    //-------------------------------------------------------
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
    //-------------------------------------------------------
    state MovingToContainerSource
    {
        int nPosX;
        int nPosY;
        int nPosZ;
        
        if (IsMoving())
        {
            return MovingToContainerSource;
        }
        else
        {
            nPosX = GetLocationX();
            nPosY = GetLocationY();
            nPosZ = GetLocationZ();
            //sprawdzic czy dojechalismy tam gdzie nalezalo
            if ((nPosX == m_nCurrPutGetX) && (nPosY == m_nCurrPutGetY) && (nPosZ == m_nCurrPutGetZ))
            {
                if (m_nGetContainerFrom == 0)
                {
                    CallGetContainer();
                }
                else
                {
                    assert m_nGetContainerFrom == 1;
                    CallGetSingleContainer(m_nContainerX, m_nContainerY, m_nContainerZ);
                }
                return GettingContainer;
            }
            else
            {
                //kazac mu tam znowu jechac (!moze jakis licznik zeby nie wywolywal w kolko)
                CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                return MovingToContainerSource;
            }
        }
    }
    //-------------------------------------------------------
    state MovingToContainerDestination
    {
        int nPosX;
        int nPosY;
        int nPosZ;
        
        if (IsMoving())
        {
            return MovingToContainerDestination;
        }
        else
        {
            
            nPosX = GetLocationX();
            nPosY = GetLocationY();
            nPosZ = GetLocationZ();
            //sprawdzic czy dojechalismy tam gdzie nalezalo
            if ((nPosX == m_nCurrPutGetX) && (nPosY == m_nCurrPutGetY) && (nPosZ == m_nCurrPutGetZ))
            {
                CallPutContainer();
                return PuttingContainer;
            }
            else
            {
                //kazac mu tam znowu jechac (!moze jakis licznik zeby nie wywolywal w kolko)
                CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                return MovingToContainerDestination;
            }
        }
    }
    //-------------------------------------------------------
    state GettingContainer
    {
        unit uBuilding;
        unit uContainer;
        if (IsGettingContainer())
        {
            return GettingContainer;
        }
        else
        {
            if (HaveContainer())
            {
                //jesli biezemy pojedynczy kontener to teraz znalezc nastepny w poblizu
                if (m_nGetContainerFrom == 1)
                {
                    uContainer = FindSingleContainer();
                    if (uContainer)
                    {
                        
                        m_nContainerX = uContainer.GetLocationX();
                        m_nContainerY = uContainer.GetLocationY();
                        m_nContainerZ = uContainer.GetLocationZ();
                        m_nGetContainerFrom = 1;
                    }
                    else
                    {
                        //juz nie ma nastepnego w poblizu
                        m_nGetContainerFrom = 0;
                    }
                }
                //pojechac do budynku przeznaczenia jesli jest
                if (GetDestinationBuilding() != null)
                {
                    m_nCurrPutGetX = GetDestinationBuildingPutLocationX();
                    m_nCurrPutGetY = GetDestinationBuildingPutLocationY();
                    m_nCurrPutGetZ = GetDestinationBuildingPutLocationZ();
                    CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                    
                    return MovingToContainerDestination;
                }
                else
                {
                    //sprobowac znalezc ten budynek
                    uBuilding = FindContainerRefineryBuilding();
                    if (uBuilding != null)
                    {
                        SetDestinationBuilding(uBuilding);
                        m_nCurrPutGetX = GetDestinationBuildingPutLocationX();
                        m_nCurrPutGetY = GetDestinationBuildingPutLocationY();
                        m_nCurrPutGetZ = GetDestinationBuildingPutLocationZ();
                        CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                        
                        return MovingToContainerDestination;
                    }
                    else
                    {
                        //!!transportBase
                        return Nothing;
                    }
                }
            }
            else
            {
                //z jakiegos powodu nie wzielismy kontenera - poszukac nowej kopalni lub pojedynczego kontenera
                if (m_nGetContainerFrom == 0)
                {
                    uBuilding = GetSourceBuilding();//aby sie upewnic czy zabity (i skasowac referencje w kodzie)
                    if (uBuilding == null)
                    {
                        //najpierw probujemy znalezc kopalnie
                        uBuilding = FindContainerMineBuilding();
                    }
                    if (uBuilding != null)
                    {
                        SetSourceBuilding(uBuilding);
                        m_nCurrPutGetX = GetSourceBuildingTakeLocationX();
                        m_nCurrPutGetY = GetSourceBuildingTakeLocationY();
                        m_nCurrPutGetZ = GetSourceBuildingTakeLocationZ();
                        m_nGetContainerFrom = 0;
                        CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                        
                        return MovingToContainerSource;
                    }
                    else
                    {
                        //probujemy znalezc wolny kontener
                        uContainer = FindSingleContainer();
                        if (uContainer)
                        {
                            m_nContainerX = uContainer.GetLocationX();
                            m_nContainerY = uContainer.GetLocationY();
                            m_nContainerZ = uContainer.GetLocationZ();
                            m_nCurrPutGetX = GetContainerTakeLocationX(m_nContainerX, m_nContainerY, m_nContainerZ);
                            m_nCurrPutGetY = GetContainerTakeLocationY(m_nContainerX, m_nContainerY, m_nContainerZ);
                            m_nCurrPutGetZ = GetContainerTakeLocationZ(m_nContainerX, m_nContainerY, m_nContainerZ);
                            m_nGetContainerFrom = 1;
                            CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                            
                            return MovingToContainerSource;
                        }
                        else
                        {
                            return Nothing;
                        }
                    }
                }
                else
                {
                    assert m_nGetContainerFrom == 1;
                    //najpierw probujemy znalezc nastepny wolny kontener
                    uContainer = FindSingleContainer();
                    if (uContainer)
                    {
                        m_nContainerX = uContainer.GetLocationX();
                        m_nContainerY = uContainer.GetLocationY();
                        m_nContainerZ = uContainer.GetLocationZ();
                        m_nCurrPutGetX = GetContainerTakeLocationX(m_nContainerX, m_nContainerY, m_nContainerZ);
                        m_nCurrPutGetY = GetContainerTakeLocationY(m_nContainerX, m_nContainerY, m_nContainerZ);
                        m_nCurrPutGetZ = GetContainerTakeLocationZ(m_nContainerX, m_nContainerY, m_nContainerZ);
                        m_nGetContainerFrom = 1;
                        CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                        
                        return MovingToContainerSource;
                    }
                    else
                    {
                        uBuilding = GetSourceBuilding();//aby sie upewnic czy zabity (i skasowac referencje w kodzie)
                        if (uBuilding == null)
                        {
                            //probujemy znalezc kopalnie
                            uBuilding = FindContainerMineBuilding();
                        }
                        if (uBuilding != null)
                        {
                            SetSourceBuilding(uBuilding);
                            m_nCurrPutGetX = GetSourceBuildingTakeLocationX();
                            m_nCurrPutGetY = GetSourceBuildingTakeLocationY();
                            m_nCurrPutGetZ = GetSourceBuildingTakeLocationZ();
                            m_nGetContainerFrom = 0;
                            CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                            
                            return MovingToContainerSource;
                        }
                        else
                        {
                            //probujemy znalezc wolny kontener
                            return Nothing;
                        }
                    }
                }
            }
        }
    }
    //-------------------------------------------------------
    state PuttingContainer
    {
        unit uBuilding;
        unit uContainer;
        if (IsPuttingContainer())
        {
            return PuttingContainer;
        }
        else
        {
            if (!HaveContainer())
            {
                //pojechac do kopalni lub po pojedynczy kontener
                if ((m_nGetContainerFrom == 1) && IsContainerInPoint(m_nContainerX, m_nContainerY, m_nContainerZ))
                {
                    m_nGetContainerFrom = 1;
                    m_nCurrPutGetX = GetContainerTakeLocationX(m_nContainerX, m_nContainerY, m_nContainerZ);
                    m_nCurrPutGetY = GetContainerTakeLocationY(m_nContainerX, m_nContainerY, m_nContainerZ);
                    m_nCurrPutGetZ = GetContainerTakeLocationZ(m_nContainerX, m_nContainerY, m_nContainerZ);
                    CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                    
                    return MovingToContainerSource;
                }
                else
                {
                    if (GetSourceBuilding() != null)
                    {
                        m_nCurrPutGetX = GetSourceBuildingTakeLocationX();
                        m_nCurrPutGetY = GetSourceBuildingTakeLocationY();
                        m_nCurrPutGetZ = GetSourceBuildingTakeLocationZ();
                        m_nGetContainerFrom = 0;
                        CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                        
                        return MovingToContainerSource;
                    }
                    else
                    {
                        //probujemy znalezc kopalnie
                        uBuilding = FindContainerMineBuilding();
                        if (uBuilding != null)
                        {
                            SetSourceBuilding(uBuilding);
                            m_nCurrPutGetX = GetSourceBuildingTakeLocationX();
                            m_nCurrPutGetY = GetSourceBuildingTakeLocationY();
                            m_nCurrPutGetZ = GetSourceBuildingTakeLocationZ();
                            m_nGetContainerFrom = 0;
                            CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                            
                            return MovingToContainerSource;
                        }
                        else
                        {
                            //!!jeszcze transportBase
                            //probujemy jeszcze znalezc wolny kontener
                            uContainer = FindSingleContainer();
                            if (uContainer)
                            {
                                m_nContainerX = uContainer.GetLocationX();
                                m_nContainerY = uContainer.GetLocationY();
                                m_nContainerZ = uContainer.GetLocationZ();
                                m_nCurrPutGetX = GetContainerTakeLocationX(m_nContainerX, m_nContainerY, m_nContainerZ);
                                m_nCurrPutGetY = GetContainerTakeLocationY(m_nContainerX, m_nContainerY, m_nContainerZ);
                                m_nCurrPutGetZ = GetContainerTakeLocationZ(m_nContainerX, m_nContainerY, m_nContainerZ);
                                m_nGetContainerFrom = 1;
                                CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                                
                                return MovingToContainerSource;
                            }
                            else
                            {
                                return Nothing;
                            }
                        }
                    }
                }
            }
            else
            {
                uBuilding = GetDestinationBuilding();//aby sie upewnic czy zabity (i skasowac referencje w kodzie)
                if (uBuilding == null)
                {
                    //z jakiegos powodu nie zdolalismy oddac kontenera - znalezc nowa rafinerie
                    uBuilding = FindContainerRefineryBuilding();
                }
                if (uBuilding != null)
                {
                    SetDestinationBuilding(uBuilding);
                    m_nCurrPutGetX = GetDestinationBuildingPutLocationX();
                    m_nCurrPutGetY = GetDestinationBuildingPutLocationY();
                    m_nCurrPutGetZ = GetDestinationBuildingPutLocationZ();
                    CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                    
                    return MovingToContainerDestination;
                }
                else
                {
                    //!!transportBase
                    return Nothing;
                }
            }
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
            //!!wrocic do tego co robilismy
                      if(m_nState==1)
                        {
                            CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                            state MovingToContainerDestination;
                        }
            else 
                        {
                            if(m_nState==2)
                            {
                                CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                                state MovingToContainerSource;
                            }
                            else
                            {
                                if(m_nState==3)
                                {
                                    CallMoveToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                                    state StartMoving;
                                }
                                else
                                    state Nothing;
                            }
                        }
        }
    }
    event OnFreezeForSupplyOrRepair(int nFreezeTicks)
    {
            if(state==GettingContainer || state==PuttingContainer)
            {
            }
            else
            {
                m_nState=0;
                if(state==MovingToContainerDestination)
                    m_nState=1;
                if(state==MovingToContainerSource)
                    m_nState=2;
                if(state==Moving)
                    m_nState=3;
        CallFreeze(nFreezeTicks);
        state Froozen;
            }
      true;
    }
    //------------------------------------------------------- 
    
    //-------------------------------------------------------
    command Initialize()
    {
        m_nGetContainerFrom = 0;
        //pozwolic dzialkom strzelac samym (o ile sa jakies)
        SetCannonFireMode(-1, 1);
        false;
    }
    //-------------------------------------------------------
    command Uninitialize()
    {
        //wykasowac referencje
        SetDestinationBuilding(null);
        SetSourceBuilding(null);
        false;
    }
    //-------------------------------------------------------
    
    /*bez nazwy - wywolywane po kliknieciu kursorem */
    command SetContainerSource(unit uTarget) hidden button "translateCommandSetMine"
    {
        SetSourceBuilding(uTarget);
        m_nGetContainerFrom = 0;
        if (!HaveContainer())
        {
            m_nCurrPutGetX = GetSourceBuildingTakeLocationX();
            m_nCurrPutGetY = GetSourceBuildingTakeLocationY();
            m_nCurrPutGetZ = GetSourceBuildingTakeLocationZ();
            CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
            
            state MovingToContainerSource;
        }
        else
        {
            if (GetDestinationBuilding() != null)
            {
                m_nCurrPutGetX = GetDestinationBuildingPutLocationX();
                m_nCurrPutGetY = GetDestinationBuildingPutLocationY();
                m_nCurrPutGetZ = GetDestinationBuildingPutLocationZ();
                CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                
                state MovingToContainerDestination;
            }
        }
        NextCommand(1);
        true;
    }
    //-------------------------------------------------------
    command GetSingleContainer(unit uTarget) hidden button "translateCommandGetContainer"
    {
        m_nContainerX = uTarget.GetLocationX();
        m_nContainerY = uTarget.GetLocationY();
        m_nContainerZ = uTarget.GetLocationZ();
        m_nGetContainerFrom = 1;
        if (!HaveContainer())
        {
            m_nCurrPutGetX = GetContainerTakeLocationX(m_nContainerX, m_nContainerY, m_nContainerZ);
            m_nCurrPutGetY = GetContainerTakeLocationY(m_nContainerX, m_nContainerY, m_nContainerZ);
            m_nCurrPutGetZ = GetContainerTakeLocationZ(m_nContainerX, m_nContainerY, m_nContainerZ);
            CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
            
            state MovingToContainerSource;
        }
        else
        {
            if (GetDestinationBuilding() != null)
            {
                m_nCurrPutGetX = GetDestinationBuildingPutLocationX();
                m_nCurrPutGetY = GetDestinationBuildingPutLocationY();
                m_nCurrPutGetZ = GetDestinationBuildingPutLocationZ();
                CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                
                state MovingToContainerDestination;
            }
        }
        NextCommand(1);
        true;
    }
    //-------------------------------------------------------
    command SetContainerDestination(unit uTarget) hidden button "translateCommandSetRefinery"
    {
        SetDestinationBuilding(uTarget);
        if (HaveContainer())
        {
            m_nCurrPutGetX = GetDestinationBuildingPutLocationX();
            m_nCurrPutGetY = GetDestinationBuildingPutLocationY();
            m_nCurrPutGetZ = GetDestinationBuildingPutLocationZ();
            CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
            
            state MovingToContainerDestination;
        }
        else
        {
            if (GetSourceBuilding() != null)
            {
                m_nCurrPutGetX = GetSourceBuildingTakeLocationX();
                m_nCurrPutGetY = GetSourceBuildingTakeLocationY();
                m_nCurrPutGetZ = GetSourceBuildingTakeLocationZ();
                m_nGetContainerFrom = 0;
                CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ);
                
                state MovingToContainerSource;
            }
        }
        NextCommand(1);
        true;
    }
    //-------------------------------------------------------
    command Move(int nGx, int nGy, int nLz) hidden button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        m_nMoveToX = nGx;
        m_nMoveToY = nGy;
        m_nMoveToZ = nLz;
        CallMoveToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
        state StartMoving;
        true;
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
    command Stop() button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        CallStopMoving();
        state StartMoving;
        true;
    }
    //-------------------------------------------------------
    command SetLights(int nMode) button lights description "translateCommandStateLightsModeDescription" hotkey priority 204
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
    command SpecialChangeUnitsScript() button "translateCommandChangeScript" description "translateCommandChangeScriptDescription" hotkey priority 254 
    {
        //special command - no implementation
    }
    //-------------------------------------------------------
    /*
    command UserNoParam0() button "Find"
    {
    unit uContainer;
    uContainer = FindSingleContainer();
    if (uContainer)
    {
    m_nContainerX = uContainer.GetLocationX();
    m_nContainerY = uContainer.GetLocationY();
    m_nContainerZ = uContainer.GetLocationZ();
    m_nCurrPutGetX = GetContainerTakeLocationX(m_nContainerX, m_nContainerY, m_nContainerZ);
    m_nCurrPutGetY = GetContainerTakeLocationY(m_nContainerX, m_nContainerY, m_nContainerZ);
    m_nCurrPutGetZ = GetContainerTakeLocationZ(m_nContainerX, m_nContainerY, m_nContainerZ);
    m_nGetContainerFrom = 1;
    CallMoveToPointForce(m_nCurrPutGetX, m_nCurrPutGetY, m_nCurrPutGetZ,);
    
      state MovingToContainerSource;
      }
      }
    */
    //-------------------------------------------------------
    
}
