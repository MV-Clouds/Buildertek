({
	doInit : function(component, event, helper) {
	    component.set("v.isOpen", true);
	    var value = helper.getParameterByName(component , event, 'inContextOfRef');
    	var context = '';
    	var parentRecordId = '';
        var recordId = component.get('v.recordId');
    	component.set("v.parentRecordId",parentRecordId);
    	if(value != null){
    		context = JSON.parse(window.atob(value));
    		parentRecordId = context.attributes.recordId;
            console.log('record id --> ',parentRecordId);
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
        // component.find('quantityId').set("v.value", 1);
        var temp = component.get("v.parentRecordId");
        console.log('temp --> ',temp);

		helper.fetchpricebooks(component, event, helper);

        //helper.fetchfields(component, event, helper);

        var action = component.get("c.getFieldSet");
        action.setParams({
            objectName: 'buildertek__Quote_Item__c',
            fieldSetName: 'buildertek__BT_Detail_Page_Fields'
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields0 = JSON.parse(response.getReturnValue());
                console.log(listOfFields0);
                component.set("v.listOfFields0", listOfFields0);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);

	},

    handleSubmit : function(component, event, helper) {
        console.log('handleSubmit');
        event.preventDefault();  
        var fields = event.getParam('fields');
        //fields['buildertek__Product__c'] = component.get("v.productId");
        console.log('fields: ' + JSON.stringify(fields));
        var data = JSON.stringify(fields);
        var action = component.get("c.saveRecord");
        action.setParams({
            "data": data,
            "productid": component.get("v.productId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                console.log(response.getReturnValue());
                var recordId = response.getReturnValue();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "Success!",
                    "message": "The record has been created successfully."
				});
				toastEvent.fire();
                

                // var saveAndNew = component.get("v.saveAndNew");
                // if (saveAndNew) {
                //     $A.get('e.force:refreshView').fire();
                //     component.set("v.saveAndNew", false);
                //     console.log('saveAndNew');
                // } else{
                //     console.log('saveAndClose');
                //     var navEvt = $A.get("e.force:navigateToSObject");
                //     navEvt.setParams({
                //         "recordId": recordId,
                //         "slideDevName": "detail"
                //     });
                //     navEvt.fire();

                //     var workspaceAPI = component.find("workspace");
                //     workspaceAPI.getFocusedTabInfo().then(function(response) {
                //         var focusedTabId = response.tabId;
                //         workspaceAPI.closeTab({tabId: focusedTabId});
                //     })
                // }

                var saveNnew = component.get("v.isSaveNew");
                console.log('saveNnew: ' + saveNnew);

                if(saveNnew){
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    console.log('saveAndClose');
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                
                    component.set("v.parentRecordId", null);

                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
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
        


    },

    handlesaveNnew : function(component, event, helper) {
        component.set("v.isSaveNew", true);
    },

    saveNnew : function(component, event, helper) {
        component.set("v.saveAndNew", true);
        console.log('saveNnew');
    },
    
	// handleComponentEvent : function(component, event, helper) {
	//     var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	//     component.set("v.newQuoteItem.Name",selectedAccountGetFromEvent.Name);
	//     component.set("v.newQuoteItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	//     component.set("v.productId", selectedAccountGetFromEvent.Id);
	// 	component.set("v.productName", selectedAccountGetFromEvent.Name);
    //     console.log('productId ==> '+selectedAccountGetFromEvent.Id);
	//     helper.getProductDetails(component, event, helper);
    //     //alert('test');
    // },
    // ClearhandleComponentEvent: function (component, event, helper) {
        
    // },
    handleComponentEvents : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newQuoteItem.Name",selectedAccountGetFromEvent.Name);
	    component.set("v.newQuoteItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
        //alert('test handler');
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
            window.history.back();
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
        var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedGroup = component.get("v.selectedGroup");
        var quotelinegroup;
        if(selectedGroup != undefined){
            quotelinegroup = selectedGroup.Id;
        }else{
            quotelinegroup = null;
        }
        
        var selectedPo = component.get("v.selectedPORecord");
        var Porec;
        if(selectedPo != undefined){
            Porec = selectedPo.Id;
        }else{
            Porec = null;
        } 
        var selectedQuote = component.get("v.selectedQuoteRecord");
        var parentRecordId = component.get("v.parentRecordId");
        var selectedQuoteRecordId;
        if(parentRecordId != undefined){
            selectedQuoteRecordId =  parentRecordId;   
        }else{
            if(selectedQuote != undefined){
                selectedQuoteRecordId = selectedQuote.Id;    
            }
        }
        component.set("v.newQuoteItem.buildertek__Purchase_Order__c", Porec);
      //  component.set("v.newPOItem.buildertek__Quote__c", liabilityGLAccount);
        component.set("v.newQuoteItem.buildertek__Grouping__c", quotelinegroup);
        component.set("v.newQuoteItem.buildertek__Cost_Code__c", costcode);
        //component.set("v.newPOItem.buildertek__Purchase_Order__c", PO);
        var QuoteLineToInsert = JSON.stringify(component.get("v.newQuoteItem"));
        var QuoteLineName=component.get("v.newQuoteItem.Name");
        //alert(QuoteLineName);
        if(selectedQuoteRecordId != undefined){
            if(QuoteLineName==undefined){
                //alert('test');
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Please Provide a Product Description.',
                        type : 'error',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            }else{
            var action = component.get("c.saveQuotelineItem");
            action.setParams({
                QuoteLines : QuoteLineToInsert,
                QuoteId : selectedQuoteRecordId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                     component.set("v.Spinner", true);
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var result = response.getReturnValue();
                    $A.get("e.force:closeQuickAction").fire();
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                         workspaceAPI.closeTab({tabId: focusedTabId});
                         //$A.get('e.force:refreshView').fire();
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Quote Line was created ',
                        messageTemplate: "Quote Line {0} was created",
                        messageTemplateData: [{
                        url: baseURL+'/lightning/r/buildertek__Quote_Item__c/'+escape(result.Id)+'/view',
                        label: result.Name,
                        }],
                        type : 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set("v.Spinner", false);
                    
                    window.open ("/"+result.Id,"_Self");     
                }
            });
            $A.enqueueAction(action);   
            }
        }else{
            var pillTarget = component.find("errorId"); 
            $A.util.addClass(pillTarget, 'showErrorMessage');    
        }
        
   },
   saveAndNew : function(component, event, helper) {
       //component.set("v.Spinner", true);
          var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedGroup = component.get("v.selectedGroup");
        var quotelinegroup;
        if(selectedGroup != undefined){
            quotelinegroup = selectedGroup.Id;
        }else{
            quotelinegroup = null;
        }
        
        var selectedPo = component.get("v.selectedPORecord");
        var Porec;
        if(selectedPo != undefined){
            Porec = selectedPo.Id;
        }else{
            Porec = null;
        } 
        var selectedQuote = component.get("v.selectedQuoteRecord");
        var parentRecordId = component.get("v.parentRecordId");
        var selectedQuoteRecordId;
        if(parentRecordId != undefined){
            selectedQuoteRecordId =  parentRecordId;   
        }else{
            if(selectedQuote != undefined){
                selectedQuoteRecordId = selectedQuote.Id;    
            }
        }
      
        component.set("v.newQuoteItem.buildertek__Grouping__c", quotelinegroup);
        component.set("v.newQuoteItem.buildertek__Quote__c", selectedQuoteRecordId);
        component.set("v.newQuoteItem.buildertek__Cost_Code__c", costcode);
        component.set("v.newQuoteItem.buildertek__Purchase_Order__c", Porec);
        var QuoteLineToInsert = JSON.stringify(component.get("v.newQuoteItem"));
        var QuoteLineName=component.get("v.newQuoteItem.Name");
        if(selectedQuoteRecordId != undefined){
            if(QuoteLineName==undefined){
                //alert('test');
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Please Provide a Product Description.',
                        type : 'error',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            }else{
        var action = component.get("c.saveQuotelineItem");
        action.setParams({
            QuoteLines : QuoteLineToInsert,
                QuoteId : selectedQuoteRecordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var result = response.getReturnValue();
                component.set("v.newQuoteItem", null); 
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Quote Line was created',
                    messageTemplate: "Quote Line {0} was created",
                    messageTemplateData: [{
                    url: baseURL+'/lightning/r/buildertek__Quote_Item__c/'+escape(result.Id)+'/view',
                    label: result.Name,
                    }],
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.Spinner", false);
                window.location.reload(true);
            }
        });
        $A.enqueueAction(action);  
            }
            }else{
            var pillTarget = component.find("errorId"); 
            $A.util.addClass(pillTarget, 'showErrorMessage');    
        }
   },
     changefamily : function(component, event, helper) {
        
        var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({"recordByEvent" : product });  
                compEvent.fire();
       component.set('v.newQuoteItem.Name', '');
       component.set('v.newQuoteItem.buildertek__Unit_Price__c', '');
        component.set('v.newQuoteItem.buildertek__Unit_Cost__c', '');
        component.set('v.newQuoteItem.buildertek__Markup__c', '');
         
        
    },
    changeEvent: function(component, event, helper) {
         
                var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({"recordByEvent" : product });  
                compEvent.fire();
              // component.set('v.newQuote.Name', '');
              //  component.set('v.newQuote.buildertek__Grouping__c', null);
               // component.set('v.newQuote.buildertek__UOM__c', '');
               // component.set('v.newQuote.buildertek__Unit_Cost__c', '');
               // component.set('v.newQuote.buildertek__Quantity__c', 1);
              //  component.set('v.newQuote.buildertek__Markup__c', ''); 
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

    handlefieldChange : function(component, event, helper) {
        console.log('handlefieldChange');
        var productId = component.get("v.productId");
        console.log('productId ==> '+productId);
    },


    saveAndNewLine : function(component, event, helper) {
        component.set("v.saveAndNew", true);

        event.preventDefault();  
        var fields = component.find('newQuoteLine').submit(fields); 
        fields = event.getParam('fields');

        console.log('fields: ' + JSON.stringify(fields));
        var data = JSON.stringify(fields);
        var action = component.get("c.saveRecord");
        action.setParams({
            "data": data,
            "productid": component.get("v.productId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                console.log(response.getReturnValue());
                var recordId = response.getReturnValue();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "Success!",
                    "message": "The record has been created successfully."
				});
				toastEvent.fire();
                

                var saveAndNew = component.set("v.saveAndNew");
                if (saveAndNew) {
                    window.location.reload();
                } else{
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();

                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
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

    },

})