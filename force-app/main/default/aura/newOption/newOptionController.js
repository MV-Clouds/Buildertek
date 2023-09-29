({
    doInit: function(component, event, helper) {
        
        /*var recordId = component.get("v.recordId")
        console.log('getting recordId '+recordId);*/
        component.set('v.disableIt' , false);
        
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state;
        var base64Context = state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        component.set("v.recordId", addressableContext.attributes.recordId);
        component.set('v.selectionTypeId', addressableContext.attributes.recordId);

        var action2 = component.get("c.getFieldSet");
        console.log(action2);
        action2.setParams({
            objectName: 'buildertek__Question__c',
            fieldSetName: 'buildertek__NewOptionPageFields'
        });
        action2.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields0 = JSON.parse(response.getReturnValue());
                console.log({listOfFields0});
                component.set("v.listOfFields0", listOfFields0);
            }
        });
        $A.enqueueAction(action2);
    },


    saveAndNew: function(component, event, helper) {
        helper.saveAndNew(component, event);
        $A.get("e.force:refreshView").fire();
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
          var workspaceAPI = component.find("workspace");
          workspaceAPI.getFocusedTabInfo().then(function(response) {
              var focusedTabId = response.tabId;
              workspaceAPI.closeTab({tabId: focusedTabId});
          })
          .catch(function(error) {
              console.log(error);
              var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    "scope": "buildertek__Question__c"
                });
                homeEvent.fire();
          });
          $A.get("e.force:closeQuickAction").fire();
          component.set("v.isOpen", false);
          window.setTimeout(
              $A.getCallback(function() {
                  $A.get('e.force:refreshView').fire();
              }), 1000
          );
     },

     changeSelectionType:function(component, event, helper) {
        helper.changeSelectionType(component, event, helper);
     },

     changePricebook:function(component, event, helper) {
        helper.changePriceBook(component, event, helper);
     },

    handleSubmit: function (component, event, helper) {


        component.set("v.isDisabled", true);
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("fields");
        console.log(component.get('v.selectedBudgetName') , 'selectedBudgetName');
        let budgetName=component.get('v.selectedBudgetName');
        let budgetLineName=component.get('v.selectedBudgetLineName');
        let budgetLineId=component.get('v.selectedBudgetLineId');
        let budgetId=component.get('v.selectedBudgetId');
        let productId=component.get('v.selectedProductId');

        
        console.log({budgetLineId});
        

        fields["buildertek__Cost__c"] = component.get("v.SalesPrice");
        if(budgetLineId == ''){
            fields["buildertek__Budget_Line__c"] = '';
        }else{
            fields["buildertek__Budget_Line__c"] = component.get("v.selectedBudgetLineId");
        }
        
        if(budgetId == ''){
            fields["buildertek__Budget__c"] = '';
        }else{
            fields["buildertek__Budget__c"] = component.get("v.selectedBudgetId");
        }

        if(productId == ''){
            fields["buildertek__Product__c"] = '';
        }else{
            fields["buildertek__Product__c"] = component.get("v.selectedProductId");
        }

        fields["Name"] = component.get("v.optName");
        fields["buildertek__Options_Name__c"] = component.get("v.optLongName");
        fields["buildertek__Markup__c"] = component.get("v.markupValue");    

        var allData = JSON.stringify(fields);
        var action = component.get("c.saveData");
        action.setParams({
            allData : allData
        });
        action.setCallback(this, function(response){
            console.log(response.getError());
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();

                $A.get("e.force:closeQuickAction").fire();
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.get('e.force:refreshView').fire();
                    }), 1000
                );

                console.log({result});

                var saveNnew = component.get("v.isSaveNew");

                if(saveNnew){
                    $A.get('e.force:refreshView').fire();
                    component.set("v.isSaveNew", false);
                }
                else{
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                    debugger
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                }


                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    message: 'Option created successfully.',
                    duration: ' 5000',
                    type: 'success'
                });
                toastEvent.fire();
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();

                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'Something went wrong',
                        duration: ' 5000',
                        type: 'error'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
    },

    handlesaveNnew : function(component, event, helper) {
        component.set("v.isSaveNew", true);
    },

    searchBudgetData: function(component, event, helper) {
        console.log('searchBudgetData');
        component.set('v.displayBudget', true);
        component.set('v.displayBudgetLine', false);
        component.set('v.displayProduct', false);


        var selectionTypeId = component.get('v.selectionTypeId');
        console.log(selectionTypeId  , 'selectionTypeId');
        if (selectionTypeId == null || selectionTypeId =='' || selectionTypeId == undefined) {
            try {
                helper.getAlBudget(component, event, helper);
            } catch (error) {
                console.log('Error => ',error);
            }
            
        } else{
            helper.getOnlyBudget(component, event, helper , selectionTypeId);
        }

        event.stopPropagation();
 
    },
    searchProductData: function(component, event, helper) {
        component.set('v.displayProduct', true);
        component.set('v.displayBudgetLine', false);
        component.set('v.displayBudget', false);
        var pricebook =component.get("v.selectedPricebookId");
        if (pricebook == null || pricebook =='' || pricebook == undefined) {
            component.set("v.productList" , null);            
        } else{
            helper.getPricebooksProduct(component, event, helper, pricebook);
        }
        event.stopPropagation();
    },
    keyupProductData:function(component, event, helper) {
        component.set('v.displayProduct', true);

            var allRecords = component.get("v.productList");
            var searchFilter = event.getSource().get("v.value").toUpperCase();
            var tempArray = [];
            var i;
            for (i = 0; i < allRecords.length; i++) {
                if ((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                    tempArray.push(allRecords[i]);
                }else{
                    component.set('v.selectedProductId' , ' ')
                }
            }
            component.set("v.productList", tempArray);
            let pricebook =component.get("v.selectedPricebookId");

            if (pricebook == null || pricebook =='' || pricebook == undefined) {
                component.set("v.productList" , null);
            } else{
                    helper.getPricebooksProduct(component, event, helper , pricebook, searchFilter);
            }
    },
    keyupBudgetData:function(component, event, helper) {

        console.log('selectedBudgetId=====', component.get('v.selectedBudgetId'));
        // let getBugetId=component.get('v.selectedBudgetId');
        // console.log({getBugetId});
        // if(getBugetId == ' '){
        //     console.log('budgetid is null');
        //  event.getSource().set("v.readonly" , true);

            

        // }else{
            var allRecords = component.get("v.budgetList");
            var searchFilter = event.getSource().get("v.value").toUpperCase();
            console.log({searchFilter});
            var tempArray = [];
            var i;
            console.log("ok")
            for (i = 0; i < allRecords.length; i++) {
                console.log(allRecords[i].Name);
                console.log(allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1);
                if ((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                    tempArray.push(allRecords[i]);
                }else{
                    component.set('v.selectedBudgetId' , ' ')
                }
            }


            component.set("v.budgetList", tempArray);

            var selectionTypeId = component.get('v.selectionTypeId');

            if(searchFilter == ''){
                if (selectionTypeId == null || selectionTypeId =='' || selectionTypeId == undefined) {
                    try {
                        helper.getAlBudget(component, event, helper);
                    } catch (error) {
                        console.log('Error => ',error);
                    }
                    
                } else{
                    helper.getOnlyBudget(component, event, helper , selectionTypeId);
                }
            }
        // }
    },

    keyupBudgetLineData:function(component, event, helper) {
        console.log('on key up');
        var allRecords = component.get("v.budgetLineList");
        var searchFilter = event.getSource().get("v.value").toUpperCase();
        console.log({searchFilter});
        var tempArray = [];
        var i;
        for (i = 0; i < allRecords.length; i++) {
            console.log(allRecords[i].Name);
            console.log(allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1);
            if ((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                tempArray.push(allRecords[i]);
            }else{
                component.set('v.selectedBudgetLineId' , '');
            }
        }
        component.set("v.budgetLineList", tempArray);

        var selectedBudgetId = component.get('v.selectedBudgetId');
        var BudgetValue=component.get('v.selectedBudgetName');
        var budgetLineValue=  component.get('v.selectedBudgetLineId');
        console.log({budgetLineValue});


        if(searchFilter == ''){
                helper.getAllBudgetLine(component, event, helper , selectedBudgetId , BudgetValue);
        }

    },
    searchBudgetLineData:function(component, event, helper) {
        console.log('searchBudgetLineData');
        component.set('v.displayBudgetLine', true);
        component.set('v.displayBudget', false);
        component.set('v.displayProduct', false);

        console.log('<<<<<<<<<<---------->>>>>' ,  component.get('v.selectedBudgetName'));

        var BudgetValue=component.get('v.selectedBudgetName');
        var selectedBudgetId = component.get('v.selectedBudgetId');
        helper.getAllBudgetLine(component, event, helper , selectedBudgetId , BudgetValue);
        event.stopPropagation();
    },

    clickHandlerBudget: function(component, event, helper){
        // event.preventDefault();
        console.log('clickHandlerBudget');
        component.set('v.displayBudget', false);

        
        var recordId = event.currentTarget.dataset.value;
        console.log('recordId ==> '+recordId);
        component.set('v.selectedBudgetId', recordId);

        var budgetList = component.get("v.budgetList");
        budgetList.forEach(element => {
            console.log('element => ',element);
            if (recordId == element.Id) {
                component.set('v.selectedBudgetName', element.Name);
            }
        });
        // event.stopPropagation();

    },
    clickHandlerProduct: function(component, event, helper){
        component.set('v.displayProduct', false);   
        var recordId = event.currentTarget.dataset.value;
        console.log('clickHandlerProduct',recordId);
        component.set('v.selectedProductId', recordId);
        var productList = component.get("v.productList");
        productList.forEach(element => {
            if (recordId == element.Id) {
                component.set('v.selectedProductName', element.Name);
                component.set('v.selectedProductId', element.Id);
            }
        });
        var action = component.get("c.getProduct");
        action.setParams({
            productId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log({state});
            var result= response.getReturnValue();
            console.log({result});

            if (state === "SUCCESS") {
                console.log({result});
                component.set('v.optName' , result.Name);
                component.set('v.optLongName' , result.Name);
                console.log(result.PricebookEntries);
                // console.log(result.PricebookEntries[0].UnitPrice);
                if(result.PricebookEntries != undefined){
                    console.log(result.PricebookEntries[0].UnitPrice);
                    component.set('v.SalesPrice' , result.PricebookEntries[0].UnitPrice);
                }else{
                    component.set('v.SalesPrice' , 0);

                }

            }
        });
        $A.enqueueAction(action);
    },
    clickHandlerBudgetLine: function(component, event, helper){

        component.set('v.displayBudgetLine', false);
        var recordId = event.currentTarget.dataset.value;
        console.log('recordId ==> '+recordId);
        component.set('v.selectedBudgetLineId', recordId);

        var budgetLineList = component.get("v.budgetLineList");
        budgetLineList.forEach(element => {
            console.log('element => ',element);
            if (recordId == element.Id) {
                component.set('v.selectedBudgetLineName', element.Name);

            }
        });
        var action = component.get("c.getBudgetLineUnitSalesPrice");
        action.setParams({
            budgetLineId: component.get('v.selectedBudgetLineId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log({state});
            var result= response.getReturnValue();
            console.log({result});

            if (state === "SUCCESS") {
                console.log({result});
                // $A.util.removeClass(component.find("mySpinner"), "slds-hide");

                if(result.buildertek__Sales_Price__c != null){
                    component.set('v.SalesPrice' , result.buildertek__Sales_Price__c);              
                }else{
                    component.set('v.SalesPrice' , 0);

                }
                console.log(result.buildertek__Gross_Profit_Percemtage__c);


                if(result.buildertek__Gross_Profit_Percemtage__c != null){
                    component.set("v.markupValue" , result.buildertek__Gross_Profit_Percemtage__c); 
                }else{
                    component.set("v.markupValue" , 0); 

                }
            }
        });
        $A.enqueueAction(action);
    },

    
    hideList:function(component, event, helper){
        
        component.set('v.displayBudget', false);
        component.set('v.displayBudgetLine', false);
        component.set('v.displayProduct', false);
    },

    changeProduct:function(component, event, helper){
        console.log(event.getSource().get('v.value'));
        let productValue=event.getSource().get('v.value');
        var action = component.get("c.getProduct");
        action.setParams({
            productId: productValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log({state});
            var result= response.getReturnValue();
            console.log({result});

            if (state === "SUCCESS") {
                console.log({result});
                component.set('v.optName' , result.Name);
                component.set('v.optLongName' , result.Name);
                console.log(result.PricebookEntries);
                // console.log(result.PricebookEntries[0].UnitPrice);
                if(result.PricebookEntries != undefined){
                    console.log(result.PricebookEntries[0].UnitPrice);
                    component.set('v.SalesPrice' , result.PricebookEntries[0].UnitPrice);
                }else{
                    component.set('v.SalesPrice' , 0);

                }

            }
        });
        $A.enqueueAction(action);
    }



})