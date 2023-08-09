trigger Order_Entry_Release_BU_AU on Order_Entry_Release__c (Before Update, After Update) 
{ 
    // JV -20200329 Added logic to support integration rollback
    //
    // Version 8x2
    //  20180504 - Modifications for CPQ and Trigger_Source__c = 'Test Data Setup'
    //  20180524 - Modifications for handling new field edits: Deposit Amount, Shipping Container, Payment Terms, Freight
    //  20180529 - Modifications for Simultaneous support for CPQ and Standard Trigger Objects  
    //  20180530 - Modifications to accommodate either CPQ or Standard SFDC Quote objects
    //  20180626 - Modification to accommodate multi-currency               
    
    // Version 7 - Combines Go-Live version with changes in Version 6 for metric support
    //  20180208 - Correction changing "Shipping" to "Partially Shipped" in Status checks
    //  20180208 - Add support for processing Promised Date
    //  20180208 - Add code to prevent changes to Shipping Address after Order has Shipped
    //  20180208 - Corrected logic for capturing Previous date values.
    //  20180213 - Corrected error preventing field update when "Confirmation Pending"
    
    //Go-Live version based on version 5. Corrections included are:
    //  - Added the Product__c field to the SELECT statement for Order Entry Line. This was causing Quote changes to fail
    //  - Changed the if.. statement which checks for Integration in-progress to use AND instead of OR operators. This was allowing changes during integration.
    //  - Moved the fieldChange = true statement to the first line of the Bill-to and Ship-to Address Processing. This was causing the changes to the Accounts
    //      to be ignored for Integration.
    //  - Made changes to Hold Release Requested processing to correct bug with the Release Integration Status not being set correctly
    //  
    //  - 20171107 - Added logic to require Request Date for Integration
    //
    // Version 5:
    //      - Date Field Name Changes
    //      - Changes to support new change integration with Integration Scope and Integration Action Requested
    //      - Support for Changing Quote 
    //      - Corrections for Pre-Integration Hold and Cancellation Requests
    //      - Require Scheduled Ship Date to Request Integration
    // Updated Date         Developer       Project             Tracking Id                         Requirement                         
    // 30-July-2020         Bajrang         Project Concrete    SOLS_PICKED_SHIPPED_CLOSED_VLD_01   Cascading Date changes on Release level will filter out OEL's with SOLS as Picked, Shipped, Closed  
    // 03-Aug-2020          Srikanth        Project Concrete    SOLS_PICKED_SHIPPED_CLOSED_VLD_02   Throw an validation error if user tries to cancel OER which has even one OEL as  SOLS as Picked, Shipped, Closed  
    // 30-July-2020         Bajrang         Project Concrete    INTREQ_PROD_CODE_VLD_01             When OER is changed to "Integration Requested" and any of the OEL's has Product Code null then validation error is thrown  
  	// 23-Aug-2020          Rekha           Project Concrete    CANCELLATION_BUGS_SEP_20, WO_STATUS_VLD_01                   	Throw an validation error if User tries to cancel OER if any of the OEL's have any Work order status except for blank and unreleased  
    // 06-Jan-2021			Srikanth		projectconcrete 2.2  projectconcrete_2.2	
    // 06-Jan-2021 			Rekha    	    SW items invoice Hold    SW_ITEMS_INVOICE_HOLD
    // 12-Jan-2021			Srikanth   		SO Changes			SO_CHANGES_Jan_2021					
    // 18-Feb-2021	        Rekha           Validation on SSD   FIX_VALIDATION_ON_PAST_SSD          Update Order Entry Release Trigger to validate for OEL SSD > Today 
		
    Map<Id,Account> relatedAccountMap = new Map<Id,Account>();
    OrderEntryReleaseWrapper oerWrapper;
    Order_Entry_Release__c oer;
    Order_Entry_Release__c oerOld;
    Boolean fieldChange;
    Boolean lineItemsChanged;
    Boolean confirmationRequired;
    Boolean hasErrors;
    Boolean hasErrorsOnOEL;//CANCELLATION_BUGS_SEP_20
    Boolean preIntegration; 
    AddressLines addrLines;
    // 20180530 Changed to Support both SFDC and CPQ Quote..
    Id budgetaryEstimate;
    //MS
    List<RecordType> bidQuoteRecordType = new List<RecordType>();
    Map<Id, QuoteWrapper> quoteWrapperMap = new Map<Id, QuoteWrapper>();
    Map<Id,OrderEntryReleaseWrapper> oerWrapperMap = new Map<Id, OrderEntryReleaseWrapper>();
    //
    Id currentUserId = Id.valueOf(userinfo.getUserId());
    Set<Id> acctIds = new set<Id>();
    Set<Id> oerIDs = new Set<Id>();
    Set<Id> integrationOERIds = new Set<Id>();
    Set<Id> changedCPQQuoteIds = new Set<Id>();
    Set<Id> changedSFDCQuoteIDs = new Set<Id>();
    Set<String> oelHoldSkip = new Set<String> {'Shipped', 'Hold', 'Cancelled', 'Complete'};
        
        Set<String> preIntegrationStatus = new Set<String>{'Draft','Pre-Release Review', 'Confirmation Pending', 'Confirmed'};
            //Added by ENP - Planned
            Set<String> preConfirmationStatus = new Set<String> {'Draft','Pre-Release Review', 'Confirmation Pending','Planned'};
                Set<String> preConfirmationStatusCSS = new Set<String> {'Draft','Planned','Change Requested'};
                    // JV - 20180208 Changed "Shipping" to "Partially Shipped" 
                    // JV - 20180213 Added "Confirmation Pending"
                    // JV - 20180308 Removed "Shipped"
                    Set<String> fieldChangeOK = new Set<String> {'Draft', 'Pre-Release Review', 'Confirmed', 'Confirmation Pending', 'Pre-Production', 'In Production',
                        'Partially Shipped', 'Change Requested', 'Change Confirmation Required'};
                            //Added by ENP - Planned,Booked,Confirmation Requested,Confirmed
                            Set<String> fieldChangeCSSOK = new Set<String> {'Draft', 'Pre-Release Review', 'Pre-Production', 'In Production',
                                'Partially Shipped', 'Change Requested', 'Change Confirmation Required','Planned','Booked','Approved-to-Ship','Change Confirmation Pending'};
                                    //Added by ENP - Planned,Draft
                                    Set<String> fieldChangeSWOK = new Set<String> {'Draft','Planned'};
                                        //Added by ENP - Planned,Booked,Approved-to-Ship,Invoiced
                                        Set<String> hasShipped = new Set<String> {'Shipped', 'Complete', 'Invoiced'};
                                            // JV 20180208 - Added following for checking changes to shipping info
                                            List<Order_Entry_Line__c> oelsForUpdate = new List<Order_Entry_Line__c>();
    //Set<String> cascadeStateOnly = new Set<String> {'Draft', 'Pre-Release Review','Confirmation Pending'};
    //Added by ENP
    Set<String> cascadeStateOnly = new Set<String> {'Draft', 'Pre-Release Review','Confirmation Pending', 'Approved-to-Ship', 'Planned','Booked','Invoiced', 'Approval to Ship Requested'};
	// projectconcrete_2.2 
    Set<String> changeInPoNotAllowed = new Set<String> { 'Confirmation Requested',  'Confirmed', 'Integration Requested', 'Change Integration Requested', 'Change Confirmation Requested', 'Change Confirmed', 'Approval to Ship Requested' }; 
        // *** V.6 Change to handle OEL Record Type
        //Map<ID,RecordType> oelRecordTypeMap = Order_Entry_Trigger_Helper_2.getRecordTypeMap('Order_Entry_Line__c');
        //Added by ENP
        //Map<ID,RecordType> oerRecordTypeMap = Order_Entry_Trigger_Helper_2.getRecordTypeMap('Order_Entry_Release__c');
        Map<ID,Schema.RecordTypeInfo> oelRecordTypeMapSchema = Schema.SObjectType.Order_Entry_Line__c.getRecordTypeInfosById();
    Map<ID,Schema.RecordTypeInfo> oerRecordTypeMapSchema = Schema.SObjectType.Order_Entry_Release__c.getRecordTypeInfosById();
    Map<String, Double> currencyConversionMap = new Map<String, Double>();
    // JV 20200329 - Added code for to support Integration Rollback
    RollbackUtils rollbackUtils = new RollbackUtils();
    
    
    if (trigger.isUpdate && trigger.isBefore )
    {
        // **************************************************************************
        // * Processing Occuring before Updates are made.                           *
        // **************************************************************************
        //
        System.debug('entered');
        for(Order_Entry_Release__c oer: trigger.new)
        {
            // Preparation:
            // Create map of OER wrappers
            // Get Account info for Accounts referenced by the OERs
            // Create a list of OERs changed by the Integration IF
            // Get the Order Entry Lines for each OER to validate updates
            // Get Quote Lines if the Quote is changed for a Release
            //
            /*if(oer.Status__c != trigger.oldMap.get(oer.Id).Status__c && trigger.oldMap.get(oer.Id).Status__c == 'Integration Requested' && oer.Status__c == 'Planned'){
oer.Request_Date_Update_Needed__c = true;
}

if(oer.Request_Date__c != trigger.oldMap.get(oer.Id).Request_Date__c && oer.Request_Date_Update_Needed__c) {
oer.Request_Date_Update_Needed__c = false;
}*/
            
            System.debug('entered');
            if (oer.Trigger_Source__c != 'Release') // Exclude recursive updates
            {
                System.debug('entered');
                // JV 20200329 - Added code for to support Integration Rollback
                if ((Test.isRunningTest() && oer.Trigger_Source__c == 'Test Data Setup') || oer.Trigger_Source__c == 'Rollback') 
                {
                    oer.Trigger_Source__c = 'UI';
                }
                else
                {
                    oerWrapperMap.put(oer.Id, new OrderEntryReleaseWrapper(oer));
                    oerIds.add(oer.Id);
                    if (oer.Shipping_Account__c != null)
                    {
                        acctIds.add(oer.Shipping_Account__c);
                    }
                    if (oer.Billing_Account__c != null)
                    {
                        acctIds.add(oer.Billing_Account__c);
                    }
                    if (oer.Sold_to_Account__c != null)
                    {
                        acctIds.add(oer.Sold_to_Account__c);
                    }
                    if (oer.Trigger_Source__c == 'Integration')
                    {
                        integrationOERIds.add(oer.Id);
                    }
                    // 20180530 Changed to Support both SFDC and CPQ Quote..
                    if (oer.CPQ_Quote__c != trigger.oldMap.get(oer.Id).CPQ_Quote__c)
                    {
                        changedCPQQuoteIds.add(oer.CPQ_Quote__c);
                    }
                    if (oer.Quote__c != trigger.oldMap.get(oer.Id).Quote__c)
                    {
                        changedSFDCQuoteIds.add(oer.Quote__c);
                    }
                    //.. 20180530
                    
                }
            }
        }
        //Get Currency Conversion table - //Added by ENP
        for (CurrencyType cRates : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE]) {
            currencyConversionMap.put(cRates.IsoCode, cRates.ConversionRate);
        }
        for (Account acct : [SELECT Id, Name, BillingAddress, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, 
                             ShippingAddress, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry  from Account where Id in :acctIds])
        {
            relatedAccountMap.put(acct.Id, acct);
        }
        // JV 20171018 - Added Product__c to fields retrieved
        // JV 20171115 - Added RecordTypeId to fields retrieved
        // JV 20180208 - Added Promised_Date__c, First_Promised_Date__c, Previous_Promised_Date__c to fields retrived
        // JV 20180626 - Added CurrencyISOCode to fields retrieved
        // SW_ITEMS_INVOICE_HOLD
        for (Order_Entry_Line__c oel : [SELECT Id, Name,CurrencyISOCode, RecordTypeId, Line_Number__c, Cancellation_Date__c, Cancellation_Reason__c, First_Scheduled_Ship_Date__c, Product__c,
                                        First_Request_Ship_Date__c, Shipment_Date__c, Shipping_Account__c, Shipping_Address__c, Shipping_City__c, Shipping_Country__c, Shipping_Name__c,
                                        Shipping_Postal_Code__c, Shipping_State_Province__c, Shipping_Street_1__c, Shipping_Street_2__c, Shipping_Street_3__c, Order_Entry_Release__c,
                                        Use_Account_Shipping_Address__c, Trigger_Source__c, Integration_Status__c, Priority__c, Status__c, Hold_Reason__c, Hold_Comments__c, Hold_Type__c, Integration_Errors__c, Request_Date__c,
                                        Promised_Date__c , First_Promised_Date__c, Previous_Promised_Date__c,
                                        Pre_Change_Status__c,Part_Number__c,Scheduled_Ship_Date__c, Sales_Order_Line_Status__c,Work_Order_Status__c,Previous_Scheduled_Ship_Date__c, Previous_Request_Ship_Date__c, Integration_Action_Requested__c, CPQ_Quote_Line__c
                                        FROM Order_Entry_Line__c WHERE Order_Entry_Release__c IN :oerIDs])
        {
            // *** V.6 Change to handle OEL Record Type
            oerWrapperMap.get(oel.Order_Entry_Release__c).addOrderEntryLine(oel, oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName());         
            //           oerWrapperMap.get(oel.Order_Entry_Release__c).addOrderEntryLine(oel);
        }
        
        // 20180530 Changed to Support both SFDC and CPQ Quote..
        
        if (changedCPQQuoteIds.size() > 0)
        {
            //MS commenting the SOQL line
            //RecordType qrt = [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType WHERE IsActive = true AND SObjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Budgetary_Estimate' LIMIT 1];
            //budgetaryEstimate = qrt.Id;
            // JV - 20180626 - Added CurrencyISOCode fields
            bidQuoteRecordType = [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType WHERE IsActive = true AND SObjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Budgetary_Estimate','Bid_Quote_Locked_Approved', 'Bid_Quote_Locked_Record_Type') ];
            for(SBQQ__Quote__c qte : [SELECT Id, CurrencyISOCode, RecordTypeId, name, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE id IN :changedCPQQuoteIds])
            {
                quoteWrapperMap.put(qte.id, new QuoteWrapper(qte));
            }           
        }
        if (changedSFDCQuoteIds.size() > 0)
        {
            // JV - 20180626 - Added CurrencyISOCode fields
            for(Quote qte : [SELECT Id, name, CurrencyISOCode, OpportunityId, QuoteNumber FROM Quote WHERE id IN :changedSFDCQuoteIds])
            {
                quoteWrapperMap.put(qte.id, new QuoteWrapper(qte));
            }           
        }
        
        if (changedCPQQuoteIds.size() > 0)
        {
            for(SBQQ__QuoteLine__c qli : [SELECT Id, CurrencyISOCode, SBQQ__Product__c, SBQQ__Quote__c, SBQQ__CustomerPrice__c, SBQQ__Discount__c, SBQQ__Quantity__c, Product_SKU__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c IN :changedCPQQuoteIds])
            {
                quoteWrapperMap.get(qli.SBQQ__Quote__c).addQuoteLineItem(qli);
            }
        }
        if (changedSFDCQuoteIDs.size() > 0)
        {
            // JV - 20180626 - Added CurrencyISOCode fields
            for(QuoteLineItem qli : [SELECT Id, CurrencyISOCode, Product2Id, QuoteId, UnitPrice, Discount,Product_SKU__c FROM QuoteLineItem where QuoteId IN :changedSFDCQuoteIDs])
            {
                quoteWrapperMap.get(qli.QuoteID).addQuoteLineItem(qli);
            }
        }
        // .. 20180530
        
        hasErrors = false;
        hasErrorsOnOEL = false;//CANCELLATION_BUGS_SEP_20
        for (OrderEntryReleaseWrapper oerw : oerWrapperMap.values())
        {
            // ******************************************************************************
            // * Main loop for processing non-Integration updates from UIs and Line Trigger *
            // ******************************************************************************
            //
            
            if (oerw.oer.Status__c == 'Approval to Ship Requested' && oerw.oer.Integration_Status__c == 'Complete' && 
                trigger.oldMap.get(oerw.oer.Id).Integration_Status__c!= 'Complete' && oerw.oer.Oracle_SO_Number__c == null && oerw.oer.Oracle_Sales_Order_Id__c!= null && !oerRecordTypeMapSchema.get(oerw.oer.RecordTypeID).getDeveloperName().contains('IGU')){
                    
                    
                    oerw.oer.Oracle_SO_Number__c= oerw.oer.Oracle_Sales_Order_Id__c;
                }
            if (oerw.oer.Trigger_Source__c == null || oerw.oer.Trigger_Source__c == 'UI') 
            {
                fieldChange = false;
                confirmationRequired = false;
                preIntegration = false;
                lineItemsChanged = false;
                
                oer = oerw.oer;
                oerOld = trigger.oldMap.get(oer.Id);
                system.debug('entered');
                if (oerOld.Integration_Status__c != null && oerOld.Integration_Status__c != 'Requested' && oerOld.Integration_Status__c != 'Initial' && oerOld.Integration_Status__c != 'Complete' && 
                    oerOld.Integration_Status__c != 'Error' )
                {
                    oerw.addValidationError('Update is not permitted while integration is in process');
                    hasErrors = true;
                }
                // projectconcrete_2.2 
                if (changeInPoNotAllowed.contains(oer.Status__c)  && oer.Customer_P_O_Number__c != oerOld.Customer_P_O_Number__c) {
                    hasErrors = true; 
                    oerw.addValidationError('Changes to field ‘Customer P.O. Number’ is not permitted when Release Status is ' + oerOld.Status__c); 
                }
                //
                // Check for Field Changes and Set Change Type Requested
                //
                if (oer.Shipping_City__c !=  oerOld.Shipping_City__c ||
                    oer.Shipping_Country__c !=  oerOld.Shipping_Country__c ||
                    oer.Shipping_Name__c !=  oerOld.Shipping_Name__c ||
                    oer.Shipping_Postal_Code__c !=  oerOld.Shipping_Postal_Code__c ||
                    oer.Shipping_State_Province__c !=  oerOld.Shipping_State_Province__c ||
                    oer.Shipping_Street_1__c !=  oerOld.Shipping_Street_1__c ||
                    oer.Shipping_Street_2__c !=  oerOld.Shipping_Street_2__c ||
                    oer.Shipping_Street_3__c !=  oerOld.Shipping_Street_3__c
                   )
                {   
                    if (hasShipped.contains(oerOld.Status__c))
                    {
                        // JV 20180208 - Added check to prevent changes to the Shipping Address after Order has shipped
                        hasErrors = true;
                        oerw.addValidationError('Changes to Shipping Address are not allowed when Release Status = ' + oerOld.Status__c);
                    }
                    else
                    {
                        oer.Shipping_Country__c = AddressUtils.getStandardName(oer.Shipping_Country__c);
                        addrLines = new AddressLines();
                        addrLines.name = oer.Shipping_Name__c;
                        addrLines.street1 = oer.Shipping_Street_1__c;
                        addrLines.street2 = oer.Shipping_Street_2__c;
                        addrLines.street3 = oer.Shipping_Street_3__c;
                        addrLines.city = oer.Shipping_City__c;
                        addrLines.stateProvince = oer.Shipping_State_Province__c;
                        addrLines.postalCode = oer.Shipping_Postal_Code__c;
                        addrLines.country = oer.Shipping_Country__c;
                        oer.Shipping_Address__c = AddressUtils.formatAddress(oer.Shipping_Name__c, addrLines, true);
                        fieldChange = true;
                        lineItemsChanged = true;
                        
                        //if (oer.Status__c == 'Approved-to-Ship')
                        // confirmationRequired = true;
                        oerw.copyShippingInfoToLines(false); 
                        
                    }
                }
                // projectconcrete_2.2 
                if (oer.Billing_Street_1__c != oerOld.Billing_Street_1__c || 
                    oer.Billing_Street_2__c != oerOld.Billing_Street_2__c || 
                    oer.Billing_Street_3__c != oerOld.Billing_Street_3__c || 
                    oer.Billing_City__c != oerOld.Billing_City__c || 
                    oer.Billing_State_Province__c != oerOld.Billing_State_Province__c || 
                    oer.Billing_Postal_Code__c != oerOld.Billing_Postal_Code__c || 
                    oer.Billing_Country__c != oerOld.Billing_Country__c)
                { 
                    fieldChange = true;
                } 
                if (oer.Billing_Account__c !=  oerOld.Billing_Account__c)
                {
                    // projectconcrete_2.2   
                    if ((oer.Pre_Change_Status__c == 'Partially Shipped' && oer.Status__c == 'Change Requested') ||  oer.Status__c == 'Partially Shipped' ) 
                    { 
                        oerw.addValidationError('Changes to field ‘Billing Account’ is not permitted when Release Status is ' + oerOld.Status__c);   
                        hasErrors = true;
                    }  
                    else 
                    {
                        // JV 20171020 - Moved the following statement from within the Billing Address processing
                        fieldChange = true;
                        if (oer.Billing_Account__c != null)
                        {
                            Address billingAddress;
                            if (relatedAccountMap.get(oer.Billing_Account__c).BillingStreet != null || relatedAccountMap.get(oer.Billing_Account__c).BillingCity != null)
                            {
                                billingAddress = relatedAccountMap.get(oer.Billing_Account__c).BillingAddress;
                            }
                            else
                            {
                                if (relatedAccountMap.get(oer.Billing_Account__c).ShippingStreet != null || relatedAccountMap.get(oer.Billing_Account__c).ShippingCity != null)
                                {
                                    billingAddress = relatedAccountMap.get(oer.Billing_Account__c).ShippingAddress;
                                }
                                else
                                {
                                    oerw.addValidationError('Billing Account has no valid addresses.');
                                    hasErrors = true;
                                }
                            }
                            if (billingAddress != null)
                            {
                                oer.Billing_Address__c = AddressUtils.formatAddress(relatedAccountMap.get(oer.Billing_Account__c).Name, billingAddress);
                                addrLines = new AddressLines(relatedAccountMap.get(oer.Billing_Account__c).Name, billingAddress);
                                oer.Billing_Street_1__c = addrLines.street1;
                                oer.Billing_Street_2__c = addrLines.street2;
                                oer.Billing_Street_3__c = addrLines.street3;
                                oer.Billing_City__c = addrLines.city;
                                oer.Billing_State_Province__c = addrLines.stateProvince;
                                oer.Billing_Postal_Code__c = addrLines.postalCode;
                                oer.Billing_Country__c = AddressUtils.getStandardName(addrLines.country);
                            }
                        }
                        else
                        {
                            oerw.addValidationError('Billing Account is a required field; it may not be null');
                            hasErrors = true;
                        }
                    }
                }
                // projectconcrete_2.2 
                if (oer.Sold_To_Street_1__c != oerOld.Sold_To_Street_1__c || 
                    oer.Sold_To_Street_2__c != oerOld.Sold_To_Street_2__c || 
                    oer.Sold_To_Street_3__c != oerOld.Sold_To_Street_3__c || 
                    oer.Sold_To_City__c != oerOld.Sold_To_City__c || 
                    oer.Sold_To_State_Province__c != oerOld.Sold_To_State_Province__c || 
                    oer.Sold_To_Postal_Code__c != oerOld.Sold_To_Postal_Code__c ||
                    oer.Sold_To_Country__c != oerOld.Sold_To_Country__c) 
                {
                    fieldChange = true;
                    
                }
                if (oer.Sold_to_Account__c !=  oerOld.Sold_to_Account__c)
                {                   
                    if(oer.Sold_to_Account__c != null)
                    {
                        // projectconcrete_2.2   
                        if ((oer.Pre_Change_Status__c == 'Partially Shipped' && oer.Status__c == 'Change Requested') ||  oer.Status__c == 'Partially Shipped' ) 
                        { 
                            oerw.addValidationError('Changes to field ‘Sold-to Account’ is not permitted when Release Status is ' + oerOld.Status__c);   
                            hasErrors = true;  
                        }  
                        else 
                        {
                            // JV 20171020 - Moved the following statement from within the Sold-to Address processing
                            fieldChange = true;
                            Address soldToAddress;
                            if (relatedAccountMap.get(oer.Sold_to_Account__c).BillingStreet != null || relatedAccountMap.get(oer.Sold_to_Account__c).BillingCity != null)
                            {
                                soldToAddress = relatedAccountMap.get(oer.Sold_to_Account__c).BillingAddress;
                            }
                            else
                            {
                                if (relatedAccountMap.get(oer.Sold_to_Account__c).ShippingStreet != null || relatedAccountMap.get(oer.Sold_to_Account__c).ShippingCity != null)
                                {
                                    soldToAddress = relatedAccountMap.get(oer.Sold_to_Account__c).ShippingAddress;
                                }
                                else
                                {
                                    oerw.addValidationError('Sold-to Account has no valid address.');
                                    hasErrors = true;
                                }
                            }
                            
                            if (soldToAddress != null)
                            {
                                oer.Sold_To_Address__c = AddressUtils.formatAddress(relatedAccountMap.get(oer.Sold_To_Account__c).Name, soldToAddress);
                                addrLines = new AddressLines(relatedAccountMap.get(oer.Sold_To_Account__c).Name, soldToAddress);
                                oer.Sold_To_Street_1__c = addrLines.street1;
                                oer.Sold_To_Street_2__c = addrLines.street2;
                                oer.Sold_To_Street_3__c = addrLines.street3;
                                oer.Sold_To_City__c = addrLines.city;
                                oer.Sold_To_State_Province__c = addrLines.stateProvince;
                                oer.Sold_To_Postal_Code__c = addrLines.postalCode;
                                oer.Sold_To_Country__c = AddressUtils.getStandardName(addrLines.country);
                                fieldChange = true;
                            }
                        }
                    }
                    else
                    {
                        oerw.addValidationError('Sold-to Account is a required field; it may not be null.');
                        hasErrors = true;
                    }
                }
                // JV - 20180208 Added the following code to support Promised Date
                //Added by ENP - Bypass Date Fields for SW and Service
                //if(!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains(Label.CSS_Software)){
                if(oer.Promised_Date__c != oerOld.Promised_Date__c)
                {
                    fieldChange = true;
                    lineItemsChanged = true;
                    oer.Previous_Promised_Date__c = oerOld.Promised_Date__c;
                    oerw.setLineFields('Promised Date', oer.Promised_Date__c); 
                    if (!preIntegrationStatus.contains(oer.Status__c))
                    {
                        if (oer.First_Promised_Date__c == null)
                        {
                            oer.First_Promised_Date__c = oer.Promised_Date__c;
                        }
                    }
                    //Added by enp
                    //if(!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU') && !preConfirmationStatusCSS.contains(oer.Status__c))
                    // confirmationRequired = true;
                    
                }
                
                if(oer.Request_Date__c != oerOld.Request_Date__c)
                {
                    fieldChange = true;
                    lineItemsChanged = true;
                    oerw.setLineFields('Request Date', oer.Request_Date__c); 
                    oer.Previous_Request_Ship_Date__c = oerOld.Request_Date__c;
                    if (!preIntegrationStatus.contains(oer.Status__c))
                    {
                        if (oer.First_Request_Ship_Date__c == null)
                        {
                            oer.First_Request_Ship_Date__c = oer.Request_Date__c;
                        }
                    }
                    //Added by enp
                    // if(!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU') && !preConfirmationStatusCSS.contains(oer.Status__c))
                    //confirmationRequired = true;
                }
                
                if(oer.Scheduled_Ship_Date__c != oerOld.Scheduled_Ship_Date__c)
                {
                    fieldChange = true;
                    lineItemsChanged = true;
                    oerw.setLineFields('Committed Date', oer.Scheduled_Ship_Date__c);
                    oer.Previous_Scheduled_Ship_Date__c = oerOld.Scheduled_Ship_Date__c; 
                    if (!preIntegrationStatus.contains(oer.Status__c))
                    {
                        if (oer.First_Scheduled_Ship_Date__c == null)
                        {
                            oer.First_Scheduled_Ship_Date__c = oer.Scheduled_Ship_Date__c;
                        }
                    }
                    //Added by enp
                    // if(!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU') && !preConfirmationStatusCSS.contains(oer.Status__c))
                    //confirmationRequired = true;
                }
                system.debug('@@confirmationRequired'+confirmationRequired);
                //}
                
                if(oer.Packing_Instructions__c != oerOld.Packing_Instructions__c)
                {
                    fieldChange = true;
                }
                // 20180530 Changed to Support both SFDC and CPQ Quote..*************************************
                
                Boolean quotesOK = true;
                Boolean quoteChanged = false;
                Id changedQuoteId;
                if (oer.CPQ_Quote__c == null)
                {
                    if (oer.Quote__c == null)
                    {
                        
                        if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU')){ // Added by ENP
                            oerw.addValidationError('CPQ Quote and SFDC Quote may not both be null.');
                            hasErrors = true;//Added by enp narasimha
                            quotesOK = false;
                        }
                    }
                    else
                    {
                        if (oerOld.CPQ_Quote__c != null)
                        {
                            hasErrors = true;
                            quotesOK = false;
                            oerw.addValidationError('Once an Order Entry Release has been created, it the Quote Source may not be changed from CPQ to SFDC') ;
                        }
                        else
                        {
                            if (oerOld.Quote__c != oer.Quote__c)
                            {
                                 // projectconcrete_2.2 
                                if ((oer.Pre_Change_Status__c == 'Partially Shipped' && oer.Status__c == 'Change Requested') ||  oer.Status__c == 'Partially Shipped') 
                                {  
                                    oerw.addValidationError('Changes to field ‘SFDC Quote’ is not permitted when Release Status is ' + oerOld.Status__c); 
                                    hasErrors = true; 
                                }
                                if(oerOld.Status__c == 'Approved-to-Ship')
                                {
                                    hasErrors = true;
                                    quotesOK = false;
                                    oerw.addValidationError('SFDC Quote may not be changed after booked Order Entry Release');
                                }
                                if (quoteWrapperMap.get(oer.Quote__c).currencyISOCode != oer.CurrencyISOCode)
                                {
                                    hasErrors = true;
                                    oerw.addValidationError('SFDC Quote may not be changed to one having a different currency from the Order Entry Release');
                                }
                                else 
                                {
                                    changedQuoteId = oer.Quote__c;
                                    quoteChanged = true;
                                }
                            }
                        }                       
                    }                   
                }
                else
                {
                    if (oer.Quote__c != null)
                    {
                        hasErrors = true;
                        quotesOK = false;
                        oerw.addValidationError('Order Entry Release may not have both CPQ and SFDC Quotes.');
                    }
                    else
                    {
                        if (oerOld.Quote__c != null)
                        {
                            hasErrors = true;
                            quotesOK = false;
                            oerw.addValidationError('Once an Order Entry Release has been created, it the Quote Source may not be changed from SFDC to CPQ') ;
                        }
                        else
                        {
                            if(oerOld.CPQ_Quote__c != oer.CPQ_Quote__c)
                            {
								//projectconcrete_2.2
                                if ((oer.Pre_Change_Status__c == 'Partially Shipped' && oer.Status__c == 'Change Requested') ||  oer.Status__c == 'Partially Shipped') 
                                {  
                                    oerw.addValidationError('Changes to field ‘CPQ Quote’ is not permitted when Release Status is ' + oerOld.Status__c); 
                                    hasErrors = true; 
                                } 
                                if(oerOld.Status__c == 'Approved-to-Ship')
                                {
                                    hasErrors = true;
                                    quotesOK = false;
                                    oerw.addValidationError('CPQ Quote may not be changed after booked Order Entry Release');
                                }
                                boolean bidQuoteRecordTypeList = true;                            
                                for(RecordType rt : bidQuoteRecordType ){
                                    if(quoteWrapperMap.get(oer.CPQ_Quote__c).RecordTypeId == rt.id){
                                        bidQuoteRecordTypeList = false;
                                    }                           
                                }                            
                                if(bidQuoteRecordTypeList){
                                    hasErrors = true;
                                    quotesOK = false;
                                    oerw.addValidationError('The selected CPQ Quote is not a Bid Quote Record Type');                            
                                }
                                else
                                {
                                    if (quoteWrapperMap.get(oer.CPQ_Quote__c).currencyISOCode != oer.CurrencyISOCode)
                                    {
                                        hasErrors = true;
                                        oerw.addValidationError('Order Header\'s currency has to be same as selected Quote\'s currency');
                                    }
                                    else{
                                        quoteChanged = true;
                                        changedQuoteId = oer.CPQ_Quote__c;
                                    }
                                }
                                
                                //MS commented if else statements here
                                /*if (quoteWrapperMap.get(oer.CPQ_Quote__c).RecordTypeId != budgetaryEstimate)
{
hasErrors = true;
quotesOK = false;
oerw.addValidationError('The selected CPQ Quote is not a Bugetary Estimate Quote Record Type');
}
else
{
if (quoteWrapperMap.get(oer.CPQ_Quote__c).currencyISOCode != oer.CurrencyISOCode)
{
hasErrors = true;
oerw.addValidationError('Order Header's currency has to be same as selected Quote's currency');
}
else
{
quoteChanged = true;
changedQuoteId = oer.CPQ_Quote__c;
}
}*/                               
                            }
                        }
                    }
                }
                
                
                if (quotesOK && quoteChanged)
                {
                    Boolean unlinkedLine = false;                    
                    for (OrderEntryLineWrapper oelw : oerw.oelwList)
                    {
                        if (!oelw.oel.Status__c.contains('Cancel'))
                        {
                            System.debug('######changedQuoteId'+changedQuoteId);
                            System.debug('######oelw.oel.Product__c'+oelw.oel.Product__c);
                            System.debug('######oelw.oel.Product__c'+quoteWrapperMap.get(changedQuoteId).getQuoteLineWrapper(oelw.oel.Product__c));
                            if (quoteWrapperMap.get(changedQuoteId).getQuoteLineWrapper(oelw.oel.Product__c) != null)                            
                            {    
                                QuoteLineWrapper qlw = quoteWrapperMap.get(changedQuoteId).getQuoteLineWrapper(oelw.oel.Product__c);
                                if (qlw.source == 'CPQ')
                                {
                                    oelw.oel.CPQ_Quote_Line__c = qlw.quoteLineId;
                                }
                                else
                                {
                                    oelw.oel.Quote_Line_Item__c = qlw.quoteLineId;
                                }
                                oelw.isUpdated = true;
                            }
                            else
                            {
                                if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU')) {// Added by ENP
                                    oerw.addValidationError('Updated Order Entry Release Quote has no matching Line Item for Order Entry Line Number ' + 
                                                            String.valueOf(oelw.oel.Line_Number__c));
                                    hasErrors = true;
                                    unlinkedLine = true;
                                }
                            }
                        }
                        if (!unlinkedLine)
                        {
                            fieldChange = true;
                            if((!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU') && !preConfirmationStatusCSS.contains(oer.Status__c)) || oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                                confirmationRequired = true;
                            lineItemsChanged = true;
                        }                        
                    }
                }
                // ..20180530 *****************************************************************                 
                if (oer.Deposit_Amount__c != oerOld.Deposit_Amount__c)
                {
                    if (preIntegrationStatus.contains(oerOld.Status__c))
                    {
                        fieldChange = true;
                    }
                    else
                    {
                        hasErrors = true;
                        oerw.addValidationError('Deposit Amount may not be changed after Oracle integration completed.');
                    }
                }
                if (oer.Freight__c != oerOld.Freight__c)
                {
                    // projectconcrete_2.2  
                    if ((oer.Pre_Change_Status__c == 'Partially Shipped' && oer.Status__c == 'Change Requested') ||  oer.Status__c == 'Partially Shipped') 
                    {  
                        oerw.addValidationError('Changes to field ‘Freight’ is not permitted when Release Status is ' + oerOld.Status__c); 
                        hasErrors = true; 
                    }    
                    else 
                    {     
                        fieldChange = true; 
                    }
                }
                
                if (oer.Shipping_Container__c != oerOld.Shipping_Container__c)
                {
                    fieldChange = true;
                }
                
                if (oer.Payment_Terms__c != oerOld.Payment_Terms__c)
                {
                    // projectconcrete_2.2  
                    if ((oer.Pre_Change_Status__c == 'Partially Shipped' && oer.Status__c == 'Change Requested') ||  oer.Status__c == 'Partially Shipped') 
                    {  
                        oerw.addValidationError('Changes to field ‘Payment Terms’ is not permitted when Release Status is ' + oerOld.Status__c); 
                        hasErrors = true; 
                    }    
                    else 
                    {    
                        fieldChange = true; 
                    } 
                }
                
                if(oer.CurrencyISOCode != oerOld.CurrencyISOCode)
                {
                    if (oer.CurrencyISOCode == null)
                    {
                        hasErrors = true;
                        oerw.addValidationError('Currency may not be null');                    
                    }
                    else
                    {
                        if (oerw.oelCount != null && oerw.oelCount > 0)
                        {
                            hasErrors = true;
                            oerw.addValidationError('Currency cannot be changed when the Order Header has Order Lines');
                        }
                        else
                        {
                            //Added by ENP - Populate CurrencyConversionRate
                            if(oer.CurrencyISOCOde != null){                
                                if(currencyConversionMap<>null)
                                    oer.Conversion_Rate_Integration_Requested__c = currencyConversionMap.get(oer.CurrencyISOCOde);
                            }
                            fieldChange = true;
                        }
                    }                   
                    
                }
                
                
                
                
                
                if (fieldChange)
                {
                    if ((!fieldChangeOK.contains(oerOld.Status__c) && oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                        || (!fieldChangeCSSOK.contains(oerOld.Status__c) && oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().containsIgnoreCase(Label.CSS_Hardware))
                        || (!fieldChangeSWOK.contains(oerOld.Status__c) &&  oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().containsIgnoreCase(Label.CSS_Software)))
                    {
                        hasErrors = true;
                        oerw.addValidationError('Changes to field values are not permitted when Release Status is ' + oerOld.Status__c);
                    }
                    else
                    {
                        // JV - 20180327 - Added the if.. check for !preIntegrationStatus
                        if (!preIntegrationStatus.contains(oerOld.Status__c))
                        {
                            if (lineItemsChanged)
                            {
                                oerw.oer.Integration_Scope__c = 'Release and Line Items';
                            }
                            else
                            {
                                oerw.setIntegrationScope('Release');
                            }
                        }
                    }
                }
                //              
                //Added by enp phase-1
                if(oer.Customer_Confirmation_Signed__c && oer.Status__c == 'Confirmation Requested'){
                    oer.Status__c = 'Confirmed';
                    oer.Customer_Confirmation_Signed__c=false;
                }
                
                // Check for Status changes from UI or Line Updates
                // 
                
                if (oer.Status__c != oerOld.Status__c)
                {
                    //
                    
                    // States which are cascaded without further processing
                    //oerOld.Status__c = ' Integration Error' Added by enp-Narasimha
                    
                    if (cascadeStateOnly.contains(oer.Status__c) || oerOld.Status__c == 'Integration Error')
                    {
                        
                        for (OrderEntryLineWrapper oelw : oerw.oelwList)
                        {
                            
                            if (oelw.oel.Status__c == oerOld.Status__c)
                            {
                                oelw.oel.Status__c = oer.Status__c;
                                oelw.isUpdated = true;
                                
                            }
                        }                           
                    }
                    
                    
                    
                    //
                    // Check to see if the Status change is allowed by workflow sequence constraints
                    //
                    
                    System.debug('@@#####'+oer);
                    //Added by ENP - New Parameter  - Record Type
                    String statusCheck = StateTransitionMap.checkStatusChange(oerOld.Status__c, oer.Status__c, oerOld.Integration_Status__c, oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName());
                    if (statusCheck != 'OK')
                    {
                        oerw.addValidationError(statusCheck);
                        hasErrors = true;
                    }
                    else
                    {
                        //
                        // Handling Status Changes Requiring special actions
                        //                   
                        if (oer.Status__c.contains('Cancel'))
                        {
                            //
                            // Cancellation Processing
                            //
                            if (fieldChange)
                            {
                                //
                                // If cancellation is in progress, don't allow other changes in the same transaction
                                //
                                oerw.addValidationError('Changes to other field values are not allowed during the cancellation process');
                                hasErrors = true;
                            }
                            //Srikanth - SOLS_PICKED_SHIPPED_CLOSED_VLD_02 adding for adding condition to validate Picked/Closed/Shipped SOLS values 
                            //CANCELLATION_BUGS_SEP_20 Start
                            hasErrorsOnOEL = false;                           
                            List<String> SOLSFilter = new List<String>{'Picked','Closed','Shipped'};
                            //SO_CHANGES_Jan_2021
                            for( OrderEntryLineWrapper oelw : oerw.oelwList )
                            {
                                if((SOLSFilter.Contains(oelw.oel.Sales_Order_Line_Status__c) && (!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))) ||
                                  ((SOLSFilter.Contains(oelw.oel.Sales_Order_Line_Status__c) || oelw.oel.Sales_Order_Line_Status__c == 'Packed' ) && (oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU')))
                                  )
                                {
                                    hasErrors = true;
                                    hasErrorsOnOEL = true;
                               }
                            } 
                            if (hasErrorsOnOEL)
                            {
                                if (oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                                	oerw.addValidationError('Order cannot be cancelled when any of the Order Lines has OEL SOLS as Packed or Picked or Shipped or Closed');
                                else
                                    oerw.addValidationError('Order cannot be cancelled when any of the Order Lines has OEL SOLS as Picked or Shipped or Closed');
                                hasErrorsOnOEL = false;
                            }
                            //Rekha - CANCELLATION_BUGS_SEP_20 To validate any Work order status except for blank and unreleased   
                            //SO_CHANGES_Jan_2021
                            /*                         
                            for( OrderEntryLineWrapper oelw : oerw.oelwList )
                            { 
                                  
                                if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU') && oelw.oel.Work_Order_Status__c != null && oelw.oel.Work_Order_Status__c != 'Unreleased')
                                {
                                    hasErrors = true;
                                    hasErrorsOnOEL = true;
                                }  
                            }  
                            if (hasErrorsOnOEL)
                            {
                                hasErrorsOnOEL = false;
                                oerw.addValidationError('Order cannot be cancelled when any of the Order Lines has Work order status except blank or unreleased');
                            }*/
                            //CANCELLATION_BUGS_SEP_20 End
                            // Added by Anil - 05/03/2019
                            if (oer.Status__c == 'Cancelled' && !oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU') && oerOld.Status__c == 'Draft')
                            {
                                // Reason required for cancellation
                                if (oer.Cancellation_Reason__c == null){
                                    oerw.addValidationError('You must enter a cancellation reason');
                                    hasErrors = true;
                                }
                                else{
                                    for (OrderEntryLineWrapper oelw : oerw.oelwList){
                                        oelw.oel.Status__c = 'Cancelled';
                                        oelw.oel.Cancellation_Reason__c = oer.Cancellation_Reason__c;
                                        oelw.isUpdated = true;
                                    }   
                                    oer.Status__c = 'Cancelled';
                                }
                            }
                            // End by Anil - 05/03/2019
                            
                            else if (oer.Status__c == 'Cancellation Requested')
                            {
                                // Reason required for cancellation
                                if (oer.Cancellation_Reason__c == null)
                                {
                                    oerw.addValidationError('You must enter a cancellation reason');
                                    hasErrors = true;
                                }
                                else
                                {
                                    
                                    // JV 20171018T1359 - Changed oer.Status to oerOld.Status below...
                                    if (preConfirmationStatus.contains(oerOld.Status__c) && oerw.allLinesPreConfirmation())                         
                                    {
                                        System.debug('*** OER and OELs all Pre-Confirmation');
                                        
                                        for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                        {
                                            if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                                                oelw.oel.Status__c = 'Cancelled';
                                            else
                                                oelw.oel.Status__c = 'Cancellation Requested';
                                            oelw.oel.Cancellation_Reason__c = oer.Cancellation_Reason__c;
                                            oelw.isUpdated = true;
                                        }   
                                        if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                                            oer.Status__c = 'Cancelled';
                                        
                                        
                                    }
                                    else // Not Pre-Confirmation
                                    {
                                        Boolean oelCancelOK = true;
                                        for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                            //
                                            // Order Entry Release cannot be cancelled if any of its Order Entry Lines cannot be cancelled.
                                            //
                                        {               
                                            if (!oelw.oel.Status__c.contains('Cancel') && oelw.oel.Status__c != 'Shipped' && oelw.oel.Status__c !='Complete')
                                            {
                                                //System.debug('@@#####'+oelw.oel.RecordType.DeveloperName);
                                                //Added by ENP - New Parameter  - Record Type
                                                String oelStatusCheck = StateTransitionMap.checkStatusChange(oelw.oel.Status__c, 'Cancellation Requested', oelw.oel.Integration_Status__c, oelRecordTypeMapSchema.get(oelw.oel.RecordTypeID).getDeveloperName());
                                                if (oelStatusCheck != 'OK')
                                                {
                                                    hasErrors = true;
                                                    oerw.addValidationError('Order Entry Line ' + String.valueOf(oelw.oel.Line_Number__c) + ' cannot be cancelled; Status is ' + oelw.oel.Status__c);
                                                    oelCancelOK = false;                                      
                                                }
                                            }
                                        }
                                        if (oelCancelOK)
                                        {
                                            oer.Integration_Scope__c = 'Release and Line Items';
                                            for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                            {
                                                if (!oelw.oel.Status__c.contains('Cancel') && oelw.oel.Status__c != 'Shipped' && oelw.oel.Status__c !='Complete')
                                                {                                                   
                                                    oelw.oel.Cancellation_Reason__c = oer.Cancellation_Reason__c;
                                                    oelw.isUpdated = true;
                                                    oelw.oel.Status__c = 'Cancellation Confirmation Pending';
                                                }
                                            }
                                            oer.Pre_Cancellation_Status__c = oerOld.Status__c;
                                            oer.Status__c = 'Cancellation Confirmation Pending';
                                            
                                        }
                                    } // End not Pre-Confirmation
                                }                               
                            } 
                            else
                            {
                                if (oer.Status__c == 'Cancellation Confirmation Requested')
                                {
                                    oer.Integration_Scope__c = 'Release and Line Items';
                                    for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                    {
                                        if (oelw.oel.Status__c == 'Cancellation Confirmation Pending')
                                        {
                                            oelw.oel.Status__c = 'Cancellation Confirmation Requested';
                                            oelw.isUpdated = true;
                                        }
                                    }
                                }
                                else
                                {
                                    if (oer.Status__c == 'Cancellation Confirmed')
                                    {
                                        oer.Integration_Scope__c = 'Release and Line Items';
                                        for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                        {
                                            if (oelw.oel.Status__c == 'Cancellation Confirmation Requested')
                                            {
                                                oelw.oel.Status__c = 'Cancellation Confirmed';
                                                oelw.isUpdated = true;
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if (oer.Status__c == 'Cancellation Integration Requested')
                                        {
                                            //Added by ENP
                                            if (oer.Cancellation_Reason__c == null){
                                                oerw.addValidationError('You must enter a cancellation reason');
                                                hasErrors = true;
                                            }
                                            // JV - 20200329 Added Rollback Creation
                                            else {
                                                Rollback_Order_Entry_Release__c rboer = rollbackUtils.createOERRollback(oerOld);
                                                if(rboer.Rollback_Errors__c != null) {
                                                    oerw.addValidationError(rboer.Rollback_Errors__c);
                                                    hasErrors = true;
                                                }                                
                                                else
                                                {
                                                    oer.Integration_Scope__c = 'Release and Line Items';            
                                                    oer.Integration_Action_Requested__c = 'Cancel';
                                                    oer.Integration_Requestor__c = currentUserId;
                                                    //if(!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                                                    //oer.Integration_Status__c = 'Requested';
                                                    //else
                                                    oer.Integration_Status__c = 'Change Requested';
                                                    oer.Integration_Errors__c = null;
                                                    for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                                    {
                                                        if (oelw.oel.Status__c == 'Cancellation Confirmed' || oelw.oel.Status__c == 'Planned' || oelw.oel.Status__c == 'Cancellation Requested') // Added by AS - 19/02
                                                        {
                                                            oelw.oel.Status__c = 'Cancellation Integration Requested';
                                                            oelw.isUpdated = true;  
                                                            //if(!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                                                            //oelw.oel.Integration_Status__c = 'Requested';
                                                            //else
                                                            oelw.oel.Integration_Status__c = 'Change Requested';
                                                            oelw.oel.Integration_Action_Requested__c = 'Cancel';
                                                            oelw.oel.Integration_Errors__c = null;                                           
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } // End Cancellation Processing
                        // 
                        // Process Holds
                        //
                        if (oer.Status__c.contains('Hold'))
                        {
                            if (fieldChange)
                            {
                                oerw.addValidationError('Changes to other field values are not allowed during the hold process');
                                hasErrors = true;
                            }
                            if (oer.Status__c == 'Hold Requested')
                            {
                                if (oer.Hold_Reason__c == null)
                                {
                                    oerw.addValidationError('You must enter a hold reason');
                                    hasErrors = true;
                                }
                                else
                                {
                                    if (preIntegrationStatus.contains(oer.Status__c) && oerw.allLinesPreIntegration())
                                    {
                                        for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                        {
                                            oelw.oel.Status__c = 'Hold';
                                            oelw.oel.Hold_Reason__c = oer.Hold_Reason__c;
                                            oelw.isUpdated = true;                                          
                                        }
                                        oer.Status__c = 'Hold';
                                    }
                                    else
                                    {
                                        Boolean oelHoldOK = true;
                                        for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                        {
                                            oer.Integration_Scope__c = 'Release and Line Items';
                                            if (!oelHoldSkip.contains(oelw.oel.Status__c))
                                            {
                                                //System.debug('@@@#$$'+oelw.oel.RecordType.DeveloperName);
                                                //Added by ENP - New Parameter  - Record Type
                                                String oelStatusCheck = StateTransitionMap.checkStatusChange(oelw.oel.Status__c, 'Hold Requested', oelw.oel.Integration_Status__c, oelRecordTypeMapSchema.get(oelw.oel.RecordTypeID).getDeveloperName());
                                                if (oelStatusCheck != 'OK')
                                                {
                                                    hasErrors = true;
                                                    oerw.addValidationError('Order Entry Line ' + String.valueOf(oelw.oel.Line_Number__c) + ' cannot be placed on Hold; Status is ' + oelw.oel.Status__c);
                                                    oelHoldOK = false;
                                                }
                                            }
                                        }
                                        if (oelHoldOK)
                                        {
                                            oer.Integration_Scope__c = 'Release and Line Items';
                                            for (OrderEntryLineWrapper oelw : oerw.oelwList)                                            
                                            {
                                                if (!oelHoldSkip.contains(oelw.oel.Status__c))
                                                {
                                                    oelw.oel.Pre_Hold_Status__c = oelw.oel.Status__c;
                                                    oelw.oel.Status__c = 'Hold Requested';
                                                    oelw.oel.Hold_Reason__c = oer.Hold_Reason__c;
                                                    oelw.isUpdated = true;
                                                }
                                            }
                                            lineItemsChanged = true;                                  
                                            oer.Pre_Hold_Status__c = oerOld.Status__c;
                                        }
                                    }
                                }
                            }
                            if (oer.Status__c == 'Hold Release Requested')
                            {
                                oer.Integration_Scope__c = 'Release and Line Items';
                                // JV - 20171020 Added the following statement
                                oer.Integration_Action_Requested__c = 'Hold Release';
                                Rollback_Order_Entry_Release__c rboer = rollbackUtils.createOERRollback(oerOld); // added by BM
                                //oer.Integration_Status__c = 'Change Requested';
                                for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                {
                                    if (oelw.oel.Status__c == 'Hold')
                                    {                                    
                                        oelw.oel.Status__c = 'Hold Release Requested';
                                        oelw.isUpdated = true;
                                        //oelw.Integration_Status__c = 'Change Requested';
                                    }
                                }
                                lineItemsChanged = true;
                            }                               
                        } // End of Hold Processing
                        //
                        // Process Confirmations
                        //
                        
                        if (oer.Status__c == 'Confirmation Requested')
                        {
                            
                            //oer.Integration_Scope__c = 'Release and Line Items';
                            for (OrderEntryLineWrapper oelw : oerw.oelwList)
                            {
                                if(oelw.oel.Status__c != 'Cancelled'){
                                    lineItemsChanged = true;
                                    oelw.oel.Status__c = 'Confirmation Requested';
                                    oelw.isUpdated = true;
                                }
                            }
                            
                        }
                        
                        if (oer.Status__c == 'Change Confirmation Requested')
                        {
                            
                            for (OrderEntryLineWrapper oelw : oerw.oelwList)
                            {
                                if (oelw.oel.Status__c == 'Change Confirmation Required' || oelw.oel.Status__c == 'Change Confirmation Pending' )
                                {
                                    lineItemsChanged = true;
                                    
                                    oelw.oel.Status__c = 'Change Confirmation Requested';
                                    
                                    oelw.isUpdated = true;
                                    
                                }
                                else
                                {
                                    if (oelw.oel.Status__c == 'Cancellation Confirmation Pending')
                                    {                                   
                                        lineItemsChanged = true;
                                        oelw.oel.Status__c = 'Cancellation Confirmation Requested';
                                        oelw.isUpdated = true;                                  
                                    }
                                }
                            }                           
                        }
                        
                        if (oer.Status__c == 'Change Confirmed')
                        {
                            for (OrderEntryLineWrapper oelw : oerw.oelwList)
                            {
                                if (oelw.oel.Status__c == 'Change Confirmation Requested')
                                {
                                    lineItemsChanged = true;
                                    oelw.oel.Status__c = 'Change Confirmed';
                                    oelw.isUpdated = true;
                                }
                                else
                                {
                                    if (oelw.oel.Status__c == 'Cancellation Confirmation Requested')
                                    {                                   
                                        lineItemsChanged = true;
                                        oelw.oel.Status__c = 'Cancellation Confirmed';
                                        oelw.isUpdated = true;
                                        
                                    }
                                }                           
                            }
                        }
                        
                        if (oer.Status__c == 'Confirmed')
                        {
                            //oer.Integration_Scope__c = 'Release and Line Items';
                            for (OrderEntryLineWrapper oelw : oerw.oelwList)
                            {
                                if(oelw.oel.Status__c != 'Cancelled'){
                                    lineItemsChanged = true;
                                    oelw.oel.Status__c = 'Confirmed';
                                    oelw.isUpdated = true;
                                }
                            }
                        }
                        // projectconcrete_2.2
                        if (oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU') && oerOld.Status__c == 'Draft' && oer.Status__c != 'Cancelled' ) 
                        { 
                            //System.debug('###########oerw.oelwList.size'+oerw.oelwList.size()); 
                            if(oerw.oelwList.size()==0){ 
                                oerw.addValidationError('Please adding lines when order is in Draft Status'); 
                                hasErrors = true; 
                            } 
                        }
                        //projectconcrete_2.2 - Validation of Date Not null before confirmation process 
                        if (oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU') &&  
                            oerOld.Status__c == 'Pre-Release Review' && oer.Status__c == 'Confirmation Pending' && 
                            (oer.Scheduled_Ship_Date__c == null  || oer.Request_Date__c == null || oer.Promised_Date__c == null)) 
                        { 
                            hasErrors = true; 
                            if (oer.Scheduled_Ship_Date__c == null) 
                            { 
                                oerw.addValidationError('Scheduled Ship Date is required before submitting for confirmation'); 
                            } 
                            if (oer.Request_Date__c == null) 
                            { 
                                oerw.addValidationError('Request Date is required before submitting for confirmation'); 
                            } 
                            if (oer.Promised_Date__c == null)                                
                            { 
                                oerw.addValidationError('Promised Date is required before submitting for confirmation'); 
                            } 
                            if(oer.Scheduled_Ship_Date__c != null && oer.Scheduled_Ship_Date__c < System.today()) 
                            { 
                                hasErrors = true; 
                                oerw.addValidationError('Schedule Ship Date shouldn\'t be in the past before submitting for confirmation'); 
                            } 
                        } 
                        if (oer.Status__c == 'Integration Requested')
                        {
                            //System.debug('###########oerw.oelwList.size'+oerw.oelwList.size());
                            if(oerw.oelwList.size()==0){
                                oerw.addValidationError('You Cannot submit Order to Intgeration Requested without adding lines');
                                hasErrors = true;
                            }
                            //Schedule Ship Date shouldn't be in the past when submitted for Integfation - BM
                            if(oer.Scheduled_Ship_Date__c != null && oer.Scheduled_Ship_Date__c < System.today())
                            {
                                hasErrors = true;
                                oerw.addValidationError('Schedule Ship Date shouldn\'t be in the past when submitting for Integration ');
                            }
                            //SW_ITEMS_INVOICE_HOLD
                            if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().containsIgnoreCase(Label.CSS_Software))
                            {
                                for( OrderEntryLineWrapper oelw : oerw.oelwList )
                                {
                                    if(oelw.oel.Hold_Reason__c == null && oelw.oel.Hold_Type__c == 'View Invoice Hold' )
                                    {
                                        hasErrors = true;
                                        oerw.addValidationError('Please enter valid Hold Reason on line #: ' + oelw.oel.Line_Number__c );
                                    }
                                     if(oelw.oel.Hold_Comments__c == null && oelw.oel.Hold_Type__c == 'View Invoice Hold' )
                                    {
                                        hasErrors = true;
                                        oerw.addValidationError('Please enter Hold Comments on line #: ' + oelw.oel.Line_Number__c );
                                    }
                                   
                                }
                            }
                            
                            // IGU orders should not be allowed to integrate without product code - BM Tracking ID: INTREQ_PROD_CODE_VLD_01
                            if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                            {
                                for( OrderEntryLineWrapper oelw : oerw.oelwList )
                                {
                                    if(oelw.oel.Part_Number__c == null || oelw.oel.Part_Number__c == '' )
                                    {
                                        hasErrors = true;
                                        oerw.addValidationError('OEL should have product code before submitting for integration. Product Id '+ oelw.oel.Product__c);
                                    }
                                    
                                }
                            }
                            // JV 20171107 - Changed the following logic to require Request Date as well as
                            // Scheduled Ship Date
                            if (oer.Scheduled_Ship_Date__c == null  || oer.Request_Date__c == null || oer.Promised_Date__c == null)
                            {
                                hasErrors = true;
                                if (oer.Scheduled_Ship_Date__c == null)
                                {
                                    oerw.addValidationError('Scheduled Ship Date is required for Integration');
                                }
                                if (oer.Request_Date__c == null)
                                {
                                    oerw.addValidationError('Request Date is required for Integration');
                                }
                                if (oer.Promised_Date__c == null)                               
                                {
                                    oerw.addValidationError('Promised Date is required for Integration');
                                }
                                
                            }
                            else
                            {
                                /*if(oerw.oelwList.size()<=0){
oerw.addValidationError('You Cannot submit Order to Intgeration Requested without adding lines');                                   
}*/
                                oer.Integration_Scope__c = 'Release and Line Items';
                                // JV 20200329 - Added code Integration Rollback Record
                                Rollback_Order_Entry_Release__c rboer = rollbackUtils.createOERRollback(oerOld);
                                if(rboer.Rollback_Errors__c != null) {
                                    oerw.addValidationError(rboer.Rollback_Errors__c);
                                    hasErrors = true;
                                }
                                else {                                
                                    for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                    {
                                        //Added by Enp for recordtype criteria
                                        if (oelw.oel.Status__c == 'Confirmed' && oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                                        {
                                            oelw.oel.Status__c = 'Integration Requested';
                                            lineItemsChanged = true;
                                            oelw.isUpdated = true;
                                        }
                                        if(!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                                        {
                                            if(oelw.oel.Status__c == 'Cancelled'){
                                                oelw.oel.Integration_Action_Requested__c = 'Cancel';
                                            }
                                            else
                                                oelw.oel.Status__c = 'Integration Requested';
                                            lineItemsChanged = true;
                                            oelw.isUpdated = true;
                                        }
                                    }
                                    oer.Integration_Status__c = 'Requested';
                                    oer.Integration_Requestor__c = currentUserId;
                                    oer.Integration_Errors__c = null;
                                } // JV - 20200329 -- End change for Rollback 
                            }
                        }
                        //Added by ENP - START
                        if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName()==Label.CSS_Hardware){
                            /*if (oer.Status__c == 'Change Integration Requested'){   
//oer.Integration_Scope__c = 'Release and Line Items';
for (OrderEntryLineWrapper oelw : oerw.oelwList){   

if(oelw.oel.Status__c != 'Cancelled' && (oelw.oel.Status__c == 'Change Requested' || oelw.oel.Status__c == 'Cancellation Requested'))
oelw.oel.Status__c = 'Change Integration Requested';

lineItemsChanged = true;
oelw.isUpdated = true;
}
oer.Integration_Status__c = 'Change Requested';
oer.Integration_Requestor__c = currentUserId;
oer.Integration_Errors__c = null;
//Added by ENP
//oer.Integration_Action_Requested__c = 'Update';
}  */                     
                            
                            if (oer.Status__c == 'Approval to Ship Requested'){ 
                                oer.Integration_Status__c = 'Change Requested';
                                oer.Integration_Requestor__c = currentUserId;
                                oer.Integration_Errors__c = null;
                                oer.Integration_Scope__c = 'Release and Line Items';
                                oer.Integration_Action_Requested__c ='Update';
                                
                                //Schedule Ship Date shouldn't be in the past when submitted for Integfation - BM
                                if(oer.Scheduled_Ship_Date__c != null && oer.Scheduled_Ship_Date__c < System.today())
                                {
                                    hasErrors = true;
                                    oerw.addValidationError('Schedule Ship Date shouldn\'t be in the past when submitting for Integration ');
                                }
                                // Integration Rollback for Approval to Ship Requested -- BM
                                Rollback_Order_Entry_Release__c rboer = rollbackUtils.createOERRollback(oerOld);
                                if(rboer.Rollback_Errors__c != null) {
                                    oerw.addValidationError(rboer.Rollback_Errors__c);
                                    hasErrors = true;
                                }
                                
                                for (OrderEntryLineWrapper oelw : oerw.oelwList){
                                    /*if(oer.Sales_Order_Status__c == 'Booked')
{
oelw.oel.Status__c='Approved-to-Ship';
}*/
                                    if(oelw.oel.Status__c != 'Cancelled'){
                                        oelw.oel.Integration_Status__c = 'Change Requested';
                                        oelw.oel.Integration_Action_Requested__c ='Update';
                                        lineItemsChanged = true;
                                        oelw.isUpdated = true;
                                    }
                                    
                                }
                            }
                        }
                        //Added by ENP - END                          
                        //else{
                        if (oer.Status__c == 'Change Integration Requested' /*&& oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU')*/)
                        {
                            //Schedule Ship Date shouldn't be in the past when submitted for Integfation - BM
                          /*  //FIX_VALIDATION_ON_PAST_SSD
                            if(oer.Scheduled_Ship_Date__c != null && oer.Scheduled_Ship_Date__c < System.today())       
                                                                 
                            { 
                                
                                hasErrors = true;   
                                
                                oerw.addValidationError('Schedule Ship Date shouldn\'t be in the past when submitted for Integration '); 
                            } 
                             
                           */
                            System.debug('tttttest111');
                            for( OrderEntryLineWrapper oelw : oerw.oelwList )
                                {
                                    if(oelw.oel.Scheduled_Ship_Date__c != null && oelw.oel.Scheduled_Ship_Date__c < System.today() && (oelw.oel.Status__c == 'Change Requested' ||  oelw.oel.Status__c == 'Change Integration Requested' ))
                                   {   System.debug('tttttest');
                                        hasErrors = true;
                                         oerw.addValidationError('Schedule Ship Date on line shouldn\'t be in the past when submitting for Integration. Line No:' +oelw.oel.Line_Number__c);//FIX_VALIDATION_ON_PAST_SSD  added line number                                    }
                                   }    
                                }
                                    
                            
                            //IGU orders should not be allowed to integrate without product code - BM
                            if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                            {
                                for( OrderEntryLineWrapper oelw : oerw.oelwList )
                                {
                                    if(oelw.oel.Part_Number__c == null || oelw.oel.Part_Number__c == '' )
                                    {
                                        hasErrors = true;
                                        oerw.addValidationError('OEL should have product code beofre submitting for integration. Product Id '+ oelw.oel.Product__c);
                                    }
                                    
                                }
                            }
                            if (oer.Scheduled_Ship_Date__c == null)
                            {
                                hasErrors = true;
                                oerw.addValidationError('Scheduled Ship Date is required for Integration');
                            }
                            else
                            {
                                // JV 20200329 - Added code to create Integration Rollback
                                Rollback_Order_Entry_Release__c rboer = rollbackUtils.createOERRollback(oerOld);
                                if(rboer.Rollback_Errors__c != null) {
                                    oerw.addValidationError(rboer.Rollback_Errors__c);
                                    hasErrors = true;
                                }
                                else {                                
                                    for (OrderEntryLineWrapper oelw : oerw.oelwList)
                                    {
                                        if (oelw.oel.Status__c == 'Change Requested' || oelw.oel.Status__c == 'Change Confirmed' || oelw.oel.Status__c == 'Hold Requested'
                                            || oelw.oel.Status__c == 'Hold Release Requested' || oelw.oel.Status__c == 'Cancellation Requested')
                                        {
                                            oelw.oel.Status__c = 'Change Integration Requested';
                                            oelw.isUpdated = true;
                                            oerw.setIntegrationScope('Line Items');
                                        }
                                        else
                                        {
                                            if (oelw.oel.Status__c == 'Cancellation Confirmed')
                                            {
                                                oelw.oel.Status__c = 'Cancellation Integration Requested';
                                                oelw.oel.Integration_Action_Requested__c = 'Cancel';
                                                oelw.isUpdated = true;
                                                oerw.setIntegrationScope('Line Items');
                                            }
                                        }                             
                                    }
                                    if (oerOld.Status__c == 'Hold Requested') // It might be Hold or Hold Release
                                    {
                                        oer.Integration_Action_Requested__c = 'Hold';
                                    }
                                    else
                                    {
                                        // JV - 20171020 "if" statement added for Hold Release
                                        if (oerOld.Status__c == 'Hold Release Requested') 
                                        {
                                            oer.Integration_Action_Requested__c = 'Hold Release';
                                        }
                                        else                                
                                        {
                                            oer.Integration_Action_Requested__c = 'Update';
                                        }                           
                                    }
                                    oer.Integration_Status__c = 'Change Requested';                             
                                    oer.Integration_Requestor__c = currentUserId;                                
                                    oer.Integration_Errors__c = null;
                                }
                            }
                            
                        }
                        //}
                        if (oerOld.Status__c == 'Integration Error')
                        {
                            oer.Integration_Errors__c = null;
                            if (oer.Integration_Status__c == 'Error')
                            {
                                oer.Integration_Status__c = 'Initial';
                            }
                        }   
                        
                    } // End of valid status change processing                                    
                } // End of Status Change Processing
                
                if (fieldChange && !hasErrors)                    
                {
                    
                    if (confirmationRequired)
                    {
                        if (preIntegrationStatus.contains(oerOld.status__c))
                        {
                            if (oerOld.Status__c == 'Confirmed')
                            {
                                oer.Status__c = 'Confirmation Pending';
                            }                            
                        }
                        else
                        {   
                            //Added by enp
                            if(!oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU'))
                                oer.Status__c = 'Change Confirmation Pending';
                            else
                                oer.Status__c = 'Change Confirmation Required';
                            if((oerold.Status__c != 'Change Confirmation Pending' && oerold.Status__c != 'Change Confirmation Required' && oerold.Status__c != 'Integration Error') && (oerold.Status__c != 'Change Confirmation Pending' && oerold.Status__c != 'Change Confirmation Required' && oerold.Status__c != 'Integration Error'))
                                oer.Pre_Change_Status__c = oerOld.Status__c;
                        }
                    }
                    else
                    {
                        if (!preIntegrationStatus.contains(oerOld.status__c))
                        {
                            oer.Status__c = 'Change Requested';
                            if(oerold.Status__c != 'Change Requested' && oerold.Status__c != 'Change Confirmation Pending' && oerold.Status__c != 'Change Confirmation Required' && oerold.Status__c != 'Integration Error')
                                oer.Pre_Change_Status__c = oerOld.Status__c;
                            oer.Integration_Action_Requested__c = 'Update';  
                            system.debug('@@@field'+fieldChange);                               
                        }
                    }
                }
                
            } // End of Trigger Source = UI  change processing
            else
            {
                if (oerw.oer.Trigger_Source__c == 'Line')
                {
                    oer = oerw.oer;
                    oerOld = trigger.oldMap.get(oer.Id);
                    if(oer.Status__c != oerOld.Status__c)
                    {
                        if(oer.Status__c == 'Change Confirmation Required' || oer.Status__c == 'Change Requested' || oer.Status__c == 'Change Confirmation Pending' )
                        {
                            oer.Pre_Change_Status__c = oerOld.Status__c;
                        }
                    }
                    // JV - 20180329 Added code to catch error in update of Integration Status
                    if (oer.Integration_Status__c != oerOld.Integration_Status__c)
                    {
                        hasErrors = true;
                        oerw.addValidationError('Error: Integration Status Updated to ' + oer.Integration_Status__c + ' by Trigger Source ' + oer.Trigger_Source__c);                       
                    }
                }
                /*Added by enp
if (oerw.oer.Trigger_Source__c == 'Integration' && !oerRecordTypeMapSchema.get(oerw.oer.RecordTypeID).getDeveloperName().contains('IGU'))
{
oer = oerw.oer;
oerOld = trigger.oldMap.get(oer.Id);
if (oer.Status__c == 'Approval to Ship Requested' && oer.Sales_Order_Status__c == 'Booked' && oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains(Label.CSS_Hardware)){                
oer.Status__c = 'Approved-to-Ship';
}
if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains(Label.CSS_Software)){
if (oer.Status__c == 'Planned' && oer.Sales_Order_Status__c == 'Booked'){                   
oer.Status__c = 'Booked';
}
else if (oer.Status__c == 'Booked' && oer.Sales_Order_Status__c == 'Closed'){                   
oer.Status__c = 'Invoiced';
}
else if (oer.Sales_Order_Status__c == 'Cancelled'){                 
oer.Status__c = 'Cancelled';
}
}
if (cascadeStateOnly.contains(oer.Status__c))
{
system.debug('@app');
for (OrderEntryLineWrapper oelw : oerw.oelwList)
{
if (oelw.oel.Status__c == oerOld.Status__c)
{
oelw.oel.Status__c = oer.Status__c;
oelw.isUpdated = true;
system.debug('@app');
}
}                           
}
}
//ended by enp*/
            }
            
        } // End of Main Loop non-integration updates
        
        // *******************************************************
        // Process Order Entry Release Updates from Integration  *
        // *******************************************************
        //
        
        if (integrationOERIds.size() != 0)
        {
            Set<Id> oerStatusCheckIds = new Set<Id>();
            for (Id oerId : integrationOERIds)
            {
                // Order Entry Line Changes may change Order Entry Release Status
                if (oerWrapperMap.get(oerId).oer.Integration_Scope__c != null &&
                    oerWrapperMap.get(oerId).oer.Integration_Scope__c.contains('Line Items'))                
                {
                    oerStatusCheckIds.add(oerId);
                }
            }
            for (Id oerID : integrationOERIDs)
            {                   
                OrderEntryReleaseWrapper oerw = oerWrapperMap.get(oerID);
                Order_Entry_Release__c oer = oerw.oer;
                oerOld = trigger.oldMap.get(oer.Id);
                
                if (oer.Integration_Status__c !=  oerOld.Integration_Status__c)
                {
                    //
                    // Set/reset values for Status and Integration control base on the integration outcome
                    //
                    if (oer.Integration_Status__c == 'Error')
                    {
                        oer.Status__c = 'Integration Error';
                    }
                    else
                    {
                        if (oer.Integration_Status__c == 'Complete')
                        {
                            if (oer.Status__c == 'Change Integration Requested')
                            {
                                if(oerStatusCheckIds.contains(oerId))
                                {                                       
                                    if (oerw.getNewStatus() != null && oer.Status__c != oerw.getNewStatus())
                                    {
                                        oer.Status__c = oerw.getNewStatus();
                                    }
                                    else
                                    {
                                        if (oer.Integration_Action_Requested__c == 'Hold')
                                        {
                                            oer.Status__c = 'Hold';
                                        }
                                        else if (oer.Integration_Action_Requested__c == 'Hold Release')// SW_ITEMS_INVOICE_HOLD added 
                                        {
                                            oer.Status__c = oer.Pre_Hold_Status__c;
                                        }
                                        else
                                        {
                                            oer.Status__c = oer.Pre_Change_Status__c;
                                        }
                                    }
                                }
                                else
                                {
                                    if (oer.Integration_Action_Requested__c == 'Hold')
                                    {
                                        oer.Status__c = 'Hold';
                                    }
                                    else
                                    {
                                        if (oer.Integration_Action_Requested__c == 'Release Hold')
                                        {
                                            oer.Status__c = oer.Pre_Hold_Status__c;
                                        }
                                        else
                                        {
                                            oer.Status__c = oer.Pre_Change_Status__c;
                                        }
                                    }
                                }
                            }
                            if (oer.Status__c == 'Cancellation Integration Requested')
                            {
                                oer.Status__c = 'Cancelled';
                            }
                            // JV 20180213 Added " || 'Pre-Production'" to the if statement. Lines Integration Status may updated First_Scheduled_Ship_Date__c
                            // causing the update of the Release to 'Pre-Production'. If this is the case, First... Dates are not captured
                            //Added by ENP - Planned
                            if (oer.Status__c == 'Integration Requested' || oer.Status__c == 'Pre-Production' || oer.Status__c == 'Planned')
                            {
                                //Added by ENP - Record Type
                                if(oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU')){
                                    oer.Status__c = 'Pre-Production';
                                }
                                //Added by ENP
                                else{
                                    oer.Status__c = 'Planned';
                                    //oer.Integration_Status__c ='';
                                }
                                oer.First_Request_Ship_Date__c = oer.Request_Date__c;
                                oer.First_Scheduled_Ship_Date__c = oer.Scheduled_Ship_Date__c;
                                // JV -20180208 - Added line to capture First Promised Date
                                oer.First_Promised_Date__c = oer.Promised_Date__c;
                            }
                            //Added by ENP 
                            /*if(oer.Status__c == 'Booked'){

oer.Status__c = 'Approved-to-Ship';
}*/
                            oer.Integration_Scope__c = null;
                            oer.Integration_Action_Requested__c = null;
                            oer.Integration_Errors__c = null;
                            oer.Integration_Requestor__c = null;
                            system.debug('@@scope'+oer.Integration_Scope__c);
                            // JV - 20200329 Added code for Integration Rollback_Errors__c
                            // If integration completed normally, clear the Rollback image
                            String clrResult = rollbackUtils.clearRollbacks(oer);
                            if(clrResult != 'OK')
                            {
                                System.debug('*** Warning - Clear Rollbacks failed for OER ' + oer.name);
                            }
                        }                       
                    }
                }
            } // End of Integration Update Processing Loop
        } // End of Updates from Integration
        oelsForUpdate.clear();
        for (OrderEntryReleaseWrapper oerw : oerWrapperMap.values())
        {
            for (OrderEntryLineWrapper oelw : oerw.oelwList)
            {
                system.debug('oelw.oel.Name'+oelw.oel.Name+'oelw.isUpdated'+oelw.isUpdated);    // BM - 20200731 - Included Closed and Shipped  Tracking Id: SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                // SO_CHANGES_Jan_2021
                if (oelw.isUpdated && (oelw.oel.Sales_Order_Line_Status__c !='Packed' && oelw.oel.Sales_Order_Line_Status__c !='Picked' && oelw.oel.Sales_Order_Line_Status__c !='Closed' && oelw.oel.Sales_Order_Line_Status__c !='Shipped'))
                    //|| 
                    //(oelw.oel.Status__c =='Partially Shipped' && (oelw.oel.Sales_Order_Line_Status__c !='Picked' && oelw.oel.Sales_Order_Line_Status__c !='Closed' && oelw.oel.Sales_Order_Line_Status__c !='Shipped')))
                {
                    system.debug('oelw.oel.Name'+oelw.oel.Name);
                    oelw.oel.Trigger_Source__c = 'Release';
                    oelsForUpdate.add(oelw.oel);
                }
            }           
        }
        List<Database.SaveResult> srList = Database.update(oelsForUpdate, false);
        Integer i = 0;
        for (Database.SaveResult sr: srList)
        {
            if (!sr.isSuccess())
            {
                for (Database.Error err : sr.getErrors())
                {                       
                    Order_Entry_Line__c oelInError = oelsForUpdate[i];                   
                    String errMsg = err.getMessage();
                    OrderEntryReleaseWrapper oerwInError = oerWrapperMap.get(oelInError.Order_Entry_Release__c);
                    oerwInError.addValidationError('Cascaded update to Order Entry Line # ' + String.valueOf(oelInError.Line_Number__c) + ' failed: ' + errMsg);
                }
                hasErrors = true;
            }
            i++;
        }  
        if (hasErrors)
        {
            //Added by ENP - Admin Override
            //User u = [SELECT ID,Admin_Override__c FROM USER WHERE ID=:userinfo.getUserId()];
            
            for (OrderEntryReleaseWrapper oerw: oerWrapperMap.values())
            {
                if (oerw.hasErrors && !oerw.oer.No_Validation__c) // Added additional flag Check - ENP
                {                   
                    String displayMessage = '';
                    for (i = 0; i < oerw.validationErrors.size(); i++)
                    {
                        if (i > 0)
                        {
                            displayMessage = displayMessage + '<br/>';
                        }
                        displayMessage = displayMessage +   String.valueOf(i+1) + ') ' + oerw.validationErrors[i];
                        System.debug('*** Added err: ' + oerw.validationErrors[i]);
                    }
                    //if(!(userinfo.getprofileId().contains(label.CSSValidationSkip) && !oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().contains('IGU')))
                    oerw.oer.addError(displayMessage,false);                                                  
                }
            }
        }
        
        
    }        // End of Before Update processing
    
    //BALA - 9/19/19 - When Auto Book Orders are Shipped, update related Product Request and Issue statuses.
    Set<Id> shippedPROrders = new Set<Id>();
    if (trigger.isUpdate && trigger.isAfter)
    {
        system.debug('oerWrapperMap:' + oerWrapperMap);
        // After update actions
        for(Integer Indx = 0; Indx < Trigger.new.size(); Indx++) {
            if (Trigger.new[Indx].Trigger_Source__c == 'Line')
            {
                if(Trigger.old[Indx].Status__c != Trigger.new[Indx].Status__c && Trigger.new[Indx].Status__c == 'Shipped' )//&& Trigger.new[Indx].Auto_Book_Order__c
                {
                    shippedPROrders.add(Trigger.new[Indx].Id);
                }
            }
        }
    }
    
    if(shippedPROrders.size() > 0) {
        Case_Quote_Order_Util.setRelatedPRsToFulFillStatus(shippedPROrders);
    }
}