public with sharing class ImportPOinCOController {

    /* ================================================
        CreatedDate:-4th January 2023
        Description:-Display purchase order List if Project related to change order is not empty and Purchase order related to Change order is Empty
    ====================================================*/
    @AuraEnabled
    public static wrapperClass  getPoList(String recordId){

        wrapperClass wc = new wrapperClass();
        wc.purchaseOrderList=new List<buildertek__Purchase_Order__c>();
    
        buildertek__Change_Order__c changeOrder;
        if(recordId!= null && recordId !=''){
            changeOrder=[SELECT Id, Name, buildertek__Project__c , buildertek__Purchase_Order__c FROM buildertek__Change_Order__c where Id=:recordId LIMIT 1];
        }
        if(changeOrder!=null){
            if(changeOrder.buildertek__Purchase_Order__c == null && changeOrder.buildertek__Project__c != null){
                List<buildertek__Purchase_Order__c> poList =[SELECT Id,Name ,buildertek__PO_Total__c, buildertek__Project__c  ,buildertek__Status__c,buildertek__Vendor__c , buildertek__Vendor__r.Name  FROM buildertek__Purchase_Order__c where buildertek__Project__c=:changeOrder.buildertek__Project__c];
                wc.purchaseOrderList=poList;
                wc.POisNull=false;
                wc.message='Purchase Order List';
                return wc;
            }else if(changeOrder.buildertek__Project__c == null && changeOrder.buildertek__Purchase_Order__c == null){
                wc.message='noData';
                return wc;

            }else{
                wc.POisNull=true;
                wc.message='Purchase Order is already defined';
                return wc;
            }
        }else{
           
            return null;
        }
   
    }

    /* ================================================
        CreatedDate:-4th January 2023
        Description:-This method used to create change order Line when user click on Import po button from change order Record page
     ====================================================*/
    @AuraEnabled
    public static String  createCoLine(String poRecordId , String coRecordId){
 
        List<buildertek__Change_Order_Item__c> changeOrderLineList= new List<buildertek__Change_Order_Item__c>();
        buildertek__Purchase_Order__c purchaseOrder ;
        List<buildertek__Purchase_Order_Item__c> poLineList ;

        if(poRecordId != null && poRecordId!=''){
            purchaseOrder = [Select Id , Name, buildertek__Vendor__c From buildertek__Purchase_Order__c  where Id=:poRecordId LIMIT 1];
            poLineList = [SELECT Id, Name, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Purchase_Order__c FROM buildertek__Purchase_Order_Item__c where buildertek__Purchase_Order__c=:poRecordId];
        }

        if(poLineList.size() > 0){
            for(buildertek__Purchase_Order_Item__c poLine: poLineList){
                buildertek__Change_Order_Item__c changeOrderLine= new buildertek__Change_Order_Item__c();
                 changeOrderLine.buildertek__Quantity__c = poLine.buildertek__Quantity__c;
                 changeOrderLine.buildertek__Unit_Price__c = poLine.buildertek__Unit_Price__c;
                 changeOrderLine.Name=poLine.Name;
                 changeOrderLine.buildertek__Vendor__c=purchaseOrder.buildertek__Vendor__c;
                 if(coRecordId != null && coRecordId != ''){
                     changeOrderLine.buildertek__Change_Order__c = coRecordId;
                 }
                 changeOrderLineList.add(changeOrderLine);
            }
 
             if(changeOrderLineList.size() > 0){
                 insert changeOrderLineList;
                 System.debug(changeOrderLineList);
                 System.debug(changeOrderLineList.size());
 
                 // update change order vendor value equal to Purchase order vendor value
                 buildertek__Change_Order__c changeOrder = new buildertek__Change_Order__c();
                 changeOrder.Id = coRecordId;
                 changeOrder.buildertek__Vendor__c = purchaseOrder.buildertek__Vendor__c;
                 changeOrder.buildertek__Purchase_Order__c  = purchaseOrder.Id;

                 
                 update changeOrder;
                 System.debug(changeOrder);
                 
             }
             return 'success';
 
        }else{
             return 'noRecords';
        }
 
    }

    public class wrapperClass{
        @AuraEnabled
        public List<buildertek__Purchase_Order__c> purchaseOrderList{get;set;}
        @AuraEnabled
        public Boolean POisNull;
        @AuraEnabled
        public String message;

    }
     
 }