({
    showError: function(component ,title, severity, errorMessage) {
        component.set("v.title",title);
        component.set("v.severity",severity);
        component.set("v.errorMessage",errorMessage);
        component.set("v.showMessage",true);
    }
});