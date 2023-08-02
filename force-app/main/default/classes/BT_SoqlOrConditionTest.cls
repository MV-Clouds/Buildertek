/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_SoqlOrConditionTest
* Created by Sagar
*
* Test class for BT_SoqlOrCondition

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@IsTest
private class BT_SoqlOrConditionTest {
    
    private static testmethod void testOrConditionEmpty(){
        System.assertEquals('',new BT_SoqlOrCondition().toSoql());   
    }

    private static testmethod void testNestedOrConditionEmpty(){
        System.assertEquals('',new BT_SoqlOrCondition().add(new BT_SoqlOrCondition()).add(new BT_SoqlOrCondition()).toSoql());   
    }

    private static testmethod void testOrConditionWithOneConditionOnly(){
        System.assertEquals(
            'name = \'acme\'',
            new BT_SoqlOrCondition()
                .add(new BT_SoqlFieldCondition('name ',BT_SoqlBuilder.Operator.EQUALS,'acme'))
                .toSoql());   
    }

    private static testmethod void testTwoFieldConditions(){
        System.assertEquals(
            '(name = \'acme\' OR ispartner = true)',
            new BT_SoqlOrCondition()
                .add(new BT_SoqlFieldCondition('name ',BT_SoqlBuilder.Operator.EQUALS,'acme'))
                .add(new BT_SoqlFieldCondition('ispartner',BT_SoqlBuilder.Operator.EQUALS,true))
                .toSoql()
        );   
    }

}