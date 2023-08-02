/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  11-Apr-2018
*/
public with sharing class BT_LookUpController {
    @AuraEnabled
    public static String getTargetSObjectName(String sobjectName, String fieldName){
       String targetSObjectName = DescribeHandler.getSObjectType(sobjectName, fieldName);
       return targetSObjectName; 
    }
    
    @AuraEnabled
    public static List<SObject> getAllValues(String objectName){
        String queryString;
        system.debug('objectName ---------> '+objectName);
        if(objectName == 'buildertek__Cost_Codes__c'){
            queryString = 'Select Id, buildertek__Cost_Code_Name__c from ' + objectName;    
        }else{
            queryString = 'Select Id, Name from ' + objectName + ' ORDER BY Name ASC';    
        }
         List<SObject> soblst ;
        /*if(objectName == 'buildertek__Cost_Codes__c'){
        if(Schema.sObjectType.buildertek__Cost_Codes__c.fields.Id.isAccessible() &&
             Schema.sObjectType.buildertek__Cost_Codes__c.fields.buildertek__Cost_Code_Name__c.isAccessible()){
             soblst = Database.query(String.escapeSingleQuotes(queryString));
             }
        }else{*/
            soblst = Database.query(String.escapeSingleQuotes(queryString));
        /*}*/
        
        return soblst;    
    }
    
    @AuraEnabled
    public static List<SObject> searchKeyword(String objectName, String value){
        value = '%'+ value + '%';
        String queryString;
        System.debug('the value is ' + value);
        system.debug('objectName ---------> '+objectName);
        if(objectName == 'buildertek__Cost_Codes__c'){
            queryString = 'Select Id, buildertek__Cost_Code_Name__c from ' + objectName + ' where buildertek__Cost_Code_Name__c like : value';    
        }else{
            queryString = 'Select Id, Name from ' + objectName + ' where Name like : value ORDER BY Name ASC';    
        }
         List<SObject> soblst ;
       /*if(objectName == 'buildertek__Cost_Codes__c'){
        if(Schema.sObjectType.buildertek__Cost_Codes__c.fields.Id.isAccessible() &&
             Schema.sObjectType.buildertek__Cost_Codes__c.fields.buildertek__Cost_Code_Name__c.isAccessible()){
             soblst = Database.query(String.escapeSingleQuotes(queryString));
             }
        }else{*/
            soblst = Database.query(queryString);
        /*}*/
        return soblst;
    }
    
    @AuraEnabled
    public static List<SObject> searchKeyword(String objectName, String value, String filter){
        value = '%'+ value + '%';
        System.debug('the value is ' + value);
         system.debug('--filter--'+filter);
         system.debug('objectName ---------> '+objectName);
         
        String queryString;
        if(objectName == 'buildertek__Cost_Codes__c'){
            queryString = 'Select Id, buildertek__Cost_Code_Name__c from ' + objectName + ' where buildertek__Cost_Code_Name__c like : value ORDER BY Name ASC';    
        }else{
            queryString = 'Select Id, Name from ' + objectName + ' where Name like : value ORDER BY Name ASC';    
        }
        if(filter != '' && filter != null){
          //  queryString += ' and ';
           
           // queryString += filter;
        }
        List<SObject> soblst ;
      /* if(objectName == 'buildertek__Cost_Codes__c'){
        if(Schema.sObjectType.buildertek__Cost_Codes__c.fields.Id.isAccessible() &&
             Schema.sObjectType.buildertek__Cost_Codes__c.fields.buildertek__Cost_Code_Name__c.isAccessible()){
             soblst = Database.query(String.escapeSingleQuotes(queryString));
             }
        }else{*/
            soblst = Database.query(queryString);
        /*}*/
        system.debug('--queryString-- '+queryString);
        return soblst;
    }
}