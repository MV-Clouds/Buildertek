({
    doInit : function(component, event, helper) {
        var id = component.get("v.recordId");
        console.log(id);

        var Objectname = component.get("v.sobjecttype");
        console.log('Objectname---> ',Objectname);

        if(Objectname == "Account"){
            component.set("v.ShowAccountTypeOpt", true);
        }

        if (Objectname == 'buildertek__Purchase_Order__c') {
            helper.SyncPO(component, event, helper);
        }

        if(Objectname == 'buildertek__Account_Payable__c'){
            helper.SyncCOInvoice(component, event, helper)
        }
    },

    // this method only run when Object Is Account
    handleRecordLoaded: function(component, event, helper) {

        console.log(component.get("v.BTAccountType.buildertek__BT_Account_Type__c"));
        var BTAccountType = component.get("v.BTAccountType")["buildertek__BT_Account_Type__c"];
        var QBID = component.get("v.BTAccountType")["buildertek__QB_Type__c"];
        var QBType = component.get("v.BTAccountType")["buildertek__QB_Type__c"];
        if(BTAccountType == "Customer" || BTAccountType == "Vendor"){
            component.set("v.AccountType", BTAccountType)
        }
        if(QBID == null){
            helper.SyncAccountToQuickbook(component, event, helper);
        }
        else if(QBID != null){
            if(BTAccountType == QBType){
                helper.SyncAccountToQuickbook(component, event, helper);
            }
            else{
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error",
                    "message":  'This Account is sync as ' + QBType + ' in Quickbook, So You can not sync this Account as ' + BTAccountType +  ' again.',
                }); 
                $A.get("e.force:closeQuickAction").fire();
            }
        }

    },

    handleChangeAccountType: function(component, event, helper){
        var auraIdField = event.getSource().getLocalId();

        console.log('Selected account type : ',component.find(auraIdField).get("v.value"));

        component.set("v.AccountType",component.find(auraIdField).get("v.value"));
    },

    CloseQuickAction: function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

})