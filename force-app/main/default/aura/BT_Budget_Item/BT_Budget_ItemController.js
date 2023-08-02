({
    initialize : function(component, event, helper) {
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
       /* var budgetId = component.get("v.recordId");
        $('#'+budgetId+'groups').nestable({ maxDepth:1,
                                           handleClass:'av-section-handle', 
                                           listClass:'av-list', 
                                           threshold:15,
                                           group:1}).on('change', function(e) {
            var list   = e.length ? e : $(e.target);
            helper.setSortIds(component, event, helper, list.nestable('serialize'));
            
        });*/
        //helper.createItemGrid(component, event, helper);
    },
    
    doInit: function(cmp, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var groupFilter = "buildertek__budget__c ='"+cmp.get("v.recordId")+"'";
        cmp.set("v.groupFilter",groupFilter);
        cmp.set("v.selectedRows",[]);
        cmp.set("v.selectedCol",[]);
    },
    
    newLineItem: function(component, event, helper){
        helper.createForceRecordEditComp(component, event, helper, "", "NEW", "New Budget Item","buildertek__Budget_Item__c",new Object());
    },
    
    addProduct: function(component, event, helper) {
        var overlayLib;
        $A.createComponents([
            ["c:BT_ProductsAdder",{
                "aura:id":"btSelectProducts",
                "recordId":component.get("v.recordId"),
                "_gFiled":"buildertek__Group__c",
                "_gSobject":"buildertek__Budget_Item__c",
                "_gFilter":"buildertek__Budget__c = '"+component.get("v.recordId")+"'",
                "saveCallback":function(Items){
                    console.log('items',Items);
                    var newBudgetItems = [];
                    for (var i = 0; i < Items.length; i++) { 
                        var newBi = new Object();
                        newBi.buildertek__Product__c = Items[i].productId;
                        newBi.Name = Items[i].productName;
                        newBi.buildertek__budget__c = component.get("v.recordId");
                        newBi.buildertek__Unit_Price__c = Items[i].salesPrice;
                        newBi.buildertek__quantity__c = Items[i].quantity;
                        newBi.buildertek__Group__c = Items[i].groupid;
                        newBudgetItems.push(newBi);
                    }
                    overlayLib.close();
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                    helper.addSelectedProducts(component, event, helper, newBudgetItems);
                },
                "cancelCallback":function(){
                    overlayLib.close();
                }
            }],
            
        ],
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        header: "Add Product(s) in Budget",
                        body: components[0], 
                        footer:"",
                        showCloseButton: true,
                        cssClass: "btmodal_80",
                        closeCallback: function() {
                            
                        }
                    }).then(function (overlay) {
                        overlayLib = overlay;
                    });
                }
            });
            
	},
            
   deleteSelectedItem: function(component, event, helper) {
   	// 	console.log(component.get("v.selectedListCol"));
    //     var grid = component.find('ItemList');
    //     var result =  component.get("v.selectedRows"); 
    //     console.log('result1 -------> '+JSON.stringify(result1));
    //     var result1 = component.get("v.selectedCol");
    //     if(!result || result.length < 1) { 
    //         component.find('notifLib').showNotice({
    //             "variant": "error",
    //             "header": "Please Select Budget Line!",
    //             "message": "Please select the Budget Line you would like to Delete.",
    //             closeCallback: function() {
    //             }
    //         });
    //     } else {
    //       $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
    //         var setRows = [];
    //         for (var i = 0; i < result.length; i++){
    //             setRows.push(result[i].Id);
    //         }
    //       component.set("v.deleteRecords", setRows); 
    //       helper.deleteRecord(component,event,helper);
    //     }
    
        var selCol = component.get("v.selectedCol");
        var finalString = JSON.stringify(selCol).replace(/\s/g, "");
        
        finalString = finalString.replace('[[', '[');
        finalString = finalString.replace(']]', ']');
        for(var i=0; i<200; i++){
            finalString = finalString.replace('}],[{', '},{');    
        }
        if(finalString.includes('[],')){
            finalString = finalString.replace('[],', '');        
        }
        if(finalString.includes(',[]')){
            finalString = finalString.replace(',[]', '');        
        }
        
        
        if(finalString.includes('\'')){
            finalString = finalString.replace('\'', '');    
        }
        var budgetItems = JSON.parse(finalString);
        var NewBudgets = [];
        for(var i=0, j= budgetItems.length-1;i <= j;j--){
            NewBudgets.push(budgetItems[j]);
        }
        //alert('New Budgets ---------> '+JSON.stringify(NewBudgets));
        var selectedRows = component.get("v.selectedRows");
        var i,  n, rowData;
        var newRFQItems = [];  
                        
		if(NewBudgets.length > 0){
		    var GroupList = [];
            var BudgetIds = [];
            for (i = 0, n = NewBudgets.length; i < n; i++) {
                rowData = NewBudgets[i].GroupId;
                if(!GroupList.includes(NewBudgets[i].GroupId)){
                    GroupList.push(NewBudgets[i].GroupId);
                    for(var j = 0;j< NewBudgets[i].lineItems.length;j++){
                        BudgetIds.push(NewBudgets[i].lineItems[j].Id);
                    }
                }
            }
            if(BudgetIds.length > 0){
				$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
				var setRows = [];
				// for (var i = 0; i < result.length; i++){
				// 	setRows.push(result[i].Id);
				// }
			   component.set("v.deleteRecords", BudgetIds); 
			   helper.deleteRecord(component,event,helper);
			}
			else{
				component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Please Select Budget Line!",
                "message": "Please select the Budget Line you would like to Delete.",
                closeCallback: function() {
                }
				});
			}
			
		}
		else{
			component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Please Select Budget Line!",
                "message": "Please select the Budget Line you would like to Delete.",
                closeCallback: function() {
                }
			});
		}
	},
            
            
   eventAction: function(component, event, helper) {
            if(event.getParam("action") == 'transfer_budget') {
            var defaultValue = new Object();
            defaultValue.buildertek__From__c = event.getParam("budgetitemid");
            helper.createForceRecordEditComp(component, event, helper, "", "NEW", "Transfer Budget Amount","buildertek__Budget_Modifications__c", defaultValue);
            } 
            },
            
	newRFQ:function(component, event, helper) {
	    var selCol = component.get("v.selectedCol");
        var finalString = JSON.stringify(selCol).replace(/\s/g, "");
        
        finalString = finalString.replace('[[', '[');
        finalString = finalString.replace(']]', ']');
        for(var i=0; i<200; i++){
            finalString = finalString.replace('}],[{', '},{');    
        }
        if(finalString.includes('[],')){
            finalString = finalString.replace('[],', '');        
        }
        if(finalString.includes(',[]')){
            finalString = finalString.replace(',[]', '');        
        }
        
        
        if(finalString.includes('\'')){
            finalString = finalString.replace('\'', '');    
        }
        var budgetItems = JSON.parse(finalString);
        var NewBudgets = [];
        for(var i=0, j= budgetItems.length-1;i <= j;j--){
            NewBudgets.push(budgetItems[j]);
        }
        var selectedRows = component.get("v.selectedRows");
        var i,  n, rowData;
        var newRFQItems = [];  
                        
		if(NewBudgets.length > 0){
		    var GroupList = [];
            var BudgetIds = [];
            for (i = 0, n = NewBudgets.length; i < n; i++) {
                rowData = NewBudgets[i].GroupId;
                if(!GroupList.includes(NewBudgets[i].GroupId)){
                    GroupList.push(NewBudgets[i].GroupId);
                    for(var j = 0;j< NewBudgets[i].lineItems.length;j++){
                        BudgetIds.push(NewBudgets[i].lineItems[j].Id);
                    }
                }
            }
            if(BudgetIds.length > 0){
                var action;
                action = component.get("c.BudgetItemList");
                action.setParams({
                    BudgetIds: BudgetIds
                });
                action.setCallback(this, function (response) {
                    if (component.isValid() && response.getState() === "SUCCESS") {
                        
                        for(i=0;i< response.getReturnValue().length;i++){
                            rowData = response.getReturnValue()[i];
                            var newRFQItem = new Object();
                            newRFQItem.Name = rowData.Name;
                            newRFQItem.buildertek__Product__c = rowData.buildertek__Product__c;
                            newRFQItem.buildertek__Budget_Item__c = rowData.Id,
                            newRFQItem.buildertek__Description__c = rowData.buildertek__Description__c,			
                            newRFQItem.buildertek__Quantity__c = rowData.buildertek__Quantity__c;
                            newRFQItem.buildertek__Unit_Price__c = rowData.buildertek__Unit_Price__c;
                            newRFQItems.push(newRFQItem);
                        }
                            
                            var rfq = component.get("v.newRFQ");
        rfq.buildertek__Budget__c = component.get("v.sampleNewRecord").Id;
        rfq.buildertek__Project__c = component.get("v.sampleNewRecord").buildertek__Project__c;
        
        var overlayLib;
        $A.createComponents([
            ["c:BT_New_RFQ",{
                "aura:id":"btNewRFQ",
                "newRFQ":rfq,
                "newRFQItems":newRFQItems,
                "saveCallback":component.get("v.refreshGridAction"),
                "cancelCallback":function(){
                    overlayLib.close();
                }
            }],
            
        ],
            function(components, status, errorMessage){
                    if (status === "SUCCESS") {
                        component.find('overlayLib').showCustomModal({
                            header: "New RFQ",
                            body: components[0], 
                            footer: components[0].find("footer").get("v.body"),
                            showCloseButton: true,
                            cssClass: 'slds-modal_medium',
                            closeCallback: function() {
                                   
                            }
                        }).then(function (overlay) {
                            overlayLib = overlay;
                        });
                    }
                }
            );
            
            
                    }
                });
                $A.enqueueAction(action);
            }
            else {
            component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Please Select Budget Line!",
            "message": "Please Select Budget Line to Create RFQ.",
            closeCallback: function() {
            }
            });
                        }
        }
        else {
            component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Please Select Budget Line!",
            "message": "Please Select Budget Line to Create RFQ.",
            closeCallback: function() {
            }
	 
            });
                        }
        
        
            
	},
                
    newCO:function(component, event, helper) {
        var selCol = component.get("v.selectedCol");
        var finalString = JSON.stringify(selCol).replace(/\s/g, "");
        
        finalString = finalString.replace('[[', '[');
        finalString = finalString.replace(']]', ']');
        for(var i=0; i<200; i++){
            finalString = finalString.replace('}],[{', '},{');    
        }
        if(finalString.includes('[],')){
            finalString = finalString.replace('[],', '');        
        }
        if(finalString.includes(',[]')){
            finalString = finalString.replace(',[]', '');        
        }
        
        
        if(finalString.includes('\'')){
            finalString = finalString.replace('\'', '');    
        }
        var budgetItems = JSON.parse(finalString);
        var NewBudgets = [];
        for(var i=0, j= budgetItems.length-1;i <= j;j--){
            NewBudgets.push(budgetItems[j]);
        }
        var selectedRows = component.get("v.selectedRows");
        var i,  n, rowData;
        var newCOItems = [];
                        
		if(NewBudgets.length > 0){
		    var GroupList = [];
            var BudgetIds = [];
            for (i = 0, n = NewBudgets.length; i < n; i++) {
                rowData = NewBudgets[i].GroupId;
                if(!GroupList.includes(NewBudgets[i].GroupId)){
                    GroupList.push(NewBudgets[i].GroupId);
                    for(var j = 0;j< NewBudgets[i].lineItems.length;j++){
                        BudgetIds.push(NewBudgets[i].lineItems[j].Id);
                    }
                }
            }
			
			if(BudgetIds.length > 0){
                var action;
                action = component.get("c.BudgetItemList");
                action.setParams({
                    BudgetIds: BudgetIds
                });
                action.setCallback(this, function (response) {
                    if (component.isValid() && response.getState() === "SUCCESS") {
                        
                        for(i=0;i< response.getReturnValue().length;i++){
                            rowData = response.getReturnValue()[i];
            
                            var newCOItem = new Object();
                            newCOItem.Name = rowData.Name;
                            newCOItem.Item_Name__c = rowData.Name;
                            newCOItem.buildertek__Product__c = rowData.buildertek__Product__c;
                            newCOItem.buildertek__Budget_Item__c = rowData.Id,
                            newCOItem.buildertek__Description__c = rowData.buildertek__Description__c,			
                            newCOItem.buildertek__Quantity__c = rowData.buildertek__Quantity__c;
                            newCOItem.buildertek__Unit_Price__c = rowData.buildertek__Unit_Price__c;
                            newCOItems.push(newCOItem);
                        }
                       // component.set("v.selectedCol", []);
                        var CO = component.get("v.newCO");
                        CO.buildertek__Budget__c = component.get("v.sampleNewRecord").Id;
                        CO.buildertek__Project__c = component.get("v.sampleNewRecord").buildertek__Project__c;
                        CO.buildertek__Status__c = 'Pending';
        
                        var overlayLib;
                        $A.createComponents([
                            ["c:BT_New_Change_Order",{
                                "aura:id":"btNewco",
                                "newCO":CO,
                                "newCOItems":newCOItems,
                                "saveCallback":component.get("v.refreshGridAction"),
                                "cancelCallback":function(){
                                    overlayLib.close();
                                }
                            }],
                            
                        ],
                        function(components, status, errorMessage){
                            if (status === "SUCCESS") {
                                component.find('overlayLib').showCustomModal({
                                    header: "New Change Order",
                                    body: components[0], 
                                    footer: components[0].find("footer").get("v.body"),
                                    showCloseButton: true,
                                    cssClass: 'slds-modal_medium',
                                    closeCallback: function() {
                                        
                                    }
                                }).then(function (overlay) {
                                    overlayLib = overlay;
                                });
                            }
                        }
                        );
                    }
                });
                $A.enqueueAction(action);
            }
            else {
                component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Please Select Budget Line!",
                "message": "Please Select Budget Line to Create Change Order.",
                closeCallback: function() {
                }
                });
            }
        }
        else {
            component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Please Select Budget Line!",
            "message": "Please Select Budget Line to Create Change Order.",
            closeCallback: function() {
            }
            });
        }
    },
                    
    newPO:function(component, event, helper) {
        var selCol = component.get("v.selectedCol");
        var finalString = JSON.stringify(selCol).replace(/\s/g, "");
        
        finalString = finalString.replace('[[', '[');
        finalString = finalString.replace(']]', ']');
        for(var i=0; i<200; i++){
        	finalString = finalString.replace('}],[{', '},{');    
        }
        if(finalString.includes('[],')){
        	finalString = finalString.replace('[],', '');        
        }
        if(finalString.includes(',[]')){
        	finalString = finalString.replace(',[]', '');        
        }
        
        
        if(finalString.includes('\'')){
        	finalString = finalString.replace('\'', '');    
        }
        var budgetItems = JSON.parse(finalString);
        var NewBudgets = [];
        for(var i=0, j= budgetItems.length-1;i <= j;j--){
        	NewBudgets.push(budgetItems[j]);
        }
        var selectedRows = component.get("v.selectedRows");
        var i,  n, rowData;
        var newPOItems = [];
        				
        if(NewBudgets.length > 0){
        	var GroupList = [];
        	var BudgetIds = [];
        	for (i = 0, n = NewBudgets.length; i < n; i++) {
        		rowData = NewBudgets[i].GroupId;
        		if(!GroupList.includes(NewBudgets[i].GroupId)){
        			GroupList.push(NewBudgets[i].GroupId);
        			for(var j = 0;j< NewBudgets[i].lineItems.length;j++){
        				BudgetIds.push(NewBudgets[i].lineItems[j].Id);
        			}
        		}
        	}
        	
        	if(BudgetIds.length > 0){
        		var action;
        		action = component.get("c.BudgetItemList");
        		action.setParams({
        			BudgetIds: BudgetIds
        		});
        		action.setCallback(this, function (response) {
        			if (component.isValid() && response.getState() === "SUCCESS") {
        				
        				for(i=0;i< response.getReturnValue().length;i++){
        					rowData = response.getReturnValue()[i];
        					var newPOItem = new Object();
        					newPOItem.Name = rowData.Name;
        					newPOItem.buildertek__Product__c = rowData.buildertek__Product__c;
        					newPOItem.buildertek__Budget_Item__c = rowData.Id;
        					newPOItem.buildertek__Description__c = rowData.buildertek__Description__c;			
        					newPOItem.buildertek__Quantity__c = rowData.buildertek__Quantity__c;
        					newPOItem.buildertek__Unit_Price__c = rowData.buildertek__Unit_Price__c;
        					newPOItems.push(newPOItem);
        				}
        				
        				var PO = component.get("v.newPO");
        				PO.buildertek__Budget__c = component.get("v.sampleNewRecord").Id;
        				PO.buildertek__Project__c = component.get("v.sampleNewRecord").buildertek__Project__c;
        				
        				var overlayLib;
        				$A.createComponents([
        					["c:BT_New_Purchase_Order",{
        						"aura:id":"btNewPo",
        						"newPO":PO,
        						"newPOItems":newPOItems,
        						"saveCallback":component.get("v.refreshGridAction"),
        						"cancelCallback":function(){
        							overlayLib.close();
        						}
        					}],
        					
        				],
        				function(components, status, errorMessage){
        					if (status === "SUCCESS") {
        						component.find('overlayLib').showCustomModal({
        							header: "New Purchase Order",
        							body: components[0], 
        							footer: components[0].find("footer").get("v.body"),
        							showCloseButton: true,
        							cssClass: "btmodal",
        							closeCallback: function() {
        								
        							}
        						}).then(function (overlay) {
        							overlayLib = overlay;
        						});
        					}
        				}
        				);
        				
        			}
        		});
        		$A.enqueueAction(action);
        	}
        	else {
        		component.find('notifLib').showNotice({
        		"variant": "error",
        		"header": "Please Select Budget Line!",
        		"message": "Please Select Budget Line to Create PO.",
        		closeCallback: function() {
        		}
        		});
        	}
        }	
        else {
        	component.find('notifLib').showNotice({
        		"variant": "error",
        		"header": "Please Select Budget Line!",
        		"message": "Please Select Budget Line to Create PO.",
        		closeCallback: function() {
        		}
        	});
        }
    },
                        
	newSubContract:function(component, event, helper) {
	    var selCol = component.get("v.selectedCol");
        var finalString = JSON.stringify(selCol).replace(/\s/g, "");
        
        finalString = finalString.replace('[[', '[');
        finalString = finalString.replace(']]', ']');
        for(var i=0; i<200; i++){
        	finalString = finalString.replace('}],[{', '},{');    
        }
        if(finalString.includes('[],')){
        	finalString = finalString.replace('[],', '');        
        }
        if(finalString.includes(',[]')){
        	finalString = finalString.replace(',[]', '');        
        }
        
        
        if(finalString.includes('\'')){
        	finalString = finalString.replace('\'', '');    
        }
        var budgetItems = JSON.parse(finalString);
        var NewBudgets = [];
        for(var i=0, j= budgetItems.length-1;i <= j;j--){
        	NewBudgets.push(budgetItems[j]);
        }
        var selectedRows = component.get("v.selectedRows");
        var i,  n, rowData;
        var newSubContractItems = [];
        				
        if(NewBudgets.length > 0){
        	var GroupList = [];
        	var BudgetIds = [];
        	for (i = 0, n = NewBudgets.length; i < n; i++) {
        		rowData = NewBudgets[i].GroupId;
        		if(!GroupList.includes(NewBudgets[i].GroupId)){
        			GroupList.push(NewBudgets[i].GroupId);
        			for(var j = 0;j< NewBudgets[i].lineItems.length;j++){
        				BudgetIds.push(NewBudgets[i].lineItems[j].Id);
        			}
        		}
        	}
        	
        	if(BudgetIds.length > 0){
        		var action;
        		action = component.get("c.BudgetItemList");
        		action.setParams({
        			BudgetIds: BudgetIds
        		});
        		action.setCallback(this, function (response) {
        			if (component.isValid() && response.getState() === "SUCCESS") {
        				
        				for(i=0;i< response.getReturnValue().length;i++){
        					rowData = response.getReturnValue()[i];
        					var newSubContractItem = {};
                    newSubContractItem.Name = rowData.Name;
                    newSubContractItem.buildertek__Product__c = rowData.buildertek__Product__c;
                    newSubContractItem.buildertek__Budget_Item__c = rowData.Id,
                    newSubContractItem.buildertek__Description__c = rowData.buildertek__Description__c,			
                    newSubContractItem.buildertek__Quantity__c = rowData.buildertek__Quantity__c;
                    newSubContractItems.push(newSubContractItem);
                }
                var subContract = component.get("v.newSubContract");
                subContract.buildertek__Budget__c = component.get("v.sampleNewRecord").Id;
                subContract.buildertek__Project__c = component.get("v.sampleNewRecord").buildertek__Project__c;
                
                var overlayLib;
                $A.createComponents([
                    ["c:BT_New_Sub_Contract",{
                        "aura:id":"btNewSubContract",
                        "newSubContract":subContract,
                        "newSubContractItems":newSubContractItems,
                        "saveCallback":component.get("v.refreshGridAction"),
                        "cancelCallback":function(){
                            overlayLib.close();
                        }
                    }],
                    
                ],
                function(components, status, errorMessage){
                    if (status === "SUCCESS") {
                        component.find('overlayLib').showCustomModal({
                            header: "New Sub-Contract",
                            body: components[0], 
                            footer: components[0].find("footer").get("v.body"),
                            showCloseButton: true,
                            cssClass: "btmodal",
                            closeCallback: function() {
                                
                            }
                        }).then(function (overlay) {
                            overlayLib = overlay;
                        });
                    }
                }
                );
        				
        			}
        		});
        		$A.enqueueAction(action);
        	}
        	else {
        		component.find('notifLib').showNotice({
        		"variant": "error",
        		"header": "Please Select Budget Line!",
        		"message": "Please Select Budget Line to Create Sub-Contract.",
        		closeCallback: function() {
        		}
        		});
        	}
        }	
        else {
        	component.find('notifLib').showNotice({
        		"variant": "error",
        		"header": "Please Select Budget Line!",
        		"message": "Please Select Budget Line to Create Sub-Contract.",
        		closeCallback: function() {
        		}
        	});
        }
    },
        
    importCSV:function(component, event, helper) {
                            
    },
                            
  	refreshList: function(component, event, helper) {
                            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                            var grid = component.find('ItemList');
                            grid.refreshData();
    },
     onSaveSuccess: function(component, event, helper){
                            if(event){
                            if(event.getParams().message && event.getParams().message.indexOf('Budget Item') != -1 && event.getParams().message.indexOf('was saved') != -1){
                            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                            var grid = component.find('ItemList');
                            grid.refreshData();
                            }
                            } 
    },
                            
    saveBudgetItemRecord: function (component, event, helper) {
                            
                            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                            console.log("######## on change Save Budget Record############");
                            var budgetLineObject = component.get("v.newBudgetLine");
                            console.log("##### Budget Line Object "+JSON.stringify(budgetLineObject));
                            var action = component.get("c.saveBudgetLineItem");
                            action.setParams({"budgetLineRecord":budgetLineObject});
                            action.setCallback(this,function(respo){
                            if (component.isValid() && respo.getState() === "SUCCESS") {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                            "title": "",
                            "message": "Budget Line Added succesfully.",
                            "type": "success"
                            });
                            
                            var grid = component.find('ItemList');
                            grid.refreshData();
                            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                            }
                            });
                            $A.enqueueAction(action);
                            },	
                            handleComponentEvent : function(component, event, helper) {
                            // get the selected Account record from the COMPONETN event 	 
                            var selectedAccountGetFromEvent = event.getParam("recordByEvent");
                            console.log("##################################record By Event",JSON.stringify(selectedAccountGetFromEvent)); 
                            component.set("v.productId",selectedAccountGetFromEvent.Id);
                            component.set("v.productName",selectedAccountGetFromEvent.Name);
                            helper.getProductDetails(component,event,helper);
                            },
                            newGroup: function(component, event, helper){
		$A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "New Budget Group",
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_NewBudgetGroup", {
                    "budgetId" : component.get("v.recordId"),
                    "onSuccess" : function(){
						var grid = component.find('ItemList');
                            grid.refreshData();
                    }
                }], 
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer:components[1].find("footer"),
                        showCloseButton: true,
                        cssClass: 'slds-modal_large'
                    });
                    
                }
            });
	},
	
	handleValueChange : function (component, event, helper) {
        var previousValue = event.getParam("oldValue");
        var currentValue = event.getParam("value");
        var selectedValue = [];
        selectedValue.push(previousValue, currentValue);
        //alert('Selected Value --------> '+JSON.stringify(selectedValue));
        var selectedCol = component.get("v.selectedCol");
        
        if(selectedCol != null){
            selectedCol.push(currentValue);   
            component.set("v.selectedCol", selectedCol);
        }else{
            component.set("v.selectedCol", selectedValue);    
        }
        
       
        console.log('selectedCol --------> '+ JSON.stringify(selectedCol));
        
        //component.set("v.selectedRows", selectedValue);
    }, 
    
    /*handleCheckboxChange : function (component, event, helper) {
        var previousValue = event.getParam("oldValue");
        var currentValue = event.getParam("value");
        var selectedValue = [];
        selectedValue.push(previousValue, currentValue);
        console.log('Parent selectedValue -------> '+selectedValue);
        var selectedCol = component.get("v.selectedListCol");
        ////alert('selectedCol --------> '+selectedCol);
        if(selectedCol != null){
            selectedCol.push(currentValue);   
            component.set("v.selectedListCol", selectedCol);
        }else{
            component.set("v.selectedListCol", selectedValue);    
        }
    }*/
                            
                            })