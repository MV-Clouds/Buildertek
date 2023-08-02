({
	closeModel : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();    
	},
    getPoList : function(component, event, helper){
    	component.set("v.Spinner", true);
        var vendorValue = component.get("v.searchRfqVendorFilter");
        var statusValue = component.get("v.searchRfqStatusFilter");
        var descriptionValue = component.get("v.searchRfqDesFilter");
        var recId = component.get("v.recordId");
         var action = component.get("c.getMasterRFQs");
        action.setParams({
            "recordId" : recId,
            "vendorName" : vendorValue.trim(),
            "status" : statusValue.trim(),
            "description":descriptionValue.trim()
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                component.set("v.masterBudgetsList", result);
                var resultData = [];
                result.forEach(function(item,index){
                    resultData.push(item.purchaseOrderRecord);
                });
                var rows = resultData;
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    if (row.buildertek__Vendor__c){
                        row.Vendorname = row.buildertek__Vendor__r.Name; 
                    }
                    if (row.buildertek__Schedule_Item__c && row.buildertek__Schedule_Item__r.Name != undefined ){
                        row.ScheduleItem = row.buildertek__Schedule_Item__r.Name; 
                    }
                    if(row.Name){
                        row.linkName = '/'+row.Id;
                    }
                }
                component.set("v.orgData",rows);
                component.set("v.data",rows);
                var groupByData = component.get("v.orgData");
                helper.formatDataByGroups(component,event,helper,groupByData);
                component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterBudgetsList").length> i)
                        PaginationList.push(result[i]);    
                }
                var grandPOtotal = 0;
                var grandPaidAmounttotal = 0;
                var grandPOBalancetotal = 0;
                for(var i=0; i< result.length; i++){
                   grandPOtotal = grandPOtotal + result[i].purchaseOrderRecord.buildertek__PO_Total__c;
                   grandPaidAmounttotal = grandPaidAmounttotal + result[i].purchaseOrderRecord.buildertek__Paid_Amount__c;
                   grandPOBalancetotal = grandPOBalancetotal + result[i].purchaseOrderRecord.buildertek__PO_Balance__c;
                   component.set('v.POtoal', grandPOtotal);
                   component.set('v.PaidAmount', grandPaidAmounttotal);
                   component.set('v.POBalance', grandPOBalancetotal);
                    
                }
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
	},
     next: function (component, event, helper) {
        var sObjectList = component.get("v.masterBudgetsList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.masterBudgetsList"); 
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    setColumns: function(component) {
        component.set("v.columns",[
            {
                label : 'Name',
                //fieldName : 'POName',
                fieldName: 'linkName', 
                type: 'url',
             	typeAttributes: { label: { fieldName: 'Name' }, target: '_blank', tooltip: { fieldName: 'Name' } } 
                /*type: 'url',
                typeAttributes: { 
                    label: {
                        fieldName: 'Name',
                        target: "_blank"
                    } 
                }*/,                
                sortable : true
            },
            {
                label : 'Vendor',
                fieldName : 'Vendorname',
                //fieldName : 'buildertek__Vendor__r.Name',
                type : 'text',
                sortable : true
            },
            {
                label : 'Status',
                
                fieldName : 'buildertek__Status__c',
                type : 'text',
                sortable : true
            },
            {
                label: 'Created Date',
                fieldName : 'buildertek__Date_Created__c',
                type: 'Date',
                sortable : true
            },
            {
                label : 'Description',
                fieldName : 'buildertek__Description__c',
                type : 'text',
                sortable : true
            },
            {
                label : 'PO Total',
                fieldName : 'buildertek__PO_Total__c',
                type : 'currency',
                sortable : true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label : 'Paid Amount',
                fieldName : 'buildertek__Paid_Amount__c',
                type : 'currency',
                sortable : true,
                 cellAttributes: { alignment: 'left' }
            },
            {
                label : 'PO Balance',
                fieldName : 'buildertek__PO_Balance__c',
                type : 'currency',
                sortable : true,
                 cellAttributes: { alignment: 'left' }
            },
            {
                label : 'Schedule Item',
                fieldName: 'ScheduleItem',
                //fieldName : 'buildertek__Schedule_Item__r.Name',
                type : 'text',
                sortable : true
            }]);
    },
      
    sortData : function(component,event,fieldName,sortDirection,data){//,tableId){
        //var data = data;//event.getSource().get("v.data");//component.get("v.data");
        //function to return the value stored in the field
        var removeRowIndex = -1;
        var removeRowItem = data.filter(function(item,index){
            if(item.Name == 'Totals'){
                removeRowIndex = index;
                return item;
            }
        });
        if(removeRowIndex > -1){
             data.splice(removeRowIndex,1);
        }
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        var sortedBy = event.getParam('fieldName');
        // to handel number/currency type fields 
        if(fieldName == 'buildertek__PO_Balance__c'|| fieldName == 'buildertek__Paid_Amount__c' || fieldName == 'buildertek__PO_Total__c' || fieldName =='buildertek__Date_Created__c' || fieldName == 'linkName'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else if(fieldName == 'buildertek__Description__c' || fieldName == 'buildertek__Status__c' || fieldName == 'ScheduleItem' || fieldName == 'Vendorname') {// to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }/*else if(){
            data.sort(function(a, b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * (Date.parse(a) - Date.parse(b));
            });
        }*/
        
        if(removeRowIndex > -1){
            data.push(removeRowItem[0]);
        }
        
        event.getSource().set("v.data",data);
        event.getSource().set("v.sortedDirection",sortDirection);
        event.getSource().set("v.sortedBy",sortedBy);
        /*component.set("v.data",data);
         event.getSource().set("v.sortDirection",sortDirection);
          event.getSource().set("v.sortedBy",sortedBy);
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', sortedBy)*/;
    },
    formatDataByGroups : function(component,event,helper,mapData){
        let recordsMap = new Map();
        for (var i in mapData) {
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
        var result = Array.from(recordsMap.entries());
        var groupData = [];
        for(var i in result){
            var newObj = {};
            if(result[i][0].indexOf('(#&%*)') > -1){
                //alert('&&');
                newObj['groupName'] = result[i][0].split('(#&%*)')[1];
            }else{
              //  alert('%%%%');
                newObj['groupName'] = result[i][0];
            }
            newObj['groupData'] = result[i][1];
           // newObj['selectedRows'] = [];
            var res = result[i][1];
            var totalsObj = {};
            var grandPOtotal = 0;
            var grandPaidAmounttotal = 0;
            var grandPOBalancetotal = 0;
            for(var j=0; j< res.length; j++){
                   grandPOtotal = grandPOtotal + res[j].buildertek__PO_Total__c;
                   grandPaidAmounttotal = grandPaidAmounttotal + res[j].buildertek__Paid_Amount__c;
                   grandPOBalancetotal = grandPOBalancetotal + res[j].buildertek__PO_Balance__c;
             }
            totalsObj['Name'] = 'Totals'
            totalsObj['linkName'] = 'Totals'
            //totalsObj['Vendorname'] = 'Totals'
            totalsObj['buildertek__PO_Total__c'] = grandPOtotal;
             totalsObj['buildertek__Paid_Amount__c'] = grandPaidAmounttotal;
            totalsObj['buildertek__PO_Balance__c'] = grandPOBalancetotal
            
            newObj['groupData'].push(totalsObj);
            //newObj['groupDataTotals'] = [grandPOtotal, grandPaidAmounttotal, grandPOBalancetotal];
            groupData.push(newObj);
        }
        console.log(groupData);
        component.set("v.dataByGroup",groupData);
        component.set("v.Spinner", false);
    }
            
})