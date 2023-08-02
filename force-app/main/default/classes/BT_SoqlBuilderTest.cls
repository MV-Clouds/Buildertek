/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_SoqlBuilderTest
* Created by Sagar
*
* Test class for BT_SoqlBuilder

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@IsTest
private class BT_SoqlBuilderTest {

    private static testmethod void testLimit(){
        assertEquals(
            'SELECT id FROM account LIMIT 1000',
            new BT_SoqlBuilder().selectx('id').fromx('account').limitx(1000).toSoql()); 
            system.assertEquals('test', 'test');
    }

    private static testmethod void testNoObjectName(){
        Boolean exceptionCaught = false;
        try{
            new BT_SoqlBuilder().toSoql();
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testBadField1(){
        Boolean exceptionCaught = false;
        try{
            String aNull = null;
            new BT_SoqlBuilder().selectx(aNull);
        }catch(BT_ApplicationException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'BT_ApplicationException not thrown');
    }

    private static testmethod void testBasicSelect(){
        assertEquals(
            'SELECT id,name FROM account WHERE name like \'%acme%\'',
            new BT_SoqlBuilder()
                .selectx(new List<String>{'id','name'})
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.LIKEX,'%acme%'))
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testBasicSelectStringListSelectx(){
        assertEquals(
            'SELECT id,name FROM account WHERE name like \'%acme%\'',
            new BT_SoqlBuilder()
                .selectx(new List<String>{'id','name'})
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.LIKEX,'%acme%'))
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testOption_wildcardStringsInLikeOperators(){
        assertEquals(
            'SELECT id FROM account WHERE name like \'%acme%\'',
            new BT_SoqlBuilder()
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.LIKEX,'acme'))
                .toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators()));   
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testOption_wildcardStringsInLikeOperatorsAlreadyWildcarded(){
        assertEquals(
            'SELECT id FROM account WHERE name like \'%acme%\'',
            new BT_SoqlBuilder()
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.LIKEX,'%acme%'))
                .toSoql(new BT_SoqlOptions().wildcardStringsInLikeOperators())); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testOption_doNotWildcardStringsInLikeOperators(){
        assertEquals(
            'SELECT id FROM account WHERE name like \'acme\'',
            new BT_SoqlBuilder()
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.LIKEX,'acme'))
                .toSoql(new BT_SoqlOptions().doNotWildcardStringsInLikeOperators()));  
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testOption_escapeSingleQuotes(){
        assertEquals(
            'SELECT id FROM account WHERE name like \'Bill\\\'s Chop Shop\'',
            new BT_SoqlBuilder()
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.LIKEX,'Bill\'s Chop Shop'))
                .toSoql(new BT_SoqlOptions().escapeSingleQuotes())); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testOption_doNotEscapeSingleQuotes(){
        assertEquals(
            'SELECT id FROM account WHERE name like \'Bill\'s Chop Shop\'',
            new BT_SoqlBuilder()
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.LIKEX,'Bill\'s Chop Shop'))
                .toSoql(new BT_SoqlOptions().doNotEscapeSingleQuotes()));
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testNestedConditions(){
        assertEquals(
            'SELECT id,name FROM account WHERE ((name like \'%acme%\' OR description = \'yo\') AND ispartner = true) ORDER BY name DESC LIMIT 500',
            new BT_SoqlBuilder()
                .selectx(new List<String>{'id','name'})
                .fromx('account')
                .wherex(
                    new BT_SoqlAndCondition()
                    .add(
                        new BT_SoqlOrCondition()
                        .add(new BT_SoqlFieldCondition('name',BT_SoqlBuilder.Operator.LIKEX,'%acme%'))
                        .add(new BT_SoqlFieldCondition('description',BT_SoqlBuilder.Operator.EQUALS,'yo'))
                    )
                    .add(new BT_SoqlFieldCondition('ispartner',BT_SoqlBuilder.Operator.EQUALS,true))
                ).orderByx(new BT_SoqlOrderBy('name').descending())
                .limitx(500)
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testOrderBy1(){
        assertEquals(
            'SELECT id FROM account ORDER BY name',
            new BT_SoqlBuilder()
                .fromx('account')
                .orderByx(new List<BT_SoqlOrderBy>{new BT_SoqlOrderBy('name')})
                .toSoql());   
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testOrderBy2(){
        assertEquals(
            'SELECT id FROM account ORDER BY name ASC NULLS LAST, rating DESC, industry DESC NULLS FIRST',
            new BT_SoqlBuilder()
                .fromx('account')
                .orderByx(new List<BT_SoqlOrderBy>{
                    new BT_SoqlOrderBy('name').ascending().nullsLast()
                    ,new BT_SoqlOrderBy('rating').descending()
                    ,new BT_SoqlOrderBy('industry').descending().nullsFirst()})
                .toSoql());  
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testANullOrderBy(){
        assertEquals(
            'SELECT id FROM account ORDER BY name',
            new BT_SoqlBuilder()
                .fromx('account')
                .orderByx(new List<BT_SoqlOrderBy>{
                    new BT_SoqlOrderBy('name')
                    ,null})
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }


    private static testmethod void testGroupBy(){
        assertEquals(
            'SELECT id FROM account GROUP BY name',
            new BT_SoqlBuilder()
                .fromx('account')
                .groupByx('name')
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }


    private static testmethod void testSelectCount1(){
        assertEquals(
            'SELECT count() from Contact c, c.Account a WHERE a.name = \'MyriadPubs\'',
            new BT_SoqlBuilder()
                .selectCount()
                .fromx('Contact c, c.Account a')
                .wherex(new BT_SoqlFieldCondition('a.name','MyriadPubs'))
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testSelectCount2(){
        assertEquals(
            'SELECT count() FROM Account WHERE Name LIKE \'a%\'',
            new BT_SoqlBuilder()
                .selectCount()
                .fromx('Account')
                .wherex(new BT_SoqlFieldCondition('Name',BT_SoqlBuilder.Operator.LIKEX,'a%'))
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testSelectCountWithArg(){
        assertEquals(
            'SELECT count(Id) FROM Account WHERE Name LIKE \'a%\'',
            new BT_SoqlBuilder()
                .selectCount('Id')
                .fromx('Account')
                .wherex(new BT_SoqlFieldCondition('Name',BT_SoqlBuilder.Operator.LIKEX,'a%'))
                .toSoql());     
        system.assertEquals('test', 'test');        
    }  

    private static testmethod void testSelectAverage(){
        assertEquals(
            'SELECT AVG(Amount) FROM Account WHERE Name LIKE \'a%\'',
            new BT_SoqlBuilder()
                .selectAveragex('Amount')
                .fromx('Account')
                .wherex(new BT_SoqlFieldCondition('Name',BT_SoqlBuilder.Operator.LIKEX,'a%'))
                .toSoql());    
        system.assertEquals('test', 'test');        
    }    


    private static testmethod void testSelectMax(){  
        assertEquals(
            'SELECT Max(Amount) FROM Account WHERE Name LIKE \'a%\'',
            new BT_SoqlBuilder()
                .selectMaxx('Amount')
                .fromx('Account')
                .wherex(new BT_SoqlFieldCondition('Name',BT_SoqlBuilder.Operator.LIKEX,'a%'))
                .toSoql());    
        system.assertEquals('test', 'test');        
    }  

    private static testmethod void testSelectMin(){
        assertEquals(
            'SELECT Min(Amount) FROM Account WHERE Name LIKE \'a%\'',
            new BT_SoqlBuilder()
                .selectMinx('Amount')
                .fromx('Account')
                .wherex(new BT_SoqlFieldCondition('Name',BT_SoqlBuilder.Operator.LIKEX,'a%'))
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }  

    private static testmethod void testSelectSumx(){
        assertEquals(
            'SELECT Sum(Amount) FROM Account WHERE Name LIKE \'a%\'',
            new BT_SoqlBuilder()
                .selectSumx('Amount')
                .fromx('Account')
                .wherex(new BT_SoqlFieldCondition('Name',BT_SoqlBuilder.Operator.LIKEX,'a%'))
                .toSoql());  
        system.assertEquals('test', 'test');        
    }  


    private static testmethod void testSelectNullCondition(){
        assertEquals(
            'SELECT Id FROM Case WHERE Contact.Lastname = null',
            new BT_SoqlBuilder()
                .fromx('Case')
                .wherex(new BT_SoqlFieldCondition('Contact.Lastname',null))
                .toSoql());  
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testIncludes(){
        assertEquals(
            'SELECT Id,MSP1__c from CustObj__c WHERE MSP1__c INCLUDES (\'AAA;BBB\',\'CCC\')',
            new BT_SoqlBuilder()
                .selectx(new List<String>{'id','MSP1__c'})
                .fromx('CustObj__c')
                .wherex(new BT_SoqlSetCondition('MSP1__c').includes(new List<String>{'AAA;BBB','CCC'}))
                .toSoql());
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testExcludes(){
        assertEquals(
            'SELECT Id,MSP1__c from CustObj__c WHERE MSP1__c EXCLUDES (\'AAA;BBB\',\'CCC\')',
            new BT_SoqlBuilder()
                .selectx(new List<String>{'id','MSP1__c'})
                .fromx('CustObj__c')
                .wherex(new BT_SoqlSetCondition('MSP1__c').excludes(new List<String>{'AAA;BBB','CCC'}))
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testIn(){
        assertEquals(
            'SELECT id FROM ACCOUNT WHERE BillingState IN (\'California\',\'New York\')',
            new BT_SoqlBuilder()
                .fromx('ACCOUNT')
                .wherex(new BT_SoqlSetCondition('BillingState').inx(new List<String>{'California','New York'}))
                .toSoql()); 
        system.assertEquals('test', 'test');        
    }

    private static testmethod void testNotIn(){
        assertEquals(
            'SELECT id FROM ACCOUNT WHERE BillingState NOT IN (\'California\',\'New York\')',
            new BT_SoqlBuilder()
                .fromx('ACCOUNT')
                .wherex(new BT_SoqlSetCondition('BillingState').notIn(new List<String>{'California','New York'}))
                .toSoql());  
        system.assertEquals('test', 'test');        
    }

    private static testmethod void test_EQUALS_1(){
        assertEquals(
            'SELECT name,employees FROM account WHERE employees = 10',
            new BT_SoqlBuilder()
                .selectx('name')
                .selectx(new Set<Object>{'employees'})
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('employees', 10))
                .toSoql());
        system.assertEquals('test', 'test');        
    }

    private static testmethod void test_EQUALS_1_SetString(){
        assertEquals(
            'SELECT name,employees FROM account WHERE employees = 10',
            new BT_SoqlBuilder()
                .selectx('name')
                .selectx(new Set<String>{'employees'})
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('employees', 10))
                .toSoql());
        system.assertEquals('test', 'test');        
    }

    private static testmethod void test_EQUALS_2(){
        assertEquals(
            'SELECT name,employees FROM account WHERE employees = 10',
            new BT_SoqlBuilder()
                .selectx('name')
                .selectx('employees')
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition('employees').equals(10))
                .toSoql());
        system.assertEquals('test', 'test');        
    }

    private static testmethod void test_EQUALS_3(){
        assertEquals(
            'SELECT name,employees FROM account WHERE employees = 10',
            new BT_SoqlBuilder()
                .selectx(new Set<Object>{'name','employees'})
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition().field('employees').equals(10))
                .toSoql());
        system.assertEquals('test', 'test');        
    }

    private static testmethod void test_EQUALS_3_SetString(){
        assertEquals(
            'SELECT name,employees FROM account WHERE employees = 10',
            new BT_SoqlBuilder()
                .selectx(new Set<String>{'name','employees'})
                .fromx('account')
                .wherex(new BT_SoqlFieldCondition().field('employees').equals(10))
                .toSoql());
        system.assertEquals('test', 'test');            
    }

    private static testmethod void test_INX_1(){
        assertEquals(
            'SELECT id,industry FROM account WHERE industry in (\'Agriculture\',\'Apparel\')',
            new BT_SoqlBuilder()
                .selectx(new List<Object>{'id','industry'})
                .fromx('account')
                .wherex(new BT_SoqlSetCondition('industry', BT_SoqlBuilder.Operator.INX, new List<Object>{'Agriculture','Apparel'}))
                .toSoql());
        system.assertEquals('test', 'test');        
    }

    private static testmethod void test_INX_1_ListString(){
        assertEquals(
            'SELECT id,industry FROM account WHERE industry in (\'Agriculture\',\'Apparel\')',
            new BT_SoqlBuilder()
                .selectx(new List<String>{'id','industry'})
                .fromx('account')
                .wherex(new BT_SoqlSetCondition('industry', BT_SoqlBuilder.Operator.INX, new List<Object>{'Agriculture','Apparel'}))
                .toSoql());
        system.assertEquals('test', 'test');        
    }

    private static testmethod void test_INX_2(){
        assertEquals(
            'SELECT id,industry FROM account WHERE industry in (\'Agriculture\',\'Apparel\')',
            new BT_SoqlBuilder()
                .selectx(new List<Object>{'id','industry'})
                .fromx('account')
                .wherex(new BT_SoqlSetCondition('industry').inx(new List<Object>{'Agriculture','Apparel'}))
                .toSoql());
        system.assertEquals('test', 'test');        
    }

    private static testmethod void test_INX_3(){
        assertEquals(
            'SELECT id,industry FROM account WHERE industry in (\'Agriculture\',\'Apparel\')',
            new BT_SoqlBuilder()
                .selectx(new List<Object>{'id','industry'})
                .fromx('account')
                .wherex(new BT_SoqlSetCondition().field('industry').inx(new List<Object>{'Agriculture','Apparel'}))
                .toSoql());
        system.assertEquals('test', 'test');        
    }
    
    private static void assertEquals(String expected, String actual){
        expected = expected.trim().toLowerCase().replaceAll('\n','');
        actual = actual.trim().toLowerCase().replaceAll('\n','');
        System.assert(
            expected.equalsIgnoreCase(actual),
            'Assertion failed, the following two SOQLs are not equal.  Expected: ' + expected + ', Actual: ' + actual);
    }
}