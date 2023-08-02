({
	helperMethod : function() {
		
	},
    Yes: function (component, event, helper) {
        var newButton = component.find("newButtonDiv");
        $A.util.toggleClass(newButton, "slds-show");
        component.set("v.openModel", true);
        component.set("v.open", false);
        component.set("v.showProductFields", true);
        helper.showCMP(component,event,helper);
    },
    No: function (component, event, helper) {
        component.set("v.openModel", true);
        component.set("v.open", false);
        component.set("v.showProductFields", false);
        helper.showCMP(component,event,helper);
    },
    showCMP: function(component, event, helper){
        if (component.get("v.openModel")) {
            console.log('In if Condition:::');
            component.set("v.openModel", false);
            $A.createComponents(
                [
                    [
                        "aura:html",
                        {
                            tag: "h2",
                            body: "New RFQ Lines",
                            HTMLAttributes: {
                                class: "slds-text-heading_medium slds-hyphenate",
                            },
                        },
                    ],
                    [
                        "c:BT_New_RFQ_Items_Override",
                        {
                            mainObjectFieldAPI: component.get("v.objectAPI"),
                            mainObjectId: component.get("v.recordId"),
                            showProductFileds: component.get("v.showProductFields"),
                            onCancel: function () {
                                //alert('hi DFL');
                                //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                                component.get("v.modalPromise").then(function (modal) {
                                    modal.close();
                                });
                                $A.get("e.force:refreshView").fire();
                            },
                            onSuccess: function (file) {
                                //alert('hi');
                                $A.get("e.c:BT_SpinnerEvent")
                                    .setParams({ action: "HIDE" })
                                    .fire();
                                component.get("v.modalPromise").then(function (modal) {
                                    modal.close();
                                });
                                $A.get("e.force:refreshView").fire();
                                // var toastEvent = $A.get("e.force:showToast");
                                // toastEvent.setParams({
                                //     mode: 'sticky',
                                //     message: 'RFQ Line created successfully',
                                //     type : 'success',
                                //     duration: '10000',
                                //     mode: 'dismissible'
                                // });
                                // toastEvent.fire();
                            },
                        },
                    ],
                ],
                function (components, status) {
                    console.log('calling this before opening model');
                    if (status === "SUCCESS") {
                        var modalPromise = component.find("overlay").showCustomModal({
                            header: components[0],
                            body: components[1],
                            footer: components[1].find("footer"),
                            showCloseButton: true,
                            cssClass: "",
                            closeCallback: function () { },
                        });
                        component.set("v.modalPromise", modalPromise);
                    }
                }
            );
        }
    }
})