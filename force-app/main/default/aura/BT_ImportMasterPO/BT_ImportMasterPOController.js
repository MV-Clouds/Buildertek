({
    doInit : function(component, event, helper) {
        component.set('v.isOpen',true); 
        helper.simulateServerRequest(component,$A.getCallback(function handleServerResponse(serverResponse) {
            component.set('v.options', serverResponse.plans);
            component.set('v.selectedValue', serverResponse.selectedPlanId);
            component.set('v.loading',false);
            var planType = "None"
            helper.getPoList(component,event,helper,planType);
            
        }));
    },
    
    doVendorSearch : function(component, event, helper){
        var vendorValue = component.get("v.searchVendorFilter");
        var planType = component.find('projectPlanId').get('v.value');
        if(planType == 0){
            planType = "None";
        }
        helper.getPoList(component,event,helper,planType);
    },
    
    onPlanChange:function(component, event, helper){
        console.log('on Change::',component.find('projectPlanId').get('v.value'));
        var planType = component.find('projectPlanId').get('v.value');
        var pageSize = component.get("v.pageSize");
        var vendorValue = component.get("v.searchVendorFilter");
        helper.getPoList(component,event,helper,planType);
        
        /*var POList=[];
        var action = component.get('c.getMasterPO');
       
        console.log('planType::',planType);
        component.set('v.POList', POList);
        action.setParams({"planType" : planType,
                          "currentProjectId" :component.get('v.recordId')
                         });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var purchaseOrders = response.getReturnValue();
                console.log('PurchaseOrders::',purchaseOrders);
                if(purchaseOrders!=undefined){
                    for(var i in purchaseOrders){
                        if(purchaseOrders[i].buildertek__Purchase_Orders__r!=undefined){
                            for(var j in purchaseOrders[i].buildertek__Purchase_Orders__r){
                                if(purchaseOrders[i].buildertek__Purchase_Orders__r[j].Id!=undefined){
                                    var obj={};
                                    obj.Id = purchaseOrders[i].buildertek__Purchase_Orders__r[j].Id;
                                    obj.Name = purchaseOrders[i].buildertek__Purchase_Orders__r[j].Name;
                                    obj.buildertek__Project__c = purchaseOrders[i].Name;
                                    obj.buildertek__Is_Selected__c = false;
                                    POList.push(obj);
                                }
                            } 
                        }
                    }
                }
                component.set('v.POList',POList);
                POList.length>0 ? component.set('v.isRecordsExist',true) : component.set('v.isRecordsExist',false);
            }
        });
        $A.enqueueAction(action);*/
    },
    
    onChangeHandler:function(component, event, helper){
        var selectionId = event.getSource().get("v.text");
        var POList = component.get('v.POList');
        for(var i in POList){
            if(POList[i].Id == selectionId){
                if(POList[i].buildertek__Is_Selected__c){
                    POList[i].buildertek__Is_Selected__c=true;
                }else{
                    POList[i].buildertek__Is_Selected__c=false;
                }
                
            }
        }
        component.set('v.POList',POList);
        console.log('POList::',POList);
    },
    
    selectAll : function(component, event, helper){
        var selectedHeaderCheck = event.getSource().get("v.value"); 
        var purchaseOrder =  component.get('v.POList');
        var getAllId = component.find("checkPO");
        if(purchaseOrder != null){
            if(purchaseOrder.length > 1){
                if(! Array.isArray(getAllId)){
                    if(selectedHeaderCheck == true){ 
                        component.find("checkPO").set("v.value", true); 
                    }else{
                        component.find("checkPO").set("v.value", false);
                    }
                }
                else{ 
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkPO")[i].set("v.value", true); 
                            var checkbox = component.find("checkPO")[i].get("v.text");  
                            purchaseOrder[i].buildertek__Is_Selected__c = true;
                        }
                    }else{
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkPO")[i].set("v.value", false); 
                            var checkbox = component.find("checkPO")[i].get("v.text"); 
                            var purchaseOrder = component.get("v.POList");
                            purchaseOrder[i].buildertek__Is_Selected__c = false;
                        }
                    } 
                } 
            }else{
                var i=0;
                if (selectedHeaderCheck == true) {
                    component.find("checkPO").set("v.value", true); 
                    var checkbox = component.find("checkContractor").get("v.text");  
                    purchaseOrder[i].buildertek__Is_Selected__c = true;
                }else{
                    component.find("checkPO").set("v.value", false); 
                    var checkbox = component.find("checkPO").get("v.text"); 
                    var purchaseOrder = component.get("v.POList");
                    purchaseOrder[i].buildertek__Is_Selected__c = false;
                } 
            }
        }
        component.set('v.POList',purchaseOrder);
    },
    
    closeModel:function(component, event, helper){
        component.set('v.isOpen',false); 
        location.href =  '/lightning/r/buildertek__Purchase_Order__c/'+component.get('v.recordId')+'/related/buildertek__Purchase_Orders__r/view'

    },
    
    importPO : function(component, event, helper){
        var toastEvent = $A.get("e.force:showToast");
        component.set('v.loading',true);
        var selectedPOIds = [];
        var purchaseOrder =  component.get('v.POList');
        if(purchaseOrder!=undefined ){
            for(var i in purchaseOrder){
                if(purchaseOrder[i].buildertek__Is_Selected__c){
                    selectedPOIds.push(purchaseOrder[i].Id);
                }
            }   
        }
      //  alert('selectedPOIds.length'+selectedPOIds.length);
        if(selectedPOIds.length>0){
            helper.importMasterPO(component, event, helper,selectedPOIds);            
        }else{
            //component.set('v.isOpen',false);
            //alert('selectedPOIds.length'+selectedPOIds.length);
          component.set('v.loading',false);
            /*toastEvent.setParams({
                "type" : 'error',
                "title": "Error!",
                "message": "Select Purchase Order"
            });
            toastEvent.fire();*/
            component.find('notifLib').showNotice({
				"variant": "error",
				"header": "No Purchase Orders",
				"message": "Please Select a Purchase Orders.",
				closeCallback: function () {}
			});
        }
    },
})