/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_SoqlAndConditionTest
* Created by Sagar
*
* Test class for BT_SoqlAndCondition

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@IsTest
private class BT_SoqlAndConditionTest {
    
    private static testmethod void testAndConditionEmpty(){
        System.assertEquals('',new BT_SoqlAndCondition().toSoql());   
    }

    private static testmethod void testNestedAndConditionEmpty(){
        System.assertEquals('',new BT_SoqlAndCondition().add(new BT_SoqlAndCondition()).add(new BT_SoqlAndCondition()).toSoql());   
    }

    private static testmethod void testAndConditionWithOneConditionOnly(){
        System.assertEquals(
            'name = \'acme\'',
            new BT_SoqlAndCondition()
                .add(new BT_SoqlFieldCondition('name ',BT_SoqlBuilder.Operator.EQUALS,'acme'))
                .toSoql());   
    }

    private static testmethod void testTwoFieldConditions(){
        System.assertEquals(
            '(name = \'acme\' AND ispartner = true)',
            new BT_SoqlAndCondition()
                .add(new BT_SoqlFieldCondition('name ',BT_SoqlBuilder.Operator.EQUALS,'acme'))
                .add(new BT_SoqlFieldCondition('ispartner',BT_SoqlBuilder.Operator.EQUALS,true))
                .toSoql()
        );   
    }

}