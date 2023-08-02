public with sharing class ReceiveMaterialPOLinesController {
    
    @auraEnabled
    public static list<buildertek__Purchase_Order_Item__c> getProducts(String recordId)
    {
        //system.debug(recordId);
        list<buildertek__Purchase_Order_Item__c> Products =[select id,Name,buildertek__Purchase_Order__c, buildertek__Product__r.Name,buildertek__Product__r.Id,buildertek__Product__c,buildertek__Quantity__c, buildertek__Quantity_Remaining__c
        from buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =:recordId];
        system.debug(Products);
        return Products;
    }

    @auraEnabled
    public static boolean deleteDocument(String ContentDocumentId){
        List<ContentDocument> cd = [SELECT Id FROM ContentDocument WHERE Id =: ContentDocumentId];
        system.debug(cd);
        if(cd.size() >= 0){
            delete cd;
        }
        return true;
    }
    
    
    @auraEnabled
    public static boolean addProducts(String ProductsList , List<String> productId){
        
        //   list<Product2> prod = [select Id from Product2 where Id IN:= POItems ];
        // system.debug('workinggggg' + productId);
        boolean flag = false;
        Decimal old_quantity_recieved = 0;
        
        system.debug('productsKist'+ ProductsList);
        List<String> selectedProdIds = new List<String>();
        list<RfqDataTableWrapper> newProductList = (list<RfqDataTableWrapper>)JSON.deserialize(ProductsList, list<RfqDataTableWrapper>.class);
        List<buildertek__Inventory_Tracking__c> invTrackList= new List<buildertek__Inventory_Tracking__c>();
        Map<Id, List<string>> POLinetoCdId = new map<Id, List<string>>();
        
        //iterate over list and store the polineid in a list
        System.debug(newProductList);
        List<Id> polineIds = new List<Id>();
        for(RfqDataTableWrapper p: newProductList){
            polineIds.add(p.polineId);
            if(p.ContentDocumnetIdList != null){
                POLinetoCdId.put(p.polineId, p.ContentDocumnetIdList);
            }
        }
        System.debug(POLinetoCdId);
        //System.debug(polineIds);
        List<buildertek__Purchase_Order_Item__c> polineList = [Select Id , buildertek__Purchase_Order__c, buildertek__Product__c,buildertek__Item_Name__c,buildertek__Quantity_Received__c,buildertek__Product__r.buildertek__Available_Quantity__c,buildertek__Quantity_Remaining__c FROM buildertek__Purchase_Order_Item__c WHERE Id IN:polineIds];
        System.debug(polineList);
        for(buildertek__Purchase_Order_Item__c poline: polineList){
            if(newProductList[0].quantity_recieved != null){
                if(poline.buildertek__Quantity_Remaining__c - newProductList[0].quantity_recieved >= 0){
                    if(poline.buildertek__Quantity_Received__c == null){
                        poline.buildertek__Quantity_Received__c = newProductList[0].quantity_recieved;
                        flag = true;
                    }
                    else if(poline.buildertek__Quantity_Received__c != null){
                        old_quantity_recieved = poline.buildertek__Quantity_Received__c;
                        poline.buildertek__Quantity_Received__c = poline.buildertek__Quantity_Received__c + newProductList[0].quantity_recieved;
                    }
                }
            }else{
                return false;
            }
        }
        System.debug(polineList);
        update polineList;

        
        
        if (newProductList != null)
        {
            System.debug(newProductList);
            for(RfqDataTableWrapper p: newProductList){
                selectedProdIds.add(p.prodId);
                
            }
            List<Product2> newProdListToUpdate = new List<Product2>();
            Map<String,Decimal> prodMap = new Map<String,Decimal>();
            Decimal quant = 0;
            for(RfqDataTableWrapper newProd : newProductList){
                //prodMap.put(newProd.prodId, newProd.quantity_recieved);
                if(prodMap.containsKey(newProd.prodId)){
                    quant = prodMap.get(newProd.prodId);
                    System.debug(quant+ 'quant');
                    if(quant != null){
                        quant = quant+newProd.quantity_recieved;
                    }else{
                        quant = newProd.quantity_recieved;
                    }
                     prodMap.put(newProd.prodId, quant);
                }else{
                    prodMap.put(newProd.prodId, newProd.quantity_recieved);
                }
                //newProdListToUpdate.add(prodItem);
            }
            List<Product2> prodListToUpdate = [Select Id,buildertek__Available_Quantity__c FROM Product2 WHERE Id IN:productId];
    
            System.debug('prodMap.keySet()::::::::::' + prodMap.keySet());
            for(Product2 prod:prodListToUpdate){

                Product2 prodItem = new Product2();
                prodItem.Id = prod.Id;
                System.debug(prod.buildertek__Available_Quantity__c);
                System.debug(prodMap.get(prod.Id));

                if(prod.buildertek__Available_Quantity__c!= null && prodMap.get(prod.Id)!= null){
                    prodItem.buildertek__Available_Quantity__c =prod.buildertek__Available_Quantity__c+ prodMap.get(prod.Id);
                }else if(prod.buildertek__Available_Quantity__c == null && prodMap.get(prod.Id)!= null){
                    prodItem.buildertek__Available_Quantity__c = prodMap.get(prod.Id);
                }
                System.debug(prodItem.buildertek__Available_Quantity__c);

                system.debug(prodMap.get(prod.Id));
                newProdListToUpdate.add(prodItem);
                

            }
            update newProdListToUpdate;
            
            system.debug(newProdListToUpdate);

            for(buildertek__Purchase_Order_Item__c poline: polineList){
                buildertek__Inventory_Tracking__c  invTrack= new buildertek__Inventory_Tracking__c();
                invTrack.buildertek__Date_Received__c= Date.today();
                if(flag){
                    invTrack.buildertek__Old_Quantity__c= 0;
                }else{
                    invTrack.buildertek__Old_Quantity__c= old_quantity_recieved;
                }
                invTrack.buildertek__New_Quantity__c= poline.buildertek__Quantity_Received__c;
                invTrack.buildertek__Product__c= poline.buildertek__Product__c;
                invTrack.buildertek__Description__c= poline.buildertek__Item_Name__c;
                invTrack.buildertek__BT_Purchase_Order_Line__c= poline.Id;
                invTrack.buildertek__Purchase_Order__c= poline.buildertek__Purchase_Order__c;
                invTrackList.add(invTrack);

            }
            if(invTrackList.size() > 0){
                System.debug('invTrackList' + invTrackList);
                insert invTrackList;
            }

            //create a map of polineid and inventory tracking id
            Map<Id, Id> POLinetoInvTrackId = new map<Id, Id>();
            for(buildertek__Inventory_Tracking__c invTrack: invTrackList){
                POLinetoInvTrackId.put(invTrack.buildertek__BT_Purchase_Order_Line__c, invTrack.Id);
            }
            System.debug('POLinetoInvTrackId' + POLinetoInvTrackId);

            
            Map<Id, Id> ContentDocumentIdtoInvTrackId = new map<Id, Id>();
            for(Id polineId : POLinetoCdId.keySet()){
               List<Id> cdIdList = POLinetoCdId.get(polineId);
               Id invTrackId = POLinetoInvTrackId.get(polineId);
                for(Id cdId : cdIdList){
                     ContentDocumentIdtoInvTrackId.put(cdId, invTrackId);
                }
            }
            System.debug('ContentDocumentIdtoInvTrackId' + ContentDocumentIdtoInvTrackId);

            
            

            //create a contentdocumentlink list
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            for(Id cdId : ContentDocumentIdtoInvTrackId.keySet()){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cdId;
                cdl.LinkedEntityId = ContentDocumentIdtoInvTrackId.get(cdId);
                cdl.ShareType = 'V';
                cdlList.add(cdl);
            }
            System.debug('cdlList' + cdlList);
            if(cdlList.size() > 0){
                insert cdlList;
            }




            return true;
        }
        
        return false;
        
    }
    
    
    
 public class RfqDataTableWrapper{
      
        @AuraEnabled
        public Integer quantity_recieved{ get; set; }
        
        @AuraEnabled
        public Id prodId{ get; set; }

        @AuraEnabled
        public Id polineId{ get; set;}

        @AuraEnabled
        public List<String> ContentDocumnetIdList { get; set; }
    }
}