/* Lightning Component Controller.
 * Copyright 2018-2019, thoriyas.
 * All rights reserved
 *
 * Created by - sagar
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/* global $ sforce*/
/* eslint-disable no-console, no-alert, no-extra-boolean-cast */

({
	
	init : function (component, event, helper) {
		var richTableColumns = [];
        richTableColumns.push("");
        richTableColumns.push("Column Header");
        richTableColumns.push("Data Type");
        richTableColumns.push("Show Total");
        richTableColumns.push("Required");
        
        component.set("v.richTableColumns",richTableColumns);
	},
	
	/*This function is used for header column validation and Add new in the data table*/
	addNewRow : function (component, event, helper) {
		var richTableData = component.get('v.richTableData');
		var row = {};
		
		// validation on "Header" column
		var isValid = helper.dataTableValidation(component, event, helper);
		
		// If there is not any validation in data table then add new row in the data table 		
		if (isValid) {
			row["header"] = "";
			row["dataType"] = "Text";
			row["showTotal"] = "No";
			row["required"] = "No";
			richTableData.push(row);
	        component.set('v.richTableData',richTableData);
		}
	},
	
	/* This function is used for delete row from the data table*/
	deleteRow : function (component, event, helper) {
		var rowNumber = event.getSource().get('v.name');
		var richTableData = component.get('v.richTableData');
		richTableData.splice(rowNumber,1);
		component.set('v.richTableData',richTableData);
	},
	
	/* This function is used for change the check box value like as (true == Yes and False == No)*/
	changeInputValue : function (component, event, helper) {
		var source = event.getSource()
		if (source.get('v.checked')) {
			source.set('v.value','Yes');
		} else {
			source.set('v.value','No');
		}
	},
	
	/* this method is used for validation data table columns*/
	dataTableValidation : function (component, event, helper) {
		var columnHeaders = component.find("columnHeaders");
		if ($A.util.isUndefinedOrNull(columnHeaders)) {
			return false;
		} else {
			return helper.dataTableValidation(component, event, helper);
		}
	} 
})