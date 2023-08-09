/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  29-Nov-2018
*/
public with sharing class RFITriHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipRFIUpdateTrigger = false;
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public RFITriHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeUpdate(RFI__c[] newRFI){
        for(buildertek__RFI__c rf:newRFI){
          if(String.valueOf(rf.OwnerId).startsWith('005') && rf.OwnerId!=rf.buildertek__Submitted_By__c){
              rf.buildertek__RFI_Assigned_To__c = rf.OwnerId;
          }
        }
    
    }
    
    public void OnBeforeInsert(RFI__c[] newRFI){
        system.debug('OnBeforeInsert');
         /*buildertek__RFI_Settings__c bsettings = [Select Id,Name,buildertek__Queue_Name__c from buildertek__RFI_Settings__c WHERE Name = 'RFI Settings'];
         list<QueueSObject>  Queuereclist= new list<QueueSObject>();
         Queuereclist = [Select Id, Queue.Id, Queue.Name, Queue.Type from QueueSObject WHERE Queue.Type ='Queue' AND Queue.Name =: bsettings.buildertek__Queue_Name__c Limit 1];
         system.debug('OnBeforeInsert-->'+Queuereclist);*/
        
        List<RFI__c> rfiList;
        /*if(Schema.sObjectType.RFI__c.fields.id.isAccessible() && 
           Schema.sObjectType.RFI__c.fields.Auto_Number__c.isAccessible() &&
           Schema.sObjectType.RFI__c.fields.buildertek__Project__c.isAccessible()){*/
               rfiList = [Select Id, Auto_Number__c from RFI__c 
                          where Project__c =:newRFI[0].Project__c 
                          ORDER BY CREATEDDATE DESC  LIMIT 1];
               
           //}
        if(!Test.isRunningTest()){
            system.debug('rfiList-->'+rfiList);
            BT_Utils.genrateAutoNumber(rfiList, newRFI, 'Auto_Number__c');    
        }
        
        /*for(buildertek__RFI__c rfi : newRFI){
          if(Queuereclist!=null){
             if(Queuereclist.size()>0){
                rfi.OwnerId = Queuereclist[0].Queue.Id;
             }
          }
           
        } */
        
    }
    
    public void OnBeforeDelete(RFI__c[] deleteRFI, Map<ID, RFI__c> RFIMap){
        for(buildertek__RFI__c rfi : deleteRFI){
            if(rfi.buildertek__Status__c == 'Submitted' || rfi.buildertek__Status__c == 'Completed'){
                rfi.adderror('RFI Cannot be deleted');    
            }
        }    
    }
    
    public void updaterfiaccount(List<RFI__c> rfilist){
        
        set<Id> userids = new set<Id>();
        for(buildertek__RFI__c rec : rfilist){
             userids.add(rec.OwnerId);
        } 
system.debug(userids);
        map<Id,User> useridmap = new map<Id,User>();
        list<User> usrslist = [SELECT Id, Name, AccountId FROM User Where Id In:userids];
        for(User usrrec:usrslist){
            if(usrrec.AccountId!=null){
                useridmap.put(usrrec.Id,usrrec);
            }
        }
system.debug(useridmap);

        for(buildertek__RFI__c rec1 : rfilist){
            if(rec1.OwnerId!=null){
                if(useridmap.get(rec1.OwnerId)!=null){
                    User userrec1 = useridmap.get(rec1.OwnerId);
                    rec1.buildertek__Vendor_Account__c = userrec1.AccountId;
                }
            }
        }   

              

    }
    
    
   public static void sharingRecord(List<RFI__c> rfiRec, Map<ID, RFI__c> RFIMap){ 
        List<buildertek__RFI__Share> rfishList=new List<buildertek__RFI__Share>();
        List<buildertek__RFI__Share> sharesToDelete =new  List<buildertek__RFI__Share>();
        buildertek__RFI__Share rfish=new buildertek__RFI__Share();
        for(RFI__c rfi:rfiRec){
            if(rfi.RFI_Reassigned_To__c!=null){
                if(RFIMap.get(rfi.Id).RFI_Reassigned_To__c != rfi.RFI_Reassigned_To__c){    
                    sharesToDelete = [SELECT Id 
                                      FROM buildertek__RFI__Share 
                                      WHERE ParentId =:RFIMap.get(rfi.Id).Id
                                      AND RowCause = 'Manual'];
                    
                    rfish.ParentId=rfi.Id;
                    rfish.UserOrGroupId=rfi.RFI_Reassigned_To__c;
                    rfish.AccessLevel= 'Edit';
                    rfish.RowCause=Schema.buildertek__RFI__Share.RowCause.Manual;             
                    rfishList.add(rfish);
                }
            }else{
                sharesToDelete = [SELECT Id 
                                      FROM buildertek__RFI__Share 
                                      WHERE ParentId =:RFIMap.get(rfi.Id).Id
                                      AND RowCause = 'Manual'];
            }
        }
        if(!sharesToDelete.isEmpty()){
            Database.Delete(sharesToDelete, false);
        }
        System.debug('share record***********************************'+rfishList);
        Database.SaveResult[] lsr = Database.insert(rfishList,false);
    }  
    public static void openRFICount(List<RFI__c> rfiRec){ 
    //SELECT Id, Name, buildertek__Status__c, buildertek__RFQ__c FROM buildertek__RFI__c
    Set<Id> rfiId=new Set<Id>();
    Set<Id> parentId=new Set<Id>();
        Set<Id> vendorAccountId=new Set<Id>();
        User getUser=[SELECT Id, Name, AccountId FROM User where id=:userInfo.getUserId()];
    for(buildertek__RFI__c rfi:rfiRec){
        if(rfi.buildertek__RFQ__c!=null && rfi.buildertek__Vendor_Account__c!=null){
            rfiId.add(rfi.Id);
    parentId.add(rfi.buildertek__RFQ__c);
vendorAccountId.add(rfi.buildertek__Vendor_Account__c);            
        }
    
    }
    System.debug('RFQ----------- '+parentId);
    System.debug('vendorAccountId----------- '+vendorAccountId);
    List<buildertek__RFI__c> rfiList=[SELECT Id, Name, buildertek__Status__c, buildertek__RFQ__c,
                                      buildertek__Vendor_Account__c FROM buildertek__RFI__c
                                      where buildertek__RFQ__c in : parentId 
                                      and buildertek__Vendor_Account__c =: getUser.AccountId and buildertek__Status__c !='Closed'];
        System.debug('Size of RFI -----------'+rfiList.size());
        List<buildertek__RFQ_To_Vendor__c> rfqtovendor=[SELECT Id, Name, buildertek__RFQ__c,
                                                  buildertek__Vendor__c, buildertek__Open_RFI__c 
                                                  FROM buildertek__RFQ_To_Vendor__c where buildertek__Vendor__c=: getUser.AccountId and buildertek__RFQ__c in :parentId];
                      
           //SELECT Id, Name, buildertek__RFQ__c, buildertek__Vendor__c, buildertek__Open_RFI__c FROM buildertek__RFQ_To_Vendor__c 
           //where buildertek__RFQ__c='a1T1K000006h63WUAQ' and  buildertek__Vendor__c='0011K00002S8dsaQAB'
                      System.debug('Vendor record    '+rfqtovendor.size());
        if(rfqtovendor.size()>0){
        for(buildertek__RFQ_To_Vendor__c rtv : rfqtovendor){
        rtv.buildertek__Open_RFI__c=rfiList.size();
        }
        update rfqtovendor;
        }
        

    }

    
}