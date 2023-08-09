/*
    Copyright (c) 2017-2018, BuilderTek.
    All rights reserved.
    
    Developed By: Sagar
    Date: 30-Nov-2018
    */
    public with sharing class WarrantyTriggerHandler {
        //Boolean variable to allow skipping execution of trigger in certain scenarios
        public static Boolean blnSkipTrigger = false;
        
        private boolean m_isExecuting = false;
        private integer BatchSize = 0;
        
        public WarrantyTriggerHandler (boolean isExecuting, integer size){
            m_isExecuting = isExecuting;
            BatchSize = size;
        }
        
        public void OnBeforeInsert(buildertek__Warranty__c[] newRecords){
            List<buildertek__Warranty__c> warrantyList;
            if(Schema.sObjectType.buildertek__Warranty__c.fields.id.isAccessible()
               && Schema.sObjectType.buildertek__Warranty__c.fields.buildertek__Auto_Number__c.isAccessible()
               && Schema.sObjectType.buildertek__Warranty__c.fields.buildertek__Project__c.isAccessible()
              ){
                  
                  warrantyList = [Select Id, buildertek__Auto_Number__c from buildertek__Warranty__c
                                  where buildertek__Project__c =:newRecords[0].buildertek__Project__c
                                  ORDER BY CREATEDDATE DESC LIMIT 1];
              }
            list<id> projectid = new list<id>();
            for(buildertek__Warranty__c warrantyRec : newRecords){
                if(warrantyRec.buildertek__Project__c != null){
                   projectid.add(warrantyRec.buildertek__Project__c); 
                }
            }
            list<buildertek__Project__c> projectlist = [select id,Name,buildertek__Estimated_Completion_Date__c from buildertek__Project__c where Id IN : projectid];
            for(buildertek__Warranty__c warrantyRec : newRecords){
                 system.debug('projectRec.buildertek__Estimated_Completion_Date__c' + warrantyRec.buildertek__Effective_Date__c);
                for(buildertek__Project__c projectRec : projectlist){
                    system.debug('projectRec.buildertek__Estimated_Completion_Date__c' + projectRec.buildertek__Estimated_Completion_Date__c);
                    if( warrantyRec.buildertek__Effective_Date__c == null && projectRec.buildertek__Estimated_Completion_Date__c != null){
                        warrantyRec.buildertek__Effective_Date__c = projectRec.buildertek__Estimated_Completion_Date__c;
                    }
                }
            }
            for(buildertek__Warranty__c warrantyRec : newRecords){
               /* if( warrantyRec.buildertek__Effective_Date__c != null && warrantyRec.buildertek__Project__c != null && warrantyRec.buildertek__Project__r.buildertek__Estimated_Completion_Date__c != null){
                    warrantyRec.buildertek__Effective_Date__c = warrantyRec.buildertek__Project__r.buildertek__Estimated_Completion_Date__c;
                }*/
                if(warrantyRec.buildertek__Effective_Date__c != null && warrantyRec.buildertek__Length_of_Warranty__c != null){
                    if(warrantyRec.buildertek__Length_of_Warranty__c.contains('month') || warrantyRec.buildertek__Length_of_Warranty__c.contains('months')){
                        List<string> s = warrantyRec.buildertek__Length_of_Warranty__c.split(' ');
                        integer addingDays = integer.valueOf(s[0]) * 30;
                        warrantyRec.buildertek__Due_Date__c = warrantyRec.buildertek__Effective_Date__c.adddays(addingDays);
                    }
                    if(warrantyRec.buildertek__Length_of_Warranty__c.contains('year') || warrantyRec.buildertek__Length_of_Warranty__c.contains('years')){
                        List<string> s = warrantyRec.buildertek__Length_of_Warranty__c.split(' ');
                        integer addingDays = integer.valueOf(s[0]) * 365;
                        warrantyRec.buildertek__Due_Date__c = warrantyRec.buildertek__Effective_Date__c.adddays(addingDays);
                    }
                }
            }
            if(!Test.isRunningTest()){
                BT_Utils.genrateAutoNumber(warrantyList, newRecords, 'buildertek__Auto_Number__c');
                
            }
        }
       
       public void OnAfterUpdate(buildertek__Warranty__c[] updatedWarranty, Map<Id, buildertek__Warranty__c> oldWarrantyMap){
            for(buildertek__Warranty__c warrantyRec : updatedWarranty){
                 if(warrantyRec.buildertek__Effective_Date__c != null && warrantyRec.buildertek__Length_of_Warranty__c != null && 
                    (oldWarrantyMap.get(warrantyRec.id).buildertek__Effective_Date__c != warrantyRec.buildertek__Effective_Date__c ||
                    oldWarrantyMap.get(warrantyRec.id).buildertek__Length_of_Warranty__c != warrantyRec.buildertek__Length_of_Warranty__c)){
                    if(warrantyRec.buildertek__Length_of_Warranty__c.contains('month') || warrantyRec.buildertek__Length_of_Warranty__c.contains('months')){
                        List<string> s = warrantyRec.buildertek__Length_of_Warranty__c.split(' ');
                        integer addingDays = integer.valueOf(s[0]) * 30;
                        warrantyRec.buildertek__Due_Date__c = warrantyRec.buildertek__Effective_Date__c.adddays(addingDays);
                    }
                    if(warrantyRec.buildertek__Length_of_Warranty__c.contains('year') || warrantyRec.buildertek__Length_of_Warranty__c.contains('years')){
                        List<string> s = warrantyRec.buildertek__Length_of_Warranty__c.split(' ');
                        integer addingDays = integer.valueOf(s[0]) * 365;
                        warrantyRec.buildertek__Due_Date__c = warrantyRec.buildertek__Effective_Date__c.adddays(addingDays);
                    }
                }else if(oldWarrantyMap.get(warrantyRec.id).buildertek__Due_Date__c != warrantyRec.buildertek__Due_Date__c){
                    system.debug('%%%'+oldWarrantyMap.get(warrantyRec.id).buildertek__Due_Date__c);
                    system.debug('%%%'+warrantyRec.buildertek__Due_Date__c);
                }
            }
        }
    }