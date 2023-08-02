trigger Order_Entry_Release_BI on Order_Entry_Release__c (Before Insert) 
{
    // 20171107 - Code changed to permit Draft Release with blank Quote
    // 20180509 - Changed to use CPQ Quote
    // 20180531 - Change to support both SFDC and CPQ Quote
    // 20180626 - Change to initialize CurrencyISOCode
    AddressLines addrLines;
    Address billingAddress;
    Address shippingAddress;
    Address soldToAddress;
    List<OrderEntryReleaseWrapper> oerwList = new List<OrderEntryReleaseWrapper>();
    // 20180531 - Change to support both SFDC and CPQ Quote
    Map<Id, SBQQ__Quote__c> cpqQuoteMap = new Map<Id, SBQQ__Quote__c>();
    Set<Id> cpqQuoteIds = new Set<Id>();
    // 20180626 - Added following 2 fields for retrieving Opportunity data
    Set<Id> opptyIDs = new SEt<Id>();
    Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
    RecordType qrt;
    //MS
    List<RecordType> bidQuoteRecordType = new List<RecordType>();
    Map<ID,Schema.RecordTypeInfo> oerRecordTypeMapSchema = Schema.SObjectType.Order_Entry_Release__c.getRecordTypeInfosById();
    Boolean hasErrors;
    //Added by ENP
    Map<String, Double> currencyConversionMap = new Map<String, Double>();
    
    if (trigger.isBefore && trigger.isInsert)
    {
        hasErrors = false;
        Set<Id> relatedAcctIds = new set<Id>();
        Map<Id,Account> relatedAccts = new Map<Id,Account>();
        
        for(Order_Entry_Release__c oer : trigger.new)
        {
            oerwList.add(new OrderEntryReleaseWrapper(oer));
            if (oer.Shipping_Account__c != null)
            {
                relatedAcctIds.add(oer.Shipping_Account__c);
            }
            if (oer.Billing_Account__c != null)
            {
                relatedAcctIds.add(oer.Billing_Account__c);
            }
            if (oer.Sold_to_Account__c != null)
            {
                relatedAcctIds.add(oer.Sold_to_Account__c);
            }
            if (oer.CPQ_Quote__c != null)
            {
                cpqQuoteIds.add(oer.CPQ_Quote__c);
            }
            opptyIDs.add(oer.Opportunity__c);
        }
        
        //Get Currency Conversion table - //Added by ENP
        for (CurrencyType cRates : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE]) {
             currencyConversionMap.put(cRates.IsoCode, cRates.ConversionRate);
        }
        
        for (Account acct : [SELECT Id, Name, ShippingAddress, BillingAddress FROM Account WHERE Id IN :relatedAcctIds ])
        {
            relatedAccts.put(acct.Id, acct);
        }
        // 20180626 - added the folowing SELECT for Opportunity 
        for (Opportunity oppty : [SELECT Id, CurrencyISOCode, Name, PriceBook2Id, RecordTypeID FROM Opportunity WHERE Id in :opptyIDs])
        {
            opptyMap.put(oppty.Id, oppty);
        }
        if (cpqQuoteIds.size() > 0)
        {
        //MS commented the next line
            //qrt = [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType WHERE IsActive = true AND SObjectType = 'SBQQ__Quote__c' AND DeveloperName = 'Budgetary_Estimate' LIMIT 1];
        //MS added a new line
        bidQuoteRecordType = [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType WHERE IsActive = true AND SObjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Budgetary_Estimate', 'Bid_Quote_Locked_Approved', 'Bid_Quote_Locked_Record_Type')];
            for(SBQQ__Quote__c qte : [SELECT Id, RecordTypeId, name, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE id IN :cpqQuoteIds])
            {
                cpqQuoteMap.put(qte.id, qte);
            } 
        }       
        for(OrderEntryReleaseWrapper oerw: oerwList)
        {
            Order_Entry_Release__c oer = oerw.oer;
            // JV 20171107 - Added logic to if... statement to allow blank Quote in Draft Status
            // JV 20180509 - Changed to use CPQ Quote
            // 20180531 - Change to support both SFDC and CPQ Quote
            
            // 20180626 - Initialize currency if null
            if (oer.CurrencyISOCOde == null)
            {
                oer.CurrencyISOCode = opptyMap.get(oer.Opportunity__c).CurrencyISOCode;
            }

            if (oerRecordTypeMapSchema.get(oer.RecordTypeID).getDeveloperName().containsIgnoreCase('IGU') && oer.CPQ_Quote__c == null && oer.Quote__c == null && oer.Status__c != 'Draft')
            {
                oerw.addValidationError('CPQ Quote and SFDC Quote cannot both be null.');
                hasErrors = true;
            }
            else
            {
                if (oer.CPQ_Quote__c != null)
                {
                   //MS commented next 5 lines
                    /*if (cpqQuoteMap.get(oer.CPQ_Quote__c).RecordTypeId != qrt.Id)
                    {
                        hasErrors = true;
                        oerw.addValidationError('The selected CPQ Quote is not a Bugetary Estimate Quote Record Type');
                    }*/
                    //MS added new lines
                 boolean bidQuoteRecordTypeList = true;                 
                 for(RecordType rt : bidQuoteRecordType){
                   if(cpqQuoteMap.containsKey(oer.CPQ_Quote__c) && cpqQuoteMap.get(oer.CPQ_Quote__c).RecordTypeId == rt.Id)
                   {
                   bidQuoteRecordTypeList = false;
                   }
                 }
                 
                    if (bidQuoteRecordTypeList)
                    {
                        hasErrors = true;
                        oerw.addValidationError('The selected CPQ Quote is not a Bid Quote Quote Record Type');
                    }
                }
            }
            // 20180531 

            if (oer.Shipping_Name__c != null)
            {
                AddressLines addrLines = new AddressLines();
                addrLines.name = oer.Shipping_Name__c;
                addrLines.street1 = oer.Shipping_Street_1__c;
                addrLines.street2 = oer.Shipping_Street_2__c;
                addrLines.street3 = oer.Shipping_Street_3__c;
                addrLines.city = oer.Shipping_City__c;
                addrLines.stateProvince = oer.Shipping_State_Province__c;
                addrLines.postalCode = oer.Shipping_Postal_Code__c;
                addrLines.country = AddressUtils.getStandardName(oer.Shipping_Country__c);
                oer.Shipping_Address__c = AddressUtils.formatAddress(oer.Shipping_Name__c, addrLines, true);
            }

                            
            if (oer.Billing_Account__c != null)
            {

                if (relatedAccts.get(oer.Billing_Account__c).BillingAddress != null)
                {
                    billingAddress = relatedAccts.get(oer.Billing_Account__c).BillingAddress;
                }
                else
                {
                    if (relatedAccts.get(oer.Billing_Account__c).ShippingAddress != null)
                    {
                        billingAddress = relatedAccts.get(oer.Billing_Account__c).ShippingAddress;
                    }
                }
                oer.Billing_Address__c = AddressUtils.formatAddress(relatedAccts.get(oer.Billing_Account__c).Name, billingAddress);
                addrLines = new AddressLines(relatedAccts.get(oer.Billing_Account__c).Name, billingAddress);
                oer.Billing_Street_1__c = addrLines.street1;
                oer.Billing_Street_2__c = addrLines.street2;
                oer.Billing_Street_3__c = addrLines.street3;
                oer.Billing_City__c = addrLines.city;
                oer.Billing_State_Province__c = addrLines.stateProvince;
                oer.Billing_Postal_Code__c = addrLines.postalCode;
                oer.Billing_Country__c = AddressUtils.getStandardName(addrLines.country);
            }
            else
            {
                oerw.addValidationError('Billing Account is a required field; it may not be null.');
                hasErrors = true;
            }   

        
            if (oer.Sold_to_Account__c != null)
            {

                if (relatedAccts.get(oer.Sold_to_Account__c).BillingAddress != null)
                {
                    soldToAddress = relatedAccts.get(oer.Sold_to_Account__c).BillingAddress;
                }
                else
                {
                    if (relatedAccts.get(oer.Sold_to_Account__c).ShippingAddress != null)
                    {
                        soldToAddress = relatedAccts.get(oer.Sold_to_Account__c).ShippingAddress;
                    }
                }
                oer.Sold_to_Address__c = AddressUtils.formatAddress(relatedAccts.get(oer.Sold_to_Account__c).Name, soldToAddress);
                addrLines = new AddressLines(relatedAccts.get(oer.Sold_to_Account__c).Name,soldToAddress);
                oer.Sold_to_Street_1__c = addrLines.street1;
                oer.Sold_to_Street_2__c = addrLines.street2;
                oer.Sold_to_Street_3__c = addrLines.street3;
                oer.Sold_to_City__c = addrLines.city;
                oer.Sold_to_State_Province__c = addrLines.stateProvince;
                oer.Sold_to_Postal_Code__c = addrLines.postalCode;
                oer.Sold_to_Country__c = AddressUtils.getStandardName(addrLines.country);
            }   
            else
            {
                oerw.addValidationError('Sold-to Account is a required field; it may not be null.');
                hasErrors = true;
            }
            
            //Added by ENP
            if(oer.CurrencyISOCOde != null){                
                if(currencyConversionMap<>null)
                    oer.Conversion_Rate_Integration_Requested__c = currencyConversionMap.get(oer.CurrencyISOCOde);
                    
            }
            else{
                oerw.addValidationError('Please Populate Currency.');
                hasErrors = true;               
            }   
        }
        if (hasErrors)
        {
            for (OrderEntryReleaseWrapper oerw: oerwList)
            {
                if (oerw.hasErrors)
                {                   
                    String displayMessage = '';
                    for (Integer i = 0; i < oerw.validationErrors.size(); i++)
                    {
                        if (i > 0)
                        {
                            displayMessage = displayMessage + '<br/>';
                        }
                        displayMessage = displayMessage +   String.valueOf(i+1) + ') ' + oerw.validationErrors[i];
                        System.debug('*** Added err: ' + oerw.validationErrors[i]);
                    }
                    oerw.oer.addError(displayMessage,false);                                                  
                }
            }
        }
        
    }
}