harvester "translateScriptNameHarvester"
{
    
    int m_nMoveToX;
    int m_nMoveToY;
    int m_nMoveToZ;
    int m_nHarvestX;
    int m_nHarvestY;
    int m_nHarvestZ;
    int m_bValidHarvest;
    int m_nDestinationX;
    int m_nDestinationY;
    int m_nDestinationZ;
    int m_bValidDestination;
        int m_nState;
    int  m_nLandCounter;
    
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
    state StartLanding;
    state Landing;
    state WaitForMovingToHarvestPoint;
    state MovingToHarvestPoint;
    state MovingToDestinationBuilding;
    state Harvesting;
    state PuttingResource;
    
    function int Land()
    {
        if (!IsOnGround())
        {
            m_nMoveToX = GetLocationX();
            m_nMoveToY = GetLocationY();
            m_nMoveToZ = GetLocationZ();
            if (!IsFreePoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ))
            {
                if (Rand(2))
                {
                    m_nMoveToX = m_nMoveToX + (Rand(m_nLandCounter) + 1);
                }
                else
                {
                    m_nMoveToX = m_nMoveToX - (Rand(m_nLandCounter) + 1);
                }
                if (Rand(2))
                {
                    m_nMoveToY = m_nMoveToY + (Rand(m_nLandCounter) + 1);
                }
                else
                {
                    m_nMoveToY = m_nMoveToY - (Rand(m_nLandCounter) + 1);
                }
                m_nLandCounter = m_nLandCounter + 1;
                if (IsFreePoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ))
                {
                    CallMoveAndLandToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                }
                else
                {
                    CallMoveLowToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
                }
            }
            else
            {
                CallMoveAndLandToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
            }
            return true;
        }
        else
        {
            return false;
        }
    }
    //-------------------------------------------------------
    function int SetHarvestPoint(int nX, int nY, int nZ)
    {
        m_nHarvestX = nX;
        m_nHarvestY = nY;
        m_nHarvestZ = nZ;
        m_bValidHarvest = true;
        SetCurrentHarvestPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
        return true;
    }
    
    function int FindNewHarvestPoint()
    {
        //znajduje nowy punkt z zasobami i do niego jedzie
        if (FindResource())
        {
            if(Distance(m_nHarvestX,m_nHarvestY,GetFoundResourceX(), GetFoundResourceY())>12
                &&Distance(m_nDestinationX,m_nDestinationY,GetFoundResourceX(), GetFoundResourceY())>10) 
                return false;
            
            SetHarvestPoint(GetFoundResourceX(), GetFoundResourceY(), GetFoundResourceZ());
            return true;
        }
        else
        {
            //m_bValidHarvest zostaje takie jakie bylo
            return false;
        }
    }
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
    state StartLanding
    {
        return Landing, 20;
    }
    //--------------------------------------------------------------------------
    state Landing
    {
        if (IsMoving())
        {
            if ((GetLocationX() == m_nMoveToX) && (GetLocationY() == m_nMoveToY) && (GetLocationZ() == m_nMoveToZ) && 
                !IsFreePoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ))
            {
                if (!Land())
                {
                    NextCommand(1);
                    return Nothing;
                }
            }
            return Landing;
        }
        else
        {
            if (!Land())
            {
                NextCommand(1);
                return Nothing;
            }
            return Landing;
        }
    }
    //--------------------------------------------------------------------------
    
    state WaitForMovingToHarvestPoint
    {
        if (IsHarvesting())
        {
            return WaitForMovingToHarvestPoint;
        }
        else
        {
            //tak dla pewnosci wywolujemy jeszcze raz Call...
            CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
            return MovingToHarvestPoint,40;
        }
    }

    state MovingToHarvestPoint
    {
        int nPosX;
        int nPosY;
        int nPosZ;
        
        
        //=====uwaga latka======= harvesterka staje przed punktem w ktorym ma harwestowac nalezaloby sprawdzic czy tam ktos stoi
        if (IsMoving())
        {
            nPosX = GetLocationX() - m_nHarvestX;
            nPosY = GetLocationY() - m_nHarvestY;
            nPosZ = GetLocationZ() - m_nHarvestZ;
            if(!nPosZ) 
            {
                if(nPosX<0)nPosX=-nPosX;
                if(nPosY<0)nPosY=-nPosY;
                if(nPosX<2 && nPosY<2)
                {
                    CallStopMoving();
                }
            }
        }
        //========================
        if(IsMoving())
        {
            return MovingToHarvestPoint;
        }
        else
        {
            nPosX = GetLocationX();
            nPosY = GetLocationY();
            nPosZ = GetLocationZ();
            if (m_bValidHarvest && (nPosX == m_nHarvestX) && (nPosY == m_nHarvestY) && (nPosZ == m_nHarvestZ))
            {
                //sprawdzic czy jest tu jeszcze zasob
                if (IsResourceInPoint(nPosX, nPosY, nPosZ))
                {
                    CallHarvest();
                    return Harvesting;
                }
                else
                {
                    //znalezc jakis zasob
                    if (FindNewHarvestPoint())
                    {
                        CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
                        return MovingToHarvestPoint;
                    }
                    else
                    {
                        return Nothing;
                    }
                }
            }
            else
            {
                //sprawdzic czy nie ma zasobu tu gdzie stoimy (o ile jest rozny od slotu budynku)
                if (IsResourceInPoint(nPosX, nPosY, nPosZ) &&
                    (!m_bValidDestination || (nPosX != m_nDestinationX) || (nPosY != m_nDestinationY) || (nPosZ != m_nDestinationZ)))
                {
                    //ok kopiemy tu gdzie jestesmy
                    SetHarvestPoint(nPosX, nPosY, nPosZ);
                    CallHarvest();
                    return Harvesting;
                }
                else
                {
                    //znalezc jakis zasob
                    if (FindNewHarvestPoint())
                    {
                        CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
                        return MovingToHarvestPoint;
                    }
                    else
                    {
                        return MovingToHarvestPoint,101;
                    }
                }
            }
        }
    }
    
    state MovingToDestinationBuilding
    {
        int nPosX;
        int nPosY;
        int nPosZ;
        if (IsMoving())
        {
            return MovingToDestinationBuilding;
        }
        else
        {
            nPosX = GetLocationX();
            nPosY = GetLocationY();
            nPosZ = GetLocationZ();
            if (m_bValidDestination && (nPosX == m_nDestinationX) && (nPosY == m_nDestinationY) && (nPosZ == m_nDestinationZ))
            {
                CallPutResource();
                return PuttingResource;
            }
            else
            {
                if (m_bValidDestination)
                {
                    //kazac mu tam znowu jechac (moze jakis licznik (+ zmiana budynku) zeby nie wywolywal tego w kolko)
                    CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                    return MovingToDestinationBuilding,41;
                }
                else
                {
                    return Nothing;
                }
            }
        }
    }
    
    state Harvesting
    {
        unit uBuilding;
        if (IsHarvesting())
        {
            //jeszcze nie skonczyl
            return Harvesting;
        }
        else
        {
            //skonczyl - jedziemy do budynku
            if (HaveFullResources())
            {
                if (m_bValidDestination && (GetHarvesterBuilding() != null))
                {
                    CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                    
                    return MovingToDestinationBuilding;
                }
                else
                {
                    //!!znalezc inny budynek
                    uBuilding = FindHarvesterRefineryBuilding();
                    if (uBuilding != null)
                    {
                        SetHarvesterBuilding(uBuilding);
                        m_nDestinationX = GetHarvesterBuildingPutLocationX();
                        m_nDestinationY = GetHarvesterBuildingPutLocationY();
                        m_nDestinationZ = GetHarvesterBuildingPutLocationZ();
                        m_bValidDestination = true;
                        CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                        
                        return MovingToDestinationBuilding;
                    }
                    else
                    {
                        return Nothing;
                    }
                }
            }
            else
            {
                //nie zdolalismy zapelnic calego pojazdu - znalezc nastepna kratke
                if (FindNewHarvestPoint())
                {
                    CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
                    return MovingToHarvestPoint;
                }
                else
                {
                    //nie ma juz zasobow - pojechac z tym co mamy (o ile mamy) do budynku
                    if (HaveSomeResources())
                    {
                        if (m_bValidDestination && (GetHarvesterBuilding() != null))
                        {
                            CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                            
                            return MovingToDestinationBuilding;
                        }
                        else
                        {
                            //!!znalezc inny budynek
                            uBuilding = FindHarvesterRefineryBuilding();
                            if (uBuilding != null)
                            {
                                SetHarvesterBuilding(uBuilding);
                                m_nDestinationX = GetHarvesterBuildingPutLocationX();
                                m_nDestinationY = GetHarvesterBuildingPutLocationY();
                                m_nDestinationZ = GetHarvesterBuildingPutLocationZ();
                                m_bValidDestination = true;
                                CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                                
                                return MovingToDestinationBuilding;
                            }
                            else
                            {
                                return Nothing;
                            }
                        }
                    }
                    else
                    {
                        return Nothing;
                    }
                }
            }
        }
    }
    
    state PuttingResource
    {
        unit uBuilding;
        if (IsPuttingResource())
        {
            return PuttingResource;
        }
        else
        {
            if (HaveSomeResources())
            {
                //z jakiegos powodu zostaly resource'y
                if (m_bValidDestination && (GetHarvesterBuilding() != null))
                {
                    CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                    
                    return MovingToDestinationBuilding;
                }
                else
                {
                    //!!znalezc inny budynek
                    uBuilding = FindHarvesterRefineryBuilding();
                    if (uBuilding != null)
                    {
                        SetHarvesterBuilding(uBuilding);
                        m_nDestinationX = GetHarvesterBuildingPutLocationX();
                        m_nDestinationY = GetHarvesterBuildingPutLocationY();
                        m_nDestinationZ = GetHarvesterBuildingPutLocationZ();
                        m_bValidDestination = true;
                        CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                        
                        return MovingToDestinationBuilding;
                    }
                    //else przechodzimy dalej
                }
            }
            if (m_bValidHarvest)
            {
                //nie sprawdzamy IsResourceInPoint zeby nie weszla do znajdowania nowego punktu
                //bo moze znalezc ten na ktorym stoimy i zablokowac slot budynku
                //pojechac tam
                CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
                return MovingToHarvestPoint;
            }
            else
            {
                //znalezc nowy punkt
                if (FindNewHarvestPoint())
                {
                    CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
                    return MovingToHarvestPoint;
                }
                else
                {
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
                            CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
                            state MovingToHarvestPoint;
                        }
            else 
                        {
                            if(m_nState==2)
                            {
                                CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                                state MovingToDestinationBuilding;
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
            if(state==WaitForMovingToHarvestPoint || 
                state==PuttingResource || 
                state==Harvesting)
            {
            }
            else
            {
                m_nState=0;
                if(state==MovingToHarvestPoint)
                    m_nState=1;
                if(state==MovingToDestinationBuilding)
                    m_nState=2;
                if(state==Moving)
                    m_nState=3;
        CallFreeze(nFreezeTicks);
        state Froozen;
            }
      true;
        true;
    }
    //------------------------------------------------------- 
    
    command Initialize()
    {
        m_bValidHarvest = false;
        m_bValidDestination = false;
        //pozwolic dzialkom strzelac samym (o ile sa jakies)
        SetCannonFireMode(-1, 1);
        false;
    }
    
    command Uninitialize()
    {
        //wykasowac referencje
        m_bValidHarvest = false;//potrzebne przy przejezdzaniu do innego swiata
        m_bValidDestination = false;
        InvalidateCurrentHarvestPoint();
        SetHarvesterBuilding(null);
        false;
    }
    
    /*bez nazwy - wywolywane po kliknieciu kursorem*/
    command SetHarvestPoint(int nX, int nY, int nZ) hidden button "translateCommandHarvest"
    {
        SetHarvestPoint(nX, nY, nZ);
        if (!HaveFullResources())
        {
            CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
            if (IsHarvesting())
            {
                state WaitForMovingToHarvestPoint;
            }
            else
            {
                state MovingToHarvestPoint;
            }
        }
        else
        {
            if (m_bValidDestination && (GetHarvesterBuilding() != null))
            {
                CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                
                state MovingToDestinationBuilding;
            }
        }
        NextCommand(1);
        true;
    }
    
    /*bez nazwy - wywolywane po kliknieciu kursorem*/
    command SetContainerDestination(unit uObject) hidden button "translateCommandSetRefinery"
    {
        SetHarvesterBuilding(uObject);
        m_nDestinationX = GetHarvesterBuildingPutLocationX();
        m_nDestinationY = GetHarvesterBuildingPutLocationY();
        m_nDestinationZ = GetHarvesterBuildingPutLocationZ();
        m_bValidDestination = true;
        if (HaveSomeResources())
        {
            CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
            
            state MovingToDestinationBuilding;
        }
        else
        {
            if (m_bValidHarvest)
            {
                CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
                
                if (IsHarvesting())
                {
                    state WaitForMovingToHarvestPoint;
                }
                else
                {
                    state MovingToHarvestPoint;
                }
            }
        }
        NextCommand(1);
        true;
    }
    
    command Move(int nGx, int nGy, int nLz) hidden button "translateCommandMove" description "translateCommandMoveDescription" hotkey priority 21
    {
        m_nMoveToX = nGx;
        m_nMoveToY = nGy;
        m_nMoveToZ = nLz;
        CallMoveToPoint(m_nMoveToX, m_nMoveToY, m_nMoveToZ);
        state StartMoving;
        true;
    }
    
    command Enter(unit uEntrance) hidden button "translateCommandEnter"
    {
        m_nMoveToX = GetEntranceX(uEntrance);
        m_nMoveToY = GetEntranceY(uEntrance);
        m_nMoveToZ = GetEntranceZ(uEntrance);
        CallMoveInsideObject(uEntrance);
        state StartMoving;
        true;
    }
    
    command Stop() button "translateCommandStop" description "translateCommandStopDescription" hotkey priority 20
    {
        CallStopMoving();
        state StartMoving;
        true;
    }
   //--------------------------------------------------------------------------
        command Land() button "translateCommandLand" description "translateCommandLandDescription" hotkey priority 31 
    {
        if(state==Harvesting)return;
                if(state==PuttingResource)return;
        m_nLandCounter = 1;
        if (Land())
        {
            state StartLanding;
        }
        else
        {
            NextCommand(1);
        }
    }
 
    //--------------------------------------------------------------------------
    command SetLights(int nMode) button lights description "translateCommandStateLightsModeDescription" hotkey priority 204
    {
        if (nMode == -1)
        {
            lights = (lights + 1) % 3;
        }
        else
        {
            lights = nMode;
        }
        SetLightsMode(lights);
    }
    
    
    //-------------------------------------------------------
    command SpecialChangeUnitsScript() button "translateCommandChangeScript" description "translateCommandChangeScriptDescription" hotkey priority 254 
    {
        //special command - no implementation
    }
    /*
    command UserNoParam0() button "Find"
    {
    if (FindNewHarvestPoint())
    {
    CallMoveAndLandToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
    state MovingToHarvestPoint;
    }
    true;
    }
    */
}
