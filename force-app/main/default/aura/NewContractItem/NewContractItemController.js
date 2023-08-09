({
    init: function (component, event, helper) {
        component.set("v.Spinner", true);
        var page = component.get("v.page") || 1;
        helper.getGroups(component, event, helper, page);
        helper.fetchpricebooks(component, event, helper);
    },

    navigate: function (component, event, helper) {
        component.set("v.Spinner", true);
        var page = component.get("v.page") || 1;
        // get the previous button label  
        var direction = event.getSource().get("v.label");
        // set the current page,(using ternary operator.)  
        page = direction === "Previous" ? (page - 1) : (page + 1);
        // call the helper function
        helper.getGroups(component, event, helper, page);
    },
    changefamily: function (component, event, helper) {

        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({ "recordByEvent": product });
        compEvent.fire();
        component.set('v.newContractLine.Name', '');

        component.set('v.newContractLine.buildertek__Unit_Price__c', '');


    },

    changeEvent: function (component, event, helper) {
        var group = component.find('groupId');
        group.set("v._text_value", '');

        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({ "recordByEvent": product });
        compEvent.fire();
        component.set('v.newContractLine.Name', '');
        component.set('v.newContractLine.buildertek__Contract_Item_Group__c', null);
        component.set('v.newContractLine.buildertek__Cost_Code__c', null);
        component.set('v.newContractLine.buildertek__Unit_Price__c', '');
        component.set('v.newContractLine.buildertek__Quantity__c', 1);

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

    groupLoaded: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "HIDE" }).fire();
    },

    doView: function (component, event, helper) {
        ////console.log(event.currentTarget.dataset.record);
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        editRecordEvent.setParams({
            "recordId": event.currentTarget.dataset.record
        });
        editRecordEvent.fire();
    },

    newGroup: function (component, event, helper) {
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "New Contract Group",
                    "HTMLAttributes": {
                        "class": "slds-text-heading_medium slds-hyphenate"
                    }
                }],
                ["c:BT_NewContractGroup", {
                    "contractId": component.get("v.recordId"),
                    "onSuccess": function () {
                        var page = component.get("v.page") || 1;
                        helper.getGroups(component, event, helper, page);
                    }
                }],

            ], function (components, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer: components[1].find("footer"),
                        showCloseButton: true,
                        cssClass: 'slds-modal_medium'
                    });

                }
            });
    },

    handleSaveSuccess: function (component, event, helper) {
        if (event) {
            if (event.getParams().message && event.getParams().message.indexOf('was saved') != -1) {
                //$A.enqueueAction(component.get('c.init'));
                var page = component.get("v.page") || 1;
                helper.getGroups(component, event, helper, page);
                $A.get("e.force:refreshView").fire();
            }
        }
    },

    saveContractLineRecord: function (component, event, helper) {
        component.set("v.Spinner", true);
        var quoteObject = component.get("v.newContractLine");
        var recordId = component.get("v.recordId");
        component.set("v.newContractLine.buildertek__Contract__c", recordId);
        //quoteObject.buildertek__Contract__c = component.get("v.recordId");

        var action = component.get("c.saveContractLineItem");
        action.setParams({ "contractRecord": JSON.stringify(quoteObject) });
        action.setCallback(this, function (respo) {
            if (component.isValid() && respo.getState() === "SUCCESS") {
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var result = respo.getReturnValue();
                var group = component.find('groupId');
                group.set("v._text_value", '');
                var costCode = component.find('costCodeId');
                costCode.set("v._text_value", '');
                var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({ "recordByEvent": product });
                compEvent.fire();
                component.find('contractLineID').set("v.value", '');
                component.set('v.newContractLine.Name', '');
                component.set('v.newContractLine.buildertek__Unit_Price__c', null);
                component.set('v.newContractLine.buildertek__Cost_Code__c', null);
                component.set('v.newContractLine.buildertek__Contract_Item_Group__c', null);
                component.set('v.newContractLine.buildertek__Quantity__c', null);
                window.setTimeout(
                    $A.getCallback(function () {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Contract Line created successfully',
                            messageTemplate: "Contract Line {0} created successfully.",
                            messageTemplateData: [{
                                url: baseURL + '/lightning/r/buildertek__Contract_Item__c/' + escape(result.Id) + '/view',
                                label: result.Name,
                            }],
                            type: 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }), 3000
                );
                component.set("v.Spinner", false);
                component.refreshData();
                $A.get('e.force:refreshView').fire();

            }
        });
        $A.enqueueAction(action);
    },
    handleEvent: function (component, event, helper) {
        var message = event.getParam("message");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "",
            "message": message,
            "type": "success"
        });
        component.refreshData();
        $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "HIDE" }).fire();
    },

    handleComponentEvent: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.newContractLine.Name", selectedAccountGetFromEvent.Name);
        component.set("v.newContractLine.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);

        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
        // component.set("v.BudgetLine.buildertek__Product__r.Name",selectedAccountGetFromEvent.Name);
    },

    editQuote: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.id;
        //alert('recordId ---------> '+recordId);
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
    },

    deleteQuote: function (component, event, helper) {
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        component.set("v.isOpen", true);
        var recordId = event.currentTarget.dataset.id;
        //alert('recordId ---------> '+recordId);
        component.set("v.quoteItemId", recordId);

    },

    // handleSelectAll : function (component, event, helper) {
    //     var checkvalue = component.find("selectAll").get("v.value");
    //     var checkQuoteItem = component.find("checkQuoteItem"); 
    //     if(checkvalue == true){
    //         for(var i=0; i<checkQuoteItem.length; i++){
    //             checkQuoteItem[i].set("v.value",true);
    //         }
    //     }
    //     else{ 
    //         for(var i=0; i<checkQuoteItem.length; i++){
    //             checkQuoteItem[i].set("v.value",false); 
    //         }
    //     }    
    // },

    handleSelectAll: function (component, event, helper) {
        //var groupName = event.getSource().get("v.value");
        var totalRecords = component.get('v.TotalRecords');
        var records = totalRecords.tarTable.ListOfEachRecord;
        let groupIds = new Set()
        let groupIdsToRemove = new Set()
        for (var i in totalRecords.groups) {
            if (totalRecords.groups[i].isSelected != undefined && totalRecords.groups[i].isSelected) {
                groupIds.add(totalRecords.groups[i].Id);
            } else {
                groupIdsToRemove.add(totalRecords.groups[i].Id);
            }
        }

        for (var i in records) {
            if (groupIds.has(records[i].groupId)) {
                records[i].isSelected = true;
            } else if (groupIdsToRemove.has(records[i].groupId)) {
                records[i].isSelected = false;
            }
        }
        component.set('v.TotalRecords', totalRecords);
        // var checkvalue = component.find("selectAll").get("v.value");
        // var checkQuoteItem = component.find("checkQuoteItem");

        // if (checkvalue == true) {
        //     for (var i = 0; i < checkQuoteItem.length; i++) {
        //         checkQuoteItem[i].set("v.value", true);
        //     }
        // } else {
        //     for (var i = 0; i < checkQuoteItem.length; i++) {
        //         checkQuoteItem[i].set("v.value", false);
        //     }
        // }
    },

    // unCheckAll : function (component, event, helper) {
    //     var checkvalue = component.find("selectAll");
    //     var selectedRec = event.getSource().get("v.value");
    //     if (selectedRec == true) {
    //         checkvalue.set("v.value", false);    
    //     }
    // },

    unCheckAll: function (component, event, helper) {
        var selectedId = event.getSource().get("v.text");
        var totalRecords = component.get('v.TotalRecords');
        var records = totalRecords.tarTable.ListOfEachRecord;
        let deSelectGroup = new Set()

        for (var i in records) {
            if (selectedId === records[i].recordId) {
                if (records[i].isSelected === false) {
                    deSelectGroup.add(records[i].groupId);
                }
            }
        }

        for (var i in totalRecords.groups) {
            if (deSelectGroup.has(totalRecords.groups[i].Id)) {
                totalRecords.groups[i].isSelected = false;
            }
        }
        component.set('v.TotalRecords', totalRecords);
        // var checkQuoteItem = component.find("checkQuoteItem");
        // var checkvalue = component.find("selectAll");
        // var checkBool = 0;

        // for (var i = 0; i < checkQuoteItem.length; i++) {
        //     if (checkQuoteItem[i].get("v.value")) {
        //         checkBool++;
        //     }
        // }

        // if (checkBool == checkQuoteItem.length) {
        //     checkvalue.set("v.value", true);
        // } else {
        //     checkvalue.set("v.value", false);
        // }

    },

    deleteSelectedContractItem: function (component, event, helper) {
        //alert('hiiiiiii');
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var contractIds = [];

        var delId = [];
        var getAllId = component.find("checkQuoteItem");
        if (!Array.isArray(getAllId)) {
            if (getAllId.get("v.value") == true) {
                contractIds.push(getAllId.get("v.text"));
            }
        } else {
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    contractIds.push(getAllId[i].get("v.text"));
                }
            }
        }
        if (contractIds.length > 0) {
            var action = component.get('c.deleteSelectedItems');
            action.setParams({
                "recordIds": contractIds
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
                                message: 'Selected Contract Lines was deleted',
                                type: 'success',
                                duration: '10000',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }), 3000
                    );
                    window.setTimeout(
                        $A.getCallback(function () {
                            document.location.reload(true);
                        }), 4000
                    );
                    /*var checkvalue = component.find("selectAll").set("v.value", false);
                    var page = component.get("v.page") || 1;
                    helper.getBudgetGroups(component, event, helper, page);*/
                }
            });
            $A.enqueueAction(action);
        } else {
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Please Select Contract Line!",
                "message": "Please select the Contract Line you would like to Delete.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
        }

    },


    closeModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },

    deleteQuoteItems: function (component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get("v.quoteItemId");
        //alert('recordId ----------> '+recordId);
        var action = component.get("c.deleteQuoteItem");
        action.setParams({ "quoteId": recordId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.isOpen", false);
                $A.get("e.force:refreshView").fire();
                window.setTimeout(
                    $A.getCallback(function () {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Contract Line was deleted',
                            messageTemplate: "Contract Line {0} was deleted.",
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
                //$A.enqueueAction(component.get('c.init'));
                var page = component.get("v.page") || 1;
                helper.getGroups(component, event, helper, page);
                //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();

            }
        });
        $A.enqueueAction(action);
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
            var finStrings = component.get("v.finalString");
            var delId = {};
            var newId = {};
            if (finStrings == null) {
                delId = { "Id": recordId }
                component.set("v.finalString", delId);
            } else {
                var isVal = 'True';
                for (var k = 0; k < quoteList.length; k++) {
                    if (quoteList[k].Id == recordId) {
                        newId = component.get("v.finalString");
                        isVal = 'false';
                    }
                }
                if (isVal == 'True') {
                    newId = { "Id": recordId };
                    component.set("v.finalString", newId);
                }

            }
            var finString = component.get("v.finalString");
            var fieldName = component.get("v.fieldName");
            var getAllId = component.find("inputId");
            if (!Array.isArray(getAllId)) {
                if (getAllId.get("v.value") != null) {
                    if (finString.Id == recordId) {
                        finString[fieldName] = getAllId.get("v.value");
                        quoteList.push(finString);
                    } else {
                        //alert('else statement');
                        var isValue = 'True';
                        for (var l = 0; l < quoteList.length; l++) {
                            if (quoteList[l].Id == recordId) {
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
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") != null) {
                        if (finString.Id == recordId) {
                            finString[fieldName] = getAllId[i].get("v.value");
                            quoteList.push(finString);
                        } else {
                            //alert('else statement -->');
                            newId[fieldName] = getAllId[i].get("v.value");
                            quoteList.push(newId);
                        }
                    }
                }
            }
            component.set("v.datalist", quoteList);
            component.set("v.showButtons", true);

            var action = component.get("c.prepareString");
            action.setParams({
                "contractString": JSON.stringify(quoteList),
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    //console.log('result ---------> '+result);
                    component.set("v.contractItemList", result);

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
        //$A.enqueueAction(component.get('c.init'));
        var page = component.get("v.page") || 1;
        helper.getGroups(component, event, helper, page);
    },

    SaveEditedValues: function (component, event, helper) {
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        component.set("v.Spinner", true);
        var recordId = component.get("v.quoteItemId");
        var action = component.get("c.saveUpdatedValues");
        action.setParams({
            "contractItemList": component.get("v.contractItemList")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isEditMode", false);
                component.set("v.showButtons", false);
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
                //$A.enqueueAction(component.get('c.init'));
                var page = component.get("v.page") || 1;
                helper.getGroups(component, event, helper, page);
            }
        });
        $A.enqueueAction(action);
    },
    //mass Functionality start

    // onclickDuplicate: function (component, event, helper) {
    //     var currentId = event.currentTarget.getAttribute("data-id");
    //     component.set("v.currentId", currentId);
    //     component.set("v.isDuplicate", true);

    // },

    onclickDuplicate: function(component, event, helper) {
        var currentId = event.currentTarget.getAttribute("data-id");
        component.set("v.currentId", currentId);
        component.set("v.PopupHeader", "Duplicate Quote Line");
        component.set("v.PopupDescription", "Are you sure you want to duplicate this Quote Line?");
        component.set("v.isDuplicate", true);
    },

    closeDuplicateModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isDuplicate" attribute to "Fasle"  
        component.set("v.isOpen", false);
        component.set("v.isDuplicate", false);
        component.set("v.currentId", "");
    },

    duplicateContract: function (component, event, helper) {
        console.log('duplicateContract');
        console.log('spinnner value ::', component.get("v.Spinner"));
        // component.set("v.Spinner", true);
        $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "SHOW" }).fire();
        console.log('spinnner value ::', component.get("v.Spinner"));
        component.set("v.isDuplicate", false);
        var currentId = component.get("v.currentId");
        if (currentId != "" && currentId != undefined) {
            var checkvalue = component.find("selectAll");
            var duplicateRecs = [];
            duplicateRecs.push(currentId);
            console.log('duplicateRecs', JSON.stringify(duplicateRecs));
            var action = component.get("c.duplicateContractLineItem");
            action.setParams({
                "contractLineRecords": duplicateRecs
            });
            action.setCallback(this, function (respo) {
                console.log('response is : ', respo.getState());
                if (respo.getState() === "SUCCESS") {
                    // checkvalue.set("v.value", false);
                    component.set("v.currentId", "");
                    $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "HIDE" }).fire();
                    $A.get('e.force:refreshView').fire();
                    window.setTimeout(
                        $A.getCallback(function () {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: 'Duplicate records for selected contract items created successfully.',
                                type: 'success',
                                duration: '5000',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }), 1000
                    );
                    var page = component.get("v.page") || 1;
                    helper.getGroups(component, event, helper, page);
                    //component.set("v.Spinner",false);
                }

            });
            $A.enqueueAction(action);
        }
    },
    onClickMassUpdateCancel: function (component, event, helper) {
        component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
        component.set("v.isChangeData", false);
        component.set("v.Spinner", true);
        var page = component.get("v.page") || 1;
        helper.getGroups(component, event, helper, page);
    },

    onClickMassUpdate: function (component, event, helper) {
        component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
        if (component.get("v.enableMassUpdate") == false && component.get("v.isChangeData")) {
            console.log(component.get("v.Spinner"));
            component.set("v.Spinner", true);
            console.log(component.get("v.Spinner"));
            var TotalRecords = component.get("v.TotalRecords");
            var ListOfEachRecord = TotalRecords.tarTable.ListOfEachRecord;
            var ListOfEachRecordLength = ListOfEachRecord.length;
            var newMassQi = [];
            console.log('@@ originalValue length :: ', ListOfEachRecordLength, '   @@ originalValue :: ', JSON.stringify(ListOfEachRecord));

            for (var i = 0; i < ListOfEachRecordLength; i++) {
                var newMassQuoteItem = {};
                newMassQuoteItem.sobjectType = 'buildertek__Quote_Item__c';
                for (var j = 0; j < ListOfEachRecord[i].recordList.length; j++) {
                    if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Quantity__c') {
                        newMassQuoteItem.buildertek__Quantity__c = ListOfEachRecord[i].recordList[j].originalValue;
                    } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Unit_Price__c') {
                        newMassQuoteItem.buildertek__Unit_Price__c = ListOfEachRecord[i].recordList[j].originalValue;
                    }
                }

                newMassQuoteItem.Id = ListOfEachRecord[i].recordId;
                newMassQi.push(newMassQuoteItem);

            }
            console.log('update list :::', JSON.stringify(newMassQi));
            if (newMassQi.length > 0) {

                var action = component.get("c.massUpdateContractLineItem");
                action.setParams({ "contractLineRecords": JSON.stringify(newMassQi) });
                action.setCallback(this, function (respo) {
                    console.log('response is : ', respo.getState());
                    component.set("v.isChangeData", false);
                    if (respo.getState() === "SUCCESS") {
                        $A.get('e.force:refreshView').fire();
                        window.setTimeout(
                            $A.getCallback(function () {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    mode: 'sticky',
                                    message: 'Contract Line Updated successfully',
                                    type: 'success',
                                    duration: '10000',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                            }), 3000
                        );
                        var page = component.get("v.page") || 1;
                        helper.getGroups(component, event, helper, page);
                    }
                });
                $A.enqueueAction(action);
            }
        }

    },

    expandCollapseGroups: function (component, event, helper) {
        var quoteId = component.get("v.quoteId")
        var grpIndex = event.currentTarget.dataset.grpindex;
        var expandicon = document.getElementsByClassName(quoteId + ' expandGrpIcon_' + grpIndex);
        var collapeIcon = document.getElementsByClassName(quoteId + ' collapseGrpIcon_' + grpIndex);
        var className = quoteId + " groupRows_" + grpIndex;
        var grpRows = document.getElementsByClassName(className);
        var allGroups = component.get("v.TotalRecords").groups;
        console.log(expandicon[0].style.display)
        console.log(collapeIcon[0].style.display)
        if (expandicon[0].style.display == "inline-block" && collapeIcon[0].style.display == "none") {
            component.set("v.isExpandGrp", true);
            expandicon[0].style.display = 'none';
            collapeIcon[0].style.display = 'inline-block';

            if (!expandicon[0].classList.contains('hideExpandIcon')) {
                expandicon[0].classList.add('hideExpandIcon')
            }
            if (expandicon[0].classList.contains('hideExpandIconhideCollapseIcon')) {
                expandicon[0].classList.remove('hideExpandIconhideCollapseIcon')
            }
            for (var i = 0; i < grpRows.length; i++) {
                var item = grpRows[i];
                if (item.style.display == "none") {
                    item.style.display = 'table-row';
                }
            }
            var hideCollapseIconEles = document.getElementsByClassName(quoteId + ' hideExpandIcon')
            if (hideCollapseIconEles.length == allGroups.length) {
                var expandallicon = document.getElementsByClassName('expandAllBtn_' + quoteId);
                var collapeallIcon = document.getElementsByClassName('CollapeseAllBtn_' + quoteId);
                collapeallIcon[0].style.display = "inline-block";
                expandallicon[0].style.display = "none";
            }


        } else if (expandicon[0].style.display == "none" && collapeIcon[0].style.display == "inline-block") {
            collapeIcon[0].style.display = 'none';
            expandicon[0].style.display = 'inline-block';

            if (!expandicon[0].classList.contains('hideExpandIconhideCollapseIcon')) {
                expandicon[0].classList.add('hideExpandIconhideCollapseIcon')
            }
            if (expandicon[0].classList.contains('hideExpandIcon')) {
                expandicon[0].classList.remove('hideExpandIcon')
            }
            for (var i = 0; i < grpRows.length; i++) {
                var item = grpRows[i];
                if (item.style.display == "table-row") {
                    item.style.display = 'none';
                }
            }
            var hideExpandIconEles = document.getElementsByClassName(quoteId + ' hideExpandIconhideCollapseIcon')
            if (hideExpandIconEles.length == allGroups.length) {
                var expandallicon = document.getElementsByClassName('expandAllBtn_' + quoteId);
                var collapeallIcon = document.getElementsByClassName('CollapeseAllBtn_' + quoteId);
                expandallicon[0].style.display = "inline-block";
                collapeallIcon[0].style.display = "none";
            }
        }

    },

})