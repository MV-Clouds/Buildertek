({
    onLoadNew : function(component, event, helper) {
        var action = component.get('c.onLoadPickistVal');
        action.setParams({
            'quoteId' :component.get('v.recordId')
            
        });
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if(state === 'SUCCESS'){
                var returnVarPicklist = JSON.parse(response.getReturnValue()).varPicklist;
                var populateProjectID = JSON.parse(response.getReturnValue()).ProjectID;
                var populateCustomerID = JSON.parse(response.getReturnValue()).CustomerID;    
                var populateQuote = JSON.parse(response.getReturnValue()).Quote;
                var populateOpportunity = JSON.parse(response.getReturnValue()).Opportunity;    
                var populateBillingStreet = JSON.parse(response.getReturnValue()).BillingStreet;    
                var populateBillingCity = JSON.parse(response.getReturnValue()).BillingCity;
                var populateBillingCountry = JSON.parse(response.getReturnValue()).BillingCountry;    
                var populateBillingState = JSON.parse(response.getReturnValue()).BillingState;    
                var populateBillingZip = JSON.parse(response.getReturnValue()).BillingZip;    
                var populateBillingToAccount = JSON.parse(response.getReturnValue()).BillToAccount;
                var populateCPOValues = JSON.parse(response.getReturnValue()).customerPOAllValues;    
                var populateCurrencyIsoCode = JSON.parse(response.getReturnValue()).CurrencyIsoCode; 
                
                component.set("v.TermsPicklistValue", returnVarPicklist);
                component.set("v.AutoPopulateOppLookupProjectID", populateProjectID);
                component.set("v.AutoPopulateAccLookupCustomerID", populateCustomerID);
                component.set("v.AutoPopulateQuote", populateQuote);
                component.set("v.AutoPopulateOpportunity", populateOpportunity);
                component.set("v.AutoPopulateBillingStreet", populateBillingStreet);
                component.set("v.AutoPopulateBillingCity", populateBillingCity);
                component.set("v.AutoPopulateBillingCountry", populateBillingCountry);
                component.set("v.AutoPopulateBillingState", populateBillingState);
                component.set("v.AutoPopulateBillingZip", populateBillingZip);
                component.set("v.AutoPopulateBillingToAccount", populateBillingToAccount);
                component.set("v.AutoPopulateCurrencyIsoCode", populateCurrencyIsoCode);
                // alert('alert 1-------------->' +JSON.parse(response.getReturnValue()).customerPOAllValues);
                
                component.set("v.CPOnameList", populateCPOValues);
                
            } else if(state === 'ERROR'){
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    handleSubmit: function(component, event, helper) {
        
        event.preventDefault();       
        
        var eventfields = event.getParam('fields');
        //alert('eventfields' +JSON.stringify(eventfields));
        console.table('eventfieldsTable'  +JSON.stringify(eventfields));

        //console.log('eventfields' +eventfields[0].Invoiced_Amount__c);
        var termsPickList = component.find("AutoPopulateTermsFromOER").get('v.value');
        var CPOname = component.find("AutoPopulateCPO").get('v.value');
        var AutoCurrencyIsoCode = component.find("AutoPopulateCurrencyIsoCode").get('v.value');
        
        //alert('alert 2-------->'+CPOname);
        var action = component.get('c.saveInvoice');
        action.setParams({
            'invoice1':JSON.stringify(eventfields),
            'termsPickList' :termsPickList,
            'CPOname' :CPOname,
            'Currencycd' :AutoCurrencyIsoCode
        });
        //alert("alert 3------------>"+action.getParam('CPOname')+"---------------");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert("alert 4------------"+state+"---------------");
            
            if(state === 'SUCCESS' && JSON.parse(response.getReturnValue()).success){                    
                var successMessage = JSON.parse(response.getReturnValue()).successMessage;
                //alert("successMessage" +successMessage);
                var ids = JSON.parse(response.getReturnValue()).invoice.Id;
                
                component.set("v.invoiceId", ids);
                // alert (Component.get("v.invoiceId"));
                component.set("v.SuccessMessage", successMessage);
                
            } else{
                var errors = response.getError();
                console.log('errors:'  +errors);
                var errorMsg = JSON.parse(response.getReturnValue()).errorMessage;
                console.log('errorMessage:' + errorMsg);
                component.set("v.ErrorMessage", errorMsg)
                //alert ('else-------->');
                /*if(errors != null && errors[0].message != null){
                    component.set("v.ErrorMessage", errors[0].message);
                    console.log('errorConsoleLog' +errors[0].message);
                }*/
            }
        });            
        $A.enqueueAction(action); 
    }
})