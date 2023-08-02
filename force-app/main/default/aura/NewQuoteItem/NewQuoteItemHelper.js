({

    createProductItemPicker: function (component, event, helper, groupId) {

        var overlayLib;
        $A.createComponents([
                ["c:BT_ProductsAdder", {
                    "aura:id": "btSelectProducts",
                    "recordId": component.get("v.recordId"),
                    "_gFiled": "buildertek__Grouping__c",
                    "_gSobject": "buildertek__Quote_Item__c",
                    "_gFilter": "",
                    "saveCallback": function (Items) {
                        console.log('items', Items);
                        var newQuoteItems = [];
                        for (var i = 0; i < Items.length; i++) {
                            var newQi = new Object();
                            newQi.buildertek__Quote__c = component.get("v.recordId"),
                                newQi.buildertek__Grouping__c = Items[i].groupid;
                            newQi.buildertek__Product__c = Items[i].productId;
                            newQi.Name = Items[i].productName;
                            newQi.buildertek__budget__c = component.get("v.recordId");
                            newQi.buildertek__Unit_Price__c = Items[i].salesPrice;
                            newQi.buildertek__Unit_Cost__c = Items[i].salesPrice;
                            newQi.buildertek__quantity__c = Items[i].quantity;
                            newQi.buildertek__Additional_Discount__c = Items[i].Discount;
                            newQi.buildertek__Description__c = Items[i].description;
                            newQuoteItems.push(newQi);
                        }
                        overlayLib.close();
                        $A.get("e.c:BT_SpinnerEvent").setParams({
                            "action": "SHOW"
                        }).fire();
                        helper.addSelectedProducts(component, event, helper, newQuoteItems);
                    },
                    "cancelCallback": function () {
                        overlayLib.close();
                    }
                }],

            ],
            function (components, status, errorMessage) {

                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        header: "Add Product(s) in Quote",
                        body: components[0],
                        footer: "",
                        showCloseButton: true,
                        cssClass: "btmodal_80",
                        closeCallback: function () {

                        }
                    }).then(function (overlay) {
                        overlayLib = overlay;
                    });
                }
            }
        );

    },

    createRFQPicker: function (component, event, helper) {
        var overlayLib;
        $A.createComponents([
                ["c:BT_RFQSelection", {
                    "aura:id": "btSelectRFQ",
                    "projectId": "",
                    "quotId": component.get("v.recordId"),
                    "saveCallback": function (Items) {
                        //console.log(Items);
                        $A.get("e.c:BT_SpinnerEvent").setParams({
                            "action": "SHOW"
                        }).fire();
                        overlayLib.close();
                        var action = component.get("c.createQuoteItem");
                        action.setParams({
                            quoteItemsJSON: JSON.stringify(Items)
                        });
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                /*var grid = component.find('quoteItemList');
                                grid.refreshData();*/
                                window.setTimeout(
                                    $A.getCallback(function () {
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            mode: 'sticky',
                                            message: 'Quote line added successfully',
                                            type: 'success',
                                            duration: '10000',
                                            mode: 'dismissible'
                                        });
                                        toastEvent.fire();
                                    }), 3000
                                );
                                component.refreshComponent();
                            } else if (state === "INCOMPLETE") {
                                // do something
                            } else if (state === "ERROR") {
                                var errors = response.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        //console.log("Error message: " + errors[0].message);
                                    }
                                } else {
                                    //console.log("Unknown error");
                                }
                            }
                        });
                        $A.enqueueAction(action);
                    },
                    "cancelCallback": function () {
                        overlayLib.close();
                    }
                }],

            ],
            function (components, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        header: "Select RFQ's",
                        body: components[0],
                        footer: components[0].find("footer"),
                        showCloseButton: true,
                        cssClass: "btmodal_60",
                        closeCallback: function () {

                        }
                    }).then(function (overlay) {
                        overlayLib = overlay;
                    });
                }
            }
        );

    },

    createForceRecordEditComp: function (component, event, helper, recordId, action, title, obj) {
        $A.createComponent("c:BT_Force_Record_Edit", {
                "aura:id": "btNewQuoteItemEdit",
                "title": title,
                "objectApi": "buildertek__Quote_Item__c",
                "parentId": component.get("v.recordId"),
                "parentApi": "buildertek__Quote__c",
                "newRecordName": "Quote Item",
                "saveCallBack": component.get("v.refreshGridAction"),
                "newRecordId": recordId,
                "defaultValue": obj,
                "action": action
            },
            function (grid) {
                if (component.isValid()) {
                    var targetCmp = component.find('newQuoteItem');
                    var body = targetCmp.get("v.body");
                    body.push(grid);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },

    addSelectedProducts: function (component, event, helper, items) {
        var action;
        action = component.get("c.createQuoteItem");
        action.setParams({
            quoteItemsJSON: JSON.stringify(items)
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                window.setTimeout(
                    $A.getCallback(function () {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "",
                            "message": "Product Added Successfully.",
                            "type": "success"
                        });
                        toastEvent.fire();
                    }), 3000
                );

                component.refreshComponent();
                //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": response.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        $A.enqueueAction(action);
    },
    // get an Price from 
    /* getProductDetails:function(component,event,helper){
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        //console.log("----productId",productId);
        action.setParams({"productId":productId});
        action.setCallback(this,function(respo){
            var res = respo.getReturnValue(); 
            //console.log("----respo---",res.length);
            var getProductDetails = component.get("v.newQuote");
            delete getProductDetails.buildertek__Grouping__r;
            //console.log("@quote@",component.get("v.recordId"));
            getProductDetails.buildertek__Quote__c = component.get("v.recordId");
            //console.log("getprodct----",JSON.stringify(getProductDetails));
            if(res.length>=1) {
                getProductDetails.buildertek__Unit_Cost__c = res[0].UnitPrice;
            }else{
                getProductDetails.buildertek__Unit_Cost__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            component.set("v.newQuote",getProductDetails);
            
            //console.log("getprodct----",JSON.stringify(getProductDetails));
			
            //console.log("----log",res);
        });
        $A.enqueueAction(action);
    },*/

    // Convert JSON object to sObject List

    getGroups: function (component, event, helper, page) {

        //component.set("v.groupLoaded", false);

        if (component.get("v.recordId")) {
            var action = component.get("c.retrieveGroups");
            action.setStorable({
                ignoreExisting: true
            });
            action.setParams({
                quoteId: component.get("v.recordId"),
                pageNumber: page,
                recordToDisply: 50
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log(result);
                    component.set("v.TotalRecords", result); //This Line has slow performance past 200 objects being loaded.
                    if (result != undefined && result.wrapperList != undefined) {
                        component.set('v.wrapperListLength', result.wrapperList.length - 1);
                    }
                    console.log('total records....' + JSON.stringify(component.get("v.TotalRecords")));
                    component.set("v.columns", result.columns);
                    component.set("v.page", result.page);
                    component.set("v.total", result.total);
                    if (result.total == 0) {
                        component.set("v.pages", 1);
                    } else {
                        component.set("v.pages", Math.ceil(result.total / 50));
                    }
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
            $A.enqueueAction(action);
        }
    },

    /*updateMarkupOnUI : function(component, event, helper, page) {
        //alert('Hii');
		//component.set("v.groupLoaded", false);
		
        if(component.get("v.recordId")) {
            var action = component.get("c.retrieveGroups");
            action.setStorable({
                ignoreExisting: true
            });
            action.setParams({ 
                quoteId : component.get("v.recordId"),
                pageNumber : page,
                recordToDisply : 50
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue(); 
                    //alert('result -----> '+JSON.stringify(result));
                    //var t0 = performance.now();
                    component.set("v.TotalRecords", result);//This Line has slow performance past 200 objects being loaded.
                    console.log('total records....'+JSON.stringify(component.get("v.TotalRecords")));
                    //var t1 = performance.now();
                    //console.log("------------> component.set took " + (t1 - t0) + " milliseconds to execute."); 
                    component.set("v.columns", result.columns);
                    component.set("v.page", result.page);
                    component.set("v.total", result.total);
                    component.set("v.pages", Math.ceil(result.total / 50));
                    //component.set("v.Spinner", false); 
                    
                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
					
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
                }
            });
            $A.enqueueAction(action);
        }
	},*/

    // get an Price from 
    getProductDetails: function (component, event, helper) {
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({
            "productId": productId
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            var ProductDetails = component.get("v.newQuote");
            delete ProductDetails.buildertek__Grouping__r;
            ProductDetails.buildertek__Quote__c = component.get("v.recordId");
            if (res.length >= 1) {

                ProductDetails.buildertek__Unit_Cost__c = res[0].buildertek__Unit_Cost__c;
                ProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
                ProductDetails.buildertek__Markup__c = res[0].buildertek__Markup__c / 100;
                ProductDetails.buildertek__Additional_Discount__c = res[0].buildertek__Discount__c;
            } else {
                ProductDetails.buildertek__Unit_Cost__c = 0;
                ProductDetails.buildertek__Unit_Price__c = 0;
                ProductDetails.buildertek__Markup__c = 0;
                ProductDetails.buildertek__Additional_Discount__c = 0;
            }
            ProductDetails.buildertek__Product__c = productId;

            ProductDetails.Name = productName;
            component.set("v.newQuote", ProductDetails);
        });
        $A.enqueueAction(action);
    },

    fetchPickListVal: function (component, event, helper) {
        var actions = component.get("c.getselectOptions");
        actions.setParams({
            "QuoteObject": component.get("v.newQuote"),
            "QuoteField": "buildertek__UOM__c"
        });
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var allBudgetValues = JSON.parse(response.getReturnValue());
                if (allBudgetValues != undefined && allBudgetValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allBudgetValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allBudgetValues[i].Id,
                        value: allBudgetValues[i].Id
                    });

                }
                //component.find(elementId).set("v.options", opts);
                component.set("v.options", opts);
            }
        });
        $A.enqueueAction(actions);
    },

    /*getGrouping : function(component, event, fieldsList, allFields, groupIds){
        var recordId = component.get("v.recordId");
        //alert('recordId ---------> '+recordId);
        var action = component.get("c.groupValues");
        action.setParams({
            "recordId" : recordId,
            "currencyFields" : fieldsList,
            "allFields" : allFields,
            "groupIds" : groupIds
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert('state -------->'+state);
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                //console.log('result --------> '+JSON.stringify(result));
                component.set("v.InnerList", result);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            }
        });
        $A.enqueueAction(action);        
    },
    
    getTableData : function(component, event, allFields, fieldType){
        var recordId = component.get("v.recordId");
        allFields.push('Id','buildertek__Grouping__c');
        fieldType.push({"fieldName":'Id', "fieldType":'', "isEditable": false});
        fieldType.push({"fieldName":'buildertek__Grouping__c', "fieldType":'Reference', "isEditable": false});
        var finalString = JSON.stringify(fieldType)
        var action = component.get("c.getQuoteItemData"); 
        action.setParams({
            "recordId" : recordId,
            "fieldsList" : allFields,
            "fieldString" : finalString
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert('state -------> '+state);
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                //console.log('Final result --------> '+JSON.stringify(result));
                component.set("v.Table_header_Records", result);
            }
        });
        $A.enqueueAction(action);
    },*/

    fetchpricebooks: function (component, event, helper) {
        var action = component.get("c.getpricebook");
        action.setParams({
            "quoteId": component.get("v.recordId")
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {

                component.set("v.pricebookName", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        var actions = component.get("c.getpricebooks");

        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({
                    key: "None",
                    value: ""
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key]
                    });
                }
                component.set("v.pricebookoptions", opts);
            }
        });
        $A.enqueueAction(actions);
    },

    getQuoteInfo: function (component, event, helper) {
        var actions = component.get("c.getQuoteRecord");
        actions.setParams({
            "quoteRecId": component.get("v.recordId")
        });
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.QuoteRec", result);
            }
        });
        $A.enqueueAction(actions);
    },

})