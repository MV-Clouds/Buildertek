({
	doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        console.log(component.get("v.budgetId") , '{{{RECORD BUDGET}}}}}');
       var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        
        helper.fetchpricebooks(component, event, helper);
        var pricebook = component.get("v.recordItem").pricebookName
        var productfamily = component.get("v.recordItem").productfamily
        var productId = component.get("v.recordItem").product.Id;
        var productName = component.get("v.recordItem").product.Name;
        var newBudgetLine = component.get("v.recordItem").newBudgetLine
        var UOMvalues = component.get("v.recordItem").UOMvalues
        var vendor = component.get("v.recordItem").Vendor
        component.set("v.pricebookName",pricebook)
        component.set("v.productfamily",productfamily)
        component.set("v.selectedContractor",vendor)
        component.set("v.newBudgetLine",newBudgetLine)
        component.set("v.UOMvalues",UOMvalues)
       /* if(productId){
            component.set("v.productId",productId)
            component.get("v.productName",productName)
            var compEvent = component.getEvent("ChildBudgetLineLookupEvent");
            compEvent.setParams({
                "message" : {
                    "Id":component.get("v.productId"),
                    "Name":component.get("v.productName")
                }
            });
            compEvent.fire();
        } */
                    
       //helper.getTableFieldSet(component, event, helper);
       /* window.setTimeout(
            $A.getCallback(function () {
                //helper.getQuoteName(component, event, helper);
               // helper.getTotalRecord(component, event, helper);
                helper.getTableRows(component, event, helper, pageNumber, pageSize);
                component.set('v.isLoading', false);
                component.set("v.listofproductfamily", '');
                var list = component.get('v.listOfRecords');
                var obj = {};
                list.unshift(obj);
                component.set('v.listOfRecords', list);
            }), 1000
        );
        */
        
    },
    /*onAddClick: function (component, event, helper) {
        var fields = component.get('v.fieldSetValues');
        var list = component.get('v.listOfRecords');
        var obj = {};
        for (var i in fields) {
            obj[fields[i].name] = '';
        }
        list.unshift(obj);
        component.set('v.listOfRecords', list);
       // helper.fetchpricebooks(component, event, helper);
    },*/
    clearLookupValue: function (component, event, helper) {
		var childCmp = component.find("tradeTypeId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("accountId");
		var retnMsg = childCmp.clearLookup();
	},
    changeEvent: function (component, event, helper) {
        helper.changeEventHelper(component, event, helper);
	},
    changefamily: function (component, event, helper) {
        var product = component.get('v.selectedLookUpRecord');
        if(Object.values(product)[0]){
           /* var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
            compEvent.setParams({
                "recordByEvent": product
            });
            compEvent.fire();*/
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
		component.set('v.newBudgetLine.buildertek__Unit_Price__c', '');
		component.set('v.newBudgetLine.buildertek__Sales_Price__c', '');
        
       /* var obj =  {
            "productfamily": component.get("v.productfamily"),
            "pricebookName" : component.get("v.pricebookName"),
            "product": {
                "Id":'',
                "Name":''
            },
            "newBudgetLine" : component.get("v.newBudgetLine"),
            "UOMvalues" : component.get("v.UOMvalues"),
            "Vendor" : component.get("v.selectedContractor"),
            "index": component.get("v.index")
        }
        component.set("v.recordItem",obj)*/
        
	},

    handleComponentEvent: function (component, event, helper) {
		// get the selected Account record from the COMPONETN event 	 
		var selectedAccountGetFromEvent = event.getParam("recordByEvent");
		component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
		helper.getProductDetails(component, event, helper);
        helper.getUOMValues(component, event, helper);
	},
    onInputChange : function (component, event, helper) {
        if(event.getSource().get("v.name")){
            var fieldName = event.getSource().get("v.name").split('-');
            var fieldLabel = fieldName[1];
            var selectedValue = event.getSource().get("v.value");
            var record = component.get('v.record');
            alert('record'+record);
            record[fieldLabel] = selectedValue != '' && selectedValue != 'None' ? selectedValue : '';
            alert('hello'+record);
            component.set('v.record', record);
        }
        
	},
    handleValueChange : function (component, event, helper) {
        var compEvent = component.getEvent("ChildBudgetLineEvent");
        compEvent.setParams({
            "isdelete" : false,
            "message" : {
                "productfamily": component.get("v.productfamily"),
                "pricebookName" : component.get("v.pricebookName"),
                "product": {
                    "Id":component.get("v.productId"),
                    "Name":component.get("v.productName")
                },
                "newBudgetLine" : component.get("v.newBudgetLine"),
                "UOMvalues" : component.get("v.UOMvalues"),
                "Vendor" : component.get("v.selectedContractor"),
                "index": component.get("v.index")
            }
        });
        var obj =  {
                "productfamily": component.get("v.productfamily"),
                "pricebookName" : component.get("v.pricebookName"),
                "product": {
                    "Id":component.get("v.productId"),
                    "Name":component.get("v.productName")
                },
                "newBudgetLine" : component.get("v.newBudgetLine"),
                "UOMvalues" : component.get("v.UOMvalues"),
                "Vendor" : component.get("v.selectedContractor"),
                "index": component.get("v.index")
            }
        component.set("v.recordItem",obj)
        compEvent.fire();
    },
    deletebudgetlineRecord: function (component, event, helper) {
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
      /*  var dataAttr = event.currentTarget.dataset.recordid.split("_");
        var recordid = dataAttr[0]; 
        var recordList;
        if(JSON.parse(JSON.stringify(component.get("v.deleteQuoteLines"))).length){
            recordList = JSON.parse(JSON.stringify(component.get("v.deleteQuoteLines")));
        }else{
            recordList =[];
        }
        var quoteLines = component.get("v.listOfRecords");
        quoteLines.splice(Number(dataAttr[1]),1);
        if(recordid){
            recordList.push(recordid);
        }
        component.set("v.listOfRecords",quoteLines);
        component.set("v.deleteQuoteLines",recordList);*/
        
    },
    
    
    
})