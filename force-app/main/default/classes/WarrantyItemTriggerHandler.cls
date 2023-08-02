/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  30-Nov-2018
*/
public with sharing class WarrantyItemTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipTrigger = false;
	 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public WarrantyItemTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
 	public void OnBeforeInsert(buildertek__Warranty_Item__c[] newRecords){
 	    List<buildertek__Warranty_Item__c> warrantyItemList;
 	    if(Schema.sObjectType.buildertek__Warranty_Item__c.fields.id.isAccessible()
 	        && Schema.sObjectType.buildertek__Warranty_Item__c.fields.buildertek__Auto_Number__c.isAccessible()){
 	        
 	        warrantyItemList = [Select Id, buildertek__Auto_Number__c from buildertek__Warranty_Item__c 
 									 where buildertek__Warranty__c =:newRecords[0].buildertek__Warranty__c 
 									 ORDER BY CREATEDDATE DESC  LIMIT 1];    
 	    }
 	    
     	//BT_Utils.genrateAutoNumber(warrantyItemList, newRecords, 'buildertek__Auto_Number__c');
     	set<Id> warrantyid = new set<Id>();
        for(buildertek__Warranty_Item__c warrantyitemrec : newRecords){
            if(warrantyitemrec.buildertek__Warranty__c !=null){
                warrantyid.add(warrantyitemrec.buildertek__Warranty__c);
            }
        }
        list<buildertek__Warranty__c> warrantylst = [select id,name,buildertek__Locked__c from buildertek__Warranty__c where Id IN :warrantyid];
         for(buildertek__Warranty_Item__c warrantyitemrec : newRecords){
            for(buildertek__Warranty__c warnty :warrantylst ){
                if(warrantyitemrec.buildertek__Warranty__c == warnty.Id && warnty.buildertek__Locked__c == true){
                    warrantyitemrec.addError('You cannot create new Item because Warranty is Locked' );
                }
            }
        }
 	}
    
    public void OnBeforeUpdate(buildertek__Warranty_Item__c[] oldwarrantyitem, buildertek__Warranty_Item__c[] updatedwarrantyitems, Map<ID, buildertek__Warranty_Item__c> warrantyItemMap){
        set<Id> warrantyid = new set<Id>();
        for(buildertek__Warranty_Item__c warrantyitemrec : updatedwarrantyitems){
            if(warrantyitemrec.buildertek__Warranty__c !=null){
                warrantyid.add(warrantyitemrec.buildertek__Warranty__c);
            }
        }
        list<buildertek__Warranty__c> warrantylst = [select id,name,buildertek__Locked__c from buildertek__Warranty__c where Id IN :warrantyid];
         for(buildertek__Warranty_Item__c warrantyitemrec : updatedwarrantyitems){
            for(buildertek__Warranty__c warnty :warrantylst ){
                if(warrantyitemrec.buildertek__Warranty__c == warnty.Id && warnty.buildertek__Locked__c == true){
                    warrantyitemrec.addError('You cannot edit this Item because Warranty is Locked' ); 
                }
            }
        }
 	}

}