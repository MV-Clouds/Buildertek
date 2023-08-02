/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  04-Sep-2018
*/
public with sharing class BT_MultiSelectLookupController {
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList,Boolean isPreQual,string recId) {
        system.debug('searchKeyWord'+searchKeyWord);
        system.debug('ExcludeitemsList'+ExcludeitemsList);
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        
        List<string> lstExcludeitems = new List<string>();
        if(ExcludeitemsList!=null){
            for(sObject item : ExcludeitemsList ){
                lstExcludeitems.add(item.id);
            }            
        }
        
        try{
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records  
            // String sQuery = 'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
            String sQuery;

            if(ObjectName == 'contact') {
                if(isPreQual){
                    sQuery =  'select id, Name, Email from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND AccountId=:recId order by createdDate DESC limit 5';
                }else{
                    sQuery =  'select id, Name, Email from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
                }
                
                
            }

            //Strat Changes on 5th December 2022
            // String sQuery2 = 'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND buildertek__Meeting__c=:recId order by createdDate DESC limit 5';
            if(ObjectName == 'buildertek__Attendee__c') {
                if(isPreQual){
                    sQuery =  'select id, Name, buildertek__Meeting__c, buildertek__Email_Address__c from ' +ObjectName + ' where Name LIKE: searchKey AND buildertek__Meeting__c=:recId AND buildertek__Meeting__c!=null  order by createdDate DESC limit 5';
                }else{
                    System.debug('===OUTISDE IF ====');
                    sQuery =  'select id, Name, buildertek__Meeting__c , buildertek__Email_Address__c from ' +ObjectName + ' where Name LIKE: searchKey AND buildertek__Meeting__c=:recId AND buildertek__Meeting__c!=null order by createdDate DESC LIMIT 5';
                }
        
            }
            // End Changes on 5th December 2022
            
            List < sObject > lstOfRecords; 
            if(ObjectName == 'contact') { 
                if(Schema.sObjectType.contact.fields.Id.isAccessible() &&
                   Schema.sObjectType.contact.fields.Name.isAccessible() &&
                   Schema.sObjectType.contact.fields.Email.isAccessible()){
                       lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
                   } 
            }else{
                lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
            }

            // CHNAGES ON DEC 5TH
            if(ObjectName == 'buildertek__Attendee__c') { 
                if(Schema.sObjectType.buildertek__Attendee__c.fields.Id.isAccessible() &&
                   Schema.sObjectType.buildertek__Attendee__c.fields.Name.isAccessible() &&
                   Schema.sObjectType.buildertek__Attendee__c.fields.buildertek__Email_Address__c.isAccessible()){
                       lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
                   } 
                   System.debug('========List in if==========');
            }else{
                lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
                System.debug('========List out  if==========');

            }
            // end chnages

            for (sObject obj: lstOfRecords) { 
                System.debug(obj.Id);
            
                returnList.add(obj);
            }
            System.debug(lstOfRecords);
            System.debug(returnList);
            System.debug(returnList.size());


        }catch(Exception e){
            system.debug('exception--->'+e.getMessage()+'--line no--->'+e.getLineNumber());
        }
        
        return returnList;
    }
}