({
    getTableData : function(component, event, helper){
    	var pageResults = component.get("v.pageResults");
        var tableData = [];
        console.log('pageResults length ------> '+pageResults.length);
        var readResults = component.get("v.readResults");
        var parentFields = [];
        for(var a=0;a<readResults.length;a++){
            if(readResults[a].CustomerName != '' && readResults[a].CustomerName != undefined){
                parentFields.push({
                    "label" : 'CustomerName',
                    "value" : readResults[a].CustomerName.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].CustomerName.type
                });	    
            }
            if(readResults[a].CustomerId != '' && readResults[a].CustomerId != undefined){
            	parentFields.push({
                    "label" : 'CustomerId',
                    "value" : readResults[a].CustomerId.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].CustomerId.type
                });    
            }
            if(readResults[a].PurchaseOrder != '' && readResults[a].PurchaseOrder != undefined){
            	parentFields.push({
                    "label" : 'PurchaseOrder',
                    "value" : readResults[a].PurchaseOrder.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].PurchaseOrder.type
                });    
            }
            if(readResults[a].InvoiceId != '' && readResults[a].InvoiceId != undefined){
            	parentFields.push({
                    "label" : 'InvoiceId',
                    "value" : readResults[a].InvoiceId.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].InvoiceId.type
                });    
            }
            if(readResults[a].InvoiceDate != '' && readResults[a].InvoiceDate != undefined){
            	parentFields.push({
                    "label" : 'InvoiceDate',
                    "value" : readResults[a].InvoiceDate.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].InvoiceDate.type
                });    
            }
            if(readResults[a].DueDate != '' && readResults[a].DueDate != undefined){
            	parentFields.push({
                    "label" : 'DueDate',
                    "value" : readResults[a].DueDate.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].DueDate.type
                });    
            }
            if(readResults[a].VendorName != '' && readResults[a].VendorName != undefined){
            	parentFields.push({
                    "label" : 'VendorName',
                    "value" : readResults[a].VendorName.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].VendorName.type
                });    
            }
            if(readResults[a].VendorAdress != '' && readResults[a].VendorAdress != undefined){
            	parentFields.push({
                    "label" : 'VendorAdress',
                    "value" : readResults[a].VendorAdress.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].VendorAdress.type
                });    
            }
            if(readResults[a].VendorAddressRecipient != '' && readResults[a].VendorAddressRecipient != undefined){
            	parentFields.push({
                    "label" : 'VendorAddressRecipient',
                    "value" : readResults[a].VendorAddressRecipient.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].VendorAddressRecipient.type
                });    
            }
            if(readResults[a].CustomerAddress != '' && readResults[a].CustomerAddress != undefined){
            	parentFields.push({
                    "label" : 'CustomerAddress',
                    "value" : readResults[a].CustomerAddress.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].CustomerAddress.type
                });    
            }
            if(readResults[a].CustomerAddressRecipient != '' && readResults[a].CustomerAddressRecipient != undefined){
            	parentFields.push({
                    "label" : 'CustomerAddressRecipient',
                    "value" : readResults[a].CustomerAddressRecipient.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].CustomerAddressRecipient.type
                });    
            }
            if(readResults[a].BillingAddress != '' && readResults[a].BillingAddress != undefined){
            	parentFields.push({
                    "label" : 'BillingAddress',
                    "value" : readResults[a].BillingAddress.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].BillingAddress.type
                });    
            }
            if(readResults[a].BillingAddressRecipient != '' && readResults[a].BillingAddressRecipient != undefined){
            	parentFields.push({
                    "label" : 'BillingAddressRecipient',
                    "value" : readResults[a].BillingAddressRecipient.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].BillingAddressRecipient.type
                });    
            }
            if(readResults[a].ShippingAddress != '' && readResults[a].ShippingAddress != undefined){
            	parentFields.push({
                    "label" : 'ShippingAddress',
                    "value" : readResults[a].ShippingAddress.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].ShippingAddress.type
                });    
            }
            if(readResults[a].ShippingAddressRecipient != '' && readResults[a].ShippingAddressRecipient != undefined){
            	parentFields.push({
                    "label" : 'ShippingAddressRecipient',
                    "value" : readResults[a].ShippingAddressRecipient.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].ShippingAddressRecipient.type
                });    
            }
            if(readResults[a].SubTotal != '' && readResults[a].SubTotal != undefined){
            	parentFields.push({
                    "label" : 'SubTotal',
                    "value" : readResults[a].SubTotal.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].SubTotal.type
                });    
            }
            if(readResults[a].TotalTax != '' && readResults[a].TotalTax != undefined){
            	parentFields.push({
                    "label" : 'TotalTax',
                    "value" : readResults[a].TotalTax.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].TotalTax.type
                });    
            }
            if(readResults[a].InvoiceTotal != '' && readResults[a].InvoiceTotal != undefined){
            	parentFields.push({
                    "label" : 'InvoiceTotal',
                    "value" : readResults[a].InvoiceTotal.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].InvoiceTotal.type
                });    
            }
            if(readResults[a].PreviousUnpaidBalance != '' && readResults[a].PreviousUnpaidBalance != undefined){
            	parentFields.push({
                    "label" : 'PreviousUnpaidBalance',
                    "value" : readResults[a].PreviousUnpaidBalance.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].PreviousUnpaidBalance.type
                });    
            }
            if(readResults[a].AmountDue != '' && readResults[a].AmountDue != undefined){
            	parentFields.push({
                    "label" : 'AmountDue',
                    "value" : readResults[a].AmountDue.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].AmountDue.type
                });    
            }
            if(readResults[a].ServiceStartDate != '' && readResults[a].ServiceStartDate != undefined){
            	parentFields.push({
                    "label" : 'ServiceStartDate',
                    "value" : readResults[a].ServiceStartDate.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].ServiceStartDate.type
                });    
            }
            if(readResults[a].ServiceEndDate != '' && readResults[a].ServiceEndDate != undefined){
            	parentFields.push({
                    "label" : 'ServiceEndDate',
                    "value" : readResults[a].ServiceEndDate.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].ServiceEndDate.type
                });    
            }
            if(readResults[a].ServiceAddress != '' && readResults[a].ServiceAddress != undefined){
            	parentFields.push({
                    "label" : 'ServiceAddress',
                    "value" : readResults[a].ServiceAddress.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].ServiceAddress.type
                });    
            }
            if(readResults[a].ServiceAddressRecipient != '' && readResults[a].ServiceAddressRecipient != undefined){
            	parentFields.push({
                    "label" : 'ServiceAddressRecipient',
                    "value" : readResults[a].ServiceAddressRecipient.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].ServiceAddressRecipient.type
                });    
            }
            if(readResults[a].RemittanceAddress != '' && readResults[a].RemittanceAddress != undefined){
            	parentFields.push({
                    "label" : 'RemittanceAddress',
                    "value" : readResults[a].RemittanceAddress.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].RemittanceAddress.type
                });    
            }
            if(readResults[a].RemittanceAddressRecipient != '' && readResults[a].RemittanceAddressRecipient != undefined){
            	parentFields.push({
                    "label" : 'RemittanceAddressRecipient',
                    "value" : readResults[a].RemittanceAddressRecipient.text,
                    "mappingField" : '',
                    "fieldType": readResults[a].RemittanceAddressRecipient.type
                });    
            }
            
            
            component.set("v.fieldsData", parentFields);
        }
        var tableFields = [];
        var addedFields = [];
        for(var i=0;i<pageResults.length;i++){
            if(pageResults[i].tables != undefined){
            	for(var j=0;j<pageResults[i].tables.length;j++){
                    console.log('cells length ------> '+pageResults[i].tables[j].cells.length);
                    for(var k=0;k<pageResults[i].tables[j].cells.length;k++){
                        if(pageResults[i].tables[j].cells[k].rowIndex == 0){
                            if(pageResults[i].tables[j].cells[k].tableId == j){
                                tableData.push({
                                    "label" : pageResults[i].tables[j].cells[k].text,
                                    "value" : '',
                                    "rowIndex" : pageResults[i].tables[j].cells[k].rowIndex,
                                    "columnIndex" : pageResults[i].tables[j].cells[k].columnIndex,
                                    "mappingField" : '',
                                    "tableId": pageResults[i].tables[j].cells[k].tableId,
                                    "headerLabel": pageResults[i].tables[j].cells[k].headerLabel
                                }); 
                            	addedFields.push(pageResults[i].tables[j].cells[k].text);
                            }
                            
                        }else{
                            tableFields.push({
                            	"label" : '',
                                "value" : pageResults[i].tables[j].cells[k].text,
                                "rowIndex": pageResults[i].tables[j].cells[k].rowIndex,
                                "columnIndex": pageResults[i].tables[j].cells[k].columnIndex    
                            });    
                        }   
                    }    
                }        
            }
        }
        var finalTableFields = [];
        for(var i=0;i<tableData.length;i++){
            for(var j=0;j<tableFields.length;j++){
                if(tableData[i].rowIndex == tableFields[j].rowIndex && tableData[i].columnIndex == tableFields[j].columnIndex){
                    finalTableFields.push({
                        "label" : tableData[i].text,
                        "value" : tableFields[j].text
                    });   
                }    
            }    
        }
        component.set("v.tableData", tableData);
        helper.getAllFields(component, event, helper,'buildertek__Billings__c');
        helper.getAllFields(component, event, helper,'buildertek__Billable_Lines__c');    
    },
    getAllFields : function(component,event,helper,objectName){
        component.set("v.Spinner", true);
    	var action = component.get("c.getSobjectFields"); 
        action.setParams({
            "objectName" : objectName
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                
                if(objectName == 'buildertek__Billings__c'){
                	component.set("v.invoiceFields", result);
                    

                }else{
                	component.set("v.invoiceLineFields", result);    
                } 
                component.set("v.Spinner", false);
            }    
        });
        $A.enqueueAction(action);
    },
    getFieldMapping : function(component,event,helper){
        component.set("v.Spinner", true);
        var action = component.get("c.getAllFieldMappings");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.length > 1){
                    component.set("v.currentStep", '2');
                    component.set("v.isExistingMap", true);
                	component.set("v.fieldMappingsList", result);                    
                }else if(result.length == 1){
                    //component.set("v.isFinalStep", true);
                    component.set("v.selectedFieldMapping", result[0].Id);
                    component.set("v.FieldMappingName", result[0].Name);
                    //component.set("v.isExistingMap", true);
                    component.set("v.fieldMappingsList", result);
                    helper.getExistingFieldMapping(component,event,helper,result[0].Id);
                } 
                component.set("v.Spinner", false);
            }    
        });
        $A.enqueueAction(action);
    },
    getExistingFieldMapping : function(component,event,helper,selectedFieldMapping){
        component.set("v.Spinner", true);
        var action = component.get("c.getExistingMapping");
        action.setParams({
            "fieldMappigId" : selectedFieldMapping
        });
        action.setCallback(this, function(response){
        	if(response.getState() === "SUCCESS"){
            	var result = response.getReturnValue();
                component.set("v.currentStep", '2');
                component.set("v.isExistingMap", true);
                component.set("v.isFinalStep", true);
                component.set("v.FieldMappingName", result.fieldMappingName);
                component.set("v.existingFieldsData", result.ParentFieldsMapping);
                component.set("v.existingTableData", result.ChildFieldsMapping);
                component.set("v.Spinner", false);
                 if(document.getElementsByClassName('pdfContainer')[0]){
                    if( result.ParentFieldsMapping.length>13)
                        document.getElementsByClassName('pdfContainer')[0].style.height = '100%';
                    else
                        document.getElementsByClassName('pdfContainer')[0].style.height = '100vh'; 
                }
            }    
        });
        $A.enqueueAction(action);
    },
    saveNewFieldMapping : function(component,event,helper,fieldMappingName){
        component.set("v.Spinner", true);
        var tableData = component.get("v.tableData");
        console.log('tableData -------> '+JSON.stringify(tableData));
        var fieldsData = component.get("v.fieldsData");
        console.log('fieldsData -------> '+JSON.stringify(fieldsData));
        var action = component.get("c.createFieldMapping");
        action.setParams({
            parentFields : JSON.stringify(fieldsData),
            childFields : JSON.stringify(tableData),
            fieldMappingName : fieldMappingName
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set("v.Spinner", false);
                component.set("v.showSavePopup", false);
                component.set("v.selectedFieldMapping", response.getReturnValue());
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Field Mapping created successfully",
                    "type": "success"
                });
                toastEvent.fire();    
                component.set("v.showSubmit", true);
                component.set("v.Spinner", false);
            }       
        });
        $A.enqueueAction(action);
    },
    
    saveExistingFieldMapping : function(component,event,helper,fieldMappingName){
        var fieldMappingId = component.get("v.selectedFieldMapping");
        var existingParentMapping = component.get("v.existingFieldsData");
        var existingChildMapping = component.get("v.existingTableData");
        var action = component.get("c.updateFieldMapping");
        action.setParams({
            "fieldMappingId" : fieldMappingId,
            "fieldMappingName" : fieldMappingName,
            "parentFields" : existingParentMapping,
            "childFields" : existingChildMapping
        });
        action.setCallback(this, function(response){
            component.set("v.showSavePopup", false);
        	var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Field Mapping updated successfully",
                "type": "success"
            });
            toastEvent.fire();    
            component.set("v.showSubmit", true);
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },
    
    saveInvoiceLines : function(component,event,helper,invoiceLinesString,invoiceId){
        console.log('invoiceLinesString --------> '+invoiceLinesString);
        console.log('invoiceId --------> '+invoiceId);
        component.set("v.Spinner", true);
        var invoiceLines = JSON.stringify(invoiceLinesString)
    	var action = component.get("c.createIncoiceLineItems");  
        action.setParams({
            "invoiceId" : invoiceId,
            "invoiceLinesString" : invoiceLines
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Invoice created successfully",
                    "type": "success"
                });
                toastEvent.fire(); 
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                component.set("v.Spinner", false);
               
            }   
        });
        $A.enqueueAction(action);
    },
})