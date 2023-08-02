/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date:  24-May-2018
*/
public with sharing class ContentDocumentLinkHandler{
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean skiptrigger = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public ContentDocumentLinkHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(ContentDocumentLink[] newRecords){
        system.debug('>>>>> Is after trigger');
        List<ContentDocumentLink> cdls  = newRecords;
        system.debug('>>>>> Is after trigger'+cdls);
        Set<ID> RFQparentIds = new Set<ID>();
        for (ContentDocumentLink cdl : cdls ) {
            String objectName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
            system.debug('>>>>> objectName'+objectName);
            if(objectName == 'buildertek__RFQ__c'){
                system.debug('>>>>>'+cdl.LinkedEntityId);
                RFQparentIds.add( cdl.LinkedEntityId );  
            }
            //RFQparentIds.add( cdl.LinkedEntityId );
        }
        if(!RFQparentIds.isEmpty()){
            List<buildertek__RFQ_To_Vendor__c> vendorRFQ = [select id,buildertek__Status__c,buildertek__Contact__r.Email,buildertek__RFQ__r.buildertek__Status__c  from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c IN:RFQparentIds];
            system.debug('>>>>>'+vendorRFQ);
            //List<contact> con = [select id,name,Email from contact order by createdDate desc limit 1];
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
            List<string> emaillist = new List<string>();
            EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE name ='EmailToVendor'];
            for(buildertek__RFQ_To_Vendor__c vr :vendorRFQ){
                if(vr.buildertek__Status__c == 'Email Sent' && vr.buildertek__RFQ__r.buildertek__Status__c != 'Accepted'){
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setTemplateId(et.Id);
                    msg.setWhatId(vr.ID);
                    msg.setTargetObjectId(vr.buildertek__Contact__c);
                    //msg.setTargetObjectId(con[0].Id);
                    msg.setToAddresses(new list<string>{vr.buildertek__Contact__r.Email});
                    lstMsgs.add(msg);
                }
            }
            if(!lstMsgs.IsEmpty()){
                Messaging.sendEmail(lstMsgs);
            }
        }
        
    }
    
    public void OnAfterInsert(ContentDocumentLink[] newRecordList, Map<ID, ContentDocumentLink> newRecordMap){
        List<ContentDistribution> conDistributionList = new List<ContentDistribution>();
        set<Id> contentDocumentId = new set<Id>();
        Map<Id,ContentVersion> conVersionMap = new Map<Id,ContentVersion>();
        Map<ID, ContentDocumentLink> conDocMap = new Map<ID, ContentDocumentLink>();
        for(ContentDocumentLink conLink : newRecordList){
            contentDocumentId.add(conLink.contentDocumentId);
            conDocMap.put(conLink.ContentDocumentId,conLink);
        }
        if(!contentDocumentId.isEmpty()){
            List<ContentVersion> conVersionList = [Select Id, Title, FirstPublishLocationId , ContentDocumentId FROM ContentVersion WHERE ContentDocumentId In : contentDocumentId];
            for(ContentVersion conVer : conVersionList){
                if(Id.valueOf(conDocMap.get(conVer.ContentDocumentId).LinkedEntityId).getSObjectType().getDescribe().getName() == 'buildertek__RFQ__c'){
                    ContentDistribution cd = new ContentDistribution();
                    cd.Name = conVer.Title;
                    cd.ContentVersionId = conVer.Id;
                    cd.RelatedRecordId = conDocMap.get(conVer.ContentDocumentId).LinkedEntityId;
                    cd.PreferencesAllowOriginalDownload = true; 
                    cd.PreferencesAllowPDFDownload = true;
                    cd.PreferencesAllowViewInBrowser = true; 
                    cd.PreferencesNotifyOnVisit = false; 
                    conDistributionList.add(cd);            
                }
            }
            if(conDistributionList.size()>0){
                insert conDistributionList;
            }
        }
    }
    
    public void OnBeforeUpdate(ContentDocumentLink[] oldRecordList, ContentDocumentLink[] updatedRecordList, Map<ID, ContentDocumentLink> newRecordMap, Map<Id, ContentDocumentLink> oldRecordMap){
    }
    
    public void OnAfterUpdate(ContentDocumentLink[] oldRecordList, ContentDocumentLink[] updatedRecordList, Map<ID, ContentDocumentLink> newRecordMap, Map<Id, ContentDocumentLink> oldRecordMap){
    }
    
    public void OnBeforeDelete(ContentDocumentLink[] recordList, Map<ID, ContentDocumentLink> recordMap){
    }
    
    public void OnAfterDelete(ContentDocumentLink[] recordList){
    }
}