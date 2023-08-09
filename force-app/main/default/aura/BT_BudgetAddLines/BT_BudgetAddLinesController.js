({
    doInit: function (component, event, helper) {
        
        
        console.log(component.get('v.recordId') , '{{{{{{RECORD ID}}}}}}}');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
            tabId: opendTab,
            label: "Budget Add Lines"
        });
        workspaceAPI.setTabIcon({
            tabId: opendTab,
            icon: 'custom:custom5',
            iconAlt: 'Budget Add Lines'
        });
    });
        
    component.set('v.isLoading', true);
       var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        helper.fetchpricebooks(component, event, helper);
       //helper.getTableFieldSet(component, event, helper);
        window.setTimeout(
            $A.getCallback(function () {
                //helper.getQuoteName(component, event, helper);
               // helper.getTotalRecord(component, event, helper);
                helper.getTableRows(component, event, helper, pageNumber, pageSize);
                component.set('v.isLoading', false);
                component.set("v.listofproductfamily", '');
                var list = component.get('v.listOfRecords');
                var obj = {
                    "productfamily": '',
                    "pricebookName" : '',
                    "product": {
                        "Id":'',
                        "Name":''
                    },
                    "newBudgetLine" : {},
                    "UOMvalues" : '',
                    "Vendor" : {},
                };
                // list.unshift(obj);
                for(var i=0;i<5;i++){
                    list.push(obj);
                }
                component.set('v.listOfRecords', list);
                
            }), 1000
        );
        
        
    },

    onAddClick: function (component, event, helper) {
        var fields = component.get('v.fieldSetValues');
        var list = component.get('v.listOfRecords');
        var obj = {};
        var obj = {
            "productfamily": '',
            "pricebookName" : '',
            "product": {
                "Id":'',
                "Name":''
            },
            "newBudgetLine" : {},
            "UOMvalues" : '',
            "Vendor" : {},
        };
       /* for (var i in fields) {
            obj[fields[i].name] = '';
        }*/
        // list.push(obj);
        for (var i = 0; i < 5; i++) {
            list.push(obj);
        }
        component.set('v.listOfRecords', list);
       // helper.fetchpricebooks(component, event, helper);
    },

    onMassUpdate: function (component, event, helper) {
        component.set('v.isLoading', true);
       /* if (!component.get('v.massUpdateEnable')) {
            component.set('v.massUpdateEnable', true);
            component.set('v.isLoading', false);
        } else if (component.get('v.massUpdateEnable')) {
            component.set('v.isLoading', true);
            component.set('v.massUpdateEnable', false);
            helper.updateMassRecords(component, event, helper);
        }*/
        component.set('v.isLoading', true);
        //component.set('v.massUpdateEnable', false);
        helper.updateMassRecords(component, event, helper);
    },

    onMassUpdateCancel: function (component, event, helper) {
        //if (component.get('v.massUpdateEnable')) {
           // component.set('v.isCancelModalOpen', true);
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
            .catch(function (error) {
                console.log(error);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "related"
                });
                navEvt.fire();
            });
            $A.get("e.force:closeQuickAction").fire();
            window.setTimeout(
                $A.getCallback(function () {
                    $A.get('e.force:refreshView').fire();
                }), 1000
            );
        //}
    },
    clearLookupValue: function (component, event, helper) {
		var childCmp = component.find("tradeTypeId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("accountId");
		var retnMsg = childCmp.clearLookup();
	},
    	changeEvent: function (component, event, helper) {
		/*var group = component.find('groupId');
		group.set("v._text_value", '');*/
		var product = component.get('v.selectedLookUpRecord');
		var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
		compEvent.setParams({
			"recordByEvent": product
		});
		compEvent.fire();
		component.set('v.newBudgetLine.Name', '');
		component.set('v.selectedContractor', null);
		component.set('v.newBudgetLine.buildertek__Group__c', null);
		component.set('v.newBudgetLine.buildertek__Sub_Grouping__c', null);
		component.set('v.options', '');
		component.set('v.newBudgetLine.buildertek__Sales_Price__c', '');
		component.set('v.newBudgetLine.buildertek__Unit_Price__c', '');
		component.set('v.newBudgetLine.buildertek__Quantity__c', '1');
		$A.enqueueAction(component.get("c.clearLookupValue"));
		/*$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "HIDE"
		}).fire();*/
        
		//$A.get('e.force:refreshView').fire();

		var action = component.get("c.getProductfamilyRecords");
		var pribooknames = component.get("v.pricebookName");
		// set param to method  
		action.setParams({
			'ObjectName': "Product2",
			'parentId': component.get("v.pricebookName")
		});
		// set a callBack    
		action.setCallback(this, function (response) {
			$A.util.removeClass(component.find("mySpinner"), "slds-show");
			var state = response.getState();
			if (state === "SUCCESS") {
				helper.fetchPickListVal(component, event, helper);
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
    changefamily: function (component, event, helper) {
		var product = component.get('v.selectedLookUpRecord');
		var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
		compEvent.setParams({
			"recordByEvent": product
		});
		compEvent.fire();
		component.set('v.newBudgetLine.Name', '');
		component.set('v.newBudgetLine.buildertek__Unit_Price__c', '');
		component.set('v.newBudgetLine.buildertek__Sales_Price__c', '');
	},

    handleComponentEvent: function (component, event, helper) {
		// get the selected Account record from the COMPONETN event 	 
		var selectedAccountGetFromEvent = event.getParam("recordByEvent");
		component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
		helper.getProductDetails(component, event, helper);
        helper.getUOMValues(component, event, helper);
	},

    handleChildBudgetLineEvent : function (component, event, helper) {
        console.log('handleChildBudgetLineEvent');
        var isdelete = JSON.parse(JSON.stringify(event.getParam("isdelete")));
        if(!isdelete){
            var valueFromChild = JSON.parse(JSON.stringify(event.getParam("message")));
            
            var listRecord = component.get("v.DuplistOfRecords");
            if(listRecord.length){
                if(listRecord[valueFromChild.index]){
                    listRecord[valueFromChild.index] = valueFromChild;
                }else{
                    listRecord.push(valueFromChild);
                }
            }else{
                listRecord.push(valueFromChild)
            }
        }else if(isdelete){
            var valueFromChild = JSON.parse(JSON.stringify(event.getParam("message")));
            var listRecord = component.get("v.listOfRecords");
            console.log('valueFromChild',valueFromChild);
            listRecord.splice(valueFromChild.index, 1);
            console.log('listRecord',listRecord);
            component.set("v.listOfRecords",listRecord);
            console.log('listRecord 2',component.get("v.listOfRecords"));
        }
        
        
        console.log(JSON.parse(JSON.stringify(listRecord)))
        component.set("v.DuplistOfRecords",listRecord);
        //component.set("v.enteredValue", valueFromChild);
    },
    deletequotelineRecord: function (component, event, helper) {
        var dataAttr = event.currentTarget.dataset.recordid.split("_");
        var recordid = dataAttr[0]; 
        //alert('recordid'+recordid);
        var recordList;
        if(JSON.parse(JSON.stringify(component.get("v.deleteQuoteLines"))).length){
            recordList = JSON.parse(JSON.stringify(component.get("v.deleteQuoteLines")));
        }else{
            recordList =[];
        }
        var quoteLines = component.get("v.listOfRecords");
        quoteLines.splice(Number(dataAttr[1]),1);
        if(recordid){
            recordList.push(recordid);
        }
        component.set("v.listOfRecords",quoteLines);
        component.set("v.deleteQuoteLines",recordList);
    },

   /* closeScreen: function (component, event, helper) {
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

        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.openTab({
        //     pageReference: {
        //         "type": "standard__recordPage",
        //         "attributes": {
        //             "recordId":component.get('v.recordId'),
        //             "actionName":"view"
        //         },
        //         "state": {}
        //     },
        //     focus: true
        // }).then(function(response) {
        //     workspaceAPI.getTabInfo({
        //         tabId: response
        // }).then(function(tabInfo) {
        //     console.log("The recordId for this tab is: " + tabInfo.recordId);
        // });
        // }).catch(function(error) {
        //     console.log(error);
        // });
    },

    closeCancelModal: function (component, event, helper) {
        component.set('v.isCancelModalOpen', false);
    },

    deleteRecord: function (component, event, helper) {
        var target = event.target;
        var index = target.getAttribute("data-index");
        var records = component.get('v.listOfRecords');
        if (records[index].Id != undefined) {
            component.set('v.selectedRecordIndex', index);
            component.set('v.quoteLineName', records[index].Name);
            component.set('v.isModalOpen', true);
        } else if (records[index].Id == undefined) {
            records.splice(index, 1);
            component.set('v.listOfRecords', records);
        }
    },
    deletequotelineRecord: function (component, event, helper) {*/
       /* var target = event.target;
        var index = target.getAttribute("data-index");
        var records = component.get('v.listOfRecords');
        if (records[index].Id != undefined) {
            component.set('v.selectedRecordIndex', index);
            component.set('v.quoteLineName', records[index].Name);
            component.set('v.isModalOpen', true);
        } else if (records[index].Id == undefined) {
            records.splice(index, 1);
            component.set('v.listOfRecords', records);
        }*/
       /* var dataAttr = event.currentTarget.dataset.recordid.split("_");
        var recordid = dataAttr[0]; 
        var recordList;
        if(JSON.parse(JSON.stringify(component.get("v.deleteQuoteLines"))).length){
            recordList = JSON.parse(JSON.stringify(component.get("v.deleteQuoteLines")));
        }else{
            recordList =[];
        }
        var quoteLines = component.get("v.listOfRecords");
        quoteLines.splice(Number(dataAttr[1]),1);
        if(recordid){
            recordList.push(recordid);
        }
        component.set("v.listOfRecords",quoteLines);
        component.set("v.deleteQuoteLines",recordList);
    },
    handleNext: function (component, event, helper) {
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        helper.getTableRows(component, event, helper, pageNumber, pageSize);
    },

    handlePrev: function (component, event, helper) {
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        helper.getTableRows(component, event, helper, pageNumber, pageSize);
    },

    handleCancel: function (component, event, helper) {
        component.set('v.isModalOpen', false);
    },

    handleDelete: function (component, event, helper) {
        var records = component.get('v.listOfRecords');
        var index = component.get('v.selectedRecordIndex');
        if (records[index].Id != undefined) {
            helper.delete(component, event, helper, records[index].Id);
            component.set('v.isModalOpen', false);
        }
    }*/
})