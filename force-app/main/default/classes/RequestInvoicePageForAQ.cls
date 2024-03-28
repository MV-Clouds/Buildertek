public without sharing class RequestInvoicePageForAQ{
    public string companycurrency {get;set;}

    public boolean multicurrency {get;set;}

    public string purchaseOrderId{ get; set; }

    public Boolean isErrorMessage{ get; set; }

    public String errorMessage{ get; set; }

    public List<buildertek__Purchase_Order__c> purchaseOrderRecord{ get; set; }

    public List<buildertek__Purchase_Order_Item__c> poLineRecord{ get; set; }

    public String latestFileName { get; set; }

    transient String fileContents { get; set; }

    public Boolean isModalVisible { get; set; }

    public String modalTitle { get; set; }

    public String modalMessage { get; set; }

    public String modalButtonLabel { get; set; }

    public Boolean HideSubmitButton { get; set; }

    public Map<Id, buildertek__Purchase_Order_Item__c> oldPurchaseOrderItemsMap { get; set; }

    public Map<Id, buildertek__Purchase_Order_Item__c> newPurchaseOrderItemsMap { get; set; }

    public RequestInvoicePageForAQ(){
        try{
            
            purchaseOrderId = ApexPages.currentPage().getParameters().get('Id').escapeHtml4();
            purchaseOrderRecord = new List<buildertek__Purchase_Order__c>();
            poLineRecord = new List<buildertek__Purchase_Order_Item__c>();

            List<buildertek__Purchase_Order__c> tempPurchaseOrderList = [SELECT Name, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__PO_Total__c, buildertek__Description__c, 
                                                                    (SELECT Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Description__c, buildertek__Quantity__c, buildertek__Actual_Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c 
                                                                     FROM buildertek__Purchase_Order_Items__r) 
                                                                    FROM buildertek__Purchase_Order__c WHERE ID = :purchaseOrderId LIMIT 1];

            if (!tempPurchaseOrderList.isEmpty()) {
                purchaseOrderRecord = tempPurchaseOrderList;
                if (!tempPurchaseOrderList[0].buildertek__Purchase_Order_Items__r.isEmpty()) {
                    poLineRecord = tempPurchaseOrderList[0].buildertek__Purchase_Order_Items__r;
                }
            }

            oldPurchaseOrderItemsMap = new Map<Id, buildertek__Purchase_Order_Item__c>();
            newPurchaseOrderItemsMap = new Map<Id, buildertek__Purchase_Order_Item__c>();
            for (buildertek__Purchase_Order_Item__c item : poLineRecord) {
                oldPurchaseOrderItemsMap.put(item.Id, item.clone());
                newPurchaseOrderItemsMap.put(item.Id, item.clone());
            }

            isErrorMessage = false;
            errorMessage = '';
            companycurrency = UserInfo.getDefaultCurrency();
            multicurrency = UserInfo.isMultiCurrencyOrganization();
            HideSubmitButton = false;

        } catch (Exception ex){
            isErrorMessage = true;
            errorMessage = ex.getMessage();
            HideSubmitButton = true;
        }
    }

    public void uploadFileToPurchaseorder(){
        try {
            // List<buildertek__Purchase_Order_Item__c> itemsToUpdate = new List<buildertek__Purchase_Order_Item__c>();

            // for (buildertek__Purchase_Order_Item__c item : poLineRecord) {
            //     item.buildertek__Actual_Quantity__c = item.buildertek__Actual_Quantity__c;
            //     itemsToUpdate.add(item);
            // }

            // if (!itemsToUpdate.isEmpty()) {
            //     update itemsToUpdate;
            // }

            // System.debug('poLineRecord-->'+poLineRecord);

            buildertek__Account_Payable__c newContractorInvoice = new  buildertek__Account_Payable__c();
            newContractorInvoice.buildertek__Project__c = purchaseOrderRecord[0].buildertek__Project__c;
            newContractorInvoice.buildertek__Purchase_Order__c = purchaseOrderRecord[0].Id;
            insert newContractorInvoice;

            for (buildertek__Purchase_Order_Item__c item : poLineRecord) {
                if (newPurchaseOrderItemsMap.containsKey(item.Id)) {
                    newPurchaseOrderItemsMap.get(item.Id).buildertek__Actual_Quantity__c = item.buildertek__Actual_Quantity__c;
                }
            }

            // Compare old and new maps and create account payable items if necessary
            List<buildertek__Account_Payable_Item__c> newContractorInvoiceLines = new List<buildertek__Account_Payable_Item__c>();
            for (Id itemId : oldPurchaseOrderItemsMap.keySet()) {
                buildertek__Purchase_Order_Item__c oldItem = oldPurchaseOrderItemsMap.get(itemId);
                buildertek__Purchase_Order_Item__c newItem = newPurchaseOrderItemsMap.get(itemId);
                if (oldItem.buildertek__Actual_Quantity__c != newItem.buildertek__Actual_Quantity__c && newItem.buildertek__Actual_Quantity__c != null) {
                    buildertek__Account_Payable_Item__c newContractorInvoiceLine = new buildertek__Account_Payable_Item__c();
                    newContractorInvoiceLine.Name = newItem.Name;
                    newContractorInvoiceLine.buildertek__Account_Payable__c = newContractorInvoice.Id;
                    newContractorInvoiceLine.buildertek__Purchase_Order_Item__c = newItem.Id;
                    newContractorInvoiceLine.buildertek__Quantity__c = newItem.buildertek__Actual_Quantity__c;
                    newContractorInvoiceLine.buildertek__Unit_Price__c = newItem.buildertek__Unit_Price__c;
                    newContractorInvoiceLine.buildertek__Description__c = newItem.buildertek__Description__c;
                    newContractorInvoiceLines.add(newContractorInvoiceLine);
                }
            }

            if (!newContractorInvoiceLines.isEmpty()) {
                insert newContractorInvoiceLines;
            }

            fileContents = Apexpages.currentpage().getparameters().get('secondParam');
            fileContents = EncodingUtil.urlDecode(fileContents, 'UTF-8');
            Blob blobValue = EncodingUtil.base64Decode(fileContents);
            String attachmentBody = EncodingUtil.base64Encode(blobValue);

            ContentVersion contentToInsert =new ContentVersion();
            contentToInsert.ContentLocation = 'S';
            contentToInsert.PathOnClient = latestFileName;
            contentToInsert.Title = latestFileName;
            contentToInsert.VersionData = EncodingUtil.base64Decode(attachmentBody);
            insert contentToInsert;

            contentToInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: contentToInsert.Id];
            ContentDocumentLink cl = new ContentDocumentLink();
            cl.ContentDocumentId = contentToInsert.ContentDocumentId;
            cl.LinkedEntityId = purchaseOrderId;
            cl.ShareType = 'V'; // Inferred permission
            cl.Visibility = 'AllUsers';
            Database.SaveResult linkSaveResult = Database.insert(cl);

            if (linkSaveResult.isSuccess()) {
                handleSuccess();
            } else {
                handleError('Failed to insert ContentDocumentLink.');
            }
        } catch (Exception ex) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            handleError(ex.getMessage());
        }
    }

    public void handleSuccess() {
        modalTitle = 'Success';
        modalMessage = 'File uploaded successfully.';
        modalButtonLabel = 'Close';
        isModalVisible = true;
        HideSubmitButton = true;
        isErrorMessage = true;
        errorMessage = 'Invoice Uploaded Successfully!';
    }

    public void handleError(String errorMessage) {
        modalTitle = 'Error';
        modalMessage = errorMessage;
        modalButtonLabel = 'Close';
        isModalVisible = true;
    }

}