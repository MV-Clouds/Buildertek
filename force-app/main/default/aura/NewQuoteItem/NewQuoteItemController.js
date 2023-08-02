({
    initialize: function (component, event, helper) {

    },

    doInit: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        console.log('New Quote');
        //var groupFilter = "buildertek__Quote__c ='"+component.get("v.recordId")+"'";
        //component.set("v.groupFilter",groupFilter);
        //component.set("v.Spinner", true);
        var page = component.get("v.page") || 1
        helper.getGroups(component, event, helper, page);
        helper.fetchPickListVal(component, event, helper);
        helper.fetchpricebooks(component, event, helper);
        helper.getQuoteInfo(component, event, helper);
        //helper.updateMarkupOnUI(component, event, helper, page);
    },

    navigate: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
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
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        component.set('v.newQuote.Name', '');
        component.set('v.newQuote.buildertek__Unit_Cost__c', '');
        component.set('v.newQuote.buildertek__Unit_Price__c', '');
        component.set('v.newQuote.buildertek__Markup__c', '');

    },
    changeEvent: function (component, event, helper) {
        var group = component.find('groupId');
        group.set("v._text_value", '');
        // var costCode = component.find('costCodeId');
        // costCode.set("v._text_value", '');
        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        component.set('v.newQuote.Name', '');
        component.set('v.newQuote.buildertek__Grouping__c', null);
        // component.set('v.newQuote.buildertek__Cost_Code__c', null);
        component.set('v.newQuote.buildertek__UOM__c', '');
        component.set('v.newQuote.buildertek__Unit_Cost__c', '');
        component.set('v.newQuote.buildertek__Unit_Price__c', '');
        component.set('v.newQuote.buildertek__Quantity__c', 1);
        component.set('v.newQuote.buildertek__Markup__c', '');
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

    doView: function (component, event, helper) {
        ////console.log(event.currentTarget.dataset.record);
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        editRecordEvent.setParams({
            "recordId": event.currentTarget.dataset.record
        });
        editRecordEvent.fire();
    },

    handleSaveSuccess: function (component, event, helper) {
        if (event) {
            if (event.getParams().message && event.getParams().message.indexOf('was saved') != -1) {
                //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                /*var grid = component.find('quoteItemList');
				grid.refreshData();*/
                //$A.get("e.force:refreshView").fire();
                var page = component.get("v.page") || 1
                helper.getGroups(component, event, helper, page);
                $A.get("e.force:refreshView").fire();
            }
        }
    },

    /*handlelocationchange:function(component, event, helper){
		//console.log('----destroy---');
		component.destroy();
	},
	*/
    /*newLineItem: function(component, event, helper){
		var evt = $A.get("e.force:createRecord");
	        evt.setParams({
	            'entityApiName':'buildertek__Quote_Item__c',
	            'defaultFieldValues': {
	                'buildertek__Quote__c':component.get("v.recordId"),
	                'Name':'Quote Item'
	            },
	            'panelOnDestroyCallback':function(){
						                	 $A.enqueueAction(component.get("v.refreshGridAction"));
						                },
	            'navigationLocation': 'RELATED_LIST'
	            //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
	        });
	        evt.fire();
		//helper.createForceRecordEditComp(component, event, helper, "", "NEW", "New Quote Item",new Object());
	},*/

    eventAction: function (component, event, helper) {
        var action, grpID = event.getParam("groupId");
        action = event.getParam("action");

        if (action == 'NEW_ITEM') {
            var evt = $A.get("e.force:createRecord");
            evt.setParams({
                'entityApiName': 'buildertek__Quote_Item__c',
                'defaultFieldValues': {
                    'buildertek__Quote__c': component.get("v.recordId"),
                    'buildertek__Grouping__c': grpID,
                    'Name': 'Quote Item'
                },
                'panelOnDestroyCallback': function (e) {
                    //console.log(e);
                    $A.enqueueAction(component.get("v.refreshGridAction"));
                },
                'navigationLocation': 'RELATED_LIST'
                //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
            });
            evt.fire();
            //helper.createForceRecordEditComp(component, event, helper, "", "NEW", "New Quote Item", obj);
        } else if (action == "ADD_PRODUCTS") {
            helper.createProductItemPicker(component, event, helper, grpID);

        } else if (action == "EDIT_GROUP") {

            //helper.createForceRecordEditComp(component, event, helper, grpID, "EDIT", "Edit Group", new Object());
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId": grpID
            });
            editRecordEvent.fire();
        }
    },


    getsetparams: function (component, event, helper) {
        var showresultvalue = event.getParam("selectedRows");
        component.set("v.selectedRows", showresultvalue);
    },

    addProduct: function (component, event, helper) {

        helper.createProductItemPicker(component, event, helper);
    },

    addRFQ: function (component, event, helper) {
        helper.createRFQPicker(component, event, helper);
    },

    refreshQuoteItemList: function (component, event, helper) {
        /*$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		var grid = component.find('quoteItemList');
		grid.refreshData();*/
        var page = component.get("v.page") || 1
        helper.getGroups(component, event, helper, page);
    },

    /*	hideAddProduct:function(component, event, helper) {
		
		JQ$("#productPicketPopUp").hide();
		component.find('productpicker').set("v.body",[]);
	},*/

    onRender: function (component, event, helper) {

    },
    handleDestroy: function (component, event, helper) {

    },

    newGroup: function (component, event, helper) {
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "New Quote Group",
                    "HTMLAttributes": {
                        "class": "slds-text-heading_medium slds-hyphenate"
                    }
                }],
                ["c:BT_NewQuoteGroup", {
                    "quoteId": component.get("v.recordId"),
                    "onSuccess": function () {
                        var page = component.get("v.page") || 1
                        helper.getGroups(component, event, helper, page);
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
    saveQuoteRecord: function (component, event, helper) {
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var quoteObject = component.get("v.newQuote");
        var recordId = component.get("v.recordId");
        component.set("v.newQuote.buildertek__Quote__c", recordId);
        var markup = quoteObject.buildertek__Markup__c;
        markup = markup * 100;
        component.set("v.newQuote.buildertek__Markup__c", markup);
        var action = component.get("c.saveQuoteLineItem");
        action.setParams({
            "quoteLineRecord": JSON.stringify(quoteObject)
        });
        action.setCallback(this, function (respo) {
            if (component.isValid() && respo.getState() === "SUCCESS") {
                var group = component.find('groupId');
                group.set("v._text_value", '');
                // var costCode = component.find('costCodeId');
                // costCode.set("v._text_value", '');
                var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({
                    "recordByEvent": product
                });
                compEvent.fire();
                component.set('v.newQuote.Name', '');
                component.set('v.newQuote.buildertek__Grouping__c', null);
                //  component.set('v.newQuote.buildertek__Cost_Code__c', null);
                component.set('v.newQuote.buildertek__UOM__c', '');
                component.set('v.newQuote.buildertek__Unit_Cost__c', '');
                component.set('v.newQuote.buildertek__Quantity__c', 1);
                component.set('v.newQuote.buildertek__Markup__c', '');
                component.set("v.listofproductfamily", '');
                //component.set("v.Spinner", false);
                //
                //$A.enqueueAction(component.get("c.doInit"));
                $A.get('e.force:refreshView').fire();
                window.setTimeout(
                    $A.getCallback(function () {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Quote Line created successfully',
                            type: 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }), 3000
                );
                var page = component.get("v.page") || 1
                helper.getGroups(component, event, helper, page);
                helper.fetchpricebooks(component, event, helper);
                helper.fetchPickListVal(component, event, helper);
                //
                //component.refreshData();
            }
        });
        $A.enqueueAction(action);
    },

    checkQuoteStatus: function (component, event, helper) {
        //alert("Hiiiiiiiii");
    },

    handleComponentEvent: function (component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },

    deleteRecord: function (component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        //alert('Hiii');
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
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
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
        component.set("v.PopupHeader", "Delete Quote Line");
        component.set("v.PopupDescription", "Are you sure you want to delete this Quote Line?");
        component.set("v.isOpen", true);
        var recordId = event.currentTarget.dataset.id;
        //alert('recordId ---------> '+recordId);
        component.set("v.quoteItemId", recordId);

    },

    deleteAllQuotelines: function (component, event, helper) {
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        component.set("v.QuotelinePopupHeader", "Delete Quote Lines");
        component.set("v.QuotelinePopupDescription", "Are you sure you want to delete Quote Lines?");
        component.set("v.isQuotelinedelete", true);
        var recordId = component.get("v.recordId");
        //alert('recordId ---------> '+recordId);
        component.set("v.quoteItemId", recordId);

    },

    deleteSelectedQuoteItem: function (component, event, helper) {
        if (component.find("checkQuoteItem") != undefined) {
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "SHOW"
            }).fire();
            var QuoteIds = [];
            var rowData;
            var newRFQItems = [];
            var delId = [];
            var getAllId = component.find("checkQuoteItem");
            if (!Array.isArray(getAllId)) {
                if (getAllId.get("v.value") == true) {
                    QuoteIds.push(getAllId.get("v.text"));
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") == true) {
                        QuoteIds.push(getAllId[i].get("v.text"));
                    }
                }
            }
            if (QuoteIds.length > 0) {
                component.set("v.QuotelinePopupHeader", "Delete Quote Lines");
                component.set("v.QuotelinePopupDescription", "Are you sure you want to delete Quote Lines?");
                component.set("v.isQuotelinedelete", true);
                /*  var action = component.get('c.deleteSelectedItems'); 
                  action.setParams({
                      "recordIds" : QuoteIds
                  });
                  action.setCallback(this, function(response){
                      var state = response.getState();
                      if(state === "SUCCESS"){
                          $A.get("e.force:refreshView").fire();
                          window.setTimeout(
                              $A.getCallback(function() {
                                  var toastEvent = $A.get("e.force:showToast");
                                  toastEvent.setParams({
                                      mode: 'sticky',
                                      message: 'Selected Quote Lines was deleted',
                                      type : 'success',
                                      duration: '10000',
                                      mode: 'dismissible'
                                  });
                                  toastEvent.fire();
                              }), 3000
                          );
                          var checkvalue = component.find("selectAll").set("v.value", false);
                          var page = component.get("v.page") || 1
                          helper.getGroups(component, event, helper, page);
                      }
                  });
                  $A.enqueueAction(action); */
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
        }
    },

    newRFQ: function (component, event, helper) {
        if (component.find("checkQuoteItem") != undefined) {
            var QuoteId;
            var rowData;
            var newRFQItems = [];
            var getAllId = component.find("checkQuoteItem");
            if (!Array.isArray(getAllId)) {
                if (getAllId.get("v.value") == true) {
                    QuoteId = getAllId.get("v.text");
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") == true) {
                        QuoteId = getAllId[i].get("v.text");
                    }
                }
            }
            if (QuoteId != undefined) {
                var overlayLib;
                $A.createComponents([
                        ["c:CreateRFQFromQuote", {
                            "quoteId": component.get("v.recordId"),
                            "selectedQuoteItem": QuoteId,
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
            } else {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Please Select Quote Line!",
                    "message": "Please Select Quote Line to Create RFQ.",
                    closeCallback: function () {}
                });
            }
        } else {
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "No Quote Lines!",
                "message": "No Quote Line Records",
                closeCallback: function () {}
            });
        }
    },

    closeModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },

    closeQuotelineModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isQuotelinedelete", false);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
    },


    deleteQuoteItems: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var recordId = component.get("v.quoteItemId");
        //alert('recordId ----------> '+recordId);
        var action = component.get("c.deleteQuoteItem");
        action.setParams({
            "quoteId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert('result -----> '+JSON.stringify(result));
                component.set("v.isOpen", false);
                //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                $A.get("e.force:refreshView").fire();
                window.setTimeout(
                    $A.getCallback(function () {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Quote Line was deleted',
                            messageTemplate: "Quote Line {0} was deleted.",
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
                var page = component.get("v.page") || 1
                helper.getGroups(component, event, helper, page);
                //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();

            }
        });
        $A.enqueueAction(action);
    },

    deleteSelectedQuoteItemlines: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var QuoteIds = [];
        var rowData;
        var newRFQItems = [];
        var delId = [];
        var getAllId = component.find("checkQuoteItem");
        if (!Array.isArray(getAllId)) {
            if (getAllId.get("v.value") == true) {
                QuoteIds.push(getAllId.get("v.text"));
            }
        } else {
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    QuoteIds.push(getAllId[i].get("v.text"));
                }
            }
        }
        if (QuoteIds.length > 0) {

            var action = component.get('c.deleteSelectedItems');
            action.setParams({
                "recordIds": QuoteIds
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.isQuotelinedelete", false);
                    $A.get("e.force:refreshView").fire();
                    window.setTimeout(
                        $A.getCallback(function () {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: 'Selected Quote Lines was deleted',
                                type: 'success',
                                duration: '10000',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }), 3000
                    );
                    var checkvalue = component.find("selectAll").set("v.value", false);
                    var page = component.get("v.page") || 1
                    helper.getGroups(component, event, helper, page);
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
        console.log('target:' + event.currentTarget);
    },

    handleLookUpEvent: function (component, event, helper) {
        var selectedRecordId = event.getParam("selectedRecordId");
        var index = event.getParam('index');
        var TotalRecords = component.get("v.TotalRecords");
        var fieldName = event.getParam('fieldName');
        var ListOfEachRecord = TotalRecords.tarTable.ListOfEachRecord;
        if(TotalRecords != undefined && TotalRecords.wrapperList!=undefined){
            component.set('v.wrapperListLength',TotalRecords.wrapperList.length-1);
        }
        if(ListOfEachRecord[index] !=undefined){
            if(ListOfEachRecord[index].recordList != undefined){
                for(var i in ListOfEachRecord[index].recordList){
                    if(ListOfEachRecord[index].recordList[i].fieldName == fieldName){
                        ListOfEachRecord[index].recordList[i].originalValue = selectedRecordId;
                    }
                }
            }
        }
        component.set("v.isChangeData", true);
        component.set("v.TotalRecords", TotalRecords);
    },
    updateQuoteData: function (component, event, helper) {
        var target = event.currentTarget;

        if (!component.get("v.enableMassUpdate")) {
            var recordId = component.get("v.quoteItemId");
            var quoteList = component.get("v.datalist");
            var initialString = component.get("v.finalString");
            var delId = {};
            var newId = {};
            if (initialString == null) {
                delId = {
                    "Id": recordId
                }
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
                    newId = {
                        "Id": recordId
                    };
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
                        var isValue = 'True';
                        for (var l = 0; l < quoteList.length; l++) {
                            if (quoteList[l].Id == recordId) {
                                newId = quoteList[l];
                                newId[fieldName] = getAllId.get("v.value");
                                quoteList.push(newId);
                                break;
                            }
                        }
                    }
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") != null) {
                        if (finString.Id == recordId) {
                            finString[fieldName] = getAllId[i].get("v.value");
                            quoteList.push(finString);
                        } else {
                            newId[fieldName] = getAllId[i].get("v.value");
                            quoteList.push(newId);
                        }
                    }
                }
            }
            component.set("v.datalist", quoteList);
            component.set("v.showButtons", true);
            console.log('quoteList:' + JSON.stringify(quoteList));
            var action = component.get("c.prepareString");
            action.setParams({
                "quoteString": JSON.stringify(quoteList),
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();


                    //Bakul - 12/16 - commented as component attribut already has latest data
                    //component.set("v.quoteItemList", result);
                    /*var action1 = component.get('c.doInit');
        			$A.enqueueAction(action1);*/
                    var page = component.get("v.page") || 1
                    helper.getGroups(component, event, helper, page);
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
        component.refreshData();
    },

    SaveEditedValues: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var recordId = component.get("v.quoteItemId");
        console.log('Quote Items ::', JSON.stringify(component.get("v.quoteItemList")));
        var action = component.get("c.saveUpdatedValues");
        action.setParams({
            "quoteItemList": component.get("v.quoteItemList")
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
                helper.getGroups(component, event, helper, page);
                //component.refreshData();
            }
        });
        $A.enqueueAction(action);
    },

    //start
    //additional functionallity for mass-update and duplicate records 

    onClickMassUpdateCancel: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
        component.set("v.isChangeData", false);
        var page = component.get("v.page") || 1
        helper.getGroups(component, event, helper, page);

    },

    onClickMassUpdate: function (component, event, helper) {
        component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
        if (component.get("v.enableMassUpdate") == false && component.get('v.isChangeData')) {
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "SHOW"
            }).fire();
            var TotalRecords = component.get("v.TotalRecords");
            var ListOfEachRecord = TotalRecords.tarTable.ListOfEachRecord;
            var ListOfEachRecordLength = ListOfEachRecord.length;

            var newMassQi = [];

            //console.log('@@ originalValue length :: ', ListOfEachRecordLength ,'   @@ originalValue :: ',JSON.stringify(ListOfEachRecord));
            for (var i = 0; i < ListOfEachRecordLength; i++) {
                var newMassQuoteItem = {};
                newMassQuoteItem.sobjectType = 'buildertek__Quote_Item__c';
                for (var j = 0; j < ListOfEachRecord[i].recordList.length; j++) {
                    if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Quantity__c') {
                        newMassQuoteItem.buildertek__Quantity__c = ListOfEachRecord[i].recordList[j].originalValue;
                    } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Unit_Cost__c') {
                        newMassQuoteItem.buildertek__Unit_Cost__c = ListOfEachRecord[i].recordList[j].originalValue;
                    } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Markup__c') {
                        newMassQuoteItem.buildertek__Markup__c = ListOfEachRecord[i].recordList[j].originalValue;
                    } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Unit_Price__c') {
                        newMassQuoteItem.buildertek__Unit_Price__c = ListOfEachRecord[i].recordList[j].originalValue;
                    } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Additional_Discount__c') {
                        newMassQuoteItem.buildertek__Additional_Discount__c = ListOfEachRecord[i].recordList[j].originalValue;
                    } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Notes__c') {
                        newMassQuoteItem.buildertek__Notes__c = ListOfEachRecord[i].recordList[j].originalValue;
                    } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__UOM__c') {
                        newMassQuoteItem.buildertek__UOM__c = ListOfEachRecord[i].recordList[j].originalValue;
                    } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Vendor__c') {
                        newMassQuoteItem.buildertek__Vendor__c = ListOfEachRecord[i].recordList[j].originalValue;
                    }else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Priority__c') {
                        debugger;
                        newMassQuoteItem.buildertek__Priority__c = ListOfEachRecord[i].recordList[j].originalValue;
                    }
                }
                newMassQuoteItem.Id = ListOfEachRecord[i].recordId;
                newMassQuoteItem.Name = ListOfEachRecord[i].recordName;
                newMassQi.push(newMassQuoteItem);
            }
            if (newMassQi.length > 0) {
                var action = component.get("c.massUpdateQuoteLineItem");
                action.setParams({
                    "quoteLineRecords": JSON.stringify(newMassQi)
                });
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
                                    message: 'Quote Line Updated successfully',
                                    type: 'success',
                                    duration: '10000',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                            }), 3000
                        );
                        var page = component.get("v.page") || 1
                        helper.getGroups(component, event, helper, page);
                    }
                });
                $A.enqueueAction(action);
            }
        }

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
    updateQuoteRecords: function (component, event, helper) {
        var checkvalue = component.find("selectAll");
        var checkQuoteItem = component.find("checkQuoteItem");
        var quoteObject = component.get("v.newMassQuote");
        var lookupValue = component.get("v.selectedMassLookUpRecord");
        var newMassQi = [];
        for (var i = 0; i < checkQuoteItem.length; i++) {
            if (checkQuoteItem[i].get("v.value") && checkQuoteItem[i].get("v.value") != undefined && checkQuoteItem[i].get("v.value") != '') {
                var newMassQuoteItem = {};
                var checkBool = 0;
                var isValueChange = false;
                newMassQuoteItem.sobjectType = 'buildertek__Quote_Item__c';
                if (lookupValue.Id != null && lookupValue.Id != undefined) {
                    newMassQuoteItem.buildertek__Product__c = lookupValue.Id;
                    isValueChange = true;
                }
                if (quoteObject.buildertek__Quantity__c != null) {
                    newMassQuoteItem.buildertek__Quantity__c = quoteObject.buildertek__Quantity__c;
                    isValueChange = true;
                }
                if (quoteObject.buildertek__Unit_Cost__c != null) {
                    newMassQuoteItem.buildertek__Unit_Cost__c = quoteObject.buildertek__Unit_Cost__c;
                    isValueChange = true;
                }
                if (quoteObject.buildertek__Markup__c != null) {
                    newMassQuoteItem.buildertek__Markup__c = quoteObject.buildertek__Markup__c * 100;
                    isValueChange = true;
                }

                newMassQuoteItem.Id = checkQuoteItem[i].get("v.text");
                newMassQi.push(newMassQuoteItem);
                checkBool++;
            }
        }
        //console.log('newMassQi',JSON.stringify(JSON.stringify(newMassQi)));
        component.set("v.newMassQi", newMassQi);

        if (checkBool > 0 && isValueChange) {
            var action = component.get("c.massUpdateQuoteLineItem");
            action.setParams({
                "quoteLineRecords": JSON.stringify(component.get("v.newMassQi"))
            });
            action.setCallback(this, function (respo) {
                console.log('response is : ', respo.getState());
                if (respo.getState() === "SUCCESS") {
                    // component.set("v.newMassQuote","{'sobjectType':'buildertek__Quote_Item__c'}");
                    component.set("v.newMassQi", "[]");
                    checkvalue.set("v.value", false);
                    component.set("v.selectedMassLookUpRecord", "{}");
                    component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
                    component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
                    $A.get('e.force:refreshView').fire();
                    window.setTimeout(
                        $A.getCallback(function () {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: 'Quote Line Updated successfully',
                                type: 'success',
                                duration: '10000',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }), 3000
                    );
                    var page = component.get("v.page") || 1
                    helper.getGroups(component, event, helper, page);
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
        if (component.find("checkQuoteItem") != undefined) {
            var QuoteIds = [];
            var getAllId = component.find("checkQuoteItem");
            if (!Array.isArray(getAllId)) {
                if (getAllId.get("v.value") == true) {
                    QuoteIds.push(getAllId.get("v.text"));
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") == true) {
                        QuoteIds.push(getAllId[i].get("v.text"));
                    }
                }
            }
            if (QuoteIds.length > 0) {
                component.set("v.PopupHeader", "Duplicate Quote Lines");
                component.set("v.PopupDescription", "Are you sure you want to duplicate this Quote Lines?");
                component.set("v.isMassDuplicate", true);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Please select the Quote Line you would like to duplicate.',
                    type: 'error',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        } else {
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "No Quote Lines!",
                "message": "No Quote Line Records",
                closeCallback: function () {}
            });
        }
    },
    onClickAddlines: function (component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:BT_MassUpdateQuote",
            componentAttributes: {
                recordId: component.get("v.recordId")
            }
        });
        evt.fire();
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
            var action = component.get("c.massDuplicateQuoteLineItem");
            action.setParams({
                "quoteLineRecords": duplicateRecs
            });
            action.setCallback(this, function (respo) {
                console.log('response is : ', respo.getState());
                if (respo.getState() === "SUCCESS") {
                    checkvalue.set("v.value", false);
                    //component.set("v.quoteLineRecords","[]");
                    $A.get('e.force:refreshView').fire();
                    window.setTimeout(
                        $A.getCallback(function () {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: 'Duplicate records for selected quote items created successfully.',
                                type: 'success',
                                duration: '10000',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }), 3000
                    );
                    var page = component.get("v.page") || 1
                    helper.getGroups(component, event, helper, page);
                    //component.set("v.Spinner",false);
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
    onclickDuplicate: function (component, event, helper) {
        var currentId = event.currentTarget.getAttribute("data-id");
        component.set("v.currentId", currentId);
        component.set("v.PopupHeader", "Duplicate Quote Line");
        component.set("v.PopupDescription", "Are you sure you want to duplicate this Quote Line?");
        component.set("v.isDuplicate", true);
    },
    duplicateQuote: function (component, event, helper) {
        var currentId = component.get("v.currentId");
        if (currentId != "" && currentId != undefined) {
            component.set("v.isDuplicate", false);
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "SHOW"
            }).fire();
            var checkvalue = component.find("selectAll");
            var duplicateRecs = [];
            duplicateRecs.push(currentId);
            var action = component.get("c.massDuplicateQuoteLineItem");
            action.setParams({
                "quoteLineRecords": duplicateRecs
            });
            action.setCallback(this, function (respo) {
                console.log('response is : ', respo.getState());
                if (respo.getState() === "SUCCESS") {
                    checkvalue.set("v.value", false);
                    //component.set("v.quoteLineRecords","[]");
                    component.set("v.currentId", "");
                    $A.get('e.force:refreshView').fire();
                    window.setTimeout(
                        $A.getCallback(function () {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: 'Duplicate records for selected quote items created successfully.',
                                type: 'success',
                                duration: '10000',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }), 3000
                    );
                    var page = component.get("v.page") || 1
                    helper.getGroups(component, event, helper, page);
                    //component.set("v.Spinner",false);
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeDuplicateModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isDuplicate" attribute to "Fasle"  
        component.set("v.isOpen", false);
        component.set("v.isDuplicate", false);
        component.set("v.isMassDuplicate", false);
        component.set("v.currentId", "");
    },
    onMarkupEdit: function (component, event, helper) {
        component.set("v.isMarkup", true);

    },
    onMarkupChange: function (component, event, helper) {
        // alert('Hiii');
        component.set("v.isMarkup", true);
        component.set("v.PopupHeader", "Save Quote Line");
        component.set("v.PopupDescription", "Are you sure you want to update quote line markup?");
        component.set("v.isQuoteRecChange", true);
        // 	var a = component.get("v.QuoteRec").Id;
        // 	alert('a---->'+a);
        //console.log("check"+JSON.stringify(component.get("v.TotalRecords")));
        //     var markupvalue = component.get("v.QuoteRec").buildertek__Markup__c;
        //     alert('a---->'+markupvalue);
        //     var action = component.get("c.saveQuoteLineItemsValues"); 
        //     	action.setParams({
        // 		"quoteRec": component.get("v.QuoteRec").Id,
        // 		markupvalue : markupvalue
        // 	});
        // 	action.setCallback(this, function(response) {
        // 		if (response.getState() == "SUCCESS") {
        // 		    var result  = response.getReturnValue();
        // 		    alert('result----->'+result);
        // 		    component.set("v.TotalRecords",result);
        // 		}
        // });
        // var records = component.get("v.TotalRecords");

        /* for(var i =0; i<records.tarTable.ListOfEachRecord.length; i++){
             for(var j=0; j<records.tarTable.ListOfEachRecord[i].recordList.length; j++){
                 if(records.tarTable.ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Markup__c'){
                     if(records.tarTable.ListOfEachRecord[i].recordList[j].originalValue <=0 || records.tarTable.ListOfEachRecord[i].recordList[j].originalValue == '' ||records.tarTable.ListOfEachRecord[i].recordList[j].originalValue == null){
                         records.tarTable.ListOfEachRecord[i].recordList[j].originalValue = markupvalue;
                     }
                     
                 }
                 //alert(records.tarTable.ListOfEachRecord[i].recordList[j].fieldName);
             }
             
         }*/

        // component.set("v.TotalRecords",records);
        //alert(JSON.stringify(records.tarTable));
        // $A.enqueueAction(action);
    },
    closeModelQuoteRec: function (component, event, helper) {
        component.set("v.isQuoteRecChange", false);
        helper.getQuoteInfo(component, event, helper);
    },
    saveQuoteSingleRecord: function (component, event, helper) {
        component.set("v.isQuoteRecChange", false);
        component.get("v.isMarkup", false);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var markupvalue = component.get("v.QuoteRec").buildertek__Markup__c;
        // alert('a---->'+markupvalue);
        var actionLines = component.get("c.saveQuoteLineItemsValues");
        actionLines.setParams({
            "quoteRec": component.get("v.QuoteRec").Id,
            markupvalue: markupvalue
        });
        actionLines.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                //  alert('result----->'+result);
                component.set("v.TotalRecords", result);
                $A.get('e.force:refreshView').fire();
                var page = component.get("v.page") || 1
                helper.getGroups(component, event, helper, page);
                window.setTimeout(
                    $A.getCallback(function () {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Quote line markup(%) updated successfully.',
                            type: 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }), 3000
                );
            }
        });
        $A.enqueueAction(actionLines);

        /* var actions = component.get("c.saveQuoteSingleRec"); 
        	actions.setParams({
    		"quoteRec": JSON.stringify(component.get("v.QuoteRec"))
    	});
            actions.setCallback(this, function(response) {
    		if (response.getState() == "SUCCESS") {
    		    var result  = response.getReturnValue();
                console.log('retVal :'+JSON.stringify(result));
                component.set("v.QuoteRec",result);
                $A.get('e.force:refreshView').fire();
                helper.getGroups(component, event, helper, page);
                
                window.setTimeout(
                        $A.getCallback(function() {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: 'Quote line markup(%) updated successfully.',
                                type : 'success',
                                duration: '10000', 
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }), 3000
                    );
            }else{
                window.setTimeout(
                        $A.getCallback(function() {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                message: 'Something Went Wrong!!',
                                type : 'error',
                                duration: '10000', 
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }), 3000
                    );
            } 
    	});
    	$A.enqueueAction(actions);
        helper.getQuoteInfo(component,event,helper);*/

    },
    //End
    //additional functionallity for mass-update and duplicate records 
    //refresh Component method
    //
    refreshComponentHandler: function (component, event, helper) {
        console.log('refreshComponentHandler');
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var page = component.get("v.page") || 1;
        helper.getGroups(component, event, helper, page);

    },
    onInputChange: function (component, event, helper) {
        var fieldName = event.getSource().get("v.name").split('-');
        var index = fieldName[0];
        var fieldLabel = fieldName[1];
        var selectedValue = event.getSource().get("v.value");
        var record = component.get('v.record');
        record[fieldLabel] = selectedValue != '' && selectedValue != 'None' ? selectedValue : '';
        component.set('v.record', record);
    }
})