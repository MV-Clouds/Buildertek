({
    doInit: function (component, event, helper) {

        
        var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                
                if(result.userRecord != null){
                   if(result.userRecord.IsPortalEnabled == true){
                    
                 
                        component.set('v.isopen',false);
                        component.set('v.ischangeorder',true);
                        component.set('v.isproduct',false);
                        component.set('v.ischangeorderline',true);
                        var listofchange = component.get("v.listOfFields");
                        var collist = [];
                        if(component.get('v.ischangeorderline') == true){
                            for (var i = 0; i < listofchange.length; i++) {
                                if(listofchange[i].name != 'buildertek__Product__c'){
                                    collist.push(listofchange[i]);
                                }
                            }
                            component.set("v.listOfFields",collist);
                        }
                    
                  
                }else{
                    debugger;
                    /* component.set('v.isopen',true); 
                    component.set('v.ischangeorderline',false);
                    component.set('v.isproduct',false);
                    component.set('v.ischangeorder',false); */
                    helper.getResponseFromCustomSettings(component, event, helper);
                } 
            }else{
                debugger
                component.set('v.isopen',true); 
                component.set('v.ischangeorderline',false);
                component.set('v.isproduct',false);
                component.set('v.ischangeorder',false); 
                helper.getResponseFromCustomSettings(component, event, helper);
            }
                
                
            }
        });
        $A.enqueueAction(action);
        
        
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
            else if(parentRecordId == 'list'){
                parentRecordId = null
            }
            component.set("v.parentRecordId", parentRecordId);
            
        }
        helper.getFields(component, event, helper);
         helper.fetchpricebooks(component, event, helper);
      

        
        
        //helper.vendors(component,event,helper);
    },
    
        handleComponentEvent: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.newPOItem.Name", selectedAccountGetFromEvent.Name);
        component.set("v.newPOItem.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        component.set("v.UnitCost",selectedAccountGetFromEvent.buildertek__Unit_Price__c );
        helper.getProductDetails(component, event, helper);
    },

    handleComponentEvents: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.newPOItem.Name", selectedAccountGetFromEvent.Name);
        component.set("v.newPOItem.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        component.set("v.UnitCost",selectedAccountGetFromEvent.buildertek__Unit_Price__c );
        helper.getProductDetails(component, event, helper);
    },

    closeModel: function (component, event, helper) {
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
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
    },
    
    changeEvent: function (component, event, helper) {

        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();

        var pribooknames = component.get("v.pricebookName");
        var action = component.get("c.getProductfamilyRecords");
        // set param to method  
        action.setParams({
            'ObjectName': "Product2",
            'parentId': component.get("v.pricebookName")
        });
        // set a callBack    
        action.setCallback(this, function (response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
           // alert(state);
            if (state === "SUCCESS") {
                // helper.fetchPickListVal(component, event, helper);
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listofproductfamily", storeResponse);

                if (component.get("v.listofproductfamily").length > 0) {
                    component.set("v.productfamily", component.get("v.listofproductfamily")[0].productfamilyvalues);
                }

            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },

    handleSubmit: function (component, event, helper) {
        //alert("hai");
       // helper.validateRecordData(component, event, helper);
        component.set('v.isLoading', true);
        var fields = event.getParam("fields");
       // alert(JSON.stringify(fields));
        // var name = component.find("Name").get("v.value");
        var selectedProductId = component.get('v.selectedLookUpRecord');
        if (selectedProductId != undefined && selectedProductId.Id != undefined) {
            if(fields.buildertek__Product__c == undefined){
                fields.buildertek__Product__c='';
            }
            fields.buildertek__Product__c = selectedProductId.Id;
          //  fields.buildertek__Unit_Price__c = selectedProductId.buildertek__Unit_Price__c;
            if(fields.Name.length > 80){
                fields.Name = fields.Name.substring(0,80);
            }
        }
        event.preventDefault(); // Prevent default submit
       // var isValid  = helper.validateRecordData(component, event, helper);
      //  if(isValid)
      //  {
            component.find('recordViewForm').submit(fields); // Submit form
       // }
        //component.find('recordViewForm').submit(fields); // Submit form
    },

    onRecordSuccess: function (component, event, helper) {
        
      //  alert('onRecordSuccess===');
        var buttonName = component.get('v.buttonTypeName');
        event.preventDefault();
        //helper.validateRecordData(component, event, helper);
       
        if (buttonName == 'saveButton') {
        //    alert("haiiiiii");
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                console.log('tabId',{focusedTabId});
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            }).catch(function (error) {
                console.log('Error', JSON.stringify(error));
            });
            setTimeout(function () {
                component.set('v.isLoading', false);
                var payload = event.getParams().response;
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Change Order Line created successfully',
                    messageTemplate: "Change Order Line created successfully.",
                    messageTemplateData: [{
                        url: baseURL + '/lightning/r/buildertek__Change_Order_Item__c/' + escape(payload.id) + '/view',
                        label: payload.name,
                    }],
                    type: 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();

                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": payload.id,
                    "slideDevName": "related"
                });
                navEvt.fire();
            }, 100);
            component.set('v.isLoading', false);
             $A.get('e.force:closeQuickAction').fire();
        }

        if (buttonName == 'saveAndNewButton'){
               var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Change Order Line created successfully',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
            helper.resetComponent(component, event, helper);
        }
    },

    handleOnError: function (component, event, helper){
        component.set('v.isLoading', false);
        var errorMessage = event.getParam("message");
        console.log('errorMessage'+errorMessage);
        helper.showToast(component, event, helper,'Error',errorMessage,'error');
    },

    saveAndNew: function (component, event, helper) {
          var Name1 = component.get("v.lineName");
          var Name2 = component.get("v.PdtName");
     //   var Name = component.find("itemName").get("v.value");
    
      //  console.log("Name = ",Name);
       
      //  console.log("Name : ",component.get("v.lineName"));
        if(Name1 != null || Name2 != null ){
        component.set('v.isLoading', true);
        event.preventDefault(); // Prevent default submit
        var buttonName = event.getSource().getLocalId();
        component.set('v.buttonTypeName',buttonName);
        var fields = event.getParam("listOfFields");
        component.find('recordViewForm').submit(fields); // Submit form*/
         } else{
                  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'Please Enter The Line Item Name.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
             }
        //$A.get('e.force:refreshView').fire();
    },
    
       unitCost: function (component, event, helper) {
        console.log(event.getSource().get("v.value"));
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
    Yes : function (component, event, helper) {
        component.set('v.isopen',false);
        component.set('v.ischangeorder',true);
        component.set('v.ischangeorderline',false);
        component.set('v.isproduct',true);
    },
    No : function (component, event, helper) {
        component.set('v.isopen',false);
        component.set('v.ischangeorder',true);
        component.set('v.isproduct',false);
        component.set('v.ischangeorderline',true);
        var listofchange = component.get("v.listOfFields");
        var collist = [];
        if(component.get('v.ischangeorderline') == true){
            for (var i = 0; i < listofchange.length; i++) {
                if(listofchange[i].name != 'buildertek__Product__c'){
                    collist.push(listofchange[i]);
                }
            }
            component.set("v.listOfFields",collist);
        }
    },
    onSaveAction : function(component, event, helper) {
        var buttonName = event.getSource().getLocalId();
        component.set('v.buttonTypeName',buttonName);
        var fields = event.getParam("listOfFields");
       // alert( JSON.stringify(fields));
        component.find('recordViewForm').submit(fields); // Submit form
    }
    
})