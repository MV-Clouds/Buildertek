({
    doInit: function (component, event, helper) {
        helper.getQuoteTemplate(component, event, helper);
    },

    closeModal: function (component, event, helper) {
        helper.close(component, event, helper);
    },

    submitDetails: function (component, event, helper) {
        helper.createPDF(component, event, helper);
    }
})
