/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_SoqlUtilsTestClass
* Created by Sagar
*
* Test class for BT_SoqlUtils

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
private class BT_SoqlUtilsTestClass {
    
    static testMethod void testBuildSelectClause() {       
        String selectClause = BT_SoqlUtils.buildSelectClause('Folder__c', null, true);
        System.assertEquals(0, selectClause.length());
        
        selectClause = BT_SoqlUtils.buildSelectClause('Folder__c', new List<String>{'Id', 'name'}, true);
    }  
    
    static testMethod void testBuildOrderByClause() {
        String orderByClause = BT_SoqlUtils.buildOrderByClause(null, false);
        System.assertEquals(0, orderByClause.length());
        
        orderByClause = BT_SoqlUtils.buildOrderByClause(new List<String>{'Name', 'Size__c'}, false);
        System.assertEquals(' ORDER BY Name, Size__c DESC', orderByClause);
    }      
    
    static testMethod void testSOQLOrderByClause(){
        String orderByDirective = 'field1';
        String SOQLOrderByClause = BT_SoqlUtils.buildSOQLOrderByClause(orderByDirective);
        System.assertEquals('ORDER BY field1 ASC', SOQLOrderByClause);
                
        orderByDirective = 'field1~field2';
        SOQLOrderByClause = BT_SoqlUtils.buildSOQLOrderByClause(orderByDirective);
        System.assertEquals('ORDER BY field1 ASC, field2 ASC', SOQLOrderByClause);
                
        orderByDirective = 'field1#ASC~field2';
        SOQLOrderByClause = BT_SoqlUtils.buildSOQLOrderByClause(orderByDirective);
        System.assertEquals('ORDER BY field1 ASC, field2 ASC', SOQLOrderByClause);
                
        orderByDirective = 'field1#DESC~field2';
        SOQLOrderByClause = BT_SoqlUtils.buildSOQLOrderByClause(orderByDirective);
        System.assertEquals('ORDER BY field1 DESC, field2 ASC', SOQLOrderByClause);
                
        orderByDirective = 'field1~field2#DESC';
        SOQLOrderByClause = BT_SoqlUtils.buildSOQLOrderByClause(orderByDirective);
        System.assertEquals('ORDER BY field1 ASC, field2 DESC', SOQLOrderByClause);
                
        orderByDirective = 'field1#DESC~field2#DESC';
        SOQLOrderByClause = BT_SoqlUtils.buildSOQLOrderByClause(orderByDirective);
        System.assertEquals('ORDER BY field1 DESC, field2 DESC', SOQLOrderByClause);
    }
}