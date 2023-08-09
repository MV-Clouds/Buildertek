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
                    component.set("v.vendorList",JSON.parse(JSON.stringify(response.getReturnValue())));
                    component.set("v.showModal",true);
                }else{
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "No Vendor",
                        "message": "No other Vendors found for this product",
                        closeCallback: function () {}
                    });
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
            "toggleValue":toggleVal
        });
        action.setCallback(this, function(response){
            debugger;
            var state = response.getState();
            if(state === "SUCCESS"){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                //component.set("v.masterBudgetsList", result);
               
                component.set("v.recordsList", result.recordList);
                component.set("v.PageNumber", result.pageNumber);
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(result.totalRecords / pageSize)
                );
                
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
                helper.formatDataByGroups(component,event,helper,groupByData);
                //component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
               
                /*var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterBudgetsList").length> i)
                        PaginationList.push(result[i]);    
                }*/
               // component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
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
       
        //var sortedBy = event.getParam('fieldName');
        // to handel number/currency type fields 
        if(fieldName == 'buildertek__Upgrade_Price__c' || fieldName == 'Name' || fieldName == "PurchaseOrder" || fieldName== "buildertek__Quantity__c"){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else if(fieldName == 'ProductType' || fieldName == 'CategoryName' || fieldName == 'ProductName' || fieldName == 'Tradetype' || fieldName == 'BuildPhase' || fieldName == 'buildertek__Standard__c' || fieldName == 'buildertek__Location_Picklist__c' || fieldName == 'VendorName') {
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });
        }
        /*if(removeRowIndex > -1){
            data.push(removeRowItem[0]);
        }*/
        
         var classIndex = event.currentTarget.dataset.sortgroupindex;
         var sortedData = JSON.parse(JSON.stringify(component.get("v.dataByGroup")));
         sortedData[classIndex]['groupData'] = data;
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
    
    formatDataByGroups : function(component,event,helper,mapData){
        let recordsMap = new Map();
        for (var i in mapData) {
            var toggleVal = component.get("v.groupBytoggle");
            
            if(component.get("v.groupByPhasetoggle")){
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
            }else if(component.get("v.groupByVendortoggle")){
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
            }else if(component.get("v.groupByCategorytoggle")){
                if(mapData[i].buildertek__Category__c){
                    if (!recordsMap.has(mapData[i].buildertek__Category__r.Id + '(#&%*)' + mapData[i].buildertek__Category__r.Name)) {
                        recordsMap.set(mapData[i].buildertek__Category__r.Id + '(#&%*)' + mapData[i].buildertek__Category__r.Name, []);
                    }
                    recordsMap.get(mapData[i].buildertek__Category__r.Id + '(#&%*)' + mapData[i].buildertek__Category__r.Name).push(JSON.parse(JSON.stringify(mapData[i])));
                }else{
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    if (!recordsMap.has('No Category')) {
                        recordsMap.set('No Category', []);
                    }
                    //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    recordsMap.get('No Category').push(JSON.parse(JSON.stringify(mapData[i])));
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
    }
})