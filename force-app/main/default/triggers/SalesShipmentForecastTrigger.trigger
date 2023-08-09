trigger SalesShipmentForecastTrigger on Sales_Shipment_Forecast__c (Before Insert, Before Update, After Insert, After Update, Before Delete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('Before Trigger');    
            SalesShipmentForecastTriggerHandler.createSalesShipmentForecaseLines(Trigger.newMap);
            System.debug('After Trigger');
        }
        /*if(Trigger.isUpdate){
            System.debug('Before Trigger');    
            SalesShipmentForeCastTriggerHandler.updateSalesShipmentForeCaseLines(Trigger.newMap, Trigger.oldMap);
            System.debug('After Trigger');
        }*/
    }

}