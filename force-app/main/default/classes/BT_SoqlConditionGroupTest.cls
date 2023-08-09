/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_SoqlConditionGroupTest
* Created by Sagar
*
* Test class for BT_SoqlConditionGroup

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@IsTest
private class BT_SoqlConditionGroupTest {
    
    private static testmethod void testNesting(){
        System.assertEquals(
            '((name = \'acme\' AND ispartner = true) OR rating = \'Hot\')',
            new BT_SoqlOrCondition()
                .add(new BT_SoqlAndCondition()
                    .add(new BT_SoqlFieldCondition('name ',BT_SoqlBuilder.Operator.EQUALS,'acme'))
                    .add(new BT_SoqlFieldCondition('ispartner',BT_SoqlBuilder.Operator.EQUALS,true)))
                .add(new BT_SoqlFieldCondition('rating',BT_SoqlBuilder.Operator.EQUALS,'Hot'))
                .toSoql()
        );   
    }

}