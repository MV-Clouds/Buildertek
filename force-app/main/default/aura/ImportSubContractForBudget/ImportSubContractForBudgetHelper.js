({
    getFields: function (component, event, helper) {
        debugger;
        var action = component.get("c.getJSONFieldSet");
        action.setParams({
            "sObjectName":"buildertek__Contract__c",
            "sFieldSetName":"buildertek__BudgetRelatedFieldset"
        })
        action.setCallback(this, function(response) {            
            if(response.getState()=="SUCCESS"){
                var fieldSetObj = JSON.parse(response.getReturnValue());  
                component.set("v.fieldSetValues", fieldSetObj);
                console.log('get fieldset=>'+JSON.stringify(fieldSetObj));
                
                /*-------------------------*/
                var y = []
                if(fieldSetObj != undefined){
                    for(let i=0;i<fieldSetObj.length;i++){
                        y.push(fieldSetObj[i].name)
                    }
                }
                y.unshift("Id")
                /*  if(y != undefined){
                for(let i=0;i<y.length;i++){
                    if(y[i] == "buildertek__Vendor__c"){
                        y[i] = "buildertek__Vendor__r.Name";
                    }
                }
                } */
                //  y.replace("buildertek__Vendor__c","buildertek__Vendor__r.Name");
                console.log("Labels : "+JSON.stringify(y));
                component.set("v.LabelList",y)
                var xyz = [];
                var abcd = {};
                var bud = 'budgetRecord';
                var labels = component.get("v.LabelList");
                if(labels){
                    for(let i=0;i<labels.length;i++){
                        abcd[labels[i]] = '';
                    }
                }
                //  alert(abcd);
                console.log(JSON.stringify(abcd))
                var h;
                var records = component.get("v.PaginationList");
                
                debugger;
                if(records){
                    for(let i=0;i<records.length;i++){
                        //   alert("ok")
                        abcd = {};
                        for(let j=0;j<y.length;j++){
                            //   alert(records[i].budgetRecord.buildertek__Vendor__r.Name)
                            if(y[j] == "buildertek__Vendor__c" && records[i].budgetRecord.buildertek__Vendor__r != undefined){
                                abcd[y[j]] = records[i].budgetRecord.buildertek__Vendor__r.Name != undefined ? records[i].budgetRecord.buildertek__Vendor__r.Name : null;
                                /*  if(records[i].budgetRecord.buildertek__Vendor__r.Name != undefined)
                                    abcd['VendorId'] = records[i].budgetRecord.buildertek__Vendor__r.Id; */
                            }
                            else if(y[j] == "buildertek__Cost_Code__c" && records[i].budgetRecord.buildertek__Cost_Code__r != undefined){
                                abcd[y[j]] = records[i].budgetRecord.buildertek__Cost_Code__r.Name != undefined ? records[i].budgetRecord.buildertek__Cost_Code__r.Name : null;
                                
                            }
                                else if(y[j] == "buildertek__Community__c" && records[i].budgetRecord.buildertek__Community__r != undefined){
                                    abcd[y[j]] = records[i].budgetRecord.buildertek__Community__r.Name != undefined ? records[i].budgetRecord.buildertek__Community__r.Name : null;
                                    
                                }
                                    else if(y[j] == "buildertek__Accounting_Year__c" && records[i].budgetRecord.buildertek__Accounting_Year__r != undefined){
                                        abcd[y[j]] = records[i].budgetRecord.buildertek__Accounting_Year__r.Name != undefined ? records[i].budgetRecord.buildertek__Accounting_Year__r.Name : null;
                                        
                                    }
                                        else if(y[j] == "buildertek__Budget__c" && records[i].budgetRecord.buildertek__Budget__r != undefined){
                                            abcd[y[j]] = records[i].budgetRecord.buildertek__Budget__r.Name != undefined ? records[i].budgetRecord.buildertek__Budget__r.Name : null;
                                            
                                        }
                                            else if(y[j] == "buildertek__BT_Quote__c" && records[i].budgetRecord.buildertek__BT_Quote__r != undefined){
                                                abcd[y[j]] = records[i].budgetRecord.buildertek__BT_Quote__r.Name != undefined ? records[i].budgetRecord.buildertek__BT_Quote__r.Name : null;
                                                
                                            }
                                                else if(y[j] == "buildertek__Project__c" && records[i].budgetRecord.buildertek__Project__r != undefined){
                                                    abcd[y[j]] = records[i].budgetRecord.buildertek__Project__r.Name != undefined ? records[i].budgetRecord.buildertek__Project__r.Name : null;
                                                    
                                                }
                                                    else if(y[j] == "buildertek__Primary_Contact__c" && records[i].budgetRecord.buildertek__Primary_Contact__r != undefined){
                                                        abcd[y[j]] = records[i].budgetRecord.buildertek__Primary_Contact__r.Name != undefined ? records[i].budgetRecord.buildertek__Primary_Contact__r.Name : null;
                                                        
                                                    }
                                                        else if(y[j] == "buildertek__Phase__c" && records[i].budgetRecord.buildertek__Phase__r != undefined){
                                                            abcd[y[j]] = records[i].budgetRecord.buildertek__Phase__r.Name != undefined ? records[i].budgetRecord.buildertek__Phase__r.Name : null;
                                                            
                                                        }
                                                            else if(y[j] == "buildertek__Email_Template__c" && records[i].budgetRecord.buildertek__Email_Template__r != undefined){
                                                                abcd[y[j]] = records[i].budgetRecord.buildertek__Email_Template__r.Name != undefined ? records[i].budgetRecord.buildertek__Email_Template__r.Name : null;
                                                                
                                                            }
                                                                else if(y[j] == "buildertek__Doc_Template__c" && records[i].budgetRecord.buildertek__Doc_Template__r != undefined){
                                                                    abcd[y[j]] = records[i].budgetRecord.buildertek__Doc_Template__r.Name != undefined ? records[i].budgetRecord.buildertek__Doc_Template__r.Name : null;
                                                                    
                                                                }
                                                                    else if(y[j] == "buildertek__Contract_File__c" && records[i].budgetRecord.buildertek__Contract_File__r != undefined){
                                                                        abcd[y[j]] = records[i].budgetRecord.buildertek__Contract_File__r.Name != undefined ? records[i].budgetRecord.buildertek__Contract_File__r.Name : null;
                                                                        
                                                                    }
                                                                        else if(y[j] == "buildertek__Change_Order__c" && records[i].budgetRecord.buildertek__Change_Order__r != undefined){
                                                                            abcd[y[j]] = records[i].budgetRecord.buildertek__Change_Order__r.Name != undefined ? records[i].budgetRecord.buildertek__Change_Order__r.Name : null;
                                                                            
                                                                        }
                                                                            else{
                                                                                abcd[y[j]] = records[i].budgetRecord[y[j]] != undefined ? records[i].budgetRecord[y[j]] : null;
                                                                                
                                                                            }
                            console.log(xyz[j])
                        }
                        xyz.push(abcd);
                        console.log(i)
                        console.log(xyz)
                        
                    }
                }
                debugger;
                console.log("Final Records : "+JSON.stringify(xyz))
                component.set("v.newRecordList",xyz)
            }
            else{
                console.log(response.getError());
            }
        })
        $A.enqueueAction(action); 
        
        
        
        
        
        
        
        
        
        /*var action = component.get("c.getJSONFieldSet");
		action.setParams({
			objectName: 'buildertek__Contract__c',
			fieldSetName: 'buildertek__BudgetRelatedFieldset'
		});
		action.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				var listOfFields = JSON.parse(response.getReturnValue());
				component.set("v.fieldSetValues", listOfFields);
			} else {
				console.log('Error');
			}
		});
		$A.enqueueAction(action);*/
    }
})