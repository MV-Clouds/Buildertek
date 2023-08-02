({
    doInit : function(component, event, helper) {
        var action = component.get("c.getProject");
        var recId = component.get("v.recordId");
        action.setParams({
            "recordId" : recId,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                 component.set("v.projectName", response.getReturnValue());
            }
            else{
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                "type": 'error',
                "message": 'Please Add Purchase Order(s)',
                
            });
            toastEvent.fire();  
            }
        });
         $A.enqueueAction(action);
        helper.getPoList(component, event, helper);
        helper.setColumns(component);
    },
    doRfqSearch : function(component, event, helper) {
        //var pageNumber = component.get("v.PageNumber");
        //var pageSize = component.get("v.pageSize");
        helper.getPoList(component, event, helper);
    },
    handleSort: function(component, event, helper) {
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        
        //component.set("v.sortBy",sortBy);
        //component.set("v.sortDirection",sortDirection);
        
        // call sortData helper function
        var data = JSON.parse(JSON.stringify(event.getSource().get("v.data")));
        //var tableId = JSON.parse(JSON.stringify(event.getSource().getLocalId()));
        helper.sortData(component,event,sortBy,sortDirection,data)//,tableId);
    },
    doGroupByVendor : function(component, event, helper) {
        var data = component.get("v.orgData");
        var toggleVal = component.get("v.groupBytoggle");
        component.set("v.selectedTableRows", []);
        component.set("v.selectedTableRowIds", []);

        if(toggleVal){
            component.set("v.Spinner", true);
            helper.formatDataByGroups(component,event,helper,data); 
            
        }
        
    },
    sendMail : function(component, event, helper) {
        console.log(component.get("v.selectedTableRows"));
        var action = component.get("c.sendMailToContact");
        var selectedIds = component.get("v.selectedTableRowIds");
        var selectedRows = component.get("v.selectedTableRows");
        if(selectedIds.length){
            component.set("v.Spinner", true);
            component.set("v.showMessage",true);
            action.setParams({
                "PoIds" : selectedIds
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.Spinner", false);
                    component.set("v.showMessage",false);
                }
            });
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": 'error',
                "message": 'Please select Purchase Order(s)',
                
            });
            toastEvent.fire();  
        }
        
    },
    getSelectedRow : function(component, event, helper) {
        var selectedRows = JSON.parse(JSON.stringify(event.getParam('selectedRows')));
        var setRows = [];
        var setRowIds = [];
        var groupDataMap = JSON.parse(JSON.stringify(component.get("v.dataByGroup")));
        var selectedGroupMap = JSON.parse(JSON.stringify(component.get("v.selectedRowsByGroupMap")));
        if(component.get("v.groupBytoggle")){
            setRows = JSON.parse(JSON.stringify(component.get("v.selectedTableRows")));
            setRowIds = JSON.parse(JSON.stringify(component.get("v.selectedTableRowIds")));
            var newSetRows = [];
            var newSetIds = [];
            if(selectedRows.length){
                 for ( var i = 0; i < selectedRows.length; i++ ) {
                    if(setRowIds.length){
                        if(selectedRows[i].Id && setRowIds.indexOf(selectedRows[i].Id) == -1){
                            newSetRows.push(selectedRows[i]);
                            setRows.push(selectedRows[i]);
                            setRowIds.push(selectedRows[i].Id);
                            newSetIds.push(selectedRows[i].Id);
                        }else if(selectedRows[i].Id && setRowIds.indexOf(selectedRows[i].Id) > -1){
                            newSetRows.push(selectedRows[i]);
                            newSetIds.push(selectedRows[i].Id);
                        }
                    }else{
                        if(selectedRows[i].Id){
                            newSetRows.push(selectedRows[i]);
                            setRows.push(selectedRows[i]);
                            setRowIds.push(selectedRows[i].Id);
                            newSetIds.push(selectedRows[i].Id);
                        }
                    } 
                } 
                //newSetRows.push(selectedRows);
                var filterSetRows = setRows.filter(function(item,index){
                    if(JSON.parse(JSON.stringify(event.getSource().get("v.data")))[0].buildertek__Vendor__c != item.buildertek__Vendor__c){
                        newSetIds.push(item.Id);
                        newSetRows.push(item);
                        return item;
                    }
                });
                setRows = newSetRows;
                setRowIds = newSetIds;            
                 
                /*for ( var i = 0; i < setRows.length; i++ ) {
                    if(setRowIds.length){
                        if(setRowIds.indexOf(setRows[i].Id) == -1){
                            //setRows.push(selectedRows[i]);
                            setRowIds.push(setRows[i].Id);
                        }
                    }else{
                        if(setRows[i].Id){
                            //setRows.push(selectedRows[i]);
                            setRowIds.push(setRows[i].Id);
                        }
                    } 
                }*/
                component.set("v.selectedRowsByGroupMap",selectedGroupMap);
                component.set("v.selectedTableRows", setRows);
                component.set("v.selectedTableRowIds",setRowIds);
            }else{
                var unselectedTableData = event.getSource().get("v.data");
                var groupName = JSON.parse(JSON.stringify(event.getSource().get("v.data")))[0].buildertek__Vendor__c;
                var filteredSetRowIds = [];
                var filteredSetRows = setRows.filter(function(item,index){
                    if(JSON.parse(JSON.stringify(event.getSource().get("v.data")))[0].buildertek__Vendor__c != item.buildertek__Vendor__c){
                       	filteredSetRowIds.push(item.Id); 
                        return item;
                    }
                })
                component.set("v.selectedTableRows", filteredSetRows);
                component.set("v.selectedTableRowIds",filteredSetRowIds);
            }
        }else{
            for ( var i = 0; i < selectedRows.length; i++ ) {
                if(selectedRows[i].Id){
                        setRows.push(selectedRows[i]);
                        setRowIds.push(selectedRows[i].Id);
                }
            }
            component.set("v.selectedTableRows", setRows);
            component.set("v.selectedTableRowIds",setRowIds);
        }
    },
})