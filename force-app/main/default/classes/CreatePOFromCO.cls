//Developer : Laxman 27/07/2020
//Description : Create Purchase order From Change Order.
public class CreatePOFromCO {
    @AuraEnabled

    public Static ResponseBase CreatePOMethod(string COId){
        system.debug('----->Init<----');
        ResponseBase response = new ResponseBase();
        Boolean isInComplete = false;
        try {
            buildertek__Change_Order__c CO = [
                Select
                    Id,
                    Name,
                    buildertek__Project__c,
                    buildertek__Budget__c,
                    buildertek__Customer_Account__c,
                    buildertek__Type__c,
                    buildertek__Status__c,
                    buildertek__Vendor__c ,
                    buildertek__Due_Date__c,
                    buildertek__Tax_Rate__c,
                    buildertek__Total_Amount_Tax__c
                from
                    buildertek__Change_Order__c
                where
                    Id =: COId
                ];

            List<buildertek__Change_Order_Item__c> COItemListWithVendor = [
                Select
                    Id,
                    Name,
                    buildertek__Item_Name__c,
                    buildertek__Cost_Code__c,
                    buildertek__Description__c,
                    buildertek__Product__c,
                    buildertek__Quantity__c,
                    buildertek__SubTotal__c,
                    buildertek__Markup__c,
                    buildertek__Discount__c,
                    buildertek__Total__c,
                    buildertek__Unit_Price__c ,
                    buildertek__Budget_Item__c,
                    buildertek__Tax_Rate__c,
                    buildertek__Vendor__c
                from
                    buildertek__Change_Order_Item__c
                where
                    buildertek__Change_Order__c =:CO.Id
            ];

            if(COItemListWithVendor == null || COItemListWithVendor.isEmpty())
            {
                response.strMessage = 'Please create at least one Change Order Line.';
                return response;
            }

            for(buildertek__Change_Order_Item__c coLineItem : COItemListWithVendor){
                if(coLineItem.buildertek__Vendor__c == null )
                {
                    isInComplete = true;
                    break;
                }
            }

            if(isInComplete && CO.buildertek__Vendor__c == NULL ){
                response.strMessage = 'Please choose a Vendor for the Change Order or for all the Change Order Lines.';
                return response;
            }

            if(isInComplete){

                buildertek__Purchase_Order__c PO1 = new buildertek__Purchase_Order__c();
                PO1.buildertek__Project__c = CO.buildertek__Project__c;
                PO1.buildertek__Status__c = 'Open';
                PO1.buildertek__Type__c = 'Contractor';
                PO1.buildertek__Vendor__c = CO.buildertek__Vendor__c;
                PO1.buildertek__Budget__c = CO.buildertek__Budget__c;
                PO1.buildertek__Change_Order__c = CO.Id;
                PO1.buildertek__Description__c = CO.Name;
                PO1.buildertek__Tax__c = CO.buildertek__Tax_Rate__c;
                insert PO1;
                system.debug('PO----------------------->>>>>>>>'+PO1);
                PO1.buildertek__Tax__c = CO.buildertek__Tax_Rate__c;
                update PO1;
                List<buildertek__Purchase_Order_Item__c> POLines = new List<buildertek__Purchase_Order_Item__c>();
                List<buildertek__Change_Order_Item__c> COItemList;

                COItemList = [Select Id, Name,buildertek__Item_Name__c,
                            buildertek__Cost_Code__c,
                            buildertek__Description__c,
                            buildertek__Product__c,
                            buildertek__Quantity__c,
                            buildertek__Total__c,
                            buildertek__Unit_Price__c ,
                            buildertek__Budget_Item__c,
                            buildertek__Tax_Rate__c
                            from buildertek__Change_Order_Item__c
                            where buildertek__Change_Order__c =:CO.Id];

                for(buildertek__Change_Order_Item__c COItem : COItemList){

                    buildertek__Purchase_Order_Item__c poitem = new buildertek__Purchase_Order_Item__c();

                    poitem.buildertek__Purchase_Order__c = PO1.Id;
                    poitem.Name = COItem.Name;
                    poitem.Cost_Code__c = COItem.buildertek__Cost_Code__c;
                    poitem.Description__c = COItem.buildertek__Description__c;
                    poitem.Product__c = COItem.buildertek__Product__c;
                    //poitem.Unit_Price__c = COItem.buildertek__Total__c;
                      poitem.Unit_Price__c = COItem.buildertek__Unit_Price__c;
                    poitem.buildertek__Budget_Item__c = COItem.buildertek__Budget_Item__c;
                    poitem.Quantity__c = COItem.buildertek__Quantity__c;
                    poitem.Tax__c = COItem.buildertek__Tax_Rate__c;
                    //poitem.buildertek__Change_Order_Item__c = COItem.Id;
                    POLines.add(poitem);
                }

                insert POLines;
                response.strMessage = 'Success';
                response.strRecordId = PO1.Id;
            }
            else{

                Map<string,list<buildertek__Change_Order_Item__c>> CoItemMap  = new  Map<string,list<buildertek__Change_Order_Item__c>>();

                List<buildertek__Purchase_Order_Item__c> POLines = new List<buildertek__Purchase_Order_Item__c>();
                for(buildertek__Change_Order_Item__c COItem : COItemListWithVendor){
                    if(CoItemMap.get(COItem.buildertek__Vendor__c) == null){
                        CoItemMap.put(COItem.buildertek__Vendor__c,new list<buildertek__Change_Order_Item__c>());
                    }
                    CoItemMap.get(COItem.buildertek__Vendor__c).add(COItem);
                }

                list<buildertek__Purchase_Order__c> PurchaseOrderlist = new list<buildertek__Purchase_Order__c>();
                for(string str : CoItemMap.keyset()){
                    buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
                    PO.buildertek__Project__c = CO.buildertek__Project__c;
                    PO.buildertek__Status__c = 'Open';
                    PO.buildertek__Type__c = 'Contractor';
                    PO.buildertek__Vendor__c = str;
                    PO.buildertek__Budget__c = CO.buildertek__Budget__c;
                    PO.buildertek__Change_Order__c = CO.Id;
                    PO.buildertek__Tax__c = CO.buildertek__Tax_Rate__c;
                    PurchaseOrderlist.add(Po);
                }

                insert PurchaseOrderlist;
                system.debug('----------->PurchaseOrderlist<------------'+PurchaseOrderlist);
                for(buildertek__Purchase_Order__c POorder : PurchaseOrderlist){
                    if(CoItemMap.get(POorder.buildertek__Vendor__c) != null){
                        for(buildertek__Change_Order_Item__c chngeOrder : CoItemMap.get(POorder.buildertek__Vendor__c)){
                            buildertek__Purchase_Order_Item__c poitem = new buildertek__Purchase_Order_Item__c();

                            poitem.buildertek__Purchase_Order__c = POorder.Id;
                            poitem.Name = chngeOrder.Name;
                            poitem.Cost_Code__c = chngeOrder.buildertek__Cost_Code__c;
                            poitem.Description__c = chngeOrder.buildertek__Description__c;
                            poitem.Product__c = chngeOrder.buildertek__Product__c;
                            //poitem.Unit_Price__c = chngeOrder.buildertek__Total__c;
                            poitem.Unit_Price__c = chngeOrder.buildertek__Unit_Price__c;
                            poitem.buildertek__Budget_Item__c = chngeOrder.buildertek__Budget_Item__c;
                            poitem.Quantity__c = chngeOrder.buildertek__Quantity__c;
                            poitem.Tax__c = chngeOrder.buildertek__Tax_Rate__c;
                           // poitem.buildertek__Change_Order_Item__c = COItem.Id;
                           // poitem.buildertek__Change_Order_Item__c = chngeOrder.Id;
                            POLines.add(poitem);
                        }
                    }
                }
                insert POLines;
            }
            response.strMessage = 'Success';
            return response;
        }
        catch(Exception ex){
            system.debug(ex + ' ex.getMessage() ' + ex.getMessage());
            response.strMessage = ex.getMessage();
            return response;
        }
    }

    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String strRecordId;
    }

}