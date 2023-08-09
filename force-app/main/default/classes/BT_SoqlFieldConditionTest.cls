/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_SoqlFieldConditionTest
* Created by Sagar
*
* Test class for BT_SoqlFieldCondition

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@IsTest
private class BT_SoqlFieldConditionTest {

    private static testmethod void testInvalidField(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlFieldCondition('  ',null,null);
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(
            exceptionCaught == true, 
            'empty field param to FieldCondition constructor did not throw BT_ApplicationException');
    }

    private static testmethod void testInvalidOperator_INCLUDES(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.INCLUDES,null);
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testInvalidOperator_EXCLUDES(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.EXCLUDES,null);
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testInvalidOperator_INX(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.INX,null);
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testInvalidOperator_NOT_IN(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.NOT_IN,null);
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testNullValue(){
        System.assertEquals('name = null',new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.EQUALS,null).toSoql());   
    }

    private static testmethod void testStringValue(){
        System.assertEquals('name = \'acme\'',new BT_SoqlFieldCondition().field('name').equals('acme').toSoql());   
        System.assertEquals('name = \'acme\'',new BT_SoqlFieldCondition('name').equals('acme').toSoql());   
        System.assertEquals('name = \'acme\'',new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.EQUALS,'acme').toSoql());   
        System.assertEquals('name like \'%acme%\'',new BT_SoqlFieldCondition().field('name').likex('%acme%').toSoql());   
        System.assertEquals('name like \'%acme%\'',new BT_SoqlFieldCondition('name').likex('%acme%').toSoql());   
        System.assertEquals('name like \'%acme%\'',new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.LIKEX,'%acme%').toSoql());   
    }

    private static testmethod void testBooleanValue(){
        System.assertEquals('ispartner = true',new BT_SoqlFieldCondition('ispartner',BT_SoqlBuilder.Operator.EQUALS,true).toSoql());   
        System.assertEquals('ispartner = false',new BT_SoqlFieldCondition('ispartner',BT_SoqlBuilder.Operator.EQUALS,false).toSoql());   
    }

    private static testmethod void testIntegerValue(){
        System.assertEquals('employees = 1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.EQUALS,1).toSoql());   
        System.assertEquals('employees != 1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.NOT_EQUALS,1).toSoql());   
        System.assertEquals('employees < 1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.LESS_THAN,1).toSoql());   
        System.assertEquals('employees > 1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.GREATER_THAN ,1).toSoql());   
        System.assertEquals('employees <= 1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.LESS_THAN_OR_EQUAL_TO,1).toSoql());   
        System.assertEquals('employees >= 1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.GREATER_THAN_OR_EQUAL_TO,1).toSoql());   
    }

    private static testmethod void testDoubleValue(){
        System.assertEquals('employees = 1.1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.EQUALS,1.1).toSoql());   
        System.assertEquals('employees != 1.1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.NOT_EQUALS,1.1).toSoql());   
        System.assertEquals('employees < 1.1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.LESS_THAN,1.1).toSoql());   
        System.assertEquals('employees > 1.1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.GREATER_THAN ,1.1).toSoql());   
        System.assertEquals('employees <= 1.1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.LESS_THAN_OR_EQUAL_TO,1.1).toSoql());   
        System.assertEquals('employees >= 1.1',new BT_SoqlFieldCondition('employees',BT_SoqlBuilder.Operator.GREATER_THAN_OR_EQUAL_TO,1.1).toSoql());   
    }

    private static testmethod void testDateValue(){
        System.assertEquals('createddate < 1960-02-17',new BT_SoqlFieldCondition('createddate',BT_SoqlBuilder.Operator.LESS_THAN,Date.newinstance(1960, 2, 17)).toSoql());   
    }

    private static testmethod void testDatetimeValue(){
        System.assertEquals('createddate >= 2008-12-01T12:00:00Z',new BT_SoqlFieldCondition('createddate',BT_SoqlBuilder.Operator.GREATER_THAN_OR_EQUAL_TO,Datetime.newInstance(2008, 12, 1)).toSoql());   
    }

    private static testmethod void testOperatorMethod_equals(){
        System.assertEquals('x = 1',new BT_SoqlFieldCondition().field('x').equals(1).toSoql());   
        System.assertEquals('x = 1',new BT_SoqlFieldCondition('x').equals(1).toSoql());   
        System.assertEquals('x = 1',new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.EQUALS,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_notEquals(){
        System.assertEquals('x != 1',new BT_SoqlFieldCondition().field('x').notEquals(1).toSoql());   
        System.assertEquals('x != 1',new BT_SoqlFieldCondition('x').notEquals(1).toSoql());   
        System.assertEquals('x != 1',new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.NOT_EQUALS,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_lessThan(){
        System.assertEquals('x < 1',new BT_SoqlFieldCondition().field('x').lessThan(1).toSoql());   
        System.assertEquals('x < 1',new BT_SoqlFieldCondition('x').lessThan(1).toSoql());   
        System.assertEquals('x < 1',new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.LESS_THAN,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_lessThanOrEqualTo(){
        System.assertEquals('x <= 1',new BT_SoqlFieldCondition().field('x').lessThanOrEqualTo(1).toSoql());   
        System.assertEquals('x <= 1',new BT_SoqlFieldCondition('x').lessThanOrEqualTo(1).toSoql());   
        System.assertEquals('x <= 1',new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.LESS_THAN_OR_EQUAL_TO,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_greaterThan(){
        System.assertEquals('x > 1',new BT_SoqlFieldCondition().field('x').greaterThan(1).toSoql());   
        System.assertEquals('x > 1',new BT_SoqlFieldCondition('x').greaterThan(1).toSoql());   
        System.assertEquals('x > 1',new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.GREATER_THAN,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_greaterThanOrEqualTo(){
        System.assertEquals('x >= 1',new BT_SoqlFieldCondition().field('x').greaterThanOrEqualTo(1).toSoql());   
        System.assertEquals('x >= 1',new BT_SoqlFieldCondition('x').greaterThanOrEqualTo(1).toSoql());   
        System.assertEquals('x >= 1',new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.GREATER_THAN_OR_EQUAL_TO,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_likex(){
        System.assertEquals('x like \'acme\'',new BT_SoqlFieldCondition().field('x').likex('acme').toSoql());   
        System.assertEquals('x like \'acme\'',new BT_SoqlFieldCondition('x').likex('acme').toSoql());   
        System.assertEquals('x like \'acme\'',new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.LIKEX,'acme').toSoql());   

        System.assertEquals('x like \'%acme%\'',new BT_SoqlFieldCondition().field('x').likex('acme').toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators()));   
        System.assertEquals('x like \'%acme%\'',new BT_SoqlFieldCondition('x').likex('acme').toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators()));   
        System.assertEquals('x like \'%acme%\'',new BT_SoqlFieldCondition('x',BT_SoqlBuilder.Operator.LIKEX,'acme').toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators()));   
    }

}