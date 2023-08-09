({
    
    afterRender : function(component, helper){
        console.log("---entry in afterRender---");
        this.superAfterRender();
        helper.createContract(component, helper);
    },
    
})