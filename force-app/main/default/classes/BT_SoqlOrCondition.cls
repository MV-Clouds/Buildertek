/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_SoqlOrCondition
* Created by Sagar: 04/08/2017
*
* Class for SOQL or condition
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_SoqlOrCondition extends BT_SoqlConditionGroup{
    
    public BT_SoqlOrCondition(){
        super('OR');
    }
    
}