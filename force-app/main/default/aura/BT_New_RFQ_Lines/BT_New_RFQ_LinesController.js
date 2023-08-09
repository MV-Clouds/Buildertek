({
    //doInit : function(component, event, helper) {

    //},
    addNewRFQLine: function (component, event, helper) {
        // // action
        // $A.get("e.c:BT_SpinnerEvent").setParams({
        //     "action": "SHOW"
        // }).fire();
        console.log('in first method');
        var action = component.get("c.getRFQLinesUsingProduct");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                console.log('state --> ',{state});
                var result = response.getReturnValue();
                console.log('result --> ',{result});
                if (result) {
                    // call below yes
                    helper.Yes(component, event, helper);
                } else {
                    // call below no
                    helper.No(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },

    importMasterRFQLine: function (component, event, helper) {
        //alert('hi');
        if (component.get("v.rfqRecord.buildertek__Status__c") != "Awarded") {
            $A.createComponents(
                [
                    [
                        "aura:html",
                        {
                            tag: "h2",
                            body: "Import Master RFQ Lines",
                            HTMLAttributes: {
                                class: "slds-text-heading_medium slds-hyphenate",
                            },
                        },
                    ],
                    [
                        "c:ImportMasterRFQItem",
                        {
                            mainObjectFieldAPI: component.get("v.objectAPI"),
                            mainObjectId: component.get("v.recordId"),
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
                            },
                        },
                    ],
                ],
                function (components, status) {
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
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: "sticky",
                message: "You cannot create RFQ lines after an RFQ has been Awarded",
                type: "error",
                duration: "10000",
                mode: "dismissible",
            });
            toastEvent.fire();
        }
    },

    importProducts: function (component, event, helper) {
        $A.createComponents(
            [
                [
                    "aura:html",
                    {
                        tag: "h2",
                        body: "Import Products",
                        HTMLAttributes: {
                            class: "slds-text-heading_medium slds-hyphenate",
                        },
                    },
                ],
                [
                    "c:Import_Products_On_RfqLines",
                    {
                        mainObjectFieldAPI: component.get("v.objectAPI"),
                        mainObjectId: component.get("v.recordId"),

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
                        },
                    },
                ],
            ],
            function (components, status) {
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
    },

    // Yes: function (component, event, helper) {
    //     var newButton = component.find("newButtonDiv");
    //     $A.util.toggleClass(newButton, "slds-show");
    //     component.set("v.openModel", true);
    //     component.set("v.open", false);
    //     component.set("v.showProductFields", true);
    // },
    // No: function (component, event, helper) {
    //     component.set("v.openModel", true);
    //     component.set("v.open", false);
    //     component.set("v.showProductFields", false);
    // },
});