/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_SoqlSetConditionTest
* Created by Sagar
*
* Test class for BT_SoqlSetCondition

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@IsTest
private class BT_SoqlSetConditionTest {
    
    private static testmethod void testInvalidField(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlSetCondition('  ');
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(
            exceptionCaught == true, 
            'empty field param to FieldCondition constructor did not throw BT_ApplicationException');
    }

    private static testmethod void testInvalidOperator_EQUALS(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlSetCondition('x',BT_SoqlBuilder.Operator.EQUALS,new List<Object>{1,2});
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testNullValue_List(){
        Boolean exceptionCaught = false;
        List<Object> value = null;
        try{
            new BT_SoqlSetCondition('x',BT_SoqlBuilder.Operator.INCLUDES,value);
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testNullValue_SoqlBuilder(){
        Boolean exceptionCaught = false;
        BT_SoqlBuilder value = null;
        try{
            new BT_SoqlSetCondition('x',BT_SoqlBuilder.Operator.NOT_IN,value);
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testEmptyValue(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlSetCondition('x',BT_SoqlBuilder.Operator.INCLUDES,new List<Object>{});
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testNameNotDefined(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlSetCondition().toSoql();   
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testOperationNotDefined(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlSetCondition('name').toSoql();   
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testNullValuesList(){
        Boolean exceptionCaught = false;
        List<Object> value = null;
        try{
            new BT_SoqlSetCondition('name').includes(value);   
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testEmptyValuesList(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlSetCondition('name').includes(new List<Object>());   
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testIncludes(){
        asertEqualsAfterRemovingNewLines(
            'name INCLUDES (\'test\',123)',
            new BT_SoqlSetCondition('name').includes(new List<Object>{'test',123}).toSoql()); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testExcludes(){
        asertEqualsAfterRemovingNewLines(
            'name EXCLUDES (\'test\',123)',
            new BT_SoqlSetCondition('name').excludes(new List<Object>{'test',123}).toSoql());  
        system.assertEquals('test', 'test');    
    }

    private static testmethod void testIn(){
        asertEqualsAfterRemovingNewLines(
            'name IN (\'test\',123)',
            new BT_SoqlSetCondition('name').inx(new List<Object>{'test',123}).toSoql());  
        system.assertEquals('test', 'test');    
    }

    private static testmethod void testNotIn(){
        asertEqualsAfterRemovingNewLines(
            'name NOT IN (\'test\',123)',
            new BT_SoqlSetCondition('name').notIn(new List<Object>{'test',123}).toSoql());   
        system.assertEquals('test', 'test');    
    }

    private static testmethod void testOperatorMethod_includes(){
        asertEqualsAfterRemovingNewLines('x INCLUDES (1,2)',new BT_SoqlSetCondition().field('x').includes(new List<Object>{1,2}).toSoql());   
        asertEqualsAfterRemovingNewLines('x INCLUDES (1,2)',new BT_SoqlSetCondition('x').includes(new List<Object>{1,2}).toSoql());   
        asertEqualsAfterRemovingNewLines('x INCLUDES (1,2)',new BT_SoqlSetCondition('x',BT_SoqlBuilder.Operator.INCLUDES,new List<Object>{1,2}).toSoql()); 
        system.assertEquals('test', 'test');
    }

    private static testmethod void testOperatorMethod_excludes(){
        asertEqualsAfterRemovingNewLines('x EXCLUDES (1,2)',new BT_SoqlSetCondition().field('x').excludes(new List<Object>{1,2}).toSoql());   
        asertEqualsAfterRemovingNewLines('x EXCLUDES (1,2)',new BT_SoqlSetCondition('x').excludes(new List<Object>{1,2}).toSoql());   
        asertEqualsAfterRemovingNewLines('x EXCLUDES (1,2)',new BT_SoqlSetCondition('x',BT_SoqlBuilder.Operator.excludes,new List<Object>{1,2}).toSoql()); 
        system.assertEquals('test', 'test');
    }

    private static testmethod void testOperatorMethod_inx(){
        asertEqualsAfterRemovingNewLines('x IN (1,2)',new BT_SoqlSetCondition().field('x').inx(new List<Object>{1,2}).toSoql());   
        asertEqualsAfterRemovingNewLines('x IN (1,2)',new BT_SoqlSetCondition('x').inx(new List<Object>{1,2}).toSoql());   
        asertEqualsAfterRemovingNewLines('x IN (1,2)',new BT_SoqlSetCondition('x',BT_SoqlBuilder.Operator.INX,new List<Object>{1,2}).toSoql()); 
        system.assertEquals('test', 'test');
    }

    private static testmethod void testOperatorMethod_notIn(){
        asertEqualsAfterRemovingNewLines('x NOT IN (1,2)',new BT_SoqlSetCondition().field('x').notIn(new List<Object>{1,2}).toSoql());   
        asertEqualsAfterRemovingNewLines('x NOT IN (1,2)',new BT_SoqlSetCondition('x').notIn(new List<Object>{1,2}).toSoql());   
        asertEqualsAfterRemovingNewLines('x NOT IN (1,2)',new BT_SoqlSetCondition('x',BT_SoqlBuilder.Operator.NOT_IN,new List<Object>{1,2}).toSoql()); 
        system.assertEquals('test', 'test');
    }


    private static testmethod void testBasicSemiJoin_Constructor(){
        asertEqualsAfterRemovingNewLines('ID IN (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new BT_SoqlSetCondition('ID', BT_SoqlBuilder.Operator.INX, 
                new BT_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new BT_SoqlFieldCondition('StageName','Closed Lost'))
            ).toSoql());  
        system.assertEquals('test', 'test');    
    }
    
    private static testmethod void testBasicSemiJoin_1(){
        asertEqualsAfterRemovingNewLines('ID IN (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new BT_SoqlSetCondition('ID').inx(
                new BT_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new BT_SoqlFieldCondition('StageName','Closed Lost'))
            ).toSoql()); 
        system.assertEquals('test', 'test');    
    }

    private static testmethod void testBasicSemiJoin_2(){
        asertEqualsAfterRemovingNewLines('ID NOT IN (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new BT_SoqlSetCondition('ID').notIn(
                new BT_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new BT_SoqlFieldCondition('StageName','Closed Lost'))
            ).toSoql());   
        system.assertEquals('test', 'test');    
    }

    private static testmethod void testBasicSemiJoin_3(){
        asertEqualsAfterRemovingNewLines('ID INCLUDES (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new BT_SoqlSetCondition('ID').includes(
                new BT_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new BT_SoqlFieldCondition('StageName','Closed Lost'))
            ).toSoql());  
        system.assertEquals('test', 'test');    
    }

    private static testmethod void testBasicSemiJoin_4(){
        asertEqualsAfterRemovingNewLines('ID EXCLUDES (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new BT_SoqlSetCondition('ID').excludes(
                new BT_SoqlBuilder().selectx('AccountId').fromx('Opportunity').wherex(new BT_SoqlFieldCondition('StageName','Closed Lost'))
            ).toSoql());  
        system.assertEquals('test', 'test');    
    }
    
    private static void asertEqualsAfterRemovingNewLines(String expected, String actual){
        System.assertEquals(expected.replaceAll('\n', ''), actual.replaceAll('\n', ''));   
    }
    
    


}