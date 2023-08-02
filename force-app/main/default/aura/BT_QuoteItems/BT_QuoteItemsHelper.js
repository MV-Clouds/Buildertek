({
    getDropDownValues: function (component, event, helper, fieldName) {
        var record = component.get('v.record');
        var action = component.get("c.getDropDown");
        action.setParams({
            fieldName: fieldName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.dropDown', response.getReturnValue());
            } else if (state === "ERROR") {
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
    fetchpricebooks: function (component, event, helper) {
        console.log(component.get("v.recordId"));
        var action = component.get("c.getpricebook");
        action.setParams({
            quoteId: component.get("v.recordId"),
        });
         var opts = [];
         action.setCallback(this, function (response) {
            console.log(response.getState());
            console.log(response.getReturnValue() , 'RESPONSE:::::::::::::::');

             if (response.getState() == "SUCCESS") {
                 var pricebook = component.get("v.recordItem").pricebookName
                 var productfamily = component.get("v.recordItem").productfamily
                 var productId = component.get("v.recordItem").product.Id;
                 var productName = component.get("v.recordItem").product.Name;
                 var newQuoteLine = component.get("v.recordItem").newQuoteLine
                //  var UOMvalues = component.get("v.recordItem").UOMvalues
                //  var vendor = component.get("v.recordItem").Vendor
                 component.set("v.pricebookName",pricebook)
                 component.set("v.selectedLookUpRecord",component.get("v.recordItem").product)
                 component.set("v.productfamily",productfamily)
                //  component.set("v.selectedContractor",vendor)
                 component.set("v.newQuoteLine",newQuoteLine)
                //  component.set("v.UOMvalues",UOMvalues)
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
    fetchPickListVal: function(component, event, helper) {
        var actions = component.get("c.getselectOptions");
        actions.setParams({
            "QuoteObject": component.get("v.newQuoteLine"),
            "QuoteField": "buildertek__UOM__c"
        });
        var opts = [];
        actions.setCallback(this, function(response) {
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
    getProductDetails: function(component, event, helper) {
        var pricebookId = component.get("v.recordItem").pricebookName;
        console.log({pricebookId});
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        console.log({productId});

        var productName = component.get("v.productName");
        action.setParams({
            productId: productId,
            pricebookId: pricebookId
        });
        action.setCallback(this, function(respo) {
            console.log(respo.getState());
            console.log(respo.getError());

            

            var res = respo.getReturnValue();
            console.log({res});
            var ProductDetails = component.get("v.newQuoteLine");
            delete ProductDetails.buildertek__Grouping__r;
            ProductDetails.buildertek__Quote__c = component.get("v.recordId");
            if (res.length >= 1) {


                if (res[0].UnitPrice >= res[0].buildertek__Unit_Cost__c) {
                    var diffVal = res[0].UnitPrice - res[0].buildertek__Unit_Cost__c;
                    console.log("Diff Value : " + diffVal)
                    var mark = (diffVal / res[0].buildertek__Unit_Cost__c);

                    //ProductDetails.buildertek__Markup__c = (diffVal/res[0].buildertek__Unit_Cost__c) * 100;
                    if (mark != 'Infinity') {
                        //  ProductDetails.buildertek__Markup__c = (diffVal/res[0].buildertek__Unit_Cost__c).toFixed(2); 
                        ProductDetails.buildertek__Markup__c = res[0].buildertek__Markup__c;
                        console.log(ProductDetails.buildertek__Markup__c)
                    } else {
                        ProductDetails.buildertek__Markup__c = 0;
                    }

                } else {
                    ProductDetails.buildertek__Markup__c = 0;
                }
                ProductDetails.buildertek__Unit_Cost__c = res[0].buildertek__Unit_Cost__c;
                ProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
            
            } else {
                ProductDetails.buildertek__Unit_Cost__c = 0;
                ProductDetails.buildertek__Unit_Price__c = 0;
                ProductDetails.buildertek__Markup__c = 0;
                ProductDetails.buildertek__Additional_Discount__c = 0;
            }
            ProductDetails.buildertek__Product__c = productId;
            ProductDetails.Name = productName;

            console.log("Quote 21")
            component.set("v.newQuoteLine", ProductDetails);
            if(ProductDetails.buildertek__Unit_Cost__c == undefined || ProductDetails.buildertek__Unit_Cost__c == null){
                component.set("v.newQuoteLine.buildertek__Unit_Cost__c", ProductDetails.buildertek__Unit_Price__c );
                console.log("Used unit price --->", ProductDetails.buildertek__Unit_Price__c)
            }
            else{
                component.set("v.newQuoteLine.buildertek__Unit_Cost__c", ProductDetails.buildertek__Unit_Cost__c );
                console.log("unitCost----->", JSON.parse(JSON.stringify(ProductDetails)));
            }
            console.log("Grouping-->", res[0].Product2.buildertek__Quote_Group__c )
            if(res[0].Product2.buildertek__Quote_Group__c != undefined && res[0].Product2.buildertek__Quote_Group__c != null){
                console.log("Inside Grouping-->", res[0].Product2.buildertek__Quote_Group__c )
                component.set("v.newQuoteLine.buildertek__Grouping__c", res[0].Product2.buildertek__Quote_Group__c);
                component.set("v.newQuoteLine.buildertek__Grouping__r.Name", res[0].Product2.buildertek__Quote_Group__r.Name);
            }

            if(res[0].Product2.Name != undefined && res[0].Product2.Name != null){
                component.set("v.newQuoteLine.Name", res[0].Product2.Name);
            }

        });
        $A.enqueueAction(action);
    },


    
    
})