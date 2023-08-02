({
    
    afterRender : function(component, helper){
        console.log("---entry in afterRender---");
        this.superAfterRender();
        helper.createInspection(component, helper);
    },
    
})