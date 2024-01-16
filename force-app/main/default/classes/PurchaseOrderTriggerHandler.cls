/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date:  19-Sep-2017
*/
public with sharing class PurchaseOrderTriggerHandler{

    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipPurchaseOrderUpdateTrigger = false;

    public static  boolean firstRun = true;

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public PurchaseOrderTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(Purchase_Order__c[] newPurchaseOrders){
        List<Purchase_Order__c> poList;
        if (Schema.sObjectType.Purchase_Order__c.fields.id.isAccessible() && Schema.sObjectType.Purchase_Order__c.fields.Auto_Number1__c.isAccessible()){
            poList = [Select Id, Auto_Number1__c
                      from Purchase_Order__c
                      where Project__c = :newPurchaseOrders[0].Project__c
                      ORDER BY CREATEDDATE DESC
                      LIMIT 1];
        }
        system.debug('poListt----->' + poList);

        //made process builder inactive and added
        set<string> POIds = new set<string>();
        for(Purchase_Order__c PO : newPurchaseOrders){
            PO.buildertek__Date_Created__c = System.today();
            POIds.add(PO.Project__c);
        }
        BT_Utils.genrateAutoNumber(poList, newPurchaseOrders, 'Auto_Number1__c');
        system.debug('POIds-->>'+POIds);
        list<buildertek__Project__c> projectList;

        projectList=[SELECT Name,buildertek__Address__c,buildertek__Customer__c,buildertek__City__c, buildertek__State__c,buildertek__Zip__c,buildertek__Country__c, buildertek__County__c FROM buildertek__Project__c WHERE Id IN :POIds];
        System.debug('projectList-->>'+projectList);

        for(Purchase_Order__c po : newPurchaseOrders){
            if(po.buildertek__Project__c != null){
                for(buildertek__Project__c prj : projectList){
                    if(po.buildertek__Project__c == prj.Id){
                        if(po.buildertek__ShipToAddress__c == null || po.buildertek__ShipToAddress__c == ''){
                            po.buildertek__ShipToAddress__c = prj.buildertek__Address__c;
                        }
                        if(po.buildertek__Ship_To_City__c == null || po.buildertek__Ship_To_City__c ==''){
                            po.buildertek__Ship_To_City__c = prj.buildertek__City__c;
                        }
                        if(po.buildertek__Ship_To_Country__c == null || po.buildertek__Ship_To_Country__c ==''){
                            po.buildertek__Ship_To_Country__c = prj.buildertek__Country__c;
                        }
                        if(po.buildertek__Ship_To_State__c == null || po.buildertek__Ship_To_State__c ==''){
                            po.buildertek__Ship_To_State__c = prj.buildertek__State__c;
                        }
                        if(po.buildertek__Ship_To_Zip__c == null || po.buildertek__Ship_To_Zip__c ==''){
                            po.buildertek__Ship_To_Zip__c = prj.buildertek__Zip__c;
                        }
                    }
                }
            }
        }
    }

    public void OnBeforeUpdate(Purchase_Order__c[] oldPurchaseOrders, Purchase_Order__c[] updatedPurchaseOrders, Map<ID, Purchase_Order__c> oldPurchaseOrderMap, Map<ID, Purchase_Order__c> PurchaseOrderMap){
        try {
            
            for (Purchase_Order__c PO : updatedPurchaseOrders){
                if ((PO.buildertek__Completion__c == 100 && PO.buildertek__Completion__c != oldPurchaseOrderMap.get(PO.Id).buildertek__Completion__c)){
                    PO.buildertek__Completion_Date__c = Date.today();
                }
                if ((PO.buildertek__Completion__c != 100 && PO.buildertek__Completion__c != oldPurchaseOrderMap.get(PO.Id).buildertek__Completion__c)){
                    PO.buildertek__Completion_Date__c = null;
                }
                if (PO.buildertek__Paid__c > 0 && PO.buildertek__Paid__c < 100){
                    if (PO.buildertek__Status__c != 'Partially Paid'){
                        PO.buildertek__Status__c = 'Partially Paid';
                    }
                } else if (PO.buildertek__Paid__c == 100){
                    if (PO.buildertek__Status__c != 'Paid'){
                        PO.buildertek__Status__c = 'Paid';
                    }
                }
                else if(PO.buildertek__Paid__c == 0){
                    if(PO.buildertek__Status__c != 'Open'){
                        PO.buildertek__Status__c = 'Open';
                    }
                }
                //made process builder inactive and added
                 PO.buildertek__Date_Created__c = System.today();
            }
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
        }
    }

    public void OnBeforeDelete(Purchase_Order__c[] PurchaseOrderToDelete, Map<ID, Purchase_Order__c> PurchaseOrderMap){
        for (Purchase_Order__c purchaseOrder : PurchaseOrderToDelete){
            if (purchaseOrder.buildertek__Status__c.equalsIgnoreCase('Awarded') || purchaseOrder.buildertek__Status__c.equalsIgnoreCase('Received')
                || purchaseOrder.buildertek__Status__c.equalsIgnoreCase('Partially Paid') || purchaseOrder.buildertek__Status__c.equalsIgnoreCase('Paid')){
                    purchaseOrder.addError('You cannot delete this Purchase Order because it has already been ' + purchaseOrder.buildertek__Status__c);
                }
        }
    }

    public void OnAfterInsert(Purchase_Order__c[] newPurchaseOrders, Map<ID, Purchase_Order__c> newPurchaseOrdersMap){

        // TODO: make this configurable
        // Auto create Account payable from newly created PO
        //PurchaseOrderDAO.createAP(newPurchaseOrders);
    }

    public void OnAfterUpdate(Purchase_Order__c[] oldPurchaseOrders, Purchase_Order__c[] updatedPurchaseOrders, Map<ID, Purchase_Order__c> PurchaseOrderMap, Map<Id, Purchase_Order__c> oldPurchaseOrdersMap){
        // build the list of PO which need processing
        List<EmailTemplate> templateId;
        EmailServicesAddress eServices;
        Set<Id> POIds = new Set<Id>();
        Set<Id> POIdsToSendEmail = new Set<Id>();
        String[] toAddresses = new String[]{};
            List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Send_Vendor_Lien_Release_On_Approval__c,
                                                                                                        buildertek__Send_PO_On_Approval__c, buildertek__Create_Invoice_on_Approval__c
                                                                                                        from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                        WHERE Name = :'Purchase Order Configuration'
                                                                                                        LIMIT 1];
        if (Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
            eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                         FROM EmailServicesAddress
                         where LocalPart = 'projects'];
        }

        for (Purchase_Order__c oldPO : oldPurchaseOrders){
            if (BT_UTILS.hasStringFieldValueChanged(PurchaseOrderMap.get(oldPO.Id), oldPO, 'Status__c')){
                POIds.add(oldPO.Id);
            }
        }

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Purchase_Order__c newPO : updatedPurchaseOrders){
            String status = oldPurchaseOrdersMap.get(newPO.Id).buildertek__Status__c;
            // system.debug('&&&&&&'+status);
            // List<buildertek__Account_Payable__c> contractInvoiveList= [Select Id , Name  , buildertek__Purchase_Order__c From buildertek__Account_Payable__c WHERE buildertek__Purchase_Order__c=:newPO.Id];
            // system.debug('contractInvoiveList ==> ' + contractInvoiveList.size());

            if (newPO.buildertek__Status__c == 'Approved' && newPO.buildertek__Status__c != status){
                if (adminInterfaceNodeConfigurations.size() > 0){
                    POIdsToSendEmail.add(newPO.Id);
                }
            }
        }
        if(!PurchaseOrderDAO.isInvoiceCreated){
            string poRec = '';
            if (adminInterfaceNodeConfigurations.size() > 0 && adminInterfaceNodeConfigurations[0].buildertek__Create_Invoice_on_Approval__c){
                list<Purchase_Order__c> purchaseorderlist = [select id,Name from Purchase_Order__c where Id IN: POIdsToSendEmail];
                for(Purchase_Order__c purchase : purchaseorderlist){
                    system.debug('&&&&&&&&&&&&&&&&'+purchaseorderlist.size());
                    poRec = purchase.id;
                    system.debug('&&&&&&&&&&&&&&&&'+poRec);
                    PurchaseOrderDAO.createAPFromPO(poRec);
                }
            }
        }
        if (!POIds.isEmpty()){
            PurchaseOrderDAO.RollUpPurchaseOrder(POIds);
        }
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        List<buildertek__Purchase_Order__c> purchaseOrderList = new List<buildertek__Purchase_Order__c>();
        if (POIdsToSendEmail.size() > 0 && adminInterfaceNodeConfigurations.size() > 0){
            
            purchaseOrderList = [Select Id, buildertek__Project__r.buildertek__Project_Manager__r.Email, buildertek__Vendor__r.buildertek__Email_Address__c, buildertek__Vendor__c
                                                                     FROM buildertek__Purchase_Order__c
                                                                     WHERE Id In :POIdsToSendEmail];
            if (adminInterfaceNodeConfigurations[0].buildertek__Send_PO_On_Approval__c) {
                
                if (Schema.sObjectType.EmailTemplate.fields.Id.isAccessible() && Schema.sObjectType.EmailTemplate.fields.Name.isAccessible()){
                    templateId = [Select Id, Name
                    FROM EmailTemplate
                    WHERE DeveloperName = :'Purchase_Order_Approved_Template'];
                }
                
                mails = new List<Messaging.SingleEmailMessage>();
                for (buildertek__Purchase_Order__c newPO : purchaseOrderList){
                    if (newPO.buildertek__Project__r != null && newPO.buildertek__Project__r.buildertek__Project_Manager__r != null && newPO.buildertek__Project__r.buildertek__Project_Manager__r.Email != null){
                        String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        List<String> sendTo = new List<String>();
                        sendTo.add(newPO.buildertek__Project__r.buildertek__Project_Manager__r.Email);
                        mail.setTargetObjectId(newPO.buildertek__Project__r.buildertek__Project_Manager__c);
                        mail.setTemplateId(templateId[0].Id);
                        mail.setWhatId(newPO.Id);
                        mail.setToAddresses(sendTo);
                        mail.setSaveAsActivity(false);
                        mails.add(mail);
                    }
                }
                if (mails.size() > 0 && templateId.size() > 0){
                    Messaging.sendEmail(mails);
                }
            }
        }

        msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        if (POIdsToSendEmail.size() > 0 && adminInterfaceNodeConfigurations.size() > 0 && adminInterfaceNodeConfigurations[0].buildertek__Send_Vendor_Lien_Release_On_Approval__c){
            if (Schema.sObjectType.EmailTemplate.fields.Id.isAccessible() && Schema.sObjectType.EmailTemplate.fields.Name.isAccessible()){
                templateId = [Select Id, Name
                              FROM EmailTemplate
                              WHERE DeveloperName = :'Purchase_Order_Line_Template'];
            }
            // List<buildertek__Purchase_Order__c> purchaseOrderList = [Select Id, buildertek__Vendor__r.buildertek__Email_Address__c , buildertek__Vendor__c
            //                                                          FROM buildertek__Purchase_Order__c
            //                                                          WHERE Id In :POIdsToSendEmail];

            List<buildertek__BT_ConfirmatioPageURL__c> confirmationPageSiteURL = [Select Id, buildertek__Public_Site_Url__c
                                                                                  FROM buildertek__BT_ConfirmatioPageURL__c LIMIT 1];

            String body = '';
            String subject = 'PurchaseLienRelease';
            String SiteUrl = '';
            String templateBody = '';
            mails = new List<Messaging.SingleEmailMessage>();
            for (buildertek__Purchase_Order__c newPO : purchaseOrderList){
                if (newPO.buildertek__Vendor__r != null && newPO.buildertek__Vendor__r.buildertek__Email_Address__c  != null){
                    if (confirmationPageSiteURL.size() > 0){
                        SiteUrl = confirmationPageSiteURL[0].buildertek__Public_Site_Url__c;
                        if (SiteUrl == null || SiteUrl == ''){
                        }
                    }
                    String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> sendTo = new List<String>();
                    sendTo.add(newPO.buildertek__Vendor__r.buildertek__Email_Address__c);
                    body += 'Hi, <br/><br/> ';
                    body += '</br> Please &nbsp;';
                    body += '<a href=' + SiteUrl + 'buildertek__ConfirmationPage?Id=' + newPO.Id + '&templateId=' + templateId[0].Id + '&isOrderLienItem=true' + '>Click here</a>';
                    body += '&nbsp;to review your Purchase Lien Release.';
                    mail.setTargetObjectId(UserInfo.getUserId());
                    mail.setTemplateId(templateId[0].Id);
                    mail.setWhatId(newPO.Id);
                    mail.setToAddresses(sendTo);
                    mail.setSaveAsActivity(false);
                    mails.add(mail);

                    SavePoint sp = Database.setSavePoint();
                    Messaging.sendEmail(mails);
                    for (Messaging.SingleEmailMessage emailNew : mails){
                        templateBody = emailNew.getHTMLBody();
                    }
                    Database.rollback(sp);

                    for (Messaging.SingleEmailMessage email : mails){
                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName('PurchaseLienRelease.pdf');
                        efa.setBody(Blob.toPdf(templateBody));
                        fileAttachments.add(efa);
                        emailToSend.setFileAttachments(fileAttachments);
                        emailToSend.setToAddresses(email.getToAddresses());
                        emailToSend.setPlainTextBody(email.getPlainTextBody());
                        emailToSend.setHTMLBody(body);
                        emailToSend.setSubject(subject);
                        msgListToBeSend.add(emailToSend);
                    }
                }
            }
            if (msgListToBeSend.size() > 0 && templateId.size() > 0){
                Messaging.sendEmail(msgListToBeSend);
            }
        }
    }
    /*  public void afterUpdate(Purchase_Order__c[] oldPurchaseOrders, Purchase_Order__c[] updatedPurchaseOrders, Map<ID, Purchase_Order__c> PurchaseOrderMap, Map<Id, Purchase_Order__c> oldPurchaseOrdersMap){
list<Id> purchaseIds = new list<Id>();
string poRec = '';
List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Send_Vendor_Lien_Release_On_Approval__c,
buildertek__Send_PO_On_Approval__c, buildertek__Create_Invoice_on_Approval__c
from buildertek__Admin_Interface_Node_Configuration__c
WHERE Name = :'Purchase Order Configuration'
LIMIT 1];
if(adminInterfaceNodeConfigurations.size()>0 ){
for(Purchase_Order__c purchaseorderRec : updatedPurchaseOrders){
String status = oldPurchaseOrdersMap.get(purchaseorderRec.Id).buildertek__Status__c;
if(purchaseorderRec.buildertek__Status__c == 'Approved' && adminInterfaceNodeConfigurations[0].buildertek__Create_Invoice_on_Approval__c == true){
purchaseIds.add(purchaseorderRec.id);
}
}
list<Purchase_Order__c> purchaseorderlist = [select id,Name from Purchase_Order__c where Id IN: purchaseIds];
for(Purchase_Order__c purchase : purchaseorderlist){
poRec = purchase.id;
PurchaseOrderDAO.createAPFromPO(poRec);
PurchaseOrderDAO.isUpdatePurchaseOrder = true;
}
}
}
*/
    public void OnBeforeUpdate(Purchase_Order__c[] newPurchaseOrders, Map<ID, Purchase_Order__c> newPurchaseOrdersMap, Map<ID, Purchase_Order__c> oldPurchaseOrdersMap){
        //* added this lines by Nishit (MV Clouds)
        Set<Id> scheduleItemId = new Set<Id>();
        System.debug('in before update method');

        List<buildertek__Account_Payable__c> contractInvoiveList= [Select Id , Name  , buildertek__Purchase_Order__c From buildertek__Account_Payable__c WHERE buildertek__Purchase_Order__c=:newPurchaseOrdersMap.keySet()];
        System.debug('contractInvoiveList' + contractInvoiveList);

        for (buildertek__Purchase_Order__c po : newPurchaseOrders) {
            if (oldPurchaseOrdersMap.get(po.Id).buildertek__Schedule_Item__c != newPurchaseOrdersMap.get(po.Id).buildertek__Schedule_Item__c) {
                if (po.buildertek__Schedule_Item__c != null) {
                    scheduleItemId.add(po.buildertek__Schedule_Item__c);
                }else {
                    po.buildertek__Start_Date__c = null;
                    po.buildertek__End_Date__c = null;
                }
            }
            system.debug('contractInvoiveList ==> ' + contractInvoiveList.size());
            system.debug('oldPurchaseOrdersMap.get(po.Id).buildertek__Date_Approved__c => ' + oldPurchaseOrdersMap.get(po.Id).buildertek__Date_Approved__c);
            system.debug('po.buildertek__Date_Approved__c => ' + po.buildertek__Date_Approved__c);
            if(!contractInvoiveList.isEmpty() && po.buildertek__Paid_Amount__c== oldPurchaseOrdersMap.get(po.Id).buildertek__Paid_Amount__c && !PurchaseOrderDAO.isInvoiceCreated){
                po.addError('You cannot update this Purchase Order because there is a Contract Invoice associated with it.  If you would like to change this Purchase Order, please remove the Contract Invoice first.');
            }
        }
        Map<Id, buildertek__Project_Task__c> taskMap = new Map<Id, buildertek__Project_Task__c>([SELECT Id, Name, buildertek__Start__c, buildertek__Finish__c FROM	buildertek__Project_Task__c WHERE Id IN: scheduleItemId]);

        if (taskMap.size() > 0) {
            for (buildertek__Purchase_Order__c po : newPurchaseOrders) {
                if (po.buildertek__Schedule_Item__c != null){
                    po.buildertek__Start_Date__c = taskMap.get(po.buildertek__Schedule_Item__c).buildertek__Start__c;
                    po.buildertek__End_Date__c = taskMap.get(po.buildertek__Schedule_Item__c).buildertek__Finish__c;
                }
            }
        }

      
    }

    public void OnAfterDelete(Purchase_Order__c[] oldPurchaseOrders){
    }

    public void updateTotalCostOnBudgetLine(Purchase_Order__c[] newPurchaseOrders, Map<ID, Purchase_Order__c> newPurchaseOrdersMap , Map<ID, Purchase_Order__c> oldPurchaseOrdersMap){


        if(PurchaseOrderTriggerHandler.firstRun){

            system.debug('newPurchaseOrdersMap'+newPurchaseOrdersMap);
            system.debug('oldPurchaseOrdersMap'+oldPurchaseOrdersMap);


            list<String> purchaseIds = new list<String>();
            list<String> budgetId = new list<String>();
            for (Purchase_Order__c newPO : newPurchaseOrders){
                purchaseIds.add(newPO.Id);
                budgetId.add(newPO.buildertek__Budget_Line__c);
            }

            PurchaseOrderTriggerHandler.firstRun = false;
           // buildertek__Purchase_Order__c purchaseRec = [select id,Name,buildertek__PO_Total__c,buildertek__Budget__c,buildertek__Budget_Line__c from buildertek__Purchase_Order__c where Id IN: Trigger.new];


          //  system.debug('purchaseorderRecord----->'+purchaseRec);

            list<buildertek__Purchase_Order_Item__c> purchaseOrderItem = [Select id,Name,buildertek__Purchase_Order__c,buildertek__Budget_Item__c from buildertek__Purchase_Order_Item__c where buildertek__Purchase_Order__c IN: purchaseIds order by CreatedDate limit 1];
            String purchaseOrderItemID;
            if (purchaseOrderItem.size() > 0) {
                purchaseOrderItemID = purchaseOrderItem[0].Id;
            }

            // if(purchaseOrderItem.size() == 0){
            //     buildertek__Purchase_Order_Item__c purchaseOrderItemRec = new buildertek__Purchase_Order_Item__c();
            //     purchaseOrderItemRec.Name = 'New Purchase Order Item - ' + newPurchaseOrders[0].Name;
            //     purchaseOrderItemRec.buildertek__Purchase_Order__c = newPurchaseOrders[0].Id;
            //     insert purchaseOrderItemRec;
            // }

            system.debug('purchaseorderItemRecord----->'+purchaseOrderItem);

            List<buildertek__Budget_Item__c> BudgetItemList = [SELECT Id, buildertek__Committed_Costs__c FROM buildertek__Budget_Item__c WHERE Id IN: budgetId];

            system.debug('BudgetItemList----------->'+BudgetItemList);

            if(BudgetItemList.size()>0){

                system.debug('BudgetItemList.size()----->'+BudgetItemList.size());

                List<buildertek__PO_Item_To_Budget_Item_Link__c> poLink = [SELECT Id, Name, buildertek__Approved_PO__c FROM buildertek__PO_Item_To_Budget_Item_Link__c WHERE buildertek__PO_Item__c =: purchaseOrderItemID];

                for(buildertek__Purchase_Order__c purchaseRec : newPurchaseOrders){

                    system.debug('121212212=========>'+oldPurchaseOrdersMap.get( purchaseRec.Id ).buildertek__Budget_Line__c);
                    system.debug('21212121===========>'+newPurchaseOrdersMap.get( purchaseRec.Id ).buildertek__Budget_Line__c);

                    if( oldPurchaseOrdersMap.get( purchaseRec.Id ).buildertek__Budget_Line__c != newPurchaseOrdersMap.get( purchaseRec.Id ).buildertek__Budget_Line__c )
                    {

                        system.debug('working');
                        List<buildertek__PO_Item_To_Budget_Item_Link__c>  budgetItemLinkRecs= new List<buildertek__PO_Item_To_Budget_Item_Link__c>();

                        system.debug('---------------------c1111');

                        if(purchaseOrderItem.size()>0){

                            system.debug('-------------------------->2222222');

                            system.debug('PurchaseOrderItem size-------------->'+purchaseOrderItem.size());
                            for(buildertek__Purchase_Order_Item__c poitemRec : purchaseOrderItem){
                                for(buildertek__Budget_Item__c budgetRec : BudgetItemList){
                                    buildertek__PO_Item_To_Budget_Item_Link__c potobudgetRec = new buildertek__PO_Item_To_Budget_Item_Link__c();
                                    potobudgetRec.buildertek__Budget_Item__c = budgetRec.id;
                                    potobudgetRec.buildertek__PO_Item__c = poitemRec.id;
                                    potobudgetRec.buildertek__Approved_PO__c =purchaseRec.buildertek__PO_Total__c;
                                    budgetItemLinkRecs.add(potobudgetRec);
                                }
                            }
                        }
                        system.debug('before------->'+ budgetItemLinkRecs);
                        Insert budgetItemLinkRecs;
                        system.debug('After-------->'+ budgetItemLinkRecs);

                    }


                    if (poLink.size()>0) {
                        if (purchaseRec.buildertek__Status__c == 'Pending') {
                            for (buildertek__PO_Item_To_Budget_Item_Link__c po : poLink) {
                                po.buildertek__Pending_PO__c = purchaseRec.buildertek__PO_Total__c;
                                po.buildertek__Approved_PO__c = 0;
                            }
                        }else {
                            for (buildertek__PO_Item_To_Budget_Item_Link__c po : poLink) {
                                po.buildertek__Pending_PO__c = 0;
                                po.buildertek__Approved_PO__c = purchaseRec.buildertek__PO_Total__c;
                            }
                        }
                    }
                }
                if (poLink.size()>0){
                    update poLink;
                }
            }



        }

    }

    public void updateAmountonProject(Purchase_Order__c[] newPurchaseOrders, Map<ID, Purchase_Order__c> oldPurchaseOrderMap) {
        try {
            // Collect unique project IDs from the updated purchase orders
            Set<Id> projectIdsToUpdate = new Set<Id>();

            for (buildertek__Purchase_Order__c newPO : newPurchaseOrders) {
                buildertek__Purchase_Order__c oldPO = oldPurchaseOrderMap.get(newPO.Id);

                // Check if relevant fields have changed
                if (hasFieldsChanged(newPO, oldPO)) {
                    projectIdsToUpdate.add(newPO.buildertek__Project__c);
                    if (newPO.buildertek__Project__c != oldPO.buildertek__Project__c) {
                        projectIdsToUpdate.add(oldPO.buildertek__Project__c);
                    }
                }
            }

            // Calculate and update aggregated values for each project
            updateProjectAggregatedValues(projectIdsToUpdate);
        } catch (Exception ex) {
            System.debug('Error--> '+ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public void updateprojectonpoinsert(Purchase_Order__c[] newPurchaseOrders) {
        try {
            // Collect unique project IDs from the updated purchase orders
            Set<Id> projectIds = new Set<Id>();
            for (buildertek__Purchase_Order__c po : newPurchaseOrders) {
                if (po.buildertek__Project__c != null) {
                    projectIds.add(po.buildertek__Project__c);
                }
            }

            // Calculate and update aggregated values for each project
            updateProjectAggregatedValues(projectIds);
        } catch (Exception ex) {
            System.debug('Error--> '+ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public boolean hasFieldsChanged(buildertek__Purchase_Order__c newPO, buildertek__Purchase_Order__c oldPO) {
        return newPO.buildertek__Status__c != oldPO.buildertek__Status__c ||
               newPO.buildertek__Paid_Amount__c != oldPO.buildertek__Paid_Amount__c ||
               newPO.buildertek__PO_Total__c != oldPO.buildertek__PO_Total__c ||
               newPO.buildertek__Project__c != oldPO.buildertek__Project__c;
    }

    public void updateProjectAggregatedValues(Set<Id> projectIds) {
        try {
            // Map to store aggregated results by project ID
            Map<Id, AggregateResult> aggregatedResultsMap = new Map<Id, AggregateResult>();
            
            // Retrieve aggregated results for each project
            for (AggregateResult aggregatedResult : [SELECT buildertek__Project__c, SUM(buildertek__Paid_Amount__c) totalPaidAmount, SUM(buildertek__PO_Total__c) totalPOTotal FROM buildertek__Purchase_Order__c WHERE buildertek__Project__c IN :projectIds AND buildertek__Status__c != 'Canceled' GROUP BY buildertek__Project__c]) {
                Id projectId = (Id)aggregatedResult.get('buildertek__Project__c');
                aggregatedResultsMap.put(projectId, aggregatedResult);
            }
    
            List<buildertek__Project__c> projectsToUpdate = new List<buildertek__Project__c>();
    
            // Iterate over the projectsToUpdate list
            for (Id projectId : projectIds) {
                // Check if aggregated result exists for the project
                if (aggregatedResultsMap.containsKey(projectId)) {
                    AggregateResult aggregatedResult = aggregatedResultsMap.get(projectId);
                    Decimal totalPaidAmount = (Decimal)aggregatedResult.get('totalPaidAmount');
                    Decimal totalPOTotal = (Decimal)aggregatedResult.get('totalPOTotal');
    
                    // Retrieve the project and update aggregated values
                    buildertek__Project__c projectToUpdate = new buildertek__Project__c(Id = projectId);
                    projectToUpdate.buildertek__Total_Paid_PO_Amount__c = totalPaidAmount;
                    projectToUpdate.buildertek__Total_PO_Amount__c = totalPOTotal;
    
                    projectsToUpdate.add(projectToUpdate);
                } else {
                    buildertek__Project__c projectToUpdate = new buildertek__Project__c(Id = projectId);
                    projectToUpdate.buildertek__Total_Paid_PO_Amount__c = 0;
                    projectToUpdate.buildertek__Total_PO_Amount__c = 0;
    
                    projectsToUpdate.add(projectToUpdate);
                }
            }
    
            System.debug('projectsToUpdate---> '+projectsToUpdate);
            if (!projectsToUpdate.isEmpty()) {
                update projectsToUpdate;
            }
        } catch (Exception ex) {
            System.debug('Error--> ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }
    
    
    
}