({
    doInit: function (component, event, helper) {  

        // var recordTypeId = component.get( "v.pageReference" ).state.recordTypeId;  
        // component.set("v.RecordTypeId",recordTypeId);
        console.log('RecordTypeId', component.get("v.RecordTypeId"));

        // get Admin values, Does user want to create CO with or without CO lines and dispaly kayout according to it.
        var action = component.get("c.getadminvalues");
		action.setCallback(this, function (response) {
    
			if (response.getState() == 'SUCCESS') {
                console.log(response.getReturnValue());
                var result=response.getReturnValue();
                if(result=='Without CO Lines'){
                    component.set('v.createWithOutCOLines', true);
                    component.set('v.createWithCOLines', false);

                }else{
                    component.set('v.createWithCOLines', true);
                    component.set('v.createWithOutCOLines', false);
                    // helper.getCOFields(component,event,helper);
                    helper.setCOLines(component,event,helper);


                }
                helper.getRecType(component,event,helper);
                var action4 = component.get("c.getvendor");
                action4.setCallback(this, function (response) {
                    var result4 = response.getReturnValue();
                    console.log("result 4 : ",result4);
                    if( result4 != null){
                        if(result4.IsPortalEnabled == true){
                            console.log("vendor : ",result4.buildertek__Account_Id__c);
                            component.set("v.isCommunity",true);
                            
                            //   component.find("vendorId").set("v.value", result4.buildertek__Account_Id__c);
                            component.set("v.vendorId",result4.buildertek__Account_Id__c);
                            component.set("v.AccountId",result4.buildertek__Account_Id__c); 
                            
                        }else{
                            
                        }
                    }
                    
                });
                $A.enqueueAction(action4); 
                
                var value = helper.getParameterByName(component, event, 'inContextOfRef');
                var context = '';
                var parentRecordId = '';
                component.set("v.parentRecordId", parentRecordId);
                if (value != null) {
                    context = JSON.parse(window.atob(value));
                    parentRecordId = context.attributes.recordId;
                    component.set("v.parentRecordId", parentRecordId);
                } else {
                    var relatedList = window.location.pathname;
                    var stringList = relatedList.split("/");
                    parentRecordId = stringList[4];
                    if (parentRecordId == 'related') {
                        var stringList = relatedList.split("/");
                        parentRecordId = stringList[3];
                    }
                    component.set("v.parentRecordId", parentRecordId);
                }
                if(parentRecordId != null && parentRecordId != ''){
                    var action = component.get("c.getobjectName");
                    action.setParams({
                        recordId: parentRecordId,
                    });
                    action.setCallback(this, function (response) {
                        if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                            var objName = response.getReturnValue();
                            if(objName == 'Account'){
                                component.set("v.CustomerAccountName", parentRecordId);
                            }else if(objName == 'buildertek__Project__c'){
                                component.set("v.parentprojectRecordId", parentRecordId);
                                helper.CustomerAccount(component,event,helper);
                            }else if(objName == 'buildertek__RFQ__c'){
                                component.set("v.parentRFQRecordId", parentRecordId);
                            }else if(objName == 'buildertek__Contract__c'){
                                component.set("v.parentContractRecordId", parentRecordId);
                                helper.getproject(component,event,helper);
                            }else if(objName == 'buildertek__Purchase_Order__c'){
                                component.set("v.parentPurchaseOrderRecordId", parentRecordId);
                            }else if(objName == 'buildertek__Budget__c'){
                                component.set("v.parentbudgetRecordId", parentRecordId);
                            }else if(objName == 'buildertek__Accounting_Period__c'){
                                component.set("v.parentaccountingPeriodRecordId", parentRecordId);
                            }
                        } 
                    });
                    $A.enqueueAction(action);
                }
        

                
			}
		});
		$A.enqueueAction(action); 
        
    },
    
    
    closeModel: function (component, event, helper) {
        component.set('v.createWithOutCOLines',false);
        component.set('v.createWithCOLines',false);

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
        window.setTimeout(
            $A.getCallback(function () {
            }), 1000
        );
    },

    gotoList : function (component, event, helper) {
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
        
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "buildertek__Change_Order__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSubmit: function (component, event, helper) {
        component.set('v.isLoading', true);
        event.preventDefault(); // Prevent default submit  

        var rfq = component.get('v.parentRFQRecordId');
        var contract = component.get('v.parentContractRecordId');
        var project = component.get('v.parentprojectRecordId');
        var po = component.get('v.parentPurchaseOrderRecordId');
        var budget = component.get('v.parentbudgetRecordId');
        var accountingperiod = component.get('v.parentaccountingPeriodRecordId');
        var fields = event.getParam("fields");
        console.log({fields});
        var name = component.find("Name").get("v.value");
        if(name != null && name != "" ){ 
            fields["Name"] = name;
        }if(rfq != null && rfq != ""){
            fields["buildertek__RFQ__c"] = rfq;
        }
        if(contract != null && contract != ""){
            fields["buildertek__Contract__c"] = contract;
        }
        if(project != null && project != ""){
            fields["buildertek__Project__c"] = project;
        }if(po != null && po != ""){
            fields["buildertek__Purchase_Order__c"] = po;
        } 
        if(budget != null && budget != ""){
            fields["buildertek__Budget__c"] = budget;
        }if(accountingperiod != null && accountingperiod != ""){
            fields["buildertek__Period__c"] = accountingperiod;
        }
        fields["RecordTypeId"] =  component.get("v.RecordTypeId");

        console.log('fields: ' + JSON.stringify(fields));
        var data = JSON.stringify(fields);
        console.log('data-->>',{data});
        var createWithOutCoLines=component.get('v.createWithOutCOLines');

        if(createWithOutCoLines){
            component.find('recordViewForm').submit(fields); // Submit form
        }else{
            var action = component.get("c.saveRecord");
            action.setParams({
                "data": data
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                var error = response.getError();
                console.log('Error =>',{error});
                if (state === "SUCCESS") {
                    console.log('success');
                    console.log(response.getReturnValue());
                    var recordId = response.getReturnValue();
                    console.log('recordId-->>',{recordId});
    
                    var coLineList = component.get("v.coLineList");
                    if(coLineList.length > 0){
                      helper.saveCOLineItems(component, event, helper, recordId);
                    }
    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "Success!",
                        "message": "The record has been created successfully."
                    });
                    toastEvent.fire();
              
                    var saveNnew = component.get("v.isSaveNew");
                    console.log('saveNnew: ' + saveNnew);
            
                    if(saveNnew){
                        // $A.get('e.force:refreshView').fire();
                        let parentprojectId = component.get("v.parentprojectRecordId");
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef: "c:ChangeOrderRecordType",
                            componentAttributes: {
                                projectId: parentprojectId
                            }
                        });

                        evt.fire();
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({ tabId: focusedTabId });
                        })
                        .catch(function (error) {
                            console.log(error);
                        });
                    }
                    else{
                        console.log('---Else---');
                        console.log('saveAndClose');
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recordId,
                            "slideDevName": "Detail"
                        });
                        navEvt.fire();
                        component.set("v.parentRecordId", null);
            
                        var focusedTabId = '';
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            focusedTabId = response.tabId;
                        })
            
                        window.setTimeout(
                            $A.getCallback(function() {
                                workspaceAPI.closeTab({tabId: focusedTabId});
                            }), 1000
                        );

                        window.setTimeout(
                            $A.getCallback(function() {
                                $A.get('e.force:refreshView').fire();
                            }), 3000
                        );
                    }
                    
                    
                }
                else if (state === "ERROR") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Error",
                        "title": "Error!",
                        "message": "Something Went Wrong"
                    });
                    toastEvent.fire();
                    console.log('error', response.getError());
                }
            });
            $A.enqueueAction(action);
        }

    },
    
    onRecordSuccess: function (component, event, helper) {
        var recordId = event.getParams().response;
        
        var action = component.get("c.updateCOType");
        action.setParams({
            recordId : recordId.id
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                var result = response.getReturnValue();
                console.log(result);
                if(result == 'success'){
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "Success!",
                        "message": "The record has been created successfully."
                    });
                    toastEvent.fire();

                    var saveNnew = component.get("v.isSaveNew");
                    console.log('saveNnew: ' + saveNnew);
            
                    if(saveNnew){
                        // $A.get('e.force:refreshView').fire();
                        let parentprojectId = component.get("v.parentprojectRecordId");
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef: "c:ChangeOrderRecordType",
                            componentAttributes: {
                                projectId: parentprojectId
                            }
                        });
                        evt.fire();
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({ tabId: focusedTabId });
                        })
                        .catch(function (error) {
                            console.log(error);
                        });
                    }
                    else{
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recordId.id,
                            "slideDevName": "Detail"
                        });
                        navEvt.fire();
                        component.set("v.parentRecordId", null);
            
                        var focusedTabId = '';
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            focusedTabId = response.tabId;
                        })
            
                        window.setTimeout(
                            $A.getCallback(function() {
                                workspaceAPI.closeTab({tabId: focusedTabId});
                            }), 1000
                        );
                    }
                    
                 
                    // var workspaceAPI = component.find("workspace");
                    // workspaceAPI.getFocusedTabInfo().then(function (response) {
                    //     var focusedTabId = response.tabId;
                    //     workspaceAPI.closeTab({
                    //         tabId: focusedTabId
                    //     });
                    // }).catch(function (error) {
                    //     console.log('Error', JSON.stringify(error));
                    // });
                    // setTimeout(function () {
                    //     component.set('v.isLoading', false);
                        
                    //     var url = location.href;
                    //     var baseURL = url.substring(0, url.indexOf('/', 14));
                        
                    //     var navEvt = $A.get("e.force:navigateToSObject");
                    //     navEvt.setParams({
                    //         "recordId": payload.id,
                    //         "slideDevName": "detail"
                    //     });
                    //     navEvt.fire();
                        
                        
                        
                    //     var toastEvent = $A.get("e.force:showToast");
                    //     toastEvent.setParams({
                    //         mode: 'sticky',
                    //         message: 'New Change Order created successfully',
                    //         messageTemplate: "New Change Order created successfully.",
                    //         messageTemplateData: [{
                    //             url: baseURL + '/lightning/r/buildertek__Change_Order__c/' + escape(payload.id) + '/view',
                    //             label: payload.name,
                    //         }],
                    //         type: 'success',
                    //         duration: '10000',
                    //         mode: 'dismissible'
                    //     });
                    //     toastEvent.fire();
                        
                        
                    // }, 2000);
                    
                    // $A.get("e.force:closeQuickAction").fire();
                    
                    
                    
                }else{
                    component.set('v.isLoading', false); 
                }
            }else{
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
        
        
        
    },
    
    vendorChanged : function(component, event, helper) {
        debugger;
        //  alert('qwertyuiop');
        var SelVendor = component.find("selectedVendor").get("v.value");
        
        // alert(SelVendor);
        component.set("v.salesforceSelectedV", SelVendor); 
        
    },
    
    handleError: function (cmp, event, helper) {
        var error = event.getParams();
        
        // Get the error message
        var errorMessage = event.getParam("message");
        // alert('errorMessage----->'+errorMessage);
    },
    
    saveAndNew: function (component, event, helper) {
        component.set('v.isLoading', true);
        var fields =  event.getParam("listOfFields");  
        event.preventDefault(); // Prevent default submit        
        component.find('recordViewForm').submit(fields); // Submit form
        $A.get('e.force:refreshView').fire();
    },
    addNewLine:function (component, event, helper) {
        var listofCOItems=component.get("v.coLineList");
        listofCOItems.push({
            'index':listofCOItems.length,
            'Name': '',
            'buildertek__Quantity__c': '',
            'buildertek__Unit_Price__c': '',
            'buildertek__Markup__c': '',
        });
        component.set("v.coLineList" , listofCOItems);
        console.log(component.get('v.coLineList'));

    },
    removeCOLine:function (component, event, helper) {

        var currentId=event.currentTarget.dataset.id;
        console.log(currentId);
        var getList=component.get('v.coLineList');
        console.log(getList);

        getList.splice(currentId,1);
        console.log(getList);

        component.set('v.coLineList' ,getList);

        
    },
    handlesaveNnew : function(component, event, helper) {
        component.set("v.isSaveNew", true);
    },
    handleCoSubmit:function(component, event, helper) {
    },
    roundToTwoDecimals: function(component, event, helper) {
        var inputField = event.getSource();
        var value = inputField.get("v.value");
        var roundedValue = parseFloat(value).toFixed(2);
        inputField.set("v.value", roundedValue);
    }
})