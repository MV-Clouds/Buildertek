public class UpdateInspectionLineController {

	public List<buildertek__Inspection_Line__c> inslines {get; private set;}    //For Inspection Line Item List
    public buildertek__Inspection_Line__c ins{get;set;}
    public String inspectionId {get;set;}   //Inspection Id
 
    private ApexPages.StandardSetController sctrl;  

    public UpdateInspectionLineController(ApexPages.StandardSetController stdSetController){    //Standard Controller to get list of object
      
        this.sctrl = stdSetController;        
        inspectionId = System.currentPageReference().getParameters().get('id'); //Get Current Record Id
        inslines = [SELECT Id, Name, buildertek__Inspection_Item__c, buildertek__Status__c, buildertek__Date_Inspected__c, buildertek__Inspection_Item_Name__c,buildertek__Description__c,buildertek__Inspected_By__r.Name,buildertek__Comments__c FROM buildertek__Inspection_Line__c WHERE buildertek__Inspection__c = :inspectionId]; 
    }
    
    
    public PageReference save(){    //Saves the Inspection lines record
        try{
            update inslines;
        }catch(Exception e){
            System.debug('Exception: ' + e);
        }
        return null;
    }

    public PageReference redirectURL(){     //Redirect to Previous Page on click cancel
        PageReference cancel = sctrl.cancel();
        return cancel;
    }
   
}