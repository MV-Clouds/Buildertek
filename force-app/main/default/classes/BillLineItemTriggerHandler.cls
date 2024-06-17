public class BillLineItemTriggerHandler {
    
    //Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipBilllineItemUpdateTrigger = false;
	 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public BillLineItemTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnAfterInsert(buildertek__Account_Payable_Item__c[] newBillLineItem, Map<ID, buildertek__Account_Payable_Item__c> newBillLineItemMap){ 
     	
     	// Create Bill Line Item to Budget Item link
       BT_CreateNewBill.createbilllineitemToBudgetItemLink(newBillLineItem);
       BT_CreateNewBill.RollUpBillLineItemAmount(newBillLineItemMap.KeySet());

       List<Id> invoiceLineids = new List<Id>();
		for(buildertek__Account_Payable_Item__c invoiceLine : newBillLineItem){
			invoiceLineids.add(invoiceLine.Id);
		}
		System.debug(invoiceLineids);
		// quickBookCallout(invoiceLineids);

        Set<Id> InoviceId = new Set<Id>();
        for(buildertek__Account_Payable_Item__c invoiceLine : newBillLineItem){
            InoviceId.add(invoiceLine.buildertek__Account_Payable__c);
        }
        recalculateInvoice(InoviceId);
 	}
     
 	public void OnAfterUpdate(buildertek__Account_Payable_Item__c[] oldBillLineItem, buildertek__Account_Payable_Item__c[] updatedBillLineItem, Map<ID, buildertek__Account_Payable_Item__c> BillLineItemMap, Map<Id, buildertek__Account_Payable_Item__c> oldBillLineItemMap){
    	
      BT_CreateNewBill.RollUpBillLineItemAmount(BillLineItemMap.KeySet());

        Set<Id> InoviceId = new Set<Id>();
        for(buildertek__Account_Payable_Item__c invoiceLine : updatedBillLineItem){
            InoviceId.add(invoiceLine.buildertek__Account_Payable__c);
        }
        recalculateInvoice(InoviceId);
 	}

    //OnAfterDelete
    public void OnAfterDelete(buildertek__Account_Payable_Item__c[] oldBillLineItem){
        Set<Id> InoviceId = new Set<Id>();
        for(buildertek__Account_Payable_Item__c invoiceLine : oldBillLineItem){
            InoviceId.add(invoiceLine.buildertek__Account_Payable__c);
        }
        recalculateInvoice(InoviceId);


    }



    public static void recalculateInvoice(Set<Id> InoviceId){
        
        //query all the Invoice buildertek__Account_Payable__c
        List<buildertek__Account_Payable__c> invoiceList = [SELECT Id, Name, buildertek__Budget__c, buildertek__BT_Budget_Line__c from buildertek__Account_Payable__c WHERE Id IN :InoviceId];

        Set<Id> budgetLineIds = new Set<Id>();
        for(buildertek__Account_Payable__c invoice : invoiceList){
            if(invoice.buildertek__BT_Budget_Line__c != null){
                budgetLineIds.add(invoice.buildertek__BT_Budget_Line__c);
            }
        }

        List<buildertek__Account_Payable_Item__c> invoiceLineList = [SELECT Id, buildertek__Account_Payable__c, buildertek__Account_Payable__r.buildertek__Budget__c, buildertek__Account_Payable__r.buildertek__BT_Budget_Line__c, buildertek__Total_Amount_With_Tax__c from buildertek__Account_Payable_Item__c where buildertek__Account_Payable__r.buildertek__BT_Budget_Line__c IN :budgetLineIds];

        //make a map where budget line id is the key and the invoice Lines are the values
        Map<Id, List<buildertek__Account_Payable_Item__c>> budgetLineToInvoiceLineMap = new Map<Id, List<buildertek__Account_Payable_Item__c>>();
        for(buildertek__Account_Payable_Item__c invoiceLine : invoiceLineList){
            if(!budgetLineToInvoiceLineMap.containsKey(invoiceLine.buildertek__Account_Payable__r.buildertek__BT_Budget_Line__c)){
                budgetLineToInvoiceLineMap.put(invoiceLine.buildertek__Account_Payable__r.buildertek__BT_Budget_Line__c, new List<buildertek__Account_Payable_Item__c>());
            }
            budgetLineToInvoiceLineMap.get(invoiceLine.buildertek__Account_Payable__r.buildertek__BT_Budget_Line__c).add(invoiceLine);
        }

        //iterate over the map and calculate the total amount for each budget line
        List<buildertek__Budget_Item__c> budgetItemsToUpdate = new List<buildertek__Budget_Item__c>();
        for(Id budgetLineId : budgetLineToInvoiceLineMap.keySet()){
            Decimal totalAmount = 0;
            for(buildertek__Account_Payable_Item__c invoiceLine : budgetLineToInvoiceLineMap.get(budgetLineId)){
                totalAmount += (invoiceLine.buildertek__Total_Amount_With_Tax__c == null) ? 0 : invoiceLine.buildertek__Total_Amount_With_Tax__c;
            }
            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c(Id = budgetLineId, buildertek__Invoice_PO__c = totalAmount);
            budgetItemsToUpdate.add(budgetItem);
        }

        //update the budget items
        if(budgetItemsToUpdate.size() > 0){
            update budgetItemsToUpdate;
        }







    }

/*------------------------- quickBookCallout ---------------------------*

|  Function quickBookCallout
|
|  Purpose:  This is an External API Callout Method which is callout in the 
|            OnAfterInsert method and this method creating the invoices 
|            in the quickbooks online app.
|
|  Parameters:
|        (IN = USED TO PASS DATA INTO THIS FUNCTION, 
|         OUT = USED TO PASS DATA OUT OF THIS FUNCTION
|         IN/OUT = USED FOR BOTH PURPOSES.)
|      
|      testlist (IN) --  This is an list of an IDs which will be used for 
|                        getting the object data.
|      (Note :- As we can not pass the list directly in the async method 
|               we have pass the IDs)
|                                      
*-------------------------------------------------------------------*/

     @future(callout = true)
     public static void quickBookCallout(List<Id> testlist){
         System.debug('In quickBookCallout Method');
         List<buildertek__Account_Payable_Item__c> invoiceLineList = new List<buildertek__Account_Payable_Item__c>();
         invoiceLineList = [SELECT id,buildertek__Quantity__c,buildertek__Unit_Price__c,Name, buildertek__Account_Payable__c, buildertek__Auto_Number__c, buildertek__Product__c,buildertek__Cost_Code__c from buildertek__Account_Payable_Item__c WHERE Id IN :testlist];
            //creating JSON data
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('Line');
            gen.writeStartArray();
            gen.writeStartObject();
                gen.writeStringField('DetailType','SalesItemLineDetail');
                gen.writeNumberField('Amount',100);
                gen.writeFieldName('SalesItemLineDetail');
                gen.writeStartObject();
                    gen.writeStringField('value','1');
                    gen.writeStringField('name','Services');
                gen.writeEndObject();
                gen.writeFieldName('TaxCodeRef');
                gen.writeStartObject();
                    gen.writeStringField('value','12');
                gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeFieldName('CustomerRef');
            gen.writeStartObject();
                gen.writeStringField('value','3');
                gen.writeStringField('name','John');
            gen.writeEndObject();
            gen.writeEndObject();
            String finalBody = gen.getAsString();
            
            Map<String,Object> metadataValue = AuthorizationController.generateAccessToken('QB_'+UserInfo.getUserName());
            String access_token = metadataValue == null ? '' : String.valueOf(metadataValue.get('buildertek__access_token__c'));
 
             HttpRequest req = new HttpRequest();
             string  endPointURL = 'https://sandbox-quickbooks.api.intuit.com/v3/company/'+String.valueOf(metadataValue.get('buildertek__company_id__c'))+'/invoice?minorversion=65';
             system.debug('endPointURL-->'+endPointURL);
             req.setEndpoint(endPointURL);
             req.setMethod('POST');
             req.setHeader('Authorization', 'bearer ' + access_token);
             req.setHeader('Content-Type','application/json');
             req.setBody(finalBody);
             req.setTimeout(120000);
             system.debug('--req--'+req);
             Http http = new Http();
             if(!Test.isRunningTest()){
                 HTTPResponse response = http.send(req);
                 //Response Handl --For dev purpose only
                 if(response.getStatusCode() == 200 ){
                     System.debug('---Response---'+response);
                     System.debug('-Response--'+response.getBody());
                 }
             }
         }
      }