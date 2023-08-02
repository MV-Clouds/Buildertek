({
    doInit: function (component, event, helper) {
       

        console.log('inisde do it :::::::::::');
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
         var pageSize = component.get("v.pageSize");
         
         helper.fetchpricebooks(component, event, helper);
         var pricebook = component.get("v.recordItem").pricebookName
         var productfamily = component.get("v.recordItem").productfamily
         var productId = component.get("v.recordItem").product.Id;
         var productName = component.get("v.recordItem").product.Name;
         var newQuoteLine = component.get("v.recordItem").newQuoteLine;
        //  var UOMvalues = component.get("v.recordItem").UOMvalues
        //  var vendor = component.get("v.recordItem").Vendor
         component.set("v.pricebookName",pricebook);
         component.set("v.productfamily",productfamily)
         component.set("v.newQuoteLine",newQuoteLine)
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
                    
                     component.set('v.removeSingleQuoteLineOption', result[0]);
                     component.set('v.hideGlobalMargin', result[1]);
                     component.set('v.hideGlobalMarkup', result[2]);
 
 
                 }
             }
 
         });
         $A.enqueueAction(btadminaction);
    },

    getLookUpValues: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var selectedRecordId = event.getParam("selectedRecordId");
        var record = component.get('v.record');
        record[fieldName] = selectedRecordId;
        component.set('v.record', record);
    },

    onInputChange: function (component, event, helper) {
        var fieldName = event.getSource().get("v.name").split('-');
        var index = fieldName[0];
        var fieldLabel = fieldName[1];

        var selectedValue = event.getSource().get("v.value");
        console.log('selectedValue--->'+selectedValue);

        var record = component.get('v.record');


        record[fieldLabel] = selectedValue != '' && selectedValue != 'None' ? selectedValue : '';

        var NetUnit;        // buildertek__Net_Unit__c          = buildertek__Unit_Cost__c + (buildertek__Unit_Cost__c * buildertek__Markup__c) - (buildertek__Unit_Cost__c * buildertek__Additional_Discount__c)
        var Total;          // buildertek__Net_Total_Price__c   = buildertek__Total_Cost__c + buildertek__Markup_Amount__c + buildertek__Tax_Amount__c - buildertek__Discount_Amount__c
        var GrossProfit;    // buildertek__Gross_Profit__c      = buildertek__Net_Total_Price__c - buildertek__Total_Cost__c
        var ProfitMargin;   // buildertek__Profit_Margin__c     = (buildertek__Net_Total_Price__c - buildertek__Total_Cost__c)/buildertek__Net_Total_Price__c
        var Quantity, UnitCost, TotalCost, Markup, Discount;

        console.log(' - - - - - - - - - - - - - - - - - - - ');
        for (var key in record){
            console.log("key -> " + key + ", value -> " + record[key]);
            if (key == 'buildertek__Quantity__c') {
                Quantity = parseInt(record['buildertek__Quantity__c']);
                console.log('Quantity --> '+Quantity);
            } 
            else if(key == 'buildertek__Unit_Cost__c'){
                UnitCost = parseInt(record['buildertek__Unit_Cost__c']);
                console.log('UnitCost --> '+UnitCost);

            } 
            else if(key == 'buildertek__Total_Cost__c'){
                TotalCost = parseInt(record['buildertek__Total_Cost__c']);
                console.log('TotalCost --> '+TotalCost);

            } 
            else if(key == 'buildertek__Markup__c'){
                Markup = parseInt(record['buildertek__Markup__c']);
                console.log('Markup --> '+Markup);

            } 
            else if(key == 'buildertek__Additional_Discount__c'){
                Discount = parseInt(record['buildertek__Additional_Discount__c']);
                console.log('Discount --> '+Discount);

            } 
        }

        if (UnitCost != null && Markup != null && Discount != null) {
            // buildertek__Unit_Cost__c + (buildertek__Unit_Cost__c * buildertek__Markup__c) - (buildertek__Unit_Cost__c * buildertek__Additional_Discount__c)

            NetUnit = (UnitCost + ((UnitCost * Markup)/100) - ((UnitCost * Discount)/100)).toFixed(2);
            record['buildertek__Net_Unit__c'] = NetUnit;

            console.log('NetUnit ----> '+NetUnit);
        }
        if (TotalCost != null && Markup != null && UnitCost != null && Discount != null) {
                UnitCost = parseInt(record['buildertek__Unit_Cost__c']);
            Total = ((Quantity * UnitCost) + (((Quantity * UnitCost)/100)*Markup) - (((Quantity * UnitCost)/100)*Discount)).toFixed(2);
            record['buildertek__Net_Total_Price__c'] = Total;

            console.log('TotalCost ----> '+TotalCost);

        }
        if (Total != null && TotalCost != null) {
            GrossProfit = (Total-(Quantity * UnitCost)).toFixed(2);
            record['buildertek__Gross_Profit__c'] = GrossProfit;
            console.log('GrossProfit ----> '+GrossProfit);

            ProfitMargin = ((GrossProfit/Total)*100).toFixed(2);
            record['buildertek__Profit_Margin__c'] = ProfitMargin;
            console.log('ProfitMargin ----> '+ProfitMargin);
        }

        component.set('v.record', record);

        console.log('Record --> ', JSON.stringify(record));

        var parentComponent = component.get("v.parent");  
        if(NetUnit != null || Total != null || GrossProfit != null || ProfitMargin != null){
            parentComponent.reloadMethod();
        }                      

    },
    clearLookupValue: function (component, event, helper) {
		var childCmp = component.find("tradeTypeId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("accountId");
		var retnMsg = childCmp.clearLookup();
	},
    changeEvent: function (component, event, helper) {
        debugger
		var product = component.get('v.selectedLookUpRecord');
        var pribook = component.get("v.pricebookName");
        console.log('pb ', pribook);

        console.log(product , 'selectedLookUpRecord:::::');
		if(Object.values(product)[0]){
            var compEvent = $A.get('e.c:BT_BudgetItemLookupEvent');
            compEvent.setParams({
                "message" : {
                    "index" : component.get("v.index"),
                    "Id":component.get("v.productId"),
                    "Name":component.get("v.productName")
                }
            });
            compEvent.fire();
        }
            
		component.set('v.newQuoteLine.Name', '');
		component.set('v.oSelectedRecordEvent', null);
		component.set('v.newQuoteLine.buildertek__Grouping__c', null);
		component.set('v.newQuoteLine.buildertek__Sub_Group__c', null);
		component.set('v.options', '');
		component.set('v.newQuoteLine.buildertek__Sales_Price__c', '');
		component.set('v.newQuoteLine.buildertek__Unit_Price__c', '');
		component.set('v.newQuoteLine.buildertek__Quantity__c', '1');
             
		$A.enqueueAction(component.get("c.clearLookupValue"));

		var action = component.get("c.getProductfamilyRecords");
		var pribooknames = component.get("v.pricebookName");
		action.setParams({
			'ObjectName': "Product2",
			'parentId': component.get("v.pricebookName")
		});
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
				// // set searchResult list with return value from server.
				component.set("v.listofproductfamily", storeResponse);
                console.log(component.get("v.listofproductfamily").length , 'lengthlengthlength===');
                if (component.get("v.listofproductfamily").length > 0) {
                    component.set("v.productfamily", '--None--');
                } else {
                    component.set("v.productfamily", 'None');
                }
			}

		});
		// enqueue the Action  
		$A.enqueueAction(action);
        // var record = component.get('v.record');
        // component.set('v.record', record);
	},
    handleValueChange : function (component, event, helper) {
        console.log('==========================');
        console.log('recordItem ==> ',component.get("v.recordItem"));
        var compEvent = component.getEvent("ChildBudgetLineEvent");
        compEvent.setParams({
            message: component.get("v.recordItem")
        });
        // var obj =  {
        //         "productfamily": component.get("v.productfamily"),
        //         "pricebookName" : component.get("v.pricebookName"),
        //         "product": {
        //             "Id":component.get("v.productId"),
        //             "Name":component.get("v.productName")
        //         },
        //         "newQuoteLine" : component.get("v.newQuoteLine"),
        //         // "UOMvalues" : component.get("v.UOMvalues"),
        //         // "Vendor" : component.get("v.selectedContractor"),
        //         "index": component.get("v.index")
        //     }
        // console.log('obj ==> ',obj);
        // component.set("v.recordItem",obj)
        compEvent.fire();
    },
    changefamily: function (component, event, helper) {
        var product = component.get('v.selectedLookUpRecord');
        if(Object.values(product)[0]){
        
            var compEvent = $A.get('e.c:BT_BudgetItemLookupEvent');
            compEvent.setParams({
                "message" : {
                    "index" : component.get("v.index"),
                    "Id":component.get("v.productId"),
                    "Name":component.get("v.productName")
                }
            });
            compEvent.fire();
        }
        
		component.set('v.newQuoteLine.Name', '');
		component.set('v.newQuoteLine.buildertek__Unit_Price__c', '');
		component.set('v.newQuoteLine.buildertek__Sales_Price__c', '');
        
      
    },
    handleComponentEvent: function(component, event, helper) {
        // get the selected Account record from the COMPONETN event
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },
    deleteQuotelineRecord: function (component, event, helper) {
        var index = component.get("v.index");
        console.log('index '+index);
        var compEvent = component.getEvent("ChildBudgetLineEvent");
        compEvent.setParams({
            "isdelete" : true,
            "message" : {
                "index": component.get("v.index")
            }
        });
		compEvent.fire();
    }

})