({
    getParameterByName: function (component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
     getProductDetails: function (component, event, helper) {
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({
            "productId": productId
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            var getProductDetails = component.get("v.newPOItem");
            ////console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Change_Order__c = component.get("v.mainObjectId");
            getProductDetails.Name = productName;
            component.set("v.PdtName", productName);
            if (res.length >= 1) {
                if(res[0].buildertek__Unit_Cost__c !=null){
                getProductDetails.buildertek__Unit_Price__c = res[0].buildertek__Unit_Cost__c;
                component.set("v.UnitPrice", res[0].buildertek__Unit_Cost__c);
                  //  alert( res[0].buildertek__Unit_Cost__c);
                }
                if (res[0].buildertek__Discount__c != null) {
                    getProductDetails.buildertek__Discount__c = res[0].buildertek__Discount__c;
                }
            } else {
                getProductDetails.buildertek__Unit_Price__c = 0;
                component.set("v.UnitPrice", '0');
            }
            getProductDetails.buildertek__Product__c = productId;

            getProductDetails.Name = productName;
             component.set("v.PdtName", productName);
            component.set("v.newPOItem", getProductDetails);
        });
        $A.enqueueAction(action);
    },

    
    fetchpricebooks: function (component, event, helper) {
        var action = component.get("c.getpricebook");
        action.setParams({
            "BudgetId": component.get("v.recordId")
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
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(actions);
    },
    getFields: function (component, event, helper) {
       // alert("field");
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields = JSON.parse(response.getReturnValue());
                component.set("v.listOfFields", listOfFields);
               // component.find("Name").set("v.autocomplete","off");
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    vendors: function (component, event, helper) {
        var parentId = component.get("v.parentRecordId")
        var action = component.get("c.getNames");
        action.setParams({
					RecordId: parentId
				});
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                
               var NameOfVendor = response.getReturnValue();
                
                component.set("v.NameOfVendor", NameOfVendor);
            } else {
                console.log('Error');
            }
             });
        $A.enqueueAction(action);
    },
    resetComponent: function (component, event, helper)
    {
         component.set('v.buttonTypeName','saveButton')
        component.set('v.pricebookName','');
        component.set('v.productfamily','');
        component.set('v.UnitPrice',null);
        component.set('v.selectedLookUpRecord',null);
        component.set("v.productId", '');
        component.set("v.productName", '');
        component.set('v.newPOItem.Name', '');
        component.set('v.newPOItem.buildertek__Unit_Price__c', '');
        component.set("v.UnitCost",'' );
        component.set("v.mainObjectId",component.get('v.parentRecordId'));
        
        if(component.get("v.ischangeorderline") == true)
        {
          //  alert("ok")
            component.set("v.lineName",'' );
            component.set("v.mainObjectId",component.get('v.parentRecordId'));
        }

        $A.enqueueAction(component.get('c.changeEvent'));

        var COId = component.get('v.parentRecordId');
        component.set("v.parentRecordId",'');
        component.set("v.parentRecordId",COId);

        component.set('v.isLoading', false);
    },
    showToast: function (component, event, helper,toastTitle,toastMessage,toastType)
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : toastTitle,
            message: toastMessage,
            duration: '10000',
            key: 'info_alt',
            type: toastType,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },

    validateRecordData: function (component, event, helper)
    {
       
        var fields2 = event.getParam("fields");
       // alert( JSON.stringify(fields2));
        console.log('@@fields2 name--'+fields2["name"] );

        var nameField = fields2["name"];
        if(nameField == null || nameField == undefined || nameField == '')
        {
            this.showToast(component, event, helper,'Error','Please Enter a Name','error');
            return false;
        }

        var changeOrderField = fields2["buildertek__Change_Order__c"];
        if(changeOrderField == null || changeOrderField == undefined || changeOrderField == '')
        {
            this.showToast(component, event, helper,'Error','Please Enter a Change Order','error');
            return false;
        }
        return true;
    },

    getResponseFromCustomSettings: function(component, event, helper){
        var action = component.get("c.checkCustomSettings");
        action.setParams({

        });
        action.setCallback(this, function(response){
            if (response.getState() == 'SUCCESS') {
                debugger
                console.log('@@response.getReturnValue()--'+response.getReturnValue());
                var getBoolValue = response.getReturnValue();
                if (getBoolValue) {
                    component.set('v.isopen',false);
                    component.set('v.ischangeorder',true);
                    component.set('v.ischangeorderline',false);
                    component.set('v.isproduct',true);
                }else if (!getBoolValue){
                    component.set('v.isopen',false);
                    component.set('v.ischangeorder',true);
                    component.set('v.isproduct',false);
                    component.set('v.ischangeorderline',true);
                    var listofchange = component.get("v.listOfFields");
                    var collist = [];
                    if(component.get('v.ischangeorderline') == true){
                        for (var i = 0; i < listofchange.length; i++) {
                            if(listofchange[i].name != 'buildertek__Product__c'){
                                collist.push(listofchange[i]);
                            }
                        }
                        component.set("v.listOfFields",collist);
                    }
                }else if(getBoolValue == null){
                    this.showToast(component, event, helper,'Error','Something went wrong','error');
                }
            }
        });
        $A.enqueueAction(action);
    }
        
        
})