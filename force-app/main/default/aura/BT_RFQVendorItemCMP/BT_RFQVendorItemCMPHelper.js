({
   
    toastMsg : function( strType, strMessage ) {  
        var showToast = $A.get( "e.force:showToast" );   
        showToast.setParams({   
              
            //message : strMessage,  
            //type : strType,  
            //mode : 'sticky'  

            title : "Success!",
            message : strMessage,
            type: 'success',
            duration: '1000',
            key: 'info_alt',
            mode: 'pester'
              
        });   
        showToast.fire();
    },
    getrelatedrfqvendorlist : function(component, event, helper){
        var action1 = component.get("c.getRfqTo");
        action1.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                   component.set("v.currencycode",response.getReturnValue());
			} 
		});
		$A.enqueueAction(action1);
        var action2 = component.get("c.getmulticurrency");
        action2.setCallback(this, function (response) {
            var state = response.getState();
             if (state === "SUCCESS") {
                  component.set("v.multicurrency",response.getReturnValue());
                //  component.set("v.multicurrency",false);
			} 
		});
		$A.enqueueAction(action2);	
    var action = component.get("c.getRelatedList");
        action.setParams({
            recId : component.get("v.rfqrecordId")
        })
        action.setCallback(this, function(data){
            //alert(data.getReturnValue());
            var result = data.getReturnValue();

            //component.set("v.RFQVendorLineList", data.getReturnValue());
            //alert(result.RFQVendorLineList);
            //alert(JSON.stringify(result.RFQVendorLineList));
            component.set("v.RFQVendorLineList",result.RFQVendorLineList);
            component.set("v.rfqtovendorId",result.rfqtovendorrec.Id);
            component.set('v.files',result.fileslist); 
            if(result.rfqtovendorrec.buildertek__Status__c=='Quote Submitted'){           
                component.set("v.submitted",true);
                component.set("v.Isrejected",false);
                component.set("v.iseditable",false);
            }else if(result.rfqtovendorrec.buildertek__Status__c=='Email Sent'){
                component.set("v.iseditable",true);
                component.set("v.Isrejected",true);
            }else if(result.rfqtovendorrec.buildertek__Status__c=='Rejected' && result.rfqtovendorrec.buildertek__RFQ__r.buildertek__Status__c != 'Canceled'){
                component.set("v.iseditable",true);
                component.set("v.Isrejected",true);
            }else{
                component.set("v.iseditable",false);
                component.set("v.Isrejected",false);
                component.set("v.submitted",true);
            }
            //alert(component.get("v.submitted"));
            //alert(component.get("v.iseditable"));
            if(component.get("v.Isrejected") == true){
                component.set('v.columns', [
                {label: 'Item Name', fieldName: 'Name', type: 'text' },
                {label: 'Description', fieldName: 'buildertek__Description__c', type: 'text'},
                {label: 'Quantity', fieldName: 'buildertek__Vendor_Quantity__c', type: 'number' ,  editable: component.get("v.iseditable")},
                {label: 'Unit Price', fieldName: 'buildertek__Vendor_Unit_Price__c', type: 'currency' ,  editable: component.get("v.iseditable"),
                 typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
                 },
               {label: 'Estimated Work(Days)', fieldName: 'buildertek__Vendor_Estimated_Work_Days__c', type: 'number' ,  editable: component.get("v.iseditable")
                },
                {label: 'Vendor Note', fieldName: 'buildertek__Note__c', type: 'text' ,  editable: component.get("v.iseditable")},
                    {label: 'Total Price', fieldName: 'buildertek__Vendor_Total_Price__c', type: 'currency' ,
                 typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
                 },
                    {type: "button", typeAttributes: {
                    label: 'Delete',
                    name: 'Delete',
                    title: 'Delete',
                    disabled: {fieldName: 'actionDisabled'},
                    value: 'delete',
                    iconPosition: 'left',
                }},
                 
                    
            ]);    
            }else{
                component.set('v.columns', [
                {label: 'Item Name', fieldName: 'Name', type: 'text' },
                {label: 'Description', fieldName: 'buildertek__Description__c', type: 'text'},
                {label: 'Quantity', fieldName: 'buildertek__Vendor_Quantity__c', type: 'number' ,  editable: component.get("v.iseditable")},
                {label: 'Unit Price', fieldName: 'buildertek__Vendor_Unit_Price__c', type: 'currency' ,  editable: component.get("v.iseditable"),
                 typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
                 },
                    {label: 'Estimated Work(Days)', fieldName: 'buildertek__Vendor_Estimated_Work_Days__c', type: 'number' ,  editable: component.get("v.iseditable")
                     },
                {label: 'Vendor Note', fieldName: 'buildertek__Note__c', type: 'text' ,  editable: component.get("v.iseditable")},
                 {label: 'Total Price', fieldName: 'buildertek__Vendor_Total_Price__c', type: 'currency' ,
                 typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
                 },   
               /* {label: 'Quantity', fieldName: 'buildertek__Quantity__c', type: 'number' ,  editable: component.get("v.iseditable")},
                  {label: 'Unit Price', fieldName: 'buildertek__Unit_Price__c', type: 'currency' ,  editable: component.get("v.iseditable"),
                 typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: "code" },
                 },
                {label: 'Vendor Note', fieldName: 'buildertek__Vendor_Note__c', type: 'text' ,  editable: component.get("v.iseditable")}*/
                /* {label: 'Unit Price', fieldName: 'buildertek__Unit_Price__c', type: 'Currency' ,  editable: component.get("v.iseditable")},*/
                /*{type: "button", typeAttributes: {
                    label: 'Edit',
                    name: 'Edit',
                    title: 'Edit',
                    disabled: false,
                    value: 'edit',
                    iconPosition: 'left'
                }}*/
            ]);    
            }
            for ( var i = 0; i < result.RFQVendorLineList.length; i++ ) {
                var row = result.RFQVendorLineList[i];
              //  alert(JSON.stringify(row));
              //  alert('hh'+row.buildertek__CreateVendor__c);
                if((row.buildertek__RFQ_Item__c != undefined && row.buildertek__RFQ_Item__c != null  && row.buildertek__RFQ_Item__c != '') ||row.buildertek__CreateVendor__c == true){
                   row.actionDisabled = true;
                }else{
                  row.actionDisabled = false;  
                }
                
                if(component.get("v.multicurrency") == true){
                    row.CurrencyIso = row.CurrencyIsoCode; 
                    component.set("v.currencycodeforamount",row.CurrencyIsoCode);
                }else{
                   row.CurrencyIso = component.get("v.currencycode");  
                 component.set("v.currencycodeforamount",component.get("v.currencycode"));
               }
               
            }
            component.set("v.RFQVendorLineList",result.RFQVendorLineList);
            component.set("v.totalamount",result.rfqtovendorrec.buildertek__Vendor_Quote_Amount__c);
        });
        $A.enqueueAction(action);
    },
    relatedrfqDocumen :function(component, event, helper){
         var fileslist = component.get('v.rfqrelatedfiles');
                //alert('fileslist'+ fileslist.length);
                if(fileslist.length > 0){
                component.set("v.Isrfqfiles",true);
               // component.set("v.isrfi",false);
                }else{
                // component.set("v.Isnofiles",true);
               // component.set("v.isrfi",false);
                }
}

})