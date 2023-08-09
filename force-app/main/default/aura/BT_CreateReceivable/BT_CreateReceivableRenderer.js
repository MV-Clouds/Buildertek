({
	afterRender : function(component, helper){
        console.log("---entry in afterRender---");
        this.superAfterRender();
        helper.createInvoice(component, helper);
    },
})