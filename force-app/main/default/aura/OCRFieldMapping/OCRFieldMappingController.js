({
	doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
		var action = component.get("c.getLatestFiles");  
        action.setParams({  
            "documentIds": component.get("v.fileId")  
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue(); 
                window.setTimeout(
                    $A.getCallback(function() {
                        var nextAction = component.get("c.getImageResponse");
                        nextAction.setParams({
                            resultId : result
                        });
                        nextAction.setCallback(this, function(response){
                            if(response.getState() === "SUCCESS"){
                                var jsonResponse = response.getReturnValue();  
                                //component.set("v.readResults", jsonResponse.readResults);
                                //component.set("v.pageResults", jsonResponse.pageResults);
                                var textedJson = JSON.parse(jsonResponse.responseString);
                                component.set("v.jsonObject", textedJson);
                                textedJson = JSON.stringify(textedJson, undefined, 4);
                                component.set("v.jsonData", textedJson);
                                console.log('textedJson --------> '+textedJson);
                                var pageResults = jsonResponse.pageResults;
                                var readResults = jsonResponse.readResults;
                                console.log('pageResults initial ------> '+JSON.stringify(pageResults));
                                var rowsList = [];
                                var columnsList = [];
                                var fields = [];
                                var headerLabelsList = [];
                                var labelsList = [];
                                for(var a=0;a<readResults.length;a++){
                                	fields.push(readResults[a].fields);	    
                                }
                                //console.log('text value -----> '+fields[0].CustomerName.text);
                                component.set("v.readResults", fields);
                                console.log('fields -------> '+JSON.stringify(fields));
                                for(var i=0;i<pageResults.length;i++){
                                    if(pageResults[i].tables != undefined){   
                                        for(var j=0;j<pageResults[i].tables.length;j++){
                                            for(var k=0;k<pageResults[i].tables[j].rows;k++){
                                                rowsList.push({"rowNumber": k});
                                                for(var l=0;l<pageResults[i].tables[j].columns;l++){
                                                    columnsList.push({"rowNumber": k, "columnNumber": l});
                                                }
                                            }
                                            var count = 0;
                                            for(var m=0;m<pageResults[i].tables[j].cells.length;m++){
                                            	pageResults[i].tables[j].cells[m].tableId = j;
                                                if(pageResults[i].tables[j].cells[m].rowIndex == 0){
                                                    labelsList.push(pageResults[i].tables[j].cells[m].text);
                                                    if(labelsList.includes(pageResults[i].tables[j].cells[m].text)){
                                                    	headerLabelsList.push({
                                                            "columnIndex": pageResults[i].tables[j].cells[m].columnIndex,
                                                            "tableId": pageResults[i].tables[j].cells[m].tableId,
                                                            "headerLabel": pageResults[i].tables[j].cells[m].text
                                                    	});     
                                                    }else{
                                                    	headerLabelsList.push({
                                                            "columnIndex": pageResults[i].tables[j].cells[m].columnIndex,
                                                            "tableId": pageResults[i].tables[j].cells[m].tableId,
                                                            "headerLabel": pageResults[i].tables[j].cells[m].text
                                                        });    
                                                    }
                                                        
                                                }
                                                count++;
                                            }
                                            pageResults[i].tables[j].rowsList = rowsList;
                                            pageResults[i].tables[j].columnsList = columnsList;
                                            rowsList = [];
                                            columnsList = [];
                                        }
                                    }
                                }
                                var finalPageResults = pageResults;
                                for(var i=0;i<finalPageResults.length;i++){
                                    if(finalPageResults[i].tables != undefined){   
                                        for(var j=0;j<finalPageResults[i].tables.length;j++){
                                            for(var m=0;m<finalPageResults[i].tables[j].cells.length;m++){
                                                for(var n=0;n<headerLabelsList.length;n++){
                                                    if(finalPageResults[i].tables[j].cells[m].rowIndex !=0 && 
                                                       		finalPageResults[i].tables[j].cells[m].columnIndex == headerLabelsList[n].columnIndex
                                                      		&& finalPageResults[i].tables[j].cells[m].tableId == headerLabelsList[n].tableId){
                                                    	finalPageResults[i].tables[j].cells[m].headerLabel = headerLabelsList[n].headerLabel;    
                                                    }    
                                                }  
                                            }
                                        }
                                    }
                                }
                                console.log('pageResults -------> '+JSON.stringify(pageResults));
                                console.log('finalPageResults -------> '+JSON.stringify(finalPageResults));
                                component.set("v.pageResults", finalPageResults);
                                component.set("v.Spinner", false);
                                component.set("v.currentStep", '1');
                                helper.getTableData(component, event, helper);
                            } 
                        });
                        $A.enqueueAction(nextAction);
                    }), 30000
                );
            }  
        });  
        $A.enqueueAction(action); 	
	},
    moveBack : function(component, event, helper) {
    	var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == '2'){
            component.set("v.currentStep", '1');
            component.set("v.isNewMap", false);
            component.set("v.isExistingMap", false);
        }else if(getCurrentStep == '3'){
            component.set("v.currentStep", '1');
            component.set("v.showJSON", false);
            component.set("v.isNewMap", false);
            component.set("v.isExistingMap", false);
        }
    },
    finish : function(component,event,helper){ 
        component.set("v.showSavePopup", true); 
    },
    
    saveMapping : function(component,event,helper){ 
        component.set("v.Spinner", true);
        var fieldMappingName = component.get("v.FieldMappingName");
        var isNewMapping = component.get("v.isNewMap");
            var isExistingMapping = component.get("v.isExistingMap");
        if(fieldMappingName != undefined){
            if(isNewMapping == true){
                helper.saveNewFieldMapping(component,event,helper,fieldMappingName);    
            }
            if(isExistingMapping == true){
                helper.saveExistingFieldMapping(component,event,helper,fieldMappingName);     
            }
        }
    },
    
    showNewMap : function(component,event,helper){
    	component.set("v.isNewMap", true);
        component.set("v.isExistingMap", false);
        component.set("v.currentStep", '2');
        component.set("v.isFinalStep", true);
    },
    showExistingMap : function(component,event,helper){
        /*var action = component.get("c.getFieldMappings");
        action.setParams({});
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.isExistingMap", true);
                component.set("v.isNewMap", false);
                component.set("v.currentStep", '3');
                component.set("v.showSubmit", true);
            	component.set("v.fieldMappingsList", response.getReturnValue());    
            }    
        });
        $A.enqueueAction(action);*/
    	helper.getFieldMapping(component,event,helper);
    },
    onSelectChange : function(component,event,helper){
        component.set("v.ShowTabs", true);
        var selectedFieldMapping = component.get("v.selectedFieldMapping");
        helper.getExistingFieldMapping(component,event,helper,selectedFieldMapping);
    },
    
    submit : function(component,event,helper){  
        component.set("v.Spinner", true);
        var pageResults = component.get("v.pageResults");
        console.log('pageResults -------> '+JSON.stringify(pageResults));
        var finalTableData = [];
        for(var i=0;i<pageResults.length;i++){
            if(pageResults[i].tables != undefined){
            	for(var j=0;j<pageResults[i].tables.length;j++){
                    pageResults[i].tables[j].tableId = j;
                	finalTableData.push(pageResults[i].tables[j]);
            	}    
            }   
        }
        console.log('finalTableData ------> '+JSON.stringify(finalTableData));
        var fieldsData = component.get("v.readResults");
        for(var k=0;k<fieldsData.length;k++){
            if(fieldsData[k].InvoiceDate != '' && fieldsData[k].InvoiceDate != undefined){
           		var d = new Date(fieldsData[k].InvoiceDate.text),
                    month = '' + (d.getMonth() + 1),
                    day = '' + d.getDate(),
                    year = d.getFullYear();
            
                if (month.length < 2){
                	month = '0' + month;    
                }  
                if (day.length < 2){
                	day = '0' + day;    
                }  
                fieldsData[k].InvoiceDate.text = [year, month, day].join('-');
            }
            if(fieldsData[k].DueDate != '' && fieldsData[k].DueDate != undefined){
            	var d = new Date(fieldsData[k].DueDate.text),
                    month = '' + (d.getMonth() + 1),
                    day = '' + d.getDate(),
                    year = d.getFullYear();
            
                if (month.length < 2){
                	month = '0' + month;    
                }  
                if (day.length < 2){
                	day = '0' + day;    
                }  
                fieldsData[k].DueDate.text = [year, month, day].join('-');    
            }
            if(fieldsData[k].ServiceStartDate != '' && fieldsData[k].ServiceStartDate != undefined){
            	var d = new Date(fieldsData[k].ServiceStartDate.text),
                    month = '' + (d.getMonth() + 1),
                    day = '' + d.getDate(),
                    year = d.getFullYear();
            
                if (month.length < 2){
                	month = '0' + month;    
                }  
                if (day.length < 2){
                	day = '0' + day;    
                }  
                fieldsData[k].ServiceStartDate.text = [year, month, day].join('-');     
            }
            if(fieldsData[k].ServiceEndDate != '' && fieldsData[k].ServiceEndDate != undefined){
            	var d = new Date(fieldsData[k].ServiceEndDate.text),
                    month = '' + (d.getMonth() + 1),
                    day = '' + d.getDate(),
                    year = d.getFullYear();
            
                if (month.length < 2){
                	month = '0' + month;    
                }  
                if (day.length < 2){
                	day = '0' + day;    
                }  
                fieldsData[k].ServiceEndDate.text = [year, month, day].join('-');     
            }
        }
        var fieldMappingId = component.get("v.selectedFieldMapping");
        console.log('fieldMappingId ------> '+fieldMappingId);
        var action = component.get("c.createRecord");
        action.setParams({
            tableData : JSON.stringify(finalTableData),
            fieldsData : JSON.stringify(fieldsData),
            fieldMappingId : fieldMappingId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                if(response.getReturnValue() != undefined){
                    var result = response.getReturnValue();
                    var invoiceId = result.invoiceId;
                    var invoiceLines = JSON.parse(result.invoiceLineJson);
                    console.log('result -------> '+JSON.stringify(invoiceLines));
                    var invoiceLinesList = [];
                    for(var i=0;i<invoiceLines.length;i++){
                        if(invoiceLines[i].buildertek__product__c != null && invoiceLines[i].buildertek__product__c != undefined){
                        	invoiceLinesList.push(invoiceLines[i]);	    
                        }    
                    }
                    console.log('invoiceLinesList -------> '+JSON.stringify(invoiceLinesList));
                    helper.saveInvoiceLines(component,event,helper,invoiceLinesList,invoiceId);
                }
                
            }    
        });
        $A.enqueueAction(action);
    },   
    
    changeFieldValue : function(component,event,helper){ 
        var fieldsData = component.get("v.fieldsData");
        console.log('fieldsData -------> '+JSON.stringify(fieldsData));
    },
    
    viewJSON : function(component,event,helper){ 
        component.set("v.showJSON", true);
        component.set("v.isNewMap", false);
        component.set("v.isExistingMap", false);
        component.set("v.currentStep", '3');
        //var container = component.find("container").getElement();
        //alert('container ------> '+container);
    }
})