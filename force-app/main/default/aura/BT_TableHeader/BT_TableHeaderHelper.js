({
    switchArrow : function(component) {
        var showArrowDown = component.get("v.showArrowDown");
        component.set("v.showArrowDown", !showArrowDown);
        this.updateArrowClass(component);
    },
    updateArrowClass : function(component){
        if(component.get("v.showArrowDown")){
            component.set("v.arrowUpClass","slds-show");
            component.set("v.arrowDownClass","slds-hide"); 
            component.set("v.orderBy", 'ASC');
             
        }else{
            component.set("v.arrowDownClass","slds-show");
            component.set("v.arrowUpClass","slds-hide");
            component.set("v.orderBy", 'DESC');
            
        }
        var orderedBy = component.get("v.orderBy");
        var cmpEvent = component.getEvent("ProductHeaderEvent"); 
        //Set event attribute value
        cmpEvent.setParams({"OrderByProduct" : orderedBy}); 
        cmpEvent.fire();
    },
})