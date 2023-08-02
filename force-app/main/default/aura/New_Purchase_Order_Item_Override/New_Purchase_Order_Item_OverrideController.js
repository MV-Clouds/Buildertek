({
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },

    handleComponentEvent: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.newPOItem.Name", selectedAccountGetFromEvent.Name);
        component.set("v.newPOItem.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },

    handleComponentEvents: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.newPOItem.Name", selectedAccountGetFromEvent.Name);
        component.set("v.newPOItem.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },

    closeModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        var isCalledFromParent=component.get('v.isCalledFromParent');
        if(!isCalledFromParent){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
            .catch(function (error) {
                console.log(error);
            });
            $A.get("e.force:closeQuickAction").fire();
            component.set("v.isOpen", false);
            window.setTimeout(
                $A.getCallback(function () {
                     $A.get('e.force:refreshView').fire();
                }), 1000
            );

        }else{
            $A.get("e.force:closeQuickAction").fire();
        }
        
    },

    changefamily: function (component, event, helper) {

        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        component.set('v.newPOItem.Name', '');
        component.set('v.newPOItem.buildertek__Unit_Price__c', '');

    },
    changeEvent: function (component, event, helper) {
        helper.changeEvent(component, event, helper);
    },

   
    handleSubmit : function (component, event, helper) {
        component.set("v.isDisabled", true);
		component.set("v.isLoading", true);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("fields");

        let getProductId= component.get("v.productId");
        if(getProductId != null){
            fields['buildertek__Product__c' ]=getProductId;

        }
        let poName=fields['Name'];
        console.log(poName);
        if(poName !=null || poName!= undefined){
            if(poName.length > 80){
                poName=poName.substring(0 , 80)
                fields['Name']=poName;
            }

        }


        var allData = JSON.stringify(fields);


        var action = component.get("c.saveData");
        action.setParams({
            allData : allData
        });
        action.setCallback(this, function(response){
            console.log(response.getState());

            if(response.getState() == 'SUCCESS') {            
                var result = response.getReturnValue();
                console.log({result});
                var saveNnew = component.get("v.isSaveNew");
                var isCalledFromParent=component.get('v.isCalledFromParent');
                console.log({isCalledFromParent});


                if(isCalledFromParent){
                    component.set('v.selectedLookUpRecord' , '');
                    component.set('v.productfamily' , '');

                    
                    component.find('field').forEach(function(f) {
                        f.reset();
                    });
                    
                }

                if(saveNnew){
                    $A.get('e.force:refreshView').fire();
                    component.set("v.isSaveNew", false);
                }else{
                    var workspaceAPI = component.find("workspace");
                    var focusedTabId = response.tabId;
                    //timeout
                    if(!isCalledFromParent){
                        window.setTimeout(
                            $A.getCallback(function() {
                                workspaceAPI.getFocusedTabInfo().then(function(response) {
                                    workspaceAPI.closeTab({tabId: focusedTabId});
                                    component.set("v.isLoading", false);
                                })
                            }), 1000
                            );
                    }
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Purchase Order Line created successfully",
                    "type": "success"
                });
                toastEvent.fire();
                component.set("v.isDisabled", false);
                component.set("v.isLoading", false);

            }else{
                var errors = response.getError();
                if (errors[0].pageErrors != undefined && (errors[0].pageErrors[0].statusCode.includes('REQUIRED_FIELD_MISSING') && errors[0].pageErrors[0].message.includes('Vendor'))) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Vendor is Missing on Purchase Order",
                        "type": "error"
                    });
                    toastEvent.fire();
                }else if (errors[0].pageErrors != undefined && (errors[0].pageErrors[0].statusCode.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION") && errors[0].pageErrors[0].message.includes("You cannot update this Purchase Order because there is a Contract Invoice associated with it.  If you would like to change this Purchase Order, please remove the Contract Invoice first."))) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "You cannot update this Purchase Order because there is a Contract Invoice associated with it",
                        "type": "error"
                    });
                    toastEvent.fire();
                } else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Something went wrong. Please try again.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                
                component.set("v.isDisabled", false);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    saveAndNew: function (component, event, helper) {
        
        component.set("v.isSaveNew", true);
        var isCalledFromParent=component.get('v.isCalledFromParent');
    },
    handleProductChange:function (component, event, helper) {
        console.log('handleProductChange');
        

        var action = component.get("c.getProductDetails");
        // set param to method  
        action.setParams({
            PriceBookId: component.get('v.pricebookName'),
            prodFamily: component.get("v.productfamily")
        });
        // set a callBack    
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {
                

            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
})