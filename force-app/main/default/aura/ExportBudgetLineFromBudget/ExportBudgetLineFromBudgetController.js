({
    doInit : function(component, event, helper) {
        console.log('**INIT Method**');
        console.log(component.get('v.recordId'));
        var action=component.get('c.getBudgetLine');
        action.setParams({
            BudgetId:component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            console.log(response.getReturnValue());
            var result= response.getReturnValue();
            console.log({result});
            var state= response.getState();
            console.log({state});
            if(state == 'SUCCESS'){
                component.set('v.budgetLineList' , result);
            }
        });
        $A.enqueueAction(action);
    },

    changeFileName: function(component, event, helper) {
        var getValue= event.getSource().get('v.value');
        component.set('v.fileName', getValue);
    },

    exportData : function(component, event, helper) {
        console.log('**EXPORT DATA**');
        var fileName=component.get('v.fileName');

        // var columns= ["buildertek__Product_Name__c", "Name" , "buildertek__Total_Sales_Price__c" , "buildertek__Markup__c" ,"buildertek__Labor__c", "buildertek__Total_Approvals_CO__c",  "buildertek__Committed_Costs__c" , "buildertek__Additional_Costs__c", "buildertek__Invoice_total__c", "buildertek__Total_Costs__c", "buildertek__Unit_Price__c", "buildertek__Quantity__c", "buildertek__Markup__c"," buildertek__Tax__c", "buildertek__Group_Name__c"];

        var columns= ["buildertek__Group_Name__c" , "Name",  "buildertek__Quantity__c", "buildertek__Unit_Price__c", "buildertek__Tax__c", "buildertek__Markup__c" , "buildertek__Labor__c", "buildertek__Total_Approvals_CO__c", "buildertek__Committed_Costs__c", "buildertek__Additional_Costs__c" , "buildertek__Invoice_total__c", , "buildertek__Total_Costs__c", "buildertek__Total_Sales_Price__c"];

        var budggetLineList=component.get('v.budgetLineList');
        const jsonArray= budggetLineList.map(function(item){
            var obj={};
            columns.forEach(function(column){
                console.log({column});
                console.log(item.hasOwnProperty(column));
                if(item.hasOwnProperty(column)){
                    if (typeof item[column] === 'string') {
                        obj[column]=item[column].replace(/[#,]/g , ';');
                    }else{
                        obj[column]=item[column];
                    }

                }else{
                    if(column== 'Name'){
                        obj[column]=null;

                    }else if(column=='buildertek__Group_Name__c'){
                        obj[column]=null;

                    }else if(column=='buildertek__Product_Name__c'){
                        obj[column]=null;
                        
                    }else{
                        obj[column]=0;
                    }
                }
            });
            return obj;
        });


        var csvContent = "data:text/csv;charset=utf-8,";
        if(jsonArray.length > 0){
            var headers = Object.keys(jsonArray[0]).join(",");
            csvContent += headers + "\n";

            // Iterating over each object and extracting values
            jsonArray.forEach(function(obj) {
            var row = Object.values(obj).join(",");
            console.log({row});
            csvContent += row + "\n";
            });
            console.log({csvContent});
            var encodedUri = encodeURI(csvContent);
            var link = document.createElement("a");
            link.setAttribute("href", encodedUri);
            link.setAttribute("download", fileName+".csv");
            document.body.appendChild(link);
            link.click();
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "",
                "message": "There are no BudgetLines to Export",
                "type": "error"
            });
            toastEvent.fire();
        }
        
        $A.get("e.force:closeQuickAction").fire();

    },
    closeModel:function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
})