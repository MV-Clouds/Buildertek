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
        
})