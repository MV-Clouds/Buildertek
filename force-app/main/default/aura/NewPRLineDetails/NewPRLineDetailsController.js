({
    doInit: function(component, event, helper) {
        component.set("v.Spinner", true);

        var pageRef = component.get("v.pageReference");
        var state = pageRef.state;
        var base64Context = state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        component.set("v.recordId", addressableContext.attributes.recordId);
        component.set("v.PRLineDetails.buildertek__Pricing_Request_Line__c", component.get("v.recordId"));
        if(component.get("v.recordId") != null && component.get("v.recordId") != undefined && component.get("v.recordId") != ''){
            helper.getOptions(component, event, helper, component.get("v.recordId"));
        }
        component.set("v.Spinner", false);
        
    },

    closePopup: function(component, event, helper) {
        helper.closePopupHelper(component, event, helper);
    },

    createRecord: function(component, event, helper) {
        helper.createRecordHelper(component, event, helper);
    },

    clickHandler: function(component, event, helper) {
        var record = event.currentTarget.dataset.value;
        component.set("v.PRLineDetails.buildertek__Product__c", record);

        var productList = component.get("v.productList");
        productList.forEach(element => {
            if (element.Id == record) {
                component.set("v.searchProductValue", element.Name);
            }
        });
        component.set("v.displayProduct", false);
    }, 

    searchProduct: function(component, event, helper) {
        helper.searchProductHelper(component, event, helper);
    }, 

    closeSearchOption: function (component, event, helper){
        component.set("v.displayProduct", false);
    },

    changeOptions: function(component, event, helper) {
        component.set("v.Spinner", true);
        var selectedOption = event.getParam("value");
        var PRLId = selectedOption[0];
        if(PRLId != null && PRLId != undefined && PRLId != ''){
            helper.getOptions(component, event, helper, PRLId);
            console.log('PRLId ==> '+ PRLId);
            component.set("v.Spinner", false);

        }else{
            component.set("v.Spinner", false);
            component.set("v.OptionList", []);
        }
    },

    saveAndNew: function(component, event, helper) {
        component.set("v.Spinner", true);
        console.log('save and new');
        component.set("v.isSaveNew", true);
        helper.createRecordHelper(component, event, helper);
        component.set("v.Spinner", false);

    }
    
})