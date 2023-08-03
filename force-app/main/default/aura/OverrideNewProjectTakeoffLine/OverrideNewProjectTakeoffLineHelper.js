({
    getParameterByName: function (component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        //alert('url -------> '+url);
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
            var getProductDetails = component.get("v.newprojecttakeoffline");
            ////console.log("@Budgetline@",component.get("v.recordId"));

            /* getProductDetails.buildertek__Description__c = productName;
             if(res.length>=1) {
                 getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
             }else{
                 getProductDetails.buildertek__Unit_Price__c = 0;
             } */
            getProductDetails.buildertek__Product__c = productId;

            getProductDetails.buildertek__Description__c = productName;
            component.set("v.newprojecttakeoffline", getProductDetails);
        });
        $A.enqueueAction(action);
    },
    fetchpricebooks: function (component, event, helper) {
        var action = component.get("c.getpricebook");
        action.setParams({
            "PtoffId": component.get("v.recordId")
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

    getFieldSetforTakeOffLines: function (component, event, helper , parentRecordId) {
		var action5 = component.get("c.getFieldSet");
        action5.setParams({
            objectName: 'buildertek__Project_Takeoff_Lines__c',
            fieldSetName: 'buildertek__TakeOff_Lines'
        });
        action5.setCallback(this, function (response) {     
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                component.set("v.Spinner", false);
                var listOfFields0 = JSON.parse(response.getReturnValue());
                console.log('listOfFieldsofPOLine-->>',{listOfFields0});
                component.set("v.listOfFields0", listOfFields0);

                if(parentRecordId != undefined && parentRecordId != ''){
                    // const parentRecordId = 'home';
                    parentRecordId != 'home' ?component.find('projectTakeOff').set("v.value", parentRecordId): " ";
                }
            }
        });
        $A.enqueueAction(action5);
	},

})