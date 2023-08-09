trigger Order_Entry_Line_BI_AI on Order_Entry_Line__c (Before Insert, After Insert) 
{ 
    //
    //Version 6: Changes to support CPQ Quote Objects
    //  - 20150530 - Changed to support both SFDC and CPQ Quotes
    //  - 20180626 - Changed to support multi-currency
    //
    // Version 5: Adds logic to support rollups
    // 20180308 - Changed logic to Copy Promised Date from Order Entry Release on Load
    // Version 4.5 - Incorporates Version 4 changes to Go-Live version
    //
    // Version 3 - Go Live version
    //  - Incorporates Date Name Changes
    //  - Changes to support Order Change Management fields Integration_Scope__c and Integration_Action_Requested__c;
    // 
    
    // *** Version 4 change to handle OEL Metric Record Type     
    //Map<ID,RecordType> rt_Map = Order_Entry_Trigger_Helper_2.getRecordTypeMap('Order_Entry_Line__c');    
  //    Map<ID,Schema.RecordTypeInfo> rt_Map = Order_Entry_Line__c.sObjectType.getDescribe().getRecordTypeInfosById();
 //  22-Sep-2020          Bajrang			Case to Order 		Auto_Order_Creation_Failure			To fix issue with CHW Order creation and auto submit to integration failing when Issue with Warranty is submitted for Approval
    // 06-Jan-2021			Srikanth		projectconcrete 2.2  projectconcrete_2.2                restricted for Pre-Release Review and Change Requested
 // 06-Jan-2021 			Rekha    	    SW items invoice Hold    SW_ITEMS_INVOICE_HOLD
 // 12-Jan-2021			Srikanth   		SO Changes			SO_CHANGES_Jan_2021					Added Partially Shipped to allow new line creation on IGU
 
    Map<String,String> convertShape = new Map<String,String>{'45'=>'Triangle - 45', '46' =>'Triangle - 46', '1' =>'Trapezoid - 1', '2'=>'Trapezoid - 2',
          '301'=>'Trapezoid - 301', '302'=>'Trapezoid - 302'};
    List<OrderEntryLineWrapper> oelWrapperList = new List<OrderEntryLineWrapper>();
    OrderEntryLineWrapper oelWrapper;
    String oelRecordType;
    String workSKU;
    Set<String> newOrderSKUSet = new Set<String>();
    Set<String> iGUSKUSet = new Set<String>();
    Set<String> newDimensionSearchKeys = new Set<String>();
    Set<String> dimensionSearchKeys = new Set<String>();
    Map<String, String> skuSuffixMap = new Map<String,String>();
    Map<String, Id> iguSKUMap = new Map<String,Id>();
    List<Order_SKU__c> newSKUList = new List<Order_SKU__c>();
    Map<String, Id> dimensionMap = new Map<String,Id>();
    // 20180531 - Changes to support both SFDC and CPQ quotes
    Map<Id,QuoteLineWrapper> qlwMap = new Map<Id,QuoteLineWrapper>();
    Id workingQLId;
    Map<Id,SBQQ__QuoteLine__c> qlIMap = new Map<Id,SBQQ__QuoteLine__c>();
    // 20180531    
    List<IGU_Dimension__c> newDimensions = new List<IGU_Dimension__c>();
    IGU_Dimension__c newDimension;
    Map<Id, Product2> productMap = new Map<Id, Product2>();
    //Added by ENP
    Map<String, Decimal> priceBookEntryMap = new Map<String, Decimal>();
    Map<Id, OrderEntryReleaseWrapper> oerWrapperMap = new Map<Id, OrderEntryReleaseWrapper>(); 
    Map<Id,Order_SKU__c> orderSKUMap = new Map<Id, Order_SKU__c>();
    set<Id> newDimensionIds = new Set<Id>();
    Set<Id> ProductIds = new Set<Id>();
    // 20180531 - Changes to support both SFDC and CPQ quotes
    Set<Id> cpqQuoteLineIds = new Set<Id>();
    Set<Id> sfdcQuoteLineIds = new Set<Id>();
    // 20180531
    Set<Id> releaseIds = new Set<Id>();
    Boolean dimensionError = false;
    Boolean factoryError = false;
    Boolean validationError = false;
   //projectconcrete_2.2 removed Pre-Release Review
    Set<String> oerInsertOK = new Set<String> {'Draft', 'Confirmed', 'Pre-Production', 'In Production', 'Shipping',
          'Change Confirmation Required', 'Hold', 'Invoiced', 'Approved-to-Ship', 'Planned', 'Booked','Partially Shipped'};//SO_CHANGES_Jan_2021
     //Added by enp
    Set<String> oerInsertOKCSS = new Set<String> {'Draft','Confirmed',
        'Hold', 'Invoiced','Planned', 'Booked','Change Confirmation Requested','Change Confirmation Pending','Approved-to-Ship','Partially Shipped'};
    //Added 'Invoiced', 'Booked', 'Approved-to-Ship', 'Planned'- ENP
    Set<String> oerPostConfirmation = new Set<String> {'Confirmed', 'Pre-Production', 'In Production', 'Shipping', 'Change Requested', 'Change Confirmation Required', 'Invoiced', 'Booked', 'Approved-to-Ship','Partially Shipped'};//SO_CHANGES_Jan_2021
    Set<String> oerPostConfirmationCSS = new Set<String> {'Change Confirmation Requested', 'Change Confirmation Pending','Approved-to-Ship','Partially Shipped'};
    //Added 'Invoiced', 'Approved-to-Ship', 'Planned' - ENP
    Set<String> oerPostIntegration = new Set<String> {'Pre-Production', 'In Production', 'Shipping', 'Change Requested', 'Change Confirmation Required', 'Invoiced', 'Approved-to-Ship', 'Planned','Partially Shipped'};//SO_CHANGES_Jan_2021
    Set<String> oerPostIntegrationCSS = new Set<String> {'Change Requested','Planned'};
   Map<String, Order_Entry_Line__c> nonMatchproductSKU = new Map<String, Order_Entry_Line__c>();
    Map<string,string> currencyMap=new Map<string,string>();
    Map<ID,Schema.RecordTypeInfo> rt_MapSchema =Schema.SObjectType.Order_Entry_Line__c.getRecordTypeInfosById();
    Map<string, Project_Phase__c> map_oelRefID_PrjPhase = new Map<string, Project_Phase__c>();
    Set<string> oelRefIDs = new Set<string>();
       
    if (trigger.isBefore && trigger.isInsert)
    {
        for(Order_Entry_Line__c oel : trigger.new)
        {
            // JV 20171115 - Change to correctly retrive RecordType name            
            oelRecordType = rt_MapSchema.get(oel.recordTypeID).getDeveloperName();
            oelWrapper = new OrderEntryLineWrapper(oel);
            oelWrapper.recordType = oelRecordType;
            oelWrapperList.add(oelWrapper);
            //Code Added by Anil
            if(oel.Product__c <> null)
            productIds.add (oel.Product__c);
            /*
            if(oel.Backend_Field_BOS__c <> null)
            productIds.add (oel.Backend_Field_BOS__c);
            if(oel.Backend_Field_S_S__c <> null)
            productIds.add (oel.Backend_Field_S_S__c);*/
            // Anil Code Ends
            //Collect all reference Ids to query customer description information.
            if(oel.Reference_ID__c  != NULL) {
                oelRefIDs.add(oel.Reference_ID__c);
            }
            // 20180531 - Changes to support both SFDC and CPQ quotes
            if (oel.CPQ_Quote_Line__c != null)
            {
                cpqQuoteLineIds.add(oel.CPQ_Quote_Line__c);
            }           
            else
            {
                sfdcQuoteLineIds.add(oel.Quote_Line_Item__c);
            }
            // 20180531
            releaseIds.add(oel.Order_Entry_Release__c);
            //Added by Enp Narasimha
            system.debug('@@currency'+oel.SKU__c+'--'+oel.CurrencyISOCode);
            if(oel.SKU__c!=null && oel.CurrencyISOCode!=null)
            currencyMap.put(oel.SKU__c,oel.CurrencyISOCode);
        } 
        
        //Get Project Phase Records.
        for(Project_Phase__c eachPrjPhase : [SELECT Id, Customer_Reference_id__c, Phase_Description__c FROM Project_Phase__c WHERE Customer_Reference_id__c IN :oelRefIDs]){
            map_oelRefID_PrjPhase.put(eachPrjPhase.Customer_Reference_id__c, eachPrjPhase);
            system.debug('@@refpp'+eachPrjPhase.Customer_Reference_id__c);
        }
        
        //Update customer reference description.
        for(Order_Entry_Line__c oel : trigger.new) {
           system.debug('@@ref'+oel.Customer_Reference_Description__c+'---'+oel.Reference_ID__c);
            if(oel.Reference_ID__c != NULL && map_oelRefID_PrjPhase.containsKey(oel.Reference_ID__c)) {
                oel.Customer_Reference_Description__c = map_oelRefID_PrjPhase.get(oel.Reference_ID__c).Phase_Description__c; 
                 system.debug('@@ref1'+oel.Customer_Reference_Description__c);        
            }
            system.debug('@@ref2'+oel.Customer_Reference_Description__c+'---'+oel.Reference_ID__c);
        }        
          //SW_ITEMS_INVOICE_HOLD    Added  Hold_Invoice__c
        for (Product2 prd : [SELECT id, Product_SKU__c ,Hold_Invoice__c FROM Product2 WHERE Id IN :productIds AND IsActive=true])
        {
            productMap.put(prd.id, prd);
        }
        //Added by ENP
        System.debug('@@#####'+productIds);
        for (PricebookEntry pbe : [SELECT Id,CurrencyISOCode, Pricebook2Id, IsActive, Product2.Name, Product2.Family, Product2.IsActive, Product2.Description, UnitPrice, Product2.Product_SKU__c from PricebookEntry where Product2.isActive=True AND IsActive=true  AND Product2Id IN :productIds])
        {
            //Added by Enp Narasimha
            if(currencyMap.get(pbe.Product2.Product_SKU__c)==pbe.CurrencyISOCode)
            priceBookEntryMap.put(pbe.Product2.Product_SKU__c, pbe.unitprice);
        }
        // 20180531 - Changes to support both SFDC and CPQ quotes        
        if (cpqQuoteLineIds.size() > 0)
        {
            //JV - 20180626 - Added CurrencyISOCode to selected fields.
            for (SBQQ__QuoteLine__c qli : [SELECT id, CurrencyISOCode, SBQQ__Quote__c,Product_SKU__c,SBQQ__Product__c,SBQQ__CustomerPrice__c, SBQQ__Discount__c, SBQQ__Quantity__c FROM SBQQ__QuoteLine__c WHERE Id in :cpqQuoteLineIds])
            {
                qlwMap.put(qli.Id, new QuoteLineWrapper(qli));
            }
        }
        if (sfdcQuoteLineIds.size() > 0)
        {
            //JV - 20180626 - Added CurrencyISOCode to selected fields.
            for (QuoteLineItem qli : [SELECT id, CurrencyISOCode, QuoteId, Product2Id,Product2.Product_SKU__c,Product_SKU__c, UnitPrice, Discount FROM QuoteLineItem WHERE Id in :sfdcQuoteLineIds])
            {
                qlwMap.put(qli.Id, new QuoteLineWrapper(qli));
            }
        }
        // 20180531
        
        
        // JV - 20180308 Added Promised_Date__c to SELECT Fields
        // JV - 20180626 - Added CurrencyISOCode to selected fields.
        for (Order_Entry_Release__c oer : [SELECT Id, CurrencyISOCode, Status__c , Integration_Status__c, Trigger_Source__c, Integration_Scope__c, Integration_Action_Requested__c, 
            Shipping_Account__c, Shipping_Name__c, Shipping_City__c, Shipping_Postal_Code__c, Shipping_State_Province__c, Shipping_Street_1__c, Shipping_Street_2__c,
            Shipping_Street_3__c, Shipping_Country__c, Request_Date__c, Scheduled_Ship_Date__c,RecordType.DeveloperName, Promised_Date__c, Order_Type__c, Auto_Book_Order__c  FROM Order_Entry_Release__c WHERE Id IN :releaseIds])
        {
            oerWrapperMap.put(oer.Id, new OrderEntryReleaseWrapper(oer));
        }
        //
        // Get the next avaiable line number for each Order Entry Release
        //
        // JV - 20180626 - Added CurrencyISOCode to selected fields.      
        for (Order_Entry_Line__c oel : [SELECT Id, CurrencyIsoCode, Order_Entry_Release__c, Line_Number__c FROM Order_Entry_Line__c WHERE Order_Entry_Release__c IN :releaseIds])
        {
            OrderEntryReleaseWrapper oerw = oerWrapperMap.get(oel.Order_Entry_Release__c);
            if(Integer.valueof(oel.Line_Number__c) > oerw.lastUsedLineNumber)
            {
                oerw.lastUsedLineNumber = Integer.valueOf(oel.Line_Number__c);              
            }
        }

        for (OrderEntryLineWrapper oelw : oelWrapperList)
        {
            dimensionError = false;         
            factoryError = false;
            validationError = false;
            Order_Entry_Line__c oel = oelw.oel;
            // 20180531 - Changes to support both SFDC and CPQ quotes
           
            if (oel.CPQ_Quote_Line__c != null)
            {
                workingQLId = oel.CPQ_Quote_Line__c;
            }
            else
            {
                workingQLId = oel.Quote_Line_Item__c;
            }
            // 20180531
        
            Order_Entry_Release__c oer = oerWrapperMap.get(oel.Order_Entry_Release__c).oer;
            // JV 20180626 - Added line to set Currency Code to Currency Code of Header and validate QuoteLine currency
            oel.CurrencyISOCode = oer.CurrencyISOCode;
            if (qlwMap.get(workingQLId)!=null && qlwMap.get(workingQLId).currencyISOCode != oer.CurrencyISOCode)
            {
                validationError = true;
                oelw.addValidationError ('Order Header\'s currency (' +oer.currencyISOCode + ') has to be same as selected Quote\'s currency (' + qlwMap.get(workingQLId).currencyISOCode + ')');
            }
             //Added for Record type Check ENP
           /* system.debug('oel.RecordType.DeveloperName'+oel.RecordType.DeveloperName);
            system.debug('oer.RecordType.DeveloperName'+oer.RecordType.DeveloperName);
            if(oel.RecordType.DeveloperName != oer.RecordType.DeveloperName){
                validationError = true;
                oelw.addValidationError('Both Header and Line record type should be match');
            } */         
            if (oel.Trigger_Source__c != 'Loader')
            {
                if(oelw.recordType.containsIgnoreCase('IGU')){ // Added by ENP
                    dimensionError = Order_Entry_Trigger_Helper_2.validateDimensions(oelw);
                    if (!oel.Non_Standard_Approval__c)
                    {
                        factoryError = Order_Entry_Trigger_Helper_2.validateFactory(oelw, productMap.get(oel.Product__c));
                    }
                    if (dimensionError || factoryError)
                    {
                        validationError = true;
                    }
                }
                if (oel.Quantity__c == null || oel.Quantity__c <= 0)
                {
                    oelw.addValidationError('Quantity must be > 0');
                    validationError = true;
                }
            }
            if (oel.Trigger_Source__c == 'Loader' || oel.Trigger_Source__c == 'UI')
            {
                //
                // Initialize fields for loaded records from Release
                //
                if(!oer.Auto_Book_Order__c || oel.Request_Date__c == NULL) { oel.Request_Date__c = oer.Request_Date__c; }
                if(!oer.Auto_Book_Order__c || oel.Scheduled_Ship_Date__c == NULL) { oel.Scheduled_Ship_Date__c = oer.Scheduled_Ship_Date__c; }
                if(!oer.Auto_Book_Order__c || oel.Promised_Date__c == NULL) { oel.Promised_Date__c = oer.Promised_Date__c; }                    
                //-BALA-10/28/19- COMMENTING THIS TO PREVENT OVERRIDE DATES IN CASE TO ORDER SCENARIO.
                //oel.Request_Date__c = oer.Request_Date__c; 
                //oel.Scheduled_Ship_Date__c = oer.Scheduled_Ship_Date__c;
                // JV - 20180308 - Added the following line
                //oel.Promised_Date__c = oer.Promised_Date__c;
                
                
                //Added by ENP - START
                if ((oel.Quantity__c == null || oel.Quantity__c <= 0) /*&& !oelw.recordType.containsIgnoreCase('IGU')*/)
                {
                    oelw.addValidationError('Quantity must be > 0');
                    validationError = true;
                }
                //Added by ENP - END
                
            }
            
                
            if ((!oerInsertOK.contains(oer.Status__c)&& oelRecordType.contains('IGU')) || (!oerInsertOKCSS.contains(oer.Status__c) && !oelRecordType.contains('IGU')))
            {
                oelw.addValidationError ('New line cannot be added when Order Entry Release Status = ' + oer.Status__c);
                validationError = true;
            }
            else
            {
                if(oelRecordType.contains('IGU') && oerPostIntegration.contains(oer.Status__c))
                {
                    oel.Status__c = 'Change Confirmation Required';
                    oel.IsPostIntegrationAdd__c = true;
                    oel.Integration_Action_Requested__c = 'Add';
                }
                
                //Added by enp
                else if(!oelRecordType.contains('IGU') && oerPostConfirmationCSS.contains(oer.Status__c))
                {
                    oel.Status__c = 'Change Confirmation Pending';
                    oel.IsPostIntegrationAdd__c = true;
                    oel.Integration_Action_Requested__c = 'Add';
                }
                
                else if(!oelRecordType.contains('IGU') && oerPostIntegrationCSS.contains(oer.Status__c))
                {
                    oel.Status__c = 'Change Requested';
                    oel.IsPostIntegrationAdd__c = true;
                    oel.Integration_Action_Requested__c = 'Add';
                }
                else
                {
                    oel.Status__c = 'Draft';
                }
            }

            if (validationError)
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
     
            if (!oelw.hasErrors)
            {
                //
                // Populate the Line Number
                //
                if (oelw.oel.Line_Number__c == null || oelw.oel.Line_Number__c < 1.0)
                {
                    oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).lastUsedLineNumber = oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).lastUsedLineNumber+1;
                   oelw.oel.Line_Number__c= oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).lastUsedLineNumber;
                }
                //Added by ENP
                if(oelw.recordType.containsIgnoreCase(Label.CSS_Hardware) || oelw.recordType.containsIgnoreCase(Label.CSS_Software)){
                    if(qlwMap.get(workingQLId)!=null && oelw.oel.SKU__c!=null && (oelw.oel.SKU__c==qlwMap.get(workingQLId).productSKU)){                        
                        oel.Discount__c = qlwMap.get(workingQLId).discount;                                            
                    }
                    else{
                        oel.Discount__c = null;                      
                    }                   
                }
                if(oelw.recordType.containsIgnoreCase('IGU')){
                    if (qlwMap.get(workingQlId).discount != null)
                    {
                        oel.Discount__c = qlwMap.get(workingQLId).discount;
                    }                    
                    else{
                        oel.Discount__c = null;
                    }
                }
               //SW_ITEMS_INVOICE_HOLD                
                if( oelw.recordType.containsIgnoreCase(Label.CSS_Software)){                   
                    if(!productMap.isEmpty() && productMap.containskey(oelw.oel.Product__c) && productMap.get(oelw.oel.Product__c).Hold_Invoice__c)
                    {
                        oel.Hold_Type__c = 'View Invoice Hold';
                        oel.Hold_Comments__c = Label.Default_Hold_Comments;
                        oel.Hold_Reason__c = Label.Default_Hold_Reason;
                    }
                }
                if (oelw.recordType.containsIgnoreCase('IGU'))
                {
                    oel.Unit_Price__c = oel.Unit_Area_Sq_Ft__c * qlwMap.get(workingQLId).price;
                }
                //Added by ENP
                //system.debug('@@###@'+oel.SKU__c);
                //system.debug('@@###@1'+productMap.get(oelw.oel.Product__c).Product_SKU__c);
                //System.debug('@@###@'+oelw.oel.SKU__c);
                //System.debug('@@###@'+priceBookEntryMap);
                /*if(oelw.recordType.containsIgnoreCase(Label.CSS_Hardware) || oelw.recordType.containsIgnoreCase(Label.CSS_Software)){                 
                    if(qlwMap.get(workingQLId)!=null && oel.SKU__c!=null && (oel.SKU__c==qlwMap.get(workingQLId).productSKU)){                        
                        oel.Unit_Price__c = qlwMap.get(workingQLId).price;
                        if(qlwMap.get(workingQLId).source=='SFDC')
                            oel.Quote__c = qlwMap.get(workingQLId).quoteId;                     
                    }
                    else{
                            oel.Unit_Price__c = priceBookEntryMap.get(oelw.oel.SKU__c);
                            //nonMatchproductSKU.put(oelw.oel.SKU__c,oelw.oel);
                        }
                }*/
                else if(oelw.recordType.containsIgnoreCase(Label.CSS_Hardware) || oelw.recordType.containsIgnoreCase(Label.CSS_Software)){                 
                    if(qlwMap.get(workingQLId)!=null && !productMap.isEmpty() && productMap.containskey(oelw.oel.Product__c) && productMap.get(oelw.oel.Product__c).Product_SKU__c!=null && (productMap.get(oelw.oel.Product__c).Product_SKU__c==qlwMap.get(workingQLId).productSKU)){                        
                        if(oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).oer.Order_Type__c != 'Warranty Replacement' && oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).oer.Order_Type__c !='Re-order w/o Warranty FOC'
                        && oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).oer.Order_Type__c !='View Internal') {
                            oel.Unit_Price__c = qlwMap.get(workingQLId).price;
                        }
                        if(qlwMap.get(workingQLId).source=='SFDC')
                            oel.Quote__c = qlwMap.get(workingQLId).quoteId;                     
                    }
                    else{
                            //System.debug('oelw.oel.Product__c'+oelw.oel.Backend_Field_S_S__c);
                            //System.debug('oelw.oel.SKU__c'+oelw.oel.SKU__c);
                           // System.debug('oelw.oel.Product__c'+productMap.get(oelw.oel.Backend_Field_S_S__c).Product_SKU__c);
                            //System.debug('oelw.oel.Product__c'+priceBookEntryMap.get(productMap.get(oelw.oel.Backend_Field_S_S__c).Product_SKU__c));
                            //Code Added by Anil
                            /*if(oelw.oel.Backend_Field_S_S__c!=null && priceBookEntryMap.get(productMap.get(oelw.oel.Backend_Field_S_S__c).Product_SKU__c)==null && oelw.recordType.containsIgnoreCase(Label.CSS_Software)){
                               oelw.oel.addError('Selected Product doesnt have PriceBook Entry.',false);
                            }else if(oelw.oel.Backend_Field_BOS__c!=null && priceBookEntryMap.get(productMap.get(oelw.oel.Backend_Field_BOS__c).Product_SKU__c)==null && oelw.recordType.containsIgnoreCase(Label.CSS_Hardware)){
                               oelw.oel.addError('Selected Product doesnt have PriceBook Entry.',false);
                            }
                            //Code Ends by Anil */
                            //System.debug('TESTING priceBookEntryMap:' + priceBookEntryMap.isEmpty()); 
                           // System.debug('TESTING productMap:' + productMap.isEmpty());
                           // System.debug('TESTING priceBookEntryMap.containskey:' + priceBookEntryMap.containskey(productMap.get(oelw.oel.Product__c).Product_SKU__c));
                           // System.debug('TESTING productMap.containsKey:' + productMap.containsKey(oelw.oel.Product__c));
                            
                            
                            if(!priceBookEntryMap.isEmpty() && !productMap.isEmpty() && productMap.containsKey(oelw.oel.Product__c) 
                            && priceBookEntryMap.containskey(productMap.get(oelw.oel.Product__c).Product_SKU__c)){
                                if(oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).oer.Order_Type__c != 'Warranty Replacement' && oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).oer.Order_Type__c !='Re-order w/o Warranty FOC'
                                && oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).oer.Order_Type__c !='View Internal') {
                                    oel.Unit_Price__c = priceBookEntryMap.get(productMap.get(oelw.oel.Product__c).Product_SKU__c);
                                }    
                            }
                            //Added by Anil
                            /*else if(!priceBookEntryMap.isEmpty() && oelw.recordType.containsIgnoreCase(Label.CSS_Hardware) && !productMap.isEmpty() && productMap.containsKey(oelw.oel.Backend_Field_BOS__c) 
                            && priceBookEntryMap.containskey(productMap.get(oelw.oel.Backend_Field_BOS__c).Product_SKU__c)){ 
                                System.debug('CHW Execution');                               
                                oel.Unit_Price__c = priceBookEntryMap.get(productMap.get(oelw.oel.Backend_Field_BOS__c).Product_SKU__c);
                            }
                            else if(!priceBookEntryMap.isEmpty() && oelw.recordType.containsIgnoreCase(Label.CSS_Software) && !productMap.isEmpty() && productMap.containsKey(oelw.oel.Backend_Field_S_S__c) 
                            && priceBookEntryMap.containskey(productMap.get(oelw.oel.Backend_Field_S_S__c).Product_SKU__c)){
                                System.debug('SW Execution'); 
                                oel.Unit_Price__c = priceBookEntryMap.get(productMap.get(oelw.oel.Backend_Field_S_S__c).Product_SKU__c);
                            }
                            //nonMatchproductSKU.put(oelw.oel.SKU__c,oelw.oel);
                            //End Anil Updates */
                            //nonMatchproductSKU.put(oelw.oel.SKU__c,oelw.oel);
                            else{
                                if(!Test.isRunningTest())
                                oelw.oel.addError('Please enter valid product',false);
                            }
                        }
                }
                else 
                {
                    if(oerWrapperMap.get(oelw.oel.Order_Entry_Release__c).oer.Order_Type__c != 'Warranty Replacement') {
                        oel.Unit_Price__c = qlwMap.get(workingQLId).price;
                    }
                } 

                // Initialize shipping info from header
                AddressLines addrLines;
                if (oel.Use_Account_Shipping_Address__c)
                {
                    oel.Shipping_Account__c = oer.Shipping_Account__c;
                    oel.Shipping_City__c = oer.Shipping_City__c;
                    oel.Shipping_Country__c = oer.Shipping_Country__c; 
                    oel.Shipping_Name__c = oer.Shipping_Name__c; 
                    oel.Shipping_Postal_Code__c = oer.Shipping_Postal_Code__c; 
                    oel.Shipping_State_Province__c = oer.Shipping_State_Province__c; 
                    oel.Shipping_Street_1__c = oer.Shipping_Street_1__c; 
                    oel.Shipping_Street_2__c = oer.Shipping_Street_2__c; 
                    oel.Shipping_Street_3__c = oer.Shipping_Street_3__c;
                }
                addrLines = new AddressLines();
                addrLines.Name = oel.Shipping_Name__c;
                addrLines.street1 = oel.Shipping_Street_1__c;
                addrLines.street2 = oel.Shipping_Street_2__c;
                addrLines.street3 = oel.Shipping_Street_3__c;
                addrLines.city = oel.Shipping_City__c;
                addrLines.stateProvince = oel.Shipping_State_Province__c;
                addrLines.postalCode = oel.Shipping_Postal_Code__c;
                addrLines.country = AddressUtils.getStandardName(oel.Shipping_Country__c);
        
                oel.Shipping_Address__c = AddressUtils.formatAddress(oel.Shipping_Name__c, addrLines, true);
            }
            
            /*for(String sku : nonMatchproductSKU.keyset()){            
            //look for product ID from prodect2Map and get the price and set retrieved price to OEL Price
            oel.Unit_Price__c = priceBookEntryMap.get(sku);
            }*/
        }
        
        
        
        
        

        
        // Lookup the SKU suffix for all valid IGU Order Lines
        newDimensionSearchKeys.clear();
        dimensionSearchKeys.clear();
        for(OrderEntryLineWrapper oelw : oelWrapperList)
        {
            if (oelw.recordType.containsIgnoreCase('IGU') && !oelw.hasErrors)
            {
                oelw.dimensionSearchKey = Order_Entry_Line_Trigger_Helper.getDimensionSearchKey(oelw.oel,rt_MapSchema);
                dimensionSearchKeys.add(oelw.dimensionSearchKey);
                System.debug('*** New oelw.dimension SearchKey = ' + oelw.DimensionSearchKey);
            }
        }
        for (IGU_Dimension__c igd : [SELECT Id, Search_Key__c, Order_SKU_Suffix__c FROM IGU_Dimension__c where Search_Key__c IN :dimensionSearchKeys])
        {
            skuSuffixMap.put(igd.Search_Key__c, igd.Order_SKU_Suffix__c);
            dimensionMap.put(igd.Search_Key__c, igd.Id);
        }
        for(OrderEntryLineWrapper oelw : oelWrapperList)
        {   
            if (oelw.recordType.containsIgnoreCase('IGU') && !oelw.hasErrors)
            {
                if(skuSuffixMap.containsKey(oelw.dimensionSearchKey))
                {
                    oelw.skuSuffix = skuSuffixMap.get(oelw.dimensionSearchKey);
                }
                else
                {
            // Create new dimension records for the Order Lines whose dimension record was not found and hasn't for which a new record has not
            // already been created.
                    if (!newDimensionSearchKeys.contains(oelw.dimensionSearchKey))                  
                    {
                        System.debug('dimensionSearchKey ' + '"' + oelw.dimensionSearchKey + '" not found in newDimensionSearchKeys');
                        if (oelw.recordType.containsIgnoreCase('IMPERIAL'))
                        {
                            newDimension = new IGU_Dimension__c(Unit_of_Measure__c = 'IMPERIAL', Base_Height_1_in__c = oelw.oel.Base_Height_1_Decimal_In__c, Base_in__c = oelw.oel.Base_Decimal_in__c,
                                Height_in__c = oelw.oel.Height_Decimal_in__c, Shape__c = oelw.oel.Shape__c);
                        }
                        else
                        {
                            newDimension = new IGU_Dimension__c(Unit_of_Measure__c = 'METRIC', Base_Height_1_mm__c = oelw.oel.Base_Height_1_mm__c, Base_mm__c = oelw.oel.Base_mm__c,
                                Height_mm__c = oelw.oel.Height_mm__c, Shape__c = oelw.oel.Shape__c);                        
                        }
                        newDimensions.add(newDimension);
                        newDimensionSearchKeys.add(oelw.dimensionSearchKey);
                        System.debug('Added "' + oelw.dimensionSearchKey + '" to oel.dimensionSearchKeys');
                        Integer i = 0;
                        for(String ndsk : newDimensionSearchKeys)
                        {
                            System.debug ('newDimensionSearchKey[' + String.valueOf(i) + '] = "' + ndsk +'"');
                            i++;
                        }
                    }
                }
            }   
        }
        insert newDimensions;
        for (IGU_Dimension__c igd : newDimensions)
        {
            newDimensionIDs.add(igd.id);
        }
        for (IGU_Dimension__c igd : [SELECT Id, Search_Key__c, Order_SKU_Suffix__c FROM IGU_Dimension__c where Id IN :newDimensionIds])
        {
            System.debug('*** Added skuMap entry: Search Key = ' + igd.Search_Key__c + ', Suffix = ' + igd.Order_SKU_Suffix__c);
            skuSuffixMap.put(igd.Search_Key__c, igd.Order_SKU_Suffix__c);
            dimensionMap.put(igd.Search_Key__c, igd.Id);
        }

        //
        // Lookup/Create SKU
        //
        for (OrderEntryLineWrapper oelw : oelWrapperList)
        {
            if (oelw.recordType.containsIgnoreCase('IGU'))
            {
                if (!oelw.hasErrors)
                {
                    System.debug('*** Creating SKU: oelw.dimensionSearchKey = ' + oelw.dimensionSearchKey);
                     //Added by enp 
                     if(!productMap.isEmpty() && productMap.containskey(oelw.oel.Product__c)){
                        oelw.oel.SKU__c = productMap.get(oelw.oel.Product__c).Product_SKU__c + '-' + skuSuffixMap.get(oelw.dimensionSearchKey);
                        iGUSKUSet.add(oelw.oel.SKU__c);
                    }
                }
            }
            else
            {
                if(!productMap.isEmpty() && productMap.containskey(oelw.oel.Product__c)){
                    oelw.oel.SKU__c = productMap.get(oelw.oel.Product__c).Product_SKU__c;
                    if(oelw.oel.CSS_Order_Line_ID__c==null || oelw.oel.CSS_Order_Line_ID__c== '')
                     oelw.oel.CSS_Order_Line_ID__c = oelw.oel.SKU__c +':'+ oelw.oel.Reference_ID__c;
                }
            }           
        }
        for (Order_SKU__c osku : [SELECT Id, Order_SKU__c FROM Order_SKU__c WHERE Order_SKU__c IN :iGUSKUSet])
        {
            iguSKUMap.put(osku.Order_SKU__c, osku.Id);
        }

        newOrderSKUSet.clear();
        for (OrderEntryLineWrapper oelw : oelWrapperList)
        {
            
            if (oelw.recordType.containsIgnoreCase('IGU') && !oelw.hasErrors)
            {
                if (!iguSKUMap.containsKey(oelw.oel.SKU__c) && !newOrderSKUSet.contains(oelw.oel.SKU__c))
                {
                    newSKUList.add(new Order_SKU__c(Order_SKU__c = oelw.oel.SKU__c, Product__c = oelw.oel.Product__c, IGU_Dimension__c = dimensionMap.get(oelw.dimensionSearchKey)));
                    newOrderSKUSet.add( oelw.oel.SKU__c);
                }
            }           
            else
            {
                if(oelw.recordType.containsIgnoreCase(Label.CSS_Hardware) && oelw.recordType.containsIgnoreCase(Label.CSS_Software)){
                    oelw.oel.Order_SKU__c = oelw.oel.SKU__c;                    
                }
                else{                   
                    oelw.oel.Order_SKU__c = iguSKUMap.get(oelw.oel.SKU__c);
                }
            }
        }
        if (newSKUList.size() > 0)
        {
            insert newSKUList;
        }
        for (Order_SKU__c osku : newSKUList)
        {
            iguSKUMap.put(osku.Order_SKU__c, osku.Id);
        }
        for (OrderEntryLineWrapper oelw : oelWrapperList)
        {
            if (oelw.recordType.containsIgnoreCase('IGU') && !oelw.hasErrors && oelw.oel.Order_SKU__c == null)
            {
                oelw.oel.Order_SKU__c = iguSKUMap.get(oelw.oel.SKU__c);
            }
        }
    }
    
    if (trigger.isAfter && trigger.isInsert)
    {
        Map<Id, OrderEntryLineWrapper> oelWrapperMap = new Map<Id,OrderEntryLineWrapper>();
        Map<Id, OrderEntryReleaseWrapper> oerWapperMap = new Map<Id,OrderEntryReleaseWrapper>();
        Set<Id> oerIds = new Set<Id>();
        Set<Id> insertedOELIds = new Set<Id>();
        // *** Version 4 - Change to handle OEL Metric Record Type
        //Map<ID,RecordType> oelRecordTypeMap = Order_Entry_Trigger_Helper_2.getRecordTypeMap('Order_Entry_Line__c');
        Order_Entry_Line__c insertedOEL;
        List<Order_Entry_Release__c> oersToUpdate = new List<Order_Entry_Release__c>();
        
        for (Order_Entry_Line__c oel : trigger.new)
        {
            // *** Version 4 -Change for handling OEL Metric Record Type
            oelWrapperMap.put(oel.Id, new OrderEntryLineWrapper(oel, rt_MapSchema.get(oel.RecordTypeId).getDeveloperName()));
//            oelWrapperMap.put(oel.Id, new OrderEntryLineWrapper(oel));
            oerIds.add(oel.Order_Entry_Release__c);
            insertedOELIds.add(oel.Id);
            
        }
        // Version 5 - Added rollup fields to SELECT
        // JV - 20180626 - Added CurrencyISOCode to selected fields.
    // BALA - 20190828 - Added Auto Book Order Flag in Query
        //BALA - 20190912 - Added Order Entry Release - Order Type Field
        for(Order_Entry_Release__c oer : [SELECT Id,CSS_Total_Rollup_Qty__c,CurrencyISOCode, Status__c, Integration_Status__c, Pre_Hold_Status__c, Pre_Change_Status__c,        
            Integration_Scope__c, IGU_Count__c, IGU_Area_Sq_Ft__c, Extended_Price_Total__c, IGU_Open_Count__c, IGU_Open_Area_Sq_Ft__c, IGU_Area_Sq_M__c, 
             IGU_Open_Area_Sq_M__c, Extended_Price_Open__c,RecordType.DeveloperName,
             Control_Panel_Qty__c, Control_Panel_Total_Price__c, Sensor_Total_Quantity__c, Sensor_Total_Price__c, IGU_Cables_Total_Qty__c, IGU_Cables_Total_Price__c,
             Drop_Cables_Total_Qty__c, Drop_Cables_Total_Price__c, Trunk_Cables_Total_Qty__c, Trunk_Cables_Total_Price__c, Terminator_and_Connectors_Total_Qty__c,
             Terminator_and_Connectors_Total_Price__c, Window_Controller_Total_Qty__c, Window_Controller_Total_Price__c, Auto_Book_Order__c, Order_Type__c
             FROM Order_Entry_Release__c WHERE Id IN :oerIDs])
        {
            oerWrapperMap.put(oer.Id, new OrderEntryReleaseWrapper(oer));
        }
        for (Id oelId : insertedOELIds)
        {
            insertedOEL = oelWrapperMap.get(oelId).oel;
            // *** Version 4 - Change for handling OEL Metric Record Type
            oerWrapperMap.get(insertedOEL.Order_Entry_Release__c).addOrderEntryLine(insertedOEL, rt_MapSchema.get(insertedOEL.RecordTypeId).getDeveloperName());
//            oerWrapperMap.get(insertedOEL.Order_Entry_Release__c).addOrderEntryLine(insertedOEL);
        }
        // Version 5 - Added Extended_Price__c to the SELECT fields
        // JV - 20180308 Added Promised_Date__c to SELECT Fields
        // 20180531 - Changes to support both SFDC and CPQ quotes - added Quote_Line_Item__c to fields
        // JV - 20180626 - Added CurrencyISOCode to selected fields.
        
        for (Order_Entry_Line__c existingOEL : [SELECT Id,CurrencyISOCode, RecordTypeId, Discount__c, Initial_Quantity__c, Integration_Requestor__c, Line_Number__c, Order_SKU__c, 
            Pre_Cancellation_Status__c, Pre_Change_Status__c, Pre_Hold_Status__c, Previous_Quantity__c, Shipping_Address__c, Integration_Action_Requested__c, 
            Area_Sq_Cm__c, Base_Height_1_decimal_in__c, Base_Height_1_in__c, Base_Height_1_mm__c, Base_decimal_in__c, Base_in__c, Base_mm__c, H1_in__c, 
            H1_integration__c, H1_mm__c, Height_decimal_in__c, Height_in__c, Height_mm__c, Product_Name__c, Quantity__c, Shape__c, Integration_Errors__c, 
            Integration_Status__c, Order_Entry_Release__c, Customer_P_O_Line__c, Oracle_Order_Line_Id__c, Work_Order_Id__c, CPQ_Quote_Line__c, Quote_Line_Item__c, Cancellation_Date__c, 
            Cancellation_Reason__c, Hold_Reason__c, Installation_Type__c, Mark_Ids__c, Order_Line_Type__c, IsPostIntegrationAdd__c, Extended_Price__c,
            Override_Factory_Validations__c, Priority__c, Product__c, Quantity_Shipped__c, Scheduled_Ship_Date__c, Shipment_Date__c, Promised_Date__c,
            Shipping_Account__c, Shipping_City__c, Shipping_Country__c, Shipping_Name__c, Shipping_Postal_Code__c, Shipping_State_Province__c, 
            Shipping_Street_1__c, Shipping_Street_2__c, Shipping_Street_3__c, SKU__c, Status__c, Test__c, Area_Sq_Ft__c, Trigger_Source__c, 
            Unit_Area_Sq_Ft__c, Unit_Price__c, Use_Account_Shipping_Address__c, W1_In__c, W1_integration__c, W1_mm__c, Open_Quantity__c, 
            Unit_Area_Sq_M__c, Total_Area_Sq_M__c,Product_Component_Type__c FROM Order_Entry_Line__c
            WHERE Order_Entry_Release__c IN :oerIDs AND Id NOT IN :insertedOELIds])
        {
            // *** Version 4 - Change for handling OEL Metric Record Type
            oerWrapperMap.get(existingOEL.Order_Entry_Release__c).addOrderEntryLine(existingOEL, rt_MapSchema.get(existingOEL.RecordTypeId).getDeveloperName());
//            oerWrapperMap.get(existingOEL.Order_Entry_Release__c).addOrderEntryLine(existingOEL);
        }
        
        for (OrderEntryLineWrapper oelw : oelWrapperMap.values())
        {
            OrderEntryReleaseWrapper oerw = oerWrapperMap.get(oelw.oel.Order_Entry_Release__c);
            Order_Entry_Release__c oer = oerw.oer;
            if (oerPostConfirmation.contains(oer.Status__c) && oer.RecordType.DeveloperName.contains('IGU'))
            {
                if (oerPostIntegration.contains(oer.Status__c))
                {
                    oerw.setIntegrationScope('Line Items');
                    if (oelw.oel.Status__c == 'Change Confirmation Required')
                    {
                        if (oer.Status__c != 'Change Confirmation Required')
                        {
                            oer.Pre_Change_Status__c = oer.Status__c;
                            oerw.isUpdated = true;
                            
                            oer.Status__c = 'Change Confirmation Required';
                            
                        }
                    }
                }
                else 
                {
                    oer.Status__c = 'Confirmation Pending';
                    oerw.isUpdated = true;                  
                }
            }
            //Added by ENP
            if(!oer.RecordType.DeveloperName.contains('IGU') && oerPostConfirmationCSS.contains(oer.Status__c))
            {
                oerw.setIntegrationScope('Line Items');
                if (oer.Status__c != 'Change Confirmation Pending' && oelw.oel.Status__c == 'Change Confirmation Pending'){
                    oer.Pre_Change_Status__c = oer.Status__c;
                    oerw.isUpdated = true;

                    oer.Status__c = 'Change Confirmation Pending';
                }
                
            }
            if(!oer.RecordType.DeveloperName.contains('IGU') && oerPostIntegrationCSS.contains(oer.Status__c))
            {
                oerw.setIntegrationScope('Line Items');
                if (oer.Status__c != 'Change Requested' && oelw.oel.Status__c == 'Change Requested'){
                    oer.Pre_Change_Status__c = oer.Status__c;
                    oerw.isUpdated = true;

                    oer.Status__c = 'Change Requested';
                }
                
            }
            //ended by Enp          
        }   
        
        for (OrderEntryReleaseWrapper oerw : oerWrapperMap.values())
        {
            //
            // JV - 20172711 added the following to support rollups
            //
            oerw.recalculateRollups();          
            if (oerw.isUpdated)
            {
                oerw.oer.Trigger_Source__c = 'Line';
            } 
            //BALA - 20190928 - For parts requests order set order status to integration requested.
            if(oerw.oer.Auto_Book_Order__c) {
                System.debug(' Auto Book Order '+oerw.oer.Auto_Book_Order__c);
                CheckIfOrderIsOrderBooked.AutoBookOrderStatic = True; //Auto_Order_Creation_Failure
                oerw.oer.Status__c = 'Integration Requested';
                oerw.oer.Trigger_Source__c = 'UI';
            }
            if (oerw.isUpdated || oerw.oer.Auto_Book_Order__c) {
                oersToUpdate.add(oerw.oer);
            }            
        }

        Boolean hasErrors = false;
        if (oersToUpdate.size() > 0)
        {
            List<Database.SaveResult> srList = new List<Database.SaveResult>();
            srList = Database.Update(oersToUpdate, false);
            Integer i = 0;
            for (Database.SaveResult sr: srList)
            {
                if (!sr.isSuccess())
                {
                    for (Database.Error err : sr.getErrors())
                    {
                            oersToUpdate[i].addError('Error updating Order_Entry_Release Status for added Order Entry Line: ' + err.getMessage());                     
                    }
                }
                i++;
            }           
        }
        //Added by ENP as part of Project Phase Implementation
        if(!test.isRunningTest())
        OrderEntryLineTriggerHandler.processProjectPhase(Trigger.newMap);
        OelShipmentDetails.oelShipmentDetailsInsert(Trigger.new); // BM OELFull creation
    }    
}