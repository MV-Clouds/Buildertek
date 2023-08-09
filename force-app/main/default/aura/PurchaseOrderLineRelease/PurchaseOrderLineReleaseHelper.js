({
    getTemplateBody : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getPurchaseOrderLines");
        action.setParams({
            recordId : recordId,
            templateId : component.get("v.selectedTemplate")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result =  response.getReturnValue();
                component.set("v.purchaseOrderLines", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    sendEmailhelper : function(component, event){
        component.set("v.Spinner", true);
        console.log(component.get('v.selectedTemplate'));
        var getTemplate=component.get('v.selectedTemplate');
        var toIds = []; 
        var ccIds = [];
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        to.forEach(function(v){ toIds.push(v.Id) });
        cc.forEach(function(v){ ccIds.push(v.Id) });
        var subject = 'PurchaseOrder[ref:'+component.get("v.recordId")+']';
        if(getTemplate!= undefined && getTemplate != ''){
            if(toIds.length != 0){
            
                var action = component.get("c.sendPurchaseOrderLineRelease"); 
                action.setParams({
                    htmlBody : component.get("v.purchaseOrderLines"),
                    recordId : component.get("v.recordId"),
                    templateId : component.get("v.selectedTemplate"),
                    to : toIds,
                    cc : ccIds,
                    Emailsubject :subject
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var result = response.getReturnValue();
                        if(result === 'Success'){
                            component.set("v.Spinner", false);
                            $A.get("e.force:closeQuickAction").fire();  
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "type": 'success',
                                "message": "Email Sent Successfully"
                            });
                            toastEvent.fire();
                        }else{
                            $A.get("e.force:closeQuickAction").fire();  
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": 'error',
                                "message": result
                            });
                            toastEvent.fire();    
                        }
                        $A.get('e.force:refreshView').fire();
                    }
                });
                $A.enqueueAction(action);    
            }else{
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": "Please select To Address to send Email"
                });
                toastEvent.fire();    
            }

        }else{
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please Select Template"
            });
            toastEvent.fire();   
        }
      
    },
})