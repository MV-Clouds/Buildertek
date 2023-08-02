trigger CreateProductSKU on Product2 (Before Insert, After Insert, Before Update)
{
    Map<String,String> generationMap  = SKU_Trigger_Helper.loadMap('Generation');
    Map<String,String> colorMap = SKU_Trigger_Helper.loadMap('Color');
    Map<String,String> paneMap = SKU_Trigger_Helper.loadMap('Panes');
    Map<String,String> shapeMap = SKU_Trigger_Helper.loadMap('Shape');
    Map<String,String> lamiMap = SKU_Trigger_Helper.loadMap('Laminate');    
    String productSKU;
     
         
    if (trigger.isBefore && trigger.isInsert)   
    {
        //
        // Validate the fields used to generate the "intelligent" part of the SKU (first 5 characters)
        //
        for (Product2 prod : trigger.new)
        {
            if (prod.Family == 'IGU' || prod.Family == 'View IGU')
            {
                if (prod.Generation__c == null || !generationMap.containsKey(prod.Generation__c.toUpperCase()))
                {
                    prod.Generation__c.addError('Invalid value for Generation; please re-enter or update SKU Prefix Element Map');
                }
                 
                if (prod.Laminate__c == null || !lamiMap.containsKey(prod.Laminate__c.toUpperCase()))
                {
                    prod.Laminate__c.addError('Invalid value for Laminate; please re-enter or update SKU Prefix Element Map');
                }
                
                if (prod.Inboard_Lite__c == null || !colorMap.containsKey(prod.Inboard_Lite__c.toUpperCase()))
                {
                    prod.Inboard_Lite__c.addError('Invalid value for Inboard Lite: ' + prod.Inboard_Lite__c + '; please re-enter or update SKU Prefix Element Map');
                    
                }
                
                if (prod.Shape__c == null || !shapeMap.containsKey(prod.Shape__c.toUpperCase()))
                {
                    prod.Shape__c.addError('Invalid value for Shape; please re-enter or update SKU Prefix Element Map');
                }
                
                if (prod.Panes__c == null || !paneMap.containsKey(prod.Panes__c.toUpperCase()))
                {
                    prod.Panes__c.addError('Invalid value for Panes; please re-enter or update SKU Prefix Element Map');
                }
            }
        }       
    }
    
    if (trigger.isAfter && trigger.isInsert)        
    {
        //
        // Product_SKU__c must be genearated After Insert because the Sequence Product_SKU__c is not generated until AFTER the record is inserted
        //
        List<Product2> newProductList = [SELECT Id, Family, ProductCode, Generation__c, Laminate__c, Inboard_Lite__c, Shape__c, Panes__c,  
             SKU_Sequence__c, Product_SKU__c FROM Product2 WHERE id IN :trigger.newMap.keySet()];
        for (Product2 prod : newProductList)
        {
            // JV - 20171031 - Correction to following from "View IGU" to "View" and "IGU"
            if (prod.family != 'IGU' && prod.family != 'View')
            {
                prod.Product_SKU__c = prod.ProductCode;             
            }
            else
            {
                productSKU = generationMap.get(prod.Generation__c.toUpperCase());
                productSKU = productSKU + lamiMap.get(prod.Laminate__c.toUpperCase());
                productSKU = productSKU + colorMap.get(prod.Inboard_Lite__c.toUpperCase());
                productSKU = productSKU + shapeMap.get(prod.Shape__c.toUpperCase());
                productSKU = productSKU + paneMap.get(prod.Panes__c.toUpperCase());
                productSKU = productSKU + '-' + SKU_Trigger_Helper.toBase36(Integer.valueOf(prod.SKU_Sequence__c),4);
                prod.Product_SKU__c = productSKU;
            }
        }   
        update newProductList;  
    }
    
    if (trigger.isBefore && trigger.isUpdate)
    {
        //
        // Once the SKU has been generated, do not allow the fields used to generate the "intelligent" segment of the SKU (first 5 characters)
        // to be updated
        //
        for (product2 prod : trigger.new)
        {
            if (prod.Family == 'IGU' && trigger.oldMap.get(prod.Id).Product_SKU__c != null)
            {
                if ((prod.Generation__c != null && trigger.oldMap.get(prod.Id).Generation__c == null) ||
                    (prod.Generation__c == null && trigger.oldMap.get(prod.Id).Generation__c != null) ||
                    (prod.Generation__c != null && trigger.oldMap.get(prod.Id).Generation__c != null && 
                     prod.Generation__c.toUpperCase() != trigger.oldMap.get(prod.Id).Generation__c.toUpperCase()))
                {
                    prod.Generation__c.addError('Generation is an IGU SKU key field and may not be updated');
                }               
                if ((prod.Laminate__c != null && trigger.oldMap.get(prod.Id).Laminate__c == null) ||
                    (prod.Laminate__c == null && trigger.oldMap.get(prod.Id).Laminate__c != null) ||
                    (prod.Laminate__c != null && trigger.oldMap.get(prod.Id).Laminate__c != null && 
                     prod.Laminate__c.toUpperCase() != trigger.oldMap.get(prod.Id).Laminate__c.toUpperCase()))
                {
                    prod.Laminate__c.addError('Laminate is an IGU SKU key field and may not be updated');
                }
                if ((prod.Inboard_Lite__c != null && trigger.oldMap.get(prod.Id).Inboard_Lite__c == null) ||
                    (prod.Inboard_Lite__c == null && trigger.oldMap.get(prod.Id).Inboard_Lite__c != null) ||
                    (prod.Inboard_Lite__c != null && trigger.oldMap.get(prod.Id).Inboard_Lite__c != null && 
                     prod.Inboard_Lite__c.toUpperCase() != trigger.oldMap.get(prod.Id).Inboard_Lite__c.toUpperCase()))
                {
                    prod.Inboard_Lite__c.addError('Inboard Lite is an IGU SKU key field and may not be updated');
                }
                if ((prod.Panes__c != null && trigger.oldMap.get(prod.Id).Panes__c == null) ||
                    (prod.Panes__c == null && trigger.oldMap.get(prod.Id).Panes__c != null) ||
                    (prod.Panes__c != null && trigger.oldMap.get(prod.Id).Panes__c != null && 
                     prod.Panes__c.toUpperCase() != trigger.oldMap.get(prod.Id).Panes__c.toUpperCase()))
                {
                    prod.Panes__c.addError('Panes is an IGU SKU key field and may not be updated');
                }
                if ((prod.Shape__c != null && trigger.oldMap.get(prod.Id).Shape__c == null) ||
                    (prod.Shape__c == null && trigger.oldMap.get(prod.Id).Shape__c != null) ||
                    (prod.Shape__c != null && trigger.oldMap.get(prod.Id).Shape__c != null && 
                     prod.Shape__c.toUpperCase() != trigger.oldMap.get(prod.Id).Shape__c.toUpperCase()))
                {
                    prod.Shape__c.addError('Shape is an IGU SKU key field and may not be updated');
                }
            }
        }
    }
}