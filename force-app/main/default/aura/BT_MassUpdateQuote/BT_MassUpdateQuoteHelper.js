({  
    getTableFieldSet: function (component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            console.log('Field Set Values::', fieldSetObj);
            var pricebook = {
                "name": "Pricebook2Id",
                "label": "Pricebook",
                "type": "REFERENCE",
                "referenceTo": "Pricebook2",
                "relationshipName": "Pricebook2",
                "picklistValues": []
            };
            fieldSetObj.push(pricebook);
            var productFamily = {
                "name": "ProductFamily",
                "label": "Product Family",
                "type": "PICKLIST",
                "referenceTo": "",
                "relationshipName": "",
                "picklistValues": []
            };
            fieldSetObj.push(productFamily);
            component.set("v.fieldSetValues", fieldSetObj);
            console.log('Field Set Values::', component.get("v.fieldSetValues"));
        })
        $A.enqueueAction(action);
    },
    getTotalRecord: function (component, event, helper) {
        // ;
        var action = component.get("c.getCount");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                // ;
                component.set("v.TotalRecords", response.getReturnValue());
                console.log('Total record',response.getReturnValue());
            }
        })
        $A.enqueueAction(action);
    },
    
    getTableRows: function (component, event, helper ,pageNumber, pageSize) {
        // ;
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();
        
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
                     component.set("v.listOfRecords", []);
                    component.set("v.cloneListOfRecords", []);
                    component.set('v.numberOfItems', 0);
                    component.set("v.PageNumber", 1);
                    component.set("v.RecordStart", 0);
                    component.set("v.RecordEnd", 0);
                    component.set("v.TotalPages", 0);
                    component.set("v.isNextVisible", true);
                    component.set('v.isLoading', false);
                    var fields = component.get('v.fieldSetValues');
                    var list = component.get('v.listOfRecords');
                    for(var i=0 ;i<5;i++){
                        var obj = {};
                        for (var k in fields) {
                            obj['Id'] = 'custom'+i                
                            obj[fields[k].name] = '';  
                        } 
                        list.unshift(obj);       
                    } 
                    component.set('v.listOfRecords', list);
                
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
                    var fields = component.get('v.fieldSetValues');
                    var list = component.get('v.listOfRecords');
                    for(var i=0 ;i<5;i++){
                        var obj = {};
                        for (var k in fields) {
                            obj['Id'] = 'custom'+i                
                            obj[fields[k].name] = '';  
                        } 
                        list.unshift(obj);       
                    } 
                    component.set('v.listOfRecords', list);
                }
            }
            else {
                component.set("v.listOfRecords", []);
                component.set("v.cloneListOfRecords", []);
                   var fields = component.get('v.fieldSetValues');
                    var list = component.get('v.listOfRecords');
                    for(var i=0 ;i<5;i++){
                        var obj = {};
                        for (var k in fields) {
                            obj['Id'] = 'custom'+i                
                            obj[fields[k].name] = '';  
                        } 
                        list.unshift(obj);       
                    } 
                    component.set('v.listOfRecords', list);
            }
            
            component.set('v.isLoading', false);
        })
        $A.enqueueAction(action);
    },
    
    updateMassRecords: function (component, event, helper) {
        component.set('v.isLoading', true);
        var listOfRecords = component.get('v.listOfRecords');
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var deleteLines = component.get("v.deleteQuoteLines");
        var action = component.get("c.updateRecords");
        for (var i in listOfRecords) {
            var obj = listOfRecords[i];
            if (obj.Id.includes('custom')) {
                var key = "Id";
                delete obj[key]; 
               
                obj.buildertek__Quote__c = component.get('v.recordId');
            }
        }
        action.setParams({
            recordId: component.get('v.recordId'),
            updatedRecords: JSON.stringify(listOfRecords),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize,
            deleteLineitems : JSON.parse(JSON.stringify(deleteLines))
        });
        
        action.setCallback(this, function (response) {
            // ;
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = JSON.parse(response.getReturnValue());
                console.log('Save List :::',list);
                console.log('Save list.length :::',list.length);
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

    getAdminValues: function (component, event, helper) {
        var btadminaction = component.get("c.getadminvalues");
        btadminaction.setCallback(this, function(response) {
            console.log('admnvalues');
            console.log(response.getState());
            if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.removeSingleQuoteLineOption', result[0]);
                component.set('v.hideGlobalMargin', result[1]);
                component.set('v.hideGlobalMarkup', result[2]);
            }else{
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
            console.log('removeSingleQuoteLineOption', component.get('v.removeSingleQuoteLineOption'));
            console.log('hideGlobalMargin', component.get('v.hideGlobalMargin'));
            console.log('hideGlobalMarkup', component.get('v.hideGlobalMarkup'));
        });
        $A.enqueueAction(btadminaction);
    },

    nameTheTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: "Mass Add Line"
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'custom:custom5',
                iconAlt: 'Mass Add Line'
            });
        });
    },

    createQuoteLineWrapper : function(component, event, helper) {
        var quoteLineWrapper = {
            pricebookEntryId : '',
            productFamily : '',
            Product : '',
            ProductName : '',
            Grouping : '',
            Notes : '',
            Quantity : '',
            UnitCost : '',
            Margin : '',
            Markup : '',
            QuoteLine : {
                buildertek__Quote__c : component.get('v.recordId'),
                buildertek__Product__c : '',
                Name : '',
                buildertek__Grouping__c : '',
                buildertek__Notes__c : '',
                buildertek__Quantity__c : '',
                buildertek__Unit_Cost__c : '',
                buildertek__Margin__c : '',
                buildertek__Markup__c : '',
            },
            productFamilyList : [],
            productList : [],
            productOptionList : [],
        };
        return quoteLineWrapper;
    },

    createQuoteLineWrapperList : function(component, event, helper) {
        var quoteLineWrapperList = [];
        // var quoteLineWrapper = helper.createQuoteLineWrapper(component, event, helper);
        for(var i = 0; i < 5; i++) {
            let quoteLineWrapper = helper.createQuoteLineWrapper(component, event, helper);
            quoteLineWrapperList.push(quoteLineWrapper);
        }
        console.log('quoteLineWrapperList', quoteLineWrapperList);
        component.set('v.quoteLineWrapperList', quoteLineWrapperList);
    },

    getFamily : function(component, event, helper, priceBookId, index) {
        // console.log('helper.getFamily : PriceBookId : ', priceBookId , ' index : ', index);
        var action = component.get("c.ProductsthroughPB");
        action.setParams({
            pbookId : priceBookId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                
                var familySet = new Set();
                for(var i = 0; i < result.length; i++) {
                    familySet.add(result[i].Family);
                }
                //create a list of family where we have label and value
                var familyList = [];
                familyList.push({
                    label : '-- All Families --',
                    value : ''
                });
                familySet.forEach(function(family) {
                    if(family){
                        familyList.push({
                            label : family,
                            value : family
                        });
                    }
                });
                var quoteLineWrapperList = component.get('v.quoteLineWrapperList');
                quoteLineWrapperList[index].GroupingOptions = component.get('v.GroupingOptions');
                quoteLineWrapperList[index].productList = result;
                quoteLineWrapperList[index].productFamilyList = familyList;
                var productOptionList = [];
                if(result.length > 0) {
                    productOptionList.push({
                        label : 'Please Select Product',
                        value : ''
                    });
                    for(var i = 0; i < result.length; i++) {
                        productOptionList.push({
                            label : result[i].Name,
                            value : result[i].Id
                        });
                    }
                }
                quoteLineWrapperList[index].productOptionList = productOptionList;
                quoteLineWrapperList[index].QuoteLine = {
                    buildertek__Quote__c : component.get('v.recordId'),
                    buildertek__Product__c : '',
                    Name : '',
                    buildertek__Grouping__c : '',
                    buildertek__Notes__c : '',
                    buildertek__Quantity__c : '',
                    buildertek__Unit_Cost__c : '',
                    buildertek__Margin__c : '',
                    buildertek__Markup__c : '',
                }
                component.set('v.quoteLineWrapperList', quoteLineWrapperList);
                console.log('quoteLineWrapperList', quoteLineWrapperList);
                component.set('v.isLoading', false);
            } else if (state === "ERROR") {
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: "Error",
                    message: "A Problem Occurred: " + JSON.stringify(response.error),
                    type: "error"
                });
                toast.fire();
                component.set('v.isLoading', false);
            }
        }); 
        $A.enqueueAction(action);
        
    },

    setProductDetails : function(component, event, helper, index, productId) {
        var quoteLineWrapperList = component.get('v.quoteLineWrapperList');
        
        quoteLineWrapperList[index].QuoteLine.buildertek__Product__c = productId;
        var productList = quoteLineWrapperList[index].productList;
        for(var i = 0; i < productList.length; i++) {
            if(productList[i].Id == productId) {
                quoteLineWrapperList[index].Product = productList[i];
            }
        }       
        quoteLineWrapperList[index].QuoteLine.Name = quoteLineWrapperList[index].Product.Name;
        if(!quoteLineWrapperList[index].QuoteLine.buildertek__Quantity__c) {
            quoteLineWrapperList[index].QuoteLine.buildertek__Quantity__c = 1;
        }
        if(quoteLineWrapperList[index].Product.UnitPrice) {
            quoteLineWrapperList[index].QuoteLine.buildertek__Unit_Cost__c = quoteLineWrapperList[index].Product.UnitPrice;
        }
        if(quoteLineWrapperList[index].Product.MarkUp) {
            quoteLineWrapperList[index].QuoteLine.buildertek__Markup__c = quoteLineWrapperList[index].Product.MarkUp;
        }
        if(quoteLineWrapperList[index].Product.Phase) {
            quoteLineWrapperList[index].QuoteLine.buildertek__Grouping__c = quoteLineWrapperList[index].Product.Phase;
        }else {
            var GroupingOptions = component.get('v.GroupingOptions');
            for(var i = 0; i < GroupingOptions.length; i++) {
                if(GroupingOptions[i].Name == 'No Grouping') {
                    quoteLineWrapperList[index].QuoteLine.buildertek__Grouping__c = GroupingOptions[i].Id;
                }
            }
        }
        component.set("v.quoteLineWrapperList", quoteLineWrapperList);
        console.log('quoteLineWrapperList', quoteLineWrapperList);
        component.set('v.isLoading', false);
    },

    QuoteLineGroups : function(component, event, helper) {
        var action = component.get("c.QLGroups");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.GroupingOptions', result);

            } else if (state === "ERROR") {
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: "Error",
                    message: "A Problem Occurred: " + JSON.stringify(response.error),
                    type: "error"
                });
                toast.fire();
            }
        });
        $A.enqueueAction(action);
    },

    getProduct : function(component, event, helper, family, index) {
        var quoteLineWrapperList = component.get("v.quoteLineWrapperList");
        var productList = quoteLineWrapperList[index].productList;
        var productOptionList = [
            {
                label : 'Please Select Product',
                value : '',
            }
        ];
        for(var i = 0; i < productList.length; i++){
            if(productList[i].Family == family){
                productOptionList.push({
                    label : productList[i].Name,
                    value : productList[i].Id,
                })
            }
        }
        quoteLineWrapperList[index].productOptionList = productOptionList;
        quoteLineWrapperList[index].QuoteLine = {
            buildertek__Quote__c : component.get('v.recordId'),
            buildertek__Product__c : '',
            Name : '',
            buildertek__Grouping__c : '',
            buildertek__Notes__c : '',
            buildertek__Quantity__c : '',
            buildertek__Unit_Cost__c : '',
            buildertek__Margin__c : '',
            buildertek__Markup__c : '',
        }
        component.set("v.quoteLineWrapperList", quoteLineWrapperList);
        console.log('quoteLineWrapperList',quoteLineWrapperList);
        component.set('v.isLoading', false);
    },

    resetProductDetails : function(component, event, helper, index) {
        var quoteLineWrapperList = component.get('v.quoteLineWrapperList');
        quoteLineWrapperList[index].QuoteLine = {
            buildertek__Quote__c : component.get('v.recordId'),
            buildertek__Product__c : '',
            Name : '',
            buildertek__Grouping__c : '',
            buildertek__Notes__c : '',
            buildertek__Quantity__c : '',
            buildertek__Unit_Cost__c : '',
            buildertek__Margin__c : '',
            buildertek__Markup__c : '',
        }
        component.set("v.quoteLineWrapperList", quoteLineWrapperList);
        console.log('quoteLineWrapperList', quoteLineWrapperList);
        component.set('v.isLoading', false);
    },

    saveQuoteLine : function(component, event, helper, quotelineList) {
        console.log('quotelineList', quotelineList);
        var action = component.get("c.saveQuoteLine");
        action.setParams({
            quotelineList : quotelineList,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: "Success",
                    message: "Quote Line Saved Successfully",
                    type: "success"
                });
                toast.fire();
                component.set('v.isLoading', false);
                helper.closeNrefresh(component, event, helper);
            } else if (state === "ERROR") {

                var error = response.getError();
                console.log('Error =>',{error});

                console.log(response.getError)
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: "Error",
                    message: "A Problem Occurred: " + JSON.stringify(response.error),
                    type: "error"
                });
                toast.fire();
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    closeNrefresh : function(component, event, helper) {
        if (component.get('v.massUpdateEnable')) {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            }) 
         
            .catch(function (error) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "related"
                });
                navEvt.fire();
            });
            $A.get("e.force:closeQuickAction").fire();
            window.setTimeout(
                $A.getCallback(function () {
                    $A.get('e.force:refreshView').fire();
                }), 1000
            );
        }
    },

})