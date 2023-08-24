({
    initialize: function(component, event, helper) {

    },
    closetab: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
            })
            .catch(function(error) {
                console.log(error);
            });
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire();
    },

    setTabName: function(component, event, helper) {
        var quoteName = component.get("v.quoteNameData");
        console.log('name-->>',quoteName.Name);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: quoteName.Name
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'custom:custom5',
                iconAlt: 'View Quote Lines'
            });
        });

        // var mainDiv = component.find("av").getElement();
        // var Element = document.getElementById("slds");
        // console.log('bottom => ', mainDiv);
    },

    doInit: function(component, event, helper) {
        component.set("v.Spinner2", true);
        component.set('v.runFirstTime' , true);
        var workspaceAPI = component.find("workspace");


        // >>>>>>>>>>>>>>>> CHB - 78, 80 <<<<<<<<<<<<<<<<<<<<
        // Check If User Have Access for Quote Line
        helper.Check_Create_User_Access(component, event, helper);
        helper.Check_Update_User_Access(component, event, helper);
        helper.Check_Delete_User_Access(component, event, helper);
        // workspaceAPI.getEnclosingTabId().then((response) => {
        //     let opendTab = response.tabId;
        //     workspaceAPI.setTabLabel({
        //         tabId: opendTab,
        //         label: "View Quote Lines"
        //     });
        //     workspaceAPI.setTabIcon({
        //         tabId: opendTab,
        //         icon: 'custom:custom5',
        //         iconAlt: 'View Quote Lines'
        //     });
        // });

        /*--------------------------------------------*/
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var page = component.get("v.page") || 1
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            component.set("v.currentTab", focusedTabId);
            //workspaceAPI.closeTab({tabId: focusedTabId});
        })
        var action = component.get("c.getProject");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //console.log(JSON.parse(JSON.stringify(response.getReturnValue())));
                var quoteData = JSON.parse(JSON.stringify(response.getReturnValue()))
                component.set("v.quoteName", quoteData.Name);
                component.set("v.quoteId", quoteData.Id);
                if (component.find('expandCollapeseAllBtn')) {
                    if (component.find('expandCollapeseAllBtn').get('v.iconName')) {
                        var quoteId = component.get("v.quoteId");

                        var spanEle = document.getElementsByClassName('expandAllBtn_' + quoteId);
                        if (spanEle[0]) {
                            spanEle[0].style.display = "none"; //spanEle[0].style.display="inline-block";
                        }
                        if (document.getElementsByClassName('CollapeseAllBtn_' + quoteId)[0]) {
                            document.getElementsByClassName('CollapeseAllBtn_' + quoteId)[0].style.display = "inline-block";
                            // document.getElementsByClassName('CollapeseAllBtn_'+quoteId)[0].style.display="none";
                        }
                    }
                }
            }
        })
        $A.enqueueAction(action);
        helper.getGroups(component, event, helper, page);
        helper.fetchPickListVal(component, event, helper);
        helper.fetchpricebooks(component, event, helper);
        helper.getQuoteInfo(component, event, helper);
        helper.getcurr(component, event, helper);
        helper.getmulticur(component, event, helper);
        helper.setRejectedBtnColor(component, event, helper);

        if (component.find('expandCollapeseAllBtn2')) {
            if (component.find('expandCollapeseAllBtn2').get('v.iconName')) {
                component.find('expandCollapeseAllBtn2').set("v.title", "Collapse All");

                component.find('expandCollapeseAllBtn2').set("v.iconName", "utility:dash");
            }

        }

        var btadminaction = component.get("c.getadminvalues");
        btadminaction.setCallback(this, function(response) {
            console.log(response.getState());
            console.log(response.getReturnValue());
            console.log('admnvalues');

            if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log({result});
                console.log(response.getState());
                console.log(response.getError());


                if (response.getState() === 'SUCCESS') {
                    var result = response.getReturnValue();
                    // if (result[0] == true || result[1] == true) {
                    //    // document.getElementById('collapseBtn').style.display='none';
                    //     component.set('v.removeSingleQuoteLineOption', result[0]);
                    //     component.set('v.hideButtons', result[0]);
                    // }else{
                    //     component.set('v.removeSingleQuoteLineOption', false);
                    //     component.set('v.hideButtons', false);
                    // }
                    component.set('v.removeSingleQuoteLineOption', result[0]);
                    component.set('v.hideGlobalMargin', result[1]);
                    component.set('v.hideGlobalMarkup', result[2]);


                }
            }

        });
        $A.enqueueAction(btadminaction);
        helper.applyCSSBasedOnURL(component);

    },

    onClickChangeGroupName: function(component, event, helper) {
        if (!component.get('v.isGroupNameOpen')) {
            var groups = component.get('v.TotalRecords').groups;
            var target = event.target;
            var index = target.getAttribute("data-index");
            component.set('v.changeGroupNameId', '');
            var groupId = groups[index].Id != undefined ? groups[index].Id : '';
            var groupName = groups[index].Name != undefined ? groups[index].Name : '';
            //Existing Group
            if (groupId != undefined && groupId != '') {
                component.set('v.changeGroupNameId', groupId);
                component.set('v.changeGroupName', groupName);
                component.set('v.groupNameIndex', index);
                component.set('v.isGroupNameOpen', true);
            }
        } else {
            if (component.get('v.changeGroupNameId') != undefined && component.get('v.changeGroupNameId') != '') {
                //Update Group Name
                helper.updateName(component, event, helper);
            }
        }
    },

    closeGroupName: function(component, event, helper) {
        if (component.get('v.isGroupNameOpen')) {
            component.set('v.isGroupNameOpen', false);
        }
    },
    addGroupDescription: function(component, event, helper) {
        if (!component.get('v.isGroupDescriptionOpen')) {
            var groups = component.get('v.TotalRecords').groups;
            var target = event.target;
            var index = target.getAttribute("data-index");
            component.set('v.budgetGroupId', '');
            var groupId = groups[index].Id != undefined ? groups[index].Id : '';
            var groupDescription = groups[index].buildertek__Description__c != undefined ? groups[index].buildertek__Description__c : '';
            console.log({ groupDescription });
            if (groupId != undefined && groupId != '') {
                component.set('v.budgetGroupId', groupId);
                component.set('v.groupDescription', groupDescription);
                component.set('v.groupDescriptionIndex', index);
                component.set('v.isGroupDescriptionOpen', true);
            }
        } else {
            //Update Group Description
            helper.updateGroupDescription(component, event, helper);
        }
    },

    closeGroupDescription: function(component, event, helper) {
        if (component.get('v.isGroupDescriptionOpen')) {
            component.set('v.isGroupDescriptionOpen', false);
        }
    },
    // customCheckbox: function(component, cellValue, helper) {
    //     console.log('customCheckbox');
    //     var isSelected = cellValue;
    //     var label = component.get('v.columns').find(function(column) {
    //         return column.fieldName === 'isSelected';
    //     }).typeAttributes.label;
    //     return [
    //         {
    //             label: label,
    //             type: 'checkbox',
    //             class: 'slds-checkbox--faux',
    //             checked: isSelected,
    //             disabled: true
    //         }
    //     ];
    //     console.log('end customCheckbox');

    // },

    addProductFromGroup: function(component, event, helper) {
        if (!component.get('v.isAddProductFromGroup')){
            console.log(event.getSource().get('v.value'));
            let phaseValue=event.getSource().get('v.value');
            component.set('v.phaseName', phaseValue);
            console.log(component.get('v.phaseName'));

            // >>>>>>>>>>> Changes For CHB - 78 <<<<<<<<<<<<<<<<<<
            // Check user have Create Access for BT_Quote_item__c
            var HaveCreateAccess = component.get("v.HaveCreateAccess");
            if(HaveCreateAccess){
                component.set('v.openProductBox', true);
            }
            else{
                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                //     "type": "error",
                //     "title": "Error!",
                //     "message": 'You don\'t have the necessary privileges to create record.'
                // });
                // toastEvent.fire();

                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error!",
                    "message": "You don\'t have the necessary privileges to Create record.",
                    closeCallback: function () {
                        $A.get("e.c:BT_SpinnerEvent").setParams({
                            "action": "HIDE"
                        }).fire();
                    }
                });
            }


            // console.log(component.get('v.runFirstTime'));
            // // if(component.get('v.runFirstTime') != true)){}
            // var groups = component.get('v.TotalRecords').groups;
            // var quote = component.get('v.newQuote');
            // console.log("New Quote1")
            // console.log("New Quote : " + quote);
            // console.log({groups});
            // console.log(event.getSource().get("v.name"));
            // console.log('*************');
            // if (event.getSource().get("v.name") != undefined) {
            //     var index = event.getSource().get("v.name");
            //     var groupId = groups[index].Id != undefined ? groups[index].Id : '';
            //     if (groupId != '') {
            //         quote.buildertek__Grouping__c = groupId;
            //         console.log("New Quote2")
            //         console.log("New Quote : " + quote)
            //         component.set('v.newQuote', quote);
            //         component.set('v.quoteGroupId', groupId);
            //     }
            // }


            // component.set('v.columns1', [
            //     // { label: '', type: 'customCheckbox', fieldName: 'isSelected', typeAttributes: { isChecked: { fieldName: 'isSelected' }, label: '' } },
            //     { label: 'Product Family', fieldName: 'Family', type: 'text' },
            //     { label: 'Product Name', fieldName: 'Name', type: 'text' },
            //     { label: 'Product Description', fieldName: 'Description', type: 'text' },
            //     { label: 'Product Code', fieldName: 'ProductCode', type: 'text' },
            //     { label: 'List Price', fieldName: 'UnitPrice', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' } }, cellAttributes: { alignment: 'left' } },

            // ]);

            // var action4 = component.get("c.getProducts");
            // action4.setCallback(this, function(response) {
            //     //  alert("ok")
            //     component.set("v.Spinner2", true);
            //     var rows = response.getReturnValue();
            //     console.log({rows});

            //     if (response.getState() == "SUCCESS" && rows!= null) {
            //         console.log('Rows =>', { rows });
            //         for (var i = 0; i < rows.length; i++) {
            //             var row = rows[i];
            //             if (row.PricebookEntries) {
            //                 row.UnitPrice = row.PricebookEntries[0].UnitPrice;
            //             }
            //         }
            //         if(component.get('v.runFirstTime') != true){
            //             component.set("v.data1", rows);
            //             component.set("v.filteredData", rows);
            //             helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
    
            //         }

            //         //console.log("data : ",response.getReturnValue());
            //         var actions = component.get("c.getpricebooks");
            //         var opts = [];
            //         actions.setCallback(this, function(response) {
            //             if (response.getState() == "SUCCESS") {
            //                 var result = response.getReturnValue();
            //                 var opts = [];
            //                 opts.push({ key: "None", value: "" });
            //                 for (var key in result) {
            //                     opts.push({ key: key, value: result[key] });
            //                 }
            //                 component.set("v.pricebookoptions", opts);

            //                 /*-----------------------------------------------------*/
            //                 var action20 = component.get("c.priceBookInProject");
            //                 action20.setParams({
            //                     "recordId": component.get("v.recordId")
            //                 });
            //                 action20.setCallback(this, function(response) {
            //                     var state = response.getState();
            //                     if (state === 'SUCCESS') {
            //                         var result = response.getReturnValue();
            //                         console.log({result});
            //                         if (result != 'ERROR') {
            //                             // component.set("v.pricebookName1", result);
            //                             component.set("v.data1", '');
            //                             var x = component.find("getPriceBookId").get("v.value");
            //                             console.log({x});

            //                             // if (x) {
            //                             //     x = 
            //                             // } else {
            //                             //     x = '';
            //                             // }


            //                             // if (x == '' || x == undefined) {
            //                             //     console.log("Empty : ", x)
            //                             //     x = 'None';

            //                             // }
            //                             console.log("Empty1 : ", x);
            //                             if(x != ''  && x != undefined){
            //                                 var selectedPricebookList = component.get("v.storePriceBookId");
            //                                 for (var i = 0; i < selectedPricebookList.length; i++) {
            //                                     selectedPricebookList.push(x);
            //                                 }
            //                                 component.set("v.storePriceBookId", selectedPricebookList)
            //                                 var action21 = component.get("c.getProductsthroughPriceBook");
            //                                 action21.setParams({
            //                                     "pbookId": x
            //                                 });
            //                                 action21.setCallback(this, function(response) {
            //                                     if (response.getState() == "SUCCESS") {
            //                                         var rows = response.getReturnValue();
            //                                         console.log("Rows : ", rows);
            //                                         for (var i = 0; i < rows.length; i++) {
            //                                             var row = rows[i];
            //                                             row.UnitPrice = row.buildertek__Available_Quantity__c;
            //                                         }
            //                                         console.log("Get Products based on PriceBook : ", response.getReturnValue());
            //                                         component.set("v.data1", rows);
            //                                         component.set("v.filteredData", rows);
            //                                         helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
            //                                         component.set("v.checkFunctionCall", true);
            //                                         var selectedRows = [];
            //                                         var listIds = component.get("v.listOfSelectedIds");
            //                                         for (var i = 0; i < listIds.length; i++) {
            //                                             selectedRows.push(listIds[i])
            //                                         }
            //                                         component.set("v.selectedRows", selectedRows)
            //                                     }
            //                                     component.set("v.Spinner2", false);
            //                                 });
            //                                 $A.enqueueAction(action21);
            //                             }else{
            //                                 component.set("v.Spinner2", false);
            //                                 console.log(component.get('v.data1'));

            //                             }
            //                         }


            //                     } else {
            //                         console.log(JSON.stringify(response.getError()))
            //                     }
            //                 });
            //                 $A.enqueueAction(action20);
            //             }
            //         });
            //         $A.enqueueAction(actions);
            //     }
            // });
            // //   component.set("v.Spinner",false);
            // $A.enqueueAction(action4);

            // //--------------------------------------------
            // component.set('v.openProductBox', true);
            // component.set("v.Spinner", false);

        } else {
            console.log("Quote 3")
            console.log('Quote Items :0: ', JSON.stringify(component.get("v.newQuote")));
            helper.addProductToGroup(component, event, helper);
        }
    },

    saveAndNew: function(component, event, helper) {
        if (!component.get('v.isAddProductFromGroup')) {
            var groups = component.get('v.TotalRecords').groups;
            var quote = component.get('v.newQuote');
            if (event.getSource().get("v.name") != undefined) {
                var index = event.getSource().get("v.name");
                var groupId = groups[index].Id != undefined ? groups[index].Id : '';
                if (groupId != '') {
                    quote.buildertek__Grouping__c = groupId;
                    console.log("Quote 4")
                    component.set('v.newQuote', quote);
                    component.set('v.quoteGroupId', groupId);
                }
            }

            component.set('v.isAddProductFromGroup', true);

        } else {

            if (component.get('v.newQuote.Name') != null && component.get('v.newQuote.buildertek__Unit_Cost__c') != null && component.get('v.newQuote.Name') != ' ' && component.get('v.newQuote.buildertek__Unit_Cost__c') != ' ' && component.get('v.newQuote.Name') != undefined && component.get('v.newQuote.buildertek__Unit_Cost__c') != undefined) {
                component.set("v.Spinner", true);
                console.log("Quote 5")
                console.log('Quote Items :0: ', JSON.stringify(component.get("v.newQuote")));
                helper.addAndSaveProduct(component, event, helper);
                $A.get('e.force:refreshView').fire();


            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Please fill the required fields.',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }

        }
    },
    // isRefreshed: function(component, event, helper) {
    // location.reload();
    //},

    closeAddProductFromGroup: function(component, event, helper) {
        if (component.get('v.isAddProductFromGroup')) {
            var quote = component.get('v.newQuote');
            quote.buildertek__Grouping__c = '';
            console.log("Quote 6")
            component.set('v.newQuote', quote);
            component.set('v.isAddProductFromGroup', false);

        }
    },

    navigate: function(component, event, helper) {
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
        if (component.find('expandCollapeseAllBtn')) {
            if (component.find('expandCollapeseAllBtn').get('v.iconName')) {
                component.find('expandCollapeseAllBtn').set("v.title", "Expand All");

                component.find('expandCollapeseAllBtn').set("v.iconName", "utility:add");
            }
        }

    },
    changefamily: function(component, event, helper) {
        console.log('changefamily');
        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        console.log("Quote 7")
        component.set('v.newQuote.Name', '');
        component.set('v.newQuote.buildertek__Unit_Cost__c', '');
        component.set('v.newQuote.buildertek__Unit_Price__c', null);
        component.set('v.newQuote.buildertek__Markup__c', '');

    },
    changeEvent: function(component, event, helper) {
        var group = component.find('groupId');
        group.set("v._text_value", '');
        var product = component.get('v.selectedLookUpRecord');
        console.log({ product });
        console.log('===================================================================');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        console.log("Quote 8")
        component.set('v.newQuote.Name', '');
        //component.set('v.newQuote.buildertek__Grouping__c', null);
        component.set('v.newQuote.buildertek__UOM__c', '');
        component.set('v.newQuote.buildertek__Unit_Cost__c', '');
        component.set('v.newQuote.buildertek__Unit_Price__c', null);
        component.set('v.newQuote.buildertek__Quantity__c', 1);
        component.set('v.newQuote.buildertek__Markup__c', '');
        var pribooknames = component.get("v.pricebookName");
        console.log("PriceBook Name : ======= : ", pribooknames);
        console.log({ product });
        //alert(pribooknames)
        var action = component.get("c.getProductfamilyRecords");
        // set param to method
        action.setParams({
            'ObjectName': "Product2",
            'parentId': component.get("v.pricebookName")
        });
        // set a callBack
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.fetchPickListVal(component, event, helper);
                var storeResponse = response.getReturnValue();
                console.log({storeResponse});
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listofproductfamily", storeResponse);
                // if(component.get("v.listofproductfamily").length ===1 && component.get("v.listofproductfamily")[0].productfamilyvalues=='None'){
                //     component.set("v.productfamily", 'None');
                //     document.getElementById('noneValue').style.display='None';
                // }else 
                console.log(component.get("v.listofproductfamily").length , 'lengthlengthlength===');

                if (component.get("v.listofproductfamily").length > 0) {
                    component.set("v.productfamily", '--None--');
                    // component.set("v.productfamily", component.get("v.listofproductfamily")[0].productfamilyvalues);

                    
                } else {
                    component.set("v.productfamily", 'None');
                }

            }

        });
        // enqueue the Action
        $A.enqueueAction(action);
    },

    doView: function(component, event, helper) {
        ////console.log(event.currentTarget.dataset.record);
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        editRecordEvent.setParams({
            "recordId": event.currentTarget.dataset.record
        });
        editRecordEvent.fire();
    },

    handleSaveSuccess: function(component, event, helper) {
        if (event) {
            if (event.getParams().message && event.getParams().message.indexOf('was saved') != -1) {
                var page = component.get("v.page") || 1
                let getValue=component.get('v.displayGrouping')
                if (getValue) {
                    helper.getQuoteGrouping(component, event, helper); 
                } else{
                    helper.getGroups(component, event, helper, page);
                }           
            }
        }
    },

    eventAction: function(component, event, helper) {
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
                'panelOnDestroyCallback': function(e) {
                    $A.enqueueAction(component.get("v.refreshGridAction"));
                },
                'navigationLocation': 'RELATED_LIST'
            });
            evt.fire();
        } else if (action == "ADD_PRODUCTS") {
            helper.createProductItemPicker(component, event, helper, grpID);
        } else if (action == "EDIT_GROUP") {
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId": grpID
            });
            editRecordEvent.fire();
        }
    },


    getsetparams: function(component, event, helper) {
        var showresultvalue = event.getParam("selectedRows");
        component.set("v.selectedRows", showresultvalue);
    },

    addProduct: function(component, event, helper) {
        helper.createProductItemPicker(component, event, helper);
    },

    addRFQ: function(component, event, helper) {
        if(component.get("v.HaveCreateAccess")){
            helper.createRFQPicker(component, event, helper);
        }
        else{
            // var toastEvent = $A.get("e.force:showToast");
            //     toastEvent.setParams({
            //         "type": "error",
            //         "title": "Error!",
            //         "message": 'You don\'t have the necessary privileges.'
            //     });
            //     toastEvent.fire();

            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Create record.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
        }
    },

    refreshQuoteItemList: function(component, event, helper) {
        var page = component.get("v.page") || 1
        helper.getGroups(component, event, helper, page);
    },

    onRender: function(component, event, helper) {

    },

    handleDestroy: function(component, event, helper) {

    },

    newGroup: function(component, event, helper) {
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
                    "onSuccess": function() {
                        var page = component.get("v.page") || 1
                        helper.getGroups(component, event, helper, page);
                    }
                }],

            ],
            function(components, status) {
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
    saveQuoteRecord: function(component, event, helper) {

        // >>>>>>>>>>> Changes For CHB - 78 <<<<<<<<<<<<<<<<<<
            // Check user have Create Access for BT_Quote_item__c
            var HasCreateAccess = component.get("v.HaveCreateAccess");
            console.log('HasCreateAccess >> ', HasCreateAccess)

        if(HasCreateAccess){
            // If User have Create Access...
            console.log('========================Save method fire======================');
            console.log(component.get('v.unitCost'));
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "SHOW"
            }).fire();
            var quoteObject = component.get("v.newQuote");
            quoteObject.buildertek__Product_Family__c = component.get("v.productfamily");
            var getDescription=component.get('v.newQuote.Name');
    
    
            var jsonString =JSON.stringify(quoteObject);
    
    
            console.log('*************************');
    
            console.log(jsonString);
            console.log(component.get("v.productfamily"));
    
            console.log(component.get("v.newQuote"));
            console.log(' Quote Data ==> ' + JSON.stringify(quoteObject));
            debugger;
    
            var recordId = component.get("v.recordId");
            component.set("v.newQuote.buildertek__Quote__c", recordId);
            var markup = quoteObject.buildertek__Markup__c;
            var margin = quoteObject.buildertek__Margin__c;
            console.log({margin} , '====margin=====');
            // markup = markup * 100;
            component.set("v.newQuote.buildertek__Margin__c", margin);
            component.set("v.newQuote.buildertek__Markup__c", markup);
    
    
            if(getDescription!= undefined && getDescription!= ''){
    
                var action = component.get("c.saveQuoteLineItem");
                action.setParams({
                    "quoteLineRecord": JSON.stringify(quoteObject)
                });
                action.setCallback(this, function(respo) {
                    var returnValue = respo.getReturnValue();
                    console.log('returnValue ===> ', { returnValue });
                    if (component.isValid() && respo.getState() === "SUCCESS") {
                        var group = component.find('groupId');
                        group.set("v._text_value", '');
                        var product = component.get('v.selectedLookUpRecord');
                        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                        compEvent.setParams({
                            "recordByEvent": product
                        });
                        compEvent.fire();
                        component.set('v.newQuote.Name', '');
                        component.set('v.newQuote.buildertek__Description__c', '');
                        component.set('v.newQuote.buildertek__Grouping__c', null);
                        component.set('v.newQuote.buildertek__UOM__c', '');
                        component.set('v.newQuote.buildertek__Unit_Cost__c', '');
                        component.set('v.newQuote.buildertek__Notes__c', '');
                        component.set('v.newQuote.buildertek__Quantity__c', 1);
                        component.set('v.newQuote.buildertek__Margin__c', '');
                        component.set('v.newQuote.buildertek__Markup__c', '');
                        component.set('v.newQuote.buildertek__Product__c', '');
                        component.set("v.listofproductfamily", '');
                        $A.get('e.force:refreshView').fire();
                        window.setTimeout(
                            $A.getCallback(function() {
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
                    }
                });
                $A.enqueueAction(action);
            }else{
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Please Enter Description',
                    type: 'error',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        }
        else{
            // var toastEvent = $A.get("e.force:showToast");
            // toastEvent.setParams({
            //     "type": "error",
            //     "title": "Error!",
            //     "message": 'You don\'t have the necessary privileges to create record.'
            // });
            // toastEvent.fire();

            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Create record.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
        }

    },

    checkQuoteStatus: function(component, event, helper) {},

    handleComponentEvent: function(component, event, helper) {
        // get the selected Account record from the COMPONETN event
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
        helper.getUOMValues(component, event, helper);
        var temp = component.get("v.newQuote.buildertek__Unit_Price__c");
        console.log('temp varr ', temp);
    },

    deleteRecord: function(component, event, helper) {
        // get the selected Account record from the COMPONETN EVENT
    },

    handleEvent: function(component, event, helper) {
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


    editQuote: function(component, event, helper) {
        console.log(event.currentTarget);
        var recordId = event.currentTarget.dataset.id;
        console.log({recordId});
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();

        
    },
    editUnitPrice: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.id;

        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();

        var HaveEditAceess = component.get("v.HaveUpdateAccess");
        // >>>>>>>>>>>>>>>>>>> CHB - 80 <<<<<<<<<<<<<<<<<<<<<<<,
        // Check If User Have Edit Access Or Not 
        if(HaveEditAceess){
            component.set("v.NetUnit", null);
            //alert('NetUnit'+component.get("v.NetUnit"));
            component.set("v.editedquoterec", recordId);
            var action = component.get("c.getquote");
            action.setParams({
                "recordId": recordId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                // alert('state'+state);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result != null) {
                        component.set("v.markup", result.buildertek__Markup__c);
                        component.set("v.isunitcost", result.buildertek__Unit_Cost__c);
                        component.set("v.isdiscount", result.buildertek__Additional_Discount__c);
                        component.set("v.isSalesprice", result.buildertek__Net_Unit__c);
                        component.set("v.listPrice", result.buildertek__Unit_Price__c);
                        component.set("v.NetUnit", result.buildertek__Net_Unit__c)
                    }
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                    component.set("v.editUnitPrice", true);
                }
            });
    
            $A.enqueueAction(action);
        }
        else{
            // var toastEvent = $A.get("e.force:showToast");
            //     toastEvent.setParams({
            //         "type": "error",
            //         "title": "Error!",
            //         "message": 'You don\'t have the necessary privileges to update record.'
            //     });
            //     toastEvent.fire();

            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Update unit price.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });

                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
        }
    },


    closeunitsalesprice: function(component, event, helper) {
        component.set("v.editUnitPrice", false);
    },


    deleteQuote: function(component, event, helper) {
        if(component.get("v.HaveDeleteAccess")){
            component.set("v.PopupHeader", "Delete Quote Line");
            component.set("v.PopupDescription", "Are you sure you want to delete this Quote Line?");
            component.set("v.isOpen", true);
            var recordId = event.currentTarget.dataset.id;
            component.set("v.quoteItemId", recordId);
        }else{
            // var toastEvent = $A.get("e.force:showToast");
            // toastEvent.setParams({
            //     "type": "error",
            //     "title": "Error!",
            //     "message": 'You don\'t have the necessary privileges to delete record.'
            // });
            // toastEvent.fire();
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Delete record.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
        }
    },

    deleteAllQuotelines: function(component, event, helper) {
        if(component.get("v.HaveDeleteAccess")){
            component.set("v.QuotelinePopupHeader", "Delete Quote Lines");
            component.set("v.QuotelinePopupDescription", "Are you sure you want to delete Quote Lines?");
            component.set("v.isQuotelinedelete", true);
            var recordId = component.get("v.recordId");
            component.set("v.quoteItemId", recordId);
        }else{
            // var toastEvent = $A.get("e.force:showToast");
            // toastEvent.setParams({
            //     "type": "error",
            //     "title": "Error!",
            //     "message": 'You don\'t have the necessary privileges to delete record.'
            // });
            // toastEvent.fire();
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Delete record.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
        }
    },

    deleteSelectedQuoteItem: function(component, event, helper) {
        if(component.get("v.HaveDeleteAccess")){
            console.log('---In Delete Method---');
            component.set("v.Spinner22", true);
            if (component.find("checkQuoteItem") != undefined || component.find("checkGroupQuoteItem1") != undefined) {
                var QuoteIds = [];
                var rowData;
                var newRFQItems = [];
                var delId = [];
                var getAllId;
                if(component.find("checkGroupQuoteItem1") != undefined){
                    getAllId = component.find("checkGroupQuoteItem1");
                }else{
                    getAllId = component.find("checkQuoteItem");
    
                }
                console.log('getAllId--->>',{getAllId});
                if (!Array.isArray(getAllId)) {
                    if (getAllId.get("v.value") == true) {
                        QuoteIds.push(getAllId.get("v.text"));
                    }
                } else {
                    for (var i = 0; i < getAllId.length; i++) {
                        console.log(getAllId[i].get("v.value")  , 'getAllId[i].get("v.value") ');
                        if (getAllId[i].get("v.value") == true) {
                            console.log('inside if');
                            QuoteIds.push(getAllId[i].get("v.text"));
                            console.log({QuoteIds});
                        }
                    }
                }
                if (QuoteIds.length > 0) {
                    var modal = component.find("exampleModal");
                    $A.util.removeClass(modal, 'hideDiv');
                    component.set("v.QuotelinePopupHeader", "Delete Quote Lines");
                    component.set("v.QuotelinePopupDescription", "Are you sure you want to delete Quote Lines?");
                    component.set("v.isQuotelinedelete", true);
                } else {
                    
                       var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                           title: 'Error',
                           message: 'Please select atleast one Quote Line ',
                           duration: ' 5000',
                           key: 'info_alt',
                           type: 'error',
                           mode: 'pester'
                       });
                       toastEvent.fire();
                    component.set("v.Spinner22", false);
                }
                component.set("v.Spinner22", false);
            }
        }else{
            // var toastEvent = $A.get("e.force:showToast");
            // toastEvent.setParams({
            //     "type": "error",
            //     "title": "Error!",
            //     "message": 'You don\'t have the necessary privileges to delete record.'
            // });
            // toastEvent.fire();
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Delete record.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
        }

        
    },

    newRFQ: function(component, event, helper) {
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
                            "cancelCallback": function() {
                                overlayLib.close();
                            }
                        }],

                    ],
                    function(components, status, errorMessage) {
                        if (status === "SUCCESS") {
                            component.find('overlayLib').showCustomModal({
                                header: "New RFQ",
                                body: components[0],
                                footer: components[0].find("footer").get("v.body"),
                                showCloseButton: true,
                                cssClass: 'slds-modal_medium',
                                closeCallback: function() {

                                }
                            }).then(function(overlay) {
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
                    closeCallback: function() {}
                });
            }
        } else {
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "No Quote Lines!",
                "message": "No Quote Line Records",
                closeCallback: function() {}
            });
        }
    },

    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isOpen", false);
        component.set("v.isBOMmodalOpen", false);


        
    },

    closeQuotelineModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isQuotelinedelete", false);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
    },


    deleteQuoteItems: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var recordId = component.get("v.quoteItemId");
        var action = component.get("c.deleteQuoteItem");
        action.setParams({
            "quoteId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.isOpen", false);
                // $A.get("e.force:refreshView").fire();
                window.setTimeout(
                    $A.getCallback(function() {
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

                // let wrap= component.get('v.QuoteLineWrapper');
                // let list=[]
                // for(let i in wrap){
                //    wrap.quoteLineList.forEach(function(elem){
                //         if(elem.Id===recordId){
                //             console.log({wrap});
                //         }else{
                //             list.push(elem);
                //         }
                //     });
                //     wrap.quoteLineList=list;
                //     console.log(wrap);
                //     component.set('v.QuoteLineWrapper' , wrap);
                // }
               
                var page = component.get("v.page") || 1
                
                let getValue=component.get('v.displayGrouping')
                if (getValue) {
                    helper.getQuoteGrouping(component, event, helper); 
                } else{
                    helper.getGroups(component, event, helper, page);
                }

                
            }
        });
        $A.enqueueAction(action);
    },

    onClickCreateNewGroup: function(component, event, helper) {
        component.set('v.addGroupPopup', true);
    },

    onClickAddGroup: function(component, event, helper) {
        var totalRecords = component.get('v.TotalRecords');
        console.log('Total Records::', JSON.stringify(totalRecords));
        var groups = totalRecords.groups;
        var groupObj = {};
        groupObj.Id = '';
        groupObj.Name = 'New Group';
        groupObj.isSelected = false;
        groupObj.buildertek__Description__c = 'Click to edit description.';
        groups.unshift(groupObj);
        component.set('v.TotalRecords', totalRecords);
    },

    newGroupCloseModal: function(component, event, helper) {
        component.set('v.addGroupPopup', false);
        component.set('v.quoteGroupNameDescription', '');
        component.set('v.quoteGroupName', '');
    },
    createNewQuoteLineGroup: function(component, event, helper) {
        var groupName = component.get('v.quoteGroupName');
        if (groupName != undefined && groupName != '') {
            helper.createQuoteLineGroup(component, event, helper);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "warning",
                "title": "Warning!",
                "message": 'Please Enter Group Name!'
            });
            toastEvent.fire();
        }
    },
    deleteSelectedQuoteItemlines: function(component, event, helper) {
        console.log('on delete quote');
        component.set("v.Spinner22",true);
        var QuoteIds = [];
        var rowData;
        var newRFQItems = [];
        var delId = [];
        var getAllId;
        if(component.find("checkGroupQuoteItem1") != undefined){
            getAllId = component.find("checkGroupQuoteItem1");
        }else{
            getAllId = component.find("checkQuoteItem");

        }       
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
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log({state});
                console.log(response.getError());
                if (state === "SUCCESS") {
                    component.set("v.Spinner22",false);
                    component.set("v.isQuotelinedelete", false);
                    $A.get("e.force:refreshView").fire();
                    window.setTimeout(
                        $A.getCallback(function() {
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
                    //var checkvalue = component.find("selectAll").set("v.value", false);
                    var page = component.get("v.page") || 1
                    let getValue=component.get('v.displayGrouping')
                    if (getValue) {
                        helper.getQuoteGrouping(component, event, helper); 
                    } else{
                        helper.getGroups(component, event, helper, page);
                    }         
                }
            });
            $A.enqueueAction(action);
        } else {
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Please Select Quote Line!",
                "message": "Please select the Quote Line you would like to Delete.",
                closeCallback: function() {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
        }
    },

    inlineEdit: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.id;
        var fieldName = event.currentTarget.dataset.label;
        var groupId = event.currentTarget.dataset.group;
        component.set("v.editedGroupId", groupId);
        component.set("v.quoteItemId", recordId);
        var editMode = component.get("v.isEditMode");
        component.set("v.isEditMode", true);
        component.set("v.fieldName", fieldName);
    },

    onblur: function(component, event, helper) {
        component.set("v.isEditMode", false);
        console.log('target:' + event.currentTarget);
    },

    handleLookUpEvent: function(component, event, helper) {
        var selectedRecordId = event.getParam("selectedRecordId");
        var index = event.getParam('index');
        var TotalRecords = component.get("v.TotalRecords");

        var fieldName = event.getParam('fieldName');
        var ListOfEachRecord = TotalRecords.tarTable.ListOfEachRecord;
        if (TotalRecords != undefined && TotalRecords.wrapperList != undefined) {
            component.set('v.wrapperListLength', TotalRecords.wrapperList.length - 1);
        }
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
        console.log("Toatl records : ", TotalRecords.tarTable.ListOfEachRecord);
    },
    updateQuoteData: function(component, event, helper) {
        var target = event.currentTarget;

        if (!component.get("v.enableMassUpdate")) {
            var recordId = component.get("v.quoteItemId");
            console.log('recordId--->>>',{recordId});
            var quoteList = component.get("v.datalist");
            console.log('quoteList--->>>',{quoteList});
            var initialString = component.get("v.finalString");
            console.log('initialString--->>>',{initialString});
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
            action.setCallback(this, function(response) {
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

    closeInlineEditForm: function(component, event, helper) {
        component.set("v.isEditMode", false);
        component.set("v.showButtons", false);
        component.refreshData();
    },

    SaveEditedValues: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var recordId = component.get("v.quoteItemId");
        console.log('Quote Items ::', JSON.stringify(component.get("v.quoteItemList")));
        var action = component.get("c.saveUpdatedValues");
        action.setParams({
            "quoteItemList": component.get("v.quoteItemList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isEditMode", false);
                component.set("v.showButtons", false);
                component.set("v.QuoteString", '');
                component.set("v.datalist", []);

                $A.get("e.force:refreshView").fire();
                window.setTimeout(
                    $A.getCallback(function() {
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
            }
        });
        $A.enqueueAction(action);
    },

    //start
    //additional functionallity for mass-update and duplicate records

    onClickMassUpdateCancel: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
        component.set("v.isChangeData", false);
        var page = component.get("v.page") || 1
        helper.getGroups(component, event, helper, page);

    },

    onClickMassUpdate: function(component, event, helper) {

         // >>>>>>>>>>> Changes For CHB - 80 <<<<<<<<<<<<<<<<<<
            // Check user have Edit Access for BT_Quote_item__c
            var HaveEditAccess = component.get("v.HaveUpdateAccess");

            if(HaveEditAccess){

                component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
                if (component.get("v.enableMassUpdate") == false && component.get('v.isChangeData')) {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "SHOW"
                    }).fire();
        
                    //$A.enqueueAction(action1);
                    var TotalRecords = component.get("v.TotalRecords");
                    console.log('TotalRecords--->>',{TotalRecords});
                    var ListOfEachRecord = TotalRecords.tarTable.ListOfEachRecord;
                    console.log('ListOfEachRecord--->>',{ListOfEachRecord});
                    var ListOfEachRecordLength = ListOfEachRecord.length;
                    console.log('ListOfEachRecordLength--->>',{ListOfEachRecordLength});
        
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
                            } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Margin__c') {
                                // console.log('---MARGIN---');
                                // console.log(ListOfEachRecord[i].recordList[j].originalValue.toFixed(4));
                                let num = ListOfEachRecord[i].recordList[j].originalValue
                                let formattedNumber = Number(num).toFixed(4);
                                console.log(formattedNumber); // Output: 3.1416
                                newMassQuoteItem.buildertek__Margin__c = formattedNumber;
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
                            } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Priority__c') {
                                // debugger;
                                newMassQuoteItem.buildertek__Priority__c = ListOfEachRecord[i].recordList[j].originalValue;
                            }
                            else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Additional_Costs__c') {
                                // debugger;
                                newMassQuoteItem.buildertek__Additional_Costs__c = ListOfEachRecord[i].recordList[j].originalValue;
                            }
                            else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Tax__c') {
                                console.log(ListOfEachRecord[i].recordList[j].originalValue , ':::::::::;');
                                newMassQuoteItem.buildertek__Tax__c = ListOfEachRecord[i].recordList[j].originalValue;
                            }
                        }
                        newMassQuoteItem.Id = ListOfEachRecord[i].recordId;
                        newMassQuoteItem.Name = ListOfEachRecord[i].recordName;
                        newMassQi.push(newMassQuoteItem);
                        console.log('newMassQi---->>>',newMassQi);
                    }
                    if (newMassQi.length > 0) {
                        var action = component.get("c.massUpdateQuoteLineItem");
                        action.setParams({
                            "quoteLineRecords": JSON.stringify(newMassQi)
                        });
                        action.setCallback(this, function(respo) {
                            console.log('response is : ', respo.getState());
                            component.set("v.isChangeData", false);
                            if (respo.getState() === "SUCCESS") {
                                $A.get('e.force:refreshView').fire();
                                window.setTimeout(
                                    $A.getCallback(function() {
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
                if (component.get("v.enableMassUpdate")) {
        
                        console.log(component.get("v.TotalRecords").groups);
                        var quoteId = component.get("v.quoteId");
                        // var spanEle = event.currentTarget.dataset.iconname;
                        // console.log(spanEle)
                        var expandallicon = document.getElementsByClassName('expandAllBtn_' + quoteId);
                        var collapeallIcon = document.getElementsByClassName('CollapeseAllBtn_' + quoteId);
                        //var labelName =spanEle
            
                        expandallicon[0].style.display = 'none';
                        collapeallIcon[0].style.display = 'inline-block';
            
            
                        var groups = component.get("v.TotalRecords").groups;
                        var quoteId = component.get("v.quoteId")
                        for (var j = 0; j < groups.length; j++) {
                            var grpIndex = j;
                            var expandicon = document.getElementsByClassName(quoteId + ' expandGrpIcon_' + grpIndex);
                            var collapeIcon = document.getElementsByClassName(quoteId + ' collapseGrpIcon_' + grpIndex);
                            var className = quoteId + " groupRows_" + grpIndex;
                            var grpRows = document.getElementsByClassName(className);
                            // if(labelName == 'Expand All') {
                            expandicon[0].style.display = 'none';
                            collapeIcon[0].style.display = 'inline-block';
                            for (var i = 0; i < grpRows.length; i++) {
                                var item = grpRows[i];
                                if (!expandicon[0].classList.contains('hideExpandIcon')) {
                                    expandicon[0].classList.add('hideExpandIcon')
                                }
                                if (expandicon[0].classList.contains('hideExpandIconhideCollapseIcon')) {
                                    expandicon[0].classList.remove('hideExpandIconhideCollapseIcon')
                                }
                                if (item.style.display == "none") {
                                    item.style.display = 'table-row';
                                }
                            }
            
                        }
            
                        var TotalRecords = component.get("v.TotalRecords");
                        console.log('TotalRecords--->>',{TotalRecords});
                        var ListOfEachRecord = TotalRecords.tarTable.ListOfEachRecord;
                        console.log('ListOfEachRecord--->>',{ListOfEachRecord});
                        var ListOfEachRecordLength = ListOfEachRecord.length;
                        console.log('ListOfEachRecordLength--->>',{ListOfEachRecordLength});
            
                        for (var i = 0; i < ListOfEachRecordLength; i++){
                            var newMassQuoteItem = {};
                            newMassQuoteItem.sobjectType = 'buildertek__Quote_Item__c';
                            for (var j = 0; j < ListOfEachRecord[i].recordList.length; j++){
                                if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Margin__c') {
                                    if (ListOfEachRecord[i].recordList[j].originalValue == '') {
                                        ListOfEachRecord[i].recordList[j].originalValue = 0;
                                    }
                                } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Markup__c') {
                                    if (ListOfEachRecord[i].recordList[j].originalValue == '') {
                                        ListOfEachRecord[i].recordList[j].originalValue = 0;
                                    }
                                } else if (ListOfEachRecord[i].recordList[j].fieldName == 'buildertek__Additional_Discount__c') {
                                    if (ListOfEachRecord[i].recordList[j].originalValue == '') {
                                        ListOfEachRecord[i].recordList[j].originalValue = 0;
                                    }
                                }
                            }
                        }
                        component.set("v.TotalRecords", TotalRecords);
                    
                }
            }
            else{
                // var toastEvent = $A.get("e.force:showToast");
                //     toastEvent.setParams({
                //         "type": "error",
                //         "title": "Error!",
                //         "message": 'You don\'t have the necessary privileges to efit record.'
                //     });
                //     toastEvent.fire();
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error!",
                    "message": "You don\'t have the necessary privileges to Update record.",
                    closeCallback: function () {
                        $A.get("e.c:BT_SpinnerEvent").setParams({
                            "action": "HIDE"
                        }).fire();
                    }
                });
            }



    },

    handleSelectAll: function(component, event, helper) {
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

    unCheckAll: function(component, event, helper) {
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
    },
    handleSelectAllGroup:function(component, event, helper) {
        let firstGroup=component.get('v.firstGrouping');
        let secondGroup=component.get('v.secondGrouping');
        let thirdGroup=component.get('v.thirdGrouping');
        let forthGrouping=component.get('v.forthGrouping');
        console.log(firstGroup);
        console.log(secondGroup);
        console.log(thirdGroup);
        console.log(forthGrouping);



        let getCheckboxValue=event.getSource().get("v.value");
        let QuoteLineWrapper = component.get('v.QuoteLineWrapper');
        let selectedGroupName = event.getSource().get("v.name");
        let groupWrapper= QuoteLineWrapper.groupWrapper;

        console.log({selectedGroupName});
        groupWrapper.forEach(function(elem){
           
            
            if(firstGroup== true){
                elem.quoteLineList.forEach(function(value){
                    if(value.buildertek__Grouping__c === selectedGroupName){
                        if(elem.isSelected=== true){
                            value.isSelected=true;
                        }else{
                            value.isSelected=false;
                        }
                    } 
                });
            }else if(secondGroup== true){
                elem.quoteLineList.forEach(function(value){
                    let getGroupName;
                    if(value.groupName!= undefined){
                        getGroupName =elem.groupName+'_'+value.groupName;
                    }else{
                        getGroupName =elem.groupName+'_';
                    }

                    value.quoteLineList.forEach(function(value2){

                        if(selectedGroupName === getGroupName){
                            if(value.isSelected=== true){
                                value2.isSelected=true;
                            }else{
                                value2.isSelected=false;
                            }
                        } 

                    });
                    
                });
            }else if(thirdGroup== true){
                console.log({selectedGroupName});
                elem.quoteLineList.forEach(function(value){
                    value.quoteLineList.forEach(function(value2){
                        let getGroupName;
                        if(value.groupName!= undefined && value2.groupName!= undefined){
                            getGroupName =elem.groupName+'_'+value.groupName+'_'+value2.groupName;
                        }else if (value.groupName!= undefined && value2.groupName== undefined){
                            getGroupName =elem.groupName+'_'+value.groupName+'_';
                        }else if (value.groupName== undefined && value2.groupName!= undefined){
                            getGroupName =elem.groupName+'__'+value2.groupName;
                        }else{

                            getGroupName =elem.groupName+'__';
                        }



                        value2.quoteLineList.forEach(function(value3){
                            if(getGroupName === selectedGroupName){
                                if(value2.isSelected=== true){
                                    value3.isSelected=true;
                                }else{
                                    value3.isSelected=false;
                                }                            } 
                        });
                    });
                    
                });
            }else if(forthGrouping== true){
                elem.quoteLineList.forEach(function(value){
                    value.quoteLineList.forEach(function(value2){
                        value2.quoteLineList.forEach(function(value3){
                            let getGroupName;
                            if(value.groupName!= undefined && value2.groupName!= undefined && value3.groupName!= undefined){
                                getGroupName =elem.groupName+'_'+value.groupName+'_'+value2.groupName+'_'+value3.groupName;
                            }else if(value.groupName!= undefined && value2.groupName!= undefined && value3.groupName== undefined){
                                getGroupName =elem.groupName+'_'+value.groupName+'_'+value2.groupName+'_';
                            }else if(value.groupName!= undefined && value2.groupName== undefined && value3.groupName== undefined){
                                getGroupName =elem.groupName+'_'+value.groupName+'__';
                            }else if(value.groupName!= undefined && value2.groupName== undefined && value3.groupName!= undefined){
                                getGroupName =elem.groupName+'_'+value.groupName+'__'+value3.groupName;
                            }else if(value.groupName == undefined && value2.groupName!= undefined && value3.groupName!= undefined){
                                getGroupName =elem.groupName+'__'+value2.groupName+'_'+value3.groupName;
                            }else if(value.groupName == undefined && value2.groupName!= undefined && value3.groupName== undefined){
                                getGroupName =elem.groupName+'__'+value2.groupName+'_';
                            }else{
                                getGroupName =elem.groupName+'___';
                            }

                            value3.quoteLineList.forEach(function(value4){
                                if(getGroupName === selectedGroupName){
                                    if(value3.isSelected=== true){
                                        value4.isSelected=true;
                                    }else{
                                        value4.isSelected=false;
                                    }                                   } 
                            });

                        });
                    });
                    
                });

            }

            
            
        });
        component.set('v.QuoteLineWrapper' , QuoteLineWrapper );
        console.log({QuoteLineWrapper});

    },
    unCheckAllGroup:function(component, event, helper) {
        let firstGroup=component.get('v.firstGrouping');
        let secondGroup=component.get('v.secondGrouping');
        let thirdGroup=component.get('v.thirdGrouping');
        let forthGrouping=component.get('v.forthGrouping');
        let selectedId = event.getSource().get("v.text");
        let selectedGroupName = event.getSource().get("v.name");
        let QuoteLineWrapper = component.get('v.QuoteLineWrapper');
        let getCurrentValue=event.getSource().get('v.value');


        let groupWrapper= QuoteLineWrapper.groupWrapper;
        groupWrapper.forEach(function(elem){
            if(firstGroup== true){
                
                elem.quoteLineList.forEach(function(value){
                    const allActive = elem.quoteLineList.every(function(obj) {
                        return obj.isSelected === true;
                     });
                    if(value.buildertek__Grouping__c === selectedGroupName){
                        if(getCurrentValue== true && allActive == true){
                            elem.isSelected=true;
                        }else{
                            elem.isSelected=false;
                        }
                    } 
                });
            }else if(secondGroup== true){
                elem.quoteLineList.forEach(function(value){
                    let getGroupName;
                    if(value.groupName!= undefined){
                        getGroupName =elem.groupName+'_'+value.groupName;
                    }else{
                        getGroupName =elem.groupName+'_';
                    }
                    const allActive = value.quoteLineList.every(function(elem) {
                        return elem.isSelected === true;
                    });
                    value.quoteLineList.forEach(function(value2){
                        if(getGroupName === selectedGroupName){
                            if(getCurrentValue== true && allActive == true){
                                value.isSelected=true;
                            }else{
                                value.isSelected=false;

                            }
                        } 
                    });    
                });
            }else if(thirdGroup== true){
                elem.quoteLineList.forEach(function(value){
                    
                    value.quoteLineList.forEach(function(value2){
                        let getGroupName;
                        if(value.groupName!= undefined && value2.groupName!= undefined){
                            getGroupName =elem.groupName+'_'+value.groupName+'_'+value2.groupName;
                        }else if (value.groupName!= undefined && value2.groupName== undefined){
                            getGroupName =elem.groupName+'_'+value.groupName+'_';
                        }else if (value.groupName== undefined && value2.groupName!= undefined){
                            getGroupName =elem.groupName+'__'+value2.groupName;
                        }else{
                            getGroupName =elem.groupName+'__';
                        }

                        const allActive = value2.quoteLineList.every(function(elem) {
                            return elem.isSelected === true;
                         });
                            
                        value2.quoteLineList.forEach(function(value3){
                        if(getGroupName === selectedGroupName){

                            if(getCurrentValue== true && allActive == true){
                                value2.isSelected=true;
                            }else{
                                value2.isSelected=false;

                            }
                        } 
                         })
                    });    
                });
            }else if(forthGrouping== true){
                elem.quoteLineList.forEach(function(value){
                    value.quoteLineList.forEach(function(value2){
                        value2.quoteLineList.forEach(function(value3){
                            let getGroupName;
                            if(value.groupName!= undefined && value2.groupName!= undefined && value3.groupName!= undefined){
                                getGroupName =elem.groupName+'_'+value.groupName+'_'+value2.groupName+'_'+value3.groupName;
                            }else if(value.groupName!= undefined && value2.groupName!= undefined && value3.groupName== undefined){
                                getGroupName =elem.groupName+'_'+value.groupName+'_'+value2.groupName+'_';
                            }else if(value.groupName!= undefined && value2.groupName== undefined && value3.groupName== undefined){
                                getGroupName =elem.groupName+'_'+value.groupName+'__';
                            }else if(value.groupName!= undefined && value2.groupName== undefined && value3.groupName!= undefined){
                                getGroupName =elem.groupName+'_'+value.groupName+'__'+value3.groupName;
                            }else if(value.groupName == undefined && value2.groupName!= undefined && value3.groupName!= undefined){
                                getGroupName =elem.groupName+'__'+value2.groupName+'_'+value3.groupName;
                            }else if(value.groupName == undefined && value2.groupName!= undefined && value3.groupName== undefined){
                                getGroupName =elem.groupName+'__'+value2.groupName+'_';
                            }else{
                                getGroupName =elem.groupName+'___';
                            }
                            const allActive = value3.quoteLineList.every(function(elem) {
                                return elem.isSelected === true;
                            });
                            value3.quoteLineList.forEach(function(value4){
                               
                                if(getGroupName === selectedGroupName){
                    
                                    if(getCurrentValue== true && allActive == true){
                                        value3.isSelected=true;
                                    }else{
                                        value3.isSelected=false;
        
                                    }

                                } 
                            });

                        
                         })
                    });    
                });

            }

            
        });
        
        
        component.set('v.QuoteLineWrapper' , QuoteLineWrapper);
        console.log({QuoteLineWrapper});

    },
    updateQuoteRecords: function(component, event, helper) {
        console.log('::::::updateQuoteRecords:::::::::');
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
        component.set("v.newMassQi", newMassQi);

        if (checkBool > 0 && isValueChange) {
            var action = component.get("c.massUpdateQuoteLineItem");
            action.setParams({
                "quoteLineRecords": JSON.stringify(component.get("v.newMassQi"))
            });
            action.setCallback(this, function(respo) {
                console.log('response is : ', respo.getState());
                if (respo.getState() === "SUCCESS") {
                    component.set("v.newMassQi", "[]");
                    checkvalue.set("v.value", false);
                    component.set("v.selectedMassLookUpRecord", "{}");
                    component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
                    component.set("v.enableMassUpdate", component.get("v.enableMassUpdate") == true ? false : true);
                    $A.get('e.force:refreshView').fire();
                    window.setTimeout(
                        $A.getCallback(function() {
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
    onClickMassDuplicate: function(component, event, helper) {
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
                closeCallback: function() {}
            });
        }
    },
    onClickAddlines: function(component, event, helper) {

        // >>>>>>>>>>> Changes For CHB - 78 <<<<<<<<<<<<<<<<<<

        var HaveCreateAccess = component.get("v.HaveCreateAccess");
        if(HaveCreateAccess){
            // If User Have Create Access Then and Then navigate to Add Mass Line Page...
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:BT_MassUpdateQuote",
                componentAttributes: {
                    recordId: component.get("v.recordId")
                }
            });
            evt.fire();
        }
        else{
            // var toastEvent = $A.get("e.force:showToast");
            // toastEvent.setParams({
            //     "type": "error",
            //     "title": "Error!",
            //     "message": 'You don\'t have the necessary privileges to create record.'
            // });
            // toastEvent.fire();

            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Create record.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });

        }

    },
    onMassDuplicate: function(component, event, helper) {
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
            // debugger;
            var action = component.get("c.massDuplicateQuoteLineItem");
            action.setParams({
                "quoteLineRecords": duplicateRecs
            });
            action.setCallback(this, function(respo) {
                if (respo.getState() === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                    window.setTimeout(
                        $A.getCallback(function() {
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
    onclickDuplicate: function(component, event, helper) {
        if(component.set("v.HaveCreateAccess")){
            var currentId = event.currentTarget.getAttribute("data-id");
            component.set("v.currentId", currentId);
            component.set("v.PopupHeader", "Duplicate Quote Line");
            component.set("v.PopupDescription", "Are you sure you want to duplicate this Quote Line?");
            component.set("v.isDuplicate", true);
        }
        else{
            // var toastEvent = $A.get("e.force:showToast");
            // toastEvent.setParams({
            //     "type": "error",
            //     "title": "Error!",
            //     "message": 'You don\'t have the necessary privileges to duplicate this record.'
            // });
            // toastEvent.fire();

            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Create record.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
        }
    },
    duplicateQuote: function(component, event, helper) {
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
            action.setCallback(this, function(respo) {
                console.log('response is : ', respo.getState());
                if (respo.getState() === "SUCCESS") {
                    component.set("v.value", false);
                    component.set("v.currentId", "");
                    $A.get('e.force:refreshView').fire();
                    window.setTimeout(
                        $A.getCallback(function() {
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
                    // helper.getGroups(component, event, helper, page);
                    let getValue=component.get('v.displayGrouping')
                    if (getValue) {
                        helper.getQuoteGrouping(component, event, helper); 
                    } else{
                        helper.getGroups(component, event, helper, page);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeDuplicateModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isDuplicate" attribute to "Fasle"
        component.set("v.isOpen", false);
        component.set("v.isDuplicate", false);
        component.set("v.isMassDuplicate", false);
        component.set("v.currentId", "");
    },
    onMarkupEdit: function(component, event, helper) {
        component.set("v.isMarkup", true);

    },

    onMarginChange: function(component, event, helper) {
        var margin = component.get("v.QuoteMargin");
        console.log({margin})

        if((margin != '' && margin != null && margin != undefined) || margin == 0){
            component.set("v.isMargin", true);
            component.set("v.PopupHeader", "Update Margin");
            component.set("v.PopupDescription", "Are you sure you want to Update Margin?");
            component.set("v.isQuoteRecChange", true);
        }else{
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please enter the value of Margin.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            
    }
    },
    onMarkupChange: function(component, event, helper) {
        var markup = component.get("v.QuoteRec").buildertek__Markup__c;
        console.log({markup})
        
            // >>>>>>>>>>> Changes For CHB - 80 <<<<<<<<<<<<<<<<<<
            // Check user have Edit Access for BT_Quote_item__c
            var HaveEditAccess = component.get("v.HaveUpdateAccess");

        if(HaveEditAccess){
            // If User Have Edit Access of Quote Line...
            if ((markup != '' && markup != null && markup != undefined) || markup == 0) {
                component.set("v.isMarkup", true);
                component.set("v.PopupHeader", "Update Markup");
                component.set("v.PopupDescription", "Are you sure you want to Update Markup?");
                component.set("v.isQuoteRecChange", true);
            }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'Please enter the value of Markup.',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
        }
        else{
            // var toastEvent = $A.get("e.force:showToast");
            //     toastEvent.setParams({
            //         "type": "error",
            //         "title": "Error!",
            //         "message": 'You don\'t have the necessary privileges to Update Global Markup.'
            //     });
            //     toastEvent.fire();
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Error!",
                "message": "You don\'t have the necessary privileges to Update Global Markup.",
                closeCallback: function () {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });

        }
            //component.set("v.PopupHeader", "Save Quote Line");
            //component.set("v.PopupDescription", "Are you sure you want to update quote line markup?");
            // let labelval = '';
            // if(margin) {
            //     labelval = 'Margin';
            // } 
            // if(markup) {
            //     labelval = 'Markup';
            // }
            // if(markup && margin) {
            //     labelval = 'Both';
            // }
        // } else {
        //     /*  component.find('notifLib').showNotice({
        //         "variant": "error",
        //         "header": "No Markup",
        //         "message": "Please enter a Markup value",
        //         closeCallback: function () {}
        //     }); */
        //     var toastEvent = $A.get("e.force:showToast");
        //     toastEvent.setParams({
        //         title: 'Error',
        //         message: 'Please enter the value of Markup.',
        //         duration: ' 5000',
        //         key: 'info_alt',
        //         type: 'error',
        //         mode: 'pester'
        //     });
        //     toastEvent.fire();
        // }
        // else if (margin != '' && margin != null && margin != 'Undefined') {
        //     component.set("v.isMargin", true);
        //     //component.set("v.PopupHeader", "Save Quote Line");
        //     //component.set("v.PopupDescription", "Are you sure you want to update quote line markup?");
        //     component.set("v.PopupHeader", "Update Margin");
        //     component.set("v.PopupDescription", "Are you sure you want to Update Margin?");
        //     component.set("v.isQuoteRecChange", true);
        // } 


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
    closeModelQuoteRec: function(component, event, helper) {
        component.set("v.isQuoteRecChange", false);
        helper.getQuoteInfo(component, event, helper);
    },
    saveQuoteSingleRecord: function(component, event, helper) {
        component.set("v.isQuoteRecChange", false);
        component.get("v.isMarkup", false);
        component.set("v.isMargin", false);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var markupvalue = component.get("v.QuoteRec").buildertek__Markup__c;
        console.log('markupvalue-->>>',{markupvalue});
        var marginvalue = component.get("v.QuoteMargin");
        console.log('marginvalue-->>>',{marginvalue});
        var actionLines = component.get("c.saveQuoteLineItemsValues");
        actionLines.setParams({
            "quoteRec": component.get("v.QuoteRec").Id,
            markupvalue: markupvalue,
            marginvalue: marginvalue
        });
        console.log('actionLines-->>>',{actionLines});
        actionLines.setCallback(this, function(response) {
            var error = response.getError();
            console.log('Error =>',{error});

            if (response.getState() == "SUCCESS") {
                console.log('<<<---Success--->>>');
                component.set("v.QuoteMargin",null);
                var result = response.getReturnValue();
                console.log({result});
                component.set("v.TotalRecords", result);
                $A.get('e.force:refreshView').fire();
                var page = component.get("v.page") || 1
                helper.getGroups(component, event, helper, page);

                var PopupHeader = component.get('v.PopupHeader');
                var msg = '';
                if (PopupHeader == 'Update Markup') {
                    msg = 'Markup';
                } else if(PopupHeader == 'Update Margin'){
                    msg = 'Margin'
                }
                window.setTimeout(
                    $A.getCallback(function() {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Quote line ' + msg + '(%) is updated successfully.',
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
        helper.getQuoteInfo(component, event, helper);
    },

    refreshComponentHandler: function(component, event, helper) {
        console.log('refreshComponentHandler');
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var page = component.get("v.page") || 1;
        helper.getGroups(component, event, helper, page);


    },
    onInputChange: function(component, event, helper) {
        var fieldName = event.getSource().get("v.name").split('-');
        var index = fieldName[0];
        var fieldLabel = fieldName[1];
        var selectedValue = event.getSource().get("v.value");
        var record = component.get('v.record');
        record[fieldLabel] = selectedValue != '' && selectedValue != 'None' ? selectedValue : '';
        component.set('v.record', record);
    },

    updateUnitSalesPrice: function(component, event, helper) {
        //	alert('hii'+component.get("v.NetUnit"));
        var netunit = component.get("v.NetUnit");
        var mar = component.get("v.markup");
        //   alert('markup'+mar);
        var unitcost = component.get("v.isunitcost");
        //   alert('unitcost'+unitcost);
        var discost = component.get("v.isdiscount") ? component.get("v.isdiscount") : 0;
        //  alert('discost'+discost);
        var salesprice = component.get("v.isSalesprice");


        var total;
        netunit = netunit * 100;
        var unitPrice = component.get("v.listPrice");
        if (unitcost != 0 && unitcost != undefined) {
            var denom = unitcost * (1 - discost / 100);
            total = -100 + netunit / denom;
        } else {

            var denom = unitPrice * (1 - discost / 100);
            total = -100 + netunit / denom;
        }

        var action = component.get("c.updatequote");
        action.setParams({
            "recordId": component.get("v.editedquoterec"),
            "markup": total
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            // alert('state'+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "SHOW"
                }).fire();
                //alert(result.buildertek__Markup__c);
                component.set("v.editUnitPrice", false);
                // component.refreshData();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);

    },
    expandCollapeAll: function(component, event, helper) {
        //component.set("v.ShowSpinner",true);
        /* console.log(component.get("v.TotalRecords").groups);
console.log(event.getSource());
var iconName = event.getSource().get("v.iconName")
var labelName = event.getSource().get("v.title");
if(labelName == 'Expand All'){
event.getSource().set("v.title", "Collapse All");
event.getSource().set("v.iconName", "utility:dash");
}else if(labelName == 'Collapse All'){
event.getSource().set("v.title", "Expand All");
event.getSource().set("v.iconName", "utility:add");
}
var groups = component.get("v.TotalRecords").groups;
for(var j=0;j<groups.length;j++){
var grpIndex = j;
var expandicon = document.getElementsByClassName('expandGrpIcon_'+grpIndex);
var collapeIcon = document.getElementsByClassName('collapseGrpIcon_'+grpIndex);
var className = "groupRows_"+grpIndex;
var grpRows = document.getElementsByClassName(className) ;
if((!expandicon[0].classList.contains('hideExpandIcon') && collapeIcon[0].classList.contains('hideCollapseIcon') && labelName == 'Expand All')
|| iconName == 'utility:add' )  {
//component.set("v.isExpandGrp",true);
//alert("HAI");
$A.util.toggleClass(expandicon[0], 'hideExpandIcon');
$A.util.toggleClass(collapeIcon[0], 'hideCollapseIcon');
for(var i=0;i<grpRows.length;i++){
var item = grpRows[i];
if(!item.classList.contains('showRows')){
item.classList.add('showRows')
}
}

}else if((expandicon[0].classList.contains('hideExpandIcon') && !collapeIcon[0].classList.contains('hideCollapseIcon') && labelName == 'Collapse All')
|| iconName == 'utility:dash'){

$A.util.toggleClass(expandicon[0], 'hideExpandIcon');
$A.util.toggleClass(collapeIcon[0], 'hideCollapseIcon');
component.set("v.isExpandGrp",false);
for(var i=0;i<grpRows.length;i++){
var item = grpRows[i];
if(item.classList.contains('showRows')){
item.classList.remove('showRows')
}
}
console.log(document.getElementsByClassName(className)[0]);
}
}*/
        console.log(component.get("v.TotalRecords").groups);
        var quoteId = component.get("v.quoteId");
        var spanEle = event.currentTarget.dataset.iconname;
        console.log("spanEle:::", spanEle);
        var expandallicon = document.getElementsByClassName('expandAllBtn_' + quoteId);
        console.log("expandall::::", expandallicon);
        var collapeallIcon = document.getElementsByClassName('CollapeseAllBtn_' + quoteId);
        var labelName = spanEle
        if (labelName == 'Expand All') {
            expandallicon[0].style.display = 'none';
            collapeallIcon[0].style.display = 'inline-block';
        } else if (labelName == 'Collapse All') {
            expandallicon[0].style.display = 'inline-block';
            collapeallIcon[0].style.display = 'none';
        }

        var groups = component.get("v.TotalRecords").groups;
        var quoteId = component.get("v.quoteId")
        for (var j = 0; j < groups.length; j++) {
            var grpIndex = j;
            var expandicon = document.getElementsByClassName(quoteId + ' expandGrpIcon_' + grpIndex);
            var collapeIcon = document.getElementsByClassName(quoteId + ' collapseGrpIcon_' + grpIndex);
            var className = quoteId + " groupRows_" + grpIndex;
            var grpRows = document.getElementsByClassName(className);
            if (labelName == 'Expand All') {
                expandicon[0].style.display = 'none';
                collapeIcon[0].style.display = 'inline-block';
                for (var i = 0; i < grpRows.length; i++) {
                    var item = grpRows[i];
                    if (!expandicon[0].classList.contains('hideExpandIcon')) {
                        expandicon[0].classList.add('hideExpandIcon')
                    }
                    if (expandicon[0].classList.contains('hideExpandIconhideCollapseIcon')) {
                        expandicon[0].classList.remove('hideExpandIconhideCollapseIcon')
                    }
                    if (item.style.display == "none") {
                        item.style.display = 'table-row';
                    }
                }

            } else if (labelName == 'Collapse All') {
                collapeIcon[0].style.display = 'none';
                expandicon[0].style.display = 'inline-block';
                for (var i = 0; i < grpRows.length; i++) {
                    var item = grpRows[i];
                    if (!expandicon[0].classList.contains('hideExpandIconhideCollapseIcon')) {
                        expandicon[0].classList.add('hideExpandIconhideCollapseIcon')
                    }
                    if (expandicon[0].classList.contains('hideExpandIcon')) {
                        expandicon[0].classList.remove('hideExpandIcon')
                    }
                    if (item.style.display == "table-row") {
                        item.style.display = 'none';
                    }
                }
            }
        }

    },
    expandCollapseGroups: function(component, event, helper) {
        /* var grpIndex = event.currentTarget.dataset.grpindex;
var expandicon = document.getElementsByClassName('expandGrpIcon_'+grpIndex);
var collapeIcon = document.getElementsByClassName('collapseGrpIcon_'+grpIndex);

var className = "groupRows_"+grpIndex;
var grpRows = document.getElementsByClassName(className) ;
var allGroups = component.get("v.TotalRecords").groups;


if(!expandicon[0].classList.contains('hideExpandIcon') && collapeIcon[0].classList.contains('hideCollapseIcon')){
$A.util.toggleClass(expandicon[0], 'hideExpandIcon');
$A.util.toggleClass(collapeIcon[0], 'hideCollapseIcon');
for(var i=0;i<grpRows.length;i++){
var item = grpRows[i];
if(!item.classList.contains('showRows')){
item.classList.add('showRows')
}
}
var hideExpandIconEles = document.getElementsByClassName('hideExpandIcon');
if(hideExpandIconEles.length == allGroups.length){
var btn = component.find("expandCollapeseAllBtn");
btn.set("v.title", "Collapse All");
btn.set("v.iconName", "utility:dash");
}

}else if(expandicon[0].classList.contains('hideExpandIcon') && !collapeIcon[0].classList.contains('hideCollapseIcon')){
$A.util.toggleClass(expandicon[0], 'hideExpandIcon');
$A.util.toggleClass(collapeIcon[0], 'hideCollapseIcon');

//component.set("v.isExpandGrp",false);
for(var i=0;i<grpRows.length;i++){
var item = grpRows[i];
if(item.classList.contains('showRows')){
item.classList.remove('showRows')
}

}
var hideCollapseIconEles = document.getElementsByClassName('hideCollapseIcon');
if(hideCollapseIconEles.length == allGroups.length){
var btn = component.find("expandCollapeseAllBtn");
btn.set("v.title", "Expand All");
btn.set("v.iconName", "utility:add");
}
console.log(document.getElementsByClassName(className)[0]);
}*/


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

    openQuoteLine: function(component, event, helper) {
        component.set("v.Spinner", true);
        //clear searchbo1
        component.set("v.searchKey2", "");
        var listid = component.get("v.listOfSelectedIds");
        console.log("List of selected Id when click next : ", listid);

        if (listid.length > 0 && listid != undefined && listid != "") {
            // debugger;
            component.set("v.openProductBox", false);
            component.set("v.openQuoteLineBox", true);
            var BookId = component.get("v.storePriceBookId");

            var action6 = component.get("c.getProductRecordsByIds");
            action6.setParams({
                "Ids": listid,
                "PricebookId": component.get("v.storePriceBookId")
                    //  "pBookId":BookId
                    //  "Ids": component.get("v.listOfSelectedIds")
            });
            // alert(listid)
            //  alert(BookId)
            action6.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var listProduct = response.getReturnValue();
                    console.log("Products : ", listProduct)
                    var xyz = [];
                    var Quotelist = component.get("v.QuoteLineList");
                    // var action = component.get("c.getQuoteLineGroup");
                    // action.setParams({
                    //     "productList": listProduct
                    // });
                    // action.setCallback(this, function(response) {
                    //     if (response.getState() == "SUCCESS") {
                    //         var result = response.getReturnValue();
                    //         console.log("Quote Line Groups : ", result);
                    //     }
                    // });
                    // $A.enqueueAction(action);                    
                    for (var i = 0; i < listProduct.length; i++) {

                        /*   xyz.push({
                            'Name':listProduct[i].Product2.Name,
                            'buildertek__Unit_Price__c':listProduct[i].buildertek__Unit_Cost__c ? listProduct[i].buildertek__Unit_Cost__c : 0,
                            'buildertek__Unit_Price__c':listProduct[i].buildertek__Unit_Cost__c ? listProduct[i].buildertek__Unit_Cost__c : 0,
                            'buildertek__Grouping__c':'',
                            'buildertek__Quantity__c':'1',
                            'buildertek__Additional_Discount__c': listProduct[i].buildertek__Discount__c ? listProduct[i].buildertek__Discount__c : 0,
                            'buildertek__Unit_Cost__c':'',
                            'buildertek__Markup__c':listProduct[i].buildertek__Markup__c ? listProduct[i].buildertek__Markup__c : 0,
                            'buildertek__Product__c':listProduct[i].Product2.Id,
                            'buildertek__Size__c':listProduct[i].Pricebook2.Name
                        }) */
                        var row1 = listProduct[i];
                        console.log("Row1 PricebookEntries : ", row1.PricebookEntries)
                        console.log("Row1 => ", { row1 });
                        var action = component.get("c.createQuoteLineGroup");
                        action.setParams({
                            "productFamilyName": row1.Family
                        });
                        action.setCallback(this, function(response) {
                            if (response.getState() == "SUCCESS") {
                                var result = response.getReturnValue();
                                console.log("Quote Line Groups : ", result);
                            }
                        });
                        $A.enqueueAction(action);
                        console.log('group => '+row1.buildertek__Quote_Group__c);
                        if (row1.PricebookEntries != undefined) {
                            if (row1.buildertek__Quote_Group__c != undefined) {
                                xyz.push({
                                    'Name': row1.Name,
                                    'buildertek__Unit_Price__c': row1.PricebookEntries[0].UnitPrice,
                                    'buildertek__Unit_Price__c': row1.PricebookEntries[0].UnitPrice,
                                    'buildertek__Grouping__c': row1.buildertek__Quote_Group__c,
                                    'buildertek__Quantity__c': '1',
                                    'buildertek__Additional_Discount__c': row1.PricebookEntries[0].buildertek__Discount__c ? row1.PricebookEntries[0].buildertek__Discount__c : 0,
                                    'buildertek__Unit_Cost__c': row1.PricebookEntries[0].buildertek__Unit_Cost__c ? row1.PricebookEntries[0].buildertek__Unit_Cost__c : row1.PricebookEntries[0].UnitPrice,
                                    'buildertek__Markup__c': row1.PricebookEntries[0].buildertek__Markup__c ? row1.PricebookEntries[0].buildertek__Markup__c : 0,
                                    'buildertek__Product__c': row1.Id,
                                    'buildertek__Size__c': row1.PricebookEntries[0].Pricebook2.Name,
                                    'buildertek__Description__c': row1.Name

                                })
                            } else {
                                xyz.push({
                                    'Name': row1.Name,
                                    'buildertek__Unit_Price__c': row1.PricebookEntries[0].UnitPrice,
                                    'buildertek__Unit_Price__c': row1.PricebookEntries[0].UnitPrice,
                                    'buildertek__Grouping__c': '',
                                    'buildertek__Quantity__c': '1',
                                    'buildertek__Additional_Discount__c': row1.PricebookEntries[0].buildertek__Discount__c ? row1.PricebookEntries[0].buildertek__Discount__c : 0,
                                    'buildertek__Unit_Cost__c': row1.PricebookEntries[0].buildertek__Unit_Cost__c ? row1.PricebookEntries[0].buildertek__Unit_Cost__c : row1.PricebookEntries[0].UnitPrice,
                                    'buildertek__Markup__c': row1.PricebookEntries[0].buildertek__Markup__c ? row1.PricebookEntries[0].buildertek__Markup__c : 0,
                                    'buildertek__Product__c': row1.Id,
                                    'buildertek__Size__c': row1.PricebookEntries[0].Pricebook2.Name,
                                    'buildertek__Description__c': row1.Name
                                })
                            }
                        }
                    }
                    component.set("v.data2", xyz);
                    console.log("data 2 : ", xyz);
                    //  var action11 = component.get("c.getQuoteLineGroupRecords");
                    //    getQuoteGrouping
                    var action11 = component.get("c.getQuoteGrouping2");
                    action11.setParams({
                        "quoteId": component.get("v.recordId")
                    });
                    action11.setCallback(this, function(response) {
                        if (response.getState() == "SUCCESS") {
                            component.set("v.quotelineRecords", response.getReturnValue());
                        }
                    });
                    $A.enqueueAction(action11);
                    component.set("v.Spinner", false);
                } else {
                    console.log(response.getError());
                    component.set("v.Spinner", false);
                }
            });
            $A.enqueueAction(action6);
        } else {
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least one Product.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
    closeBox: function(component, event, helper) {
        component.set("v.searchKey2", "");
        component.set("v.data1", []) //1
        component.set("v.selectedRows", "");
        //   component.set("v.listOfSelectedIds",null);
        component.set("v.data2", "");
        component.set("v.data2", []); //2
        component.set("v.listOfSelectedIds", []); //3
        component.set("v.pricebookName1", "") //4
            // $A.get('e.force:refreshView').fire();
        component.set("v.openProductBox", false);
        component.set("v.openQuoteLineBox", false);
        // location.reload();
    },
    closeBox2: function(component, event, helper) {
        component.set("v.data1", []) //1
        component.set("v.selectedRows", "");
        //   component.set("v.listOfSelectedIds",null);
        component.set("v.data2", "");
        component.set("v.data2", []); //2
        component.set("v.listOfSelectedIds", []); //3
        component.set("v.pricebookName1", "") //4
            // $A.get('e.force:refreshView').fire();
        component.set("v.openProductBox", false);
        component.set("v.openQuoteLineBox", false);
        // location.reload();
        /*-------------------------------------
        component.set("v.selectedRows", "");
        //  component.set("v.listOfSelectedIds",null);
        component.set("v.data2", "");
        // $A.get('e.force:refreshView').fire();
        component.set("v.openProductBox",false);
        component.set("v.openQuoteLineBox",false);
        // location.reload(); */
    },

    updateSelectedText: function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        console.log(component.get("v.pricebookName1"))
        console.log("1 st -- " + component.get("v.listOfSelectedIds"));
        component.set("v.StoreIdsOfDatatable", component.get("v.listOfSelectedIds"));
        var y = [];
        var selectedRowList = component.get("v.listOfSelectedIds")
        var NewselectedRows = [];
        for (var i = 0; i < selectedRows.length; i++) {
            if (selectedRowList.indexOf(selectedRows[i].Id) < 0) {
                selectedRowList.push(selectedRows[i].Id)

            } else {
                console.log("yes")
            }
            NewselectedRows.push(selectedRows[i].Id);
        }
        console.log("Final List :------------------> " + NewselectedRows)
        component.set("v.listOfSelectedIds", NewselectedRows)
        component.set("v.selectedRows", NewselectedRows);

    },

    cancelBox: function(component, event, helper) {
        var abc = component.get("v.listOfSelectedIds");
        component.set("v.openQuoteLineBox", false);
        component.set("v.openProductBox", true);
        console.log("cancelBox");
        // component.set("v.data1", []) //1
        // component.set("v.selectedRows", "");
        // component.set("v.data2", "");
        // component.set("v.data2", []); //2
        // component.set("v.listOfSelectedIds", []); //3
        //console data1, data2, listOfSelectedIds
        console.log("data1 : " + component.get("v.data1"));
        console.log("data2 : " + component.get("v.data2"));
        console.log("listOfSelectedIds : " + component.get("v.listOfSelectedIds"));
    },

    addQuoteLine: function(component, event, helper) {
        component.set("v.isDisabled", true)

        console.log(component.get("v.isDisabled"))
        var listQlines = component.get("v.data2");
        component.set("v.Spinner", true);
        var action10 = component.get("c.QuoteLinesInsert");
        action10.setParams({
            "Quotelines": listQlines,
            "QuoteId": component.get("v.recordId")
        });

        action10.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            component.set("v.openQuoteLineBox", false);
            $A.get("e.force:refreshView").fire();
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Success',
                message: 'Quote Lines are created successfully',
                duration: ' 5000',
                key: 'info_alt',
                type: 'success',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set("v.isDisabled", false)

            //--------------------------------------
            component.set("v.data1", []) //1
            component.set("v.selectedRows", "");
            //   component.set("v.listOfSelectedIds",null);
            component.set("v.data2", "");
            component.set("v.data2", []); //2
            component.set("v.listOfSelectedIds", []); //3
            component.set("v.pricebookName1", "") //4
                // $A.get('e.force:refreshView').fire();
            component.set("v.openProductBox", false);
            component.set("v.openQuoteLineBox", false);
            // location.reload();

        });
        $A.enqueueAction(action10);

    },

    searchTable: function(component, event, helper) {
        // helper.customCheckbox(component, cellValue, helper);
        console.log("searchTable List :------------------> " + component.get("v.listOfSelectedIds"));
        // var data = component.get('v.data1');
        // for (var i = 0; i < data.length; i++) {
        //     console.log(data[i].isSelected);
        //     console.log(data[i]);
     

        // }
    


        var allRecords = component.get("v.filteredData");
        var searchFilter = event.getSource().get("v.value").toUpperCase()
        var tempArray = [];
        var i;
        console.log("ok")
        for (i = 0; i < allRecords.length; i++) {
            if ((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                tempArray.push(allRecords[i]);
            }
        }
        console.log("Temp array : ", tempArray);
        component.set("v.data1", tempArray);
        console.log("Temp array : AFTER");
        helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));

    },

    changeEvent1: function(component, event, helper) {
        // debugger
        component.set("v.Spinner2", true);
        console.log('inside change event 1');
        component.set("v.data1", []);
        component.set("v.listOfSelectedIds", []);

        var x = component.find("getPriceBookId").get("v.value");

        if (x == '') {
            console.log("Empty : ", x)
            x = 'None';

        }
        console.log("Empty1 : ", x);
        if(x == 'None'){
            component.set("v.data1", '');
        }
        var selectedPricebookList = component.get("v.storePriceBookId");
        for (var i = 0; i < selectedPricebookList.length; i++) {
            selectedPricebookList.push(x);
        }
        component.set("v.storePriceBookId", selectedPricebookList)
        var action = component.get("c.getProductsthroughPriceBook");
        action.setParams({
            "pbookId": x
        });
        action.setCallback(this, function(response) {
            component.set("v.Spinner2", false);
            var rows = response.getReturnValue();
            if (response.getState() == "SUCCESS" && rows != null) {
                console.log("Rows : ", rows);
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    row.UnitPrice = row.buildertek__Available_Quantity__c;
                }
                console.log("Get Products based on PriceBook : ", response.getReturnValue());
                component.set("v.data1", rows);
                component.set("v.filteredData", rows);
                helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
                component.set("v.checkFunctionCall", true);
                var selectedRows = [];
                var listIds = component.get("v.listOfSelectedIds");
                for (var i = 0; i < listIds.length; i++) {
                    selectedRows.push(listIds[i])
                }
                component.set("v.selectedRows", selectedRows)
            }
        });
        $A.enqueueAction(action);

    },
    updateColumnSorting: function(component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    // new method for search filter on product family
    searchKeyProductFamily: function(component, event, helper) {
        var searchWord = component.get('v.searchKey2');
        console.log("searchKey2 result in serchWord ==>", searchWord);
        var action = component.get("c.searchProdcutFamily");
        action.setParams({
            "searchedWord": searchWord
        });
        action.setCallback(this, function(response) {

            var rows = response.getReturnValue();
            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                if (row.PricebookEntries) {
                    row.UnitPrice = row.PricebookEntries[0].UnitPrice;
                }
            }
            component.set("v.data1", rows);
            helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
            component.set("v.filteredData", rows);
        });
        $A.enqueueAction(action);
    },

    clickRejectLinesBtn: function(component, event, helper) {
        var getBtn = component.find('rejectBtn');
        var getBoolVal = component.get('v.clickRejectBtn');
        if (getBoolVal) {
            component.set('v.clickRejectBtn', false);
            getBtn.set('v.variant', 'destructive');
            getBtn.set('v.label', 'Rejected Lines');
        }else{
            component.set('v.clickRejectBtn', true);
            getBtn.set('v.variant', 'success');
            getBtn.set('v.label', 'All Lines');
        }
        $A.get('e.force:refreshView').fire();

    },

    // *** BOM Grouping ***

    onclickBOMGrouping : function(component, event, helper){
        console.log('onclickBOMGrouping');
        component.set("v.isBOMmodalOpen", true);
        var opts = [
            {label: "Phase", value:"buildertek__Grouping__c"},
            {label: "Sub Group", value:"buildertek__Sub_Group__c"},
            {label: "Build Phase", value:"buildertek__Build_Phase__c"},
            {label: "Build Reference 1", value:"buildertek__Build_Reference_1__c"},
            {label: "Base Location", value:"buildertek__Base_Location__c"},
            {label: "Location (PL)", value:"buildertek__Location_Picklist__c"},
            {label: "Location Detailed Area", value:"buildertek__Location_Detailed_Area__c"},
            {label: "Location Detail Reference 1", value:"buildertek__Location_Detail_Reference_1__c"},
            {label: "Service Category", value:"buildertek__BL_SERVICE_CATEGORY__c"},
            {label: "Product Family", value:"buildertek__Product_Family__c"},
        ]
        component.set("v.GroupingOptions", opts);
    },

    // closeModel: function(component, event, helper) { 
    //     component.set("v.isBOMmodalOpen", false);
    //  },
    
     submitDetails: function(component, event, helper) {
        helper.submitDetails(component, event, helper);

     },

     returnToNormalVIew: function(component, event, helper){
        component.set("v.valueofField1", '');
        component.set("v.valueofField2", '');
        component.set("v.valueofField3", '');
        component.set("v.valueofField4", '');
        
        component.set("v.displayGrouping", false);
        component.set("v.QuoteLineWrapper", null);
        component.set("v.forthGrouping", false);
        component.set("v.thirdGrouping", false);
        component.set("v.secondGrouping", false);
        component.set("v.firstGrouping", false);
     }, 

    expandCollapeAllBom: function(component, event, helper){
        var QuoteLineWrapper = component.get("v.QuoteLineWrapper");

        var iconName = event.currentTarget.dataset.iconname;
        var recordId = component.get("v.recordId");

        var expandallIcon = document.getElementById("expandAllBtn_" + recordId);
        var collapeallIcon = document.getElementById("collapeseAllBtn_" + recordId);

        let group1 = QuoteLineWrapper.groupWrapper;

        if (iconName == 'Expand All') {
            collapeallIcon.style.display = 'block';
            expandallIcon.style.display = 'none';

            if (component.get("v.forthGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let group3 = group2[j-1].quoteLineList;
                        for (let k = 1; k <= group3.length; k++) {
                            let group4 = group3[k-1].quoteLineList;
                            for (let l = 1; l <= group4.length; l++) {
                                let spanGroupId = i+''+j+''+k+''+l;
                                helper.expandRecordsHelper(component, event, helper, spanGroupId);
                            }
                        }
                    }
                }
            } else if (component.get("v.thirdGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let group3 = group2[j-1].quoteLineList;
                        for (let k = 1; k <= group3.length; k++) {
                            let spanGroupId = i+''+j+''+k;
                            helper.expandRecordsHelper(component, event, helper, spanGroupId);
                        }
                    }
                }
            } else if (component.get("v.secondGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let spanGroupId = i+''+j;
                        helper.expandRecordsHelper(component, event, helper, spanGroupId);
                    }
                }
            } else if(component.get("v.firstGrouping")){
                for (let i = 1; i <= group1.length; i++) {
                    let spanGroupId = i;
                    helper.expandRecordsHelper(component, event, helper, spanGroupId);
                }
            }
            component.set("v.CollapeCount", 0);
        } else if (iconName == 'Collapse All') {
            collapeallIcon.style.display = 'none';
            expandallIcon.style.display = 'block';

            if (component.get("v.forthGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let group3 = group2[j-1].quoteLineList;
                        for (let k = 1; k <= group3.length; k++) {
                            let group4 = group3[k-1].quoteLineList;
                            for (let l = 1; l <= group4.length; l++) {
                                let spanGroupId = i+''+j+''+k+''+l;
                                helper.collapeRecordsHelper(component, event, helper, spanGroupId);
                            }
                        }
                    }
                }
            } else if (component.get("v.thirdGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let group3 = group2[j-1].quoteLineList;
                        for (let k = 1; k <= group3.length; k++) {
                            let spanGroupId = i+''+j+''+k;
                            helper.collapeRecordsHelper(component, event, helper, spanGroupId);
                        }
                    }
                }
            } else if (component.get("v.secondGrouping")) {
                for (let i = 1; i <= group1.length; i++) {
                    let group2 = group1[i-1].quoteLineList;
                    for (let j = 1; j <= group2.length; j++) {
                        let spanGroupId = i+''+j;
                        helper.collapeRecordsHelper(component, event, helper, spanGroupId);
                    }
                }
            } else if(component.get("v.firstGrouping")){
                for (let i = 1; i <= group1.length; i++) {
                    let spanGroupId = i;
                    helper.collapeRecordsHelper(component, event, helper, spanGroupId);
                }
            }
            component.set("v.CollapeCount", component.get("v.TotalRecordCount"));
        }
    },

    expandCollapeGroup: function(component, event, helper){
        var recordId = component.get("v.recordId");

        var expandallIcon = document.getElementById("expandAllBtn_" + recordId);
        var collapeallIcon = document.getElementById("collapeseAllBtn_" + recordId);

        var iconName = event.currentTarget.dataset.iconname;
        var spanId = event.target.id;

        var totalRecordCount = component.get("v.TotalRecordCount");
        var collapeCount = component.get("v.CollapeCount");
    
        if (iconName == 'Expand Group') {
            let spanGroupId = spanId.replace('expandGroupBtn_','');
            helper.expandRecordsHelper(component, event, helper, spanGroupId);

            let recordDivList = document.getElementsByClassName('record_'+spanGroupId);
            let selectedRecord = recordDivList.length;
            collapeCount -= selectedRecord;
        } else if (iconName == 'Collapse Group') {
            let spanGroupId = spanId.replace('collapeseGroupBtn_','');
            helper.collapeRecordsHelper(component, event, helper, spanGroupId);

            let recordDivList = document.getElementsByClassName('record_'+spanGroupId);
            let selectedRecord = recordDivList.length;
            collapeCount += selectedRecord;
        }
        component.set("v.CollapeCount", collapeCount);

        if(collapeCount == totalRecordCount){
            collapeallIcon.style.display = 'none';
            expandallIcon.style.display = 'block';
        } else{
            collapeallIcon.style.display = 'block';
            expandallIcon.style.display = 'none';
        }

    },
    handleSelectAllProduct: function(component, event, helper) {
        var getID = component.get("v.data1");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkProduct = component.find("checkProduct"); 
        if(checkvalue == true){
            for(var i=0; i<checkProduct.length; i++){
                checkProduct[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkProduct.length; i++){
                checkProduct[i].set("v.value",false);
            }
        }
    },

    
   



})