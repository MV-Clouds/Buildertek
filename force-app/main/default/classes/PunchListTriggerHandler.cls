/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  29-Nov-2018
*/
public with sharing class PunchListTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipPLUpdateTrigger = false;
	 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public PunchListTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
 	public void OnBeforeInsert(Punch_List__c[] newPunchList){
 	    if(!Test.isRunningTest()){
 	        BT_Utils.genrateAutoNumber([Select Id, buildertek__Auto_Number1__c from Punch_List__c 
 									 where Project__c =:newPunchList[0].Project__c 
 									 ORDER BY CREATEDDATE DESC  LIMIT 1], newPunchList, 'Auto_Number1__c');    
 	    }
     	
 	}
}