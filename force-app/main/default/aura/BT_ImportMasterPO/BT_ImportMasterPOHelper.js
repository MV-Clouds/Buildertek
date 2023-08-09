({
    simulateServerRequest: function (component,onResponse) {
        var action = component.get('c.getProjectPlan');
        action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                var projectPlan = [];
                var res = response.getReturnValue();
                var obj ={};
                obj.label='None';
                obj.id='None';
                projectPlan.push(obj);
                for(var i in res){
                    obj = {};
                    obj.label=res[i];
                    obj.id=res[i];
                    projectPlan.push(obj);
                }
                var serverResponse = {
                    selectedPlanId: 0,
                    plans: projectPlan
                };
                onResponse.call(null, serverResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPoList : function(component,event, helper,planType){
        var vendorValue = component.get("v.searchVendorFilter");
        var action;
        if(planType == "None"){
            action = component.get('c.getAllMasterPO');
            console.log('planType::',planType);
            component.set('v.POList', POList);
            action.setParams({
                "vendorName": vendorValue.trim(),
                "currentProjectId" :component.get('v.recordId')
            });
        }else if(planType != "None"){
            action = component.get('c.getMasterPO');
            console.log('planType::',planType);
            component.set('v.POList', POList);
            action.setParams({
                "planType" : planType,
                "vendorName": vendorValue.trim(),
                "currentProjectId" :component.get('v.recordId')
            });
        }
         var POList=[];
        //var action = component.get('c.getMasterPO');
       
        /*console.log('planType::',planType);
        component.set('v.POList', POList);
        action.setParams({"planType" : planType,
                          "currentProjectId" :component.get('v.recordId')
                         });*/
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
                                    obj.Vendor = purchaseOrders[i].buildertek__Purchase_Orders__r[j].buildertek__Vendor__r.Name;
                                    obj.POAmount = purchaseOrders[i].buildertek__Purchase_Orders__r[j].buildertek__PO_Amount__c;
                                    obj.Description = purchaseOrders[i].buildertek__Purchase_Orders__r[j].buildertek__Description__c;
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
        $A.enqueueAction(action);
    },
    
    importMasterPO : function(component, event, helper, selectedPOIds){
        var action = component.get('c.importPurchaseOrder');
        console.log('Record Id::',component.get('v.recordId'));
        console.log('Selected PO Ids :: ',selectedPOIds);
        action.setParams({ "currentProjectId" : component.get('v.recordId'),
                          "selectedPOId" : selectedPOIds});
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS" && response.getReturnValue() === 'Success' && response.getReturnValue() !=null) {//response.getReturnValue() === 'Success'
                component.set('v.loading',false);
                component.set('v.isOpen',false); 
               location.href =  '/lightning/r/buildertek__Purchase_Order__c/'+component.get('v.recordId')+'/related/buildertek__Purchase_Orders__r/view'
                //$A.get("e.force:closeQuickAction").fire(); 
            }else if(response.getReturnValue() !='Success'){
                component.set('v.isOpen',false);
                var recordid = response.getReturnValue();
                /*var sObjectEvent = $A.get("e.force:navigateToSObject");
                sObjectEvent.setParams({
                    "recordId": response.getReturnValue().Id,
                })
                sObjectEvent.fire(); */
                component.set('v.loading',false);
                location.href = '/'+recordid;
            }/*else{
                component.set('v.loading',false);
                component.set('v.isOpen',false); 
                //$A.get("e.force:closeQuickAction").fire();
            }*/
        });
        $A.enqueueAction(action);
    },
})