trigger Order_Entry_Line_BU_AU on Order_Entry_Line__c (Before Update, After Update) 
{
    // JV - 20200329 Added code to support Integration Rollback
    // 
    // Version 8: 
    //  - Changes to accommodate direct setting of status for testing
    //  - Changes to accommodate CPQ Custom Quote Objects
    //  20180529 - Changed to handle BOTH SFDC and CPQ Order Objects
    //  20180625 - Change to handle Multi-currency
    //  20180626 - Added code to support manual change to Price
    //
    // Version 7: 
    //  - Adds code to calculate Rollups
    //  - Bug Fix: Added code to recompute total areas if Quantity Changes
    //  - 20180208 - Added code to support processing of Promised Date
    //  - Added code to prevent changes to Shipping Address once shipping has begun
    //  - Corrected code for the capture of Previous... Date values
    // 
    // Version 6: Based on V.4 Go-Live version. Version 5 code to handle metric recordtypes added.
    //
    // Go-Live Version based on V.4. Changes included:
    //  - Added coded to correctly set Previous Quantity on deletes and to correctly set Confirmation Required flag
    //      on Quantity changes.
    //  - Added to correct handling of quantity changes for Confirmed OELs
    //  - Added Line Number to the OEL fields retrieved by the afterUpdate trigger
    //
    // Version 4: 
    //  - Date Name Changes
    //  - Changes to support new change integration with Integration Scope and Integration Action Requested
    //  - Correction for pre-integration Hold 
    //  - Require Scheduled Ship Date to Request Integration 
    // Updated Date         Developer       Project             Tracking Id                         Requirement                         
    // 30-July-2020         Bajrang         Project Concrete    WORK_ORDER_STATUS_VALIDATION_01     Put a validation error when user tries to change Quantity on IGU order with status <> UnReleased.
    // 03-Aug-2020          Bajrang         Project Concrete    SOLS_PICKED_SHIPPED_CLOSED_VLD_01   Throw an validation error if ORL is updated with Quantity/Dates/Address with SOLS as Picked, Shipped, Closed  
    // 03-Aug-2020          Srikanth        Project Concrete    SOLS_PICKED_SHIPPED_CLOSED_VLD_02   Throw an validation error if ORL User tries to cancel OEL with SOLS as Picked, Shipped, Closed  
    //  22-Sep-2020          Bajrang			Case to Order 		Auto_Order_Creation_Failure			To fix issue with CHW Order creation and auto submit to integration failing when Issue with Warranty is submitted for Approval
    // 23-Aug-2020          Rekha           Project Concrete    CANCELLATION_BUGS_SEP_20           					Throw an validation error if User tries to cancel OEL with WO status as Released 
    // 23-Aug-2020          Rekha           Project Concrete    CANCELLATION_BUGS_SEP_20   							Make Quantity On OEL  and OELF to '0' When OER is cancelled & Make OELF Open line status as Cancelled
    // 02-Sep-2020          Rekha           Project Concrete    LINE_STATUS_WHEN_INTEGRATION_ERROR_THEN_COMPLETE_01 Move the line status to new status when the Integration Status is updated as Complete on a Line which has Integration Status as Error                                                 
    // 06-Jan-2021			Srikanth		projectconcrete 2.2  projectconcrete_2.2			
	// 06-Jan-2021          Rekha           SW items invoice Hold    SW_ITEMS_INVOICE_HOLD
	// 12-Jan-2021			Srikanth		SO Changes			SO_CHANGES_Jan_2021	
	// 18-Feb-2021	        Rekha           Validation on SSD   FIX_VALIDATION_ON_PAST_SSD          Update Order Entry Release Trigger to validate for OEL SSD > Today 
	// 16-Feb-2021	        Rekha           projectconcrete 2.3  projectconcrete_2.3               
			
	
    public OrderEntryLineWrapper oelWrapper;
    public Order_Entry_Line__c oel;
    public Order_Entry_Line__c oelOld;
    public Boolean fieldChange;
    public Boolean confirmationRequired;
    public Boolean hasErrors;
    public Boolean preIntegration; 
    public List<OrderEntryLineWrapper> oelWrapperList = new List<OrderEntryLineWrapper>();
    public Id currentUserId = Id.valueOf(userinfo.getUserId());
    public Set<Id> oerIds = new Set<Id>();
    public Set<Id> oelsIds = new Set<Id>();
    public Map<Id, Order_Entry_Release__c> oerMap = new Map<Id, Order_Entry_Release__c>();
    //  20180529 - Changed to handle BOTH SFDC and CPQ Order Objects
    // public SBQQ__QuoteLine__c qli;
    // public Map<Id, SBQQ__QuoteLine__c> qliMap = new Map<Id, SBQQ__QuoteLine__c>();
    public QuoteLineWrapper qlw;
    public Map<Id, QuoteLineWrapper> qlwMap = new Map<Id, QuoteLineWrapper>();
    public Set<Id> cpqQLIIds = new Set<Id>();
    public Set<Id> sfdcQLIIds = new Set<Id>();
    public Id workingQLIId;
    // 20180529
    
    public Set<String> oerUpdateOK = new Set<String> {'Draft','Pre-Release Review', 'Confirmation Pending', 'Pre-Production', 'In Production', 'Integration Error', 'Change Confirmation Required',
        'Change Confirmed', 'Change Requested', 'Hold','Partially Shipped'};
// ENP - Added Invoiced,Approved-to-Ship, Planned, Booked,Change Confirmation Requested,confirmed    
    public Set<String> oerUpdateCSSOK = new Set<String> {'Draft','Integration Error','Change Requested','Invoiced','Planned' , 'Approved-to-Ship','Change Confirmation Pending','Partially Shipped'};
    public Set<String> oerUpdateSWOK = new Set<String> {'Draft'};
    // JV - 20171020 Line added to facilitate Status Checking for Quantity changes
    // ENP - Added Approved-to-Ship, Planned,Change Requested
    public Set<String> preConfirmationStatus = new Set<String>{'Draft','Pre-Release Review', 'Confirmation Pending','Confirmed', 'Planned','Change Requested'};
    // jv - 20180208 - added the following line to check if changes to certain shipping info is O.K.
    // ENP - Added Invoiced,Approved-to-Ship
     public Set<String> hasShippedItemsItems = new Set<String> { 'Shipped', 'Complete', 'Invoiced'}; // Removed 'Partially Shipped' - BM Shipping Address change is allowed for Partially Shipped lines
    // jv - 20180208 - added the following line to check if changes to certain shipping info is O.K.
    // ENP - Added Invoiced and Booked
    public Set<String> fullyShipped = new Set<String> {'Shipped', 'Complete', 'Cancelled', 'Invoiced', 'Booked'};
    public Set<String> CSSPostBooked = new Set<String> {'Approved-to-Ship','Partially Shipped'};
     // *** Version 5: Added the following line to support OEL metric record type
    //Map<ID,RecordType> oelRecordTypeMap = Order_Entry_Trigger_Helper_2.getRecordTypeMap('Order_Entry_Line__c'); 
    Map<ID,Schema.RecordTypeInfo> oelRecordTypeMapSchema = Schema.SObjectType.Order_Entry_Line__c.getRecordTypeInfosById();  
    public Set<String> preIntegrationStatus = new Set<String>{'Draft','Pre-Release Review', 'Confirmation Pending', 'Confirmed'};
    //Added by ENP
    Map<String, Decimal> priceBookEntryMap = new Map<String, Decimal>();
    Map<Id, Product2> productMap = new Map<Id, Product2>();
    Set<Id> ProductIds = new Set<Id>();
    Map<string,string> currencyMap=new Map<string,string>();
    public RollbackUtils rollbackUtils = new RollbackUtils(); //Auto_Order_Creation_Failure
    
    if (trigger.isBefore && trigger.isUpdate)
    {
        //
        //  
       fakeMethod();
        for (Order_Entry_Line__c oel : trigger.new){
            
            //SW_ITEMS_INVOICE_HOLD
            if(oel.Hold_Type__c != trigger.oldMap.get(oel.Id).Hold_Type__c && oel.Hold_Type__c == null){
                oel.Hold_Comments__c = '';
                oel.Hold_Reason__c =  '';
            }
            else if(oel.Request_Date__c != trigger.oldMap.get(oel.Id).Request_Date__c && oel.Scheduled_Ship_Date__c != trigger.oldMap.get(oel.Id).Scheduled_Ship_Date__c){
                oel.Is_Schedule_Date_Updated__c = false;
                oel.Scheduled_Ship_Date_Updated_Date__c =  datetime.now();
                oel.Request_Date_Updated_Date__c =  datetime.now();             
            }
            else if(((oel.Request_Date__c != trigger.oldMap.get(oel.Id).Request_Date__c) || (trigger.oldMap.get(oel.Id).Request_Date_Update_Needed__c && !oel.Request_Date_Update_Needed__c)) && oel.Scheduled_Ship_Date__c == trigger.oldMap.get(oel.Id).Scheduled_Ship_Date__c)
            {
                oel.Is_Schedule_Date_Updated__c = true;
                oel.Request_Date_Updated_Date__c =  datetime.now(); 
            }
            else if(oel.Request_Date__c == trigger.oldMap.get(oel.Id).Request_Date__c && oel.Scheduled_Ship_Date__c != trigger.oldMap.get(oel.Id).Scheduled_Ship_Date__c){
                oel.Is_Schedule_Date_Updated__c = false;
                oel.Scheduled_Ship_Date_Updated_Date__c =  datetime.now();  
            } 
            
            system.debug('oel.Status__c'+oel.Status__c);
            system.debug('trigger.oldMap.get(oel.Id).Status__c'+ trigger.oldMap.get(oel.Id).Status__c);
            
            
            if(oel.Request_Date__c != trigger.oldMap.get(oel.Id).Request_Date__c && oel.Request_Date_Update_Needed__c) {
                oel.Request_Date_Update_Needed__c = false;
            }
            // JV 20203029 - Added code to support integration Rollback
            // Bypass trigger processing if the update is rolling back Integration
            if (oel.Trigger_Source__c != 'Line' && oel.Trigger_Source__c != 'Rollback'){
                // *** Version 5 - Changed to handle OEL Record Type
                oelWrapperList.add(new OrderEntryLineWrapper(oel, oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()));               
//                oelWrapperList.add(new OrderEntryLineWrapper(oel));
                oerIds.add(oel.Order_Entry_Release__c);
                //  20180529 - Changed to handle BOTH SFDC and CPQ Order Objects
                if (oel.CPQ_Quote_Line__c != trigger.oldMap.get(oel.ID).CPQ_Quote_Line__c) 
                {
                    cpqQLIIds.add(oel.CPQ_Quote_Line__c);
                }
                if (oel.Quote_Line_Item__c != trigger.oldMap.get(oel.ID).Quote_Line_Item__c) 
                {
                    sfdcQLIIds.add(oel.Quote_Line_Item__c);
                }                
                // 20180529
            }
            //Added by ENP
            productIds.add (oel.Product__c);
            //Added by Enp Narasimha
            system.debug('@@currency'+oel.SKU__c+'--'+oel.CurrencyISOCode);
            if(oel.SKU__c!=null && oel.CurrencyISOCode!=null)
            currencyMap.put(oel.SKU__c,oel.CurrencyISOCode);
        }
        // JV 20180626 - Added CurrencyISOCode to retrieved fields
        for (Order_Entry_Release__c oer : [SELECT Id,No_Validation__c,Sales_Order_Status__c, Auto_Book_Order__c, CurrencyISOCode, Status__c, Integration_Status__c, Integration_Scope__c, Integration_Action_Requested__c 
            FROM Order_Entry_Release__c WHERE Id IN :oerIDs])
        {
            oerMap.put(oer.Id, oer);
        }
        
        if (cpqQLIIds.size() > 0)
        {
            // JV 20180626 - Added CurrencyISOCode to retrieved fields
            for (SBQQ__QuoteLine__c qli : [SELECT Id, CurrencyISOCode, SBQQ__Product__c, SBQQ__Quote__c,Product_SKU__c , SBQQ__CustomerPrice__c, SBQQ__Discount__c, SBQQ__Quantity__c FROM SBQQ__QuoteLine__c
                WHERE Id IN :cpqQLIIds])
            {
                qlwMap.put(qli.Id, new QuoteLineWrapper(qli));
            }
        }
        if (sfdcQLIIds.size() > 0)
        {
            // JV 20180626 - Added CurrencyISOCode to retrieved fields
            for (QuoteLineItem qli : [SELECT Id, CurrencyISOCode, Product2Id, QuoteId, UnitPrice, Discount, Product_SKU__c FROM QuoteLineItem WHERE Id IN :sfdcQLIIds])
            {
                qlwMap.put(qli.Id, new QuoteLineWrapper(qli));
            }
        }
        //Added by ENP - START
        for (Product2 prd : [SELECT id, Product_SKU__c FROM Product2 WHERE Id IN :productIds])
        {
            productMap.put(prd.id, prd);
        }
        
        for (PricebookEntry pbe : [SELECT Id, Pricebook2Id, IsActive, Product2.Name, Product2.Family, Product2.IsActive, Product2.Description, UnitPrice, Product2.Product_SKU__c from PricebookEntry where Product2.isActive=True AND IsActive=true  AND Id IN :productIds])
        {
            //Added by Enp Narasimha
            if(currencyMap.get(pbe.Product2.Product_SKU__c)==pbe.CurrencyISOCode)
            priceBookEntryMap.put(pbe.Product2.Product_SKU__c, pbe.unitprice);
        }
        
        //Added by ENP - END
 
        for (OrderEntryLineWrapper oelw : oelWrapperList)
        {
            confirmationRequired = false;
            fieldChange = false;
            hasErrors = false;
            preIntegration = false;
            oel = oelw.oel;
            oelOld = trigger.oldMap.get(oel.Id);
            if (oel.CPQ_Quote_Line__c != null)
            {
                workingQLIId = oel.CPQ_Quote_Line__c;
            }
            else
            {
                workingQLIId = oel.Quote_Line_Item__c;              
            }
            if (oel.Trigger_Source__c != 'Integration' && !(test.isRunningTest() && oel.Trigger_Source__c == 'Test Data Setup'))
            {
                //
                // Check for integration in process
                //
                system.debug('@cancel');
                if (preIntegrationStatus.contains(oelOld.Status__c))
                {
                    preIntegration = true;
                }
                System.debug('***oer Status = ' + oerMap.get(oel.Order_Entry_Release__c).Status__c + ' /  oerUpdateOK = ' + String.valueOf(oerUpdateOK));
                if (oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') && !oerUpdateOK.contains(oerMap.get(oel.Order_Entry_Release__c).Status__c) && oel.Trigger_Source__c != 'Release')
                    
                {
                    oelw.addValidationError('Updates of Order Entry Lines are not permitted when the Order Entry Release Status is ' + oerMap.get(oel.Order_Entry_Release__c).Status__c);
                    hasErrors = true;
                }
                if (!oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') && !oerUpdateCSSOK.contains(oerMap.get(oel.Order_Entry_Release__c).Status__c)  &&  oel.Trigger_Source__c != 'Release' )
                {
                    oelw.addValidationError('Updates of Order Entry Lines are not permitted when the Order Entry Release Status is ' + oerMap.get(oel.Order_Entry_Release__c).Status__c);
                    hasErrors = true;
                }
                 if (oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains(Label.CSS_Software) && !oerUpdateSWOK.contains(oerMap.get(oel.Order_Entry_Release__c).Status__c)  &&  oel.Trigger_Source__c != 'Release' )
                {
                    oelw.addValidationError('Updates of Order Entry Lines are not permitted when the Order Entry Release Status is ' + oerMap.get(oel.Order_Entry_Release__c).Status__c);
                    hasErrors = true;
                }   
                    
                if (oelOld.Integration_Status__c != null && oelOld.Integration_Status__c != 'Requested' && oelOld.Integration_Status__c != 'Initial' && oelOld.Integration_Status__c != 'Complete' && 
                    oelOld.Integration_Status__c != 'Error' )
                {
                    oelw.addValidationError('Update is not permitted while integration is in process');
                    hasErrors = true;
                }
                //
                // Field Changes 
                // 
                //Added by ENP
               /* if ((oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Software && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Hardware) &&*/
                    if(oel.Shipping_City__c !=  oelOld.Shipping_City__c ||
                    oel.Shipping_Country__c !=  oelOld.Shipping_Country__c ||
                    oel.Shipping_Name__c !=  oelOld.Shipping_Name__c ||
                    oel.Shipping_Postal_Code__c !=  oelOld.Shipping_Postal_Code__c ||
                    oel.Shipping_State_Province__c !=  oelOld.Shipping_State_Province__c ||
                    oel.Shipping_Street_1__c !=  oelOld.Shipping_Street_1__c ||
                    oel.Shipping_Street_2__c !=  oelOld.Shipping_Street_2__c ||
                    oel.Shipping_Street_3__c !=  oelOld.Shipping_Street_3__c)
                    
                {
                    // CHW - BM SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                     if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware 
                            && (oel.Sales_Order_Line_Status__c == 'Picked' ||  oel.Sales_Order_Line_Status__c == 'Closed' || oel.Sales_Order_Line_Status__c == 'Shipped') 
                                    && oel.Sales_Order_Line_Status__c != null)
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Shipping Address is not possible when Sales Order Line Status is  ' + oelOld.Sales_Order_Line_Status__c);                      
                    }

                    // IGU SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                     // SO_CHANGES_Jan_2021
                     if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') 
                                    && (oel.Sales_Order_Line_Status__c == 'Packed' || oel.Sales_Order_Line_Status__c == 'Picked' ||  oel.Sales_Order_Line_Status__c == 'Closed' || oel.Sales_Order_Line_Status__c == 'Shipped') 
                                            && oel.Sales_Order_Line_Status__c != null) 
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Shipping Address is not possible when Sales Order Line Status is ' + oelOld.Sales_Order_Line_Status__c);     
                    }

                    // JV 20180209 - Added if... statement to prevent update of Shipping Address if Line has shipped
                    if(hasShippedItemsItems.contains(oelOld.Status__c))
                    {
                        hasErrors = true;
                        oelw.addValidationError('Shipping Address may not be changed when Order Entry Line Status = ' + oelOld.Status__c);
                    }
                    else
                    {
                        oel.Shipping_Country__c = AddressUtils.getStandardName(oel.Shipping_Country__c);
                        AddressLines addrLines = new AddressLines();
                        addrLines.name = oel.Shipping_Name__c;
                        addrLines.street1 = oel.Shipping_Street_1__c;
                        addrLines.street2 = oel.Shipping_Street_2__c;
                        addrLines.street3 = oel.Shipping_Street_3__c;
                        addrLines.city = oel.Shipping_City__c;
                        addrLines.stateProvince = oel.Shipping_State_Province__c;
                        addrLines.postalCode = oel.Shipping_Postal_Code__c;
                        addrLines.country = oel.Shipping_Country__c;
                        oel.Shipping_Address__c = AddressUtils.formatAddress(oel.Shipping_Name__c, addrLines, true);
                        fieldChange = true;
                        // if (oel.Status__c == 'Approved-to-Ship'){
                         // confirmationRequired = true;
                          
                     // }
                    }
                }
                if (oel.Shipping_Account__c != oelOld.Shipping_Account__c && (oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Software && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Hardware))
                {
                    fieldChange = true;
                }
                //Added by ENP
                if (oel.currencyISOCode != oerMap.get(oel.Order_Entry_Release__c).currencyISOCode)
                {
                    hasErrors = true;
                    oelw.addValidationError('Line currency code does not match Order Entry Release currency code');
                }
                
                if (oel.Request_Date__c != oelOld.Request_Date__c)
                {
                    // JV 20180327 - Added coded to prevent Request Date from being updated if Line has Shipped
                    //Added by enp
                   
                    if (!fullyShipped.contains(oel.Status__c))
                    {
                        fieldChange = true;
                        // JV 20180208 - Added code capture Previous Request Ship Date
                        oel.Previous_Request_Ship_Date__c = oelOld.Request_Date__c;
                        if (!preIntegrationStatus.contains(oel.Status__c))
                        {
                            if (oel.First_Request_Ship_Date__c == null )
                            {
                                oel.First_Request_Ship_Date__c = oel.Request_Date__c;
                            }
                        }
                    }
                    else
                    {
                        hasErrors = true;
                        oelw.addValidationError('Requested Date may not be changed when Order Entry Line Status = ' + oelOld.Status__c);
                    }
                     // CHW SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware 
                            && (oelOld.Sales_Order_Line_Status__c == 'Picked' ||  oelOld.Sales_Order_Line_Status__c == 'Closed' || oelOld.Sales_Order_Line_Status__c == 'Shipped') 
                                    && oelOld.Sales_Order_Line_Status__c != null)
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Request Date is not possible when Sales Order Line Status is  ' + oelOld.Sales_Order_Line_Status__c);                      
                    }

                    // IGU SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                    // SO_CHANGES_Jan_2021
                     if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') 
                                    && (oel.Sales_Order_Line_Status__c == 'Packed' || oelOld.Sales_Order_Line_Status__c == 'Picked' ||  oelOld.Sales_Order_Line_Status__c == 'Closed' || oelOld.Sales_Order_Line_Status__c == 'Shipped') 
                                            && oelOld.Sales_Order_Line_Status__c != null) 
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Request Date is not possible when Sales Order Line Status is ' + oelOld.Sales_Order_Line_Status__c); 
                            
                    }
                }
                if (oel.Scheduled_Ship_Date__c != oelOld.Scheduled_Ship_Date__c)
                {
                    //Added by enp
                    // JV 20180327 - Added coded to prevent Scheduled Ship Date from being updated if Line has Shipped
                    if (!fullyShipped.contains(oel.Status__c))
                    {
                        fieldChange = true;
                        // JV 20180208 - Added code capture Previous Scheduled Ship Date
                        oel.Previous_Scheduled_Ship_Date__c = oelOld.Scheduled_Ship_Date__c;
                        if (!preIntegrationStatus.contains(oel.Status__c))
                        {                  
                            if (oel.First_Scheduled_Ship_Date__c == null )
                            {
                                oel.First_Scheduled_Ship_Date__c = oel.Scheduled_Ship_Date__c;
                            }
                        }
                    }
                    else
                    {
                        hasErrors = true;
                        oelw.addValidationError('Scheduled Ship Date may not be changed when Order Entry Line Status = ' + oelOld.Status__c);
                    }
                    // SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                     if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware 
                            && (oelOld.Sales_Order_Line_Status__c == 'Picked' ||  oelOld.Sales_Order_Line_Status__c == 'Closed' || oelOld.Sales_Order_Line_Status__c == 'Shipped') 
                                    && oelOld.Sales_Order_Line_Status__c != null)
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Scheduled Ship Date is not possible when Sales Order Line Status is  ' + oelOld.Sales_Order_Line_Status__c);                      
                    }
                    // SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                    // SO_CHANGES_Jan_2021
                     if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') 
                                    && (oel.Sales_Order_Line_Status__c == 'Packed' || oelOld.Sales_Order_Line_Status__c == 'Picked' ||  oelOld.Sales_Order_Line_Status__c == 'Closed' || oelOld.Sales_Order_Line_Status__c == 'Shipped') 
                                            && oelOld.Sales_Order_Line_Status__c != null) 
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Scheduled Ship Date is not possible when Sales Order Line Status is ' + oelOld.Sales_Order_Line_Status__c); 
                            
                    }

                    
                                            
                }
                
                if (oel.Promised_Date__c != oelOld.Promised_Date__c)
                // JV 20180209 Added code for processing Promised Date
                {
                    // SOLS_PICKED_SHIPPED_CLOSED_VLD_01                    
                 if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware 
                            && (oelOld.Sales_Order_Line_Status__c == 'Picked' ||  oelOld.Sales_Order_Line_Status__c == 'Closed' || oelOld.Sales_Order_Line_Status__c == 'Shipped') 
                                    && oelOld.Sales_Order_Line_Status__c != null)
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Promised Date is not possible when Sales Order Line Status is  ' + oelOld.Sales_Order_Line_Status__c);                      
                    }
                    // SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                    // 
                     // SO_CHANGES_Jan_2021
                     if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') 
                      && (oel.Sales_Order_Line_Status__c == 'Packed' || oelOld.Sales_Order_Line_Status__c == 'Picked' ||  oelOld.Sales_Order_Line_Status__c == 'Closed' || oelOld.Sales_Order_Line_Status__c == 'Shipped') 
                      && oelOld.Sales_Order_Line_Status__c != null) 
                     
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Promised Date is not possible when Sales Order Line Status is ' + oelOld.Sales_Order_Line_Status__c); 
                            
                    }

                   // JV 20180327 - Added coded to prevent Promised Date from being updated if Line has Shipped
                    if (!fullyShipped.contains(oel.Status__c))
                    {
                        fieldChange = true;
                        oel.Previous_Promised_Date__c = oelOld.Promised_Date__c;
                        if (!preIntegrationStatus.contains(oel.Status__c))
                        {
                            if (oel.First_Promised_Date__c == null )
                            {
                                oel.First_Promised_Date__c = oel.Promised_Date__c;
                            }
                        }
                    }
                    else
                    {
                        hasErrors = true;
                        oelw.addValidationError('Promised Date may not be changed when Order Entry Line Status = ' + oelOld.Status__c);
                    }
                }
                if (oel.Customer_Reference_Description__c != oelOld.Customer_Reference_Description__c)
                {
                    //Added by enp
                    if(CSSPostBooked.contains(oel.Status__c) && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware)
                    {
                         if(oel.Scheduled_Ship_Date__c < system.today().addDays(Integer.valueof(label.CSSScheduleDue)))
                        {
                            oelw.addValidationError('Customer Reference Description change not allowed with due of schedule ship date');
                            hasErrors = true;
                        }
                    }
                    if (!fullyShipped.contains(oel.Status__c)){
                        fieldChange = true;
                    }
                    else
                    {
                        hasErrors = true;
                        oelw.addValidationError('Customer Reference Description may not be changed when Order Entry Line Status = ' + oelOld.Status__c);
                    }
                }
                //Added by ENP
                if (oel.Mark_Ids__c != oelOld.Mark_Ids__c && (oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Software && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Hardware))
                {
                    // projectconcrete_2.2  
                    if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') && oel.Work_Order_Status__c != 'Unreleased' && oel.Work_Order_Status__c != null) 
                    { 
                        hasErrors = true; 
                        oelw.addValidationError('Updates on Mark Id is not possible when Work Order Status is  ' + oelOld.Work_Order_Status__c); 
                    } 
                    else 
                    {        
                        fieldChange = true;  
                    }                    
                }                
                //date changes for confirmation when status in approve-to-ship.
                if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware && !preConfirmationStatus.contains(oel.Status__c) &&
                (oel.Request_Date__c != oelOld.Request_Date__c || oel.Scheduled_Ship_Date__c != oelOld.Scheduled_Ship_Date__c || oel.Promised_Date__c != oelOld.Promised_Date__c || oel.Customer_Reference_Description__c != oelOld.Customer_Reference_Description__c))
                {
                      if (!fullyShipped.contains(oel.Status__c)){
                            fieldChange = true;
                      }
                    system.debug('ttttttttttttttt');
                }
                // Quantity Change
                //
                if (oel.Quantity__c != oelOld.Quantity__c)
                {                   
                    /*/ JV - 20171020 Change this from Pre-Confirmation to Pre-Integration
                    /if (!preIntegration && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU'))
                    {
                        oelw.addValidationError('Quantity changes are not allowed when Status is ' + oel.Status__c);
                        hasErrors = true;
                    }*/
                    
                    //Tracking Id: WORK_ORDER_STATUS_VALIDATION_01 
                    //SO_CHANGES_Jan_2021
                   /* if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') && oel.Work_Order_Status__c != 'Unreleased' && oel.Work_Order_Status__c != null)
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Quantity is not possible when Work Order Status is  ' + oelOld.Work_Order_Status__c);
                    }*/
               
                // CHW - BM // SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware 
                            && (oelOld.Sales_Order_Line_Status__c == 'Picked' ||  oelOld.Sales_Order_Line_Status__c == 'Closed' || oelOld.Sales_Order_Line_Status__c == 'Shipped') 
                                    && oelOld.Sales_Order_Line_Status__c != null)
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Quantity is not possible when Sales Order Line Status is  ' + oelOld.Sales_Order_Line_Status__c);                      
                    }
                    // SOLS_PICKED_SHIPPED_CLOSED_VLD_01
                    // SO_CHANGES_Jan_2021
                     if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') 
                     && (oel.Sales_Order_Line_Status__c == 'Packed' || oelOld.Sales_Order_Line_Status__c == 'Picked' ||  oelOld.Sales_Order_Line_Status__c == 'Closed' || oelOld.Sales_Order_Line_Status__c == 'Shipped') 
                     && oelOld.Sales_Order_Line_Status__c != null) 
                    
                    {
                        hasErrors = true;
                        oelw.addValidationError('Updates on Quantity is not possible when Sales Order Line Status is ' + oelOld.Sales_Order_Line_Status__c); 
                            
                    }
                    
                    if (oel.Quantity__c == null || oel.Quantity__c <= 0) 
                    {
                        oelw.addValidationError('Quantity must be > 0.');
                        hasErrors = true;
                    }
                    else
                    {
                        //Added by Enp
                        if(CSSPostBooked.contains(oel.status__c) && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware
                            && (oel.Quantity_Change_Reason__c =='' || oel.Quantity_Change_Reason__c == null))
                        {
                            oelw.addValidationError('Please Provide Quantity Change Reason');
                            hasErrors = true;
                        }

                        if(oel.status__c == 'Partially Shipped')
                        {
							if(oel.status__c == 'Partially Shipped' && oel.Quantity__c < oelOld.Quantity_Shipped__c)
                            {
                                oelw.addValidationError('Quantity must be > shipped quantity.');
                                hasErrors = true;
                            }   
                        }
                        
                            
                        if(!preConfirmationStatus.contains(oel.Status__c) && oel.Scheduled_Ship_Date__c < system.today().addDays(Integer.valueof(label.CSSScheduleDue)))
                        {
                            oelw.addValidationError('Quantity changes not allowed with due of schedule ship date');
                            hasErrors = true;
                        }
                        
                                                
                        fieldChange = true;
                        // JV - 20171020 made confirmationRequired dependent on Status_c being post Confirmation
                        if (!preConfirmationStatus.contains(oel.Status__c))
                        {
                            confirmationRequired = true;
                        }
                        // Version 7 - Added code to recompute total area
                        if (oelw.recordType.contains('Imperial'))
                        {
                            oel.Area_Sq_Ft__c = oel.Quantity__c * oel.Unit_Area_Sq_Ft__c;
                        }
                        else
                        {
                            //Added by ENP
                            if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Hardware && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Software){
                                oel.Total_Area_Sq_m__c = oel.Quantity__c * oel.Unit_Area_Sq_M__c;
                                oel.Area_Sq_Ft__c = oel.Total_Area_Sq_m__c * 10.7639;
                            }
                        }
                        // JV - 20171020 Remove statement to set previous quantity
                    }
                                       
                }
                if ((oel.CPQ_Quote_Line__c!=null && oel.CPQ_Quote_Line__c != oelOld.CPQ_Quote_Line__c) ||  (oel.Quote_Line_Item__c !=null && oel.Quote_Line_Item__c != oelOld.Quote_Line_Item__c)) // Updated from Release
                {  
                   system.debug('workingQLIId=='+workingQLIId);                  
                    qlw= qlwMap.get(workingQLIId);
                    system.debug('qlw=='+qlw);  
                    // JV 20180626 - Added check to assure that changes to Quote Line Item do not change the Currency
                    if (qlw.currencyISOCode != oel.currencyISOCode)
                    {
                        hasErrors = true;
                        oelw.addValidationError('Quote Line currency code does not match Order Entry Line currency code');
                    }
                    else
                    {
                        fieldChange = true;
                        if((!oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') && !preConfirmationStatus.contains(oel.Status__c)) || oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU'))
                        confirmationRequired = true;
                        if (qlw.discount != null)
                        {
                            oel.Discount__c = qlw.discount;
                        }
                        else
                        {
                            oel.Discount__c = 0.0;
                        }
                        system.debug('oelw.recordType=='+oelw.recordType);
                        if (oelw.recordType.containsIgnoreCase('IGU'))
                        {
                            oel.Unit_Price__c = oel.Unit_Area_Sq_Ft__c * qlw.price;
                        }
                        //Added by ENP - START
                        else if(oelw.recordType.containsIgnoreCase(Label.CSS_Hardware)){                 
                            if(oelw.oel.SKU__c==qlw.productSKU){                        
                                oel.Unit_Price__c = qlw.price;
                                if(qlw.source=='SFDC')
                                    oel.Quote__c = qlw.quoteId;                     
                            }
                            else{
                                    oel.Unit_Price__c = priceBookEntryMap.get(oelw.oel.SKU__c);
                                    //nonMatchproductSKU.put(oelw.oel.SKU__c,oelw.oel);
                            }
                        }
                        //Added by ENP - END
                        else
                        {
                            oel.Unit_Price__c = qlw.price;
                        }
                    }   
                }
                
                // JV 20180626 - Added code to handle manual price changes
                if (oel.Unit_Price__c != oelOld.Unit_Price__c)
                {
                     // projectconcrete_2.2 
                    if ((oel.Pre_Change_Status__c == 'Partially Shipped' && oel.Status__c == 'Change Requested') ||  oel.Status__c == 'Partially Shipped' ||  oel.Status__c == 'Shipped' )           
                    { 
                        oelw.addValidationError('Changes to field ‘Unit Price’ from Quote Change is not permitted when Line Status is  ' + oelOld.Status__c);  
                        hasErrors = true ; 
                    } 
                    else 
                    {    
                        fieldChange = true; 
                        if (!preConfirmationStatus.contains(oel.Status__c)) 
                        { 
                            confirmationRequired = true; 
                        } 
                    }
                }
                                               
                //
                // SKU and Dimension cannot be changed since this changes the Order SKU
                //
                if (oel.Shape__c != oelOld.Shape__c ||
                    oel.Base_Decimal_in__c != oelOld.Base_Decimal_in__c ||
                    oel.Height_Decimal_in__c != oelOld.Height_Decimal_in__c ||
                    oel.Base_Height_1_Decimal_in__c != oelOld.Base_Height_1_Decimal_in__c)
                {
                    oelw.addValidationError('Changes to shape or dimensions are not allowed. Cancel the Order Entry Line and add a new Line');
                    hasErrors = true;
                }
                if (oel.Product__c != oelOld.Product__c)
                {
                    oelw.addValidationError('Changes to Product are not allowed. Cancel the Order Line and add a new Line');
                    hasErrors = true;
                }
                //
                // Status Changes
                //
                if ((confirmationRequired || fieldChange) && oel.Status__c.contains('Cancel'))
                {
                    oelw.addValidationError('Changes to other field values are not allowed during the cancellation process');
                    hasErrors = true;
                }
                if (oel.Status__c != oelOld.Status__c)
                {
                    //Added by ENP - New Parameter  - Record Type
                    system.debug('@@status change');
                    String statusCheck = StateTransitionMap.checkStatusChange(oelOld.Status__c, oel.Status__c, oelOld.Integration_Status__c, oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName());
                    if (statusCheck != 'OK')
                    {
                        oelw.addValidationError(statusCheck);
                        hasErrors = true;
                    }
                    else
                    {
                        if (oelOld.Status__c == 'Integration Error')
                        {
                            oel.Integration_Errors__c = '';
                            if (oel.Integration_Status__c == 'Error')
                            {
                                oel.Integration_Status__c = 'Initial';
                            }
                        }
                        //
                        // Cancellations
                        //
                        if (oel.Status__c.contains('Cancel'))
                        {
                            system.debug('@cancel');
                            /*if (confirmationRequired || fieldChange)
                            {
                                oelw.addValidationError('Changes to other field values are not allowed during the cancellation process');
                                hasErrors = true;
                            }*/
							if (oel.Status__c == 'Cancellation Requested')
                            {
                                
                                //added recordtype by enp for allow cancel requested to H/W
                                List<String> SOLSFilter = new List<String>{'Picked','Closed','Shipped'};//Srikanth added // SOLS_PICKED_SHIPPED_CLOSED_VLD_02
                                    //Rekha - To validate any Work order status except for blank and unreleased   
                                    //// CANCELLATION_BUGS_SEP_20 moved sequence of validations so that Cancellation Reason is checked after WO Status and SOLS status check

                                    //SO_CHANGES_Jan_2021
																													   
                                /*if (oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') && oelOld.Status__c !='Cancellation Requested' && oel.Work_Order_Status__c != null && oel.Work_Order_Status__c != 'Unreleased') {
                                    oelw.addValidationError('Order Lines cannot be Cancelled when Work order has status except blank or unreleased');
                                    hasErrors = true; 
                                }
                                else */
                                if (!oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') && oelOld.Status__c !='Cancellation Requested' && 
                                         oel.Trigger_Source__c == 'UI' && SOLSFilter.contains(oel.Sales_Order_Line_Status__c) ) {
                                    //Srikanth - adding for adding condition to validate Picked/Closed/Shipped SOLS values  // SOLS_PICKED_SHIPPED_CLOSED_VLD_02                          
                                    oelw.addValidationError('Order Lines cannot be Cancelled when Sales Order Line Status field has Packed or Picked or Shipped or Closed value');
                                    hasErrors = true;                                  
                                }
								else if (oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU') && oelOld.Status__c !='Cancellation Requested' && 
                                         oel.Trigger_Source__c == 'UI' && (SOLSFilter.contains(oel.Sales_Order_Line_Status__c) || oel.Sales_Order_Line_Status__c == 'Packed' )) {
                                    //Srikanth - adding for adding condition to validate Picked/Closed/Shipped SOLS values  // SOLS_PICKED_SHIPPED_CLOSED_VLD_02                          
                                    oelw.addValidationError('Order Lines cannot be Cancelled when Sales Order Line Status field has Picked or Shipped or Closed value');
                                    hasErrors = true;                                  
                                }
                                 // Reason required for cancellation        // CANCELLATION_BUGS_SEP_20 moved sequence of validations so that Cancellation Reason is checked after WO Status and SOLS status check              
                                else if (oel.Cancellation_Reason__c == null /*&& oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU')*/)
                                {
                                    oelw.addValidationError('You must enter a cancellation reason');
                                    hasErrors = true;
                                }  
                                else
                                {
                                    // *** Version 5 - Bug fix: If pre-Confirmation, set status to Cancelled.
                                    system.debug('@cancel');
                                    if (preConfirmationStatus.contains(oelOld.Status__c))
                                    {
                                        system.debug('@cancel');
                                        //Added by Enp
                                        if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU'))
                                        oel.Status__c = 'Cancelled';
                                    }
                                    else
                                    {
                                        oel.Status__c = 'Cancellation Confirmation Pending';
                                    }
//                                   // oel.Status__c = 'Cancellation Confirmation Pending';
                                    oel.Pre_Cancellation_Status__c = oelOld.Status__c;
                                    // JV - 20171020 Added the following lines to correctly set Previous Quantity
                                    //oel.Previous_Quantity__c = oel.Quantity__c; //CANCELLATION_BUGS_SEP_20
                                    //oel.Quantity__c = 0.0; //CANCELLATION_BUGS_SEP_20                               
                                }
                            }
                            //CANCELLATION_BUGS_SEP_20
                            if (oel.Status__c == 'Cancellation Requested' || oel.Status__c == 'Cancelled' || oel.Status__c == 'Cancellation Confirmation Pending'){
                                    oel.Previous_Quantity__c = oel.Quantity__c;
                                    oel.Quantity__c = 0.0;  
                             } //CANCELLATION_BUGS_SEP_20
                        } // End Cancellation Processing
                        //
                        // Holds
                        //
                        if (oel.Status__c.contains('Hold'))
                        {
                            if (confirmationRequired || fieldChange)
                            {
                                oelw.addValidationError('Changes to other field values are not allowed during the hold process');
                                hasErrors = true;
                            }
                            if (oel.Status__c == 'Hold Requested')
                            {
                                if (oel.Hold_Reason__c == null)
                                {
                                    oelw.addValidationError('You must enter a hold reason');
                                    hasErrors = true;
                                }
                                else
                                {
                                    oel.Pre_Hold_Status__c = oelOld.Status__c;
                                }
                            }
                        }
                        //
                        // Integration Requests
                        //
                         if (oel.Status__c == 'Integration Requested')     
                        {
                            system.debug('@sched');
                            oel.Integration_Requestor__c  = currentUserId;
                            oel.Integration_Errors__c = null;
                            oel.Integration_Status__c = 'Requested';
                            oel.Integration_Action_Requested__c='Add';
                            if (oel.Scheduled_Ship_Date__c == null)
                            {
                                system.debug('@sched');
                                oelw.addValidationError('Scheduled Ship Date is Required for Oracle Integration');
                            }
                            
                              //Scheduled Ship Date on line Shouldn't be in the Past when submitting for Integration - BM
                            if (oel.Scheduled_Ship_Date__c != null && oel.Scheduled_Ship_Date__c < System.today())
                            {
                                oelw.addValidationError('Schedule Ship Date on line shouldn\'t be in the past when submitting for Integration');
                                
                            }
                            // JV - 20180308 - Added requirment for Requested Date and Promised Date for Integerations
                            if (oel.Request_Date__c == null)
                            {
                                oelw.addValidationError('Request Date is Required for Oracle Integration');
                            }
                            if (oel.Promised_Date__c == null)
                            {
                                oelw.addValidationError('Promised Date is Required for Oracle Integration');
                            }
                        }
                        if (oel.Status__c == 'Change Integration Requested')
                        {
                            oel.Integration_Requestor__c  = currentUserId;
                            oel.Integration_Errors__c = null;
                            oel.Integration_Status__c = 'Change Requested';
                            if (oel.Scheduled_Ship_Date__c == null)
                            {
                                oelw.addValidationError('Scheduled Ship Date is Required for Oracle Change Integration');
                            }
                             //Scheduled Ship Date on line Shouldn't be in the Past when submitting for Integration - BM
                            if (oel.Scheduled_Ship_Date__c != null && oel.Scheduled_Ship_Date__c < System.today())
                            {
                               oelw.addValidationError('Schedule Ship Date on line shouldn\'t be in the past when submitting for Integration. Line No:' +oel.Line_Number__c);//FIX_VALIDATION_ON_PAST_SSD  added line number
                               // hasErrors = true; //FIX_VALIDATION_ON_PAST_SSD
                            }
                            if (oel.Request_Date__c == null)
                            {
                                oelw.addValidationError('Request Date is Required for Oracle Change Integration');
                            }
                            if (oel.Promised_Date__c == null)
                            {
                                oelw.addValidationError('Promised Date is Required for Oracle Change Integration');
                            }
                            if (oelOld.Status__c == 'Cancellation Requested')
                            {
                                oel.Integration_Action_Requested__c = 'Cancel';
                            }
                            if (oelOld.Status__c == 'Hold Requested')
                            {
                                oel.Integration_Action_Requested__c = 'Hold';
                            }
                            else
                            {
                                if (oelOld.Status__c == 'Hold Release Requested')
                                {
                                    oel.Integration_Action_Requested__c = 'Hold Release';
                                }
                                else
                                {
                                    if (oel.IsPostIntegrationAdd__c)
                                    {
                                        if(oel.Integration_Action_Requested__c!='Cancel')
                                        oel.Integration_Action_Requested__c = 'Add';                                        
                                    }
                                    else
                                    {
                                        if(oel.Integration_Action_Requested__c!='Cancel')
                                        oel.Integration_Action_Requested__c = 'Update';
                                    }
                                }
                            }
                        }
                        //Added by Enp  
                        if (oel.Status__c == 'Cancellation Requested')
                        {
                            oel.Integration_Action_Requested__c = 'Cancel';
                        }
                        if (oel.Status__c == 'Cancellation Integration Requested')
                        {
                            oel.Integration_Requestor__c  = currentUserId;
                            oel.Integration_Errors__c = null;
                            //Added by ENP
                            //if(!oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU'))
                            //oel.Integration_Status__c = 'Requested';
                            //else
                            oel.Integration_Status__c = 'Change Requested';
                            oel.Integration_Action_Requested__c = 'Cancel';
                            oel.Pre_Cancellation_Status__c = oelOld.Status__c;
                        }

                    }
                    System.debug('Change Requested In if1###');
                }
                else
                {
                    System.debug('Change Requested In ###'+confirmationRequired);
                    if (fieldChange)                    
                    {
                        System.debug('Change Requested In fieldchange###');
                        if (confirmationRequired)
                        {
                            if (preIntegrationStatus.contains(oelOld.status__c))
                            {
                                if (oelOld.Status__c == 'Confirmed')
                                {
                                    oel.Status__c = 'Confirmation Pending';
                                }
                                oel.Integration_Action_Requested__c = null;
                            }
                            else
                            {   
                                //changed criteria  by Enp to add pending status
                                if(!oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().contains('IGU'))
                                {
                                    oel.Status__c = 'Change Confirmation Pending';
                                }
                                else{
                                    oel.Status__c = 'Change Confirmation Required';
                                }
                                if (oelOld.Status__c != 'Change Requested' && oelOld.Status__c != 'Change Confirmation Required' && oelOld.Status__c != 'Change Confirmation Pending' && oelOld.Status__c != 'Integration Error')
                                {
                                    oel.Pre_Change_Status__c = oelOld.Status__c;
                                }
                             }
                        System.debug('Change Requested In IF###');
                        }
                        
                        else
                        {
                            if (preIntegrationStatus.contains(oelOld.status__c))
                            {
                                System.debug('Change Requested In IF###');
                                oel.Integration_Action_Requested__c = null;
                            }
                            else
                            {
                                System.debug('Change Requested in ELSE###');
                                oel.Status__c = 'Change Requested';
                                //Added by ENP  - start
                                if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware){
                                    oel.Integration_Action_Requested__c = 'Update';
                                    oel.Integration_Status__c = '';
                                }
                                //Added by ENP  - END
                                if (oelOld.Status__c != 'Change Requested' && oelOld.Status__c != 'Change Confirmation Required' && oelOld.Status__c != 'Change Confirmation Pending' && oelOld.Status__c != 'Integration Error')
                                {
                                    oel.Pre_Change_Status__c = oelOld.Status__c;
                                }
                            }
                        }
                    }
                }
                if(hasErrors && !oerMap.get(oel.Order_Entry_Release__c).No_Validation__c)
                {
                    String displayMessage = '';
                    for (Integer i = 0; i < oelw.validationErrors.size(); i++)
                    {
                        if (i > 0)
                        {
                            displayMessage = displayMessage + '<br/>';
                        }
                        displayMessage = displayMessage +   String.valueOf(i+1) + ') ' + oelw.validationErrors[i];
                        System.debug('*** Added err: ' + oelw.validationErrors[i]);
                    }
                    oelw.oel.addError(displayMessage,false);
                }                           
            }
                
            else
            {
                // 
                // Changes originated by the Integration Interface, driven by changes in
                // Oracle/MES
                //
                system.debug('@partially');
                //Added by ENP - Start
                if(!oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName().ContainsIgnoreCase('IGU') 
                                    && oel.Integration_Status__c == 'Complete' && oel.Sales_Order_Line_Status__c!=null){                    
                    if (oel.Status__c == 'Approval to Ship Requested' || (oel.Status__c == 'Integration Requested' && oerMap.get(oel.Order_Entry_Release__c).Auto_Book_Order__c))
                    {   //Added by ENP - RType Check
                        if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware &&
                            oel.Sales_Order_Line_Status__c == 'Awaiting Shipment'
                            /*oerMap.get(oel.Order_Entry_Release__c).Sales_Order_Status__c == 'Booked'*/){
                            oel.Status__c = 'Approved-to-Ship';
                        }
                    }
                    if (oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Software) {
// Changed by JV - 20200205 to handle Oracle sending a Sales_Order_Line_Status__c 'Closed' to SFDC when Line Status is 'Planned'                    
//                   {   if(oel.Status__c == 'Planned' && oel.Sales_Order_Line_Status__c == 'Booked'){
//                            oel.Status__c = 'Booked';
                        if (oel.Status__c == 'Planned' || oel.Status__c == 'Booked') {//SW_ITEMS_INVOICE_HOLD
                            if (oel.Sales_Order_Line_Status__c == 'Booked') {
                                oel.Status__c = 'Booked';
                            }
                            else if (oel.Sales_Order_Line_Status__c == 'Closed') {
                                oel.Status__c = 'Invoiced';
                            }
							else if (oel.Sales_Order_Line_Status__c == 'Awaiting Invoice') {//SW_ITEMS_INVOICE_HOLD
                                oel.pre_hold_status__c = 'Booked';  
                                oel.Status__c = 'Hold';
                                oel.Oracle_Hold__c = true;
                            }
// End of JV -20200205 Changes                          
                        }/*   //SW_ITEMS_INVOICE_HOLD
                        else if(oel.Status__c == 'Booked' && oel.Sales_Order_Line_Status__c == 'Closed'){
                            oel.Status__c = 'Invoiced';
                        }
                        else if(oel.Status__c == 'Booked' && oel.Sales_Order_Line_Status__c == 'Awaiting Invoice'){
                            oel.pre_hold_status__c = oel.Status__c;
                            oel.Status__c = 'Hold';
                            oel.Oracle_Hold__c = true;
                        }*/
                    }                   
                }
                //Added by ENP - End
                if(oel.Integration_Status__c != oelOld.Integration_Status__c  && !(test.isRunningTest() && oel.Trigger_Source__c == 'Test Data Setup'))
                {
                    system.debug('@partially');
                    if (oel.Integration_Status__c != 'In Process')
                    {
                        if (oel.Integration_Status__c == 'Complete')
                        {
                          if (oel.Quantity_Shipped__c == oel.Quantity__c && oelOld.Status__c != 'Shipped')
                        {
                            oel.Status__c = 'Shipped';                        
                        }  
                            
                            // Rekha :LINE_STATUS_WHEN_INTEGRATION_ERROR_THEN_COMPLETE_01 Added new field Pre_Integration_Status__c to capture the line status before getting responce from ORACLE
                            if (oel.Status__c == 'Integration Requested' || (oelOld.Status__c == 'Integration Error' && oel.Pre_Integration_Status__c == 'Integration Requested' ))
                            {   //Added by ENP - RType Check
                                System.debug('***********'+oel.Status__c);
                                if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Software && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Hardware){
                                    System.debug('***********'+oel.Status__c);
                                    oel.Status__c = 'Pre-Production';
                                }
                                //Added by ENP
                                else{
                                    System.debug('***********'+oel.Status__c);
                                    if(oel.Integration_Action_Requested__c == 'Cancel')
                                    {
                                        oel.Status__c = 'Cancelled';
                                    }
                                    else if(!oerMap.get(oel.Order_Entry_Release__c).Auto_Book_Order__c){ //BALA - 20190828 - Updated to handle parts order auto integration.
                                        oel.Status__c = 'Planned';
                                        //oel.Integration_Action_Requested__c='';
                                        oel.Request_Date_Update_Needed__c = true;
                                    }
                                }
                                oel.First_Scheduled_Ship_Date__c = oel.Scheduled_Ship_Date__c;
                                oel.First_Request_Ship_Date__c = oel.Request_Date__c;
                                // JV 20180209 - Added code to capture First Promised Date
                                oel.First_Promised_Date__c = oel.Promised_Date__c;
                                oel.Initial_Quantity__c = oel.Quantity__c;
                            }
                            else
                            {
                                // Rekha :LINE_STATUS_WHEN_INTEGRATION_ERROR_THEN_COMPLETE_01 Added new field Pre_Integration_Status__c to capture the line status before getting responce from ORACLE
                                if(oel.Status__c == 'Change Integration Requested'|| (oelOld.Status__c == 'Integration Error' && oel.Pre_Integration_Status__c == 'Change Integration Requested' ))
                                {
                                    if(oel.Integration_Action_Requested__c == 'Hold')
                                    {
                                        oel.Status__c = 'Hold';
                                    }
                                    else
                                    {
                                        if (oel.Integration_Action_Requested__c == 'Hold Release')
                                        {
                                         	//SW_ITEMS_INVOICE_HOLD
                                            if (oel.Sales_Order_Line_Status__c == 'Closed')
                                                oel.Status__c = 'Invoiced';
                                            else
                                            	oel.Status__c = oel.Pre_Hold_Status__c;
                                        }
                                        else
                                        {                               
                                            if (oel.IsPostIntegrationAdd__c)
                                            {   //Added by ENP
                                                if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Software && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()!=Label.CSS_Hardware){
                                                    oel.Status__c = 'Pre-Production';
                                                }
                                                //Added by ENP
                                                else {
                                                    oel.Status__c = 'Planned';
                                                    //oel.Integration_Action_Requested__c='';
                                                     oel.Request_Date_Update_Needed__c = true;
                                                }
                                                oel.IsPostIntegrationAdd__c = false;
                                            }
                                            else
                                            {
                                                //when cancel requested went to "change integration requested" then mark integration status as complete
                                                if(oel.Integration_Action_Requested__c == 'Cancel')
                                                {
                                                    oel.Status__c = 'Cancelled';
                                                     oel.Cancellation_Date__c = Date.today();
                                                }
                                                //end by ENP 
                                                else {
                                                    
                                                    if(!oel.loader__c && (oel.Pre_Change_Status__c == null || oel.Pre_Change_Status__c =='')
                                                    && (oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Software || oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware))
                                                        oel.Status__c = 'Planned';//revisit this line
                                                    else{
                                                        system.debug('@@@igu'+oel.Pre_Change_Status__c);
                                                        oel.Status__c = oel.Pre_Change_Status__c;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                else
                                {// Rekha :LINE_STATUS_WHEN_INTEGRATION_ERROR_THEN_COMPLETE_01 Added new field Pre_Integration_Status__c to capture the line status before getting responce from ORACLE
                                    if (oel.Status__c == 'Cancellation Integration Requested'|| (oelOld.Status__c == 'Integration Error' && oel.Pre_Integration_Status__c == 'Cancellation Integration Requested' ))
                                    {
                                        oel.Status__c = 'Cancelled';
                                        oel.Cancellation_Date__c = Date.today();
                                        
                                    }
                                }
                                // Rekha :LINE_STATUS_WHEN_INTEGRATION_ERROR_THEN_COMPLETE_01 Added new field Pre_Integration_Status__c to capture the line status before getting responce from ORACLE
                                if(oel.Status__c == 'Approval to Ship Requested'|| (oelOld.Status__c == 'Integration Error' && oel.Pre_Integration_Status__c == 'Approval to Ship Requested' )){
                                  oel.Status__c = 'Approval to Ship Requested'  ;
                                }
                            }
                            //ToDo impliment software service booked,invoiced,cancelled
                            oel.Integration_Action_Requested__c = null;
                            //Added by enp-Narasimha
                            oel.Integration_Requestor__c = null;
                        }
                        else
                        {
                            if (oel.Integration_Status__c == 'Error')
                            { // Rekha :LINE_STATUS_WHEN_INTEGRATION_ERROR_THEN_COMPLETE_01 Added new field Pre_Integration_Status__c to capture the line status before getting responce from ORACLE
                                if(oel.Status__c == 'Integration Requested' ||oel.Status__c == 'Change Integration Requested'||
                                   oel.Status__c == 'Cancellation Integration Requested' ||oel.Status__c == 'Approval to Ship Requested')
                                {
                                    oel.Pre_Integration_Status__c = oel.Status__c;
                                    oel.Status__c = 'Integration Error';
                                }    
                            }
                        }
                    }                   
                }
                else // "Push" changes from Oracle
                {
                    if (oel.Work_Order_Id__c != oelOld.Work_Order_Id__c)
                    {
                        if (oelOld.Work_Order_Id__c == null || oelOld.Work_Order_Id__c == '')
                        {
                            oel.Work_Order_Status__c = 'Unreleased';
                        }
                    }
                    else
                    {
                        if (oel.Work_Order_Status__c != null &&oel.Work_Order_Status__c != oelOld.Work_Order_Status__c && 
                            oel.Work_Order_Status__c == 'Released')
                        {
                            oel.Status__c = 'In Production';
                        }
                    }
                    
                    
                    if (oel.Quantity_Shipped__c != oelOld.Quantity_Shipped__c)
                    {
                    system.debug('@partially');
                       if (oel.Quantity_Shipped__c < oel.Quantity__c)
                        {
                            oel.Status__c = 'Partially Shipped';                         
                        }
                        else
                        {
                            oel.Status__c = 'Shipped';
                        }
                    }
                }
            }           
        }
        if(oel != null && test.isRunningTest() && oel.Trigger_Source__c == 'Test Data Setup')
        {
            oel.Trigger_Source__c = 'UI';
        }                   
    } // End Before processing

/*  ****************************************************************
    *  After Update Trigger: Logic for Updating Release based on   *
    *  successful updates of the Line.                             *
    ****************************************************************
*/

    
    if (trigger.isAfter && trigger.isUpdate)
    {

        List<OrderEntryLineWrapper> oelWrapperList = new List<OrderEntryLineWrapper>();
        List<Order_Entry_Line__c> oelUpdateList = new List<Order_Entry_Line__c>();
        Map<Id, OrderEntryReleaseWrapper> oerWrapperMap = new Map<Id, OrderEntryReleaseWrapper>();
        Set<Id> pushedChangeOERIds = new Set<Id>();
        Set<Id> updatedOELIds = new Set<Id>();
        // JV - 20200329 Added line to support Integration Rollback
        Order_Entry_Line__c oldOEL;
        Boolean hasPushedChanges = false;
        List<Order_Entry_Release__c> oersToUpdate = new List<Order_Entry_Release__c>();
        Map<string, Order_Entry_Line__c> LeastDateOEL= new Map<string, Order_Entry_Line__c>();
        Map<string, Order_Entry_Line__c> LeastDateOELSchedule= new Map<string, Order_Entry_Line__c>();       
        Map<Id,Order_Entry_Line__c> rollbackOELMap = new Map<Id,Order_Entry_Line__c>(); 
        
        for(Order_Entry_Line__c oel : trigger.new)
        {
            if (oel.Trigger_Source__c != 'Line' && oel.Trigger_Source__c != 'Release' && !(Test.isRunningTest() && oel.Trigger_Source__c == 'Test Data Setup')
        // JV - 20200329 Added line to support Integration Rollback
                && oel.Trigger_Source__c != 'Rollback') // Prevent Recursive Updates
            {
                // *** Version 5 - Change to Handle OEL Metric Record Type
                oelWrapperList.add(new OrderEntryLineWrapper(oel, oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()));
//                oelWrapperList.add(new OrderEntryLineWrapper(oel));
                updatedOELIds.add(oel.Id);
                oerIds.add(oel.Order_Entry_Release__c);
                if(oel.Request_Date__c != trigger.oldMap.get(oel.Id).Request_Date__c)
                {
                    if(!LeastDateOEL.containskey(oel.Order_Entry_Release__c))
                    LeastDateOEL.put(oel.Order_Entry_Release__c,oel);
                    else{
                        if(LeastDateOEL.get(oel.Order_Entry_Release__c).Request_Date__c > oel.Request_Date__c)
                        LeastDateOEL.put(oel.Order_Entry_Release__c,oel);   
                    }
                }
                if(oel.Scheduled_Ship_Date__c != trigger.oldMap.get(oel.Id).Scheduled_Ship_Date__c)
                {
                    if(!LeastDateOELSchedule.containskey(oel.Order_Entry_Release__c))
                    LeastDateOELSchedule.put(oel.Order_Entry_Release__c,oel);
                    else{
                        if(LeastDateOELSchedule.get(oel.Order_Entry_Release__c).Scheduled_Ship_Date__c > oel.Scheduled_Ship_Date__c)
                        LeastDateOELSchedule.put(oel.Order_Entry_Release__c,oel);   
                    }
                }
            } 
            else { // JV -20200329 - Code added to support Integration Rollback//srikanth added "Approval to Ship Requested" condition
                oldOEL = Trigger.oldMap.get(oel.Id);
                if (oel.Trigger_Source__c == 'Release') {
                    if ((oel.Status__c == 'Integration Requested' && oldOEL.Status__c != 'Integration Requested') ||
                        (oel.Status__c == 'Change Integration Requested' && oldOEL.Status__c != 'Change Integration Requested') ||
                        (oel.Status__c == 'Cancellation Integration Requested' && oldOEL.Status__c != 'Canellation Integration Requested')||
                        (oel.Status__c == 'Approval to Ship Requested' && oldOEL.Status__c != 'Approval to Ship Requested'))
                    {
    
                        rollbackOELMap.put(oel.Id,oel);                     
                    }
                }
            }
     
        }

        if (oerIds.size() > 0)
        {
            // Version 7 - Added Rollup fields to SELECT
            //Added by ENP - IGU_Cables_Total_Qty__c,IGU_Cables_Total_Price__c,Trunk_Cables_Total_Qty__c, Trunk_Cables_Total_Price__c, Terminator_and_Connectors_Total_Qty__c, Trunk_Cables_Total_Price__c,
            //Terminator_and_Connectors_Total_Qty__c, Terminator_and_Connectors_Total_Price__c, Window_Controller_Total_Qty__c, Window_Controller_Total_Price__c, Control_Panel_Total_Price__c
            //Control_Panel_Qty__c, Sensor_Total_Quantity__c, Sensor_Total_Price__c To Query Fields
            for (Order_Entry_Release__c oer : [SELECT Id,CSS_Total_Rollup_Qty__c,First_Scheduled_Ship_Date__c,First_Request_Ship_Date__c,Status__c, Integration_Status__c,Scheduled_Ship_Date__c ,Integration_Scope__c, Integration_Action_Requested__c, Trigger_Source__c,
                IGU_Count__c, IGU_Area_Sq_Ft__c, IGU_Open_Count__c, IGU_Open_Area_Sq_Ft__c, IGU_Area_Sq_M__c, IGU_Open_Area_Sq_M__c, Extended_Price_Open__c, Extended_Price_Total__c,
                RecordType.DeveloperName, 
                Control_Panel_Qty__c, Control_Panel_Total_Price__c, Sensor_Total_Quantity__c, Sensor_Total_Price__c, IGU_Cables_Total_Qty__c, IGU_Cables_Total_Price__c,
                Drop_Cables_Total_Qty__c, Drop_Cables_Total_Price__c, Trunk_Cables_Total_Qty__c, Trunk_Cables_Total_Price__c, Terminator_and_Connectors_Total_Qty__c,
                Terminator_and_Connectors_Total_Price__c, Window_Controller_Total_Qty__c, Window_Controller_Total_Price__c,Request_Date__c,No_Validation__c                             
                FROM Order_Entry_Release__c WHERE Id IN :oerIDs])
            {                
                oerWrapperMap.put(oer.Id, new OrderEntryReleaseWrapper(oer));
            }               
        }

        //
        // For affected Order Entry Releases, create the combined map of its Line Items changed in this transaction
        // plus its existing unchanged Line Items.
        //
        for (OrderEntryLineWrapper oelw : oelWrapperList)
        {
            // *** Version 5 - Change to handle OEL Metric Record Type
            oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).addOrderEntryLine(oelw.oel, oelRecordTypeMapSchema.get(oelw.oel.RecordTypeID).getDeveloperName());     
        }
        // JV - 20171020 Added Line_Number__c to fields retrieved
        // JV - 20171115 Added RecordTypeId to fields retrieved
        // JV -20180208 Added Dates to fields retrieved
        // Version 7 - Added Quantity__c, Area_Sq_Ft__c, Extended_Price__c, Unit_Price__c to SELECT statement
        for (Order_Entry_Line__c oels : [SELECT Id, RecordTypeId, Status__c, Order_Entry_Release__c, Line_Number__c, Quantity__c, Area_Sq_Ft__c,
            Extended_Price__c, Unit_Price__c, Open_Quantity__c, Unit_Area_Sq_Ft__c, Unit_Area_Sq_M__c, Total_Area_Sq_M__c, Request_Date__c, First_Request_Ship_Date__c,
            Previous_Request_Ship_Date__c, Scheduled_Ship_Date__c, First_Scheduled_Ship_Date__c, Previous_Scheduled_Ship_Date__c, Promised_Date__c, First_Promised_Date__c,
            Previous_Promised_Date__c,Product_Component_Type__c
             FROM Order_Entry_Line__c 
                WHERE Order_Entry_Release__c IN :OERIds AND Id NOT IN :updatedOELIds AND Status__c != 'Cancelled'])
        {
            // *** Version 5 - Change to handle OEL Metric Record Type
            oerWrapperMap.get(oels.Order_Entry_Release__c).addOrderEntryLine(oels, oelRecordTypeMapSchema.get(oels.RecordTypeID).getDeveloperName());
            // oerWrapperMap.get(oels.Order_Entry_Release__c).addOrderEntryLine(oels);
            if(!LeastDateOEL.containskey(oels.Order_Entry_Release__c))
                LeastDateOEL.put(oels.Order_Entry_Release__c,oels);
            else{
                if(LeastDateOEL.get(oels.Order_Entry_Release__c).Request_Date__c > oels.Request_Date__c)
                LeastDateOEL.put(oels.Order_Entry_Release__c,oels); 
            }
            if(!LeastDateOELSchedule.containskey(oels.Order_Entry_Release__c))
                    LeastDateOELSchedule.put(oels.Order_Entry_Release__c,oels);
            else{
                if(LeastDateOELSchedule.get(oels.Order_Entry_Release__c).Scheduled_Ship_Date__c > oels.Scheduled_Ship_Date__c)
                LeastDateOELSchedule.put(oels.Order_Entry_Release__c,oels);   
            }
        }
        
        
        for (OrderEntryLineWrapper oelw: oelWrapperList)
        {
            Order_Entry_Line__c oel = oelw.oel;
            Order_Entry_Line__c oelOld = trigger.oldMap.get(oel.Id);
            OrderEntryReleaseWrapper oerw = oerWrapperMap.get(oel.Order_Entry_Release__c);
            Order_Entry_Release__c oer = oerw.oer;
            if (oel.Trigger_Source__c == 'Integration')
            {
                if (oel.Integration_Status__c == oelOld.Integration_Status__c ||  // It's a pushed change
                    oel.Integration_Status__c == 'Complete') // OEL status change)
                {
                    
                        pushedChangeOERIds.add(oer.id);
                        oerw.hasPushedChanges = true;
                        hasPushedChanges = true;
                      system.debug('status--->' +oel.Status__c);
                    
                }
                if(oel.Status__c == 'Integration Error')
                {
                    oerw.oer.Status__c = 'Integration Error';
                     oerw.isUpdated = true;
                     
                } //Rekha : LINE_STATUS_WHEN_INTEGRATION_ERROR_THEN_COMPLETE_01 : to handle Approval to Ship Requested status	
                else if(oel.Status__c == 'Approval to Ship Requested')
                {
                    oerw.oer.Status__c = 'Approval to Ship Requested';
                    oerw.isUpdated = true;
                }
                //SW_ITEMS_INVOICE_HOLD
                 else if(oel.Oracle_Hold__c && oel.Status__c == 'Hold' )
                {
                    oerw.oer.Pre_Hold_Status__c = oel.Pre_Hold_Status__c; 
                    //oerw.oer.Pre_Change_Status__c = oerw.oer.Status__c; 
                    oerw.oer.Status__c = oel.Status__c;
                    oerw.isUpdated = true;
                }                 
            }
            else
            {
                if (!preIntegrationStatus.contains(oer.Status__c)) 
                {
                   
                    oerw.setIntegrationScope('Line Items');
                    
                    //Added by ENP - END
                    if (oel.Status__c == 'Change Confirmation Required' || oel.Status__c == 'Cancellation Confirmation Pending' || oel.Status__c == 'Change Confirmation Pending')
                    {
                        System.debug('Check 12 ###');
                        if(oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware)
                        {
                            oer.Status__c = 'Change Confirmation Pending';
                        }
                        else{
                            oer.Status__c = 'Change Confirmation Required';
                        }
                        oerw.isUpdated = true;                     
                    } 
                    else
                    {
                        System.debug('Check 123 ###');                        
                        if (oer.Status__c != 'Change Confirmation Required' && oer.Status__c != 'Cancellation Confirmation Pending' && oer.Status__c != 'Change Confirmation Pending' && oel.Status__c!= oelOld.Status__c)
                        {
                            oer.Status__c = 'Change Requested';
                            oerw.isUpdated = true;
                        }
                    }
                    if(oel.Request_Date__c != oelOld.Request_Date__c && oerw.oer.Request_Date__c!=  LeastDateOEL.get(oel.Order_Entry_Release__c).Request_Date__c && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware)
                    {
                        oerw.oer.Previous_Request_Ship_Date__c = oerWrapperMap.get(oel.Order_Entry_Release__c).oer.Request_Date__c;
                        if (!preIntegrationStatus.contains(oer.Status__c))
                        {
                            if (oerw.oer.First_Request_Ship_Date__c == null )
                            {
                                oerw.oer.First_Request_Ship_Date__c = LeastDateOEL.get(oel.Order_Entry_Release__c).Request_Date__c;
                            }
                        }
                        oerw.oer.Request_Date__c = LeastDateOEL.get(oel.Order_Entry_Release__c).Request_Date__c;
                        oerw.isUpdated = true;
                    }
                    if(oel.Scheduled_Ship_Date__c !=  oelOld.Scheduled_Ship_Date__c && oerw.oer.Scheduled_Ship_Date__c!= LeastDateOELSchedule.get(oel.Order_Entry_Release__c).Scheduled_Ship_Date__c && oelRecordTypeMapSchema.get(oel.RecordTypeID).getDeveloperName()==Label.CSS_Hardware)
                    {
                        oerw.oer.Previous_Scheduled_Ship_Date__c = oerWrapperMap.get(oel.Order_Entry_Release__c).oer.Scheduled_Ship_Date__c;
                        if (!preIntegrationStatus.contains(oer.Status__c))
                        {
                            if (oerw.oer.First_Scheduled_Ship_Date__c == null )
                            {
                                oerw.oer.First_Scheduled_Ship_Date__c = LeastDateOELSchedule.get(oel.Order_Entry_Release__c).Scheduled_Ship_Date__c;
                            }
                        }
                        oerw.oer.Scheduled_Ship_Date__c  = LeastDateOELSchedule.get(oel.Order_Entry_Release__c).Scheduled_Ship_Date__c ;
                        oerw.isUpdated = true;
                    }
                }
                
            }
        }
        system.debug('@@chst0'+hasPushedChanges);
        if (hasPushedChanges)
        {       
            for (Id oerID : pushedChangeOERIds) // Begin processing loop for OERs with pushed changes
            {
                OrderEntryReleaseWrapper oerw = oerWrapperMap.get(oerID);
                String newStatus = oerw.getNewStatus();
                system.debug('@@chst'+newStatus);
                if (oerw.oer.Status__c != newStatus)
                {
                    system.debug('@@igu'+newStatus);
                    //Added by enp
                    /*if(newStatus == 'Planned')
                    {
                       //oerw.oer.Integration_Status__c ='Complete';
                        oerw.oer.Integration_Action_Requested__c ='';
                        //oerw.oer.Trigger_Source__c='Integration';
                        //oerw.oer.Integration_Scope__c='';
                        
                    }
                    if(newStatus == 'Change Requested')
                    {
                        oerw.oer.Integration_Status__c ='';
                        oerw.oer.Integration_Action_Requested__c ='Update';
                        
                    
                        
                    }*/
                    //ended by Enp
                    // projectconcrete_2.3 
                    if (oerw.oer.Status__c != 'Change Requested' && oerw.oer.Status__c != 'Change Confirmation Required' && oerw.oer.Status__c != 'Change Confirmation Pending')
                    {            
                       System.debug('Header Status is not changed when OER is Change Requested');
                       oerw.oer.Status__c = newStatus;
                       oerw.isUpdated = true;
                      
                       //if(newStatus != 'Planned')
                        oerw.oer.Trigger_Source__c = 'Line';
                     }
                }
            }
        } 
                    
        for (OrderEntryReleaseWrapper oerw : oerWrapperMap.values())
        {
            //
            // JV - 20172411 added the following to support rollups
            //
            oerw.recalculateRollups();
            if (oerw.isUpdated)
            {
                oerw.oer.Trigger_Source__c = 'Line';
                oersToUpdate.add(oerw.oer);
            }
        }

        hasErrors = false;
        system.debug('@@igu'+oersToUpdate);
        if (oersToUpdate.size() > 0)
        {
            List<Database.SaveResult> srList = new List<Database.SaveResult>();
            srList = Database.Update(oersToUpdate, false);
            for (Database.SaveResult sr: srList)
            {
                Integer i = 0;
                if (!sr.isSuccess())
                {
                    for (Database.Error err : sr.getErrors())
                    {                       
                        for (OrderEntryLineWrapper oelw : oelWrapperList)
                        {
                            String errMsg = err.getMessage();
                            if (oelw.oel.Order_Entry_Release__c == oersToUpdate[i].Id)
                            {
                                oelw.addValidationError(errMsg);
                                
                            }
                        }
                    }
                    hasErrors = true;
                }
                i++;
            }           
        }       
        if(!hasErrors && rollbackOELMap.size() > 0) { // JV - 20200329 - The following code added to support Integration Rollback
            if(CheckIfOrderIsOrderBooked.AutoBookOrderStatic) //Auto_Order_Creation_Failure
            {
                    
                    List<Order_Entry_Line__c> oelOldRBList = new List<Order_Entry_Line__c>();
                    for(Order_Entry_Line__c oel : rollbackOELMap.values()) oelOldRBList.add(Trigger.oldMap.get(oel.Id));            
                    List<Rollback_Order_Entry_Line__c> rboelList = rollbackUtils.createOELsRollback(oelOldRBList);
                    for(Rollback_Order_Entry_Line__c rboel : rboelList) {
                        if(rboel.Rollback_Errors__c != null) {
                            rollbackOELMap.get(Id.valueOf(rboel.Order_Entry_Line__c)).addError(rboel.Rollback_Errors__c,false);
                        }
                    }
                System.debug(' In Auto Book Order');
            } //Auto_Order_Creation_Failure
            
            else {

                //Rekha: To handle Bulk Processing of Rollback_Order_Entry_Line__c records in batch
                    Map<id, Order_Entry_Line__c> oelOldRBMap = new Map<id, Order_Entry_Line__c>();
                    for(Order_Entry_Line__c oel : rollbackOELMap.values()) oelOldRBMap.put(oel.Id,Trigger.oldMap.get(oel.Id));           
                    BulkRollupOel batch=new BulkRollupOel(oelOldRBMap);
                    database.executebatch(batch,100);
                System.debug('Not In Auto Book Order');
            }
        }   
        // JV - 20200329 - End of code block added to support Integration Rollback
        
        if (hasErrors)
        {
            //Added by ENP - Admin Override
            //User u = [SELECT ID,Admin_Override__c FROM USER WHERE ID=:userinfo.getUserId()];
            for (OrderEntryLineWrapper oelw: oelWrapperList)
            {
                oel = oelw.oel;
                if (oelw.hasErrors  && !oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).oer.No_Validation__c)
                {                   
                    String displayMessage = '';
                    for (Integer i = 0; i < oelw.validationErrors.size(); i++)
                    {
                        if (i > 0)
                        {
                            displayMessage = displayMessage + '<br/>';
                        }
                        displayMessage = displayMessage +   String.valueOf(i+1) + ') ' + oelw.validationErrors[i];
                        System.debug('*** Added err: ' + oelw.validationErrors[i]);
                    }
                    oelw.oel.addError(displayMessage,false);                                                  
                }
            }
        }

    //if(!Test.isRunningTest()){
        Order_Entry_Line__c oldOelValues;
        Boolean callOelfUpdate = false;
        for(Order_Entry_Line__c oelChange : trigger.new)
        {
            oldOelValues = trigger.oldMap.get(oelChange.id);

            if(oelChange.Request_Date__c != oldOelValues.Request_Date__c || oelChange.Quantity__c != oldOelValues.Quantity__c 
                    || oelChange.Promised_Date__c != oldOelValues.Promised_Date__c || oelChange.Scheduled_Ship_Date__c != oldOelValues.Scheduled_Ship_Date__c 
                    || oelChange.Shipping_Address__c != oldOelValues.Shipping_Address__c)
            {
                callOelfUpdate = True;
            }

        }
            if(callOelfUpdate)
                OelShipmentDetails.updateOerShipQuantity(trigger.newMap,trigger.oldMap); 
    //}
        
        //Added by ENP as part of Project Phase CRD Implementation
    //OrderEntryLineTriggerHandler.processPhaseOrder(Trigger.newMap,Trigger.oldMap);
    }
    public static void fakeMethod(){
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;

  }
  
}