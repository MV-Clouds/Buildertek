({
	doInit : function(component, event, helper) {
	    component.set("v.isOpen", true);
          var value = helper.getParameterByName(component , event, 'inContextOfRef');
    	var context = '';
    	var parentRecordId = '';
    	component.set("v.parentRecordId",parentRecordId);
    	if(value != null){
    		context = JSON.parse(window.atob(value));
    		parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId",parentRecordId);
		}else{
		    var relatedList = window.location.pathname;
		    var stringList = relatedList.split("/"); 
           // alert('stringList---'+stringList);
		    parentRecordId = stringList[4];
            if(parentRecordId == 'related'){
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
		    component.set("v.parentRecordId",parentRecordId);
		}
        if(parentRecordId != null && parentRecordId != ''){
                var action = component.get("c.getobjectName");
                action.setParams({
                    recordId: parentRecordId,
                });
                action.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        var objName = response.getReturnValue();
                        if(objName == 'buildertek__Trade_Type__c'){
                            component.set("v.selectedTradeType", parentRecordId);
                        }/*else if(objName == 'buildertek__Quote_Line_Group__c'){
                        }else if(objName == 'Product2'){
                            component.set("v.selectedTradeType", parentRecordId);
                        }*/else if(objName == 'buildertek__Cost_Codes__c'){
                            component.set("v.selectedCostCode", parentRecordId);
                        }/*else if(objName == 'buildertek__Budget_Line_Sub_Group__c'){
                            component.set("v.selectedTradeType", parentRecordId);
                        }*/else if(objName == 'buildertek__Budget_Line_Group__c'){
                            component.set("v.selectedGroup", parentRecordId);
                        }else if(objName == 'Account'){
                            component.set("v.selectedAccount", parentRecordId);
                        }else if(objName == 'buildertek__Budget__c'){
                            component.set("v.budgetID", parentRecordId);
                        }
                    } 
                });
                $A.enqueueAction(action);
        }        
        /* component.find('quantityId').set("v.value", 1);
        alert('parent-------'+ parentRecordId);
        component.find('MBId').set("v.value", parentRecordId); */
        
        var action2 = component.get("c.getFieldSet");
        action2.setParams({
            objectName: 'buildertek__Budget_Item__c',
            fieldSetName: 'buildertek__BT_Detail_Page_Fields'
        });
        action2.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields0 = JSON.parse(response.getReturnValue());
                console.log({listOfFields0});
                component.set("v.listOfFields0", listOfFields0);
            }
        });
        $A.enqueueAction(action2);

        var action3 = component.get("c.getPriceBookNames");
        action3.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var priceBookNames = response.getReturnValue();
                console.log({priceBookNames});
                component.set("v.priceBookNames", priceBookNames);
            }
        });
        $A.enqueueAction(action3);

        helper.fetchpricebooks(component, event, helper);
        //component.find('MBId').set("v.value", parentRecordId);
    }, 

	handleComponentEvent : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newBudgetItem.buildertek__Item_Name__c",selectedAccountGetFromEvent.Name);
	    component.set("v.newBudgetItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },

    handleComponentEvents : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        //alert(selectedAccountGetFromEvent);
	    component.set("v.newBudgetItem.buildertek__Item_Name__c",selectedAccountGetFromEvent.Name);
	    component.set("v.newBudgetItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },

	closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
          var workspaceAPI = component.find("workspace");
          workspaceAPI.getFocusedTabInfo().then(function(response) {
              var focusedTabId = response.tabId;
              workspaceAPI.closeTab({tabId: focusedTabId});
          })
          .catch(function(error) {
              console.log(error);
          });
          $A.get("e.force:closeQuickAction").fire();
          component.set("v.isOpen", false);
          window.setTimeout(
              $A.getCallback(function() {
                  $A.get('e.force:refreshView').fire();
              }), 1000
          );
     },

   save : function(component, event, helper) {
      // alert('test');
        var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedAccount = component.get("v.selectedAccount");
        var selAccount;
        if(selectedAccount != undefined){
            selAccount = selectedAccount.Id;
        }else{
            selAccount = null;
        }
        var selectedTradeType = component.get("v.selectedTradeType");
        var selTradeType;
        if(selectedTradeType != undefined){
            selTradeType = selectedTradeType.Id;    
        }else{
            selTradeType = null;
        }
        var selectedGroup = component.get("v.selectedGroup");
        var selGroup;
        if(selectedGroup != undefined){
            selGroup = selectedGroup.Id;
        }else{
            selGroup = null;
        }
        var selectedBudget = component.get("v.selectedBudget");
        var parentRecordId = component.get("v.budgetID");
        var selectedMB;
       if(parentRecordId != undefined){
           selectedMB = component.get("v.parentRecordId");
       }else{
       
          if(selectedBudget != undefined){
            selectedMB = selectedBudget.Id;
        }else{
            selectedMB = null;
        } 
      }
        
        
        component.set("v.newBudgetItem.buildertek__Contractor__c", selAccount);
        component.set("v.newBudgetItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newBudgetItem.buildertek__Group__c", selGroup);
        component.set("v.newBudgetItem.buildertek__Cost_Code__c", costcode);
        //component.set("v.newBudgetItem.buildertek__Budget__c", selectedMB);
        var MBLineToInsert = JSON.stringify(component.get("v.newBudgetItem"));
        if(selectedMB != undefined){
           // alert('test2--'); 
            component.set("v.Spinner", true);
            var action = component.get("c.saveMBItem");
            action.setParams({
                MBLines : MBLineToInsert,
                MBId : selectedMB
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                     component.set("v.Spinner", false);
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var result = response.getReturnValue();
                    $A.get("e.force:closeQuickAction").fire();
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                         workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: ' Budget Line was created ',
                        messageTemplate: " Budget Line {0} was created",
                     /*   messageTemplateData: [{
                        url: baseURL+'/lightning/r/buildertek__Budget_Item__c/'+escape(result.Id)+'/view',
                        label: result.Name,
                        }],*/
                        type : 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    
                      var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                          "recordId": result.Id,
                          "slideDevName": "related"
                        });
                        navEvt.fire();
                   // window.open ("/"+result.Id,"_Self");     
                }
            });
            $A.enqueueAction(action);    
        }else{
            var pillTarget = component.find("errorId"); 
            $A.util.addClass(pillTarget, 'showErrorMessage');    
        }
        
   },
   saveAndNew : function(component, event, helper) {
        component.set("v.Spinner", true);
        var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedAccount = component.get("v.selectedAccount");
        var selAccount;
        if(selectedAccount != undefined){
            selAccount = selectedAccount.Id;
        }else{
            selAccount = null;
        }
        var selectedTradeType = component.get("v.selectedTradeType");
        var selTradeType;
        if(selectedTradeType != undefined){
            selTradeType = selectedTradeType.Id;    
        }else{
            selTradeType = null;
        }
        var selectedGroup = component.get("v.selectedGroup");
        var selGroup;
        if(selectedGroup != undefined){
            selGroup = selectedGroup.Id;
        }else{
            selGroup = null;
        }
       var selectedBudget = component.get("v.selectedBudget");
        var parentRecordId = component.get("v.budgetID");
        var selectedMB;
       if(parentRecordId != undefined){
           selectedMB = component.get("v.parentRecordId");
       }else{
          if(selectedBudget != undefined){
            selectedMB = selectedBudget.Id;
        }else{
            selectedMB = null;
        } 
       }
        component.set("v.newBudgetItem.buildertek__Contractor__c", selAccount);
        component.set("v.newBudgetItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newBudgetItem.buildertek__Group__c", selGroup);
        component.set("v.newBudgetItem.buildertek__Cost_Code__c", costcode);
        //component.set("v.newBudgetItem.buildertek__Budget__c", selectedMB);
        var MBLineToInsert = JSON.stringify(component.get("v.newBudgetItem"));
        if(selectedMB != undefined){
            var action = component.get("c.saveMBItem");
            action.setParams({
                MBLines : MBLineToInsert,
                MBId : selectedMB
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var result = response.getReturnValue();
                    component.set("v.newBudgetItem", null); 
                    component.set("v.Spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: ' Budget Line was created',
                        messageTemplate: " Budget Line {0} was created",
                        messageTemplateData: [{
                        url: baseURL+'/lightning/r/buildertek__Budget_Item__c/'+escape(result.Id)+'/view',
                        label: result.Name,
                        }], 
                        type : 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                          "recordId": result.Id,
                          "slideDevName": "related"
                        });
                        navEvt.fire();
                    window.location.reload(true);
                }
            });
            $A.enqueueAction(action);    
        }
            
   },

    changefamily : function(component, event, helper) {
        
        var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({"recordByEvent" : product });  
                compEvent.fire();
                component.set('v.newBudgetItem.buildertek__Item_Name__c', '');
                component.set('v.newBudgetItem.buildertek__Unit_Price__c', '');  
        
    },
    changeEvent: function(component, event, helper) {

        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({"recordByEvent" : product });  
        compEvent.fire();

        var pribooknames = component.get("v.pricebookName");
        var action = component.get("c.getProductfamilyRecords");
      // set param to method  
        action.setParams({ 
            'ObjectName' : "Product2",
            'parentId' : component.get("v.pricebookName")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
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
                
                if(component.get("v.listofproductfamily").length >0){
                 component.set("v.productfamily",component.get("v.listofproductfamily")[0].productfamilyvalues);
                }
                 
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    }, 

    
    closeModel: function (component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.isOpen", false);
        window.setTimeout(
            $A.getCallback(function() {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );

    },

    handleSubmit: function (component, event, helper) {
        component.set("v.isDisabled", true);
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();

            event.preventDefault(); // Prevent default submit
            var fields = event.getParam("fields");
            var productId = component.get("v.productId");
            if (productId == null || productId == undefined) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Please select Product!!',
                    duration: '3000',
                    type: 'error'
                });
                toastEvent.fire();
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            }else {
                // var workspaceAPI = component.find("workspace");
                // workspaceAPI.getFocusedTabInfo().then(function(response) {
                //     var focusedTabId = response.tabId;
                //     workspaceAPI.closeTab({tabId: focusedTabId});
                // })
                // .catch(function(error) {
                //     console.log(error);
                // });
                // $A.get("e.force:closeQuickAction").fire();

                var allData = JSON.stringify(fields);
                var action = component.get("c.saveData");
                action.setParams({
                    productId : productId,
                    allData : allData
                });

                action.setCallback(this, function(response){
                    if (response.getState() == 'SUCCESS') {
                        var result = response.getReturnValue();

                        $A.get("e.force:closeQuickAction").fire();
                        window.setTimeout(
                            $A.getCallback(function() {
                                $A.get('e.force:refreshView').fire();
                            }), 1000
                        );

                        console.log({result});

                        var saveNnew = component.get("v.isSaveNew");

                        if(saveNnew){
                            $A.get('e.force:refreshView').fire();
                            component.set("v.isSaveNew", false);
                        }
                        else{
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": result,
                                "slideDevName": "Detail"
                            });
                            navEvt.fire();
                            debugger
                            var workspaceAPI = component.find("workspace");
                            workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                        }

                        // var navEvt = $A.get("e.force:navigateToSObject");
                        // navEvt.setParams({
                        //     "recordId": result,
                        //     "slideDevName": "Detail"
                        // });
                        // navEvt.fire();

                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Success',
                            message: 'Budget Line created successfully.',
                            duration: ' 5000',
                            type: 'success'
                        });
                        toastEvent.fire();
                        // $A.get('e.force:refreshView').fire();
                        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();

                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: 'Something went wrong',
                            duration: ' 5000',
                            type: 'error'
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
            }
    },

    handlesaveNnew : function(component, event, helper) {
        component.set("v.isSaveNew", true);
    },

    handelsaveAndNew: function (component, event, helper) {
        component.set("v.isDisabled", true);
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
            var fields = event.getParam("fields");
            var productId = component.get("v.productId");
            var allData = JSON.stringify(fields);
            

            var action = component.get("c.saveData");
            
            action.setParams({
                productId : productId,
                allData : allData
            });

            action.setCallback(this, function(response){
                if (response.getState() == 'SUCCESS') {
                    var result = response.getReturnValue();

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'BudgetLine created successfully.',
                        duration: ' 5000',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();

                }else{
                    var error = response.getError();
                    console.log('Error --> ', {error});
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'Something went wrong',
                        duration: ' 5000',
                        type: 'error'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
    },

    handelProductChange: function (component, event, helper) {
        debugger;
        var productId = component.get('v.productId');
        var pricebookName = component.get('v.pricebookName');

        var action = component.get("c.getProductComponentValues");
        action.setParams({
            "productId": productId,
            "PriceBookName":pricebookName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                component.set('v.BudgetLineName', result.BudgetLineName);
                // component.set('v.SalesPrice', result.UnitPrice);
                // component.set('v.UnitCost', result.buildertek__Unit_Cost__c);
            }
        }
        );
        $A.enqueueAction(action);
    },

    getProductDetailValues: function (component, event, helper) {
        debugger;
        var productId = component.get('v.productId');
        // get pricebook id
        var pricebookId = component.get("c.getPriceBookId");
        console.log('pricebookId', pricebookId);
        console.log('productId', productId);
    },


        





    // onRecordSuccess: function (component, event, helper) {
    //     var payload = event.getParams().response;
    //     var expenseId = (payload.id).replace('"', '').replace('"', '');
    //     var workspaceAPI = component.find("workspace");
    //     workspaceAPI.getFocusedTabInfo().then(function (response) {
    //         var focusedTabId = response.tabId;
    //         workspaceAPI.closeTab({
    //             tabId: focusedTabId
    //         });
    //     }).catch(function (error) {
    //         console.log('Error', JSON.stringify(error));
    //     });
    //     $A.get('e.force:refreshView').fire();
    //     setTimeout(function () {
    //         component.set('v.isLoading', false);
    //         var url = location.href;
    //         var baseURL = url.substring(0, url.indexOf('/', 14));
    //         var toastEvent = $A.get("e.force:showToast");
    //         toastEvent.setParams({
    //             mode: 'sticky',
    //             message: 'Meeting created successfully',
    //             messageTemplate: "Meeting created successfully.",
    //             messageTemplateData: [{
    //                 url: baseURL + '/lightning/r/buildertek__Meeting__c/' + escape(payload.id) + '/view',
    //                 label: payload.name,
    //             }],
    //             type: 'success',
    //             duration: '10000',
    //             mode: 'dismissible'
    //         });
    //         toastEvent.fire();
    //         var navEvt = $A.get("e.force:navigateToSObject");
    //         navEvt.setParams({
    //             "recordId": payload.id,
    //             "slideDevName": "related"
    //         });
    //         navEvt.fire();
    //     }, 200);

    // },

    // handleError: function (component, event, helper) {
    //     var error = event.getParam("error");
    //     console.error(JSON.stringify(error));

    // }



})