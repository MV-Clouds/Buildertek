({
    fetchInspHelper : function(component, event, helper) {

        var reasonOption = [];
        var ar = [];
        reasonOption = component.get("v.picklistVal");
        for(var i=0;i<reasonOption.length;i++){
            ar.push(reasonOption[i].value);
        }
        console.log({ar});
        console.log({reasonOption});
        var cols = [
            {label: 'ISL#', fieldName: 'isl', type: 'text'},
            {label: 'Date Inspected', fieldName: 'dateinspected', type: 'text'},
            {label: 'Status', fieldName: 'status', type: "picklist ",editable: true, selectOptions:[{label:'Yes',value:'Yes'},{label:'No',value:'No'},]},  
        ];
        // component.set('v.mycolumns', [
        //     {label: 'ISL#', fieldName: 'isl', type: 'text'},
        //         {label: 'Date Inspected', fieldName: 'dateinspected', type: 'text'},
        //         {label: 'Status', fieldName: 'status', type: "picklist",editable: true,
        //             selectoption : ar
        //         }                
        //     ]);
            component.set('v.mycolumns',cols);
         var id1 =  component.get("v.recordId");
        // var id1 = 'a0x1K00000BVonuQAD';
         console.log({id1});
        var action = component.get("c.fetchInspections");
        action.setParams({
            // inspectionId: component.get("v.recordId"),
            inspectionId: id1
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {

                var data = response.getReturnValue();
                console.log({data});
                // component.set("v.data", data);               
                
                for ( var i = 0; i < data.length; i++ ) {
                   
                    var row = data[i];
                                      
                    row.isl = row.buildertek__Inspection_Item_Name__c;
                    row.dateinspected = row.buildertek__Date_Inspected__c;                                       
                    row.status = row.buildertek__Status__c;
                   
                }
                component.set( "v.data", data);                
            }
        });
        $A.enqueueAction(action);
    },

    getPicklist : function(component,event,helper){
        var action = component.get("c.getPicklistValues");
        action.setParams({
            objectAPIName: "buildertek__Inspection_Line__c",
            fieldAPIName: "buildertek__Status__c",
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var picklst = [];
                Object.entries(response.getReturnValue()).forEach(([key, value]) => picklst.push({ label: key, value: value }));
                console.log({picklst});
                component.set("v.picklistVal", picklst);   
                helper.fetchInspHelper(component, event, helper);             
            } else {
                var errors = response.getError();
                var message = "Error: Unknown error";
                if (errors && Array.isArray(errors) && errors.length > 0) message = "Error: " + errors[0].message;
                component.set("v.error", message);
            }
        });
        $A.enqueueAction(action);
    },

    saveInspectionhelper : function(component,event,helper){
       
    }
})