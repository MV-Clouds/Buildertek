public class testcontroller {

    public string teststring {get;set;}
    
    public testcontroller(){
            teststring='';
    if(Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Id.isAccessible()  ){teststring += ' -- buildertek__RFQ_To_Vendor__c.fields.Id';}
    if(Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Name.isAccessible()  ){teststring += ' -- buildertek__RFQ_To_Vendor__c.fields.Name';}
    if(Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_To_Vendor__c.fields.buildertek__Contact__c';}
    if(Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Status__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_To_Vendor__c.fields.buildertek__Status__c';}
    if(Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Quote_Amount__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_To_Vendor__c.fields.buildertek__Quote_Amount__c';}
    if(Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() ){teststring += ' -- buildertek__RFQ__c.fields.Id';}
    if(Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Vendor__c.isAccessible()  ){teststring += ' -- buildertek__RFQ__c.fields.buildertek__Vendor__c';}
    if(Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isAccessible()  ){teststring += ' -- buildertek__RFQ__c.fields.buildertek__Status__c';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.Id.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.Id';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.Name.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.Name';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Item_Name__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.buildertek__Item_Name__c';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Quantity__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.buildertek__Quantity__c';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Unit_Price__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.buildertek__Unit_Price__c';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Total_Price__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.buildertek__Total_Price__c';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Description__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.buildertek__Description__c';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Budget_Line_Amount__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.buildertek__Budget_Line_Amount__c';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Vendor_Note__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.buildertek__Vendor_Note__c';}
    if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Estimated_Work_Days__c.isAccessible()  ){teststring += ' -- buildertek__RFQ_Vendor_Item__c.fields.buildertek__Estimated_Work_Days__c';}
    if(Schema.sObjectType.buildertek__RFQ_To_Vendor_Document_Link__c.fields.Id.isAccessible()  ){teststring += ' -- buildertek__RFQ_To_Vendor_Document_Link__c.fields.Id';}
    if(Schema.sObjectType.buildertek__RFQ_To_Vendor_Document_Link__c.fields.Name.isAccessible()  ){teststring += ' -- buildertek__RFQ_To_Vendor_Document_Link__c.fields.Name';}
    if(Schema.sObjectType.buildertek__RFQ_To_Vendor_Document_Link__c.fields.buildertek__File__c.isAccessible() ){teststring += ' -- buildertek__RFQ_To_Vendor_Document_Link__c.fields.buildertek__File__c';}
    if(Schema.sObjectType.buildertek__File__c.fields.Id.isAccessible()  ){teststring += ' -- buildertek__File__c.fields.Id';}
    if(Schema.sObjectType.buildertek__File__c.fields.Name.isAccessible()  ){teststring += ' -- buildertek__File__c.fields.Name';}
    if(Schema.sObjectType.buildertek__File__c.fields.buildertek__File_Presigned_URL__c.isAccessible()  ){teststring += ' -- buildertek__File__c.fields.buildertek__File_Presigned_URL__c';}
    if(Schema.sObjectType.buildertek__File__c.fields.buildertek__Download_Link__c.isAccessible()  ){teststring += ' -- buildertek__File__c.fields.buildertek__Download_Link__c';}
    if(Schema.sObjectType.buildertek__File__c.fields.buildertek__Download_Link1__c.isAccessible()){teststring += ' -- buildertek__File__c.fields.buildertek__Download_Link1__c';}
    }
}