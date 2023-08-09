/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  29-Nov-2018
*/
public with sharing class RFITriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
  //  public static Boolean blnSkipRFIUpdateTrigger = false;
    
   // private boolean m_isExecuting = false;
  //  private integer BatchSize = 0;
    
    public RFITriggerHandler (boolean isExecuting, integer size){
       // m_isExecuting = isExecuting;
      //  BatchSize = size;
    }
    
    public void OnBeforeInsert(RFI__c[] newRFI){
       /* List<RFI__c> rfiList;
        if(Schema.sObjectType.RFI__c.fields.id.isAccessible() && 
           Schema.sObjectType.RFI__c.fields.Auto_Number__c.isAccessible() &&
           Schema.sObjectType.RFI__c.fields.buildertek__Project__c.isAccessible()){
               rfiList = [Select Id, Auto_Number__c from RFI__c 
                          where Project__c =:newRFI[0].Project__c 
                          ORDER BY CREATEDDATE DESC  LIMIT 1];
               
           }
        if(!Test.isRunningTest()){
            BT_Utils.genrateAutoNumber(rfiList, newRFI, 'Auto_Number__c');    
        }*/
        
    }
    
    public void OnBeforeDelete(RFI__c[] deleteRFI, Map<ID, RFI__c> RFIMap){
       /* for(buildertek__RFI__c rfi : deleteRFI){
            if(rfi.buildertek__Status__c == 'Submitted' || rfi.buildertek__Status__c == 'Completed'){
                rfi.adderror('RFI Cannot be deleted');    
            }
        } */   
    }
    
   /*public static void sharingRecord(List<RFI__c> rfiRec, Map<ID, RFI__c> RFIMap){ 
        List<RFI__Share> rfishList=new List<RFI__Share>();
        List<RFI__Share> sharesToDelete =new  List<RFI__Share>();
        RFI__Share rfish=new RFI__Share();
        for(RFI__c rfi:rfiRec){
            if(rfi.RFI_Reassigned_To__c!=null){
                if(RFIMap.get(rfi.Id).RFI_Reassigned_To__c != rfi.RFI_Reassigned_To__c){    
                    sharesToDelete = [SELECT Id 
                                      FROM RFI__Share 
                                      WHERE ParentId =:RFIMap.get(rfi.Id).Id
                                      AND RowCause = 'Manual'];
                    
                    rfish.ParentId=rfi.Id;
                    rfish.UserOrGroupId=rfi.RFI_Reassigned_To__c;
                    rfish.AccessLevel= 'Edit';
                    rfish.RowCause=Schema.RFI__Share.RowCause.Manual;             
                    rfishList.add(rfish);
                }
            }else{
                sharesToDelete = [SELECT Id 
                                      FROM RFI__Share 
                                      WHERE ParentId =:RFIMap.get(rfi.Id).Id
                                      AND RowCause = 'Manual'];
            }
        }
        if(!sharesToDelete.isEmpty()){
            Database.Delete(sharesToDelete, false);
        }
        System.debug('share record***********************************'+rfishList);
        Database.SaveResult[] lsr = Database.insert(rfishList,false);
    }*/
    
    
}