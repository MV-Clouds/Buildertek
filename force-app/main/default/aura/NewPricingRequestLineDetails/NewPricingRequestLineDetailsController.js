({
    doInit : function(component, event, helper) {
        component.set("v.openProductBox",true);
        component.set('v.columns1', [
            {label: 'Product Name', fieldName: 'Name', type: 'text',sortable: true},
            {label: 'Product Code', fieldName: 'ProductCode', type: 'text'},
            {label: 'List Price', fieldName: 'UnitPrice', type: 'currency',typeAttributes: {currencyCode: { fieldName: 'CurrencyIsoCode' }},cellAttributes: { alignment: 'left' }},
            {label: 'Product Description', fieldName: 'Description', type: 'text'},
            {label: 'Product Family', fieldName: 'Family', type: 'text'}
        ]);
        component.set("v.Spinner",true);
        var  action = component.get("c.getproductsOne");
        action.setParams({
            "recordId": component.get("v.recordId")
        }); 
        
        action.setCallback(this,function(response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result =  response.getReturnValue();
                console.log("Result")
                console.log(result)
                component.set("v.data1",result.productList)
                component.set("v.pricebookName",result.PriceBookIdForProduct);
                component.set("v.filteredData",result.productList)
                helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
                //----------------------------------------------------
                 var actions = component.get("c.getpricebooks");
                var opts = [];
                actions.setCallback(this, function(response) {
                    if (response.getState() == "SUCCESS") {
                        var result  = response.getReturnValue();
                        var opts = [];
                        opts.push({key: "None", value: "" });
                        for(var key in result){
                            opts.push({key: key, value: result[key]});
                        }
                        component.set("v.pricebookoptions", opts);
                         component.set("v.Spinner",false);
                    }
                   else if (response.getState() === "INCOMPLETE") {
                
            }
                else if (response.getState() === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            
            
            
        });
        $A.enqueueAction(actions); 
                
            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            
            
            
        });
        $A.enqueueAction(action); 
    },
    
    
    closeBox : function(component, event, helper) {
        component.set("v.openProductBox",false);
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    
    searchTable : function(component,event,helper) {
        var allRecords = component.get("v.filteredData");
        var searchFilter = event.getSource().get("v.value").toUpperCase()
        var tempArray = [];
        var i;
        debugger;
        for(i=0; i < allRecords.length; i++){
            if((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1))
            {
                tempArray.push(allRecords[i]);
            }
        }
        debugger;
        component.set("v.data1",tempArray);
        helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
    },
    
    changeEvent1 :  function (component, event, helper) {
        debugger
        component.set("v.data1",'');
        var x = component.find("getPriceBookId").get("v.value");
        if(x){
            component.set("v.storePriceBookId",x);
        }
        if(x == ''){
            x = 'None';
            
        }
        var action = component.get("c.getProductsthroughPriceBook");
        action.setParams({
            "pbookId": x
        }); 
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var rows = response.getReturnValue();
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    row.UnitPrice = row.buildertek__Available_Quantity__c;
                }
                component.set("v.data1",rows);
                component.set("v.filteredData",rows);
                helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
                var selectedRows = [];
                var listIds = component.get("v.listOfSelectedIds");
                for(var i=0;i< listIds.length;i++){
                    selectedRows.push(listIds[i])
                }
                component.set("v.selectedRows",selectedRows)
            }     
        });
        $A.enqueueAction(action); 
    },
    
    updateSelectedText : function (component, event, helper) { 
        var selectedRows = event.getParam('selectedRows');
        component.set("v.StoreIdsOfDatatable",component.get("v.listOfSelectedIds"));
        var y =[];
        var selectedRowList =component.get("v.listOfSelectedIds") 
        var NewselectedRows = [];
        for (var i = 0; i < selectedRows.length; i++){
            if(selectedRowList.indexOf(selectedRows[i].Id) < 0){
                selectedRowList.push(selectedRows[i].Id)
            } 
            else{ 
            }
            NewselectedRows.push(selectedRows[i].Id); 
        }    
        component.set("v.listOfSelectedIds",selectedRowList)   
        component.set("v.selectedRows",NewselectedRows);
    },
    
    openQuoteLine :  function (component, event, helper) {
        var listid = component.get("v.listOfSelectedIds");
        if(listid.length > 0 && listid != undefined){  
            component.set("v.openProductBox",false);
            component.set("v.openQuoteLineBox",true);
            var action6 = component.get("c.getProductRecordsByIds");
            action6.setParams({
                "Ids": listid
            });
            action6.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){
                    var listProduct = response.getReturnValue();
                    var xyz = [];
                    var Quotelist = component.get("v.QuoteLineList");
                    for (var i = 0; i < listProduct.length; i++) {
                        var row1 = listProduct[i];
                        if(row1.PricebookEntries != undefined){
                            var m;
                            var num;
                            if(component.get("v.storePriceBookId")){
                                for(var k=0;k<row1.PricebookEntries.length;k++){
                                    console.log(component.get("v.storePriceBookId"))
                                    console.log(row1.PricebookEntries[k].Pricebook2.Id)
                                    if(row1.PricebookEntries[k].Pricebook2.Id == component.get("v.storePriceBookId")){
                                        m = row1.PricebookEntries[k].Pricebook2.Name;
                                        console.log(m)
                                        num = k;
                                    }
                                    else{
                                        m = row1.PricebookEntries[0].Pricebook2.Name;
                                        num = 0;
                                    }
                                }
                            }
                            else{
                                m = row1.PricebookEntries[0].Pricebook2.Name;
                                num = 0;
                            }
                            xyz.push({
                                'buildertek__Product__c':row1.Name,
                                'Name':row1.Name,
                                'buildertek__Unit_Price__c':row1.PricebookEntries[num].buildertek__Unit_Cost__c ? row1.PricebookEntries[num].buildertek__Unit_Cost__c : row1.PricebookEntries[num].UnitPrice,
                                'buildertek__Description__c':row1.Name,
                                'buildertek__Cost__c':'',
                                'buildertek__Markup__c':(row1.PricebookEntries[num].buildertek__Markup__c == undefined) ? '0' : row1.PricebookEntries[num].buildertek__Markup__c,
                                'buildertek__Product__c':row1.Id,
                                'buildertek__Size__c':m,                //row1.PricebookEntries[0].Pricebook2.Name,
                                'buildertek__Vendor__c':'',
                                'buildertek__Quantity__c':'1',
                                'buildertek__Multiplier__c':row1.PricebookEntries[num].buildertek__Multiplier__c ?  row1.PricebookEntries[num].buildertek__Multiplier__c : '0'
                            })
                        }
                        else if(row1.PricebookEntries != undefined){
                            var m;
                            var num;
                            if(component.get("v.storePriceBookId")){
                                for(var k=0;k<row1.PricebookEntries.length;k++){
                                    if(row1.PricebookEntries[k].Pricebook2.Id == component.get("v.storePriceBookId")){
                                        m = row1.PricebookEntries[k].Pricebook2.Name;
                                        num = k;
                                    }
                                    else{
                                        m = row1.PricebookEntries[0].Pricebook2.Name;
                                        num = 0;
                                    }
                                }
                            }
                            else{
                                m = row1.PricebookEntries[0].Pricebook2.Name;
                                num = 0;
                            }
                            debugger;
                            xyz.push({
                                'buildertek__Product__c':row1.Name,
                                'Name':row1.Name,
                                'buildertek__Unit_Price__c':row1.PricebookEntries[num].buildertek__Unit_Cost__c ? row1.PricebookEntries[num].buildertek__Unit_Cost__c : row1.PricebookEntries[num].UnitPrice,
                                'buildertek__Unit_Price__c':'0',
                                'buildertek__Description__c':row1.Name,
                                'buildertek__Cost__c':'',
                                'buildertek__Markup__c':(row1.PricebookEntries[num].buildertek__Markup__c == undefined) ? '0' : row1.PricebookEntries[num].buildertek__Markup__c,
                                'buildertek__Product__c':row1.Id,
                                'buildertek__Size__c':m,  // row1.PricebookEntries[0].Pricebook2.Name,
                                'buildertek__Vendor__c':'',
                                'buildertek__Quantity__c':'1',
                                'buildertek__Multiplier__c':row1.PricebookEntries[num].buildertek__Multiplier__c ? row1.PricebookEntries[num].buildertek__Multiplier__c : '0'
                            })
                        }
                            else{
                                xyz.push({
                                    'buildertek__Product__c':row1.Name,
                                    'Name':row1.Name,
                                    'buildertek__Unit_Price__c':'0',
                                    'buildertek__Unit_Price__c':'0',
                                    'buildertek__Description__c':row1.Name,
                                    'buildertek__Cost__c':'',
                                    'buildertek__Markup__c':'0',
                                    'buildertek__Product__c':row1.Id,
                                    'buildertek__Size__c':'',
                                    'buildertek__Vendor__c':'',
                                    'buildertek__Quantity__c':'1',
                                    'buildertek__Multiplier__c': '0'
                                })
                            }
                    }
                    component.set("v.data2",xyz);
                    var action11 = component.get("c.getQuoteGrouping2");
                    action11.setParams({
                        "quoteId": component.get("v.recordId")
                    }); 
                    action11.setCallback(this,function(response){
                        if(response.getState() == "SUCCESS"){
                            component.set("v.quotelineRecords",response.getReturnValue());
                        }
                    });
                    $A.enqueueAction(action11);
                }
            });
            $A.enqueueAction(action6);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please select at least one product.',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }    
    }, 
    
    addQuoteLine : function (component, event, helper) {
        component.set("v.isDisabled",true);
        var listQlines = component.get("v.data2");
        var y = []
        if(listQlines != undefined){
            for(var i=0;i<listQlines.length;i++)
                if(listQlines[i].buildertek__Description__c != undefined){
                    if(listQlines[i].buildertek__Description__c.trim() != ""){
                        //   listQlines[i].buildertek__Vendor__c =  listQlines[i].buildertek__Vendor__c.Id
                        /*   if( listQlines[i].buildertek__Markup__c != undefined &&  listQlines[i].buildertek__Markup__c != null &&  listQlines[i].buildertek__Markup__c != '' && listQlines[i].buildertek__Markup__c != ' ' && listQlines[i].buildertek__Markup__c != 0 && listQlines[i].buildertek__Markup__c != '0'){
                   //      listQlines[i].buildertek__Cost__c =   listQlines[i].buildertek__Quantity__c*(listQlines[i].buildertek__Unit_Price__c +  listQlines[i].buildertek__Unit_Price__c*(listQlines[i].buildertek__Markup__c)/100)
                                                  if( listQlines[i].buildertek__Multiplier__c != undefined &&  listQlines[i].buildertek__Multiplier__c != null &&  listQlines[i].buildertek__Multiplier__c != '' && listQlines[i].buildertek__Multiplier__c != ' ' && listQlines[i].buildertek__Multiplier__c != 0 && listQlines[i].buildertek__Multiplier__c != '0'){
                                                      
                                                        listQlines[i].buildertek__Cost__c =   listQlines[i].buildertek__Quantity__c*(listQlines[i].buildertek__Unit_Price__c * listQlines[i].buildertek__Markup__c)*( listQlines[i].buildertek__Multiplier__c);
                                                  }
                            else{

                        listQlines[i].buildertek__Cost__c =   listQlines[i].buildertek__Quantity__c*(listQlines[i].buildertek__Unit_Price__c * listQlines[i].buildertek__Markup__c);

                        }
                        }
                        else{
                               if( listQlines[i].buildertek__Multiplier__c != undefined &&  listQlines[i].buildertek__Multiplier__c != null &&  listQlines[i].buildertek__Multiplier__c != '' && listQlines[i].buildertek__Multiplier__c != ' ' && listQlines[i].buildertek__Multiplier__c != 0 && listQlines[i].buildertek__Multiplier__c != '0'){

                             listQlines[i].buildertek__Cost__c =  listQlines[i].buildertek__Unit_Price__c* listQlines[i].buildertek__Quantity__c* listQlines[i].buildertek__Multiplier__c;
                               }
                            else{
                                  listQlines[i].buildertek__Cost__c =  listQlines[i].buildertek__Unit_Price__c* listQlines[i].buildertek__Quantity__c;
                            }
                        } */
                        listQlines[i].buildertek__Cost__c =  listQlines[i].buildertek__Unit_Price__c;
                        y.push(listQlines[i]);
                    }
                }
        }
        
        
        if(listQlines.length == y.length){
            var action = component.get("c.insertRec");
            action.setParams({
                "recId": component.get("v.recordId"),
                "PRLDetails":listQlines
            }); 
            action.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){
                    component.set("v.openQuoteLineBox",false);
                    $A.get("e.force:refreshView").fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Pricing Request Line Detail(s) created successfully.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                else{
                    component.set("v.isDisabled",false);;
                }
            });
            $A.enqueueAction(action);
        }   
        else{
            component.set("v.isDisabled",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please fill the required fields.',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }         
    },
    
    cancelBox :  function (component, event, helper) { 
        component.set("v.openQuoteLineBox",false);
        component.set("v.openProductBox",true);
    },
    
    
    changeSalesPrice1 : function(component, event, helper) {
        debugger;
        var recIndex = Number(event.getSource().get("v.name"));
        var recordList = component.get("v.data2");
        if(recordList.length > 0){
            
            
            
            if(recordList[recIndex]["buildertek__Unit_Price__c"] == null){
                recordList[recIndex]["buildertek__Unit_Price__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Unit_Price__c"] = Number(recordList[recIndex]["buildertek__Unit_Price__c"])   
            }
            if(recordList[recIndex]["buildertek__Quantity__c"] == null){
                recordList[recIndex]["buildertek__Quantity__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Quantity__c"] = Number(recordList[recIndex]["buildertek__Quantity__c"])   
            }
            
            if(recordList[recIndex]["buildertek__Markup__c"] == null || recordList[recIndex]["buildertek__Markup__c"] == ""){
                recordList[recIndex]["buildertek__Markup__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Markup__c"] = Number(recordList[recIndex]["buildertek__Markup__c"])   
            }
            
            if(recordList[recIndex]["buildertek__Multiplier__c"] == null || recordList[recIndex]["buildertek__Multiplier__c"] == ""){
                recordList[recIndex]["buildertek__Multiplier__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Multiplier__c"] = Number(recordList[recIndex]["buildertek__Multiplier__c"])   
            }
            
            recordList[recIndex]["buildertek__Unit_Price__c"] = Number(event.getSource().get("v.value"));
            
            
            
        }
        component.set("v.data2",recordList); 
    },
    
    changeSalesPrice2 : function(component, event, helper) {
        debugger;
        var recIndex = Number(event.getSource().get("v.name"));
        var recordList = component.get("v.data2");
        if(recordList.length > 0){
            
            if(recordList[recIndex]["buildertek__Unit_Price__c"] == null){
                recordList[recIndex]["buildertek__Unit_Price__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Unit_Price__c"] = Number(recordList[recIndex]["buildertek__Unit_Price__c"])   
            }
            if(recordList[recIndex]["buildertek__Quantity__c"] == null){
                recordList[recIndex]["buildertek__Quantity__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Quantity__c"] = Number(recordList[recIndex]["buildertek__Quantity__c"])   
            }
            
            if(recordList[recIndex]["buildertek__Markup__c"] == null || recordList[recIndex]["buildertek__Markup__c"] == ""){
                recordList[recIndex]["buildertek__Markup__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Markup__c"] = Number(recordList[recIndex]["buildertek__Markup__c"])   
            }
            
            if(recordList[recIndex]["buildertek__Multiplier__c"] == null || recordList[recIndex]["buildertek__Multiplier__c"] == ""){
                recordList[recIndex]["buildertek__Multiplier__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Multiplier__c"] = Number(recordList[recIndex]["buildertek__Multiplier__c"])   
            }
            
            recordList[recIndex]["buildertek__Quantity__c"] = Number(event.getSource().get("v.value"));
        }
        component.set("v.data2",recordList); 
    },
    
    changeSalesPrice3 : function(component, event, helper) {
        debugger;
        var recIndex = Number(event.getSource().get("v.name"));
        var recordList = component.get("v.data2");
        if(recordList.length > 0){
            
            if(recordList[recIndex]["buildertek__Unit_Price__c"] == null){
                recordList[recIndex]["buildertek__Unit_Price__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Unit_Price__c"] = Number(recordList[recIndex]["buildertek__Unit_Price__c"])   
            }
            if(recordList[recIndex]["buildertek__Quantity__c"] == null){
                recordList[recIndex]["buildertek__Quantity__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Quantity__c"] = Number(recordList[recIndex]["buildertek__Quantity__c"])   
            }
            
            if(recordList[recIndex]["buildertek__Markup__c"] == null || recordList[recIndex]["buildertek__Markup__c"] == ""){
                recordList[recIndex]["buildertek__Markup__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Markup__c"] = Number(recordList[recIndex]["buildertek__Markup__c"])   
            }
            
            if(recordList[recIndex]["buildertek__Multiplier__c"] == null || recordList[recIndex]["buildertek__Multiplier__c"] == ""){
                recordList[recIndex]["buildertek__Multiplier__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Multiplier__c"] = Number(recordList[recIndex]["buildertek__Multiplier__c"])   
            }
            
            recordList[recIndex]["buildertek__Markup__c"] = Number(event.getSource().get("v.value"));
        }
        component.set("v.data2",recordList); 
    },
    
    changeSalesPrice4 : function(component, event, helper) {
        debugger;
        var recIndex = Number(event.getSource().get("v.name"));
        var recordList = component.get("v.data2");
        if(recordList.length > 0){
            
            if(recordList[recIndex]["buildertek__Unit_Price__c"] == null){
                recordList[recIndex]["buildertek__Unit_Price__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Unit_Price__c"] = Number(recordList[recIndex]["buildertek__Unit_Price__c"])   
            }
            if(recordList[recIndex]["buildertek__Quantity__c"] == null){
                recordList[recIndex]["buildertek__Quantity__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Quantity__c"] = Number(recordList[recIndex]["buildertek__Quantity__c"])   
            }
            
            if(recordList[recIndex]["buildertek__Markup__c"] == null || recordList[recIndex]["buildertek__Markup__c"] == ""){
                recordList[recIndex]["buildertek__Markup__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Markup__c"] = Number(recordList[recIndex]["buildertek__Markup__c"])   
            }
            
            if(recordList[recIndex]["buildertek__Multiplier__c"] == null || recordList[recIndex]["buildertek__Multiplier__c"] == ""){
                recordList[recIndex]["buildertek__Multiplier__c"] = 0; 
            }else{
                recordList[recIndex]["buildertek__Multiplier__c"] = Number(recordList[recIndex]["buildertek__Multiplier__c"])   
            }
            
            recordList[recIndex]["buildertek__Multiplier__c"] = Number(event.getSource().get("v.value"));
        }
        component.set("v.data2",recordList); 
    },
    
})