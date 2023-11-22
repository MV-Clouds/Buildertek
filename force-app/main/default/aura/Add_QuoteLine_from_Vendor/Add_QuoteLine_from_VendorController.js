({
    doInit : function(component, event, helper) {
        var QuoteId = component.get("v.quoteId");
        console.log('QuoteId: ' + QuoteId);
        helper.getVendors(component, event, helper);
    },

    closeCmp : function(component, event, helper) {
        component.set("v.openProductBoxwithVendor", false); 
    },

    searchVendor : function(component, event, helper) {
        var keyword = event.getSource().get("v.value");
        //ItervendorList
        //MainvendorList

        //iterate over main vendor list and if keyword matches Name , add to ItervendorList
        var MainvendorList = component.get("v.MainvendorList");
        var ItervendorList = [];
        for(var i=0; i<MainvendorList.length; i++){
            if(MainvendorList[i].Name.toLowerCase().includes(keyword.toLowerCase())){
                ItervendorList.push(MainvendorList[i]);
            }
        }
        component.set("v.ItervendorList", ItervendorList);
    },

    goToVenderPage : function(component, event, helper){
        component.set("v.selectedProduct", false);
        component.set("v.selectedVendor", true);
        component.set("v.disableBtnVen" , true);
    },

    goToProductModal: function(component, event, helper) {
        helper.goToProdModalHelper(component, event, helper);
    },

    goToEditModal: function(component, event, helper){
        helper.goToEditModalHelper(component,event,helper);
    },

    radioButtonAction: function(component, event, helper) {
        var selected = event.getSource().get("v.text");
        console.log('selected--->',selected);
        component.set('v.vendorId',selected);
        
        component.set("v.disableBtnVen" , false);
    },
    
    backToProductModal: function(component, event, helper){
        component.set("v.selectedVendor", false);
        component.set("v.selectedProduct", true);
        component.set("v.selectedEdit", false);
        helper.goToProdModalHelper(component, event, helper);
    }
})