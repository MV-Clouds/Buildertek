({
	initialize: function (component, event, helper) {

	},


	doInit: function (component, event, helper) {
		// alert('test2'); 
		component.set("v.budgetrecid", component.get("v.recordId"));
		//alert('budgetrecid---->'+component.get("v.budgetrecid"));
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		var page = component.get("v.page") || 1
		helper.getBudgetGroups(component, event, helper, page);
		helper.fetchPickListVal(component, event, helper);
		helper.fetchpricebooks(component, event, helper);
		// helper.fetchcsosttypevalues(component, event, helper);
		component.set("v.listofproductfamily", '');
		//helper.fetchproductfamily(component, event, helper);

	},

	navigate: function (component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		var page = component.get("v.page") || 1;
		// get the previous button label  
		var direction = event.getSource().get("v.label");
		///alert('direction ---------> '+direction); 
		// set the current page,(using ternary operator.)  
		page = direction === "Previous" ? (page - 1) : (page + 1);
		// call the helper function
		helper.getBudgetGroups(component, event, helper, page);
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

	onContingency: function (component, event, helper) {
		component.set('v.isContingency', true);
	},

	closeContingencyModel: function (component, event, helper) {
		component.set('v.isContingency', false);
	},

	handleCancel: function (component, event, helper) {
		component.find("overlayLib").notifyClose();
	},

	changeEvent: function (component, event, helper) {
		var group = component.find('groupId');
		group.set("v._text_value", '');
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
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "HIDE"
		}).fire();
		$A.get('e.force:refreshView').fire();

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

	handleSaveSuccess: function (component, event, helper) {
		if (event) {
			if (event.getParams().message && event.getParams().message.indexOf('was saved') != -1) {
				var page = component.get("v.page") || 1
				helper.getBudgetGroups(component, event, helper, page);
				$A.get("e.force:refreshView").fire();
			}
		}
	},

	doView: function (component, event, helper) {
		////console.log(event.currentTarget.dataset.record);
		var editRecordEvent = $A.get("e.force:navigateToSObject");
		editRecordEvent.setParams({
			"recordId": event.currentTarget.dataset.record
		});
		editRecordEvent.fire();
	},


	addProduct: function (component, event, helper) {
		var overlayLib;
		$A.createComponents([
				["c:BT_ProductsAdder", {
					"aura:id": "btSelectProducts",
					"recordId": component.get("v.recordId"),
					"_gFiled": "buildertek__Group__c",
					"_gSobject": "buildertek__Budget_Item__c",
					"_gFilter": "buildertek__Budget__c = '" + component.get("v.recordId") + "'",
					"saveCallback": function (Items) {
						//console.log('items',Items);
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
						$A.get("e.c:BT_SpinnerEvent").setParams({
							"action": "SHOW"
						}).fire();
						helper.addSelectedProducts(component, event, helper, newBudgetItems);
					},
					"cancelCallback": function () {
						overlayLib.close();
					}
				}],

			],
			function (components, status, errorMessage) {
				if (status === "SUCCESS") {
					component.find('overlayLib').showCustomModal({
						header: "Add Product(s) in Budget",
						body: components[0],
						footer: "",
						showCloseButton: true,
						cssClass: "btmodal_80",
						closeCallback: function () {
							overlayLib.close();
						}
					}).then(function (overlay) {
						overlayLib = overlay;
					});
				}
			});

	},


	eventAction: function (component, event, helper) {
		if (event.getParam("action") == 'transfer_budget') {
			var defaultValue = new Object();
			defaultValue.buildertek__From__c = event.getParam("budgetitemid");
			helper.createForceRecordEditComp(component, event, helper, "", "NEW", "Transfer Budget Amount", "buildertek__Budget_Modifications__c", defaultValue);
		}
	},

	newRFQ: function (component, event, helper) {
		if (component.find("checkQuoteItem") != undefined) {
			var BudgetIds = [];
			var rowData;
			var newRFQItems = [];
			var getAllId = component.find("checkQuoteItem");
			if (!Array.isArray(getAllId)) {
				if (getAllId.get("v.value") == true) {
					BudgetIds.push(getAllId.get("v.text"));
				}
			} else {
				for (var i = 0; i < getAllId.length; i++) {
					if (getAllId[i].get("v.value") == true) {
						BudgetIds.push(getAllId[i].get("v.text"));
					}
				}
			}

			if (BudgetIds.length > 0) {
				var action;
				action = component.get("c.BudgetItemList");
				action.setParams({
					BudgetIds: BudgetIds
				});
				action.setCallback(this, function (response) {
					if (component.isValid() && response.getState() === "SUCCESS") {

						for (i = 0; i < response.getReturnValue().length; i++) {
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
								["c:BT_New_RFQ", {
									"aura:id": "btNewRFQ",
									"newRFQ": rfq,
									"newRFQItems": newRFQItems,
									"saveCallback": component.get("v.refreshGridAction"),
									"cancelCallback": function () {
										overlayLib.close();
									}
								}],

							],
							function (components, status, errorMessage) {
								if (status === "SUCCESS") {
									component.find('overlayLib').showCustomModal({
										header: "New RFQ",
										body: components[0],
										footer: components[0].find("footer").get("v.body"),
										showCloseButton: true,
										cssClass: 'slds-modal_medium',
										closeCallback: function () {

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
			} else {
				component.find('notifLib').showNotice({
					"variant": "error",
					"header": "Please Select Budget Line!",
					"message": "Please Select Budget Line to Create RFQ.",
					closeCallback: function () {}
				});
			}
		} else {
			component.find('notifLib').showNotice({
				"variant": "error",
				"header": "No Budget Lines",
				"message": "No Budget Lines Records.",
				closeCallback: function () {}
			});
		}

	},

	newCO: function (component, event, helper) {
		if (component.find("checkQuoteItem") != undefined) {
			var BudgetIds = [];
			var rowData;
			var newCOItems = [];

			var getAllId = component.find("checkQuoteItem");
			if (!Array.isArray(getAllId)) {
				if (getAllId.get("v.value") == true) {
					BudgetIds.push(getAllId.get("v.text"));
				}
			} else {
				for (var i = 0; i < getAllId.length; i++) {
					if (getAllId[i].get("v.value") == true) {
						BudgetIds.push(getAllId[i].get("v.text"));
					}
				}
			}
			//alert('BudgetIds --------> '+BudgetIds);

			if (BudgetIds.length > 0) {
				var budgetlineid = BudgetIds[0];
				var action;
				action = component.get("c.BudgetItemList");
				action.setParams({
					BudgetIds: BudgetIds
				});
				action.setCallback(this, function (response) {
					if (component.isValid() && response.getState() === "SUCCESS") {

						for (i = 0; i < response.getReturnValue().length; i++) {
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
								["c:BT_New_Change_Order", {
									"aura:id": "btNewco",
									"newCO": CO,
									"newCOItems": newCOItems,
									"budgetlineid": budgetlineid,
									"saveCallback": component.get("v.refreshGridAction"),
									"cancelCallback": function () {
										overlayLib.close();
									}
								}],

							],
							function (components, status, errorMessage) {
								if (status === "SUCCESS") {
									component.find('overlayLib').showCustomModal({
										header: "New Change Order",
										body: components[0],
										footer: components[0].find("footer").get("v.body"),
										showCloseButton: true,
										cssClass: 'slds-modal_medium',
										closeCallback: function () {

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
			} else {
				component.find('notifLib').showNotice({
					"variant": "error",
					"header": "Please Select Budget Line!",
					"message": "Please Select Budget Line to Create Change Order.",
					closeCallback: function () {}
				});
			}
		} else {
			component.find('notifLib').showNotice({
				"variant": "error",
				"header": "No Budget Lines",
				"message": "No Budget Lines Records.",
				closeCallback: function () {}
			});
		}
	},

	newPO: function (component, event, helper) {
		if (component.find("checkQuoteItem") != undefined) {
			var BudgetIds = [];
			var rowData;
			var newPOItems = [];

			var getAllId = component.find("checkQuoteItem");
			if (!Array.isArray(getAllId)) {
				if (getAllId.get("v.value") == true) {
					BudgetIds.push(getAllId.get("v.text"));
				}
			} else {
				for (var i = 0; i < getAllId.length; i++) {
					if (getAllId[i].get("v.value") == true) {
						BudgetIds.push(getAllId[i].get("v.text"));
					}
				}
			}

			if (BudgetIds.length > 0) {
				var budgetlineid = BudgetIds[0];
				var action;
				action = component.get("c.BudgetItemList");
				action.setParams({
					BudgetIds: BudgetIds
				});
				action.setCallback(this, function (response) {
					if (component.isValid() && response.getState() === "SUCCESS") {

						for (i = 0; i < response.getReturnValue().length; i++) {
							rowData = response.getReturnValue()[i];
							//alert('rowData.Id-----'+rowData.Id);
							var newPOItem = new Object();
							newPOItem.Name = rowData.Name;
							newPOItem.buildertek__Product__c = rowData.buildertek__Product__c;
							newPOItem.buildertek__Budget_Item__c = rowData.Id;
							newPOItem.buildertek__Description__c = rowData.Name; //rowData.buildertek__Description__c;
							newPOItem.buildertek__Quantity__c = rowData.buildertek__Quantity__c;
							newPOItem.buildertek__Unit_Price__c = rowData.buildertek__Unit_Price__c;
							newPOItems.push(newPOItem);
						}

						var PO = component.get("v.newPO");
						console.log('PO:::::', JSON.stringify(PO));
						//alert('PO-----'+JSON.stringify(PO));
						PO.buildertek__Budget__c = component.get("v.sampleNewRecord").Id;
						PO.buildertek__Project__c = component.get("v.sampleNewRecord").buildertek__Project__c;
						PO.buildertek__Status__c = 'Pending';

						var overlayLib;
						$A.createComponents([
								["c:BT_New_Purchase_Order", {
									"aura:id": "btNewPo",
									"newPO": PO,
									"newPOItems": newPOItems,
									"budgetlineid": budgetlineid,
									"saveCallback": component.get("v.refreshGridAction"),
									"cancelCallback": function () {
										overlayLib.close();
									}
								}],

							],
							function (components, status, errorMessage) {
								if (status === "SUCCESS") {
									component.find('overlayLib').showCustomModal({
										header: "New Purchase Order",
										body: components[0],
										footer: components[0].find("footer").get("v.body"),
										showCloseButton: true,
										cssClass: "btmodal",
										closeCallback: function () {

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
			} else {
				component.find('notifLib').showNotice({
					"variant": "error",
					"header": "Please Select Budget Line!",
					"message": "Please Select Budget Line to Create PO.",
					closeCallback: function () {}
				});
			}
		} else {
			component.find('notifLib').showNotice({
				"variant": "error",
				"header": "No Budget Lines",
				"message": "No Budget Lines Records.",
				closeCallback: function () {}
			});
		}
	},

	/*	newSubContract: function (component, event, helper) {
		var BudgetIds = [];
		var rowData;
		var newSubContractItems = [];

		var getAllId = component.find("checkQuoteItem");
		if (!Array.isArray(getAllId)) {
			if (getAllId.get("v.value") == true) {
				BudgetIds.push(getAllId.get("v.text"));
			}
		} else {
			for (var i = 0; i < getAllId.length; i++) {
				if (getAllId[i].get("v.value") == true) {
					BudgetIds.push(getAllId[i].get("v.text"));
				}
			}
		}
		//alert('BudgetIds --------> '+BudgetIds);

		if (BudgetIds.length > 0) {
			var action;
			action = component.get("c.BudgetItemList");
			action.setParams({
				BudgetIds: BudgetIds
			});
			action.setCallback(this, function (response) {
				if (component.isValid() && response.getState() === "SUCCESS") {
					for (i = 0; i < response.getReturnValue().length; i++) {
						rowData = response.getReturnValue()[i];
						var newSubContractItem = {};
						newSubContractItem.Name = rowData.Name;
						newSubContractItem.buildertek__Product__c = rowData.buildertek__Product__c;
						newSubContractItem.buildertek__Budget_Item__c = rowData.Id;
						newSubContractItem.buildertek__Description__c = rowData.buildertek__Description__c;
						newSubContractItem.buildertek__Quantity__c = rowData.buildertek__Quantity__c;
						newSubContractItem.buildertek__Unit_Price__c = rowData.buildertek__Unit_Price__c;
						newSubContractItems.push(newSubContractItem);
					}
					var subContract = component.get("v.newSubContract");
					subContract.buildertek__Budget__c = component.get("v.sampleNewRecord").Id;
					subContract.buildertek__Project__c = component.get("v.sampleNewRecord").buildertek__Project__c;

					var overlayLib;
					$A.createComponents([
							["c:BT_New_Sub_Contract", {
								"aura:id": "btNewSubContract",
								"newSubContract": subContract,
								"newSubContractItems": newSubContractItems,
								"saveCallback": component.get("v.refreshGridAction"),
								"cancelCallback": function () {
									overlayLib.close();
								}
							}],

						],
						function (components, status, errorMessage) {
							if (status === "SUCCESS") {
								component.find('overlayLib').showCustomModal({
									header: "New Sub-Contract",
									body: components[0],
									footer: components[0].find("footer").get("v.body"),
									showCloseButton: true,
									cssClass: "btmodal",
									closeCallback: function () {

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
		} else {
			component.find('notifLib').showNotice({
				"variant": "error",
				"header": "Please Select Budget Line!",
				"message": "Please Select Budget Line to Create Sub-Contract.",
				closeCallback: function () {}
			});
		}

	},  */


	newExpense: function (component, event, helper) {
		component.set("v.isNewExpense", true);
		component.set('v.budgetItemId', '');
		var budgetId = component.get("v.sampleNewRecord").Id;
		component.set("v.expensebudget", budgetId);
		if (component.find("checkQuoteItem") != undefined) {
			var BudgetIds = [];
			var rowData;


			var getAllId = component.find("checkQuoteItem");
			if (!Array.isArray(getAllId)) {
				if (getAllId.get("v.value") == true) {
					BudgetIds.push(getAllId.get("v.text"));
				}
			} else {
				for (var i = 0; i < getAllId.length; i++) {
					if (getAllId[i].get("v.value") == true) {
						BudgetIds.push(getAllId[i].get("v.text"));
					}
				}
			}

			if (BudgetIds.length > 0) {
				var budgetitemId = BudgetIds[0];
				component.set('v.budgetItemId', budgetitemId);
				component.set('v.isExpenseUpdate', true);
				/*var createRecordEvent = $A.get("e.force:createRecord");
				createRecordEvent.setParams({
					"entityApiName": "buildertek__Expense__c",
					'defaultFieldValues': {
						'buildertek__Budget__c': component.get("v.sampleNewRecord").Id,
						'buildertek__Project__c': component.get("v.sampleNewRecord").buildertek__Project__c,
						//'buildertek__Budget_Line__c': budgetitemId,
					}
				});
				createRecordEvent.fire();*/



			} else {
				component.set('v.isExpenseUpdate', false);
				// component.find('notifLib').showNotice({
				// 	"variant": "error",
				// 	"header": "Please Select Budget Line!",
				// 	"message": "Please Select Budget Line to Create Expense ",
				// 	closeCallback: function () {}
				// });
			}
		} else {
			component.find('notifLib').showNotice({
				"variant": "error",
				"header": "No Budget Lines",
				"message": "No Budget Lines Records.",
				closeCallback: function () {}
			});
		}
	},

	doSave: function (component, event, helper) {
		debugger;
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		component.set("v.isNewExpense", false);
		var expenseDescription = component.get("v.expenseDescription");
		var expensebudget = component.get("v.expensebudget");
		var expenseType = component.get("v.expenseType");
		var expenseCostCode = component.get("v.expenseCostCode");
		var expensePaymentMethod = component.get("v.expensePaymentMethod");
		var expenseRefNo = component.get("v.expenseRefNo");
		var expenseAmount = component.get("v.expenseAmount");
		var expenseNote = component.get("v.expenseNote");
		var isExpenseUpdate = component.get("v.isExpenseUpdate");
		var budgetItemId = component.get("v.budgetItemId");
		//Update Expense  
		if (budgetItemId != undefined && isExpenseUpdate) {
			var action = component.get("c.updateBudgetItemFromExpenseItem");
			action.setParams({
				"expenseDescription": expenseDescription,
				"expensebudgetId": expensebudget,
				"expenseType": expenseType,
				"expenseCostCode": expenseCostCode,
				"expensePaymentMethod": expensePaymentMethod,
				"expenseRefNo": expenseRefNo,
				"expenseAmount": expenseAmount,
				"expenseNote": expenseNote,
				"projectId": component.get("v.sampleNewRecord").buildertek__Project__c,
				'budgetItemId': budgetItemId
			});
			action.setCallback(this, function (response) {
				if (response.getState() === "SUCCESS") {
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();
					$A.getCallback(function () {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'Budget Line created successfully',
							type: 'success',
							duration: '10000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					});
					$A.get('e.force:refreshView').fire();
					component.refreshData();
					component.set("v.expenseDescription", null);
					component.set("v.expensebudget", null);
					component.set("v.expenseType", null);
					component.set("v.expenseCostCode", null);
					component.set("v.expensePaymentMethod", null);
					component.set("v.expenseRefNo", null);
					component.set("v.expenseAmount", null);
					component.set("v.expenseNote", null);
				} else if (response.getState() === "ERROR") {
					let errors = response.getError();
					let message = 'Unknown error'; // Default error message
					// Retrieve the error message sent by the server
					if (errors && Array.isArray(errors) && errors.length > 0) {
						message = errors[0].message;
					}
					// Display the message
					console.error(message);
					$A.getCallback(function () {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'Budget Line not created',
							type: 'ERROR',
							duration: '10000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					});
					$A.get('e.force:refreshView').fire();
				}
			});
			$A.enqueueAction(action);
		} else {
			var action = component.get("c.createBudgetItemFromExpenseItem");
			action.setParams({
				"expenseDescription": expenseDescription,
				"expensebudgetId": expensebudget,
				"expenseType": expenseType,
				"expenseCostCode": expenseCostCode,
				"expensePaymentMethod": expensePaymentMethod,
				"expenseRefNo": expenseRefNo,
				"expenseAmount": expenseAmount,
				"expenseNote": expenseNote,
				"projectId": component.get("v.sampleNewRecord").buildertek__Project__c
			});
			action.setCallback(this, function (response) {
				if (response.getState() === "SUCCESS") {
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();
					$A.getCallback(function () {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'Budget Line created successfully',
							type: 'success',
							duration: '10000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					});
					$A.get('e.force:refreshView').fire();
					component.refreshData();
					component.set("v.expenseDescription", null);
					component.set("v.expensebudget", null);
					component.set("v.expenseType", null);
					component.set("v.expenseCostCode", null);
					component.set("v.expensePaymentMethod", null);
					component.set("v.expenseRefNo", null);
					component.set("v.expenseAmount", null);
					component.set("v.expenseNote", null);
				} else if (response.getState() === "ERROR") {
					let errors = response.getError();
					let message = 'Unknown error'; // Default error message
					// Retrieve the error message sent by the server
					if (errors && Array.isArray(errors) && errors.length > 0) {
						message = errors[0].message;
					}
					// Display the message
					console.error(message);
					$A.getCallback(function () {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'Budget Line not created',
							type: 'ERROR',
							duration: '10000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					});
					$A.get('e.force:refreshView').fire();
				}
			});
			$A.enqueueAction(action);
		}

	},
	doCancel: function (component, event, helper) {
		component.set("v.isNewExpense", false);
		component.set("v.expenseDescription", null);
		component.set("v.expensebudget", null);
		component.set("v.expenseType", null);
		component.set("v.expenseCostCode", null);
		component.set("v.expensePaymentMethod", null);
		component.set("v.expenseRefNo", null);
		component.set("v.expenseAmount", null);
		component.set("v.expenseNote", null);
	},
	importCSV: function (component, event, helper) {

	},

	refreshList: function (component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		//$A.enqueueAction(component.get('c.doInit'));
		var page = component.get("v.page") || 1
		helper.getBudgetGroups(component, event, helper, page);
	},
	onSaveSuccess: function (component, event, helper) {
		if (event) {
			if (event.getParams().message && event.getParams().message.indexOf('Budget Item') != -1 && event.getParams().message.indexOf('was saved') != -1) {
				$A.get("e.c:BT_SpinnerEvent").setParams({
					"action": "SHOW"
				}).fire();
				//$A.enqueueAction(component.get('c.doInit'));
				var page = component.get("v.page") || 1
				helper.getBudgetGroups(component, event, helper, page);
			}
		}
	},

	/*saveBudgetItemRecord: function (component, event, helper) {

$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
//console.log("######## on change Save Budget Record############");
var budgetLineObject = component.get("v.newBudgetLine");
//console.log("##### Budget Line Object "+JSON.stringify(budgetLineObject));
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

//$A.enqueueAction(component.get('c.doInit'));
$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
}
});
$A.enqueueAction(action);
},	
handleComponentEvent : function(component, event, helper) {
// get the selected Account record from the COMPONETN event 	 
var selectedAccountGetFromEvent = event.getParam("recordByEvent");
//console.log("##################################record By Event",JSON.stringify(selectedAccountGetFromEvent)); 
component.set("v.productId",selectedAccountGetFromEvent.Id);
component.set("v.productName",selectedAccountGetFromEvent.Name);
helper.getProductDetails(component,event,helper);
},*/


	newGroup: function (component, event, helper) {
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
					"budgetId": component.get("v.recordId"),
					"onSuccess": function () {
						var page = component.get("v.page") || 1
						helper.getBudgetGroups(component, event, helper, page);
					}
				}],

			],
			function (components, status) {
				if (status === 'SUCCESS') {
					component.find('overlayLib').showCustomModal({
						header: components[0],
						body: components[1],
						footer: components[1].find("footer"),
						showCloseButton: true,
						cssClass: 'slds-modal_large'
					});

				}
			});
	},

	saveBudgetItemRecord: function (component, event, helper) {

		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		var recordId = component.get("v.recordId");
		component.set("v.newBudgetLine.buildertek__Budget__c", recordId);
		//alert('Budget --> '+component.get("v.newBudgetLine.buildertek__Product__c"));
		var budgetLineObject = component.get("v.newBudgetLine");

		var tradeType;
		var contractor;
		/*  Comment by Laxman 08-07-2020
		var selectedTradetype = component.get("v.selectedTradeType");
		if (selectedTradetype != undefined) {
			tradeType = selectedTradetype.Id;
		} else {
			tradeType = null;
		} */
		console.log('Sub Group::', JSON.stringify(budgetLineObject));
		debugger;
		var selectedContractor = component.get("v.selectedContractor");
		if (selectedContractor != undefined) {
			contractor = selectedContractor.Id;
		} else {
			contractor = null;
		}
		// If we want tarade type value we have to pass parameter like "tradeType:tradeType"
		var action = component.get("c.saveBudgetLineItem");
		action.setParams({
			"budgetLineRecord": JSON.stringify(budgetLineObject),
			recordId: recordId,
			contractor: contractor

		});
		action.setCallback(this, function (respo) {
			if (component.isValid() && respo.getState() === "SUCCESS") {
				var url = location.href;
				var baseURL = url.substring(0, url.indexOf('/', 14));
				var result = respo.getReturnValue();
				var group = component.find('groupId');
				group.set("v._text_value", '');
				//var costCode = component.find('costCodeId');
				//costCode.set("v._text_value", '');
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
				component.set('v.newBudgetLine.buildertek__UOM__c', '');
				component.set('v.newBudgetLine.buildertek__Unit_Price__c', '');
				component.set('v.newBudgetLine.buildertek__Quantity__c', '1');
				component.set('v.newBudgetLine.buildertek__Sales_Price__c', '');
				$A.enqueueAction(component.get("c.clearLookupValue"));
				$A.get("e.c:BT_SpinnerEvent").setParams({
					"action": "HIDE"
				}).fire();

				/*$A.get('e.force:refreshView').fire();
				alert('TS');*/
				window.setTimeout(
					$A.getCallback(function () {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'Budget Line created successfully',
							type: 'success',
							duration: '10000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					}), 3000
				);
				$A.get('e.force:refreshView').fire();
				component.refreshData();
			}
		});
		$A.enqueueAction(action);

	},
	clearLookupValue: function (component, event, helper) {
		var childCmp = component.find("tradeTypeId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("accountId");
		var retnMsg = childCmp.clearLookup();
	},
	handleComponentEvent: function (component, event, helper) {
		// get the selected Account record from the COMPONETN event 	 
		var selectedAccountGetFromEvent = event.getParam("recordByEvent");
		component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
		helper.getProductDetails(component, event, helper);
	},

	/*handleEvent  : function(component, event, helper){
var message = event.getParam("message");
var toastEvent = $A.get("e.force:showToast");
toastEvent.setParams({
"title": "",
"message": message,
"type": "success"
});
component.refreshData();
$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
},*/


	editBudget: function (component, event, helper) {
		var recordId = event.currentTarget.dataset.id;
		var editRecordEvent = $A.get("e.force:editRecord");
		editRecordEvent.setParams({
			"recordId": recordId
		});
		editRecordEvent.fire();
	},

	deleteBudget: function (component, event, helper) {
		component.set("v.isOpen", true);
		var recordId = event.currentTarget.dataset.id;
		component.set("v.quoteItemId", recordId);
	},

	removegrouping: function (component, event, helper) {
		component.set("v.isremovegroup", true);
		var groupingrecordId = event.currentTarget.dataset.id;
		component.set("v.groupingid", groupingrecordId);
		component.set("v.budgetrecid", component.get("v.recordId"));
	},

	handleSelectAll: function (component, event, helper) {
		var checkvalue = component.find("selectAll").get("v.value");
		var checkQuoteItem = component.find("checkQuoteItem");
		if (checkvalue == true) {
			for (var i = 0; i < checkQuoteItem.length; i++) {
				checkQuoteItem[i].set("v.value", true);
			}
		} else {
			for (var i = 0; i < checkQuoteItem.length; i++) {
				checkQuoteItem[i].set("v.value", false);
			}
		}
	},

	deleteSelectedBudgetItem: function (component, event, helper) {
		if (component.find("checkQuoteItem") != undefined) {
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "SHOW"
			}).fire();
			var BudgetIds = [];
			var rowData;
			var newRFQItems = [];
			var delId = [];
			var getAllId = component.find("checkQuoteItem");
			if (!Array.isArray(getAllId)) {
				if (getAllId.get("v.value") == true) {
					BudgetIds.push(getAllId.get("v.text"));
				}
			} else {
				for (var i = 0; i < getAllId.length; i++) {
					if (getAllId[i].get("v.value") == true) {
						BudgetIds.push(getAllId[i].get("v.text"));
					}
				}
			}
			if (BudgetIds.length > 0) {
				component.set("v.BudgetlinePopupHeader", "Delete Budget Lines");
				component.set("v.BudgetlinePopupDescription", "Are you sure you want to delete Budget Lines?");
				component.set("v.isBudgetlinedelete", true);
				component.set("v.isSelectAll", false);
				/* var action = component.get('c.deleteSelectedItems');
			action.setParams({
				"recordIds": BudgetIds
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					$A.get("e.force:refreshView").fire();
					//$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire(); 
					window.setTimeout(
						$A.getCallback(function () {
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								mode: 'sticky',
								message: 'Selected Budget Lines was deleted',
								type: 'success',
								duration: '10000',
								mode: 'dismissible'
							});
							toastEvent.fire();
						}), 3000
					);
					 window.setTimeout(
                        $A.getCallback(function() {
                            document.location.reload(true);    
                        }), 4000
                    ); 
					
				}
			});
			$A.enqueueAction(action); */
			} else {
				component.find('notifLib').showNotice({
					"variant": "error",
					"header": "Please Select Budget Line!",
					"message": "Please select the Budget Line you would like to Delete.",
					closeCallback: function () {
						$A.get("e.c:BT_SpinnerEvent").setParams({
							"action": "HIDE"
						}).fire();
					}
				});
			}
		}
	},
	createnewbudgetlinegroup: function (component, event, helper) {

		// var budgetlinegroup = JSON.stringify(component.get("v.newbudgetgrouprec"));
		var groupName = component.find('gpnameid').get("v.value");
		var groupdescrption = component.find('gpdescid').get("v.value");
		//alert('groupName---' + groupName);
		if (groupName != undefined && groupName != null) {
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "SHOW"
			}).fire();
			var action = component.get("c.savenewbudgetlinegroup");
			action.setParams({
				newbudgetllinegroup: groupName,
				newbudgetllinegroupdes: groupdescrption

			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();
					var result = response.getReturnValue();
					//alert('result' + result);
					if (result == 'Success') {
						component.set("v.budgetllinegroupdescription", '');
						component.set("v.budgetllinegroupName", '');
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'New Budget Line Group created Successfully ',
							type: 'success',
							duration: '1000',
							mode: 'dismissible'
						});
						toastEvent.fire();
						//component.set("v.newbudgetgrouprec", '');
						component.set("v.isnewbudgetgroup", false);

					} else {
						//alert('noname')
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'This name is alredy exist. Please try with another name.',
							type: 'warning',
							duration: '1000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					}
				}
			});

			$A.enqueueAction(action);
		} else {
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				mode: 'sticky',
				message: 'Please enter Name',
				type: 'error',
				duration: '1000',
				mode: 'dismissible'
			});
			toastEvent.fire();
		}

	},


	createNewBudgetSubGroup: function (component, event, helper) {
		var budgetLineSubGroupName = component.find('budgetLineSubGroupName').get("v.value");
		var budgetLineSubGroupDescription = component.find('budgetLineSubGroupDescription').get("v.value");
		if (budgetLineSubGroupName != undefined && budgetLineSubGroupName != null) {
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "SHOW"
			}).fire();
			var action = component.get("c.saveNewBudgetSubGroup");
			action.setParams({
				budgetLineSubGroupName: budgetLineSubGroupName,
				budgetLineSubGroupDescription: budgetLineSubGroupDescription
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();
					var result = response.getReturnValue();
					if (result == 'Success') {
						component.set("v.budgetLineSubGroupDescription", '');
						component.set("v.budgetLineSubGroupName", '');
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'New Budget Line Sub Group created Successfully ',
							type: 'success',
							duration: '1000',
							mode: 'dismissible'
						});
						toastEvent.fire();
						component.set("v.isNewBudgetSubGroup", false);

					} else {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'This name is already exist. Please try with another name.',
							type: 'warning',
							duration: '1000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					}
				}
			});
			$A.enqueueAction(action);
		} else {
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				mode: 'sticky',
				message: 'Please enter Name',
				type: 'error',
				duration: '1000',
				mode: 'dismissible'
			});
			toastEvent.fire();
		}
	},

	newbudgetGroup: function (component, event, helper) {
		component.set("v.isnewbudgetgroup", true);
	},

	newBudgetSubGroup: function (component, event, helper) {
		component.set("v.isNewBudgetSubGroup", true);
	},


	newgroupcloseModel: function (component, event, helper) {
		// for Hide/Close Model,set the "new budgetline group" attribute to "Fasle"  

		component.set("v.budgetllinegroupdescription", '');
		component.set("v.budgetllinegroupName", '');
		component.set("v.isnewbudgetgroup", false);
	},

	newGroupBudgetSubGroupClose: function (component, event, helper) {
		component.set("v.budgetLineSubGroupDescription", '');
		component.set("v.budgetLineSubGroupName", '');
		component.set("v.isNewBudgetSubGroup", false);
	},
	closeModel: function (component, event, helper) {
		// for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
		component.set("v.isOpen", false);
	},
	removegroupingcloseModel: function (component, event, helper) {
		// for Hide/Close Model,set the "isremovegroup" attribute to "Fasle"  

		component.set("v.isremovegroup", false);


	},
	closeBudgetlineModel: function (component, event, helper) {
		component.set("v.isBudgetlinedelete", false);
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "HIDE"
		}).fire();
	},
	removegroupingBudgetItems: function (component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		var action = component.get("c.RemovegroupingBudgetLineItems");
		action.setParams({
			"groupingid": component.get("v.groupingid"),
			"budgetId": component.get("v.budgetrecid")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {

				var result = response.getReturnValue();
				component.set("v.isremovegroup", false);

				window.setTimeout(
					$A.getCallback(function () {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'Grouping  was deleted',
							type: 'success',
							duration: '1000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					}), 2000
				);

				var page = component.get("v.page") || 1
				//To much loading on deletion problem
				helper.getBudgetGroups(component, event, helper, page);



			}
		});
		$A.enqueueAction(action);
	},
	deleteBudgetItems: function (component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		var recordId = component.get("v.quoteItemId");
		//alert('recordId ----------> '+recordId);
		var action = component.get("c.deleteBudgetLineItem");
		action.setParams({
			"budgetId": recordId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				component.set("v.isOpen", false);
				//$A.get("e.force:refreshView").fire();
				//reduce the reload time 
				/*
				var TotalRecords = {};
				if(component.get("v.TotalRecords") != undefined){
				    TotalRecords = component.get("v.TotalRecords");
				}
				var isRecordFound = false;
				var isGroupRecordAvailable = false;
				var groupRecordsList = [];
				var groupId;
				var indexOfRecord;  
				if(TotalRecords != undefined && TotalRecords.tarTable != undefined && TotalRecords.tarTable.ListOfEachRecord != undefined && TotalRecords.tarTable.ListOfEachRecord.length>0){
				    for(var index=0;index<TotalRecords.tarTable.ListOfEachRecord.length;index++){
				        var singleRecord = TotalRecords.tarTable.ListOfEachRecord[index];
				        if(singleRecord.recordId == recordId){
				            isRecordFound = true;
				            indexOfRecord=index;
				            groupId=singleRecord.groupId;
				            if(groupRecordsList.includes(singleRecord.groupId)){
				                isGroupRecordAvailable = true; 
				                break;
				            } 
				        }else{
				            if(!groupRecordsList.includes(singleRecord.groupId)){
				                if(groupId==singleRecord.groupId){
				                    isGroupRecordAvailable = true; 
				                    break;
				                }
				                groupRecordsList.push(singleRecord.groupId);
				            }
				        }
				    }
				}
				if(isRecordFound){
				    var ListOfEachRecord = TotalRecords.tarTable.ListOfEachRecord; 
				    var preListOfEachRecord = ListOfEachRecord.splice(0,indexOfRecord);
				    var postListOfEachRecord = [];
				    if(ListOfEachRecord.length>1){
				       postListOfEachRecord = ListOfEachRecord.splice(1,ListOfEachRecord.length)
				    }
				    var newListOfEachRecord = preListOfEachRecord.concat(postListOfEachRecord);
				    TotalRecords.tarTable.ListOfEachRecord = newListOfEachRecord;
				    
				    if(!isGroupRecordAvailable){
				        var groupIndex;
				        var isGroupFound = false;
				        if(TotalRecords.groups != undefined && TotalRecords.groups.length>0){
				            for(var index=0;index<TotalRecords.groups.length;index++){
				                var singleGroup = TotalRecords.groups[index];
				                if(singleGroup.Id == groupId){
				                    isGroupFound = true;
				                    groupIndex = index;
				                    break;	
				                }
				            }
				            if(isGroupFound){
				                var groups = TotalRecords.groups;
				                var preGroupLst = groups.splice(0,groupIndex);;
				                var postGroupLst = [];
				                if(groups.length>1){
				                    postGroupLst = groups.splice(1,groups.length)
				                }
				                var newGroups =  preGroupLst.concat(postGroupLst);
				                TotalRecords.groups = newGroups;
				            }
				        }
				    }
				    component.set("v.TotalRecords",TotalRecords);
				}
				*/
				window.setTimeout(
					$A.getCallback(function () {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'Budget Line was deleted',
							messageTemplate: "Budget Line {0} was deleted.",
							messageTemplateData: [{
								label: result.Name,
							}],
							type: 'success',
							duration: '10000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					}), 3000
				);
				//$A.enqueueAction(component.get('c.doInit'));  
				var page = component.get("v.page") || 1
				//To much loading on deletion problem
				helper.getBudgetGroups(component, event, helper, page);

				//v.TotalRecords.tarTable.ListOfEachRecord 

			}
		});
		$A.enqueueAction(action);
	},

	deleteSelectedBudgetItemlines: function (component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();

		var BudgetIds = [];
		var rowData;
		var newRFQItems = [];
		var delId = [];
		var getAllId = component.find("checkQuoteItem");
		if (!Array.isArray(getAllId)) {
			if (getAllId.get("v.value") == true) {
				BudgetIds.push(getAllId.get("v.text"));
			}
		} else {
			for (var i = 0; i < getAllId.length; i++) {
				if (getAllId[i].get("v.value") == true) {
					BudgetIds.push(getAllId[i].get("v.text"));
				}
			}
		}
		if (BudgetIds.length > 0) {
			var action = component.get('c.deleteSelectedItems');
			action.setParams({
				"recordIds": BudgetIds
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					component.set("v.isBudgetlinedelete", false);
					$A.get("e.force:refreshView").fire();
					//$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire(); 
					window.setTimeout(
						$A.getCallback(function () {
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								mode: 'sticky',
								message: 'Selected Budget Lines was deleted',
								type: 'success',
								duration: '10000',
								mode: 'dismissible'
							});
							toastEvent.fire();
						}), 3000
					);
					var page = component.get("v.page") || 1
					helper.getBudgetGroups(component, event, helper, page);
					/* window.setTimeout(
                        $A.getCallback(function() {
                            document.location.reload(true);    
                        }), 4000
                    ); */

				}
			});
			$A.enqueueAction(action);
		} else {
			component.find('notifLib').showNotice({
				"variant": "error",
				"header": "Please Select Quote Line!",
				"message": "Please select the Quote Line you would like to Delete.",
				closeCallback: function () {
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();
				}
			});
		}
	},

	inlineEdit: function (component, event, helper) {
		var recordId = event.currentTarget.dataset.id;
		var fieldName = event.currentTarget.dataset.label;
		var groupId = event.currentTarget.dataset.group;
		component.set("v.editedGroupId", groupId);
		component.set("v.quoteItemId", recordId);
		var editMode = component.get("v.isEditMode");
		component.set("v.isEditMode", true);
		component.set("v.fieldName", fieldName);

	},

	onblur: function (component, event, helper) {
		component.set("v.isEditMode", false);

	},

	updateQuoteData: function (component, event, helper) {
		if (!component.get("v.enableMassUpdate")) {
			var recordId = component.get("v.quoteItemId");
			var quoteList = component.get("v.datalist");
			var finString = component.get("v.finalString");
			//alert('finString ---------> '+finString);
			var delId = {};
			var newId = {};
			if (finString == null) {
				//alert('if');
				delId = {
					"Id": recordId
				}
				component.set("v.finalString", delId);
			} else {
				//alert('else');
				//alert('finString.Id --------> '+finString.Id);
				var isVal = 'True';
				for (var k = 0; k < quoteList.length; k++) {
					//alert(quoteList[k].Id);
					if (quoteList[k].Id == recordId) {
						//alert('new if' +quoteList[k].Id);
						newId = component.get("v.finalString");
						isVal = 'false';
						//break;
					}
					/*else if(isVal = 'True'){
					alert('new else');
					newId = {"Id": recordId};
					component.set("v.finalString", newId);  
					}*/
				}
				if (isVal == 'True') {
					newId = {
						"Id": recordId
					};
					component.set("v.finalString", newId);
				}

			}
			var finString = component.get("v.finalString");

			var flList = [];
			var fieldName = component.get("v.fieldName");
			var getAllId = component.find("inputId");
			var finalList = [];
			if (!Array.isArray(getAllId)) {
				//alert('if');
				if (getAllId.get("v.value") != null) {
					if (finString.Id == recordId) {
						//alert('if statement');
						finString[fieldName] = getAllId.get("v.value");
						//alert('finString ------> '+finString);
						quoteList.push(finString);
					} else {
						//alert('else statement');
						var isValue = 'True';
						for (var l = 0; l < quoteList.length; l++) {
							//alert('else statement'+quoteList[l].Id);
							//alert('recordId ---------> '+recordId);
							if (quoteList[l].Id == recordId) {
								//alert('Fin recordId -------> '+recordId);
								//alert('Fin newId -------> '+JSON.stringify(newId));
								newId = quoteList[l];
								newId[fieldName] = getAllId.get("v.value");
								quoteList.push(newId);
								break;
							}
						}
						/*if(isValue == 'True'){
						newId[fieldName] = getAllId.get("v.value");
						quoteList.push(newId);    
						}*/

					}
				}
			} else {
				//alert('else');
				for (var i = 0; i < getAllId.length; i++) {
					if (getAllId[i].get("v.value") != null) {
						if (finString.Id == recordId) {
							//alert('if statement');
							finString[fieldName] = getAllId[i].get("v.value");
							//alert('finString ------> '+finString);
							quoteList.push(finString);
						} else {
							//alert('else statement -->');
							newId[fieldName] = getAllId[i].get("v.value");
							quoteList.push(newId);
						}
					}
				}
			}
			//alert('finalList ---------> '+JSON.stringify(quoteList));
			component.set("v.finalList", finalList);
			component.set("v.datalist", quoteList);
			component.set("v.showButtons", true);

			var action = component.get("c.prepareString");
			action.setParams({
				"budgetString": JSON.stringify(quoteList),
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var result = response.getReturnValue();
					//console.log('result ---------> '+result);
					component.set("v.budgetList", result);

				}
			});
			$A.enqueueAction(action);
		} else {
			component.set("v.isChangeData", true);
		}
	},

	closeInlineEditForm: function (component, event, helper) {
		component.set("v.isEditMode", false);
		component.set("v.showButtons", false);
		//$A.enqueueAction(component.get('c.doInit'));
		var page = component.get("v.page") || 1
		helper.getBudgetGroups(component, event, helper, page);
	},
	SaveEditedValues: function (component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		var recordId = component.get("v.quoteItemId");
		var action = component.get("c.saveUpdatedValues");
		action.setParams({
			"budgetItemList": component.get("v.budgetList")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.isEditMode", false);
				component.set("v.showButtons", false);
				component.set("v.QuoteString", '');
				component.set("v.datalist", []);
				$A.get("e.force:refreshView").fire();
				window.setTimeout(
					$A.getCallback(function () {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							mode: 'sticky',
							message: 'Your changes are saved',
							type: 'success',
							duration: '10000',
							mode: 'dismissible'
						});
						toastEvent.fire();
					}), 3000
				);
				var page = component.get("v.page") || 1
				helper.getBudgetGroups(component, event, helper, page);
			}
		});
		$A.enqueueAction(action);
	},
	//mass Functionality start

	onclickDuplicate: function (component, event, helper) {
		var currentId = event.currentTarget.getAttribute("data-id");
		component.set("v.currentId", currentId);
		component.set("v.isDuplicate", true);
	},
	closeDuplicateModel: function (component, event, helper) {
		// for Hide/Close Model,set the "isDuplicate" attribute to "Fasle"  
		component.set("v.isOpen", false);
		component.set("v.isDuplicate", false);
		component.set("v.isMassDuplicate", false);
		component.set("v.currentId", "");
	},

	duplicateBudget: function (component, event, helper) {

		var currentId = component.get("v.currentId");
		if (currentId != "" && currentId != undefined) {
			component.set("v.isDuplicate", false);
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "SHOW"
			}).fire();
			var checkvalue = component.find("selectAll");
			var duplicateRecs = [];
			duplicateRecs.push(currentId);
			var action = component.get("c.massDuplicateBudgetLineItem");
			action.setParams({
				"budgetLineRecords": duplicateRecs
			});
			action.setCallback(this, function (respo) {
				console.log('response is : ', respo.getState());
				if (respo.getState() === "SUCCESS") {
					checkvalue.set("v.value", false);
					component.set("v.currentId", "");
					$A.get('e.force:refreshView').fire();
					window.setTimeout(
						$A.getCallback(function () {
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								mode: 'sticky',
								message: 'Duplicate records for selected budget items created successfully.',
								type: 'success',
								duration: '10000',
								mode: 'dismissible'
							});
							toastEvent.fire();
						}), 3000
					);
					var page = component.get("v.page") || 1
					helper.getBudgetGroups(component, event, helper, page);

				}
			});
			$A.enqueueAction(action);
		}

	},

	onMassDuplicate: function (component, event, helper) {
		var checkvalue = component.find("selectAll");
		var checkQuoteItem = component.find("checkQuoteItem");
		var duplicateRecs = component.get("v.duplicateRecs");
		var checkBool = 0;

		component.set("v.isMassDuplicate", false);

		for (var i = 0; i < checkQuoteItem.length; i++) {
			if (checkQuoteItem[i].get("v.value") && checkQuoteItem[i].get("v.value") != undefined && checkQuoteItem[i].get("v.value") != '') {
				duplicateRecs.push(checkQuoteItem[i].get("v.text"));
				checkBool++;
			}
		}

		if (checkBool > 0) {
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "SHOW"
			}).fire();
			var action = component.get("c.massDuplicateBudgetLineItem");
			action.setParams({
				"budgetLineRecords": duplicateRecs
			});
			action.setCallback(this, function (respo) {
				console.log('response is : ', respo.getState());
				if (respo.getState() === "SUCCESS") {
					checkvalue.set("v.value", false);
					$A.get('e.force:refreshView').fire();
					window.setTimeout(
						$A.getCallback(function () {
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								mode: 'sticky',
								message: 'Duplicate records for selected budget items created successfully.',
								type: 'success',
								duration: '10000',
								mode: 'dismissible'
							});
							toastEvent.fire();
						}), 3000
					);
					var page = component.get("v.page") || 1
					helper.getBudgetGroups(component, event, helper, page);
				}
			});
			$A.enqueueAction(action);

		} else {
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				mode: 'sticky',
				message: 'Please select any record.',
				type: 'warning',
				duration: '10000',
				mode: 'dismissible'
			});
			toastEvent.fire();
		}

	},
	onClickMassDuplicate: function (component, event, helper) {
		component.set("v.isMassDuplicate", true);
	},

	unCheckAll: function (component, event, helper) {
		var checkQuoteItem = component.find("checkQuoteItem");
		var checkvalue = component.find("selectAll");
		var checkBool = 0;

		for (var i = 0; i < checkQuoteItem.length; i++) {
			if (checkQuoteItem[i].get("v.value")) {
				checkBool++;
			}
		}

		if (checkBool == checkQuoteItem.length) {
			checkvalue.set("v.value", true);
		} else {
			checkvalue.set("v.value", false);
		}

	},

	//mass Functionality end

	onClickMassUpdateCancel: function (component, event, helper) {
		component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
		component.set("v.isChangeData", false);
		component.set("v.Spinner", true);
		var page = component.get("v.page") || 1;
		helper.getBudgetGroups(component, event, helper, page);
	},

	onClickMassUpdate: function (component, event, helper) {
		debugger;
		component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
		if (component.get("v.enableMassUpdate") == false && component.get('v.isChangeData')) {
			// if (component.get("v.enableMassUpdate") == false) {
			alert('hii');
			component.set("v.Spinner", true);
			var TotalRecords = component.get("v.TotalRecords");
			var ListOfEachRecord = TotalRecords.tarTable.ListOfEachRecord;
			var ListOfEachRecordLength = ListOfEachRecord.length;
			var newMassQi = [];
			for (var i = 0; i < ListOfEachRecordLength; i++) {
				var newMassQuoteItem = {};
				newMassQuoteItem.sobjectType = 'buildertek__Budget_Item__c';
				var countUnchangedValue = 0;
				for (var j = 0; j < ListOfEachRecord[i].recordList.length; j++) {
					var listOfRecord = ListOfEachRecord[i].recordList.length;
					var currency = ListOfEachRecord[i].recordList[j].recordValue;
					var recordValue = Number(currency.replace(/[^0-9.-]+/g, ""));
					if (recordValue != ListOfEachRecord[i].recordList[j].originalValue) {

						if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Quantity__c') {
							alert('hii' + ListOfEachRecord[i].recordList[j].originalValue);
							if (ListOfEachRecord[i].recordList[j].originalValue != '') {
								newMassQuoteItem.buildertek__Quantity__c = ListOfEachRecord[i].recordList[j].originalValue;
							} else {
								newMassQuoteItem.buildertek__Quantity__c = 1;
							}
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Unit_Price__c') {
							newMassQuoteItem.buildertek__Unit_Price__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Forecast_To_Complete__c') {
							newMassQuoteItem.buildertek__Forecast_To_Complete__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Sales_Price__c') {
							newMassQuoteItem.buildertek__Sales_Price__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Notes__c') {
							newMassQuoteItem.buildertek__Notes__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Cost_Code__c') {
							newMassQuoteItem.buildertek__Cost_Code__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__UOM__c') {
							newMassQuoteItem.buildertek__UOM__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Amount_In__c') {
							newMassQuoteItem.buildertek__Amount_In__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Amount_Out_2__c') {
							newMassQuoteItem.buildertek__Amount_Out_2__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Base_Sq_Feet__c') {
							newMassQuoteItem.buildertek__Base_Sq_Feet__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Item_Name__c') {
							newMassQuoteItem.buildertek__Item_Name__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Forecast_To_Complete__c') {
							newMassQuoteItem.buildertek__Forecast_To_Complete__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Cost_Type__c') {
							newMassQuoteItem.buildertek__Cost_Type__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Description__c') {
							newMassQuoteItem.buildertek__Description__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Discount__c') {
							newMassQuoteItem.buildertek__Discount__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Eligible_Amount__c') {
							newMassQuoteItem.buildertek__Eligible_Amount__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Group__c') {
							newMassQuoteItem.buildertek__Group__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Previously_Billed__c') {
							newMassQuoteItem.buildertek__Previously_Billed__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Product__c') {
							newMassQuoteItem.buildertek__Product__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Regional_Factor__c') {
							newMassQuoteItem.buildertek__Regional_Factor__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Trade_Type__c') {
							newMassQuoteItem.buildertek__Trade_Type__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Upgrades__c') {
							newMassQuoteItem.buildertek__Upgrades__c = ListOfEachRecord[i].recordList[j].originalValue;
						} else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Contractor__c') {
							newMassQuoteItem.buildertek__Contractor__c = ListOfEachRecord[i].recordList[j].originalValue;
						}
					} else {
						countUnchangedValue++;
					}
				}
				newMassQuoteItem.Id = ListOfEachRecord[i].recordId;
				newMassQuoteItem.Name = ListOfEachRecord[i].recordName;
				newMassQi.push(newMassQuoteItem);
			}
			if (newMassQi.length > 0) {
				var action = component.get("c.massUpdateBudgetLineItem");
				action.setParams({
					"budgetLineRecords": JSON.stringify(newMassQi)
				});
				action.setCallback(this, function (respo) {
					component.set("v.isChangeData", false);
					if (respo.getState() === "SUCCESS") {
						$A.get('e.force:refreshView').fire();
						window.setTimeout(
							$A.getCallback(function () {
								var toastEvent = $A.get("e.force:showToast");
								toastEvent.setParams({
									mode: 'sticky',
									message: 'Budget Line Updated successfully',
									type: 'success',
									duration: '1000',
									mode: 'dismissible'
								});
								toastEvent.fire();
							}), 1000
						);
						var page = component.get("v.page") || 1;
						helper.getBudgetGroups(component, event, helper, page);
					}
				});
				$A.enqueueAction(action);
			}
		}

	},
	handleLookUpEvent: function (component, event, helper) {
		var selectedRecordId = event.getParam("selectedRecordId");
		var index = event.getParam('index');
		var TotalRecords = component.get("v.TotalRecords");
		var fieldName = event.getParam('fieldName');
		var ListOfEachRecord = TotalRecords.tarTable.ListOfEachRecord;
		if (ListOfEachRecord[index] != undefined) {
			if (ListOfEachRecord[index].recordList != undefined) {
				for (var i in ListOfEachRecord[index].recordList) {
					if (ListOfEachRecord[index].recordList[i].fieldName == fieldName) {
						ListOfEachRecord[index].recordList[i].originalValue = selectedRecordId;
					}
				}
			}
		}
		component.set("v.isChangeData", true);
		component.set("v.TotalRecords", TotalRecords);
	},
})