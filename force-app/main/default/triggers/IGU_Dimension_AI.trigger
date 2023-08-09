trigger IGU_Dimension_AI on IGU_Dimension__c (After Insert) 
{
    public final Map<String,String> uomMap = new Map<String,String> {'Imperial'=>'1', 'Metric'=>'2'};
    public final Map<String,String> shapeMap = new Map<String,String> {'Rectangle'=>'0', 'Triangle - 45'=>'45', 'Triangle - 46'=>'46', 'Trapezoid - 1'=>'1', 'Trapezoid - 2'=>'2', 
        'Trapezoid - 301'=>'301', 'Trapezoid - 302'=>'302'};
        
    if (trigger.isAfter && trigger.isInsert)  
    {
        Set<Id> igdIds = new Set<Id>();
        

        for(IGU_Dimension__c igd : trigger.new)
        {
            igdIds.add(igd.Id);
        }
        List<IGU_Dimension__c> newIGUDimensions = [SELECT Id, Name, Order_SKU_Suffix__c, Search_Key__c, Unit_of_Measure__c, Shape__c, Base_in__c, Height_in__c, Base_Height_1_in__c,
            Base_mm__c, Height_mm__c, Base_Height_1_mm__c FROM IGU_Dimension__c WHERE Id IN :igdIds];
        for (IGU_Dimension__c igd : newIGUDimensions)
        {           
            if(igd.Unit_of_Measure__c == 'IMPERIAL')
            {
                igd.Search_Key__c = uomMap.get(igd.Unit_of_Measure__c) + '\t' + shapeMap.get(igd.Shape__c) + '\t' + String.valueOf(igd.base_in__c) + '\t' + String.valueOf(igd.height_in__c) + '\t' + String.valueOf(igd.base_height_1_in__c);
            }
            else
            {
                igd.Search_Key__c = uomMap.get(igd.Unit_of_Measure__c) + '\t' + shapeMap.get(igd.Shape__c) + '\t' + String.valueOf(igd.base_mm__c) + '\t' + String.valueOf(igd.height_mm__c) + '\t' + String.valueOf(igd.base_height_1_mm__c);              
            }
            igd.Order_SKU_Suffix__c = SKU_Trigger_Helper.toBase36(Integer.valueOf(igd.Name),5);
        }
        update newIGUDimensions;
    }
}