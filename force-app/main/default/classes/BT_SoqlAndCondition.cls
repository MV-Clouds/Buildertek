/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_SoqlAndCondition
* Created by Sagar: 04/08/2017
*
* Class for SOQL and condition
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_SoqlAndCondition extends BT_SoqlConditionGroup{
    
    public BT_SoqlAndCondition(){
        super('AND');
    }
    
}