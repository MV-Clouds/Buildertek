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
        var pricebookId = component.get("v.recordItem").pricebookName;
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({
            productId: productId,
            pricebookId: pricebookId
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            var getProductDetails = component.get("v.newBudgetLine");
           delete getProductDetails.buildertek__Group__r;
            ////console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Budget__c = component.get("v.recordId");
            console.log("getprodct----",JSON.stringify(getProductDetails));
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
        component.set('v.isLoading', true);

        var action = component.get("c.getpricebook");
        action.setParams({
            BudgetId: component.get("v.recordId"),
        });
         var opts = [];
         action.setCallback(this, function (response) {
             if (response.getState() == "SUCCESS") {
                 var pricebook = component.get("v.recordItem").pricebookName
                 var productfamily = component.get("v.recordItem").productfamily
                 var productId = component.get("v.recordItem").product.Id;
                 var productName = component.get("v.recordItem").product.Name;
                 var newBudgetLine = component.get("v.recordItem").newBudgetLine
                 var UOMvalues = component.get("v.recordItem").UOMvalues
                 var vendor = component.get("v.recordItem").Vendor
                 component.set("v.pricebookName",pricebook)
                 component.set("v.selectedLookUpRecord",component.get("v.recordItem").product)
                 component.set("v.productfamily",productfamily)
                 component.set("v.selectedContractor",vendor)
                 component.set("v.newBudgetLine",newBudgetLine)
                 component.set("v.UOMvalues",UOMvalues)
                 component.set("v.productId",productId)
                 component.get("v.productName",productName)
                 helper.fetchPickListVal(component, event, helper);
                 if(productfamily){
                     var valObj = {'productfamilyvalues': productfamily}
                     var prodFam = [];
                     prodFam.push(valObj);
                     component.set("v.listofproductfamily", prodFam);
                 }
                 
                 if(!pricebook){
                   component.set("v.pricebookName", response.getReturnValue());  
                 }
             }
         });
        $A.enqueueAction(action);
        var actions = component.get("c.getpricebooks");
        actions.setParams({
            recordId:component.get('v.budgetId')
        })
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                console.log(component.get('v.budgetId'));
                var result = response.getReturnValue();
                console.log({result});
                let projectHavePricebook=result[0].defaultValue;
                var pricebookOptions = [];
                if(Object.keys(projectHavePricebook).length !=0){
                    pricebookOptions.push({ key: projectHavePricebook.Name, value: projectHavePricebook.Id });
                    result[0].priceWrapList.forEach(function(element){
                        if(projectHavePricebook.Id !== element.Id){
                            pricebookOptions.push({ key: element.Name, value: element.Id });
                        }else{
                            pricebookOptions.push({ key: "None", value: "" });

                        }
                    });
                    component.set('v.pricebookName' , projectHavePricebook.Id);

                }else{
                    pricebookOptions.push({ key: "None", value: "" });
                    result[0].priceWrapList.forEach(function(element){
                        pricebookOptions.push({ key: element.Name, value: element.Id });
                    });
                }

                if(component.get('v.pricebookName')!= undefined || component.get('v.pricebookName')!=null){
                    helper.changeEventHelper(component, event, helper);
                }

                component.set("v.pricebookoptions", pricebookOptions);
                component.set('v.isLoading', false);


            }else{
                component.set('v.isLoading', false);

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
    getTableRows: function (component, event, helper ,pageNumber, pageSize) {
        debugger;
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
    changeEventHelper: function (component, event, helper) {
        component.set('v.isLoading', true);

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
            
		component.set('v.newBudgetLine.Name', '');
		component.set('v.oSelectedRecordEvent', null);
		component.set('v.newBudgetLine.buildertek__Group__c', null);
		component.set('v.newBudgetLine.buildertek__Sub_Grouping__c', null);
		component.set('v.options', '');
		component.set('v.newBudgetLine.buildertek__Sales_Price__c', '');
		component.set('v.newBudgetLine.buildertek__Unit_Price__c', '');
		component.set('v.newBudgetLine.buildertek__Quantity__c', '1');
		$A.enqueueAction(component.get("c.clearLookupValue"));
		var action = component.get("c.getProductfamilyRecords");
		var pribooknames = component.get("v.pricebookName");
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
                component.set('v.isLoading', false);

			}else{
                component.set('v.isLoading', false);

            }

		});
		// enqueue the Action  
		$A.enqueueAction(action);
            var record = component.get('v.record');
       // record[fieldLabel] = selectedValue != '' && selectedValue != 'None' ? selectedValue : '';
       // alert('hello'+record);
        component.set('v.record', record);
	},
})