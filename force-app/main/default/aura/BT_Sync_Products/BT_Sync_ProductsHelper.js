({
	getQuoteLinesRecords:function(component, event) {
		var action = component.get("c.getQuoteLineRecordList");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var QuoteLineList = response.getReturnValue();
                component.set("v.quoteLineList", QuoteLineList);
				component.set("v.Spinner", false);

            }
			else {
				component.set("v.Spinner", false);
				var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "type": "Error",
                            "message": "Something went wrong while getting Quote Lines."  
                        });
                        toastEvent.fire();
			}
        });
        $A.enqueueAction(action);
	},
	changePricebookHelper : function(component, event, helper , priceBookId){
		component.set("v.Spinner", true);
		var priceBookId = component.find("selectedPricebook").get("v.value");
        component.set("v.sProductFamily", '');
        component.set("v.sProductName", '');
        if (priceBookId != '') {
            var action = component.get("c.getProductsthroughPriceBook2");
            action.setParams({
                "pbookId": priceBookId 
            });
            action.setCallback(this, function(response) {
                var rows = response.getReturnValue();
                if (response.getState() == "SUCCESS" && rows != null) {
					component.set("v.Spinner", false);
                    var selectedRecords = component.get("v.selectedRecords");
                    var selectedRows = [];
                    var remainingRows = [];

                    rows.forEach(function(row) {
                        var matchingRecord = selectedRecords.find(function(record) {
                            return record.Id === row.Id;
                        });

                        if (matchingRecord) {
                            row.Selected = true; 
                            selectedRows.push(row);
                        } else {
                            row.Selected = false;
                            remainingRows.push(row);
                        }
                    });

                    var updatedRows = selectedRecords.concat(remainingRows);
					updatedRows.forEach(function(item) {
							if (item.Name.length > 80) {
								item.Name = item.Name.substring(0, 77) + '...';
							}
							if (item.Description && item.Description.length > 80) {
								item.Description = item.Description.substring(0, 77) + '...';
							}
						});
					
                    component.set("v.tableDataList", updatedRows);
                    var productFamilySet = new Set();
                    rows.forEach(element => {
                        if (element.Family != undefined && element.Family != '') {
                            productFamilySet.add(element.Family);
                        }
                    });
                    var productFamilyList = [];
                    productFamilyList.push({
                        key: '-- All Product Family --',
                        value: ''
                    });
                    productFamilySet.forEach(function(value) {
                        productFamilyList.push({
                            key: value,
                            value: value
                        });
                    });
                    component.set("v.productFamilyOptions", productFamilyList);
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.tableDataList", []);
            component.set("v.Spinner", false);
        }
    },
    getPricebookRecords:function(component, event) {	
        var action = component.get("c.getPricebookList");
        action.setParams({
            recordId:component.get("v.recordId")
        })
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            let projectHavePricebook=result[0].defaultValue;
            var pricebookOptions = [];
            if(Object.keys(projectHavePricebook).length !=0){
				
				pricebookOptions.push({ key: projectHavePricebook.Name, value: projectHavePricebook.Id });
                result[0].priceWrapList.forEach(function(element){
					if(projectHavePricebook.Id !== element.Id){
						pricebookOptions.push({ key: element.Name, value: element.Id });
                    }else{
						pricebookOptions.push({ key: "None", value: "" });
                    }
                });
                component.set('v.selectedPricebookId' , projectHavePricebook.Id);

            }else{
                pricebookOptions.push({ key: "None", value: "" });
                result[0].priceWrapList.forEach(function(element){
                    pricebookOptions.push({ key: element.Name, value: element.Id });
                });
            }
            if(component.get('v.selectedPricebookId')!= undefined){
				var priceBookId = component.find("selectedPricebook").get("v.value");
                this.changePricebookHelper(component, event);
            }
			else{
                 
            }
            component.set("v.pricebookoptions", pricebookOptions);
        });
        $A.enqueueAction(action);
	}, 
	changeProductFamilyHelper : function(component, event, helper , priceBookId, productFamilyId){
        component.set("v.Spinner", true);
        let sProductFamily = component.get("v.sProductFamily");
        if (priceBookId != '' && productFamilyId != '') {
            
            var action = component.get("c.getProductsthroughProductFamily");
            action.setParams({
                "pbookId": priceBookId ,
                "pfId": productFamilyId
            });
            action.setCallback(this, function(response) {
                var rows = response.getReturnValue();
                if (response.getState() == "SUCCESS" && rows != null) {
                    var selectedRecords = component.get("v.selectedRecords");
                    var selectedRows = [];
                    var remainingRows = [];
                    rows.forEach(function(row) {
                        var matchingRecord = selectedRecords.find(function(record) {
                            return record.Id === row.Id;
                        });

                        if (matchingRecord) {
                            row.Selected = true; // Assuming there's a field like 'Selected__c'
                            selectedRows.push(row);
                        } else {
                            row.Selected = false;
                            remainingRows.push(row);
                        }
                    });

                    // Combine selectedRows and remainingRows while maintaining selected order
                    var updatedRows = selectedRecords.concat(remainingRows);
					updatedRows.forEach(function(item) {
							if (item.Name.length > 80) {
								item.Name = item.Name.substring(0, 77) + '...';
							}
							if (item.Description && item.Description.length > 80) {
								item.Description = item.Description.substring(0, 77) + '...';
							}
						});
                    component.set("v.tableDataList", updatedRows);
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.tableDataList", []);
            if(component.get('v.selectedPricebookId')!= undefined){
                var priceBookId = component.find("selectedPricebook").get("v.value");
                helper.changePricebookHelper(component, event);
            }
        }
    },
	searchDatatableHelper : function(component, event, helper){
        component.set("v.Spinner", true);
        if (component.get("v.selectedPricebookId") != '') {
            let sProductFamily = component.get("v.sProductFamily");
            let sProductName = component.get("v.sProductName");
            let sPriceBook = component.get("v.selectedPricebookId");
            if (sProductName != '' && sProductFamily == '') {
                    var action = component.get("c.getProductsbyName");
                    action.setParams({
                        "pbookId": sPriceBook ,
                        "pName": sProductName
                    });
                    action.setCallback(this, function(response) {
                        var rows = response.getReturnValue();
                        if (response.getState() == "SUCCESS" && rows != null) {
                            var selectedRecords = component.get("v.selectedRecords");
                            rows.forEach(function(row) {
                                var matchingRecord = selectedRecords.find(function(record) {
                                    return record.Id === row.Id;
                                });
                                if (matchingRecord) {
                                    row.Selected = true;
                                }
                            });

                            // Sort the records with selected ones on top
                            rows.sort(function(a, b) {
                                if (a.Selected && !b.Selected) {
                                    return -1; // a comes before b
                                } else if (!a.Selected && b.Selected) {
                                    return 1; // b comes before a
                                }
                                return 0; // no change in order
                            });
                            
                            component.set("v.tableDataList", rows);
                            component.set("v.Spinner", false);
                        }
                    });
                    $A.enqueueAction(action);
                
            }
            else if (sProductName != '' && sProductFamily != '') {
                    var action = component.get("c.getProductsbyNameandFamily");
                    action.setParams({
                        "pbookId": sPriceBook ,
                        "pName": sProductName ,
                        "pfId": sProductFamily
                    });
                    action.setCallback(this, function(response) {
                        var rows = response.getReturnValue();
                        if (response.getState() == "SUCCESS" && rows != null) {
                            var selectedRecords = component.get("v.selectedRecords");
                            rows.forEach(function(row) {
                                var matchingRecord = selectedRecords.find(function(record) {
                                    return record.Id === row.Id;
                                });
                                if (matchingRecord) {
                                    row.Selected = true;
                                }
                            });

                            // Sort the records with selected ones on top
                            rows.sort(function(a, b) {
                                if (a.Selected && !b.Selected) {
                                    return -1; // a comes before b
                                } else if (!a.Selected && b.Selected) {
                                    return 1; // b comes before a
                                }
                                return 0; // no change in order
                            });
                            
                            component.set("v.tableDataList", rows);
                            component.set("v.Spinner", false);
                        }
                    });
                    $A.enqueueAction(action);
                
            }
            else if (sProductName == '' && sProductFamily != '') {
                var selectedPricebook = component.find("selectedPricebook").get("v.value");
                var selectedProductFamily = component.find("selectedProductFamily").get("v.value");
                helper.changeProductFamilyHelper(component, event, helper , selectedPricebook, selectedProductFamily);
            }
            else if (sProductName == '' && sProductFamily == '') {
                var selectedPricebook = component.find("selectedPricebook").get("v.value");
                helper.changePricebookHelper(component, event, helper , selectedPricebook);
            }
        }
    }, 
	UpdateQuoteLineList: function(component, event, helper){
		var onlyUpdatedQuoteLines = component.get("v.onlyUpdatedQuoteLines");
		var onlyUpdatedQuoteLines_JSON = JSON.stringify(onlyUpdatedQuoteLines);
			component.set("v.ShowMassSaveButton", true);
			var action = component.get("c.massUpdateQuoteLine");
			action.setParams({
				onlyUpdatedQuoteLines:  onlyUpdatedQuoteLines_JSON 
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					component.set("v.Spinner", false);
					var workspaceAPI = component.find("workspace");
					workspaceAPI.getFocusedTabInfo().then(function(response) {
						
						var focusedTabId = response.tabId;
						workspaceAPI.closeTab({tabId: focusedTabId});
					});
					window.setTimeout(
						$A.getCallback(function () {
							$A.get('e.force:refreshView').fire();
						}), 1000
					);
				}
				else if (state === "ERROR") {
					component.set("v.Spinner", false);
					var errors = response.getError();
					if (errors) {
						for (var i = 0; i < errors.length; i++) {
							console.error("Error: " + errors[i].message);
						}
					} else {
						console.error("Unknown error");
					}
				}
			});

		$A.enqueueAction(action);
	}
})