@RestResource(urlMapping='/showPurchaseOrders/*')

global class showPurchaseOrder{

    @HttpGet

    global static List<Purchase_Order__c> getPO()
    {
        List<Purchase_Order__c> POlst;
        try
        {        
            POlst = [select name, Proejct_PO_Number__c, Vendor__c, date_approved__c, 
                        PO_Amount__c, Paid_Amount__c, PO_Balance__c
                        from Purchase_Order__c];
        }
        catch(Exception ex)
        {        
            system.debug('Error'+ ex.getMessage());
        }
        return POlst;
    }    


}