({
    
    afterRender : function(component, helper){
        console.log("---entry in afterRender---");
        this.superAfterRender();
        helper.CreateInvoice(component, helper);
    },

})