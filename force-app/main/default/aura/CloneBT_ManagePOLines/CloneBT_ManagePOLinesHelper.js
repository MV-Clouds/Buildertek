({
    setColumns: function(component) {
        component.set("v.columns",[
            {
                label : 'Name',
                fieldName: 'linkName', 
                type: 'url',
                typeAttributes: { 
                    label: { fieldName: 'Name' }, 
                    target: '_blank', 
                    tooltip: { fieldName: 'Name' } 
                },                
                sortable : true
            },
            {
                label : 'Vendor',
                fieldName : 'VendorName',
                //fieldName : 'buildertek__Vendor__r.Name',
                type : 'text',
                sortable : true
            },
            /* {
                label : 'Product',
                //buildertek__Product__c
                fieldName : 'ProductName',
                type : 'text',
                sortable : true
            },
            {
                label: 'Build Phase',
                //buildertek__Build_Phase__c
                fieldName : 'BuildPhase',
                type: 'text',
                sortable : true
            },
            {
                label : 'Trade Type',
                //buildertek__Trade_Type__c
                fieldName : 'Tradetype',
                type : 'text',
                sortable : true
            },*/
            {
                
                label : 'Category',
                //buildertek__Category__c
                fieldName : 'CategoryName',
                type : 'text',
                sortable : true
            },
            //buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name
            {
                
                label : 'Purchase order',
                //buildertek__Category__c
                fieldName : 'PurchaseOrder',
                type : 'text',
                sortable : true
            },
            {
                label : 'Product Type',
                //buildertek__Product_Type__c
                fieldName : 'ProductType',
                type : 'text',
                sortable : true
            },
            {
                label : 'Location',
                fieldName : 'buildertek__Location_Picklist__c',
                type : 'Picklist',
                sortable : true
            },
            {
                label : 'Standard',
                fieldName : 'buildertek__Standard__c',
                type : 'Picklist',
                sortable : true
            },
            /* {
                label : 'Upgrade Price',
                fieldName : 'buildertek__Upgrade_Price__c',
                type : 'currency',
                sortable : true,
                cellAttributes: { alignment: 'left' }
            },*/
            {
                label : 'Quantity',
                fieldName : 'buildertek__Quantity__c',
                type : 'number',
                sortable : true
                
            },
            {
                label : 'List Price',
                fieldName : 'buildertek__BL_LIST_PRICE__c',
                type : 'Currency',
                sortable : true
                
            },
            {
                label : 'Discount',
                fieldName : 'buildertek__BL_DISCOUNT__c',
                type : 'Percent',
                sortable : true
                
            },
            {
                label : 'Markup',
                fieldName : 'buildertek__BL_MARKUP__c',
                type : 'Percent',
                sortable : true
                
            },
            {
                label : 'Unit Cost',
                fieldName : 'buildertek__BL_UNIT_COST__c',
                type : 'Currency',
                sortable : true
                
            }
        ]);
    },
     getPoList : function(component,event,helper){
        var action = component.get("c.getprovendors");
        var recId = component.get("v.recordId");
        action.setParams({
            "optionLineID" : recId
        });
        action.setCallback(this, function(response){
            alert('JSON.stringify(response.getReturnValue())).length'+JSON.parse(JSON.stringify(response.getReturnValue())).length);
            if(response.getState() == 'SUCCESS'){
                if(JSON.parse(JSON.stringify(response.getReturnValue())).length){
                }
            }else{
                console.log(response);
            }
        });
        $A.enqueueAction(action);
    },
   
    
    getPoLinesList: function(component,event,helper,pageNumber,pageSize){
        component.set("v.Spinner", true);
        var vendorValue = component.get("v.searchVendorFilter");
        var categoryValue = component.get("v.searchCategoryFilter");
        var tradeTypeValue = component.get("v.searchTradeTypeFilter");
        var productTypeValue = component.get("v.searchProductTypeFilter");
        var purchaseOrderValue = component.get("v.searchPurchaseOrderFilter");
        var buildPhaseValue = component.get("v.searchBuildPhaseFilter");
        var toggleVal = component.get("v.groupBytoggle"); 
        var recId = component.get("v.recordId");
        
        //dynamic filter
        var bomLineOptionlist = component.get("v.fieldBOMLineNameApiList")
        var filter2 = '';
        for(var i=0;i<bomLineOptionlist.length;i++){
            if(bomLineOptionlist[i].Value){
                var fieldApiName = bomLineOptionlist[i]['Name']
                if(bomLineOptionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(bomLineOptionlist[i].Type == 'STRING' ||bomLineOptionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(bomLineOptionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(bomLineOptionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' ='+value1;
                }else if(bomLineOptionlist[i].Type == 'DATETIME'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                } else if(bomLineOptionlist[i].Type == 'DATE'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter2);
            }
        }
        
        var action = component.get("c.getProductOptionLines");
        action.setParams({
            "pageNumber" : pageNumber,
            "pageSize": pageSize,
            "recordId" : recId,
            "vendorName" : vendorValue,
            "category" : categoryValue,
            "tradeType": tradeTypeValue,
            "purchaseOrder": purchaseOrderValue,
            "productType": productTypeValue,
            "buildPhase": buildPhaseValue,
            "toggleValue":toggleVal,
            "filter": filter2
        });
        action.setCallback(this, function(response){
            debugger;
            var state = response.getState();
            if(state === "SUCCESS"){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                //component.set("v.masterBudgetsList", result);
                
                component.set("v.recordsList", result.recordList);
                component.set("v.listOfRecords", JSON.parse(result.sObjectRecordsList));
                component.set("v.cloneListOfRecords", JSON.parse(result.sObjectRecordsList));
                component.set("v.fieldValues", JSON.parse(result.fieldValues));
                //alert(JSON.stringify(component.get("v.listOfRecords")));
                //alert(JSON.stringify(component.get("v.cloneListOfRecords")));
                //alert(JSON.stringify(component.get("v.fieldValues")));
                
                
                component.set("v.PageNumber", result.pageNumber);
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(result.totalRecords / pageSize)
                );
                console.log('&**&*&*&*&*&*& ',result.recordList);
                var resultData = [];
                result.recordList.forEach(function(item,index){
                    resultData.push(item);
                });
                var rows = resultData;
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    
                    if (row.buildertek__Vendor__c){
                        row.VendorName = row.buildertek__Vendor__r.Name; 
                    }
                    if (row.buildertek__Purchase_Order__c){
                        row.PurchaseOrder = row.buildertek__Purchase_Order__r.Name; 
                    }
                    if (row.buildertek__Product_Type__c){
                        row.ProductType = row.buildertek__Product_Type__r.Name; 
                    }
                    if (row.buildertek__Category__c){
                        row.CategoryName = row.buildertek__Category__r.Name; 
                    }
                    if (row.buildertek__Trade_Type__c){
                        row.Tradetype = row.buildertek__Trade_Type__r.Name; 
                    }
                    if (row.buildertek__Build_Phase__c){
                        row.BuildPhase = row.buildertek__Build_Phase__r.Name; 
                    }
                    if (row.buildertek__Product__c){
                        row.ProductName = row.buildertek__Product__r.Name; 
                    }
                    if(row.Name){
                        row.linkName = '/'+row.Id;
                    }
                }
                component.set("v.orgData",rows);
                component.set("v.data",rows);
                var groupByData = component.get("v.orgData");
                component.set("v.fieldmaptype",result.fieldtypemap)
                helper.formatDataByGroups(component,event,helper,groupByData,result.fieldtypemap,
                                         JSON.parse(result.sObjectRecordsList));
                //component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                
                /*var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterBudgetsList").length> i)
                        PaginationList.push(result[i]);    
                }*/
                // component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
            }else{
                 component.set("v.Spinner", false);
                console.log(response.getError())
            }
        });
        $A.enqueueAction(action);
    },
    sortData : function(component,event,fieldName,sortDirection,data){
        /*var removeRowIndex = -1;
        var removeRowItem = data.filter(function(item,index){
            if(item.Name == 'Totals'){
                removeRowIndex = index;
                return item;
            }
        });
        if(removeRowIndex > -1){
             data.splice(removeRowIndex,1);
        }*/
         var key = function(a) { return a[fieldName]; }
         var reverse = sortDirection == 'asc' ? 1: -1;
         
        data.sort(function(a,b) {
            var x = '';
            var y = '';
            for (var i in a) {
                var arowKey = a[i].Key.replace('__r','__c');
                if(arowKey==fieldName){
                    x = a[i].Value+'';
                    break;  
                }                
            }
            
            for (var j in b) {
                var browKey = b[j].Key.replace('__r','__c');
                if(browKey==fieldName){
                    y = b[j].Value+'';
                    break;  
                }                
            }   
            x = x.toLowerCase();
            y = y.toLowerCase();
            
            
            return reverse * ((x>y) - (y>x));
        });

         var classIndex = event.currentTarget.dataset.sortgroupindex;
         var sortedData = JSON.parse(JSON.stringify(component.get("v.dataByGroup")));
         sortedData[classIndex]['groupedRecordsTmp'] = data;
         var ele = event.currentTarget;
         var sortEle = ele.getElementsByClassName("slds-icon-utility-arrowdown")[0];
         console.log(sortedData,data)
         component.set("v.dataByGroup",sortedData);
         /* if(sortDirection =="asc"){
            sortEle.style.transform = "rotate(180deg)";
        }else{
            sortEle.style.transform = "rotate(0deg)";
        }*/
         component.set("v.sortedBy",fieldName);
         if(sortDirection == "asc"){
             component.set("v.sortDirection","desc");
         }else{
             component.set("v.sortDirection","asc");
         }
         component.set("v.sortingGroupIndex",Number(classIndex));
         /* event.getSource().set("v.data",data);
        event.getSource().set("v.sortedDirection",sortDirection);
        event.getSource().set("v.sortedBy",sortedBy);*/
     },
    
    /* formatDataByGroups : function(component,event,helper,mapData){
        let recordsMap = new Map();
        for (var i in mapData) {
            var toggleVal = component.get("v.groupBytoggle");
            if(!toggleVal){
                //group by phase
                if(mapData[i].buildertek__Build_Phase__c){
                    if (!recordsMap.has(mapData[i].buildertek__Build_Phase__r.Id + '(#&%*)' + mapData[i].buildertek__Build_Phase__r.Name)) {
                        recordsMap.set(mapData[i].buildertek__Build_Phase__r.Id + '(#&%*)' + mapData[i].buildertek__Build_Phase__r.Name, []);
                    }
                    recordsMap.get(mapData[i].buildertek__Build_Phase__r.Id + '(#&%*)' + mapData[i].buildertek__Build_Phase__r.Name).push(JSON.parse(JSON.stringify(mapData[i])));
                }else{
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    if (!recordsMap.has('No Build Phase')) {
                        recordsMap.set('No Build Phase', []);
                    }
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    recordsMap.get('No Build Phase').push(JSON.parse(JSON.stringify(mapData[i])));
                    //console.log(recordsMap.get("No vendor"))
                }
            }else if(toggleVal){
                if(mapData[i].buildertek__Vendor__c){
                    if (!recordsMap.has(mapData[i].buildertek__Vendor__r.Id + '(#&%*)' + mapData[i].buildertek__Vendor__r.Name)) {
                        recordsMap.set(mapData[i].buildertek__Vendor__r.Id + '(#&%*)' + mapData[i].buildertek__Vendor__r.Name, []);
                    }
                    recordsMap.get(mapData[i].buildertek__Vendor__r.Id + '(#&%*)' + mapData[i].buildertek__Vendor__r.Name).push(JSON.parse(JSON.stringify(mapData[i])));
                }else{
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    if (!recordsMap.has('No Vendor')) {
                        recordsMap.set('No Vendor', []);
                    }
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    recordsMap.get('No Vendor').push(JSON.parse(JSON.stringify(mapData[i])));
                    //console.log(recordsMap.get("No vendor"))
                }
            }
            
   
		}
        var result = Array.from(recordsMap.entries());
        var groupData = [];
        for(var i in result){
            var newObj = {};
            if(result[i][0].indexOf('(#&%*)') > -1){
                newObj['groupName'] = result[i][0].split('(#&%*)')[1];
            }else{
                newObj['groupName'] = result[i][0];
            }
            newObj['groupData'] = result[i][1];
            groupData.push(newObj);
        }
        console.log(groupData);
        component.set("v.dataByGroup",groupData);
        component.set("v.Spinner", false);
    }*/
    
    
    formatDataByGroups : function(component,event,helper,mapData,fieldtypemap,sObjectRecordsList){
        let recordsMap = new Map();
        let sObjectRecordsMap = new Map();
        
        
        for (var kkk in  sObjectRecordsList) {
            sObjectRecordsMap.set(sObjectRecordsList[kkk].Id, sObjectRecordsList[kkk]);
        }
         //alert(sObjectRecordsMap);
        
        
        
        for (var i in mapData) {
            var toggleVal = component.get("v.groupBytoggle");
            
            if(component.get("v.groupByPhasetoggle")){
                //group by phase
                if(mapData[i].sheetrecord.buildertek__Build_Phase__c){
                    if (!recordsMap.has(mapData[i].sheetrecord.buildertek__Build_Phase__r.Id + '(#&%*)' + mapData[i].sheetrecord.buildertek__Build_Phase__r.Name)) {
                        recordsMap.set(mapData[i].sheetrecord.buildertek__Build_Phase__r.Id + '(#&%*)' + mapData[i].sheetrecord.buildertek__Build_Phase__r.Name, []);
                    }
                    mapData[i]['sheetrecord']['showIcon'] = mapData[i]['isShowIcon']
                    recordsMap.get(mapData[i].sheetrecord.buildertek__Build_Phase__r.Id + '(#&%*)' + mapData[i].sheetrecord.buildertek__Build_Phase__r.Name).push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                }else{
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    if (!recordsMap.has('No Build Phase')) {
                        recordsMap.set('No Build Phase', []);
                    }
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    mapData[i]['sheetrecord']['showIcon'] = mapData[i]['isShowIcon']
                    recordsMap.get('No Build Phase').push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                    //console.log(recordsMap.get("No vendor"))
                }
            }else if(component.get("v.groupByVendortoggle")){
                if(mapData[i].sheetrecord.buildertek__Vendor__c){
                    if (!recordsMap.has(mapData[i].sheetrecord.buildertek__Vendor__r.Id + '(#&%*)' + mapData[i].sheetrecord.buildertek__Vendor__r.Name)) {
                        recordsMap.set(mapData[i].sheetrecord.buildertek__Vendor__r.Id + '(#&%*)' + mapData[i].sheetrecord.buildertek__Vendor__r.Name, []);
                    }
                   mapData[i]['sheetrecord']['showIcon'] = mapData[i]['isShowIcon']
                    recordsMap.get(mapData[i].sheetrecord.buildertek__Vendor__r.Id + '(#&%*)' + mapData[i].sheetrecord.buildertek__Vendor__r.Name).push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                }else{
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    if (!recordsMap.has('No Vendor')) {
                        recordsMap.set('No Vendor', []);
                    }
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    mapData[i]['sheetrecord']['showIcon'] = mapData[i]['isShowIcon']
                    recordsMap.get('No Vendor').push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                    //console.log(recordsMap.get("No vendor"))
                }
            }else if(component.get("v.groupByCategorytoggle")){
                if(mapData[i].sheetrecord.buildertek__Category__c){
                    if (!recordsMap.has(mapData[i].sheetrecord.buildertek__Category__r.Id + '(#&%*)' + mapData[i].sheetrecord.buildertek__Category__r.Name)) {
                        recordsMap.set(mapData[i].sheetrecord.buildertek__Category__r.Id + '(#&%*)' + mapData[i].sheetrecord.buildertek__Category__r.Name, []);
                    }
                    mapData[i]['sheetrecord']['showIcon'] = mapData[i]['isShowIcon']
                    recordsMap.get(mapData[i].sheetrecord.buildertek__Category__r.Id + '(#&%*)' + mapData[i].sheetrecord.buildertek__Category__r.Name).push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                }else{
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    if (!recordsMap.has('No Category')) {
                        recordsMap.set('No Category', []);
                    }
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    mapData[i]['sheetrecord']['showIcon'] = mapData[i]['isShowIcon']
                    recordsMap.get('No Category').push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                    //console.log(recordsMap.get("No vendor"))
                }
                
            }
            
            
        }
        var result = Array.from(recordsMap.entries());
        var groupData = [];
        for(var i in result){
            var newObj = {};
            if(result[i][0].indexOf('(#&%*)') > -1){
                newObj['groupName'] = result[i][0].split('(#&%*)')[1];
            }else{
                newObj['groupName'] = result[i][0];
            }
            newObj['groupData'] = result[i][1];
           
            
            //dynamic field
            var selectedFields = component.get("v.bomLineselectedFields").split(',');
            var mainList = [];
			var sObjectRecordsList = [];            
            //alert('arrkeys '+i+arrkeys);
            for (var j in newObj['groupData'] ) {
                //alert(newObj['groupData'][j].Id);               
                //alert(JSON.stringify(sObjectRecordsMap.get(newObj['groupData'][j].Id)));

                
                let newList = [];    
                if(selectedFields.indexOf('Id') < 0){
                    selectedFields.unshift('Id')
                }
                console.log(newObj['groupData'][j])
                for(var k=0; k<selectedFields.length; k++){  
                    var AllRowListMap = new Map(Object.entries(newObj['groupData'][j]));
                    console.log('*****************',AllRowListMap);
                    var keyId  = Array.from(AllRowListMap.keys())[0]; 
                    //alert(keyId);
                    var mapKey =  selectedFields[k]; 
                    
                    var strrecord = JSON.stringify(Object.entries(newObj['groupData'][j]));                     
                    let indexObj = {};
                    indexObj.fieldType = fieldtypemap[mapKey];
                    indexObj.inlineEdit = false;
                    indexObj.showEditIcon = true;
                    if(strrecord.indexOf(mapKey)>0){
                        if(mapKey.indexOf('__c')>0){
                            indexObj.Key = mapKey;                                
                            indexObj.Value = AllRowListMap.get(mapKey); 
                            indexObj.Id  = AllRowListMap.get(keyId); 
                        }
                        
                        if(mapKey.indexOf('__r')>0){
                            console.log('^^^^^^^'+(mapKey));
                            console.log('^^^^^^^'+JSON.stringify(AllRowListMap.get(mapKey)));
                            console.log('^^^^^^^'+AllRowListMap);
                            console.log('^^^^^^^ out'+AllRowListMap.get(mapKey));
                            if(AllRowListMap.get(mapKey) != undefined){
                                console.log('^^^^^^^ inn'+AllRowListMap.get(mapKey));
                                var AllRowListMap2 = new Map(Object.entries(AllRowListMap.get(mapKey))); 
                                var mapKey2 = Array.from(AllRowListMap2.keys())[0];
                                console.log('mapKey2',mapKey2);
                                indexObj.Key = mapKey;                                
                                indexObj.Value = AllRowListMap2.get(mapKey2); 
                                indexObj.Id  = AllRowListMap.get(keyId); 
                            }

                                
                          
                        }
                        if(mapKey=='Name'){
                            indexObj.Key = mapKey;                                
                            indexObj.Value = AllRowListMap.get(mapKey);
                            indexObj.Id  = AllRowListMap.get(keyId); 
                        }
                        if(mapKey=='Id'){
                            indexObj.Key = mapKey;                                
                            indexObj.Value = AllRowListMap.get(mapKey);
                            indexObj.Id  = AllRowListMap.get(keyId); 
                            indexObj.showVendorIcon = newObj['groupData'][j]['showIcon']
                        }
                    }else{
                        indexObj.Key = mapKey;                                
                        indexObj.Value = '';
                        indexObj.Id  = AllRowListMap.get(keyId); 
                        indexObj.showVendorIcon = newObj['groupData'][j]['showIcon']
                    }  
                    
                    newList.push(indexObj);  
                    
                }
               /* newList.unshift({'Key':'showVenordIcon','showVenordIcon': newObj['groupData'][j]['showIcon'] })
               delete newObj['groupData'][j]['showIcon'];*/
                delete newObj['groupData'][j]['showIcon'];
                mainList.push(newList); 
		        sObjectRecordsList.push(sObjectRecordsMap.get(newObj['groupData'][j].Id));
            }
            
            newObj.groupedRecordsTmp = mainList;
            newObj.sObjectRecordsList = sObjectRecordsList;
            groupData.push(newObj);
        }
        console.log(groupData);
        
        
        
        component.set("v.dataByGroup",groupData);
        component.set("v.cloneDataByGroup",groupData);
        
        
        component.set("v.Spinner", false);
    },
    fetchTakeOffLinesData: function (component, event, helper) {       
        var action = component.get("c.getTakeOffLinesData");        
        action.setCallback(this, function (response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    console.log(result);
                    //alert(JSON.stringify(result.TakeOffFieldSettings));
                   
                    // bom line data
                    component.set("v.bomLineFieldsSettings",result.bomLineFieldSettings);
                    var bomSelectedFieldsLength = result.bomLineselectedFields.split(',').length
                    bomSelectedFieldsLength = bomSelectedFieldsLength+2;
                    component.set("v.bomLineselectedFieldsLength",bomSelectedFieldsLength)
                    component.set("v.bomLineselectedFields",result.bomLineselectedFields);
                }
                var getBOMLineFieldMapAction =  component.get("c.getBOMLineFiledNameAndApi")
                component.set("v.isSpinner",true)
                getBOMLineFieldMapAction.setCallback(this, function (response) {
                    debugger;
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isSpinner",true)
                        var result = response.getReturnValue();
                        component.set("v.fieldBOMLineNameApiMap",result)
                        var neList = []
                        neList = Object.values(result)
                        console.log(neList)
                        component.set("v.fieldBOMLineNameApiList",neList)
                        component.set("v.isSpinner",false)
                    }
                })
                $A.enqueueAction(getBOMLineFieldMapAction);
                
                component.set("v.isSpinner", false);
                
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    
    
      updateMassRecords: function (component, event, helper) {
        debugger;
        component.set('v.isLoading', true);
        //var listOfRecords = component.get('v.listOfRecords');
        //var listOfRecords = component.get('v.listOfRecords');
          
          var data = JSON.parse(JSON.stringify(component.get("v.dataByGroup")));
          var newList = []
          for (var i in data) {
              //alert(JSON.stringify(data[i].sObjectRecordsList));
              for(var j in data[i].sObjectRecordsList){
                 //alert(data[i].sObjectRecordsList[j].Id);
                 //alert(data[i].sObjectRecordsList[j].Name); 
                 newList.push(data[i].sObjectRecordsList[j]); 
              }
          }          
          
        var action = component.get("c.updateRecords"); 
        
        action.setParams({
            recordId: component.get('v.recordId'),
            updatedRecords: JSON.stringify(newList)
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                var pageNumber = component.get("v.PageNumber");
                var pageSize = component.get("v.pageSize");
                helper.getPoLinesList(component, event, helper,pageNumber,pageSize);
                
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },

    deleteRecord: function (component, event, helper, deleteRecordId) {
        component.set('v.isLoading', true);
        var action = component.get("c.deleteBOMLine");
        action.setParams({
            deleteRecordId: deleteRecordId           
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                var pageNumber = component.get("v.PageNumber");
                var pageSize = component.get("v.pageSize");
                helper.getPoLinesList(component, event, helper,pageNumber,pageSize);
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    
    
    
    
})