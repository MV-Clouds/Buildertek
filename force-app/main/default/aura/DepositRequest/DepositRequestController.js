({
    doInit : function(component, event, helper) {
        component.find("AutoPopulateInvoiceType").set("v.value", "Deposit Request");
        component.find("AutoPopulateIntegrationStatus").set("v.value", "New");
        //component.find("CurrencyIsoCode").set("v.value", "");
        var today = new Date(); 
       /* var dd = today.getDate();  
        var mm = today.getMonth()+1;  
        var yyyy = today.getFullYear(); 
        if(dd<10)  {     dd='0'+dd; }   
        if(mm<10)  {     mm='0'+mm; }  
        today = mm+'-'+dd+'-'+yyyy; 
        console.log(today); 
        today = mm+'/'+dd+'/'+yyyy; 
        console.log(today); 
        today = dd+'-'+mm+'-'+yyyy; 
        console.log(today); 
        today = dd+'/'+mm+'/'+yyyy; 
        alert(today);
            */
        component.set('v.AutoPopulateTodayDateAttribute', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
    
        helper.onLoadNew(component, event, helper);
    },
    handleLoad : function(component, event, helper){
    $A.util.addClass(component.find("spinner"), "slds-hide");    
	},
    verifyData: function(component, event, helper) {
        component.set("v.disableButton",true);
        component.set("v.showMessage",false);
        helper.handleSubmit(component, event, helper);
    },
    handleSuccess: function(component, event, helper) {     
    },
        
    navigateToDetailPage : function(component, event, helper) {
        //helper.navigateToDetailPage(component, event, helper);
        $A.get("e.force:closeQuickAction").fire(); 
    },
    
    handleHideErrorDisplayModal : function(component, event, helper) {
        var invoiceId = component.get('v.invoiceId');
        var currentId = component.get("v.recordId");
        //alert("invoiceIdAlert" +invoiceId);
        if(component.get("v.ErrorMessage")==null ){
            component.set("v.ErrorMessage",null);
            component.set("v.SuccessMessage",null);
        	window.location.replace('/lightning/r/Invoice__c/'+invoiceId+'/view');
        }
        else{
            component.set("v.ErrorMessage",null);
            component.set("v.SuccessMessage",null);
        	window.location.replace('/lightning/r/SBQQ__Quote__c/'+currentId+'/view');
        }
    }
})