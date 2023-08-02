({
    expandAll: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var selectedVendorList = component.get('v.selectedVendorList');
        var expandicon = document.getElementsByClassName(recordId + 'expandGrpIcon_');
        var collapeIcon = document.getElementsByClassName(recordId + 'collapseGrpIcon_');
        if (expandicon[0].style.display == "inline-block" && collapeIcon[0].style.display == "none") {
            component.set("v.isExpandGrp", true);
            expandicon[0].style.display = 'none';
            collapeIcon[0].style.display = 'inline-block';
            for (var i in selectedVendorList) {
                selectedVendorList[i].buildertek__IS_VENDOR_EXPANDED__c = true;
            }
        }
        component.set('v.selectedVendorList', selectedVendorList);
    },
    CollapeAll: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var selectedVendorList = component.get('v.selectedVendorList');
        var expandicon = document.getElementsByClassName(recordId + 'expandGrpIcon_');
        var collapeIcon = document.getElementsByClassName(recordId + 'collapseGrpIcon_');
        if (expandicon[0].style.display == "none" && collapeIcon[0].style.display == "inline-block") {
            collapeIcon[0].style.display = 'none';
            expandicon[0].style.display = 'inline-block';
            for (var i in selectedVendorList) {
                selectedVendorList[i].buildertek__IS_VENDOR_EXPANDED__c = false;
            }
        }
        component.set('v.selectedVendorList', selectedVendorList);
    },

    initialize: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        component.set('v.columns', [{
                label: 'Line name',
                fieldName: 'Name',
                type: 'text'
            },
            {
                label: 'Item Name',
                fieldName: 'Name',
                type: 'text'
            },

            {
                label: 'Description',
                fieldName: 'buildertek__Description__c',
                type: 'text'
            },

            {
                label: 'Quantity',
                fieldName: 'buildertek__Quantity__c',
                type: 'number',
                class: 'slds-align-left'
            },
            {
                label: 'Unit Price',
                fieldName: 'buildertek__Unit_Price__c',
                type: 'currency'
            },
            {
                label: 'Total Price',
                fieldName: 'buildertek__Total_Price__c',
                type: 'currency',
                typeAttributes: {
                    currencyCode: 'USD',
                    align: 'center'
                }
            },
            {
                label: 'Vendor Notes',
                fieldName: 'buildertek__Vendor_Note__c',
                type: 'text'
            }
        ]);
        helper.getdata(component, event, helper);
        helper.RFQStatus(component, event, helper);
        helper.getcurr(component, event, helper);
        helper.getmulticur(component, event, helper);
        component.set('v.checkThis' , false);
    },
    scriptsLoaded: function(component, event, helper) {

    },

    vendorLoaded: function(component, event, helper) {
        //helper.moreDetails(component.get("v.rfqToVendorList")[0].Id,'0');
    },

    selectAll: function(component, event, helper) {
        //alert("hai");
        // debugger;
        var checkAllSelected = event.getSource().get("v.value");
        var vendorList = component.get("v.selectedVendorList");
        var getAllId = component.find("vendorselection");
        // var getAllId = JSON.parse(JSON.stringify(component.find("vendorselection")));
        component.set('v.selectallid', checkAllSelected);

        if (getAllId != undefined) {
            console.log('Is not null');
            if (vendorList.length > 1) {
                console.log('length is greater than 1');
                if (!Array.isArray(getAllId)) {
                    console.log('get All Id');
                    if (checkAllSelected == true) {
                        component.find("vendorselection").set("v.value", true);
                    } else {
                        component.find("vendorselection").set("v.value", false);
                    }
                } else {
                    if (checkAllSelected == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("vendorselection")[i].set("v.value", true);
                            var checkbox = component.find("vendorselection")[i].get("v.text");
                            vendorList[i].buildertek__IS_VENDOR_SELECTED__c = true;
                        }
                    } else {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("vendorselection")[i].set("v.value", false);
                            var checkbox = component.find("vendorselection")[i].get("v.text");
                            var vendorList = component.get("v.selectedVendorList");
                            vendorList[i].buildertek__IS_VENDOR_SELECTED__c = false;
                        }
                    }
                }
            } else {
                var i = 0;
                if (checkAllSelected == true) {
                    //component.find("vendorselection").set("v.value", true);
                    //var checkbox = component.find("vendorselection").get("v.text");
                    vendorList[i].buildertek__IS_VENDOR_SELECTED__c = true;
                } else {
                    //   component.find("vendorselection").set("v.value", false);
                    //var checkbox = component.find("vendorselection").get("v.text");
                    var vendorList = component.get("v.selectedVendorList");
                    vendorList[i].buildertek__IS_VENDOR_SELECTED__c = false;
                }
            }
        }
        component.set('v.selectedVendorList', vendorList);

        // === BUIL-3031:- Changes if status = "REJECTED" then hide that checkbox and make value of checkbox = false;
        vendorList.forEach(function(value){
            if(value.buildertek__Status__c == 'Rejected'){
                value.buildertek__IS_VENDOR_SELECTED__c =false;
                vendorList.push(value);
            }
        });
        var uniqueSet = new Set(vendorList);
        var uniqueList = Array.from(uniqueSet);
        component.set("v.selectedVendorList" , uniqueList);
        console.log(component.get("v.selectedVendorList" ));
        // === End of BUIL-3031 ====
    },

    openRFQ: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        window.open('/' + recordId);
    },

    openVendor: function(component, event, helper) {
        var recordId = event.getSource().get("v.name");
        window.open('/' + recordId);
    },

    openVendoraccount: function(component, event, helper) {
        var accid = event.target.id;

        window.open('/' + accid);
    },

    showMoreDetails: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var record = component.get("v.rfqToVendorList")[event.currentTarget.id];
        //alert('record ---------> '+JSON.stringify(record));
        var selectedVendor = document.getElementsByClassName('selectedVendor');

        for (var i = 0; i < selectedVendor.length; i++) {
            selectedVendor[i].classList.remove("selectedVendor");
        }

        document.getElementById(event.currentTarget.id).classList.add("selectedVendor");
        $A.createComponents(
            [
                ["force:recordView", {
                    "recordId": record.Id
                }],

            ],
            function(components, status) {
                if (status === 'SUCCESS') {
                    component.set("v.IsOnLoad", false);
                    component.set("v.recordViewForm", components);
                    component.set("v.isCompare", false);
                    component.set("v.showVendorActions", true);
                    component.set("v.activeRFQVendor", record);
                    component.set("v.linedata", record.buildertek__Vendor_Items__r);
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();

                }
            });


    },

    uncheckAll: function(component, event, helper) {
        component.find("vendorCheckall").set("v.checked", false);
    },

    awardRFQ: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        //alert('Active Vendor ---------> '+component.get("v.activeRFQVendor"));
        var subject = 'Quote has been awarded to you [ref:' + component.get("v.recordId") + ']';
        var selectedVendor = component.get("v.activeRFQVendor");
        //alert('selectedVendor ---------> '+selectedVendor);
        var recordId;
        if (selectedVendor != null && selectedVendor != undefined) {
            var contactId = selectedVendor.buildertek__Contact__c;
            recordId = selectedVendor.Id;
            helper.updateStatus(component, event, helper, recordId, "Awarded", subject, contactId);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": "Please Select Vendors"
            });
            toastEvent.fire();
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        }
    },

    awardSelectedVendor: function(component, event, helper) {
        component.set('v.vendorName', '');
        component.set('v.vendorId', '');
        component.set('v.isAwardedClick', true);
        component.set('v.vendorName', event.getSource().get("v.alternativeText"));
        component.set('v.vendorId', event.getSource().get("v.name"));
    },
    deleteselectedVendor: function(component, event, helper) {
        component.set('v.vendorName', '');
        component.set('v.vendorId', '');
        component.set('v.isdeleteClick', true);
        component.set('v.vendorName', event.getSource().get("v.alternativeText"));
        component.set('v.vendorId', event.getSource().get("v.name"));
    },
    cancelvendor: function(component, event, helper) {
        component.set('v.isdeleteClick', false);
        component.set('v.vendorList', []);
    },
    confirmdelete: function(component, event, helper) {
        component.set('v.isdeleteClick', false);
        //component.set('v.isComparePopupOpen', false);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var selectedVendor = component.get("v.vendorId");
        //var vendorName = component.get('v.vendorName');
        //var action = component.get("c.getSelectedVendorData");
        helper.deleteVendorLink(component, event, helper);
    },


    confirmAward: function(component, event, helper) {
        component.set('v.isAwardedClick', false);
        component.set('v.MultipleAwardedClick', false);
        component.set('v.isComparePopupOpen', false);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var subject = 'Quote has been awarded to you [ref:' + component.get("v.recordId") + ']';
        var contactId;
        var subject = 'Quote has been awarded to you [ref:' + component.get("v.recordId") + ']';
        var selectedVendor = component.get("v.vendorId");
        var vendorName = component.get('v.vendorName');
        var action = component.get("c.getSelectedVendorData");
        console.log('selectedVendor::', selectedVendor);

        action.setParams({
            vendorId: selectedVendor
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.buildertek__Contact__c != undefined) {
                    contactId = result.buildertek__Contact__c;
                }
                helper.updateStatus(component, event, helper, selectedVendor, "Awarded", subject, contactId);
            }
        });
        $A.enqueueAction(action);
    },

    cancelAward: function(component, event, helper) {
        component.set('v.isAwardedClick', false);
        component.set('v.vendorList', []);
    },

    rejectRFQ: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        helper.updateStatus(component, event, helper, component.get("v.activeRFQVendor").Id, "Rejected");
    },

    acceptedRFQ: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        helper.updateStatus(component, event, helper, component.get("v.activeRFQVendor").Id, "Accepted");
    },

    canceledRFQ: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        helper.updateStatus(component, event, helper, component.get("v.activeRFQVendor").Id, "Canceled");
    },

    sendRFQ: function(component, event, helper) {
        var selectedvendors = [];
        selectedvendors.push(component.get("v.activeRFQVendor").Id);
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "RFQ Email Preview",
                    "HTMLAttributes": {
                        "class": "slds-text-heading_medium slds-hyphenate"
                    }
                }],
                ["c:BT_RFQ_Email_Preview", {
                    "rfqId": component.get("v.recordId"),
                    "vendorIds": selectedvendors,
                    "onSuccess": function(object, contactId) {
                        component.get('v.modalPromise').then(function(modal) {
                            modal.close();
                        });
                        $A.get("e.c:BT_SpinnerEvent").setParams({
                            "action": "SHOW"
                        }).fire();
                        helper.updateStatus(component, event, helper, component.get("v.activeRFQVendor").Id, "Email Sent", object, contactId);
                    },
                }],

            ],
            function(components, status) {
                if (status === 'SUCCESS') {
                    var modalPromise = component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer: components[1].find("footer"),
                        showCloseButton: true,
                        cssClass: 'slds-modal_medium'
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            });

    },

    sendMassEmails: function(component, event, helper) {

        var selectedvendors1 = [];
        var selectedVendorList = component.get('v.selectedVendorList');

        selectedVendorList.filter(function(selectedVendor) {
            console.log(selectedVendor);
            selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true ? selectedvendors1.push(selectedVendor.Id) : '';
        });


        console.log({ selectedVendorList });
        // debugger;
        var btadminaction = component.get("c.getadminvalues");
        btadminaction.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log({ result });
                if (result == true) {
                    component.set("v.Isbtvalue", true);


                    var action = component.get("c.checkProtalUsers");
                    action.setParams({
                        recordId: component.get("v.recordId"),
                        selectedVendors: selectedvendors1
                    });
                    action.setCallback(this, function(response) {
                        // debugger;
                        console.log('response 390->' + response.getState());
                        if (response.getState() == 'SUCCESS') {
                            var result = response.getReturnValue();
                            // debugger;
                            if (result.isportal == true) {
                                component.set("v.isPortalUser", true);




                                var isDisabled = component.get("v.isDisabled");
                                if (isDisabled == true) {
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type": "error",
                                        "message": "You cannot Email this RFQ because this RFQ is already Awarded"
                                    });
                                    toastEvent.fire();
                                } else {
                                    var vendorList = component.get("v.rfqToVendorList");

                                    var selectedvendors = [];
                                    var selectedVendorList = component.get('v.selectedVendorList');

                                    var noMailVedors = [];

                                    var noContactVendors = [];

                                    var isValidEmail = [];

                                    selectedVendorList.filter(function(selectedVendor) {
                                        selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true ? selectedvendors.push(selectedVendor.Id) : '';

                                        (selectedVendor.isEmail == true && selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true) ? noMailVedors.push(selectedVendor.Id): '';
                                        (selectedVendor.isContact == true && selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true) ? noContactVendors.push(selectedVendor.Id): '';
                                        (selectedVendor.isValidEmail == false && selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true) ? noContactVendors.push(selectedVendor.Id): '';

                                    });

                                    if (noMailVedors.length) {
                                        console.log('no mailvendor length');
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "type": "error",
                                            "message": "There is no valid email address for this Primary Contact"
                                        });
                                        toastEvent.fire();
                                    } else if (noContactVendors.length) {
                                        console.log('no contactvendor length');
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "type": "error",
                                            "message": "There is no valid email address for this Primary Contact"
                                        });
                                        toastEvent.fire();
                                    } else if (isValidEmail.length) {
                                        console.log('no validemail length');
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "type": "error",
                                            "message": "There is no valid email address for this Primary Contact"
                                        });
                                        toastEvent.fire();
                                    } else {
                                        console.log({ selectedvendors })
                                        if (selectedvendors.length > 0) {

                                            $A.createComponents(
                                                [
                                                    ["aura:html", {
                                                        "tag": "h2",
                                                        "body": "RFQ Email Preview",
                                                        "HTMLAttributes": {
                                                            "class": "slds-text-heading_medium slds-hyphenate"
                                                        }
                                                    }],
                                                    ["c:BT_RFQ_Email_Preview", {
                                                        "rfqId": component.get("v.recordId"),
                                                        "vendorIds": selectedvendors,
                                                        "onSuccess": function(object) {
                                                            component.get('v.modalPromise').then(function(modal) {
                                                                modal.close();
                                                            }).catch(function(error) {
                                                                console.log(error)
                                                            });
                                                            $A.get("e.c:BT_SpinnerEvent").setParams({
                                                                "action": "SHOW"
                                                            }).fire();
                                                            helper.sendRFQEmail(component, event, helper, selectedvendors);
                                                        },
                                                    }],
                                                ],
                                                function(components, status) {
                                                    if (status === 'SUCCESS') {
                                                        var modalPromise = component.find('overlayLib').showCustomModal({
                                                            header: components[0],
                                                            body: components[1],
                                                            footer: components[1].find("footer"),
                                                            showCloseButton: true,
                                                            cssClass: 'mymodal'
                                                        });
                                                        component.set("v.modalPromise", modalPromise);
                                                    }
                                                });
                                        } else {
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                "type": "error",
                                                "title": "Error!",
                                                "message": "Please Select Vendors"
                                            });
                                            toastEvent.fire();
                                            $A.get("e.c:BT_SpinnerEvent").setParams({
                                                "action": "HIDE"
                                            }).fire();
                                        }
                                    }
                                }

                            } else {
                                // debugger;

                                if (result.ConList) {
                                    component.set("v.nonPortalUserContactList", result.ConList);

                                    component.set("v.isNonPortalContactPopUP", true);

                                }

                            }
                        }

                    });
                    $A.enqueueAction(action);

                } else {
                    var isDisabled = component.get("v.isDisabled");
                    if (isDisabled == true) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "message": "You cannot Email this RFQ because this RFQ is already Awarded"
                        });
                        toastEvent.fire();
                    } else {
                        var vendorList = component.get("v.rfqToVendorList");

                        var selectedvendors = [];
                        var selectedVendorList = component.get('v.selectedVendorList');

                        var noMailVedors = [];

                        var noContactVendors = [];

                        var isValidEmail = [];

                        selectedVendorList.filter(function(selectedVendor) {
                            selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true ? selectedvendors.push(selectedVendor.Id) : '';

                            (selectedVendor.isEmail == true && selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true) ? noMailVedors.push(selectedVendor.Id): '';
                            (selectedVendor.isContact == true && selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true) ? noContactVendors.push(selectedVendor.Id): '';
                            (selectedVendor.isValidEmail == false && selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true) ? noContactVendors.push(selectedVendor.Id): '';

                        });

                        if (noMailVedors.length) {
                            console.log('no1 mailvendor length');

                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "error",
                                "message": "There is no valid email address for this Primary Contact"
                            });
                            toastEvent.fire();
                        } else if (noContactVendors.length) {
                            console.log('no1 vendor length');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "error",
                                "message": "There is no valid email address for this Primary Contact"
                            });
                            toastEvent.fire();
                        } else if (isValidEmail.length) {
                            console.log('no1 valid length');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "error",
                                "message": "There is no valid email address for this Primary Contact"
                            });
                            toastEvent.fire();
                        } else {
                            if (selectedvendors.length > 0) {

                                $A.createComponents(
                                    [
                                        ["aura:html", {
                                            "tag": "h2",
                                            "body": "RFQ Email Preview",
                                            "HTMLAttributes": {
                                                "class": "slds-text-heading_medium slds-hyphenate"
                                            }
                                        }],
                                        ["c:BT_RFQ_Email_Preview", {
                                            "rfqId": component.get("v.recordId"),
                                            "vendorIds": selectedvendors,
                                            "onSuccess": function(object) {
                                                component.get('v.modalPromise').then(function(modal) {
                                                    modal.close();
                                                }).catch(function(error) {
                                                    console.log(error)
                                                });
                                                $A.get("e.c:BT_SpinnerEvent").setParams({
                                                    "action": "SHOW"
                                                }).fire();
                                                helper.sendRFQEmail(component, event, helper, selectedvendors);
                                            },
                                        }],
                                    ],
                                    function(components, status) {
                                        if (status === 'SUCCESS') {
                                            var modalPromise = component.find('overlayLib').showCustomModal({
                                                header: components[0],
                                                body: components[1],
                                                footer: components[1].find("footer"),
                                                showCloseButton: true,
                                                cssClass: 'mymodal'
                                            });
                                            component.set("v.modalPromise", modalPromise);
                                        }
                                    });
                            } else {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "error",
                                    "title": "Error!",
                                    "message": "Please Select Vendors"
                                });
                                toastEvent.fire();
                                $A.get("e.c:BT_SpinnerEvent").setParams({
                                    "action": "HIDE"
                                }).fire();
                            }
                        }

                    }

                }
            }
        });
        $A.enqueueAction(btadminaction);
    },


    closeQuotelineModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isQuotelinedelete", false);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
    },

    deleteVendors: function(component, event, helper) {
        var isDisabled = component.get("v.isDisabled");
        if (isDisabled == true) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "You cannot delete this RFQ as this RFQ is already Awarded"
            });
            toastEvent.fire();
        } else {
            var vendorList = component.get("v.rfqToVendorList");
            //  alert(vendorList)
            console.log("see : ", vendorList)
            var allcheckbox = [];
            //	alert(component.find("vendorselection").length)
            if (component.find("vendorselection").length == undefined) {
                allcheckbox.push(component.find("vendorselection"));
            } else {
                allcheckbox = component.find("vendorselection");
            }
            //   alert('allcheck'+JSON.stringify(allcheckbox))
            var selectedvendors = [];
            if (vendorList.length > 0) {
                //   alert('enter2')
                //   alert(allcheckbox.length)
                for (var i = 0; i < allcheckbox.length; i++) {
                    //  alert(allcheckbox.length);
                    //   alert(allcheckbox[i].get("v.checked"));
                    if (allcheckbox[i].get("v.checked")) {
                        //   alert('enter')
                        selectedvendors.push(vendorList[allcheckbox[i].get("v.value")].Id);
                    }
                }
            }
            /* else {
                                        //alert(allcheckbox.get("v.checked"));
                                        if (allcheckbox.get("v.checked")) {
                                            selectedvendors.push(vendorList[allcheckbox.get("v.value")].Id);
                                        }
                                    } */

            if (selectedvendors.length > 0) {
                $A.createComponents(
                    [
                        ["aura:html", {
                            "tag": "h2",
                            "body": "Confirmation",
                            "HTMLAttributes": {
                                "class": "slds-text-heading_medium slds-hyphenate "
                            }
                        }],
                        ["lightning:button", {
                            "aura:id": "no_button",
                            "label": "Cancel",
                            "name": "no",
                            "onclick": component.getReference("c.closeRemoveVendor")
                        }],
                        ["lightning:button", {
                            "aura:id": "Yes_button",
                            "label": "Yes",
                            "name": "yes",
                            "variant": "brand",
                            "onclick": component.getReference("c.removeVendors")
                        }]
                    ],
                    function(contant, status) {
                        if (status === "SUCCESS") {
                            var footer = [];
                            footer.push(contant[1]);
                            footer.push(contant[2]);
                            /*	var overlayLib = component.find('overlayLib').showCustomModal({
                     header: contant[0],
                     body: "Are you sure you want to delete this vendor?",
                     footer: footer,
                     showCloseButton: true
                 });
                 component.set("v.modalPromise", overlayLib);*/

                            component.set("v.QuotelinePopupHeader", "Delete Vendors");
                            component.set("v.QuotelinePopupDescription", "Are you sure you want to delete this vendor?");
                            component.set("v.isQuotelinedelete", true);


                        }
                    }
                );
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "Please Select Vendors"
                });
                //  alert('1')
                //    $A.get('e.force:refreshView').fire();
                toastEvent.fire();
                // location.reload();

                /*   $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire(); */
            }
        }
    },

    closeRemoveVendor: function(component, event, helper) {
        component.get('v.modalPromise').then(function(modal) {
            modal.close();
        });
    },

    removeVendors: function(component, event, helper) {

        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var selectedvendors = [];
        var selectedVendorList = component.get('v.selectedVendorList');
        selectedVendorList.filter(function(selectedVendor) {
            selectedVendor.buildertek__IS_VENDOR_SELECTED__c == true ? selectedvendors.push(selectedVendor.Id) : '';
        });
        component.set('v.selectedVendorList', selectedVendorList);
        if (selectedvendors.length > 0) {

            helper.removeVendorLink(component, event, helper, selectedvendors);


        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": "Please Select Vendors"
            });
            toastEvent.fire();
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        }
    },

    addVendors: function(component, event, helper) {
        var isrfqStatus = component.get("v.rfqStatus");
        if (isrfqStatus == 'Accepted' || isrfqStatus == 'Awarded') {
            component.set('v.openModal', true);
        } else {
            var overlayLib;
            $A.get('e.force:refreshView').fire();
            $A.createComponents(

                [

                    ["aura:html", {
                        "tag": "h2",
                        "body": "Add Vendors",
                        "HTMLAttributes": {
                            "class": "slds-text-heading_medium slds-hyphenate",
                            //  "style":"height : 686px !important"
                        }
                    }],
                    ["c:BT_VendorAdder", {
                        "aura:id": "vendorAdder",
                        "onCancel": function() {
                            overlayLib.close();
                        },
                        "savecallback": function(items) {
                            $A.get('e.force:refreshView').fire();

                            $A.get("e.c:BT_SpinnerEvent").setParams({
                                "action": "SHOW"
                            }).fire();
                            overlayLib.close();
                            var selectedvendors = [];
                            for (var i = 0; i < items.length; i++) {
                                selectedvendors.push(items[i].Id);
                            }
                            helper.createVendorLink(component, event, helper, selectedvendors);
                        },
                        "parentId": component.get("v.recordId")
                    }],

                ],
                function(contant, status) {
                    if (status === "SUCCESS") {
                        component.find('overlayLib').showCustomModal({
                            header: contant[0],
                            body: contant[1],
                            showCloseButton: true,
                            cssClass: 'uiModal--large'
                        }).then(function(overlay) {
                            overlayLib = overlay;
                        });
                        component.set("v.overlayLib", overlayLib);
                        $A.get('e.force:refreshView').fire();

                    }
                }
            );

        }
    },

    checkAll: function(component, event, helper) {
        var allcheckbox = component.find("vendorselection");
        var vendorCheckall = component.find("vendorCheckall").get("v.checked");
        var vendorList = component.get("v.rfqToVendorList");
        if (vendorList.length > 0) {
            if (vendorList.length > 1) {
                for (var i = 0; i < allcheckbox.length; i++) {
                    if (vendorCheckall == true) {
                        allcheckbox[i].set("v.checked", vendorCheckall);
                    } else {
                        allcheckbox[i].set("v.checked", false);
                    }
                    //allcheckbox[i].set("v.checked", vendorCheckall);
                }
            } else {
                if (vendorCheckall == true) {
                    allcheckbox.set("v.checked", true);
                } else {
                    allcheckbox.set("v.checked", false);
                }
            }

        }

    },
    expandVendor: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var expandedId = event.getSource().get("v.name");
        var selectedVendorList = component.get('v.selectedVendorList');
        console.log('Expnded id ::', expandedId);
        var i = 0;
        selectedVendorList.filter(function(selectedVendor) {
            if (selectedVendor.Id == expandedId) {
                selectedVendor.buildertek__IS_VENDOR_EXPANDED__c = true;
            }
            if (selectedVendor.buildertek__IS_VENDOR_EXPANDED__c == true) {
                i++;
            }
        });
        component.set('v.selectedVendorList', selectedVendorList);
        if (i == selectedVendorList.length) {
            //console.log('show')
            var expandicon = document.getElementsByClassName(recordId + 'expandGrpIcon_');
            var collapeIcon = document.getElementsByClassName(recordId + 'collapseGrpIcon_');
            collapeIcon[0].style.display = "inline-block";
            expandicon[0].style.display = "none";
        }

    },
    collapseVendor: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var collapsedId = event.getSource().get("v.name");
        var selectedVendorList = component.get('v.selectedVendorList');
        console.log('Collapsed id ::', collapsedId);
        var i = 0;
        selectedVendorList.filter(function(selectedVendor) {
            if (selectedVendor.Id == collapsedId) {
                selectedVendor.buildertek__IS_VENDOR_EXPANDED__c = false;
            }
            if (selectedVendor.buildertek__IS_VENDOR_EXPANDED__c == false) {
                i++;
            }
        });
        component.set('v.selectedVendorList', selectedVendorList);
        if (i == selectedVendorList.length) {
            //console.log('show')
            var expandicon = document.getElementsByClassName(recordId + 'expandGrpIcon_');
            var collapeIcon = document.getElementsByClassName(recordId + 'collapseGrpIcon_');
            expandicon[0].style.display = "inline-block";
            collapeIcon[0].style.display = "none";
        }

    },
    onVendorSelectionChange: function(component, event, helper) {
        var vendorId = event.getSource().get("v.checked");
        //  alert(vendorId);
        if (vendorId == false) {
            component.find("checkAllRFQs").set("v.value", false);
        }
        /*var selectedVendorList = component.get('v.selectedVendorList');
var vendorId = event.getSource().get("v.name");

var count = 0;
var limitExceed=false;
var selectedVendor = selectedVendorList.filter(function(getSelected) {
if(getSelected.buildertek__IS_VENDOR_SELECTED__c){
count+=1;
}
return getSelected.buildertek__IS_VENDOR_SELECTED__c == true;
});
component.set('v.totalSelectedVendor',count);
var selectedVendorLimit;
if(limitExceed){
selectedVendorList.filter(function(records) {
records.Id == vendorId ? records.buildertek__IS_VENDOR_SELECTED__c=false:records;
});
component.set('v.selectedVendorList',selectedVendorList);
}*/
    },

    awardMultipleVendor: function(component, event, helper) {
        var isAwarded = component.get('v.isAwarded');
        var isAccepted = component.get('v.isAccepted');
        var isDisabled = component.get("v.isDisabled");
        // alert('isDisabled.......'+isDisabled);
        if (isDisabled == true) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "This RFQ has already been Awarded."
            });
            toastEvent.fire();
        } else if (isDisabled == false) {
            var toastEvent = $A.get("e.force:showToast");
            if (!isAwarded) {
                var selectedVendorList = component.get('v.selectedVendorList');
                //alert( JSON.stringify(selectedVendorList));
                var vendorList = [];
                for (var i in selectedVendorList) {
                    if (selectedVendorList[i].buildertek__IS_VENDOR_SELECTED__c) {
                        //alert(selectedVendorList[i].Id);
                        vendorList.push(selectedVendorList[i].Id);
                    }
                }
                // alert('vendorList.length'+vendorList.length);
                if (vendorList.length == 1) {
                    //alert('test'+vendorList);
                    var action = component.get("c.checkClosedRFIs");
                    action.setParams({
                        rfqtovendorids: vendorList
                    });
                    action.setCallback(this, function(response) {
                        var fieldSetObj = response.getReturnValue();
                        var vendorrfinotclosedcount = 0;
                        var vendorid = '';

                        //alert(fieldSetObj);
                        for (var i = 0; i < Object.keys(fieldSetObj).length; i++) {
                            //alert(Object.keys(fieldSetObj)[i]);
                            //alert( Object.values(fieldSetObj)[i]);
                            if (Object.values(fieldSetObj)[i] == 'RFIs Not Closed') {
                                vendorrfinotclosedcount = vendorrfinotclosedcount + 1;
                                vendorid = Object.keys(fieldSetObj)[i];
                                break;
                            }
                        }

                        if (vendorrfinotclosedcount == 0) {
                            component.set('v.isMultipleAwardedClick', true);
                            component.set('v.vendorList', vendorList);
                        } else {
                            var vendorname = '';
                            for (var i in selectedVendorList) {
                                if (selectedVendorList[i].Name) {
                                    //alert(selectedVendorList[i].Name);
                                    vendorname = selectedVendorList[i].Name;
                                }
                            }
                            toastEvent.setParams({
                                "type": "error",
                                "title": "All RFIs should be closed",
                                "message": "You must close all RFI's before Awarding this RFQ."

                                // "message": 'All RFIs should be closed for '+vendorname+' before submitting the RFQ.'
                            });
                            toastEvent.fire();
                        }

                    });
                    var action2 = component.get("c.checkStatus");
                    action2.setParams({
                        rfqtovendorids: vendorList
                    });
                    action2.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                            //  alert(response.getReturnValue());
                            if (response.getReturnValue()) {
                                $A.enqueueAction(action);
                            } else {
                                toastEvent.setParams({
                                    "type": "error",
                                    "title": "",
                                    "message": 'You cannot Award to this Vendor as they have not Submitted their RFQ yet.'
                                });
                                toastEvent.fire();
                            }
                        }
                    });

                    $A.enqueueAction(action2);
                    /*  if(isAccepted == true){
                     toastEvent.setParams({
                                "type": "error",
                                "title": "",
                                "message": 'You cannot Awa.'
                            });
                            toastEvent.fire();

                }*/





                    //component.set('v.isMultipleAwardedClick', true);
                    //component.set('v.vendorList', vendorList);
                } else if (vendorList.length > 1) {

                    // component.set('v.MultipleAwardedClick', true);
                    var action = component.get("c.checkClosedRFIs");
                    action.setParams({
                        rfqtovendorids: vendorList
                    });
                    action.setCallback(this, function(response) {
                        var fieldSetObj = response.getReturnValue();
                        var vendorrfinotclosedcount = 0;
                        var vendorid = '';

                        //alert(fieldSetObj);
                        for (var i = 0; i < Object.keys(fieldSetObj).length; i++) {
                            //alert(Object.keys(fieldSetObj)[i]);
                            //alert( Object.values(fieldSetObj)[i]);
                            if (Object.values(fieldSetObj)[i] == 'RFIs Not Closed') {
                                vendorrfinotclosedcount = vendorrfinotclosedcount + 1;
                                vendorid = Object.keys(fieldSetObj)[i];
                                break;
                            }
                        }

                        if (vendorrfinotclosedcount == 0) {
                            component.set('v.MultipleAwardedClick', true);
                            component.set('v.vendorList', vendorList);
                        } else {
                            var vendorname = '';
                            for (var i in selectedVendorList) {
                                if (selectedVendorList[i].Name) {
                                    //alert(selectedVendorList[i].Name);
                                    vendorname = selectedVendorList[i].Name;
                                }
                            }
                            toastEvent.setParams({
                                "type": "error",
                                "title": "All RFIs should be closed",
                                "message": "You must close all RFI's before Awarding this RFQ."

                                // "message": 'All RFIs should be closed for '+vendorname+' before submitting the RFQ.'
                            });
                            toastEvent.fire();
                        }

                    });
                    var action2 = component.get("c.checkStatus");
                    action2.setParams({
                        rfqtovendorids: vendorList
                    });
                    action2.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                            //alert(response.getReturnValue());
                            if (response.getReturnValue()) {
                                $A.enqueueAction(action);
                            } else {
                                toastEvent.setParams({
                                    "type": "error",
                                    "title": "",
                                    "message": 'You cannot Award to this Vendor as they have not Submitted their RFQ yet.'
                                });
                                toastEvent.fire();
                            }
                        }
                    });

                    $A.enqueueAction(action2);


                    /* toastEvent.setParams({
                        "type": "error",
                        "title": "Select Vendor",
                        "message": 'Please select Only One Vendor to Award.'
                    });
                    toastEvent.fire();*/
                } else {
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Select Vendor",
                        "message": 'Please select a Vendor.'
                    });
                    toastEvent.fire();
                }
            }
        } else if (isDisabled == undefined) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "Please Add Vendors for this RFQ."
            });
            toastEvent.fire();

        } else {
            toastEvent.setParams({
                "type": "error",
                "title": "You cannot assign Vendor!",
                "message": 'Quote has been Awarded for this RFQ.'
            });
            toastEvent.fire();
        }
    },
    cancelRFQ: function(component, event, helper) {
        // debugger;
        var isAwarded = component.get('v.isAwarded');
        var isAccepted = component.get('v.isAccepted');
        var toastEvent = $A.get("e.force:showToast");
        if ((isAwarded == false && isAccepted == false) || (isAwarded == undefined && isAccepted == false)) {
            component.set('v.isCancelRFQ', true);
            /*var selectedVendorList = component.get('v.selectedVendorList');
var vendorList = [];
for (var i in selectedVendorList) {
if (selectedVendorList[i].buildertek__IS_VENDOR_SELECTED__c) {
    vendorList.push(selectedVendorList[i].Id);
}
}
if (vendorList.length > 0) {
component.set('v.isCancelRFQ', true);
component.set('v.vendorList', vendorList);
console.log('vendorList::::::',vendorList);
} else {
toastEvent.setParams({
    "type": "error",
    "title": "No Vendor Selected",
    "message": 'Please select at least one Vendor.'
});
toastEvent.fire();
}*/
        } else if (isAccepted == true) {
            toastEvent.setParams({
                "type": "error",
                "title": "You cannot cancel RFQ!",
                "message": 'RFQ has been Accepted.'
            });
            toastEvent.fire();
        } else if (isAwarded == true) {
            toastEvent.setParams({
                "type": "error",
                "title": "You cannot cancel RFQ!",
                "message": 'RFQ has been Awarded.'
            });
            toastEvent.fire();
        }
    },
    cancelvoidRFQ: function(component, event, helper) {
        // debugger;
        var isAwarded = component.get('v.isAwarded');
        var isAccepted = component.get('v.isAccepted');
        var toastEvent = $A.get("e.force:showToast");
        component.set('v.isvoidRFQ', true);
        /*if ((isAwarded == false && isAccepted == false) ||( isAwarded == undefined && isAccepted == false)) {
component.set('v.isCancelRFQ', true);
} else if(isAccepted == true){
toastEvent.setParams({
"type": "error",
"title": "You cannot cancel RFQ!",
"message": 'RFQ has been Accepted.'
});
toastEvent.fire();
}else if(isAwarded == true){
toastEvent.setParams({
"type": "error",
"title": "You cannot cancel RFQ!",
"message": 'RFQ has been Awarded.'
});
toastEvent.fire();
}*/
    },

    /*cancelRFQ: function (component, event, helper) {
debugger;
var isAwarded = component.get('v.isAwarded');
var toastEvent = $A.get("e.force:showToast");
if (isAwarded) {
var selectedVendorList = component.get('v.selectedVendorList');
var vendorList = [];
for (var i in selectedVendorList) {
if (selectedVendorList[i].buildertek__IS_VENDOR_SELECTED__c) {
vendorList.push(selectedVendorList[i].Id);
}
}
if (vendorList.length > 0) {
component.set('v.isCancelRFQ', true);
component.set('v.vendorList', vendorList);
console.log('vendorList::::::',vendorList);
} else {
toastEvent.setParams({
"type": "error",
"title": "No Vendor Selected",
"message": 'Please select at least one Vendor.'
});
toastEvent.fire();
}
} else {
toastEvent.setParams({
"type": "error",
"title": "You cannot cancel RFQ!",
"message": 'RFQ must have Awarded or Accepted.'
});
toastEvent.fire();
}
},*/
    cancelconfirmModelRFQ: function(component, event, helper) {
        component.set('v.isCancelRFQ', false);
        //var vendorList = component.get('v.vendorList');
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        helper.cancelRFQ(component, event, helper);
        //var subject = 'RFQ Cancelation Notice for [ref:' + component.get("v.recordId") + ']';
        /* var contactIds = [];
var action = component.get("c.getSelectedVendorsData");
action.setParams({
vendorId: vendorList
});
action.setCallback(this, function (response) {
var state = response.getState();
if (state === "SUCCESS" && response.getReturnValue()) {
var result = response.getReturnValue();
helper.cancelRFQ(component, event, helper);
/*for (var i in result) {
if (result[i].buildertek__Contact__c != undefined) {
    contactIds.push(result[i].buildertek__Contact__c);
}
}
helper.cancelAcceptedRFQ(component, event, helper, vendorList, contactIds);*/
        /* }
});
$A.enqueueAction(action);*/
    },

    confirmModelRFQ: function(component, event, helper) {
        component.set('v.isCancelRFQ', false);
        var vendorList = component.get('v.vendorList');
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        //var subject = 'RFQ Cancelation Notice for [ref:' + component.get("v.recordId") + ']';
        var contactIds = [];
        var action = component.get("c.getSelectedVendorsData");
        action.setParams({
            vendorId: vendorList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                var result = response.getReturnValue();
                for (var i in result) {
                    if (result[i].buildertek__Contact__c != undefined) {
                        contactIds.push(result[i].buildertek__Contact__c);
                    }
                }
                helper.cancelAcceptedRFQ(component, event, helper, vendorList, contactIds);
            }
        });
        $A.enqueueAction(action);
    },
    cancelModelRFQ: function(component, event, helper) {
        component.set('v.vendorList', []);
        component.set('v.isCancelRFQ', false);
    },
    cancelvoidconfirmModelRFQ: function(component, event, helper) {
        //component.set('v.vendorList', []);
        component.set('v.isvoidRFQ', false);
    },
    voidconfirmModelRFQ: function(component, event, helper) {
        component.set('v.isvoidRFQ', false);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        helper.voidRFQ(component, event, helper);
    },
    confirmMultipleAwards: function(component, event, helper) {
        component.set('v.MultipleAwardedClick', false);
        //  alert("haii");
        component.set('v.isMultipleAwardedClick', false);
        var vendorList = component.get('v.vendorList');
        //  alert('vendorList'+vendorList.length);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var subject = 'Quote has been awarded to you [ref:' + component.get("v.recordId") + ']';
        var contactIds = [];
        var subject = 'Quote has been awarded to you [ref:' + component.get("v.recordId") + ']';
        var action = component.get("c.getSelectedVendorsData");
        action.setParams({
            vendorId: vendorList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                //  alert(state);
                var result = response.getReturnValue();
                // alert(JSON.stringify(result));
                for (var i in result) {
                    if (result[i].buildertek__Contact__c != undefined) {
                        contactIds.push(result[i].buildertek__Contact__c);
                    }
                }
                helper.awardMultipleVendors(component, event, helper, vendorList, "Awarded", subject, contactIds);
            }
        });
        $A.enqueueAction(action);
    },

    cancelMultipleAwards: function(component, event, helper) {
        component.set('v.vendorList', []);
        component.set('v.isMultipleAwardedClick', false);
        component.set('v.MultipleAwardedClick', false);

    },

    compare: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        component.set("v.IsOnLoad", false);
        var vendorList = component.get("v.rfqToVendorList");
        var selectedvendors = component.get('v.selectedVendorList');
        var selectedVendor = selectedvendors.filter(function(getSelected) {
            return getSelected.buildertek__IS_VENDOR_SELECTED__c == true;
        });
        var dynamicClass = '';
        var dynamicStyle = '';
        if (selectedVendor != undefined && selectedVendor.length > 1 && selectedVendor.length <= 6) {
            if (selectedVendor.length == 2) {
                dynamicClass = 'slds-col slds-size_1-of-2';
                dynamicStyle = 'width:49%;margin:1px;';
            } else if (selectedVendor.length == 3) {
                dynamicClass = 'slds-col slds-size_1-of-3';
                dynamicStyle = 'width:33%;margin:1px;';
            } else if (selectedVendor.length == 4) {
                dynamicClass = 'slds-col slds-size_1-of-4';
                dynamicStyle = 'width:24.6%;margin:1px;';
            } else if (selectedVendor.length == 5) {
                dynamicClass = '';
                dynamicStyle = 'margin:1px;';
            } else if (selectedVendor.length == 6) {
                dynamicClass = '';
                dynamicStyle = 'margin:1px;';
            }

            //* slice Name of vendor items to render properly in table
            selectedVendor.forEach(element => {
                console.log('element ',element);
                if (element.hasOwnProperty('buildertek_Vendor_Items_r')) {
                element.buildertek__Vendor_Items__r.forEach(ele => {
                    if(ele.Name.length > 35){
                        ele.Name = ele.Name.slice(0,35)+'...';
                    }
                    
                });
            }
            });
            component.set('v.dynamicStyle', dynamicStyle);
            component.set('v.dynamicClass', dynamicClass);
            component.set("v.isComparePopupOpen", true);
            component.set("v.showVendorActions", false);
            component.set('v.selectedVendor', selectedVendor);
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        } else if (selectedVendor.length > 6) {
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
            var errorMessage = 'You cannot compare more than 6 vendors';
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: errorMessage,
                type: 'warning',
            });
            toastEvent.fire();
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": "Please select at least two Vendors."
            });
            toastEvent.fire();
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
            $A.get('e.force:refreshView').fire();
        }

    },
    closeModel: function(component, event, helper) {
        component.set('v.isComparePopupOpen', false);
    },

    attachDocument: function(component, event, helper) {

        component.set('v.isAttachDocClick', true);
    },
    doCancel: function(component, event, helper) {
        component.set("v.fileName", '');
        component.set("v.selectedfilesFill", []);
        component.set("v.isAttachDocClick", false);

    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        //alert(event.getSource().get("v.files").length);
        if (event.getSource().get("v.files").length > 0) {
            // fileName = event.getSource().get("v.files")[0]['name'];
        }

        component.set("v.selectedfileslist", event.getSource().get("v.files"));
        /*var xyz  =   [];
if(component.get("v.selectedfileslist")!=null){
xyz = component.get("v.selectedfileslist");
xyz.push(event.getSource().get("v.files"));
component.set("v.selectedfileslist",xyz);
}else{
component.set("v.selectedfileslist",event.getSource().get("v.files"));
}*/


        var fileCount = event.getSource().get("v.files").length;


        var files = '';
        var mapData = [];
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) {
                fileName = event.getSource().get("v.files")[i]["name"];
                var obj = {};
                obj['Name'] = fileName;
                if (i == 0) {
                    files = fileName;
                } else {
                    files = files + ',' + fileName;
                }
                mapData.push(obj);
            }
        } else {
            files = fileName;
        }
        component.set("v.fileName", files);
        component.set("v.selectedfilesFill", mapData);
        //alert(typeof event.getSource().get("v.files"));
        //component.set("v.fileName", fileName);
    },


    addFiles: function(component, event, helper) {
        var fills = component.get("v.selectedfilesFill");
        if (fills.length > 0) {

            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "SHOW"
            }).fire();
            component.set("v.isAttachDocClick", false);
            var recid = component.get("v.recordId");
            //alert(recid);
            helper.uploadHelper(component, event, recid, helper);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Please Select files to add',
                type: 'error',
                duration: '5000',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    },



    uploadFile1: function(component, event, helper) {
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "Upload File",
                    "HTMLAttributes": {
                        "class": "slds-text-heading_medium slds-hyphenate"
                    }
                }],
                ["c:BT_AddFiles", {
                    "mainObjectFieldAPI": component.get("v.objectAPI"),
                    "mainObjectId": component.get("v.recordId"),
                    "selectedFiles": component.get("v.selectedFiles"),
                    "onCancel": function() {
                        component.get('v.modalPromise').then(function(modal) {
                            modal.close();
                        });
                        $A.get('e.force:refreshView').fire();
                    },
                    "onSuccess": function(file) {
                        component.get('v.modalPromise').then(function(modal) {
                            modal.close();
                        });

                        var selectedFiles = [];
                        for (var i = 0; i < file.length; i++) {
                            selectedFiles.push({
                                "Id": file[i].Id,
                                "Name": file[i].Name
                            });
                        }
                        //alert('selectedFiles ---------> '+selectedFiles.length);
                        //component.set("v.selectedFiles", selectedFiles);

                        var action;
                        action = component.get("c.linkRFQDocuments");
                        action.setParams({
                            "files": selectedFiles,
                            "RFQid": component.get("v.recordId")
                        });
                        action.setCallback(this, function(response) {
                            if (response.getState() === "SUCCESS") {
                                $A.get("e.c:BT_SpinnerEvent").setParams({
                                    "action": "SHOW"
                                }).fire();
                                helper.getdata(component, event, helper);

                            }
                        });
                        $A.enqueueAction(action);

                        $A.get('e.force:refreshView').fire();
                    }
                }],

            ],
            function(components, status) {
                if (status === 'SUCCESS') {

                    var modalPromise = component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer: components[1].find("footer"),
                        showCloseButton: true,
                        closeCallback: function() {

                        }
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            });
    },
    closeStatusModel: function(component, event, helper) {
        component.set('v.openModal', false);
    },

    uploadFileToVendor: function(component, event, helper) {
        var activeRFQVendor = component.get("v.activeRFQVendor");
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "Upload File",
                    "HTMLAttributes": {
                        "class": "slds-text-heading_medium slds-hyphenate"
                    }
                }],
                ["c:BT_UploadFiles", {
                    "mainObjectFieldAPI": component.get("v.objectAPI"),
                    "mainObjectId": component.get("v.recordId"),
                    "onCancel": function() {
                        component.get('v.modalPromise').then(function(modal) {
                            modal.close();
                        });
                    },
                    "onSuccess": function(file) {
                        component.get('v.modalPromise').then(function(modal) {
                            modal.close();
                        });

                        var action;
                        action = component.get("c.linkRFQDocumentToVendor");
                        action.setParams({
                            "fileId": file.Id,
                            "vendorId": activeRFQVendor.Id
                        });
                        action.setCallback(this, function(response) {
                            if (response.getState() === "SUCCESS") {
                                $A.get("e.c:BT_SpinnerEvent").setParams({
                                    "action": "SHOW"
                                }).fire();
                                helper.getdata(component, event, helper);

                            }
                        });
                        $A.enqueueAction(action);

                        $A.get('e.force:refreshView').fire();
                    }
                }],

            ],
            function(components, status) {
                if (status === 'SUCCESS') {

                    var modalPromise = component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer: components[1].find("footer"),
                        showCloseButton: true,
                        closeCallback: function() {

                        }
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            });
    },
    filelist: function(component, event, helper) {
        //alert('Vendor Id   '+event.currentTarget.dataset.rowid);
        var vendorId = event.target.id;
        var recordId = component.get("v.recordId");
        //alert('vendr'+vendorId);
        var action = component.get("c.getContentDocs1");
        action.setParams({
            arecordId: vendorId,
            rfqID: recordId
        });
        action.setCallback(this, function(actionResult) {
            component.set('v.files', actionResult.getReturnValue());
            var fileslist = component.get('v.files');
            //alert('fileslist'+ fileslist.length);
            if (fileslist.length > 0) {
                component.set("v.Isfiles", true);
                component.set("v.noFiles", false);

            } else {
                component.set("v.Isfiles", false);
                component.set("v.noFiles", true);
            }
        });
        $A.enqueueAction(action);
    },
    closefilesModel: function(component, event, helper) {
        component.set("v.Isfiles", false);
        component.set("v.noFiles", false);
    },

    // function for clear the Record Selaction
    clear: function(component, event, heplper) {
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.selectedfilesFill");

        for (var i = 0; i < AllPillsList.length; i++) {
            if (AllPillsList[i].Name == selectedPillId) {
                AllPillsList.splice(i, 1);
                component.set("v.selectedfilesFill", AllPillsList);
            }
        }
    },

    refreshAll: function(component, event, helper) {
        $A.enqueueAction(component.get("c.initialize"));
    },




    AddContactsButtonClick: function(component, event, helper) {
        var recordid = event.target.id.split('_')[1];
        var accrecordId = event.target.id.split('_')[0];

        var action = component.get("c.saverfqvendorcontacts");
        action.setParams({
            recordid: recordid,
            accrecordId: accrecordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var selectedIds = component.get("v.listOfSelectedSOVIds");
            //  alert(selectedIds);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // alert(JSON.stringify( result.length));
                for (var k = 0; k < result.length; k++) {
                    selectedIds.push(result[k].buildertek__Contact__c)
                }
            }




            var compon = component.get('v.Contractids');
            var selectedVendorList = component.get('v.selectedVendorList');
            component.set("v.iscontactModalOpen", true);
            component.set('v.vendorId', recordid);
            // component.set('v.accrecordid', accrecordId)
            var pageNumber = component.get("v.PageNumber");
            var pageSize = component.get("v.PageSize");
            var action = component.get("c.getContactData");
            action.setParams({
                "pageNumber": pageNumber,
                "pageSize": pageSize,
                "recordId": accrecordId,
                "vendorRFQId": recordid
            });
            action.setCallback(this, function(result) {
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.IsSpinner", false);
                    var resultData = result.getReturnValue();
                    component.set("v.ContactList", resultData.contactList);
                    if (resultData.contactList.length == 0) {
                        component.set("v.iscontactModalOpen", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Error",
                            "title": "Error",
                            "message": "No contacts for the Account."
                        });
                        toastEvent.fire();
                    }
                    var recordIds = [];
                    for (var i = 0; i < resultData.contactList.length; i++) {
                        if (selectedIds.indexOf(resultData.contactList[i].Id) < 0) {
                            resultData.contactList[i].isChecked = false;
                        } else {
                            recordIds.push(resultData.contactList[i].Id)
                            resultData.contactList[i].isChecked = true;
                        }
                    }
                    if (recordIds.length == resultData.contactList.length) {
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

        });
        $A.enqueueAction(action);

    },
    handleNext: function(component, event, helper) {
        //alert(component.find('headCheckRFQ').("v.checked"))
        component.set("v.IsSpinner", true);
        component.find("headCheckRFQ").set("v.checked", false);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.PageSize");
        pageNumber++;
        helper.getContactList(component, pageNumber, pageSize);
    },

    handlePrev: function(component, event, helper) {
        component.set("v.IsSpinner", true);
        component.find("headCheckRFQ").set("v.checked", false);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.PageSize");
        pageNumber--;
        helper.getContactList(component, pageNumber, pageSize);
    },

    onSelectChange: function(component, event, helper) {
        var page = 1
        var pageSize = component.get("v.PageSize");
        helper.getContactList(component, page, pageSize);
    },

    selectRfq: function(component, event, helper) {
        var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.listOfSelectedSOVIds");
        var getAllId = component.find("checkRFQ");
        if (checkbox.get("v.checked")) {
            if (selectedRfqIds.indexOf(checkbox.get("v.name")) == -1) {
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if (!Array.isArray(getAllId)) {
                if (!component.find("headCheckRFQ").get("v.checked")) {
                    component.find("headCheckRFQ").set("v.checked", true);
                }
            } else {
                if (selectedRfqIds.length == getAllId.length) {
                    if (!component.find("headCheckRFQ").get("v.checked")) {
                        component.find("headCheckRFQ").set("v.checked", true);
                    }
                }
            }

            var sovlist = component.get("v.ContactList");
            for (var i = 0; i < sovlist.length; i++) {
                if (sovlist[i].RecordId == checkbox.get("v.name")) {
                    sovlist[i].isChecked = checkbox.get("v.checked");
                }
            }
            component.set("v.ContactList", sovlist);

        } else {
            if (component.find("headCheckRFQ").get("v.checked")) {
                component.find("headCheckRFQ").set("v.checked", false);
            }
            if (selectedRfqIds.indexOf(checkbox.get("v.name")) > -1) {
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index, 1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedSOVIds", selectedRfqIds);

    },

    selectAllRfq: function(component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.ContactList")));
        // alert( JSON.stringify(rfqRecordList));
        var getAllId = component.find("checkRFQ");
        var recordIds = component.get("v.listOfSelectedSOVIds");
        if (checkStatus) {
            if (rfqRecordList.length) {
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", true);
                    var Id = component.find("checkRFQ").get("v.name");
                    if (recordIds.indexOf(Id) == -1) {
                        recordIds.push(Id)
                    }
                } else {
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", true);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if (recordIds.indexOf(Id) == -1) {
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedSOVIds", recordIds);
                //alert(component.get("v.listOfSelectedSOVIds").length);
            }
        } else {
            if (rfqRecordList.length) {
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", false);
                    var Id = component.find("checkRFQ").get("v.name");
                    if (recordIds.indexOf(Id) > -1) {
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index, 1);
                    }
                } else {
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", false);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if (recordIds.indexOf(Id) > -1) {
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index, 1);
                        }
                    }
                }
                component.set("v.listOfSelectedSOVIds", recordIds);
            }
        }
        console.log(recordIds);
    },
    close: function(component, event, helper) {
        // component.find("headCheckRFQ").set("v.checked", true);
        component.set("v.iscontactModalOpen", false);
        //$A.get("e.force:closeQuickAction").fire();
    },

    savecontact: function(component, event, helper) {
        component.set("v.Spinner", true);
        var recordIds = [];
        var recordId = component.get('v.vendorId');
        var contractId = component.get("v.listOfSelectedSOVIds");
        var getAllId = component.find("checkRFQ");
        var ContactList = component.get("v.ContactList");
        var action = component.get("c.savecontacts");
        action.setParams({
            contractId: contractId,
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                var result = response.getReturnValue();
                //alert(JSON.stringify(result));
                component.set("v.iscontactModalOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "Success",
                    "message": "Record saved successfully."
                });
                toastEvent.fire();

            }
            component.set("v.Contractids", result);
            component.set("v.listOfSelectedSOVIds", []);
            $A.get('e.force:refreshView').fire();
            // location.reload()
            // window.reload();


        });
        $A.enqueueAction(action);

    },


    filelist1: function(component, event, helper) {
        var rfqvendorId = event.target.id.split('_')[1];
        var vendorId = event.target.id.split('_')[0];
        var recordId = component.get("v.recordId");
        var action = component.get("c.getContentDocs1");
        action.setParams({
            arecordId: vendorId,
            rfqID: recordId
        });
        action.setCallback(this, function(actionResult) {
            component.set('v.files', actionResult.getReturnValue());
            var urlEvent = $A.get("e.force:navigateToURL");
            // alert("hai");
            urlEvent.setParams({
                // "url": '/lightning/r/buildertek__RFQ_To_Vendor__c/'+rfqvendorId+'/related/AttachedContntDocuments/view'
                "url": '/lightning/r/buildertek__RFQ_To_Vendor__c/' + rfqvendorId + '/related/AttachedContentDocuments/view'
            });
            urlEvent.fire();
            //  var fileslist = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/buildertek__RFQ_To_Vendor__c/'+rfqvendorId+'/related/AttachedContntDocuments/view';
            // alert('fileslist'+  JSON.stringify(fileslist));
            /*   if(fileslist.length > 0){
component.set("v.Isfiles",true);
component.set("v.noFiles",false);

}else{
component.set("v.Isfiles",false);
component.set("v.noFiles",true);
}*/
        });
        $A.enqueueAction(action);
    },


    closePortalContactScreen: function(component, event, helper) {
        component.set("v.isNonPortalContactPopUP", false);

    },


})