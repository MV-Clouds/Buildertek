({
    doinit : function(component, event, helper) {
        helper.fetchcategorytypes(component);
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
        cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
    }
    
    
    
})