({
	createPurchaseOrder : function(component, event, helper) {
	    var recordId = component.get("v.recordId");
	    var project = component.get("v.QuoteRecord.buildertek__Project__c");
	    //alert('project --> '+project);
        var products = component.get("v.objInfo");
        //alert('products --> '+JSON.stringify(products));
	    var SubOptions = [];
	    for(var i=0 ; i < products.length;i++){
	        if(products[i].ProductCheck == true){
	            SubOptions.push(products[i].product.Id+'-'+products[i].POQuantity);
	        }
	    }
	    //alert('SubOptions --> '+SubOptions);
	    if(SubOptions.length > 0){
	        component.set("v.selectedobjInfo",SubOptions);
	         //component.set("v.isOpen", false);
	         
	         var action = component.get("c.createPurchseOrderAndLines");
	            action.setParams({
	                ProductIds : SubOptions,
	                recordId : recordId,
	                projectId : project
	            });
                action.setCallback(this, function(response) {
                var state = response.getState();
                //alert('state --> '+state);
                if(state === "SUCCESS"){
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var result = response.getReturnValue();
                    if(result.status == "Error"){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: result.Message,
                            type : 'error'
                        });
                        toastEvent.fire();
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: result.Message,
                            messageTemplate: "Purchase Order {0} created successfully.",
                            messageTemplateData: [{
                            url: baseURL+'/lightning/r/buildertek__Purchase_Order__c/'+escape(result.recordId)+'/view',
                            label: result.recordName,
                            }],
                            type : 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }
                    
                    var recordId = component.get("v.recordId");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    
                }
            });
            $A.enqueueAction(action);
	    }
	}
})