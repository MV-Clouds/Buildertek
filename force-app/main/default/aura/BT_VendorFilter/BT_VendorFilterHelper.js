/* BT Lightning Component Controller.
 * Copyright 2016-2017, BuilderTek.
 * All rights reserved
 *
 * Created by 
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global JQ$*/
({
	//initializeGrid: it will call from Component Js
    initializeGrid: function (component, event, helper, objectName, filterConditions, globalId, fieldSetName) {
		var recordData, columnHeaders, columnModels, actionGetColumnHeaders, actionGetColumnModels, actionRecordData, state;
        alert('initialize data');
        //Prepare actoin to retrive column header Json
        actionGetColumnHeaders = component.get("c.columnsHeader");
        actionGetColumnHeaders.setParams({
            objectName: objectName,
            fieldSetAPI: fieldSetName
        });
        actionGetColumnHeaders.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                component.set("v.cloumnsHeader", response.getReturnValue());
                component.set("v.objectName",objectName);
            }
        });
        
        
        //Prepare actoin to retrive column model Json
        actionGetColumnModels = component.get("c.columnsModels");
        actionGetColumnModels.setParams({
            objectName: objectName,
            fieldSetAPI: fieldSetName
        });
        actionGetColumnModels.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                component.set("v.columnsModel", response.getReturnValue());
            }
        });
        
        //Prepare actoin to retrive data Json
        actionRecordData = component.get("c.recordData");
        actionRecordData.setParams({
            objectName: objectName,
            filterConditions: filterConditions,
            fieldSetAPI: fieldSetName
        });
        
        actionRecordData.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                component.set("v.rowData", response.getReturnValue());
                component.set("v.filterConditions",filterConditions);
                component.set("v.gridLoad",true);
            }
        });
        
        
        //enqueue GetColumnHeaders method
        $A.enqueueAction(actionGetColumnHeaders);

        //enqueue GetColumnModels method
        $A.enqueueAction(actionGetColumnModels);
        
        //enqueue RecordData method
        $A.enqueueAction(actionRecordData);
		
	}
})