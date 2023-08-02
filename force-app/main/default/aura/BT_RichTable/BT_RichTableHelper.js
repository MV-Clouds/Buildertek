({
	/* This is for validation on data table "Header" column*/
	dataTableValidation : function (component, event, helper) {
		var columnHeaders = component.find("columnHeaders");
		var dataTableColumnHeaders = [];
		
		// when data table has one row then put in array for validation.
		// for exam-: if there is multi-row then its type is array but
		// if there is only one row that is not array for this scenario use a array.
		if (!$A.util.isUndefinedOrNull(columnHeaders) && $A.util.isUndefinedOrNull(columnHeaders.length)) {
			dataTableColumnHeaders.push(columnHeaders);
		} else {
			dataTableColumnHeaders = columnHeaders;
		}
		
		// validation on all rows "Header" column
		if (!$A.util.isUndefinedOrNull(dataTableColumnHeaders)) {
			for (var i in dataTableColumnHeaders) {
				var inputField = dataTableColumnHeaders[i];
				if ($A.util.isUndefinedOrNull(inputField.get("v.value")) || $A.util.isEmpty(inputField.get("v.value")) ) {
					inputField.showHelpMessageIfInvalid();
					return false;
				}
			}
		}
		
		return true;
	}
})