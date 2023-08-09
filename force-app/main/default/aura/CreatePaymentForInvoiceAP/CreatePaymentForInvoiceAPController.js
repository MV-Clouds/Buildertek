({
    doInit : function(component, event, helper) {
        debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        var action = component.get("c.getPaymentLines");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            debugger;
            if(response.getState() === "SUCCESS"){
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                var result = response.getReturnValue();
                if(result != null){
                    component.set("v.isInvoiceLines",true)    
                    component.set("v.InvoiceDetails",result.Invoice) 
                    component.set("v.InvoiceLinesList",result.InvoiceLine) 
                    if(result.InvoiceLine == undefined){
                        component.find("headCheckRFQ").set("v.disabled", true);
                    }
                    
                    component.set("v.SubTotal",result.Invoice.buildertek__Total__c); 
                    component.set("v.invoiceName",result.Invoice.Name);
                    component.set("v.invoiceId",result.Invoice.Id);
                    
                    if(result.Invoice.buildertek__Vendor__c != null || result.Invoice.buildertek__Vendor__c != undefined){
                        component.set("v.vendorId",result.Invoice.buildertek__Vendor__c);
                    }
                    
                    if(result.Invoice.buildertek__Project__c != undefined){
                        component.set("v.projectName",result.Invoice.buildertek__Project__r.Name) ;
                    }
                }else{
                    component.set("v.Spinner", false);
                    component.set("v.showMessage", false);                    
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'There are no Invoice Lines',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                    });
                    toastEvent.fire();
                }
                
            }
        });
        $A.enqueueAction(action);
        helper.getFields(component, event, helper);
    },
    
    
    
    Createpayment : function (component, event, helper) {
        debugger;
        var Invoice = component.get("v.InvoiceDetails");
        var InvoiceLineList = component.get("v.InvoiceLinesList");
        var selectedLineIds = component.get("v.selectedPayLineIds");
        
        var recordId = component.get("v.recordId");
        
        if(selectedLineIds.length < 1){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'ERROR',
                message: 'Please Select atleast one Line',
                duration: "5000",
                key: "info_alt",
                type: "error",
            });
            toastEvent.fire();
        }
        else{
            var action = component.get("c.createPayment");  
            action.setParams({
                recordId : recordId,
                invoice : Invoice,
                invoiceLineList : InvoiceLineList,
                lineIds : selectedLineIds
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var result = response.getReturnValue();
                if(result != null){
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result.Id,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    
                    $A.get("e.force:refreshView").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "",
                        "message": "Payment Created Successfully."
                    });
                }
                
            });
            $A.enqueueAction(action);
            
        }
        
    },
    
    
    selectAllRfq : function (component, event, helper) {
        debugger;
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.InvoiceLinesList")));
        var getAllId = component.find("checkRFQ");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", true);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", true);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.selectedPayLineIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", false);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", false);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.selectedPayLineIds",recordIds);
            }
        }
        console.log(recordIds);
        
    },
    
    selectRfq: function (component, event, helper) {
        debugger;
        var checkbox = event.getSource();
        
        // alert('Chechbox--------------  '+component.find("checkRFQ").get("v.name"));
        var selectedRfqIds = component.get("v.selectedPayLineIds");
        var getAllId = component.find("checkRFQ");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckRFQ").get("v.checked")){
                    component.find("headCheckRFQ").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckRFQ").get("v.checked")){
                        component.find("headCheckRFQ").set("v.checked",true);
                    }
                }
            }
            
            
            
        }else{
            if(component.find("headCheckRFQ").get("v.checked")){
                component.find("headCheckRFQ").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.selectedPayLineIds",selectedRfqIds);
        
        
    },
    
    handleOnSubmit : function(component, event, helper) {
        debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        
        component.find('leadCreateForm').submit(eventFields);
        component.set("v.sovValues",eventFields)
    },
    
    handleOnSuccess : function(component, event, helper) {
        
        var payload = event.getParams().response;
        console.log(payload.id);
        var Invoice = component.get("v.sovValues");
        var InvoiceLineList = component.get("v.InvoiceLinesList");
        var selectedLineIds = component.get("v.selectedPayLineIds");
        
        var invoiceid = component.get("v.recordId");
        
        var action = component.get("c.createSovLines");
        action.setParams({
            recordId : payload.id,
            invoiceLineList : InvoiceLineList,
            lineIds : selectedLineIds,
            invoiceId : invoiceid
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": payload.id,
                    "slideDevName": "detail"
                });
                navEvt.fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "",
                    "message": "Payment Created Successfully."
                });
            } else {
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
        
        
        
        
        
    },
    
    CloseScreen: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleSubmit: function (component, event, helper) {
        debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        component.set('v.isLoading', true);
        var fields = event.getParam("fields");
        if(fields.buildertek__Status__c == null || fields.buildertek__Status__c == '' || fields.buildertek__Status__c == undefined){
            fields.buildertek__Status__c = component.get("v.status"); 
        }
        event.preventDefault(); // Prevent default submit
        component.find('recordViewForm').submit(fields); // Submit form
        component.set("v.sovValues",fields);
    },
    
    onRecordSuccess: function (component, event, helper) {
        
        
        var payload = event.getParams().response;
        console.log(payload.id);
        var Invoice = component.get("v.sovValues");
        var InvoiceLineList = component.get("v.InvoiceLinesList");
        var selectedLineIds = component.get("v.selectedPayLineIds");
        
        var invoiceid = component.get("v.recordId");
        
        var action = component.get("c.createSovLines");
        action.setParams({
            recordId : payload.id,
            invoiceLineList : InvoiceLineList,
            lineIds : selectedLineIds,
            invoiceId : invoiceid
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": payload.id,
                    "slideDevName": "detail"
                });
                navEvt.fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "",
                    "message": "Payment Created Successfully."
                });
            } else {
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
        
        
        
        
    },
    
    
    
    
    
    
    
})