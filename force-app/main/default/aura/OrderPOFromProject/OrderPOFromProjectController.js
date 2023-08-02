({
	doInit: function (component, event, helper) {

		// var workspaceAPI = component.find("workspace");
		// workspaceAPI.getEnclosingTabId().then((response) => {
			// let opendTab = response.tabId;
			// workspaceAPI.setTabLabel({
			// 	tabId: opendTab,
			// 	label: "Purchase Orders"
			// });
			// workspaceAPI.setTabIcon({
			// 	tabId: opendTab,
			// 	icon: 'custom:custom5',
			// 	iconAlt: 'Purchase Orders'
			// });
		// });
		// debugger;

		var productCategoryValue = component.get("v.searchCategoryFilter");
		var recId = component.get("v.recordId");

		var pageSize = component.get("v.pageSize");
		var pageNumber = component.get("v.PageNumber");

		helper.getPurchaseOrders(component, event, helper, pageNumber, pageSize);

	},

	toggle: function (component, event, helper) {
		// debugger;
		var parentItems = component.get("v.PaginationList"),
			pathIndex = event.getSource().get("v.title").split('_'),
			grpIndex = Number(pathIndex[1]),
			rowIndex = Number(pathIndex[0])

		console.log("Records")
		console.log(parentItems)

		parentItems[grpIndex].poRecInner[rowIndex].expanded = !parentItems[grpIndex].poRecInner[rowIndex].expanded;
		var childItems = parentItems[grpIndex].poRecInner[rowIndex]['poLinesWrapper']
		for (var i = 0; i < childItems.length; i++) {
			parentItems[grpIndex].poRecInner[rowIndex]['poLinesWrapper'][i].expanded = !parentItems[grpIndex].poRecInner[rowIndex]['poLinesWrapper'][i].expanded;
		}
		component.set("v.PaginationList", parentItems);

	},

	next: function (component, event, helper) {
		// debugger;
		var pageNumber = component.get("v.PageNumber");
		var pageSize = component.get("v.pageSize");
		pageNumber++;

		helper.getPurchaseOrders(component, event, helper, pageNumber, pageSize);
	},

	previous: function (component, event, helper) {
		// debugger;
		var pageNumber = component.get("v.PageNumber");
		var pageSize = component.get("v.pageSize");
		pageNumber--;
		helper.getPurchaseOrders(component, event, helper, pageNumber, pageSize);
	},

	handleCheck: function (component, event, helper) {
		// debugger;
		var checkbox = event.getSource();
		var Submittals = component.get("v.masterBudgetsList");
		var selectedHeaderCheck;
		if (Submittals != undefined) {
			for (var i = 0; i < Submittals.length; i++) {
				if (Submittals[i].poRecInner != undefined) {
					for (var j = 0; j < Submittals[i].poRecInner.length; j++) {
						if (Submittals[i].poRecInner != null) {
							if (Submittals[i].poRecInner[j].poRecord.Id == checkbox.get("v.name") && Submittals[i].poRecInner[j].poCheck == false) {
								Submittals[i].poRecInner[j].poCheck = true;
								selectedHeaderCheck = true;
							}
							else if (Submittals[i].poRecInner[j].poRecord.Id == checkbox.get("v.name") && Submittals[i].poRecInner[j].poCheck == true) {
								Submittals[i].poRecInner[j].poCheck = false;
								selectedHeaderCheck = false;
							}
						}
					}
				}
			}
		}
		component.set("v.masterBudgetsList", Submittals);

		var pathIndex = checkbox.get("v.id").split('_'),
			grpIndex = Number(pathIndex[1]),
			rowIndex = Number(pathIndex[0])

		var Submittals = component.get("v.masterBudgetsList");
		if (Submittals != undefined) {

			if (Submittals.length > 0) {
				if (selectedHeaderCheck == true) {
					if (Submittals[grpIndex]['poRecInner'][rowIndex]['poLinesWrapper']) {
						var poLines = Submittals[grpIndex]['poRecInner'][rowIndex]['poLinesWrapper']
						if (poLines != undefined) {
							for (var i = 0; i < poLines.length; i++) {
								poLines[i].poLineCheck = true;
							}
						}
					}
				} else {
					if (Submittals[grpIndex]['poRecInner'][rowIndex]['poLinesWrapper']) {
						var poLines = Submittals[grpIndex]['poRecInner'][rowIndex]['poLinesWrapper']
						if (poLines != undefined) {
							for (var i = 0; i < poLines.length; i++) {
								poLines[i].poLineCheck = false;
							}
						}
					}
				}
			}
			component.set("v.PaginationList", Submittals);
		}

	},

	selectAll: function (component, event, helper) {
		// debugger;
		var selectedHeaderCheck = event.getSource().get("v.value");
		var Submittals = component.get("v.masterBudgetsList");
		var getAllId = component.find("checkContractor");
		if (getAllId != undefined && Submittals != undefined) {
			if (Submittals.length > 0) {
				if (!Array.isArray(getAllId)) {
					if (selectedHeaderCheck == true) {
						component.find("checkContractor").set("v.value", true);
						component.set("v.selectedCount", 1);
					} else {
						component.find("checkContractor").set("v.value", false);
						component.set("v.selectedCount", 0);
					}
				}
				else {
					if (selectedHeaderCheck == true) {
						for (var i = 0; i < getAllId.length; i++) {
							component.find("checkContractor")[i].set("v.value", true);
							component.find("checkContractor")[i].set("v.checked", true);
						}
						for (var i = 0; i < Submittals.length; i++) {
							if (Submittals[i].poRecInner != undefined) {
								for (var j = 0; j < Submittals[i].poRecInner.length; j++) {
									if (Submittals[i].poRecInner[j].poRecord.buildertek__Status__c != 'Ordered') {
										Submittals[i].poRecInner[j].poCheck = true;
									}
									var poLines = Submittals[i]['poRecInner'][j]['poLinesWrapper'];
									if (poLines != undefined){
										for (var k = 0; k < poLines.length; k++) {
											poLines[k].poLineCheck = true;
										}
									}
								}
							}
						}
						var checkPOLineClass = document.querySelectorAll(".checkPOLineClass");
						for (let i = 0; i < checkPOLineClass.length; i++) {
							checkPOLineClass[i].checked = true;
						}
					}
					else {
						for (var i = 0; i < getAllId.length; i++) {
							component.find("checkContractor")[i].set("v.value", false);
							component.find("checkContractor")[i].set("v.checked", false);
						}
						for (var i = 0; i < Submittals.length; i++) {
							if (Submittals[i].poRecInner != undefined) {
								for (var j = 0; j < Submittals[i].poRecInner.length; j++) {
									if (Submittals[i].poRecInner[j].poRecord.buildertek__Status__c != 'Ordered') {
										Submittals[i].poRecInner[j].poCheck = false;
									}
									var poLines = Submittals[i]['poRecInner'][j]['poLinesWrapper'];
									if (poLines != undefined){
										for (var k = 0; k < poLines.length; k++) {
											poLines[k].poLineCheck = false;
										}
									}
								}
							}
						}
						var checkPOLineClass = document.querySelectorAll(".checkPOLineClass");
						for (let i = 0; i < checkPOLineClass.length; i++) {
							checkPOLineClass[i].checked = false;
						}
					}
				}
			} else {
				var i = 0;
				if (selectedHeaderCheck == true) {
					component.find("checkContractor").set("v.value", true);
					component.set("v.selectedCount", 1);
					Submittals[i].poCheck = true;
				} else {
					component.find("checkContractor").set("v.value", false);
					component.set("v.selectedCount", 0);
					Submittals[i].poCheck = false;
				}
			}
		}
		component.set("v.masterBudgetsList", Submittals)
	},

	closeModel: function (component, event, helper) {
		$A.get('e.force:refreshView').fire();
	},

	clear: function (component, event, heplper) {
		// debugger;
		event.stopPropagation();
		event.preventDefault();
		var selectedPillId = event.getSource().get("v.name");
		var selectedPillIndex = selectedPillId.split("_")[0];
		var selectedPillPo = selectedPillId.split("_")[1];
		var allFileList = component.get("v.fileData2");
		var AllPillsList = component.get("v.selectedfilesFill");

		/*for(var i = 0; i < AllPillsList.length; i++){
				if(AllPillsList[i].Name == selectedPillId){
					AllPillsList.splice(i, 1);
					component.set("v.selectedfilesFill", AllPillsList);
				}  
			}*/

		if (allFileList.length != undefined) {
			for (var i = 0; i < allFileList.length; i++) {
				if (allFileList[i].POId == selectedPillPo && i == Number(selectedPillIndex)) {
					allFileList.splice(i, 1);
					//component.set("v.selectedfilesFill", AllPillsList);
				}
			}
		}
		component.set("v.fileData2", allFileList);

		var names = []

		if (component.get("v.fileData2") != undefined) {
			for (var i = 0; i < component.get("v.fileData2").length; i++) {
				var name = {};
				name['FileName'] = [];
				name['poId'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i])).POId
				name['FileName'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i]))["fileName"];
				names.push(name);
			}
		}
		component.set("v.FileNameList", names);
	},

	confirmOrderPO: function (component, event, helper) {
		// debugger;
		component.set("v.Spinner2", true);
		component.set("v.Spinner", true);
		var record = component.get("v.recordId");
		var select = component.get("v.selectedobjInfo");
		var budgetsList = component.get("v.masterBudgetsList");
		var budgetIds = [];
		if (budgetsList != null && budgetsList != undefined) {
			for (var i = 0; i < budgetsList.length; i++) {
				if (budgetsList[i].poRecInner != undefined) {
					for (var j = 0; j < budgetsList[i].poRecInner.length; j++) {
						if (budgetsList[i].poRecInner != null) {
							if (budgetsList[i].poRecInner[j].poCheck == true) {
								budgetIds.push(budgetsList[i].poRecInner[j].poRecord.Id);
							}
						}
					}
				}
			}
		}

		if (budgetIds.length > 0) {
			window.setTimeout(
				$A.getCallback(function () {
					component.set("v.selectedPOList", false);

				}), 1000);

			console.log(JSON.stringify(component.get("v.fileData2")))
			component.set("v.selectedobjInfo", budgetIds);
			var action = component.get("c.sendMail");
			action.setParams({
				budgetIds: budgetIds,
				filedata: JSON.stringify(component.get("v.fileData2"))
			});

			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var result = response.getReturnValue();
					if (result.Status === 'Success') {
						component.set("v.Spinner", false);
						component.set("v.Spinner2", false);
						component.set("v.selectedPOList", false);
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Success!",
							"message": result.Message,
							"type": 'Success'
						});
						toastEvent.fire();


						$A.get("e.force:closeQuickAction").fire();
						window.setTimeout(
							$A.getCallback(function () {
								//document.location.reload(true);   
								var action1 = component.get("c.getMasterBudgets");
								action1.setParams({
									recId: component.get("v.recordId"),
									"pageNumber": component.get("v.PageNumber"),
									"pageSize": component.get("v.pageSize"),
									"poFilter" : '',
									"poLineFilter" : '',
									"tradeTypeFilter" : '',
									"projectFilter" : '',
									"productFilter" : '',
									"permitFilter" : ''
								});
								action1.setCallback(this, function (response) {
									var state = response.getState();
									if (state === "SUCCESS") {
										// debugger;
										var pageSize = component.get("v.pageSize");
										var result = response.getReturnValue();
										component.set("v.masterBudgetsList", result);
										component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
										component.set("v.startPage", 0);
										component.set("v.endPage", pageSize - 1);
										var PaginationList = [];
										for (var i = 0; i < pageSize; i++) {
											if (component.get("v.masterBudgetsList").length > i)
												PaginationList.push(result[i]);
										}
										component.set('v.PaginationList', PaginationList);
										component.set("v.Spinner", false);
									} else {
										component.set("v.Spinner", false);
									}
								});
								$A.enqueueAction(action1);
							}), 1000
						);
					} else {
						component.set("v.Spinner2", false);
						component.set("v.selectedPOList", false);
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Error!",
							"message": result.Message,
							"type": 'Error'
						});
						toastEvent.fire();
					}
				}
			});
			$A.enqueueAction(action);

		}
	},

	orderPO: function (component, event, helper) {
		// debugger;

		var record = component.get("v.recordId");
		var select = component.get("v.selectedobjInfo");
		var budgetsList = component.get("v.masterBudgetsList");
		console.log({budgetsList});
		var budgetIds = [];
		if (budgetsList != null) {

			for (var i = 0; i < budgetsList.length; i++) {
				if (budgetsList[i].poRecInner != undefined) {
					for (var j = 0; j < budgetsList[i].poRecInner.length; j++) {
						if (budgetsList[i].poRecInner != null) {
							if (budgetsList[i].poRecInner[j].poCheck == true) {
								budgetIds.push(budgetsList[i].poRecInner[j].poRecord);
							}
						}
					}
				}
			}
		}

		var disableBtn = false;
		budgetIds.forEach(element => {
			console.log('element.buildertek__Vendor__c ==> '+element.buildertek__Vendor__c);
			if (element.buildertek__Vendor__c != null && element.buildertek__Vendor__c != '') {
				if (element.buildertek__Vendor__r.buildertek__Email_Address__c == null || element.buildertek__Vendor__r.buildertek__Email_Address__c == '') {
					disableBtn = true;
				}
			} else{
				disableBtn = true;
			}
		});

		component.set("v.disableOrder", disableBtn);

		component.set("v.SelectedPurchaseOrders", budgetIds);

		if (budgetIds.length > 0) {
			component.set("v.selectedPOList", true);
		} else {
			component.set("v.Spinner", false);
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				title: 'Error',
				message: 'Please select at least 1 Purchase Order.',
				duration: "5000",
				key: "info_alt",
				type: "error",
			});
			toastEvent.fire();
		}

	},

	closePOListPopUp: function (component, event, helper) {
		// debugger;
		component.set("v.selectedPOList", false);
		component.set("v.fileData2", []);

		var selectedHeaderCheck = component.find("checkContractors").get("v.value");

		var Submittals = component.get("v.masterBudgetsList");
		var getAllId = component.find("checkContractor");
		if (getAllId != undefined && Submittals != undefined) {
			if (Submittals.length > 0) {
				if (!Array.isArray(getAllId)) {
					if (selectedHeaderCheck == true) {
						component.find("checkContractor").set("v.value", true);
						component.set("v.selectedCount", 1);
					} else {
						component.find("checkContractor").set("v.value", false);
						component.set("v.selectedCount", 0);
					}
				}
				else {
					if (selectedHeaderCheck == true) {
						for (var i = 0; i < getAllId.length; i++) {
							component.find("checkContractor")[i].set("v.value", false);
							component.find("checkContractor")[i].set("v.checked", false);

						}
						for (var i = 0; i < Submittals.length; i++) {
							if (Submittals[i].poRecInner != undefined) {
								for (var j = 0; j < Submittals[i].poRecInner.length; j++) {
									if (Submittals[i].poRecInner[j].poRecord.buildertek__Status__c != 'Ordered') {
										Submittals[i].poRecInner[j].poCheck = false;
									}
								}
							}
						}
					}
					else {
						for (var i = 0; i < getAllId.length; i++) {
							component.find("checkContractor")[i].set("v.value", false);
							component.find("checkContractor")[i].set("v.checked", false);
						}
						for (var i = 0; i < Submittals.length; i++) {
							if (Submittals[i].poRecInner != undefined) {
								for (var j = 0; j < Submittals[i].poRecInner.length; j++) {
									if (Submittals[i].poRecInner[j].poRecord.buildertek__Status__c != 'Ordered') {
										Submittals[i].poRecInner[j].poCheck = false;
									}
								}
							}
						}
					}
				}
			} else {
				var i = 0;
				if (selectedHeaderCheck == true) {
					component.find("checkContractor").set("v.value", true);
					component.set("v.selectedCount", 1);
					Submittals[i].poCheck = true;
				} else {
					component.find("checkContractor").set("v.value", false);
					component.set("v.selectedCount", 0);
					Submittals[i].poCheck = false;
				}
			}
		}
		component.set("v.masterBudgetsList", Submittals)

		component.find("checkContractors").set("v.value", false);




	},

	handleFilesChange2: function (component, event, helper) {
		// debugger;
		var fileName = "No File Selected..";
		var fileCount = event.target.files;
		var POId = event.currentTarget.dataset.index;
		var files = '';

		if (fileCount.length > 0) {
			component.set("v.uploadFile", true);
			for (var i = 0; i < fileCount.length; i++) {
				fileName = fileCount[i]["name"];
				if (files == '') {
					files = fileName;
				} else {
					files = files + ',' + fileName;
				}
				helper.readFiles2(component, event, helper, fileCount[i], event.currentTarget.dataset.index);

			}
		}
		component.set("v.fileName2", files);

	},

	massUpdate: function (component, event, helper) {
		component.set("v.enableMassUpdate", true);
	},

	cancelMassUpdate: function (component, event, helper) {
		component.set("v.enableMassUpdate", false);
	},

	saveMassUpdate: function (component, event, helper) {
		// debugger;
		var unitCost = component.get("v.UnitCostValue");

		if (unitCost != undefined) {

			var budgetIds = [];
			var budgetsList = component.get("v.masterBudgetsList")

			// debugger;

			if (budgetsList != null && budgetsList != undefined) {
				for (var i = 0; i < budgetsList.length; i++) {
					if (budgetsList[i].poRecInner != undefined) {
						if (budgetsList[i].poRecInner != undefined) {
							for (var j = 0; j < budgetsList[i].poRecInner.length; j++) {
								if (budgetsList[i].poRecInner[j].poLinesWrapper != undefined) {
									for (var k = 0; k < budgetsList[i].poRecInner[j].poLinesWrapper.length; k++) {
										if (budgetsList[i].poRecInner != null) {
											if (budgetsList[i].poRecInner[j].poLinesWrapper[k].poLineCheck == true && budgetsList[i].poRecInner[j].poLinesWrapper[k].PORow == false) {
												budgetIds.push(budgetsList[i].poRecInner[j].poLinesWrapper[k].RecordId);
											}
										}
									}
								}
							}
						}
					}
				}
			}

			component.set("v.Spinner", true);

			console.log({budgetIds});
			if (budgetIds.length > 0) {
				var action = component.get("c.updatePOLines");
				action.setParams({
					poLineIds: budgetIds,
					unitCostValue: unitCost
				});
				action.setCallback(this, function (response) {
					var state = response.getState();
					var error = response.getError();
					if (state === "SUCCESS") {
						component.set("v.enableMassUpdate", false);
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"type": "success",
							"title": "",
							"message": "Unit Cost is Updated Successfully."
						});
						toastEvent.fire();

						component.set("v.Spinner", false);
						$A.get('e.force:refreshView').fire();
						console.log(response.getReturnValue())
					}
					else {
						component.set("v.Spinner", false);


						var error = ""


						if (response.getError() != null) {
							if (response.getError()[0].pageErrors != undefined) {
								error = JSON.stringify(response.getError()[0].pageErrors[0].message);
							} else if (response.getError()[0].message != null) {
								error = response.getError()[0].message;
							}
						}


						if (error.includes('Required fields are missing: [Vendor]')) {
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								title: 'Error',
								message: error,
								duration: "5000",
								key: "info_alt",
								type: "error",
							});
							toastEvent.fire();
						} else {
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								title: 'Error',
								message: error,
								duration: "5000",
								key: "info_alt",
								type: "error",
							});
							toastEvent.fire();
						}
					}
				});
				$A.enqueueAction(action);

			} else {
				component.set("v.Spinner", false);
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: 'Error',
					message: 'Please select at least 1 Purchase Order Item.',
					duration: "5000",
					key: "info_alt",
					type: "error",
				});
				toastEvent.fire();
			}



		} else {
			component.set("v.Spinner", false);
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				title: 'Error',
				message: 'Please enter Unit Cost.',
				duration: "5000",
				key: "info_alt",
				type: "error",
			});
			toastEvent.fire();
		}


	},

	doSearch: function (component, event, helper) {
		var pageNumber = component.get("v.PageNumber");
		var pageSize = component.get("v.pageSize");
        helper.getPurchaseOrders(component, event, helper, pageNumber, pageSize);
	},

	handleBlur: function (component, event, helper) {

		var inputField = event.getSource();
		var unitCost = event.getSource().get("v.value");

		var count = 0;
		if (unitCost >= 1) ++count;

		while (unitCost / 10 >= 1) {
			unitCost /= 10;
			++count;
		}
		if (count > 16) {
			inputField.setCustomValidity("You cannot enter more that 16 digits");
			component.set("v.isSave", true);
		} else {
			inputField.setCustomValidity("");
			component.set("v.isSave", false);
		}

	},



	selectAllPOLines: function (component, event, helper) {

		// debugger;
		var selectedHeaderCheck = event.getSource().get("v.value");


		var pathIndex = event.getSource().get("v.name").split('_'),
			grpIndex = Number(pathIndex[1]),
			rowIndex = Number(pathIndex[0])


		var Submittals = component.get("v.masterBudgetsList");
		var getAllId = component.find("checkPOLine");
		if (getAllId != undefined && Submittals != undefined) {

			if (Submittals.length > 0) {
				if (selectedHeaderCheck == true) {
					if (Submittals[grpIndex]['poRecInner'][rowIndex]['poLinesWrapper']) {
						var poLines = Submittals[grpIndex]['poRecInner'][rowIndex]['poLinesWrapper']
						if (poLines != undefined) {
							for (var i = 0; i < poLines.length; i++) {
								poLines[i].poLineCheck = true;
							}
						}
					}
				} else {
					if (Submittals[grpIndex]['poRecInner'][rowIndex]['poLinesWrapper']) {
						var poLines = Submittals[grpIndex]['poRecInner'][rowIndex]['poLinesWrapper']
						if (poLines != undefined) {
							for (var i = 0; i < poLines.length; i++) {
								poLines[i].poLineCheck = false;
							}
						}
					}
				}
			}
			component.set("v.PaginationList", Submittals)
		}

	},

	handleCheckPoLine: function (component, event, helper) {
		// debugger;
		var id = event.target.id;
		var Submittals = component.get("v.masterBudgetsList");
		for(var i=0 ; i < Submittals.length;i++){
			if(Submittals[i].poRecInner != null){
				for(var j=0;j<Submittals[i].poRecInner.length;j++){
					if(Submittals[i].poRecInner[j].poLinesWrapper != null){
						for(var k=0;k<Submittals[i].poRecInner[j].poLinesWrapper.length;k++){
							if (j+'-'+i+'-'+k == id) {
								Submittals[i].poRecInner[j].poLinesWrapper[k].poLineCheck = !Submittals[i].poRecInner[j].poLinesWrapper[k].poLineCheck;
							} 
						}
					}
				}
			}
		}
		component.set("v.PaginationList",Submittals);
	},




	maintoggle: function (component, event, helper) {
		// debugger;
		var parentItems = component.get("v.PaginationList")
		var isExpanded = component.get("v.isExpanded");
		if (isExpanded) {
			if (parentItems != undefined) {
				for (var i = 0; i < parentItems.length; i++) {
					if (parentItems[i].poRecInner != undefined) {
						for (var j = 0; j < parentItems[i].poRecInner.length; j++) {
							parentItems[i].poRecInner[j].expanded = !isExpanded;
							if (parentItems[i].poRecInner[j]['poLinesWrapper'] != undefined) {
								for (var k = 0; k < parentItems[i].poRecInner[j]['poLinesWrapper'].length; k++) {
									parentItems[i].poRecInner[j]['poLinesWrapper'][k].expanded = !isExpanded;
								}
							}
						}
					}
				}
			}
		} else{
			if (parentItems != undefined) {
				for (var i = 0; i < parentItems.length; i++) {
					if (parentItems[i].poRecInner != undefined) {
						for (var j = 0; j < parentItems[i].poRecInner.length; j++) {
							parentItems[i].poRecInner[j].expanded = !isExpanded;
							if (parentItems[i].poRecInner[j]['poLinesWrapper'] != undefined) {
								for (var k = 0; k < parentItems[i].poRecInner[j]['poLinesWrapper'].length; k++) {
									parentItems[i].poRecInner[j]['poLinesWrapper'][k].expanded = !isExpanded;
								}
							}
						}
					}
				}
			}
		}

		component.set("v.PaginationList", parentItems);
		isExpanded = !isExpanded;
		component.set("v.isExpanded", isExpanded);
	},

	
	removePO: function(component, event, helper) {
		var POId = event.currentTarget.dataset.index;
		var vendorList = component.get("v.SelectedPurchaseOrders");
		console.log('vendorList',vendorList);
		var updatedVendorList = [];

		for (var i = 0; i < vendorList.length; i++) {
			if (vendorList[i].Id != POId) {
				updatedVendorList.push(vendorList[i]);
			}
		}
        component.set("v.SelectedPurchaseOrders", updatedVendorList);
		var disableBtn = false;
		if (updatedVendorList.length > 0) {
			console.log('in if');
			updatedVendorList.forEach(element => {
			  console.log('element.buildertek__Vendor__c ==> ' + element.buildertek__Vendor__c);
			  if (element.buildertek__Vendor__c != null && element.buildertek__Vendor__c != '') {
				if (element.buildertek__Vendor__r.buildertek__Email_Address__c == null || element.buildertek__Vendor__r.buildertek__Email_Address__c == '') {
				  disableBtn = true;
				}
			  } else {
				disableBtn = true;
			  }
			});
		  } else {
			// disableBtn = false;
			component.set("v.selectedPOList", false);
			var a = component.get('c.closePOListPopUp');
            $A.enqueueAction(a);
		  }
		  
        console.log('disableBtn',disableBtn);
		component.set("v.disableOrder", disableBtn);

	},
	
	


})