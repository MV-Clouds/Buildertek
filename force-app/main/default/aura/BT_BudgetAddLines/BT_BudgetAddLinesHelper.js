({
     fetchPickListVal: function (component, event, helper) {
        var actions = component.get("c.getselectOptions");
        actions.setParams({
            budgetObject: component.get("v.newBudgetLine"),
            budgetField: "buildertek__UOM__c",
        });
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({
                    key: "None",
                    value: "",
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key],
                    });
                }
                component.set("v.options", opts);
            }
        });
        $A.enqueueAction(actions);
    },
     getProductDetails: function (component, event, helper) {
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({
            productId: productId,
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            //alert('res'+res);
            var getProductDetails = component.get("v.newBudgetLine");
           delete getProductDetails.buildertek__Group__r;
            ////console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Budget__c = component.get("v.recordId");
            ////console.log("getprodct----",JSON.stringify(getProductDetails));
            if (res.length >= 1) {
                if (res[0].UnitPrice != null) {
                    getProductDetails.buildertek__Sales_Price__c = res[0].UnitPrice;
                }
                if (res[0].buildertek__Unit_Cost__c != null) {
                    getProductDetails.buildertek__Unit_Price__c =
                        res[0].buildertek__Unit_Cost__c;
                }

                if (res[0].buildertek__Discount__c != null) {
                    getProductDetails.buildertek__Discount__c =
                        res[0].buildertek__Discount__c;
                }
            } else {
                getProductDetails.buildertek__Unit_Cost__c = 0;
                getProductDetails.buildertek__Unit_Price__c = 0;
                getProductDetails.buildertek__Discount__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;

            getProductDetails.Name = productName;
            component.set("v.newBudgetLine", getProductDetails);

            ////console.log("getprodct----",JSON.stringify(getProductDetails));

            ////console.log("----log",res);
        });
        $A.enqueueAction(action);
    },
     fetchpricebooks: function (component, event, helper) {
        var action = component.get("c.getpricebook");
        action.setParams({
            BudgetId: component.get("v.recordId"),
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
                    value: "",
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key],
                    });
                }
                component.set("v.pricebookoptions", opts);
            }
        });
        $A.enqueueAction(actions);
    },
	 getUOMValues : function(component, event, helper){
        var action = component.get("c.getProductUOM");
        var productId = component.get("v.productId"); 
        action.setParams({
            "productId": productId
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            var ProductDetails = component.get("v.newQuote");
            if (res != null) {
                var existuom = false;
                var quoteUOM =  component.get("v.options");
                for(var i= 0; i < quoteUOM.length; i++){
                    if(quoteUOM[i]. value == res){
                        existuom = true;
                        break;
                    }
                }
                if(existuom == true){
                    component.set("v.UOMvalues", res);
                }else{
                    component.set("v.UOMvalues", 'Each');
                }
            }else{
                component.set("v.UOMvalues", 'Each');
            } 
        });
        $A.enqueueAction(action);
        
    },
    getQuoteName: function (component, event, helper) {
        var action = component.get("c.getName");
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            component.set('v.recordName', response.getReturnValue());
        })
        $A.enqueueAction(action);
    },
    
    getTableFieldSet: function (component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            console.log('Field Set Values::', response.getReturnValue());
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
        })
        $A.enqueueAction(action);
    },
    getTotalRecord: function (component, event, helper) {
        debugger;
        var action = component.get("c.getCount");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                debugger;
                component.set("v.TotalRecords", response.getReturnValue());
                console.log('Total record',response.getReturnValue());
            }
        })
        $A.enqueueAction(action);
    },
    
    getTableRows: function (component, event, helper ,pageNumber, pageSize) {
        debugger;
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();
        if(fieldSetValues){
            for (var c = 0, clang = fieldSetValues.length; c < clang; c++) {
                if (!setfieldNames.has(fieldSetValues[c].name)) {
                    setfieldNames.add(fieldSetValues[c].name);
                    if (fieldSetValues[c].type == 'REFERENCE') {
                        if (fieldSetValues[c].name.indexOf('__c') == -1) {
                            setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('Id')) + '.Name');
                        } else {
                            setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.Name');
                        }
                    }
                }
            }
        }
       
        
        var arrfieldNames = [];
        setfieldNames.forEach(v => arrfieldNames.push(v));
        component.set('v.arrfieldNames', arrfieldNames);
        console.log('Record Id::', component.get('v.recordId'));
        console.log('Arr Field Name::', JSON.stringify(arrfieldNames));
        action.setParams({
            parentRecordId: component.get("v.recordId"),
            fieldNameJson: JSON.stringify(arrfieldNames),
            pageNumber: pageNumber,
            pageSize: pageSize
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var list = JSON.parse(response.getReturnValue());
                if (list.length > 0) {
                    console.log('Records::', response.getReturnValue());
                    component.set("v.listOfRecords", list);
                    component.set("v.cloneListOfRecords", list);
                    component.set('v.numberOfItems', list.length);
                    component.set("v.PageNumber", pageNumber);
                    component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                    component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                    if (component.get('v.TotalRecords') < pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                }else {
                    component.set("v.listOfRecords", []);
                    component.set("v.cloneListOfRecords", []);
                    component.set('v.numberOfItems', 0);
                    component.set("v.PageNumber", 1);
                    component.set("v.RecordStart", 0);
                    component.set("v.RecordEnd", 0);
                    component.set("v.TotalPages", 0);
                    component.set("v.isNextVisible", true);
                    component.set('v.isLoading', false);
                }
            }
            else {
               //  alert('hello3');
               // component.set("v.listOfRecords", []);
                component.set("v.cloneListOfRecords", []);
            }
            
            component.set('v.isLoading', false);
        })
        $A.enqueueAction(action);
    },
    
    // getToDoFieldSet: function (component, event, helper, recordId) {
    //     var action = component.get("c.getFieldsFromFieldSet");
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var fieldsStr = response.getReturnValue();
    //             var fields = JSON.parse(fieldsStr);
    //             component.set("v.fields", fields);
    //         } else {
    //             console.log('Error');
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    
    
    updateMassRecords: function (component, event, helper) {
        component.set('v.isLoading', true);
        var listOfRecords = component.get('v.DuplistOfRecords');
        // var listOfRecords = component.get('v.listOfRecords');
        // alert('listOfRecords'+listOfRecords);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var deleteLines = component.get("v.deleteQuoteLines");
        var action = component.get("c.updateMultipleBudgetLine");
        
        /* console.log('listOfRecords 1 ', JSON.parse(JSON.stringify(listOfRecords)));
        for (var i = listOfRecords.length - 1; i >= 0; i--) {
            if (listOfRecords[i].buildertek__Product__c == undefined || listOfRecords[i].buildertek__Product__c == '') {
                listOfRecords.splice(i, 1);
            }
        }
        console.log('listOfRecords 2 ', JSON.parse(JSON.stringify(listOfRecords))); */
        console.log('listOfRecords 1 ', JSON.parse(JSON.stringify(listOfRecords)));
        
        for (var i in listOfRecords) {
            var uom = component.get("v.UOMvalues");
            var obj = listOfRecords[i];
            if (obj.Id == undefined) {
                obj.buildertek__Budget__c = component.get('v.recordId');
                obj.buildertek__UOM__c = uom;
            }
            if (obj.newBudgetLine.Name == null || obj.newBudgetLine.Name == '') {
                delete listOfRecords[i];
            }
            
        }
        //if any of the indes of the array is null then remove it
        for (var i = listOfRecords.length - 1; i >= 0; i--) {
            if (listOfRecords[i] == null) {
                listOfRecords.splice(i, 1);
            }
        }
        console.log('listOfRecords 2 ', JSON.parse(JSON.stringify(listOfRecords)));
        debugger;

        if(listOfRecords.length == 0){
            component.set('v.isLoading', false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please insert atleast one Budget Line ',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            return;
        }else{
            
            action.setParams({
                recordId: component.get('v.recordId'),
                updatedRecords: JSON.stringify(listOfRecords),
                pageNumber: pageNumber,
                pageSize: pageSize,
                deleteLineitems : JSON.parse(JSON.stringify(deleteLines))
            });
            
            action.setCallback(this, function (response) {
                debugger;
                var state = response.getState();
                if (state === "SUCCESS") {
                    // alert(state);
                    component.set('v.isLoading', false);
                    // $A.get('e.force:refreshView').fire()
                    var workspaceAPI = component.find("workspace");
                    // alert('jjjjjj'+workspaceAPI);
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        // alert('mmmmmmmm'+workspaceAPI.getFocusedTabInfo());
                        var focusedTabId = response.tabId;
                        // alert(focusedTabId);
                        console.log(response.tabId)
                        workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response) {
                            // alert('kkkkn');
                            // workspaceAPI.getFocusedTabInfo().then(function(response) {
                                //console.log(response.tabId)
                                //  alert('nnnnnn');
                                var workspaceAPI = component.find("workspace");
                                
                                window.setTimeout(function(){
                                    location.reload()
                                },800)
                                $A.get('e.force:refreshView').fire()
                                // })
                                
                                $A.get('e.force:refreshView').fire()
                            });
                            
                        })
                        
                        .catch(function(error) {
                            // alert('ggggg');
                            console.log(error);
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get('v.recordId'),
                                "slideDevName": "related"
                            });
                            // alert("h")
                            location.reload()
                            $A.get('e.force:refreshView').fire()
                            navEvt.fire();
                            location.reload()
                            $A.get('e.force:refreshView').fire()
                            window.setTimeout(function(){
                                location.reload()
                            },800)
                        });
                        
                    }
                    // $A.get('e.force:refreshView').fire()
                    // location.reload()
                });
            $A.enqueueAction(action);
            }
        },

    delete: function (component, event, helper, recordId) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.deleteQuoteItem");
        action.setParams({
            quoteId: component.get('v.recordId'),
            recordId: recordId,
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = JSON.parse(response.getReturnValue());
                component.set('v.listOfRecords', list);
                component.set('v.numberOfItems', list.length);
                component.set('v.cloneListOfRecords', list);
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                component.set('v.isLoading', false);
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
    
})