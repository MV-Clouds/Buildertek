({
    getcurr : function (component, event, helper) {
        var action = component.get("c.getRfqTo");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                   component.set("v.currencycode",response.getReturnValue());
			} 
		});
		$A.enqueueAction(action);		
    },
    getmulticur : function (component, event, helper) {
        var action = component.get("c.getmulticurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                  component.set("v.multicurrency",response.getReturnValue());
                //  component.set("v.multicurrency",false);
			} 
		});
		$A.enqueueAction(action);		
    },
	getdata: function (component, event, helper, isDelete) {
        // debugger;
		var rfq, actionRfqConfig, navigateToStep, rfqToVendorList, config, actionRfqToVendorList;
		actionRfqToVendorList = component.get("c.getRfqToVendors");
		actionRfqToVendorList.setParams({
			rfqId: component.get("v.recordId")
		});
		actionRfqToVendorList.setCallback(this, function (response) {
			if (component.isValid() && response.getState() === "SUCCESS" && response.getReturnValue().length > 0) {
                
                function validateEmail(email)
                {
                    var reg = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/
                    // if (reg.test(email)){
                        return true; //}
                    // else{
                    //     return false;
                    // }
                } 
                
				var rfqToVendorList = response.getReturnValue();
                
                rfqToVendorList.sort(function (a, b) {
                    return b.buildertek__Quote_Amount__c - a.buildertek__Quote_Amount__c;
                });
                
             
                
                var isAwarded = false;
                var isAccepted = false;
                
                if (rfqToVendorList != undefined) {
					for (var i in rfqToVendorList) {
                        //alert(rfqToVendorList[i].buildertek__Status__c);
                        if(rfqToVendorList[i].buildertek__Status__c == 'Awarded' || rfqToVendorList[i].buildertek__Status__c == 'Accepted' ){
                           // alert("helo");
                           rfqToVendorList[i].buildertek__IS_VENDOR_EXPANDED__c = true; 
                        }else{
                           rfqToVendorList[i].buildertek__IS_VENDOR_EXPANDED__c = false;
                        }
                        /* if(rfqToVendorList[i].buildertek__Status__c == 'Accepted' ){
                           rfqToVendorList[i].buildertek__IS_VENDOR_EXPANDED__c = true; 
                        }else{
                           rfqToVendorList[i].buildertek__IS_VENDOR_EXPANDED__c = false;
                        }*/
						
						rfqToVendorList[i].buildertek__IS_VENDOR_SELECTED__c = false;
						rfqToVendorList[i].buildertek__Status__c == 'Awarded' ? isAwarded = true : false;
						rfqToVendorList[i].buildertek__Status__c == 'Accepted' ? isAccepted = true : false;
                        if(rfqToVendorList[i].buildertek__Contact__r){
                            if(rfqToVendorList[i].buildertek__Contact__r.Email == '' || rfqToVendorList[i].buildertek__Contact__r.Email == undefined){
                                
                                if(component.get("v.IsEmailPresent") == false){
                                   	component.set("v.IsEmailPresent",true);
                                   }
                                
                            }
                        }
                        
						/*rfqToVendorList[i].buildertek__Quote_Amount__c = new Intl.NumberFormat('en-US', {
							style: 'currency',
							currency: 'USD'
						}).format(rfqToVendorList[i].buildertek__Quote_Amount__c);*/
						if (rfqToVendorList[i].buildertek__Vendor_Items__r != undefined) {
							for (var j in rfqToVendorList[i].buildertek__Vendor_Items__r) {
								/*if (rfqToVendorList[i].buildertek__Vendor_Items__r[j].buildertek__Unit_Price__c != undefined) {
									rfqToVendorList[i].buildertek__Vendor_Items__r[j].buildertek__Unit_Price__c = new Intl.NumberFormat('en-US', {
										style: 'currency',
										currency: 'USD'
									}).format(rfqToVendorList[i].buildertek__Vendor_Items__r[j].buildertek__Unit_Price__c);
								}*/
								/*if (rfqToVendorList[i].buildertek__Vendor_Items__r[j].buildertek__Total_Price__c != undefined) {
									rfqToVendorList[i].buildertek__Vendor_Items__r[j].buildertek__Total_Price__c = new Intl.NumberFormat('en-US', {
										style: 'currency',
										currency: 'USD'
									}).format(rfqToVendorList[i].buildertek__Vendor_Items__r[j].buildertek__Total_Price__c);
								}*/
							}
						}
						/*if (rfqToVendorList[i].buildertek__Vendor_Items__r != undefined) {
							rfqToVendorList[i].buildertek__Vendor_Items__r.sort(function (a, b) {
								if (a.buildertek__Description__c === "" || a.buildertek__Description__c === null || a.buildertek__Description__c == undefined) return 1;
								if (b.buildertek__Description__c === "" || b.buildertek__Description__c === null || b.buildertek__Description__c == undefined) return -1;
								if (a.buildertek__Description__c === b.buildertek__Description__c) return 0;
								return a.buildertek__Description__c < b.buildertek__Description__c ? -1 : 1;
							});
						}*/
                        if (rfqToVendorList[i].buildertek__Vendor_Items__r != undefined) {
							rfqToVendorList[i].buildertek__Vendor_Items__r.sort(function (a, b) {
								if (a.Name === "" || a.Name === null || a.Name == undefined) return 1;
								if (b.Name === "" || b.Name === null || b.Name == undefined) return -1;
								if (a.Name === b.Name) return 0;
								return a.Name < b.Name ? -1 : 1;
							});
						}
					}
				}
				component.set("v.rfqToVendorList", rfqToVendorList);
				component.set('v.isAwarded', isAwarded);
				component.set('v.isAccepted', isAccepted);
				$A.get("e.c:BT_SpinnerEvent").setParams({
					"action": "HIDE"
				}).fire();

				if (!isDelete) {
					var selectedVendor = document.getElementsByClassName('selectedVendor');
                    
					if (selectedVendor[0]) {
						try {
							selectedVendor[0].click();
						} catch (e) {}
					}
				} else {
					component.set("v.showVendorActions", false);
				}

				var selectedVendor = document.getElementsByClassName('selectedVendor');

				for (var i = 0; i < selectedVendor.length; i++) {
					selectedVendor[i].classList.remove("selectedVendor");
				}
				var selectedVendors = [];

				for (var i = 0; i < rfqToVendorList.length; i++) {
                    
                    if(rfqToVendorList[i].buildertek__Contact__r){
                        if(rfqToVendorList[i].buildertek__Contact__r.Email == '' || rfqToVendorList[i].buildertek__Contact__r.Email == undefined){
                            rfqToVendorList[i]['isEmail'] = true;
                            
                             
                        }else{
                            rfqToVendorList[i]['isEmail'] = false;
                            rfqToVendorList[i]['isValidEmail']= validateEmail(rfqToVendorList[i].buildertek__Contact__r.Email)
                        }
                    }else{
                        rfqToVendorList[i]['isEmail'] = false;
						rfqToVendorList[i]['isValidEmail'] = false
                    }
                     
                    if(rfqToVendorList[i].buildertek__Contact__c == '' || rfqToVendorList[i].buildertek__Contact__c == undefined || rfqToVendorList[i].buildertek__Contact__c == null){
                        rfqToVendorList[i]['isContact'] = true;
                        
                    }else{
                        rfqToVendorList[i]['isContact'] = false;
                        
                    }
                    
                
          
					if (rfqToVendorList[i].buildertek__RFQ__r.buildertek__Status__c == 'Awarded' || rfqToVendorList[i].buildertek__RFQ__r.buildertek__Status__c == 'Accepted') {
						if (rfqToVendorList[i].buildertek__Status__c == 'Awarded' || rfqToVendorList[i].buildertek__Status__c == 'Accepted') {
							$A.get("e.c:BT_SpinnerEvent").setParams({
								"action": "SHOW"
							}).fire();
							component.set("v.isDisabled", true);
							selectedVendors.push(rfqToVendorList[i]);
                            
							component.set("v.selectedVendorList", selectedVendors);
                            
							component.set("v.isCompare", true);
							component.set("v.showVendorActions", false);
							$A.get("e.c:BT_SpinnerEvent").setParams({
								"action": "HIDE"
							}).fire();

						}
					} else {
						component.set("v.isDisabled", false);
                        if(rfqToVendorList[i].buildertek__Contact__r){
                            if(rfqToVendorList[i].buildertek__Contact__r.Email == '' || rfqToVendorList[i].buildertek__Contact__r.Email == undefined){
                                rfqToVendorList[i]['isEmail'] = true;
                            }else{
                                rfqToVendorList[i]['isEmail'] = false;
                            }
                        }
                        if(rfqToVendorList[i].buildertek__Contact__c == '' || rfqToVendorList[i].buildertek__Contact__c == undefined || rfqToVendorList[i].buildertek__Contact__c == null){
                            rfqToVendorList[i]['isContact'] = true;
                            
                        }else{
                            rfqToVendorList[i]['isContact'] = false;
                    }
                        
						selectedVendors.push(rfqToVendorList[i]);
						$A.get("e.c:BT_SpinnerEvent").setParams({
							"action": "SHOW"
						}).fire();
						component.set("v.selectedVendorList", selectedVendors);
						component.set("v.isCompare", true);
						component.set("v.showVendorActions", false);
						$A.get("e.c:BT_SpinnerEvent").setParams({
							"action": "HIDE"
						}).fire();
					}
				}
			} else {
				component.set("v.rfqToVendorList", []);
				component.set("v.selectedVendorList", []);
				$A.get("e.c:BT_SpinnerEvent").setParams({
					"action": "HIDE"
				}).fire();
			}
		});

		actionRfqConfig = component.get("c.getRfqConfig");
		actionRfqConfig.setParams({
			rfqId: component.get("v.recordId")
		});
		actionRfqConfig.setCallback(this, function (response) {
			if (component.isValid() && response.getState() === "SUCCESS") {
				console.log(response.getReturnValue());

				var rfqConfig = response.getReturnValue();
				rfq = rfqConfig.rfq;
				config = rfqConfig.config;

				helper.updateInfoMessage(component, event, helper, rfq.buildertek__Status__c);

			}
		});

		$A.enqueueAction(actionRfqConfig);
		$A.enqueueAction(actionRfqToVendorList);
	},

	awardMultipleVendors: function (component, event, helper, selectedVendor, statusToUpdate, subject, contactIds) {
		var actionUpdateStatus;
		actionUpdateStatus = component.get("c.updateRFQToVendorStatus");
		actionUpdateStatus.setParams({
			rfqToVendorLinkIds: selectedVendor,
			Status: statusToUpdate
		});
		actionUpdateStatus.setCallback(this, function (response) {
			var toastEvent = $A.get("e.force:showToast");
			if (component.isValid() && response.getState() === "SUCCESS") {
				component.set('v.isMultipleAwardedClick', false);
				if (response.getReturnValue() !== '') {
					toastEvent.setParams({
						"type": "success",
						"title": "",
						"message": response.getReturnValue()
					});
					$A.get("e.force:refreshView").fire();
				} else {
					toastEvent.setParams({
						"type": "error",
						"title": "Error!",
						"message": response.getReturnValue()
					});
				}
			} else {
				toastEvent.setParams({
					"type": "error",
					"title": "error",
					"message": response.getError()[0].message
				});
			}
			toastEvent.fire();
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "HIDE"
			}).fire();
		});
		$A.enqueueAction(actionUpdateStatus);
		var action = component.get("c.createMultipleTasks");
		action.setParams({
			"contactIds": contactIds,
			"whatId": component.get("v.recordId"),
			"emailSubject": subject
		});
		$A.enqueueAction(action);
		helper.getdata(component, event, helper);
	},
    cancelRFQ : function (component, event, helper) {
       var cancelreason =  component.get("v.ReasonforCancelling");
       
        var action = component.get("c.cancelRFQvendor");
		action.setParams({
			rfqToVendorLinkIds: component.get('v.vendorList'),
            recordId : component.get("v.recordId"),
            reason : cancelreason
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
                 if (state === "SUCCESS") {
                     var result = response.getReturnValue();
			var toastEvent = $A.get("e.force:showToast");
			//if (component.isValid() && response.getState() === "SUCCESS") {
				component.set('v.isCancelRFQ', false);
				console.log('response.getReturnValue()::::',response.getReturnValue());
				if (result == 'SUCCESS') {
					toastEvent.setParams({
						"type": "success",
						"title": "Success",
						"message":" RFQ has been Canceled." 
					});
					$A.get("e.force:refreshView").fire();
				} else {
					toastEvent.setParams({
						"type": "error",
						"title": "Error!",
						"message": response.getReturnValue()
					});
				}
			} else {
				toastEvent.setParams({
					"type": "error",
					"title": "error",
					"message": response.getError()[0].message
				});
			}
			toastEvent.fire();
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "HIDE"
			}).fire();
		});
		$A.enqueueAction(action);
        helper.getdata(component, event, helper);
		
        },
    voidRFQ : function (component, event, helper) {
        var action = component.get("c.voidRFQvendor");
       var selectedVendorList = component.get('v.selectedVendorList');
       // alert( JSON.stringify(selectedVendorList));
		action.setParams({
			rfqToVendorLinkIds: component.get('v.vendorList'),
            recordId : component.get("v.recordId"),
		});
        action.setCallback(this, function (response) {
            var state = response.getState();
                 if (state === "SUCCESS") {
                     var result = response.getReturnValue();
			var toastEvent = $A.get("e.force:showToast");
			//if (component.isValid() && response.getState() === "SUCCESS") {
				console.log('response.getReturnValue()::::',response.getReturnValue());
				if (result == 'SUCCESS') {
					toastEvent.setParams({
						"type": "success",
						"title": "Success",
						"message": "You have successfully Voided this RFQ."
					});
					//location.reload();
                    $A.get("e.force:refreshView").fire();
				} else {
					toastEvent.setParams({
						"type": "error",
						"title": "Error!",
						"message": response.getReturnValue()
					});
				}
			} else {
				toastEvent.setParams({
					"type": "error",
					"title": "error",
					"message": response.getReturnValue()
				});
			}
			toastEvent.fire();
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "HIDE"
			}).fire();
		});
		$A.enqueueAction(action);
        helper.getdata(component, event, helper);
		
        },
	
	cancelAcceptedRFQ: function (component, event, helper, selectedVendor, contactIds) {
		var actionUpdateStatus;
		actionUpdateStatus = component.get("c.sendRFQCancelEmailToVendor");
		actionUpdateStatus.setParams({
			rfqToVendorLinkIds: selectedVendor
			//subject: subject
		});
		actionUpdateStatus.setCallback(this, function (response) {
			var toastEvent = $A.get("e.force:showToast");
			if (component.isValid() && response.getState() === "SUCCESS") {
				component.set('v.isCancelRFQ', false);
				console.log('response.getReturnValue()::::',response.getReturnValue());
				if (response.getReturnValue() == 'SUCCESS') {
					toastEvent.setParams({
						"type": "success",
						"title": "",
						"message": response.getReturnValue()
					});
					$A.get("e.force:refreshView").fire();
				} else {
					toastEvent.setParams({
						"type": "error",
						"title": "Error!",
						"message": response.getReturnValue()
					});
				}
			} else {
				toastEvent.setParams({
					"type": "error",
					"title": "error",
					"message": response.getError()[0].message
				});
			}
			toastEvent.fire();
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "HIDE"
			}).fire();
		});
		$A.enqueueAction(actionUpdateStatus);
		// var action = component.get("c.createMultipleTasks");
		// action.setParams({
		// 	"contactIds": contactIds,
		// 	"whatId": component.get("v.recordId"),
		// 	"emailSubject": subject
		// });
		// $A.enqueueAction(action);
		helper.getdata(component, event, helper);
	},
	moreDetails: function (component, event, helper, record, index) {

		var selectedVendor = document.getElementsByClassName('selectedVendor');

		for (var i = 0; i < selectedVendor.length; i++) {
			selectedVendor[i].classList.remove("selectedVendor");
		}

		document.getElementById(index).classList.add("selectedVendor");
		$A.createComponents(
			[
				["force:recordView", {
					"recordId": record.Id
				}],

			],
			function (components, status) {
				if (status === 'SUCCESS') {
					component.set("v.recordViewForm", components);
					component.set("v.showVendorActions", true);
					component.set("v.activeRFQVendor", record);
					component.set("v.linedata", record.buildertek__Vendor_Items__r);
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();

				}
			});
	},


	updateStatus: function (component, event, helper, rfqtovendorId, statusToUpdate, subject, contactId) {
		var actionUpdateStatus;
		actionUpdateStatus = component.get("c.updateRFQToVendorStatus");
		actionUpdateStatus.setParams({
			rfqToVendorLinkIds: rfqtovendorId,
			Status: statusToUpdate
		});
		actionUpdateStatus.setCallback(this, function (response) {
			var toastEvent = $A.get("e.force:showToast");
			if (component.isValid() && response.getState() === "SUCCESS") {

				if (response.getReturnValue() !== '') {
					toastEvent.setParams({
						"type": "success",
						"title": "",
						"message": response.getReturnValue()
					});
					$A.get("e.force:refreshView").fire();

					helper.getdata(component, event, helper);
					var action = component.get("c.createTask");
					action.setParams({
						"whoId": contactId,
						"whatId": component.get("v.recordId"),
						"emailSubject": subject
					});
					$A.enqueueAction(action);

				} else {
					toastEvent.setParams({
						"type": "error",
						"title": "Error!",
						"message": response.getReturnValue()
					});
				}
			} else {
				toastEvent.setParams({
					"type": "error",
					"title": "error",
					"message": response.getError()[0].message
				});
			}
			toastEvent.fire();
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "HIDE"
			}).fire();
		});
		$A.enqueueAction(actionUpdateStatus);
	},

	sendRFQEmail: function (component, event, helper, selectedVendorIds) {
		var action;
       // var select = component.get("selectedVendorIds");
        
		action = component.get("c.sendRFQEmailToVendor");
        
		action.setParams({
			rfqToVendorLinkIds: JSON.stringify(selectedVendorIds)
		});
		action.setCallback(this, function (response) {
            console.log('response---> '+response.getState());
            console.log(component.isValid());
			var toastEvent = $A.get("e.force:showToast");
          
			if (component.isValid() && response.getState() === "SUCCESS") {
	
				if (response.getReturnValue() == 'Email Sent Successfully') {
					component.set('v.checkThis' , false);
					toastEvent.setParams({
						"type": "success",
						"title": "",
						"message": response.getReturnValue()
					});
                    console.log(component.get("v.selectedVendorList"))
                    var vendorList = JSON.parse(JSON.stringify(component.get("v.selectedVendorList")))
                  //  alert('vendorList......'+vendorList);
                    if(vendorList){
                        for(var i=0;i<vendorList.length;i++){
                            //alert("hai");
                            vendorList[i].buildertek__IS_VENDOR_SELECTED__c = false;
                        }
                        component.set("v.selectedVendorList",vendorList)
                    }
                    
					$A.get("e.force:refreshView").fire();
				} else {
					toastEvent.setParams({
						"type": "error",
						"title": "Error!",
						"message": response.getReturnValue()
					});
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();
				}
			} else {
				toastEvent.setParams({
					"type": "error",
					"title": "error",
					"message": response.getError()[0].message
				});
			}
			toastEvent.fire();
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "HIDE"
			}).fire();
		});

		$A.enqueueAction(action);
	},


	createVendorLink: function (component, event, helper, selectedVendorIds) {
		var actionCreateLink;
		//Prepare actoin to retrive column header Json
		actionCreateLink = component.get("c.linkVendors");
        //alert(selectedVendorIds);
		actionCreateLink.setParams({
			rfqId: component.get("v.recordId"),
			vendorIds: selectedVendorIds
		});
		actionCreateLink.setCallback(this, function (response) {
			var toastEvent = $A.get("e.force:showToast");
			if (component.isValid() && response.getState() === "SUCCESS") {
				if (response.getReturnValue() == 'success') {
					toastEvent.setParams({
						"type": "success",
						"title": "",
						"message": "Vendor Added Successfully."
					});

					helper.getdata(component, event, helper);

					var eventToFire = $A.get("e.c:AppEvent");
					eventToFire.fire();

				} else {
					toastEvent.setParams({
						"type": "error",
						"title": "Error!",
						"message": response.getReturnValue()
					});
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();
				}
			} else {
				toastEvent.setParams({
					"type": "error",
					"title": "error",
					"message": response.getError()[0].message
				});
				$A.get("e.c:BT_SpinnerEvent").setParams({
					"action": "HIDE"
				}).fire();
			}


			toastEvent.fire();
		});

		$A.enqueueAction(actionCreateLink);
	},
    deleteVendorLink: function (component, event, helper) {
		var actionDeleteLink;
		actionDeleteLink = component.get("c.deleteVendor");
		actionDeleteLink.setParams({
			vendorIds: component.get("v.vendorId")
		});
		actionDeleteLink.setCallback(this, function (response) {
			var toastEvent = $A.get("e.force:showToast");
			if (component.isValid() && response.getState() === "SUCCESS") {
                 var modal = component.find("exampleModal");
        $A.util.addClass(modal, 'hideDiv');
				if (response.getReturnValue() == 'success') {
                 //   $A.get("e.force:refreshView").fire();
					toastEvent.setParams({
						"type": "success",
						"title": "",
						"message": "Vendor Removed Successfully."
					});
                    component.set("v.isQuotelinedelete", false);
                //   location.reload();
					helper.getdata(component, event, helper, true);
					var eventToFire = $A.get("e.c:AppEvent");
					eventToFire.fire();
				} else {
					toastEvent.setParams({
						"type": "error",
						"title": "Error!",
						"message": response.getReturnValue()
					});
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();

				}
			} else {
				toastEvent.setParams({
					"type": "error",
					"title": "error",
					"message": response.getError()[0].message
				});
			}
			toastEvent.fire();
		});

		$A.enqueueAction(actionDeleteLink);
	},

	removeVendorLink: function (component, event, helper, selectedVendorIds) {
		var actionDeleteLink;
		actionDeleteLink = component.get("c.deleteVendorLinks");
		actionDeleteLink.setParams({
			vendorIds: JSON.stringify(selectedVendorIds)
		});
		actionDeleteLink.setCallback(this, function (response) {
			var toastEvent = $A.get("e.force:showToast");
			if (component.isValid() && response.getState() === "SUCCESS") {
                
                
                 var modal = component.find("exampleModal");
        $A.util.addClass(modal, 'hideDiv');
                
                
				if (response.getReturnValue() == 'success') {
                 //   $A.get("e.force:refreshView").fire();
					toastEvent.setParams({
						"type": "success",
						"title": "",
						"message": "Vendor Removed Successfully."
					});
                   // location.reload();
                  //   location.reload();
                    component.set("v.isQuotelinedelete", false);
                    
					helper.getdata(component, event, helper, true);
					var eventToFire = $A.get("e.c:AppEvent");
					eventToFire.fire();
				} else {
					toastEvent.setParams({
						"type": "error",
						"title": "Error!",
						"message": response.getReturnValue()
					});
					$A.get("e.c:BT_SpinnerEvent").setParams({
						"action": "HIDE"
					}).fire();

				}
               
			} else {
				toastEvent.setParams({
					"type": "error",
					"title": "error",
					"message": response.getError()[0].message
				});
			}
			toastEvent.fire();
		});

		$A.enqueueAction(actionDeleteLink);
	},
        RFQStatus : function (component, event, helper) {
            var action = component.get('c.getrfqstatus');
            action.setParams({
                recId: component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                if(response.getState() === "SUCCESS") {
                    var Status = response.getReturnValue();
                    component.set('v.rfqStatus',Status);
                }
            });
            $A.enqueueAction(action);
            
        },

	updateInfoMessage: function (component, event, helper, status) {
		console.log('---status---', status);
		// Set the info message
		if (status == 'Awarded') {
			component.find("infoMessage").set("v.type", "success");
			component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Review_info_message_with_Awarded_Status"));
		} else if (status == 'Accepted') {
			component.find("infoMessage").set("v.type", "success");
			component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Review_info_message_with_Accepted_Status"));
		} else {
			component.find("infoMessage").set("v.type", "info");
			component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Review_info_message_with_New_Status"));
		}
	},
        
	MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb      
    filesCount : 0,
    fileInputLenght: 0,
     /**
     * This method to upload files
     * @param: File Data
     */
    uploadHelper: function(component, event, recid,helper) {
        // get the selected files using aura:id [return array of files]
        //var fileInput = component.find("fuploader").get("v.files");
        var fileInput = component.get("v.selectedfileslist");
        //alert('fileInput--->'+fileInput);
        this.fileInputLenght = fileInput.length; 
        var fills = component.get("v.selectedfilesFill");
        
        //alert('uploadHelper--->'+recid);
        for (var i = 0; i < fileInput.length; i++) { 
            var filenameexists = false;
            for (var j = 0; j < fills.length; j++) {
                if(fileInput[i]["name"] == fills[j].Name){
					filenameexists = true; 
                    break;
                }
            }
            
            if(filenameexists){
                var file = fileInput[i];
                var self = this;
                //alert(file);
                // check the selected file size, if select file size greter then MAX_FILE_SIZE,
                // then show a alert msg to user,hide the loading spinner and return from function 
                if (file.size > self.MAX_FILE_SIZE) {
                    component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
                    this.showMessage('Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size,false);
                    return;
                }
                self.uploadFile(component, file,recid,helper); 
            }
        }
    }, 
     /**
     * This method to upload files
     * @param: File Data
     */
    uploadFile:function(component, file,recid,helper) {
        //alert('uploadFile--->'+recid);
        var self = this;
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {              
            //component.set("v.IsSpinner",true);
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents,recid,helper);
        });
        objFileReader.readAsDataURL(file);
    }, 
     /**
     * This method to upload files
     * @param: File Data
     */
    uploadProcess: function(component, file, fileContents,recid,helper) {
        //alert('uploadProcess--->'+recid);
        console.log("Uploading files"); 
        var self = this;
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '',recid,helper); 
        
    },
     /**
     * This method to upload files
     * @param: File Data,Safety Event Id
     */
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId,recid,helper) {
        
        //component.set("v.IsSpinner",true); 
       // component.set("v.isSubmit",true);
        // call the apex method 'SaveFile'
        //alert('uploadInChunk--->'+recid);       
        var getchunk = fileContents.substring(startPosition, endPosition);
        //alert('getchunk--->'+getchunk);
        var action = component.get("c.saveTheChunk");
        action.setParams({ 
            parentId: recid,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type, 
            fileId: attachId
        });
        // set call back 
        action.setCallback(this, function(response) { 
            //component.set("v.IsSpinner",true);
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            //alert('attachId--->'+attachId);
            var state = response.getState();
            //alert('state--->'+state);
            if (state === "SUCCESS") {
                //component.set("v.IsSpinner",true);
                this.filesCount++; 
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId,recid,helper);
                } else {
                    this.showMessage('File(s) uploaded successfully',true);
                   /* var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.recordId'),
                        "slideDevName": "related"
                    });
                    navEvt.fire();*/               
                    
            		
                   $A.get("e.c:BT_SpinnerEvent").setParams({
								"action": "HIDE"
							}).fire();
                    location.reload();
                    //helper.getrfirecords(component, event, helper);
                    //component.set("v.isSubmit",true);
                }
               /* if(this.filesCount == this.fileInputLenght){ 
                    component.set("v.IsSpinner",false);
                   
                }*/
                // handel the response errors        
            } else if (state === "INCOMPLETE") { 
                //component.set("v.Spinner", false); 
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        this.showMessage("Error message: " + response.getReturnValue(),false);
                    }
                } else {
                    console.log("Unknown error");
                    this.showMessage("Unknown error",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    showMessage : function(message,isSuccess) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": isSuccess?"Success!":"Error!",
            "type":isSuccess?"success":"error",
            "message": message,
            'duration': '10000',
            'mode': 'dismissible'
        });
        toastEvent.fire();
    },
        getContactList: function(component, pageNumber, pageSize) {
            alert("hai");
         var recordId = component.get('v.Contractids');
            alert(recordId);
        var action = component.get("c.getContact");
        action.setParams({
            "pageNumber": pageNumber,
            "pageSize": pageSize,
             "recordId":recordId
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            alert(state);
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.IsSpinner",false);
                var resultData = result.getReturnValue();
                alert('resultData'+ JSON.stringify(resultData));
              //  component.set("v.ContactList", resultData.contactList);
                
                var recordIds = [];
                var selectedIds = component.get("v.listOfSelectedSOVIds");
                for(var i=0;i<resultData.contactList.length;i++){
                    //alert(resultData.contactList[i].Id);
                    if(selectedIds.indexOf(resultData.contactList[i].Id) < 0){
                        resultData.contactList[i].isChecked = false;
                    }else{
                        recordIds.push(resultData.contactList[i].Id)
                        //alert(resultData.contactList[i].Id);
                        resultData.contactList[i].isChecked = true;
                    }
                }
                if(recordIds.length == resultData.contactList.length){
                    component.find("headCheckRFQ").set("v.checked", true);
                }
                
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
            }
        });
        $A.enqueueAction(action);
    }
            
        

})